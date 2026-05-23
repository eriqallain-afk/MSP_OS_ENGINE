# BUNDLE_KP_CloudMaster_V2
**Agent :** @IT-CloudMaster
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** M365 Admin, Teams Admin, SharePoint Admin, Intune, Azure, Conditional Access, Exchange Online, troubleshooting courant, KeepIT, portails de référence, escalades.

---

## SECTION 1 — M365 ADMIN — GESTION UTILISATEURS

### Connexion modules admin
```powershell
# Exchange Online
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName "[ADMIN]@[DOMAINE].com"

# MSGraph (moderne)
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"

# Module MSOnline (legacy mais utile)
Connect-MsolService

# Azure AD (Entra ID)
Connect-AzureAD
```

### Gestion utilisateurs et licences
```powershell
# Créer utilisateur M365
New-MgUser -DisplayName "[Prénom Nom]" `
    -UserPrincipalName "[prenom.nom]@[DOMAINE].com" `
    -MailNickname "[prenom.nom]" `
    -AccountEnabled $true `
    -PasswordProfile @{Password="[MDP_TEMP]"; ForceChangePasswordNextSignIn=$true}

# Assigner licence via MSGraph
$LicenseSku = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "ENTERPRISEPACK" }
Set-MgUserLicense -UserId "[user]@[DOMAINE].com" `
    -AddLicenses @{SkuId=$LicenseSku.SkuId} -RemoveLicenses @()

# Retirer licence
Set-MgUserLicense -UserId "[user]@[DOMAINE].com" `
    -AddLicenses @() -RemoveLicenses @($LicenseSku.SkuId)

# Lister utilisateurs sans licence
Get-MgUser -Filter "assignedLicenses/\$count eq 0" -ConsistencyLevel eventual -CountVariable unlicensed | Select-Object DisplayName, UserPrincipalName

# MFA — statut d'un utilisateur (legacy MFA)
Get-MsolUser -UserPrincipalName "[user]@[DOMAINE].com" | Select-Object DisplayName, StrongAuthenticationRequirements

# Réinitialiser MFA
Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName "[user]@[DOMAINE].com"
```

### Boîtes partagées et salles
```powershell
# Créer boîte partagée
New-Mailbox -Shared -Name "[NOM BOITE]" -PrimarySmtpAddress "[alias]@[DOMAINE].com"
Add-MailboxPermission "[alias]@[DOMAINE].com" -User "[user]@[DOMAINE].com" -AccessRights FullAccess -AutoMapping $true
Add-RecipientPermission "[alias]@[DOMAINE].com" -Trustee "[user]@[DOMAINE].com" -AccessRights SendAs -Confirm:$false

# Créer salle de réunion
New-Mailbox -Name "[Salle Réunion]" -PrimarySmtpAddress "[salle]@[DOMAINE].com" -Room
Set-CalendarProcessing -Identity "[salle]@[DOMAINE].com" -AutomateProcessing AutoAccept -AllowConflicts $false

# Lister boîtes partagées et accès
Get-Mailbox -RecipientTypeDetails SharedMailbox | ForEach-Object {
    $mbx = $_
    Get-MailboxPermission $mbx.Identity | Where-Object { $_.User -notlike "*SELF*" } |
    Select-Object @{N='Mailbox';E={$mbx.PrimarySmtpAddress}}, User, AccessRights
}
```

---

## SECTION 2 — TEAMS ADMIN

### Gestion équipes et canaux
```powershell
# Créer une équipe Teams
New-Team -DisplayName "[NOM ÉQUIPE]" -Description "[Description]" -Visibility Private

# Ajouter membres
Add-TeamUser -GroupId "[GUID_ÉQUIPE]" -User "[user]@[DOMAINE].com" -Role Member
Add-TeamUser -GroupId "[GUID_ÉQUIPE]" -User "[owner]@[DOMAINE].com" -Role Owner

# Créer canal
New-TeamChannel -GroupId "[GUID_ÉQUIPE]" -DisplayName "[NOM CANAL]" -MembershipType Standard

# Lister équipes d'un utilisateur
Get-Team | Where-Object { (Get-TeamUser -GroupId $_.GroupId).User -contains "[user]@[DOMAINE].com" }

# Archiver une équipe
Set-Team -GroupId "[GUID_ÉQUIPE]" -Archived $true

# Rapport équipes inactives (90 jours)
Get-Team | ForEach-Object {
    $activity = Get-TeamChannel -GroupId $_.GroupId -ErrorAction SilentlyContinue
    [PSCustomObject]@{Team=$_.DisplayName; Id=$_.GroupId}
}
```

### Politiques Teams (via Teams Admin Center)
```
POLITIQUES À VÉRIFIER :
- Meeting policies : qui peut enregistrer, sous-titres, lobby
- Messaging policies : qui peut supprimer/modifier messages
- App setup policies : apps épinglées pour utilisateurs
- Calling policies : appels directs autorisés
- External access : fédération avec domaines externes

Navigation : admin.teams.microsoft.com
→ Policies → Sélectionner politique → Assign users
```

### Troubleshooting Teams courant
```
PROBLÈME : Teams ne démarre pas / boucle de connexion
→ Vider cache Teams :
   %appdata%\Microsoft\Teams → supprimer contenu (garder storage/databases)
→ Désinstaller/réinstaller Teams si cache ne règle pas

PROBLÈME : Qualité audio/vidéo mauvaise
→ Teams Admin Center → Analytics & reports → Call quality dashboard
→ Vérifier QoS policies réseau (ports UDP 3478-3481)
→ Vérifier bande passante : min 1.5 Mbps up/down pour HD

PROBLÈME : Utilisateur ne voit pas les canaux
→ Vérifier appartenance à l'équipe
→ Vérifier canaux privés : l'utilisateur doit être invité spécifiquement

PROBLÈME : Appels qui échouent
→ Teams Admin Center → Voice → Phone numbers → vérifier assignation
→ Vérifier licence Teams Phone assignée
```

---

## SECTION 3 — SHAREPOINT ADMIN

### Gestion sites et permissions
```powershell
# Connexion SharePoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url "https://[TENANT]-admin.sharepoint.com"

# Lister tous les sites
Get-SPOSite -Limit All | Select-Object Url, Title, StorageUsageCurrent, Owner

# Quota d'un site
Set-SPOSite -Identity "https://[TENANT].sharepoint.com/sites/[NOM_SITE]" -StorageQuota 10240 -StorageQuotaWarningLevel 9216

# Partage externe — désactiver pour un site
Set-SPOSite -Identity "https://[TENANT].sharepoint.com/sites/[NOM_SITE]" -SharingCapability Disabled

# Ajouter admin à un site
Set-SPOUser -Site "https://[TENANT].sharepoint.com/sites/[NOM_SITE]" -LoginName "[user]@[DOMAINE].com" -IsSiteCollectionAdmin $true

# Permissions d'un utilisateur sur un site
Get-SPOUser -Site "https://[TENANT].sharepoint.com/sites/[NOM_SITE]" -LoginName "[user]@[DOMAINE].com"
```

### Troubleshooting SharePoint
```
PROBLÈME : Accès refusé (403)
→ Vérifier groupes du site (Owners/Members/Visitors)
→ Vérifier si l'héritage des permissions est brisé sur un sous-dossier
→ Ne JAMAIS briser l'héritage sans approbation superviseur

PROBLÈME : Synchronisation OneDrive ne démarre pas
→ Vérifier que l'URL SharePoint est dans la liste de sync autorisée (GPO ou tenant setting)
→ Vérifier que l'utilisateur a une licence OneDrive for Business active

PROBLÈME : Bibliothèque non visible dans Teams
→ Teams → canal → + → SharePoint → URL de la bibliothèque
→ Vérifier permissions sur la bibliothèque SharePoint liée

PROBLÈME : Fichier bloqué / checkout oublié
→ Bibliothèque → Tous les documents → colonne Extrait par → forcer l'archivage
```

---

## SECTION 4 — INTUNE / ENDPOINT MANAGER

### Vérification appareils non conformes
```
Navigation : intune.microsoft.com
→ Devices → Compliance policies → Device compliance
→ Filtrer : Non-compliant

Causes courantes non-conformité :
- BitLocker non activé
- Antivirus obsolète / désactivé
- OS non à jour
- PIN/code d'accès non configuré
- Intégrité d'appareil (Secure Boot, TPM)
```

### Politiques Intune courantes
```powershell
# Via MSGraph — lister appareils non conformes
Get-MgDeviceManagementManagedDevice -Filter "complianceState eq 'noncompliant'" | 
    Select-Object DeviceName, UserPrincipalName, OperatingSystem, ComplianceState, LastSyncDateTime

# Forcer synchronisation d'un appareil
Invoke-MgDeviceManagementManagedDeviceSyncDevice -ManagedDeviceId "[DEVICE_ID]"

# Retirer appareil (wipe)
# ⚠️ APPROBATION REQUISE — Wipe est irréversible
Remove-MgDeviceManagementManagedDevice -ManagedDeviceId "[DEVICE_ID]"
```

### Onboarding appareil Intune
```
CHECKLIST ONBOARDING INTUNE :
[ ] Azure AD Join ou Hybrid Join selon politique client
[ ] Enrollment profile assigné
[ ] Compliance policy assignée
[ ] Configuration profile assigné (Wi-Fi, VPN, email)
[ ] Apps requises publiées et assignées
[ ] Autopilot profile si déploiement zero-touch

TROUBLESHOOTING ENROLLMENT :
"MDM terms not configured"  → Tenant settings → MDM authority
"Device already enrolled"   → Retirer de Intune puis re-enroller
"Certificate error"         → Vérifier SCEP/PKCS profile
```

---

## SECTION 5 — AZURE

### Ressources et VMs Azure
```powershell
# Connexion Azure
Connect-AzAccount

# Lister toutes les VMs
Get-AzVM | Select-Object Name, ResourceGroupName, Location, @{N='Status';E={(Get-AzVM -Name $_.Name -ResourceGroupName $_.ResourceGroupName -Status).Statuses[1].DisplayStatus}}

# Démarrer / Arrêter VM Azure
Start-AzVM -ResourceGroupName "[NOM_RG]" -Name "[NOM_VM]"
Stop-AzVM -ResourceGroupName "[NOM_RG]" -Name "[NOM_VM]" -Force

# Taille d'une VM
(Get-AzVM -ResourceGroupName "[NOM_RG]" -Name "[NOM_VM]").HardwareProfile.VmSize

# Redimensionner une VM (⚠️ arrêt requis)
$vm = Get-AzVM -ResourceGroupName "[NOM_RG]" -Name "[NOM_VM]"
$vm.HardwareProfile.VmSize = "Standard_D4s_v3"
Update-AzVM -VM $vm -ResourceGroupName "[NOM_RG]"
```

### Coûts et optimisation Azure
```powershell
# Coûts du mois en cours
Get-AzConsumptionUsageDetail -StartDate (Get-Date -Day 1).Date -EndDate (Get-Date) |
    Group-Object InstanceName | Sort-Object {($_.Group | Measure-Object PretaxCost -Sum).Sum} -Descending |
    Select-Object -First 10 Name, @{N='Cost';E={($_.Group | Measure-Object PretaxCost -Sum).Sum}}

# VMs non utilisées (arrêtées mais qui facturent le stockage)
Get-AzVM | Where-Object { (Get-AzVM -Name $_.Name -ResourceGroupName $_.ResourceGroupName -Status).Statuses[1].DisplayStatus -eq "VM deallocated" }
```

### Networking Azure
```powershell
# VNets
Get-AzVirtualNetwork | Select-Object Name, ResourceGroupName, Location, AddressSpace

# NSG rules
Get-AzNetworkSecurityGroup -ResourceGroupName "[NOM_RG]" -Name "[NOM_NSG]" |
    Select-Object -ExpandProperty SecurityRules | Sort-Object Priority

# Vérifier connectivité (Network Watcher)
Test-AzNetworkWatcherConnectivity -NetworkWatcherName "[NOM_NW]" -ResourceGroupName "[NOM_RG]" `
    -SourceId "[VM_SOURCE_ID]" -DestinationAddress "[DEST_IP]" -DestinationPort 443
```

---

## SECTION 6 — ENTRA ID (AZURE AD)

### Gestion identités et accès
```powershell
# Désactiver un compte (compromission)
Update-MgUser -UserId "[user]@[DOMAINE].com" -AccountEnabled $false

# Révoquer toutes les sessions
Revoke-MgUserSignInSession -UserId "[user]@[DOMAINE].com"

# Applications avec droits OAuth (vérification)
Get-MgUserOauth2PermissionGrant -UserId "[user]@[DOMAINE].com" | 
    Select-Object ClientId, Scope | Format-Table
# ⚠️ Révoquer les grants suspects :
Remove-MgUserOauth2PermissionGrant -UserId "[user]@[DOMAINE].com" -OAuth2PermissionGrantId "[GRANT_ID]"

# Membres d'un groupe Entra ID
Get-MgGroupMember -GroupId "[GUID_GROUPE]" | ForEach-Object { Get-MgUser -UserId $_.Id | Select-Object DisplayName, UserPrincipalName }

# Rapport connexions récentes (30 derniers jours)
Get-MgAuditLogSignIn -Filter "createdDateTime ge $(([datetime]::UtcNow.AddDays(-30)).ToString('yyyy-MM-ddTHH:mm:ssZ'))" -Top 100 |
    Select-Object UserPrincipalName, CreatedDateTime, Status, IPAddress, Location
```

### Sync Entra Connect
```powershell
# Sur le serveur Entra Connect (anciennement AAD Connect)
# Forcer une synchronisation delta
Import-Module ADSync
Start-ADSyncSyncCycle -PolicyType Delta

# Synchronisation complète (plus lente)
Start-ADSyncSyncCycle -PolicyType Initial

# Statut de synchronisation
Get-ADSyncScheduler | Select-Object NextSyncCycleStartTimeInUTC, SyncCycleEnabled, CurrentlyRunning

# Erreurs de synchronisation
Get-ADSyncConnectorStatistics -ConnectorName "[NOM_TENANT].onmicrosoft.com"
```

---

## SECTION 7 — CONDITIONAL ACCESS

### Vérification et troubleshooting
```
NAVIGATION :
entra.microsoft.com → Protection → Conditional Access

POLITIQUES CRITIQUES À VÉRIFIER :
- MFA pour tous les utilisateurs (sauf exceptions documentées)
- Bloquer authentification héritée (Legacy auth)
- Accès depuis pays à risque (bloquer ou MFA renforcé)
- Conformité appareil requise pour accès données sensibles
- Protection admin : MFA + appareils conformes seulement

TROUBLESHOOTING — Utilisateur bloqué par CA :
1. Sign-in logs : entra.microsoft.com → Monitoring → Sign-in logs
2. Filtrer par UPN et chercher "Failure" avec "Conditional Access"
3. Voir quelle politique bloque et pourquoi
4. "What If" tool → tester sans impacter l'utilisateur
```

```powershell
# Sign-in log — utilisateur bloqué récemment
Get-MgAuditLogSignIn -Filter "userPrincipalName eq '[user]@[DOMAINE].com' and status/errorCode ne 0" -Top 20 |
    Select-Object CreatedDateTime, Status, ConditionalAccessStatus, IPAddress, ClientAppUsed
```

---

## SECTION 8 — EXCHANGE ONLINE AVANCÉ (hérité V1 + enrichi)

### Distribution groups et calendriers partagés
```powershell
# Créer groupe dynamique de distribution
New-DynamicDistributionGroup -Name "[NOM GROUPE]" `
    -RecipientFilter "Department -eq '[DEPARTEMENT]' -and RecipientTypeDetails -eq 'UserMailbox'"

# Calendrier partagé — accès lecture
Add-MailboxFolderPermission -Identity "[user]@[DOMAINE].com:\Calendar" `
    -User "[autre.user]@[DOMAINE].com" -AccessRights Reviewer

# Archivage — activer et vérifier
Enable-Mailbox "[user]@[DOMAINE].com" -Archive
Get-Mailbox "[user]@[DOMAINE].com" | Select-Object ArchiveStatus, ArchiveDatabase

# Journaux d'audit mailbox
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) `
    -UserIds "[user]@[DOMAINE].com" -RecordType ExchangeItem -ResultSize 100 |
    Select-Object CreationDate, Operations, UserIds | Format-Table
```

### Traçage messages (hérité V1)
```powershell
# Tracer un message
Get-MessageTrace -SenderAddress "[exp]@[DOMAINE].com" -RecipientAddress "[dest]@[DOMAINE].com" `
    -StartDate (Get-Date).AddDays(-2) -EndDate (Get-Date) | Select-Object Received, Status, Subject | Format-Table

# Règles Outlook suspectes
Get-InboxRule -Mailbox "[user]@[DOMAINE].com" | Select-Object Name, Enabled, ForwardTo, DeleteMessage | Format-List
Remove-InboxRule -Mailbox "[user]@[DOMAINE].com" -Identity "[NOM_REGLE]"

# Transfert automatique suspect
Get-Mailbox "[user]@[DOMAINE].com" | Select-Object ForwardingSmtpAddress, DeliverToMailboxAndForward
Set-Mailbox "[user]@[DOMAINE].com" -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false
```

---

## SECTION 9 — TROUBLESHOOTING M365 COURANT

### MFA en boucle
```
SYMPTÔME : Utilisateur demande MFA en boucle, ne peut pas se connecter

DIAGNOSTIC :
1. Vérifier si l'appareil est Azure AD Joined ou Registered
2. Vérifier les politiques CA actives pour cet utilisateur
3. Vérifier si une politique "Require MFA" sans exception s'applique

SOLUTIONS :
A) Réinitialiser la session Authenticator :
   → Entra ID → Users → [USER] → Authentication methods → Supprimer méthode MFA
   → Utilisateur re-configure depuis zéro

B) Exclure temporairement de CA (⚠️ documenter et planifier réinclusion) :
   → CA policy → Exclude → Users and groups → ajouter [USER]

C) Token d'accès d'urgence :
   → Entra ID → Users → [USER] → Authentication methods → Temporary Access Pass
```

### Sync Entra bloquée / objet en conflit
```powershell
# Identifier les erreurs de sync dans Entra
# Portail → Entra ID → Identity → Hybrid management → Microsoft Entra Connect → Sync errors

# Résoudre conflit UPN (sur le DC)
# Identifier l'objet en conflit
Get-ADUser -Filter {UserPrincipalName -eq "[user]@[DOMAINE].com"} | Select-Object Name, SamAccountName, DistinguishedName

# Modifier l'UPN de l'objet en conflit
Set-ADUser -Identity "[prenom.nom]" -UserPrincipalName "[prenom.nom.backup]@[DOMAINE].local"

# Forcer re-sync
Start-ADSyncSyncCycle -PolicyType Delta
```

### Problèmes de licences
```
PROBLÈME : Utilisateur a la licence mais les apps ne s'activent pas

VÉRIFICATIONS :
1. Portail M365 Admin → Users → [USER] → Licenses & apps → vérifier apps individuelles activées
2. Script de vérification :
```
```powershell
Get-MgUserLicenseDetail -UserId "[user]@[DOMAINE].com" | Select-Object SkuPartNumber, @{N='Services';E={$_.ServicePlans | Select-Object ServicePlanName, ProvisioningStatus}}
```
```
3. Si "PendingActivation" → attendre 15 min ou forcer via : Set-MgUserLicense (retirer et réassigner)
4. Si "Disabled" → service désactivé dans la licence assignée → modifier le plan de service
```

---

## SECTION 10 — KEEPIT M365 BACKUP (hérité V1)

### Vérification mensuelle KeepIT
```
Navigation : app.keepit.com
→ Dashboard → Last 30 days → Filtrer par échecs

POINTS À VÉRIFIER :
[ ] Exchange Online : tous les mailboxes sauvegardés
[ ] SharePoint Online : tous les sites sauvegardés
[ ] OneDrive : tous les utilisateurs actifs couverts
[ ] Teams : conversations et fichiers sauvegardés
[ ] Aucune erreur d'authentification (token expiré ?)

SEUIL D'ALERTE : 
- Plus de 5% des mailboxes en échec → investigation
- Token d'accès expiré → renouveler dans KeepIT Settings → Microsoft 365 connection
```

### Restauration KeepIT Exchange
```
Navigation : app.keepit.com
→ Restore → Exchange Online → Sélectionner utilisateur
→ Choisir point de restauration
→ Sélectionner emails/dossiers → Restore to original ou Restore to another mailbox

⚠️ Restauration à l'emplacement original écrase le contenu actuel si même nom
⚠️ Toujours confirmer avec le client le point de restauration choisi
⚠️ Documenter la restauration dans CW avec le billet de référence
```

---

## SECTION 11 — PORTAILS DE RÉFÉRENCE

| Portail | URL | Usage |
|---|---|---|
| M365 Admin Center | admin.microsoft.com | Gestion globale M365 |
| Entra ID (Azure AD) | entra.microsoft.com | Identités, MFA, CA |
| Exchange Admin Center | admin.exchange.microsoft.com | Mailboxes, règles, transport |
| Teams Admin Center | admin.teams.microsoft.com | Politiques Teams |
| SharePoint Admin | [TENANT]-admin.sharepoint.com | Sites, permissions |
| Intune / Endpoint | intune.microsoft.com | Appareils, conformité |
| Azure Portal | portal.azure.com | Ressources Azure |
| Azure Cost Management | portal.azure.com/#view/Microsoft_Azure_CostManagement | Coûts |
| Defender Portal | security.microsoft.com | Sécurité, alertes |
| Purview | compliance.microsoft.com | Conformité, DLP |
| KeepIT | app.keepit.com | Backup M365 |
| Service Health | admin.microsoft.com/Adminportal/Home#/servicehealth | Incidents M365 |

---

## SECTION 12 — SEUILS D'ALERTE CLOUD

| Ressource | Avertissement | Critique | Action |
|---|---|---|---|
| Licences disponibles | < 5 licences libres | 0 licence libre | Acheter licences |
| Quota mailbox | > 80% utilisé | > 90% | Archivage ou quota ++ |
| SharePoint stockage tenant | > 80% | > 90% | Purge ou achat stockage |
| Appareils non conformes | > 10% | > 25% | Revue politique Intune |
| Sync Entra (dernière sync) | > 1h | > 2h | Vérifier Entra Connect |
| Backup KeepIT (échecs) | > 2% mailboxes | > 5% mailboxes | Investigation |

---

## SECTION 13 — ESCALADES

| Situation | Destination | Délai |
|---|---|---|
| Compte M365 compromis (règles suspectes, transferts) | IT-SecurityMaster → SOC | Immédiat |
| M365 complet indisponible (vérifier Service Health d'abord) | IT-UrgenceMaster | Immédiat |
| Perte de données M365 (Exchange/SharePoint) | IT-BackupDRMaster (KeepIT) | Dans l'heure |
| Problème Entra Connect / sync > 2h | IT-SysAdmin | Dans l'heure |
| Azure VM down / site critique inaccessible | IT-UrgenceMaster | Selon priorité |
| Conditional Access bloque tous les admins | Escalade superviseur + Microsoft Support | Immédiat |
| Coûts Azure anormaux (+30% vs mois précédent) | Chef d'équipe + client | Dans la journée |

---

*BUNDLE_KP_CloudMaster_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
