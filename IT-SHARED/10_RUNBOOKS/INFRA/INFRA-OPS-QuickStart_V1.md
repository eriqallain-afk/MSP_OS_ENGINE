# INFRA-OPS-QuickStart_V1
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__Quick_Start | **Version :** 2.1
**Agent owner :** IT-CloudMaster | **Équipe :** TEAM__IT
**Domaine :** INFRA — Cloud & M365
**Date révision :** 2026-03-20 — Agent escalade mis à jour (v2.1)
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

---

## ⚠️ GARDE-FOUS — OBLIGATOIRES
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement les tâches Cloud/M365/Azure liées au billet actif.
Toute demande hors Cloud IT → refus et redirection.

**Données sensibles :**
- ❌ JAMAIS : clés API Azure, secrets d'application, IDs de tenant dans les livrables client
- ❌ JAMAIS : mots de passe temporaires en clair dans les outputs
- ❌ Dans livrables client : UPN complets, IDs d'objets Azure AD
- Les credentials sont créés et transmis **hors CW** (canal sécurisé séparé)

**Actions :**
- Avant suppression d'un compte → `⚠️ Impact : perte définitive si > 30 jours sans restauration`
- Avant modification de politiques MFA/CA → `⚠️ Impact : potentiel lockout utilisateurs`

---

## 1. Objectif
Guide de démarrage rapide pour les opérations cloud courantes :
- Gestion utilisateurs Microsoft 365
- Configuration Azure AD / Entra ID
- Dépannage Exchange Online
- Configuration Teams Phone / SharePoint

---

## 2. Connexion aux services (prérequis)

### 2.1 Modules PowerShell requis
```powershell
# Vérifier les modules installés
$modules = @('Microsoft.Graph', 'ExchangeOnlineManagement', 'MicrosoftTeams',
             'AzureAD', 'MSOnline', 'SharePointPnPPowerShellOnline')
foreach ($m in $modules) {
  $installed = Get-Module -ListAvailable -Name $m | Select-Object -First 1
  [pscustomobject]@{Module=$m; Installé=if($installed){"✓ $($installed.Version)"}else{"✗ Manquant"}}
}
```

### 2.2 Connexion (interactive — sans stocker credentials)
```powershell
# Microsoft Graph (remplace AzureAD et MSOnline)
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"

# Exchange Online
Connect-ExchangeOnline -UserPrincipalName "[ADMIN-UPN]"   # UPN non stocké dans CW

# Teams
Connect-MicrosoftTeams
```

---

## 3. Opérations courantes

### 3.1 Vérification état locataire M365
```powershell
# Licences disponibles (lecture seule)
Get-MgSubscribedSku | Select-Object SkuPartNumber,
  @{n='Achetées';e={$_.PrepaidUnits.Enabled}},
  @{n='Utilisées';e={$_.ConsumedUnits}},
  @{n='Libres';e={$_.PrepaidUnits.Enabled - $_.ConsumedUnits}} |
  Format-Table -Auto

# Comptes récemment créés (30 derniers jours)
Get-MgUser -Filter "createdDateTime ge $(((Get-Date).AddDays(-30)).ToString('yyyy-MM-dd'))" |
  Select-Object DisplayName, UserPrincipalName, CreatedDateTime | Format-Table -Auto

# Comptes sans licence
Get-MgUser -All | Where-Object {-not $_.AssignedLicenses} |
  Select-Object DisplayName, UserPrincipalName | Format-Table -Auto
```

### 3.2 Dépannage accès M365 — Arbre décision
```
Utilisateur ne peut pas se connecter
├── MFA bloqué ?
│   → Vérifier méthodes auth + réinitialiser si nécessaire
│   → Commande : Get-MgUserAuthenticationMethod -UserId [UPN]
├── Compte verrouillé ?
│   → Vérifier dans Azure AD : "Sign-in activity" 
│   → Update-MgUser -UserId [UPN] -AccountEnabled $true
├── Licence expirée / non assignée ?
│   → Get-MgUserLicenseDetail -UserId [UPN]
└── Conditional Access bloque ?
    → Vérifier les politiques CA appliquées à l'utilisateur
    → Azure AD > Monitoring > Sign-in logs
```

### 3.3 Problème Exchange Online (email)
```powershell
# État de la boîte aux lettres
Get-EXOMailbox -Identity "[UPN]" |
  Select-Object DisplayName, PrimarySmtpAddress, LitigationHoldEnabled,
                HiddenFromAddressListsEnabled, RecipientTypeDetails | Format-List

# Test de flux de messagerie
Get-MessageTrace -RecipientAddress "[UPN]" -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date) |
  Select-Object -First 10 Received, SenderAddress, RecipientAddress, Status, Subject | Format-Table -Auto

# Quota boîte (sans afficher données personnelles)
Get-EXOMailboxStatistics -Identity "[UPN]" |
  Select-Object @{n='Taille';e={$_.TotalItemSize}},
    @{n='Nb_items';e={$_.ItemCount}},
    @{n='Quota_avertissement';e={$_.IssueWarningQuota}} | Format-List
```

---

## 4. Configuration — Bonnes pratiques sécurité M365

### 4.1 Checklist sécurité baseline nouveau locataire
- [ ] MFA activé pour tous les admins (Conditional Access ou Security Defaults)
- [ ] Legacy authentication bloquée (Basic Auth)
- [ ] Self-service password reset configuré
- [ ] Audit Logging activé (`Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $True`)
- [ ] Safe Links / Safe Attachments activés (Defender for M365)
- [ ] SPF / DKIM / DMARC configurés pour le domaine
- [ ] Rôles admin sur comptes dédiés (pas de comptes utilisateur normaux comme admins)

### 4.2 Politique MFA recommandée
```
Obligatoire : tous les utilisateurs (pas uniquement admins)
Méthode     : Microsoft Authenticator (app) — premier choix
              SMS : acceptable comme fallback
Exclusion   : comptes de service → authentification par certificat
```

---

## 5. Livrables CW

### Note interne
```
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Service concerné : [M365 / Azure / Exchange / Teams]
Action effectuée : [description technique — sans credentials ni IDs sensibles]
Résultat         : [OK / WARNING — détails]
Validation       : [test effectué — résultat]
Prochaines étapes : [monitoring / [aucune]]
```

### Discussion client (client-safe)
```
- Analyse de la demande et vérification de l'environnement Microsoft 365.
- [Action effectuée : ex: Configuration du compte / correction de l'accès email].
- Validation du bon fonctionnement.
- Prochaine étape : [test utilisateur / surveillance / aucune action requise].
```

---

## 6. Escalade
- Incident M365 global (Microsoft outage) → vérifier `status.office365.com` + `IT-Commandare-NOC`
- Compromission compte admin → `IT-SecurityMaster` IMMÉDIAT
- Configuration hybride complexe (ADFS, Azure AD Connect) → `IT-Commandare-TECH`
