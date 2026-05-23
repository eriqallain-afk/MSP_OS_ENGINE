# INFRA-AD-EntraID_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__EntraID_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-CloudMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — Microsoft 365 / Entra ID
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS ADMINISTRATION

| Portail | URL |
|---|---|
| **Entra Admin Center** | https://entra.microsoft.com |
| **Azure Portal** | https://portal.azure.com |
| **M365 Admin** | https://admin.microsoft.com |
| **PowerShell** | `Connect-MgGraph` (Microsoft Graph) ou `Connect-AzureAD` |

---

## 2. CONNEXION POWERSHELL ENTRA ID

```powershell
# Microsoft Graph (recommandé)
Install-Module Microsoft.Graph -Force
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"

# AzureAD Legacy (encore supporté)
Install-Module AzureAD -Force
Connect-AzureAD
```

---

## 3. GESTION DES UTILISATEURS ENTRA ID

### Créer un utilisateur
```powershell
# Via Microsoft Graph
$PasswordProfile = @{
    Password = "<TEMP_PASSWORD>!"
    ForceChangePasswordNextSignIn = $true
}
New-MgUser -DisplayName "Prénom Nom" `
    -UserPrincipalName "prenom.nom@domaine.com" `
    -MailNickname "prenom.nom" `
    -AccountEnabled $true `
    -PasswordProfile $PasswordProfile `
    -Department "Département" `
    -JobTitle "Titre"
```

### Désactiver un compte (départ employé)
```powershell
# ⚠️ Désactiver ET révoquer les sessions
$userId = (Get-MgUser -Filter "UserPrincipalName eq 'utilisateur@domaine.com'").Id

# 1. Désactiver le compte
Update-MgUser -UserId $userId -AccountEnabled $false

# 2. Révoquer toutes les sessions et tokens (CRITIQUE si compromission)
Revoke-MgUserSignInSession -UserId $userId

# 3. Réinitialiser le mot de passe
$NewPassword = @{
    Password = "TempPW$(Get-Random -Maximum 9999)!"
    ForceChangePasswordNextSignIn = $true
}
Update-MgUserPassword -UserId $userId -PasswordProfile $NewPassword
```

---

## 4. AUDIT CONNEXIONS SUSPECTES

```powershell
# Connexions des 7 derniers jours pour un utilisateur
Get-MgAuditLogSignIn -Filter "userPrincipalName eq 'utilisateur@domaine.com'" `
    -Top 50 | Select-Object CreatedDateTime, AppDisplayName, IpAddress,
    Location, Status, RiskLevelAggregated | Format-Table -AutoSize

# Connexions à risque élevé dans le tenant
Get-MgAuditLogSignIn -Filter "riskLevelAggregated eq 'high'" -Top 50 |
    Select-Object CreatedDateTime, UserPrincipalName, IpAddress, RiskDetail | Format-Table
```

---

## 5. GESTION MFA / MÉTHODES D'AUTHENTIFICATION

```powershell
# Vérifier les méthodes d'auth d'un utilisateur
Get-MgUserAuthenticationMethod -UserId "utilisateur@domaine.com" |
    Select-Object OdataType, Id | Format-Table

# Réinitialiser les méthodes MFA (forcer re-enregistrement)
# Via portail : Entra ID → Utilisateurs → [Utilisateur] → Authentication methods
# → Cliquer "Require re-register MFA"

# Liste des utilisateurs sans MFA
Get-MgUser -All -Property UserPrincipalName,DisplayName |
    ForEach-Object {
        $methods = Get-MgUserAuthenticationMethod -UserId $_.Id
        if ($methods.Count -le 1) {  # Seulement mot de passe
            [pscustomobject]@{UPN=$_.UserPrincipalName; DisplayName=$_.DisplayName; MFAMethods=$methods.Count}
        }
    } | Format-Table
```

---

## 6. ACCÈS CONDITIONNEL — VÉRIFICATION

```
Entra Admin Center → Protection → Accès conditionnel → Stratégies
→ Lister les stratégies actives
→ Vérifier qu'elles ne bloquent pas les utilisateurs légitimes

Si un utilisateur est bloqué :
1. Entra Admin Center → Utilisateurs → [Utilisateur] → Sign-in logs
2. Identifier quelle stratégie CA bloque l'accès
3. Vérifier les conditions : localisation, appareil, application
4. Exclure temporairement si urgence (documenter dans CW)
⛔ NE PAS désactiver une stratégie CA pour un seul utilisateur — utiliser les exclusions
```

---

## 7. GESTION DES APPLICATIONS (CONSENTEMENTS OAUTH)

```powershell
# Lister les applications tierces avec consentement utilisateur
Get-MgUserOauth2PermissionGrant -UserId "utilisateur@domaine.com" |
    Select-Object ClientId, Scope, ConsentType | Format-Table

# Lister toutes les applications entreprise
Get-MgServicePrincipal -All | Where-Object {$_.Tags -contains "WindowsAzureActiveDirectoryIntegratedApp"} |
    Select-Object DisplayName, AppId, AccountEnabled | Format-Table

# Révoquer un consentement OAuth suspect
Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId "[ID]"
```

---

## 8. SYNCHRONISATION HYBRID (ENTRA CONNECT)

```powershell
# Sur le serveur où Entra Connect est installé
Import-Module ADSync

# État de la synchronisation
Get-ADSyncScheduler

# Forcer une synchronisation Delta
Start-ADSyncSyncCycle -PolicyType Delta

# Forcer une synchronisation complète (plus long)
Start-ADSyncSyncCycle -PolicyType Initial

# Vérifier les erreurs de synchronisation
Get-ADSyncConnectorRunStatus | Format-List
```

---

## 9. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer un compte Entra ID sans avoir vérifié s'il a des licences, données, permissions
⛔ NE JAMAIS désactiver une stratégie d'Accès Conditionnel globale sans test préalable
⛔ NE JAMAIS approuver des consentements OAuth d'applications inconnues
⛔ NE PAS créer des comptes admin Global Administrator pour des besoins temporaires
   → Utiliser le rôle minimum requis (Principle of Least Privilege)
⛔ NE JAMAIS configurer Entra Connect en mode complet (Initial) en heures de production
```

---

## 10. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Compte admin compromis | SOC | Immédiat |
| Accès conditionnel bloque > 10 utilisateurs | TECH | Immédiat |
| Synchronisation Entra Connect bloquée > 3h | INFRA | Dans l'heure |
| Consentement OAuth suspect détecté | SOC | Dans l'heure |
