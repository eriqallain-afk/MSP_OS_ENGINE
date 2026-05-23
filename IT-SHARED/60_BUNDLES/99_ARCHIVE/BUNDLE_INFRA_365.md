# BUNDLE — BUNDLE_INFRA_365
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Bundle ID :** BUNDLE_INFRA_365
**Source ZIP :** INFRA_M365.zip
**Généré :** 2026-04-04T20:19:33Z

## Contenu (runbooks)
1. **RUNBOOK__M365_Exchange_Online_V1** — RUNBOOK — Microsoft 365 : Exchange Online & Messagerie (Maj: 2026-03-20 | Agents: IT-Assistant-N2, IT-Assistant-N3, IT-CloudMaster)
2. **RUNBOOK__M365_Teams_SharePoint_OneDrive_V1** — RUNBOOK — Microsoft 365 : Teams, SharePoint & OneDrive (Maj: 2026-03-20 | Agents: IT-Assistant-N2, IT-Assistant-N3, IT-CloudMaster)
3. **RUNBOOK__EntraID_Operations_V1** — RUNBOOK — Microsoft Entra ID (Azure AD) : Opérations & Sécurité (Maj: 2026-03-20 | Agents: IT-Assistant-N3, IT-CloudMaster)
4. **RUNBOOK__M365_Intune_Devices_V1** — RUNBOOK — Microsoft Intune : Gestion des Appareils (Maj: 2026-03-20 | Agents: IT-Assistant-N3, IT-CloudMaster)

---

<!-- RUNBOOK_START: RUNBOOK__M365_Exchange_Online_V1 (INFRA__RUNBOOK__M365_Exchange_Online_V1.md) -->
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
<!-- RUNBOOK_END: RUNBOOK__M365_Exchange_Online_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__M365_Teams_SharePoint_OneDrive_V1 (INFRA__RUNBOOK__M365_Teams_SharePoint_OneDrive_V1.md) -->
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
<!-- RUNBOOK_END: RUNBOOK__M365_Teams_SharePoint_OneDrive_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__EntraID_Operations_V1 (INFRA__RUNBOOK__EntraID_Operations_V1.md) -->
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
<!-- RUNBOOK_END: RUNBOOK__EntraID_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__M365_Intune_Devices_V1 (INFRA__RUNBOOK__M365_Intune_Devices_V1.md) -->
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
<!-- RUNBOOK_END: RUNBOOK__M365_Intune_Devices_V1 -->

---
