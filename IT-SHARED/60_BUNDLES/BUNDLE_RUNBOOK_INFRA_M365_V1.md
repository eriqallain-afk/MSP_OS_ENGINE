# BUNDLE RUNBOOK INFRA M365 V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-CloudMaster, IT-Assistant-N2, IT-Assistant-N3 | IT-MaintenanceMaster | IT-SysAdmin
**Description :** Microsoft 365 — Exchange Online, Entra ID, Teams/SharePoint/OneDrive, Intune, Conformité
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__M365_Exchange_Online_V1 -->
## RUNBOOK — Exchange Online et Messagerie

# RUNBOOK — Microsoft 365 : Exchange Online & Messagerie
**ID :** RUNBOOK__M365_Exchange_Online_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3, IT-CloudMaster
**Domaine :** INFRA — Microsoft 365
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS ADMINISTRATION EXCHANGE

| Portail | URL |
|---|---|
| **Exchange Admin Center (EAC)** | https://admin.exchange.microsoft.com |
| **M365 Admin Center** | https://admin.microsoft.com |
| **Azure Portal (Entra ID)** | https://portal.azure.com |
| **PowerShell Exchange Online** | `Connect-ExchangeOnline -UserPrincipalName <ADMIN_UPN>.com` |

---

## 2. CONNEXION POWERSHELL EXCHANGE ONLINE

```powershell
# Installer le module si nécessaire (une seule fois)
Install-Module -Name ExchangeOnlineManagement -Force

# Connexion
Connect-ExchangeOnline -UserPrincipalName "<ADMIN_UPN>.com"

# Déconnexion après utilisation
Disconnect-ExchangeOnline -Confirm:$false
```

---

## 3. GESTION DES BOÎTES AUX LETTRES

### Créer une boîte aux lettres
```powershell
# ⚠️ Nécessite une licence Exchange Online assignée à l'utilisateur
# Assigner la licence dans M365 Admin → Users → Active Users → Licenses

# Créer un utilisateur avec boîte aux lettres
New-Mailbox -Name "Prénom Nom" -UserPrincipalName "prenom.nom@domaine.com" `
    -Password (Read-Host -AsSecureString) `
    -DisplayName "Prénom Nom" -FirstName "Prénom" -LastName "Nom"
```

### Boîte aux lettres partagée
```powershell
# Créer une boîte partagée (ne requiert pas de licence)
New-Mailbox -Shared -Name "info" -DisplayName "Info Général" `
    -Alias "info" -PrimarySmtpAddress "info@domaine.com"

# Donner accès à des utilisateurs
Add-MailboxPermission -Identity "info@domaine.com" -User "prenom.nom@domaine.com" `
    -AccessRights FullAccess -InheritanceType All -AutoMapping:$true

# Donner droit d'envoi
Add-RecipientPermission "info@domaine.com" -Trustee "prenom.nom@domaine.com" `
    -AccessRights SendAs -Confirm:$false
```

### Vérifier les permissions d'une boîte
```powershell
# Qui a accès à cette boîte ?
Get-MailboxPermission "info@domaine.com" | Where-Object {$_.User -notmatch "NT AUTHORITY"} |
    Select-Object Identity, User, AccessRights | Format-Table -AutoSize

# Droit SendAs
Get-RecipientPermission "info@domaine.com" | Where-Object {$_.Trustee -notmatch "NT AUTHORITY"}
```

---

## 4. DÉPANNAGE EMAIL — ENVOI/RÉCEPTION

### Tracer un message (Message Trace)
```
Exchange Admin Center → Mail flow → Message trace
→ Entrer : expéditeur, destinataire, plage de dates (max 10 jours)
→ Résultats : Delivered / Failed / Filtered / Pending

Via PowerShell :
Get-MessageTrace -SenderAddress "expediteur@domaine.com" `
    -RecipientAddress "destinataire@domaine.com" `
    -StartDate (Get-Date).AddDays(-2) -EndDate (Get-Date) |
    Select-Object Received, SenderAddress, RecipientAddress, Status | Format-Table
```

### Messages bloqués / en quarantaine
```
Security Admin Center (protection.office.com) → Review → Quarantine
→ Chercher les messages retenus
→ Libérer ou supprimer
```

---

## 5. VÉRIFICATION RÈGLES OUTLOOK SUSPECTES

```
⚠️ Action prioritaire en cas de compromission de compte
```

```powershell
# Voir toutes les règles Outlook d'un utilisateur
Get-InboxRule -Mailbox "utilisateur@domaine.com" |
    Select-Object Name, Enabled, Description, ForwardTo, ForwardAsAttachmentTo,
    RedirectTo, DeleteMessage, MoveToFolder | Format-List

# Supprimer une règle suspecte
Remove-InboxRule -Mailbox "utilisateur@domaine.com" -Identity "Nom de la règle"

# Voir les transferts automatiques (ForwardingSmtpAddress)
Get-Mailbox "utilisateur@domaine.com" | Select-Object DisplayName, ForwardingSmtpAddress, DeliverToMailboxAndForward

# Supprimer un transfert automatique suspect
Set-Mailbox "utilisateur@domaine.com" -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false
```

---

## 6. VÉRIFICATION ACTIVITÉ DE CONNEXION SUSPECTE

```powershell
# Voir les connexions récentes (30 jours)
Get-MailboxStatistics "utilisateur@domaine.com" |
    Select-Object LastLogonTime, LastUserActionTime | Format-List

# Audit log — connexions et actions sur la boîte
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) `
    -UserIds "utilisateur@domaine.com" -Operations "MailboxLogin,Send,Create" |
    Select-Object CreationDate, UserIds, Operations, AuditData | Format-Table
```

---

## 7. LISTES DE DISTRIBUTION ET GROUPES M365

```powershell
# Lister les membres d'un groupe
Get-DistributionGroupMember "NomGroupe@domaine.com" |
    Select-Object Name, PrimarySmtpAddress | Format-Table

# Ajouter un membre
Add-DistributionGroupMember -Identity "NomGroupe@domaine.com" -Member "utilisateur@domaine.com"

# Retirer un membre
Remove-DistributionGroupMember -Identity "NomGroupe@domaine.com" -Member "utilisateur@domaine.com" -Confirm:$false
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer une boîte aux lettres sans avoir vérifié les données importantes
⛔ NE JAMAIS désactiver le compte avant d'avoir transféré/archivé les données
   si requis par le client
⛔ NE JAMAIS envoyer des credentials de boîte partagée par email
⛔ NE PAS créer des règles de transfert vers des domaines externes sans approbation
⛔ NE JAMAIS modifier les connecteurs mail sans avoir testé en environnement de test
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Tous les utilisateurs ne reçoivent pas d'emails | NOC + TECH | Immédiat |
| Compte compromis avec règles de transfert suspectes | SOC | Immédiat |
| Queue mail bloquée (spam sortant) | SOC + TECH | Dans l'heure |
| Problème de licence Exchange (boîtes désactivées) | TECH | Dans l'heure |


---
<!-- SOURCE: RUNBOOK__EntraID_Operations_V1 -->
## RUNBOOK — Entra ID (Azure AD) Opérations et Sécurité

# RUNBOOK — Microsoft Entra ID (Azure AD) : Opérations & Sécurité
**ID :** RUNBOOK__EntraID_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-CloudMaster
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


---
<!-- SOURCE: RUNBOOK__M365_Teams_SharePoint_OneDrive_V1 -->
## RUNBOOK — Teams, SharePoint et OneDrive

# RUNBOOK — Microsoft 365 : Teams, SharePoint & OneDrive
**ID :** RUNBOOK__M365_Teams_SharePoint_OneDrive_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3, IT-CloudMaster
**Domaine :** INFRA — Microsoft 365
**Mis à jour :** 2026-03-20

---

## 1. MICROSOFT TEAMS — DÉPANNAGE

### Arbre de décision Teams
```
L'utilisateur ne peut pas accéder à Teams
│
├─ Impossible de se connecter
│   → Vérifier compte M365 actif + licence Teams assignée
│   → Vérifier Accès conditionnel (Entra ID) qui bloque
│
├─ Teams s'ouvre mais les canaux/équipes sont vides
│   → Vérifier appartenance aux équipes dans Teams Admin
│   → Vérifier que l'utilisateur n'a pas été retiré des groupes
│
├─ Teams lent / instable
│   → Vider le cache Teams (voir procédure ci-dessous)
│   → Vérifier la connexion Internet (bande passante)
│
└─ Fonctionnalité spécifique ne fonctionne pas (appels, réunions)
    → Vérifier la licence (Teams Phone requis pour appels PSTN)
    → Vérifier les politiques Teams Admin
```

### Vider le cache Teams (Windows)
```powershell
# Fermer Teams complètement d'abord
Get-Process -Name "Teams" -ErrorAction SilentlyContinue | Stop-Process -Force

# Vider le cache
$CachePath = "$env:APPDATA\Microsoft\Teams"
$Folders = @("Cache","Code Cache","GPUCache","databases","Local Storage","tmp")
foreach ($f in $Folders) {
    $path = Join-Path $CachePath $f
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Vidé : $path"
    }
}
Write-Host "Cache Teams vidé. Redémarrer Teams."
```

### Gestion Teams via PowerShell
```powershell
# Connexion
Install-Module MicrosoftTeams -Force
Connect-MicrosoftTeams

# Lister toutes les équipes
Get-Team | Select-Object DisplayName, GroupId, Visibility, Archived | Format-Table -AutoSize

# Membres d'une équipe
Get-TeamMember -GroupId "[GROUP_ID]" | Select-Object User, Role | Format-Table

# Ajouter un membre à une équipe
Add-TeamMember -GroupId "[GROUP_ID]" -User "utilisateur@domaine.com"

# Créer une nouvelle équipe
$team = New-Team -DisplayName "Nom Équipe" -Description "Description" -Visibility "Private"
# Ajouter des membres
Add-TeamMember -GroupId $team.GroupId -User "utilisateur@domaine.com"
```

---

## 2. SHAREPOINT ONLINE — GESTION ET DÉPANNAGE

### Vérification d'accès SharePoint
```
⚠️ RÈGLE : NE JAMAIS donner l'accès SharePoint sans autorisation du propriétaire du site

Procédure :
1. Identifier le propriétaire du site : SharePoint Admin → Sites → [Site] → Owners
2. Obtenir l'autorisation du propriétaire (écrit)
3. Ajouter l'utilisateur au bon groupe :
   → Visiteurs = lecture seule
   → Membres = lecture/écriture
   → Propriétaires = contrôle total
```

```powershell
# Connexion SharePoint Online
Install-Module PnP.PowerShell -Force
Connect-PnPOnline -Url "https://[tenant].sharepoint.com" -Interactive

# Lister les sites
Get-PnPTenantSite | Select-Object Title, Url, Template, StorageUsageCurrent | Format-Table -AutoSize

# Membres d'un groupe SharePoint
$site = "https://[tenant].sharepoint.com/sites/[NomSite]"
Connect-PnPOnline -Url $site -Interactive
Get-PnPGroup | ForEach-Object {
    $g = $_
    $members = Get-PnPGroupMember -Group $g.Title
    [pscustomobject]@{Group=$g.Title; Members=($members.Title -join ", ")}
} | Format-Table -AutoSize

# Ajouter un utilisateur au groupe Membres
Add-PnPGroupMember -LoginName "utilisateur@domaine.com" -Group "NomSite Members"
```

### Dépannage accès refusé SharePoint
```
1. L'utilisateur reçoit "Access Denied"
   → Vérifier qu'il est bien dans le bon groupe SharePoint
   → Vérifier que l'héritage des permissions est activé (pas de rupture d'héritage sur le sous-dossier)

2. Le site n'apparaît pas dans la liste des sites de l'utilisateur
   → S'assurer que l'utilisateur est ajouté au groupe ET que le site est partagé avec lui
   → Vérifier la visibilité du site (Private vs Public)

3. Quota dépassé
   SharePoint Admin → Sites → [Site] → Storage
   → Augmenter le quota ou archiver du contenu
```

---

## 3. ONEDRIVE — SYNCHRONISATION ET DÉPANNAGE

### Problèmes de synchronisation OneDrive
```powershell
# Vérifier l'état OneDrive (commande sur le poste)
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /status

# Réinitialiser OneDrive (résout la majorité des problèmes)
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset

# Redémarrer OneDrive après reset
Start-Sleep -Seconds 5
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
Write-Host "OneDrive relancé — attendre 1-2 min pour resynchronisation"
```

### Gestion OneDrive admin
```powershell
# Voir le quota OneDrive d'un utilisateur
Connect-SPOService -Url "https://[tenant]-admin.sharepoint.com"
Get-SPOSite -IncludePersonalSite $true -Limit All -Filter "Url -like '-my.sharepoint.com/personal/'" |
    Select-Object Url, StorageUsageCurrent, StorageQuota | Format-Table -AutoSize

# Augmenter le quota d'un utilisateur
Set-SPOSite -Identity "https://[tenant]-my.sharepoint.com/personal/[UPN_encodé]" -StorageQuota 50000
```

### Fichiers coincés en synchronisation
```
Sur le poste utilisateur :
1. Clic droit sur l'icône OneDrive (barre des tâches) → Afficher les fichiers synchronisés
2. Identifier les fichiers bloqués (symbole d'erreur)
3. Actions :
   → Renommer le fichier (supprimer les caractères spéciaux : # % & * : < > ? / \ { | })
   → Déplacer hors du dossier OneDrive, puis remettre
   → Si erreur 0x80070005 (accès refusé) → fermer l'application qui utilise le fichier
```

---

## 4. NE PAS FAIRE

```
⛔ NE JAMAIS partager un site SharePoint en "Tout le monde" sans approbation
⛔ NE JAMAIS rompre l'héritage des permissions sur des sous-dossiers
   → Crée des cas très difficiles à gérer (permissions orphelines)
⛔ NE PAS supprimer un groupe M365 lié à une équipe Teams
   → Supprime automatiquement l'équipe Teams associée
⛔ NE PAS archiver une équipe Teams sans prévenir les membres
⛔ NE JAMAIS réinitialiser OneDrive d'un utilisateur sans l'avoir averti
   → Toutes les syncs locales sont recréées (peut prendre des heures)
```

---

## 5. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Teams inaccessible pour tous les utilisateurs | NOC + TECH | Immédiat |
| Site SharePoint corrompu ou inaccessible | TECH | Dans l'heure |
| Perte de données OneDrive (fichiers supprimés) | BackupDR (Keepit) | Immédiat |
| Quota OneDrive/SharePoint dépassé massivement | TECH | Dans la journée |


---
<!-- SOURCE: RUNBOOK__M365_Intune_Devices_V1 -->
## RUNBOOK — Intune Gestion des Appareils

# RUNBOOK — Microsoft Intune : Gestion des Appareils
**ID :** RUNBOOK__M365_Intune_Devices_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-CloudMaster
**Domaine :** INFRA — Microsoft 365 / Gestion des appareils
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS INTUNE

| Portail | URL |
|---|---|
| **Intune Admin Center** | https://intune.microsoft.com |
| **Entra ID** | https://entra.microsoft.com |
| **PowerShell** | Module Microsoft.Graph.Intune |

---

## 2. HEALTH CHECK INTUNE

```
Intune Admin Center → Dashboard
→ Compliance : % d'appareils conformes
→ Configuration : profils en erreur
→ Device enrollment : nouveaux appareils en attente

Devices → All Devices
→ Filtrer par : OS, Compliance Status, Last Check-in
→ Appareils non synchronisés depuis > 7 jours (signifie probablement inactifs)

Reports → Device Compliance Reports
→ Appareils non conformes : motif (pas de BitLocker, PIN requis, etc.)
```

---

## 3. ENREGISTREMENT D'UN APPAREIL (ENROLLMENT)

### Windows Autopilot
```
1. Obtenir le hash matériel du poste :
   Démarrer le poste → PowerShell admin :
   Install-Script -Name Get-WindowsAutoPilotInfo -Force
   Get-WindowsAutoPilotInfo -OutputFile "C:\hash.csv"

2. Importer le hash dans Intune :
   Intune → Devices → Enrollment → Windows Autopilot → Import
   → Uploader le fichier CSV

3. Créer un profil Autopilot :
   Intune → Devices → Enrollment → Windows Autopilot → Deployment Profiles
   → Assigner à un groupe d'appareils

4. L'utilisateur reçoit le poste → démarre → se connecte avec son compte M365
   → Intune configure automatiquement le poste
```

### Enrollment manuel (MDM)
```
Sur le poste Windows :
Paramètres → Comptes → Accès scolaire ou professionnel
→ Connecter → entrer l'adresse email professionnelle
→ Se connecter → le poste est enregistré dans Intune
```

---

## 4. CONFORMITÉ DES APPAREILS

### Vérifier la conformité d'un appareil
```
Intune → Devices → All Devices → [Appareil]
→ Compliance : Compliant / Not Compliant / Not Evaluated
→ Si Not Compliant : voir les raisons dans l'onglet "Device compliance"

Raisons courantes de non-conformité :
→ BitLocker non activé
→ PIN/mot de passe non configuré
→ OS non à jour (version < seuil défini)
→ Antivirus désactivé ou non à jour
→ Jailbreak/root détecté (mobile)
```

### Forcer une synchronisation
```
Intune → Devices → [Appareil] → Sync
→ Le poste se reconnecte à Intune dans les 5-15 minutes

Sur le poste directement :
Paramètres → Comptes → Accès scolaire ou professionnel → [Compte] → Info → Sync
```

---

## 5. ACTIONS À DISTANCE SUR UN APPAREIL

```
Intune → Devices → [Appareil] → Actions disponibles :

Restart           → Redémarrer l'appareil (rapide, non destructif)
Sync              → Forcer la synchronisation des politiques
Remote Lock       → Verrouiller l'appareil à distance
Reset Password    → Réinitialiser le PIN/mot de passe
Retire            → Supprimer les données d'entreprise (BYOD) — conserve données personnelles
Wipe              → Réinitialisation complète usine — DESTRUCTIF
Fresh Start       → Réinstallation Windows propre (garde données perso)
Locate Device     → Géolocaliser (Mobile uniquement)
```

```
⚠️ ACTIONS DESTRUCTRICES :
⛔ NE JAMAIS Wipe sans approbation explicite du client et du superviseur
⛔ NE JAMAIS Retire sans avoir vérifié que l'utilisateur a sauvegardé ses données
⛔ Documenter toute action dans CW avant exécution
```

---

## 6. DÉPLOIEMENT D'APPLICATIONS

```
Intune → Apps → All Apps → Add
→ Type : Windows app (Win32), Microsoft Store, Built-in app

Déploiement Win32 (package MSI/EXE) :
1. Préparer le package avec IntuneWinAppUtil.exe
2. Uploader dans Intune → Apps → Add → Windows app (Win32)
3. Configurer : commande d'installation, de désinstallation, règles de détection
4. Assigner à un groupe d'utilisateurs ou d'appareils
5. Surveiller : Apps → [App] → Device Install Status
```

---

## 7. PROFILS DE CONFIGURATION

```
Intune → Devices → Configuration Profiles
→ Vérifier les profils en erreur
→ Cliquer sur un profil → Device Status → voir les appareils en erreur

Si un profil ne s'applique pas :
1. Vérifier que l'appareil est dans le groupe cible
2. Forcer une synchronisation (section 5)
3. Vérifier les logs sur le poste :
   Event Viewer → Applications and Services → Microsoft → Windows → DeviceManagement-Enterprise
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS Wipe un appareil sans autorisation explicite
⛔ NE PAS créer des politiques de conformité trop restrictives sans tester sur un groupe pilote
⛔ NE PAS retirer un appareil Autopilot de l'inventaire Intune sans le retirer aussi d'Autopilot
⛔ NE JAMAIS assigner une politique destructrice à "Tous les appareils" — toujours tester sur un groupe
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Politique Intune mal déployée (> 50 appareils impactés) | TECH | Immédiat |
| Appareil volé (Wipe à distance requis) | TECH + SOC | Immédiat |
| Problème d'enrollment massif (Autopilot) | TECH + CloudMaster | Dans l'heure |


---
<!-- SOURCE: RUNBOOK__M365_Compliance_Purview_V1 -->
## RUNBOOK — M365 Conformité et Purview

# RUNBOOK — Microsoft 365 : Conformité, Purview & Sécurité
**ID :** RUNBOOK__M365_Compliance_Purview_V1
**Version :** 1.0 | **Agents :** IT-CloudMaster, IT-SecurityMaster
**Domaine :** INFRA — Microsoft 365 / Conformité
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS PORTAILS SÉCURITÉ ET CONFORMITÉ

| Portail | URL | Usage |
|---|---|---|
| **Microsoft Purview** | https://compliance.microsoft.com | DLP, rétention, eDiscovery |
| **Defender for M365** | https://security.microsoft.com | Sécurité, menaces, incidents |
| **Entra ID Protection** | https://entra.microsoft.com | Risques, MFA, CA |
| **Secure Score** | security.microsoft.com/securescore | Score sécurité global |

---

## 2. RECHERCHE DANS LES LOGS D'AUDIT (UNIFIED AUDIT LOG)

```powershell
# Connexion
Connect-ExchangeOnline -UserPrincipalName "<ADMIN_UPN>.com"

# Recherche générale (7 derniers jours)
Search-UnifiedAuditLog `
    -StartDate (Get-Date).AddDays(-7) `
    -EndDate (Get-Date) `
    -UserIds "utilisateur@domaine.com" `
    -RecordType ExchangeAdmin `
    -ResultSize 500 |
    Select-Object CreationDate, UserIds, Operations, RecordType, AuditData |
    Format-Table -AutoSize

# Opérations courantes à rechercher :
# MailboxLogin        → Connexions boîte aux lettres
# FileAccessed        → Accès fichiers SharePoint/OneDrive
# MemberAdded         → Ajout membre Teams/groupe
# UserLoggedIn        → Connexions utilisateurs
# Set-Mailbox         → Modifications de boîtes
# New-InboxRule       → Création règles Outlook
```

---

## 3. MICROSOFT SECURE SCORE

```
security.microsoft.com → Secure Score
→ Score actuel vs score recommandé
→ Actions recommandées : liste de mesures à prendre
→ Comparer avec : industrie, clients similaires

Actions prioritaires typiques :
→ Activer MFA pour tous les admins (impact élevé)
→ Activer Defender for Office 365 (anti-phishing)
→ Activer l'audit des boîtes aux lettres
→ Bloquer l'authentification basique (Legacy Auth)
→ Activer les révisions d'accès périodiques
```

---

## 4. DEFENDER FOR MICROSOFT 365 — ALERTES

```
security.microsoft.com → Incidents & Alerts
→ Voir les incidents actifs
→ Chaque incident regroupe plusieurs alertes liées

Triage d'une alerte :
1. Cliquer sur l'alerte → Lire la description complète
2. Identifier les entités affectées (utilisateurs, appareils, emails)
3. Évaluer : Vrai positif (VP) / Faux positif (FP) / Test
4. VP → escalade SOC immédiate
5. FP → marquer comme résolu avec commentaire

⚠️ NE JAMAIS ignorer une alerte Defender sans l'avoir classée
```

---

## 5. PROTECTION CONTRE LES MENACES EMAIL (DEFENDER FOR OFFICE 365)

```
security.microsoft.com → Email & Collaboration → Threat Explorer
→ Voir les emails malveillants récents
→ Filtrer par : Phishing, Malware, Spam

Quarantaine :
security.microsoft.com → Review → Quarantine
→ Messages retenus pour révision
→ Libérer les faux positifs
→ Signaler les vrais positifs

Politiques anti-phishing :
security.microsoft.com → Policies → Anti-phishing
→ Vérifier l'impersonation protection (usurpation d'identité)
→ Vérifier les domaines protégés
```

---

## 6. DLP (DATA LOSS PREVENTION)

```
compliance.microsoft.com → Data loss prevention → Policies
→ Voir les politiques actives
→ Vérifier les alertes DLP récentes

Alerte DLP déclenchée :
1. compliance.microsoft.com → DLP → Alerts
2. Cliquer sur l'alerte → détails de l'événement
3. Identifier : qui a envoyé quoi et à qui
4. Évaluer : accident ou intention
5. VP → escalade SOC

⚠️ NE JAMAIS désactiver une politique DLP sans approbation du client
```

---

## 7. RÉTENTION ET ARCHIVAGE

```
compliance.microsoft.com → Information governance → Retention policies
→ Vérifier les politiques de rétention actives
→ S'assurer qu'elles couvrent : Exchange, SharePoint, OneDrive, Teams

Litigation Hold (hold légal sur une boîte) :
Set-Mailbox "utilisateur@domaine.com" -LitigationHoldEnabled $true

In-Place Archive (archivage Exchange Online) :
Enable-Mailbox "utilisateur@domaine.com" -Archive
Get-Mailbox "utilisateur@domaine.com" | Select-Object ArchiveStatus, ArchiveQuota
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS désactiver l'audit unifié (UAL) — requis pour toute investigation
⛔ NE PAS supprimer un Litigation Hold sans ordre juridique ou approbation client écrite
⛔ NE JAMAIS créer une règle de transport qui bypass le spam/phishing filtering
⛔ NE PAS autoriser l'authentification basique (Legacy Auth) dans de nouveaux déploiements
⛔ NE JAMAIS ignorer une alerte Defender > 2h sans l'avoir triée
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Incident Defender (vrai positif) | SOC | Immédiat |
| Alerte DLP (données sensibles exposées) | SOC + CloudMaster | Dans l'heure |
| Score sécurité < 30% | CloudMaster + TECH | Dans la semaine (planifié) |
| Litigation Hold requis (legal) | TECH + CloudMaster | Dans l'heure |


---
<!-- SOURCE: RUNBOOK__OneDrive_SharePoint_Sync_V1 -->
## RUNBOOK — OneDrive SharePoint Synchronisation

# RUNBOOK — OneDrive & SharePoint : Problèmes de Synchronisation
**ID :** RUNBOOK__OneDrive_SharePoint_Sync_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3
**Domaine :** SUPPORT — Microsoft 365
**Mis à jour :** 2026-03-20

---

## 1. ONEDRIVE — DÉPANNAGE SYNCHRONISATION

### Symptômes courants
```
→ Icône OneDrive rouge (erreur) ou bleue tournante (bloqué)
→ Fichiers ne se synchronisent pas depuis X heures/jours
→ Message "Fichier verrouillé" ou "Impossible de synchroniser"
→ Conflits de fichiers
```

### Étape 1 — Lire le message d'erreur
```
Clic sur l'icône OneDrive (barre des tâches)
→ Lire le message exact de l'erreur
→ Cliquer sur "Afficher le problème" pour le détail
```

### Étape 2 — Vérifier les fichiers problématiques
```
Caractères interdits dans les noms de fichiers OneDrive :
→ " * : < > ? / \ |
→ Noms commençant ou finissant par un espace
→ Noms commençant par un point (.)
→ Noms réservés Windows : CON, PRN, AUX, NUL, COM1-9, LPT1-9
→ Fichiers .lnk, .tmp, .pst sur certaines configurations

PowerShell — détecter les fichiers problématiques :
```powershell
$OneDrivePath = "$env:USERPROFILE\OneDrive - [NomOrganisation]"
Get-ChildItem -Path $OneDrivePath -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -match '["\*:<>?/\\|]' -or
        $_.Name -match '^\s|\s$' -or
        $_.Name -match '^\.' -or
        $_.Name -match '^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\.|$)'
    } | Select-Object FullName | Format-Table -AutoSize
```

### Étape 3 — Réinitialiser OneDrive
```powershell
# Fermer OneDrive complètement
Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Réinitialiser (conserve les fichiers locaux, recrée la synchronisation)
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset

# Attendre 30 secondes puis relancer
Start-Sleep -Seconds 30
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
Write-Host "OneDrive réinitialisé — attendre 2-5 min pour la reconnexion"
```

### Étape 4 — Si réinitialisation insuffisante
```
1. Déconnecter le compte OneDrive :
   Icône OneDrive → Paramètres → Compte → Dissocier ce PC

2. Fermer OneDrive

3. Déplacer temporairement le dossier OneDrive local (renommer en OneDrive_OLD)

4. Relancer OneDrive → se reconnecter → laisser resynchroniser

5. Comparer OneDrive_OLD avec le nouveau dossier pour s'assurer qu'aucun fichier local n'est perdu
```

---

## 2. GESTION DES CONFLITS DE FICHIERS

```
OneDrive crée des copies avec "-[Prénom Nom]-" dans le nom en cas de conflit.
Ex: Document.docx → Document-Jean Tremblay.docx

Procédure :
1. Ouvrir les deux fichiers côte à côte
2. Identifier quelle version est la plus récente/complète
3. Garder la bonne version → supprimer ou fusionner l'autre
4. Supprimer le fichier de conflit

⛔ NE PAS supprimer automatiquement tous les fichiers de conflit sans vérification
```

---

## 3. SHAREPOINT — PROBLÈMES DE SYNCHRONISATION

### Bibliothèque SharePoint qui ne se synchronise pas
```
Vérification :
1. S'assurer que OneDrive est connecté et fonctionne
2. Dans SharePoint (navigateur) → [Bibliothèque] → Synchroniser
3. OneDrive s'ouvre et propose de synchroniser la bibliothèque

Si déjà synchronisé mais bloqué :
1. Clic droit sur la bibliothèque dans l'Explorateur Windows
2. "Choisir les dossiers OneDrive à synchroniser" → vérifier la sélection
```

### Erreur "Vous ne pouvez pas synchroniser ce dossier"
```
Causes possibles :
→ Trop de fichiers (> 300 000 dans une bibliothèque)
→ Chemin trop long (> 260 caractères incluant le chemin local)
→ Quota OneDrive dépassé

Solutions :
→ Chemin trop long : raccourcir le nom des dossiers parent
→ Quota dépassé : libérer de l'espace ou augmenter le quota (admin M365)
→ Trop de fichiers : utiliser "Fichiers à la demande" au lieu de tout synchroniser
```

### Fichiers à la demande (Files on Demand)
```
Active les fichiers SharePoint/OneDrive visibles localement sans téléchargement :
Icône OneDrive → Paramètres → Paramètres → Fichiers à la demande
→ Cocher "Économiser de l'espace et télécharger les fichiers au fur et à mesure"

Icônes des fichiers :
☁️ = Disponible dans le cloud (non téléchargé)
✅ = Disponible localement (téléchargé)
🔄 = En cours de synchronisation
```

---

## 4. LIMITES IMPORTANTES ONEDRIVE/SHAREPOINT

| Limite | Valeur |
|---|---|
| Taille max fichier | 250 GB |
| Nb fichiers max bibliothèque | 300 000 (recommandé : < 100 000) |
| Longueur chemin | 400 caractères (URL) |
| Longueur nom fichier | 400 caractères |
| Types non synchronisés | .tmp, .lnk, certains .pst |
| Quota OneDrive défaut | 1 TB par utilisateur |

---

## 5. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer le dossier OneDrive local directement depuis l'Explorateur
   → Peut déclencher la suppression des fichiers dans le cloud
   → Toujours dissocier d'abord depuis les paramètres OneDrive

⛔ NE PAS renommer le dossier OneDrive principal manuellement
   → Toujours utiliser les paramètres OneDrive pour modifier l'emplacement

⛔ NE PAS stocker des bases de données actives (.mdb, .accdb, certains .sqlite) dans OneDrive
   → Ces fichiers sont souvent verrouillés par l'application = erreurs de sync

⛔ NE PAS ignorer les conflits de fichiers — vérifier toujours quelle version conserver
```

---

## 6. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Données OneDrive perdues (fichiers disparus) | BackupDR (Keepit) | Immédiat |
| Quota OneDrive atteint pour plusieurs utilisateurs | CloudMaster | Dans la journée |
| Bibliothèque SharePoint corrompue | CloudMaster + TECH | Dans l'heure |


---
<!-- SOURCE: TEMPLATE_COM_Email-Interruption-Planifiee_V1 -->
## TEMPLATE — Email Interruption Planifiée

# TEMPLATE_COM_Email-Interruption-Planifiee_V1
**Agent :** IT-TicketScribe, IT-MaintenanceMaster
**Usage :** Email client — notification de fenêtre de maintenance planifiée (J-48h)
**Mis à jour :** 2026-03-20

---

**Objet :** [NOM CLIENT] — Fenêtre de maintenance planifiée — [JOUR DATE]

Bonjour [Prénom du contact],

Nous vous informons qu'une fenêtre de maintenance est planifiée pour votre environnement informatique.

**Date :** [JOUR, DD MOIS YYYY]
**Heure :** [HH:MM] à [HH:MM] ([fuseau horaire — ex: heure de Montréal])
**Objectif :** [Description fonctionnelle — ex: Application des mises à jour de sécurité et de stabilité]

**Impact prévu :**
- [Service X] : interruption possible de [durée estimée] entre [HH:MM] et [HH:MM]
- [Service Y] : aucune interruption prévue
- [Si applicable] Accès VPN et services distants : temporairement indisponibles pendant la fenêtre

**Actions requises de votre part :**
- [ ] Sauvegarder vos documents ouverts avant [HH:MM]
- [ ] Prévoir une indisponibilité de [X] minutes sur [service concerné]
- [ ] [Autre action si applicable]

Nous vous ferons parvenir une confirmation une fois la maintenance terminée.
Pour toute question, contactez notre équipe au [téléphone support] ou [email support].

Cordialement,
[Nom du technicien]
[Nom du MSP] — Support TI


---
<!-- SOURCE: CHECKLIST_INFRA_M365-Configuration_V1 -->
## CHECKLIST — M365 Configuration

# CHECKLIST: Microsoft 365 Configuration Best Practices

## Métadonnées
- **Version:** 1.0
- **Dernière mise à jour:** Février 2026
- **Applicable à:** Microsoft 365 (E3/E5, Business Premium)
- **Durée estimation:** 2-3 heures (audit complet)

---

## 🔐 1. SÉCURITÉ & IDENTITÉ

### Azure Active Directory

#### Configuration de base
- [ ] **Noms de domaine personnalisés** configurés et vérifiés
- [ ] **Licences AAD Premium P1/P2** assignées si nécessaire
- [ ] **Self-service password reset** activé pour tous utilisateurs
- [ ] **Password protection** activé (bannir mots de passe faibles)
- [ ] **Smart Lockout** configuré (seuil: 10 tentatives, durée: 60 sec)

#### Authentification multi-facteurs (MFA)
- [ ] **MFA activé** pour tous les administrateurs (100% requis)
- [ ] **MFA encouragé** pour tous les utilisateurs (cible: 95%+)
- [ ] **Méthodes MFA** configurées: Microsoft Authenticator (recommandé), SMS backup
- [ ] **Trusted IPs** définis pour bypass conditionnel
- [ ] **App passwords** désactivés (sauf exceptions documentées)

#### Conditional Access
- [ ] **Politique 1:** Bloquer legacy authentication pour tous utilisateurs
- [ ] **Politique 2:** Exiger MFA pour tous les admins
- [ ] **Politique 3:** Exiger MFA pour accès Azure Management
- [ ] **Politique 4:** Exiger devices compliant pour accès données sensibles
- [ ] **Politique 5:** Bloquer accès depuis pays non-autorisés
- [ ] **Politique 6:** Exiger MFA pour accès à partir d'unknown locations
- [ ] **Mode Report-Only** testé avant activation
- [ ] **Break-glass account** exclu des politiques CA (documenté)

#### Comptes privilégiés
- [ ] **Global Admins:** Maximum 5 comptes (moins c'est mieux)
- [ ] **Break-glass accounts:** 2 comptes cloud-only avec MFA TOTP
- [ ] **Admin roles:** Assignés selon principe moindre privilège
- [ ] **PIM (Privileged Identity Management):** Activé pour rôles sensibles (E5 requis)
- [ ] **Admin accounts:** Noms standardisés (ex: admin-jtremblay@domain.com)
- [ ] **Monitoring alertes:** Configuré pour changements admin

### Microsoft Defender

#### Microsoft Defender for Office 365 (Plan 1/2)
- [ ] **Safe Links** activé pour emails et Teams
- [ ] **Safe Attachments** activé avec action "Block"
- [ ] **Anti-phishing policies** configurées (detect impersonation)
- [ ] **Spoof intelligence** activé
- [ ] **Quarantine policies** définies
- [ ] **Zero-hour auto purge (ZAP)** activé pour spam et phishing
- [ ] **Mail flow rules** pour bloquer file types dangereux (.exe, .js, .vbs, etc.)

#### Microsoft Defender for Endpoint (si applicable)
- [ ] **Onboarding** complété pour tous devices
- [ ] **Attack Surface Reduction (ASR)** rules activées
- [ ] **Controlled Folder Access** configuré
- [ ] **Alerts** routées vers Security Operations

#### Security Baselines
- [ ] **Microsoft 365 Security Baseline** appliqué via Intune
- [ ] **Windows Security Baseline** appliqué pour devices Windows
- [ ] **Deviation reports** générés mensuellement

---

## 📧 2. EXCHANGE ONLINE

### Configuration globale
- [ ] **Accepted domains** ajoutés et validés
- [ ] **Mail flow (connectors)** configurés si hybrid ou tierce partie
- [ ] **SPF record** publié (v=spf1 include:spf.protection.outlook.com -all)
- [ ] **DKIM signing** activé pour tous domaines
- [ ] **DMARC record** publié (p=quarantine minimum, p=reject recommandé)
- [ ] **MX records** pointent vers Exchange Online (.mail.protection.outlook.com)

### Protection anti-spam et malware
- [ ] **Anti-spam policies:** Configured (default + custom si besoin)
- [ ] **Anti-malware policies:** Action = Delete, notifications activées
- [ ] **Outbound spam filter:** Alertes configurées pour compromission compte
- [ ] **Quarantine notifications:** Envoyées aux utilisateurs (digest quotidien)

### Retention et compliance
- [ ] **Retention policies** définies (minimum: 7 ans pour emails conformité)
- [ ] **Litigation hold** activé pour utilisateurs clés si requis
- [ ] **Archive mailboxes** activés pour tous (ou selon licence)
- [ ] **Auto-expanding archive** activé si croissance prévue
- [ ] **Journaling** configuré si requis par compliance

### Délégation et partage
- [ ] **Shared mailboxes:** Permissions déléguées, pas de licences assignées
- [ ] **Calendar sharing policies:** Limitées (default = Limited Details only)
- [ ] **External sharing:** Contrôlé (pas de sharing automatique)
- [ ] **Distribution groups:** Ownership défini, moderation activée si public

### Quotas et limites
- [ ] **Mailbox quotas:** IssueWarning=45GB, ProhibitSend=48GB, ProhibitReceive=50GB
- [ ] **Send/Receive limits:** Defaults acceptables (150MB attachments)
- [ ] **Recipient limits:** 500/jour par utilisateur (default)

---

## 👥 3. SHAREPOINT ONLINE & ONEDRIVE

### Administration et gouvernance
- [ ] **Sharing settings:**
  - [ ] External sharing = "Only people in organization" (ou "New and existing guests" si nécessaire)
  - [ ] Default link type = "Specific people"
  - [ ] Default permission = "View"
- [ ] **Access control:** Require sign-in pour accès externe
- [ ] **Idle session timeout:** Configuré (recommandé: 1 heure)
- [ ] **Legacy authentication:** Bloquée

### OneDrive
- [ ] **Storage quota:** Défini par utilisateur (1TB default avec E3)
- [ ] **Sync restrictions:** Limiter à devices corporate (AAD joined/Hybrid)
- [ ] **Known Folder Move:** Déployé via GPO (Desktop, Documents, Pictures)
- [ ] **Files On-Demand:** Activé par défaut
- [ ] **Retention for deleted users:** 365 jours minimum

### Sites et Hub Sites
- [ ] **Site creation:** Contrôlé (approval required ou self-service géré)
- [ ] **Hub sites:** Structure définie (max 3 niveaux)
- [ ] **Site owners:** Minimum 2 par site
- [ ] **Inactive sites:** Politique de cleanup définie (ex: archiver après 180 jours inactifs)

### DLP et Information Protection
- [ ] **DLP policies:** Actives pour SharePoint/OneDrive
  - [ ] Bloquer partage CCN, SIN, données santé
  - [ ] Alertes configurées pour violations
- [ ] **Sensitivity labels:** Publiées et utilisées
  - [ ] Public, Internal, Confidential, Highly Confidential
  - [ ] Auto-labeling configuré si E5
- [ ] **Versioning:** Activé (500 versions par défaut)
- [ ] **Recycle bin:** 93 jours rétention (default)

---

## 💬 4. MICROSOFT TEAMS

### Configuration organisation
- [ ] **External access (federation):** Configuré selon politiques
  - [ ] Domaines autorisés/bloqués listés
  - [ ] Skype for Business federation si requis
- [ ] **Guest access:** Activé avec restrictions appropriées
  - [ ] Require MFA pour guests
  - [ ] Limiter fonctionnalités guests (pas de apps par défaut)
- [ ] **Teams creation:** Contrôlé (approval ou groupes autorisés)
- [ ] **Naming policy:** Appliquée (préfixes/suffixes, blocked words)

### Sécurité et compliance
- [ ] **Retention policies:** Configurées pour Teams messages et files
- [ ] **DLP policies:** Actives pour Teams conversations
- [ ] **Meeting policies:**
  - [ ] Lobby pour external participants
  - [ ] Recording = disabled par défaut (ou controlled)
  - [ ] Transcription selon besoins compliance
- [ ] **Chat permissions:** Restrict Giphy, memes si nécessaire
- [ ] **External apps:** Catalog contrôlé (block by default, allow liste)

### Voice et Calling (si applicable)
- [ ] **Calling policies:** Définies par groupe d'utilisateurs
- [ ] **Emergency addresses:** Configurées pour tous sites
- [ ] **Call routing:** Dial plans et routes configurés
- [ ] **Auto attendants:** Configurés avec fallback

### Usage et adoption
- [ ] **Teams analytics:** Monitoring activé
- [ ] **Usage reports:** Consultés mensuellement
- [ ] **Inactive teams:** Archivage automatique configuré (180+ jours)
- [ ] **Training resources:** Disponibles pour utilisateurs

---

## 🛡️ 5. SÉCURITÉ & COMPLIANCE CENTER

### Data Loss Prevention (DLP)
- [ ] **DLP policies actives:**
  - [ ] Exchange (email)
  - [ ] SharePoint/OneDrive (documents)
  - [ ] Teams (conversations)
  - [ ] Endpoints (si Defender for Endpoint)
- [ ] **Sensitive info types:** Customisés pour organisation
  - [ ] Numéros assurance sociale (SIN)
  - [ ] Numéros cartes crédit
  - [ ] Données spécifiques industrie
- [ ] **Policy tips:** Activés pour éduquer utilisateurs
- [ ] **Incident reports:** Envoyés à admins DLP

### Information Protection
- [ ] **Sensitivity labels:** Créées et publiées
- [ ] **Label policies:** Assignées aux bons groupes
- [ ] **Auto-labeling:** Configuré si E5 (basé sur sensitive info types)
- [ ] **Encryption:** Configurée pour labels "Confidential" et "Highly Confidential"
- [ ] **Visual markings:** Headers/footers/watermarks configurés

### Retention Policies
- [ ] **Retention policies:**
  - [ ] Email: 7 ans minimum
  - [ ] SharePoint/OneDrive: 7 ans minimum
  - [ ] Teams: Selon besoins légaux
- [ ] **Disposition review:** Processus défini pour fin de rétention
- [ ] **Preservation lock:** Appliqué aux politiques légales

### Audit et Monitoring
- [ ] **Unified Audit Logging:** Activé (obligatoire)
- [ ] **Audit retention:** 90 jours (E3) ou 1 an (E5/add-on)
- [ ] **Alert policies:** Configurées pour activités critiques
  - [ ] Création de forwarding rules
  - [ ] Mass download SharePoint
  - [ ] Elevation to admin
  - [ ] External sharing
- [ ] **Compliance Manager:** Score > 80% (cible)

### eDiscovery
- [ ] **eDiscovery cases:** Process défini
- [ ] **Custodians:** Formation fournie à legal team
- [ ] **Advanced eDiscovery:** Configuré si E5

---

## 📱 6. DEVICE MANAGEMENT (INTUNE)

### Enrollment et configuration
- [ ] **Auto-enrollment:** Configuré pour devices AAD joined
- [ ] **Device categories:** Définies (Corporate, BYOD, Kiosk, etc.)
- [ ] **Compliance policies:** Créées par plateforme (Windows, iOS, Android)
  - [ ] Require encryption
  - [ ] Minimum OS version
  - [ ] Require antivirus
  - [ ] Screen lock settings
- [ ] **Configuration profiles:** Déployés
  - [ ] Wi-Fi settings
  - [ ] VPN settings  
  - [ ] Email profiles
  - [ ] Certificates

### Application Management
- [ ] **App protection policies:** Configurées (Managed Apps)
- [ ] **Required apps:** Déployées via Intune
  - [ ] Microsoft 365 Apps
  - [ ] Company Portal
  - [ ] Authenticator
- [ ] **App configuration:** Settings poussés automatiquement
- [ ] **MAM (Mobile Application Management):** Activé pour BYOD

### Security Baselines
- [ ] **Windows 10/11 baseline:** Appliquée
- [ ] **Microsoft Edge baseline:** Appliquée
- [ ] **Microsoft 365 Apps baseline:** Appliquée
- [ ] **Deviation reports:** Monitoring mensuel

---

## 💰 7. LICENSES & COST OPTIMIZATION

### License Management
- [ ] **License assignments:** Basées sur groups (pas utilisateur par utilisateur)
- [ ] **Unused licenses:** Audit mensuel et réaffectation
- [ ] **Over-licensing:** Identifier users avec features non-utilisées
- [ ] **Under-licensing:** Users sans features nécessaires identifiés

### Usage Analytics
- [ ] **Microsoft 365 usage reports:** Consultés mensuellement
- [ ] **Adoption score:** Monitoring et amélioration
- [ ] **Inactive users:** Processus de désactivation (60 jours inactifs)
- [ ] **License optimization:** Analysis trimestrielle

---

## 📊 8. MONITORING & REPORTING

### Service Health
- [ ] **Service health dashboard:** Consulté quotidiennement
- [ ] **Maintenance notifications:** Routées vers équipe IT
- [ ] **Incident subscriptions:** Configurées pour services critiques

### Reports configurés
- [ ] **Security & Compliance reports:** Générés mensuellement
- [ ] **Usage reports:** Par service (Exchange, Teams, SharePoint)
- [ ] **DLP incident reports:** Hebdomadaires
- [ ] **Sign-in reports:** Anomalies reviewées hebdomadairement

### Alerting
- [ ] **Azure Monitor:** Intégré si infrastructure hybrid
- [ ] **Security alerts:** Routées vers SOC/équipe sécurité
- [ ] **Thresholds:** Définis pour métriques clés

---

## 🔄 9. BACKUP & DISASTER RECOVERY

### Backups
- [ ] **Third-party backup:** Configuré (Veeam, AvePoint, etc.)
  - [ ] Exchange mailboxes
  - [ ] SharePoint sites
  - [ ] OneDrive
  - [ ] Teams data
- [ ] **Backup testing:** Restore testé trimestriellement
- [ ] **Retention:** Selon politiques compliance

### Business Continuity
- [ ] **DR plan:** Documenté et testé annuellement
- [ ] **RTO/RPO:** Définis pour chaque service
- [ ] **Failover procedures:** Documentées
- [ ] **Communication plan:** Défini pour outages

---

## 📚 10. GOVERNANCE & DOCUMENTATION

### Policies et Standards
- [ ] **Acceptable Use Policy:** Publié et accepté par users
- [ ] **Data Classification Policy:** Défini et communiqué
- [ ] **Retention Policy:** Documenté
- [ ] **Security Standards:** Basés sur CIS Benchmarks ou équivalent

### Documentation technique
- [ ] **Architecture diagrams:** À jour
- [ ] **Network topology:** Documentée (si hybrid)
- [ ] **Runbooks:** Créés pour tâches récurrentes
- [ ] **Contacts et escalation:** Liste à jour

### Training et awareness
- [ ] **Admin training:** Formation continue planifiée
- [ ] **User training:** Onboarding et refreshers annuels
- [ ] **Security awareness:** Phishing simulations trimestrielles
- [ ] **Knowledge base:** Accessible et maintenue

---

## ✅ VALIDATION FINALE

### Secure Score Targets
- [ ] **Microsoft Secure Score:** > 85%
- [ ] **Compliance Score:** > 80%
- [ ] **Identity Secure Score:** > 80%

### Audit externe
- [ ] **Last audit date:** [Date]
- [ ] **Audit findings:** Tous résolus ou avec plan mitigation
- [ ] **Next audit:** [Date planifiée]

### Sign-off
- [ ] **IT Manager:** [Nom] - [Date]
- [ ] **Security Lead:** [Nom] - [Date]
- [ ] **Compliance Officer:** [Nom] - [Date]

---

## 📝 NOTES

**Date de la revue:** ___________  
**Révisé par:** ___________  
**Score de conformité:** _____ / 100  
**Prochaine revue:** ___________

**Actions prioritaires identifiées:**
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

---

*Checklist version 1.0 - IT-CloudMaster*  
*Basée sur Microsoft 365 Best Practices et CIS Benchmarks*

```
