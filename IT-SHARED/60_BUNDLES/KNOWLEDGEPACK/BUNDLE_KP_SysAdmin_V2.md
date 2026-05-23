# BUNDLE_KP_SysAdmin_V2
**Agent :** @IT-SysAdmin
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** Gestion AD, Exchange Online, DNS/DHCP, fichiers/partages, Hyper-V, services critiques, disques/stockage, patching, WSUS, health check, event logs, seuils d'alerte, escalades.

---

## SECTION 1 — ACTIVE DIRECTORY

### Gestion utilisateurs AD
```powershell
# Créer un compte utilisateur
New-ADUser -Name "Prénom Nom" `
    -SamAccountName "prenom.nom" `
    -UserPrincipalName "prenom.nom@[DOMAINE].com" `
    -Path "OU=Utilisateurs,DC=[DOMAINE],DC=local" `
    -Enabled $true `
    -AccountPassword (Read-Host -AsSecureString "Nouveau MDP") `
    -ChangePasswordAtLogon $true `
    -Department "[DEPARTEMENT]" `
    -Title "[TITRE]" `
    -Manager "[MANAGER]"

# Ajouter au groupe
Add-ADGroupMember -Identity "[NOM_GROUPE]" -Members "prenom.nom"

# Désactiver + déplacer vers OU désactivés
Disable-ADAccount -Identity "prenom.nom"
Move-ADObject -Identity (Get-ADUser "prenom.nom").DistinguishedName `
    -TargetPath "OU=Comptes_Desactives,DC=[DOMAINE],DC=local"

# Réinitialiser MDP (vérifier identité AVANT)
Set-ADAccountPassword "prenom.nom" -Reset -NewPassword (Read-Host -AsSecureString)
Set-ADUser "prenom.nom" -ChangePasswordAtLogon $true
Unlock-ADAccount "prenom.nom"

# Groupes d'un utilisateur
(Get-ADUser "prenom.nom" -Properties MemberOf).MemberOf | ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object

# Recherche d'utilisateurs désactivés depuis 30+ jours
Search-ADAccount -AccountDisabled -UsersOnly | Where-Object { $_.LastLogonDate -lt (Get-Date).AddDays(-30) } | Select-Object Name, LastLogonDate

# Comptes expirés
Search-ADAccount -AccountExpired | Select-Object Name, AccountExpirationDate
```

### Gestion groupes et OUs
```powershell
# Créer un groupe de sécurité
New-ADGroup -Name "[NOM_GROUPE]" -SamAccountName "[NOM_GROUPE]" `
    -GroupScope Global -GroupCategory Security `
    -Path "OU=Groupes,DC=[DOMAINE],DC=local" `
    -Description "[Description du groupe]"

# Membres d'un groupe
Get-ADGroupMember -Identity "[NOM_GROUPE]" -Recursive | Select-Object Name, SamAccountName

# Créer une OU
New-ADOrganizationalUnit -Name "[NOM_OU]" -Path "DC=[DOMAINE],DC=local"

# Supprimer protection contre suppression accidentelle
Set-ADOrganizationalUnit -Identity "OU=[NOM_OU],DC=[DOMAINE],DC=local" -ProtectedFromAccidentalDeletion $false
```

### GPO — Gestion et diagnostic
```powershell
# Lister toutes les GPO
Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime | Sort-Object DisplayName

# Forcer application GPO sur un poste (en remote)
Invoke-Command -ComputerName "[NOM_POSTE]" -ScriptBlock { gpupdate /force }

# Résultat GPO appliqués (sur un utilisateur/ordinateur)
Get-GPResultantSetOfPolicy -Computer "[NOM_POSTE]" -User "[DOMAINE]\prenom.nom" -ReportType Html -Path "C:\Temp\GPOReport.html"

# Lier une GPO à une OU
New-GPLink -Name "[NOM_GPO]" -Target "OU=[NOM_OU],DC=[DOMAINE],DC=local" -LinkEnabled Yes

# Sauvegarder toutes les GPO
Backup-GPO -All -Path "C:\GPO_Backup\$(Get-Date -Format 'yyyy-MM-dd')"
```

### Réplication AD et santé DC
```powershell
# Statut réplication
repadmin /showrepl
repadmin /replsummary

# Forcer réplication
repadmin /syncall /AdeP

# Vérifier SYSVOL et NETLOGON
net share | findstr /i "sysvol netlogon"

# Santé générale DC
dcdiag /test:replications /test:services /test:fsmo /v

# FSMO roles
netdom query fsmo

# NTP synchronisation DC
w32tm /query /status
w32tm /resync /force
```

---

## SECTION 2 — EXCHANGE ONLINE / M365

### Connexion Exchange Online
```powershell
# Connexion (nécessite ExchangeOnlineManagement module)
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName "[ADMIN]@[DOMAINE].com"
```

### Gestion mailbox
```powershell
# Créer boîte partagée
New-Mailbox -Shared -Name "[NOM_BOITE]" -PrimarySmtpAddress "[alias]@[DOMAINE].com"
Add-MailboxPermission "[alias]@[DOMAINE].com" -User "[user]@[DOMAINE].com" -AccessRights FullAccess -AutoMapping $true
Add-RecipientPermission "[alias]@[DOMAINE].com" -Trustee "[user]@[DOMAINE].com" -AccessRights SendAs

# Ajouter alias à une mailbox
Set-Mailbox "[user]@[DOMAINE].com" -EmailAddresses @{Add="[alias]@[DOMAINE].com"}

# Quota mailbox
Set-Mailbox "[user]@[DOMAINE].com" -ProhibitSendQuota 49GB -ProhibitSendReceiveQuota 50GB -IssueWarningQuota 45GB

# Taille mailbox
Get-MailboxStatistics "[user]@[DOMAINE].com" | Select-Object TotalItemSize, ItemCount

# Activer archivage
Enable-Mailbox "[user]@[DOMAINE].com" -Archive

# Transfert automatique — vérifier/supprimer
Get-Mailbox "[user]@[DOMAINE].com" | Select-Object ForwardingSmtpAddress, DeliverToMailboxAndForward
Set-Mailbox "[user]@[DOMAINE].com" -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false
```

### Gestion licences M365
```powershell
# Connexion MSGraph ou MsolService
Connect-MsolService

# Licences disponibles
Get-MsolAccountSku | Select-Object AccountSkuId, ActiveUnits, ConsumedUnits

# Licences d'un utilisateur
Get-MsolUser -UserPrincipalName "[user]@[DOMAINE].com" | Select-Object Licenses

# Assigner licence
Set-MsolUserLicense -UserPrincipalName "[user]@[DOMAINE].com" -AddLicenses "[TENANT]:ENTERPRISEPACK"

# Retirer licence
Set-MsolUserLicense -UserPrincipalName "[user]@[DOMAINE].com" -RemoveLicenses "[TENANT]:ENTERPRISEPACK"
```

### Groupes de distribution
```powershell
# Créer groupe de distribution
New-DistributionGroup -Name "[NOM_GROUPE]" -PrimarySmtpAddress "[groupe]@[DOMAINE].com" -Type Distribution

# Ajouter membre
Add-DistributionGroupMember -Identity "[groupe]@[DOMAINE].com" -Member "[user]@[DOMAINE].com"

# Lister membres
Get-DistributionGroupMember -Identity "[groupe]@[DOMAINE].com" | Select-Object Name, PrimarySmtpAddress
```

### Traçage messages
```powershell
# Tracer un message
Get-MessageTrace -SenderAddress "[exp]@[DOMAINE].com" -RecipientAddress "[dest]@[DOMAINE].com" `
    -StartDate (Get-Date).AddDays(-2) -EndDate (Get-Date) | Select-Object Received, Status, Subject | Format-Table

# Règles Outlook suspectes
Get-InboxRule -Mailbox "[user]@[DOMAINE].com" | Select-Object Name, Enabled, ForwardTo, DeleteMessage | Format-List
Remove-InboxRule -Mailbox "[user]@[DOMAINE].com" -Identity "[NOM_REGLE]"
```

---

## SECTION 3 — DNS / DHCP

### DNS — Diagnostics
```powershell
# Résolution DNS
Resolve-DnsName [NOM_HOTE] -Server [SERVEUR_DNS]
nslookup [NOM_HOTE] [SERVEUR_DNS]

# Zones DNS
Get-DnsServerZone -ComputerName [SERVEUR_DNS]

# Enregistrements d'une zone
Get-DnsServerResourceRecord -ZoneName "[DOMAINE].local" -ComputerName [SERVEUR_DNS]

# Ajouter enregistrement A
Add-DnsServerResourceRecordA -Name "[HOSTNAME]" -ZoneName "[DOMAINE].local" -IPv4Address "[IP_SERVEUR]" -ComputerName [SERVEUR_DNS]

# Ajouter enregistrement CNAME
Add-DnsServerResourceRecordCName -Name "[ALIAS]" -ZoneName "[DOMAINE].local" -HostNameAlias "[HOSTNAME].[DOMAINE].local" -ComputerName [SERVEUR_DNS]

# Supprimer enregistrement
Remove-DnsServerResourceRecord -ZoneName "[DOMAINE].local" -RRType "A" -Name "[HOSTNAME]" -ComputerName [SERVEUR_DNS] -Force

# Vider cache DNS serveur
Clear-DnsServerCache -ComputerName [SERVEUR_DNS] -Force

# Vider cache DNS local
ipconfig /flushdns
```

### DHCP — Gestion
```powershell
# Étendues DHCP
Get-DhcpServerv4Scope -ComputerName [SERVEUR_DHCP]

# Baux actifs d'une étendue
Get-DhcpServerv4Lease -ScopeId "[IP_ETENDUE]" -ComputerName [SERVEUR_DHCP] | Select-Object IPAddress, ClientId, HostName, LeaseExpiryTime

# Réservation DHCP
Add-DhcpServerv4Reservation -ScopeId "[IP_ETENDUE]" -IPAddress "[IP_RESERVEE]" -ClientId "[ADRESSE_MAC]" -Description "[NOM_POSTE]" -ComputerName [SERVEUR_DHCP]

# Statistiques étendue
Get-DhcpServerv4ScopeStatistics -ScopeId "[IP_ETENDUE]" -ComputerName [SERVEUR_DHCP]
# ⚠️ Seuil : Percentages Used > 80% → ajouter des IPs ou créer nouvelle étendue

# Failover DHCP
Get-DhcpServerv4Failover -ComputerName [SERVEUR_DHCP]
```

---

## SECTION 4 — FICHIERS / PARTAGES / DFS

### Partages réseau
```powershell
# Lister partages
Get-SmbShare | Select-Object Name, Path, Description

# Créer un partage
New-SmbShare -Name "[NOM_PARTAGE]" -Path "[CHEMIN_LOCAL]" -Description "[Description]" `
    -FullAccess "[DOMAINE]\[GROUPE_ADMIN]" -ChangeAccess "[DOMAINE]\[GROUPE_UTILISATEURS]"

# Permissions NTFS
Get-Acl "[CHEMIN_LOCAL]" | Format-List
$acl = Get-Acl "[CHEMIN_LOCAL]"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("[DOMAINE]\[GROUPE]","ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow")
$acl.AddAccessRule($rule)
Set-Acl "[CHEMIN_LOCAL]" $acl

# Sessions ouvertes sur partages
Get-SmbSession | Select-Object ClientComputerName, ClientUserName, NumOpens

# Fichiers ouverts
Get-SmbOpenFile | Select-Object ClientComputerName, ClientUserName, Path
```

### Quotas et DFS
```powershell
# Quota sur dossier (nécessite FSRM)
New-FsrmQuota -Path "[CHEMIN_LOCAL]" -Template "100 MB Limit"
Get-FsrmQuota -Path "[CHEMIN_LOCAL]" | Select-Object Path, Usage, SoftLimit, HardLimit

# DFS — Espaces de noms
Get-DfsnRoot
Get-DfsnFolder -Path "\\[DOMAINE]\[NAMESPACE]\*"

# DFS — Réplication
Get-DfsrGroupMembership -GroupName "*" | Select-Object GroupName, ComputerName, State
Get-DfsrBacklog -GroupName "[NOM_GROUPE]" -FolderName "[NOM_DOSSIER]" -SourceComputerName "[SERVEUR1]" -DestinationComputerName "[SERVEUR2]"
# ⚠️ Seuil : Backlog > 1000 fichiers → vérifier réplication et latence réseau
```

---

## SECTION 5 — HYPER-V

### Gestion VMs
```powershell
# Lister toutes les VMs
Get-VM | Select-Object Name, State, CPUUsage, MemoryAssigned, Uptime | Format-Table

# Démarrer / Arrêter / Sauvegarder
Start-VM -Name "[NOM_VM]"
Stop-VM -Name "[NOM_VM]" -Force
Save-VM -Name "[NOM_VM]"

# Configuration VM
Get-VMHardDiskDrive -VMName "[NOM_VM]"
Get-VMNetworkAdapter -VMName "[NOM_VM]"
Set-VM -Name "[NOM_VM]" -ProcessorCount 4 -MemoryStartupBytes 8GB
```

### Snapshots (Checkpoints)
```powershell
# Créer snapshot
Checkpoint-VM -Name "[NOM_VM]" -SnapshotName "Pre-Maintenance_$(Get-Date -Format 'yyyy-MM-dd')"

# Lister snapshots
Get-VMSnapshot -VMName "[NOM_VM]" | Select-Object Name, CreationTime, ParentSnapshotName

# Restaurer snapshot
Restore-VMSnapshot -VMName "[NOM_VM]" -Name "[NOM_SNAPSHOT]" -Confirm:$false

# Supprimer snapshot (après validation réussie)
Remove-VMSnapshot -VMName "[NOM_VM]" -Name "[NOM_SNAPSHOT]"

# ⚠️ RÈGLE : Supprimer les snapshots dans les 48h après maintenance. Snapshots anciens dégradent les performances.
```

### Migration et stockage
```powershell
# Migration stockage (Live Storage Migration)
Move-VMStorage -VMName "[NOM_VM]" -DestinationStoragePath "[CHEMIN_DESTINATION]"

# Migration Live (VM en cours d'exécution)
Move-VM -Name "[NOM_VM]" -DestinationHost "[HOST_DESTINATION]" -IncludeStorage -DestinationStoragePath "[CHEMIN_DESTINATION]"

# Export VM (backup manuel)
Export-VM -Name "[NOM_VM]" -Path "[CHEMIN_EXPORT]"

# Import VM
Import-VM -Path "[CHEMIN_EXPORT]\[NOM_VM]\Virtual Machines\[GUID].vmcx" -Copy -GenerateNewId
```

### Health check Hyper-V
```powershell
# Ressources hôte
Get-VMHost | Select-Object Name, LogicalProcessorCount, MemoryCapacity
$hostMem = Get-Counter '\Memory\Available MBytes'
# ⚠️ Seuil : Mémoire disponible hôte < 10% → risque OOM

# Disques virtuels — vérifier fragmentation et taille
Get-VHD -Path "[CHEMIN_VHD]" | Select-Object Path, VhdType, FileSize, Size, MinimumSize

# Réseaux virtuels
Get-VMSwitch | Select-Object Name, SwitchType, NetAdapterInterfaceDescription
```

---

## SECTION 6 — SERVICES CRITIQUES

### Gestion ordonnée des services
```powershell
# Lister services en erreur
Get-Service | Where-Object { $_.Status -eq "Stopped" -and $_.StartType -eq "Automatic" } | Select-Object Name, DisplayName

# Démarrer service avec dépendances
function Start-ServiceWithDeps {
    param([string]$ServiceName)
    $svc = Get-Service $ServiceName
    foreach ($dep in $svc.ServicesDependedOn) { Start-Service $dep.Name }
    Start-Service $ServiceName
}

# Arrêt ordonné services critiques (exemple serveur applicatif)
# 1. Arrêter services applicatifs en premier
Stop-Service "[SERVICE_APP]" -Force
# 2. Arrêter services de données
Stop-Service "[SERVICE_SQL]" -Force  
# 3. Arrêter services infrastructure
Stop-Service "[SERVICE_INFRA]" -Force

# Redémarrage automatique en cas d'échec
sc.exe failure "[NOM_SERVICE]" reset= 86400 actions= restart/60000/restart/60000/restart/60000
```

### Services critiques à surveiller
```
PRIORITÉ P1 — ALERTE IMMÉDIATE si stoppé :
- Active Directory Domain Services (NTDS)
- DNS Server (DNS)
- Kerberos Key Distribution Center (Kdc)
- Netlogon
- W3SVC (IIS — si serveur Web)
- SQL Server (MSSQLSERVER)
- Remote Desktop Services (TermService)
- Veeam Backup Service

PRIORITÉ P2 — ALERTE dans 15 min :
- DFS Replication (DFSR)
- DHCP Server (DHCPServer)
- Windows Time (W32Time)
- Print Spooler (Spooler)
- Remote Registry (RemoteRegistry)
```

---

## SECTION 7 — DISQUES / STOCKAGE

### Diagnostics disques
```powershell
# Espace disque tous les volumes
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{N='Used(GB)';E={[math]::Round($_.Used/1GB,2)}}, @{N='Free(GB)';E={[math]::Round($_.Free/1GB,2)}}, @{N='Total(GB)';E={[math]::Round(($_.Used+$_.Free)/1GB,2)}}

# Espace disque en remote
Invoke-Command -ComputerName "[NOM_SERVEUR]" -ScriptBlock {
    Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free
}

# Volumes montés
Get-Volume | Select-Object DriveLetter, FileSystemLabel, Size, SizeRemaining, HealthStatus
# ⚠️ Seuil : SizeRemaining < 20% du total → ticket de croissance

# Top 10 dossiers les plus lourds
$path = "C:\"
Get-ChildItem $path -Directory | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    [PSCustomObject]@{Folder=$_.FullName; SizeGB=[math]::Round($size/1GB,2)}
} | Sort-Object SizeGB -Descending | Select-Object -First 10
```

### Extension de volume
```powershell
# Vérifier partitions
Get-Disk | Select-Object Number, FriendlyName, Size, PartitionStyle
Get-Partition | Select-Object DiskNumber, PartitionNumber, Size, DriveLetter

# Étendre volume (si espace non alloué disponible)
$maxSize = (Get-PartitionSupportedSize -DriveLetter C).SizeMax
Resize-Partition -DriveLetter C -Size $maxSize

# Via diskpart (si PowerShell échoue)
# diskpart → select volume X → extend
```

### SMART et santé disque
```powershell
# Statut SMART via WMI
Get-WmiObject -Class Win32_DiskDrive | Select-Object Model, Status, Size
# Status "OK" = normal | Status "Pred Fail" = remplacer IMMÉDIATEMENT

# Événements disque dans Event Log
Get-EventLog -LogName System -EntryType Error,Warning -Source "disk","atapi","storahci" -Newest 50 | Select-Object TimeGenerated, Source, Message

# ⚠️ Event ID 7, 11, 153 (disk) → Investigation urgente matérielle
# ⚠️ Event ID 51 (disk) → Erreur I/O → vérifier câblage/contrôleur
```

---

## SECTION 8 — PATCHING ET MAINTENANCE

> ⚠️ Pour les campagnes de patching de masse (50+ serveurs, fenêtres planifiées, Qualys CVE), utiliser **IT-MaintenanceMaster** — il est calibré pour ça.
> Cette section couvre le patching ponctuel (1-5 serveurs, intervention réactive).

### Règle fondamentale — Séquencement par rôle

**1 serveur par groupe de rôle à la fois — pas 1 serveur total.**

| Groupe de rôle | Séquence correcte | Risque si mal fait |
|---|---|---|
| RDS (3 serveurs) | RDS-01 → valider sessions → RDS-02 → valider → RDS-03 | 3 reboots simultanés = tous les usagers dehors = P1 |
| DC (2 serveurs) | DC secondaire → valider AD réplication → DC primaire | 2 DC down = plus d'authentification = P1 total |
| SQL cluster | Nœud passif → failover → nœud actif | Perte de données si mal séquencé |
| Serveurs fichiers | Secondaire → valider accès → primaire | Perte d'accès aux partages |

**Valider que les sessions/services/accès sont opérationnels AVANT de passer au suivant du même groupe.**

### Checklist pré-maintenance
```
PRÉ-MAINTENANCE OBLIGATOIRE :
[ ] Billet CW ouvert avec fenêtre approuvée
[ ] Documentation client Hudu consultée — identifier les groupes de rôles
[ ] Séquence établie (quel serveur en premier par groupe)
[ ] Snapshot VM créé (si serveur virtuel — SAUF DC)
[ ] Backup vérifié — succès dans les 24h
[ ] Contact client notifié si impact service
[ ] Mode maintenance RMM activé
[ ] Pending reboot check effectué
```

### Scripts de patching
```powershell
# Vérifier mises à jour disponibles
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$Results = $Searcher.Search("IsInstalled=0")
$Results.Updates | Select-Object Title, MsrcSeverity, IsDownloaded

# Historique des mises à jour (30 derniers jours)
Get-HotFix | Where-Object { $_.InstalledOn -gt (Get-Date).AddDays(-30) } | Sort-Object InstalledOn -Descending
```

### UPDATE NON APPROUVÉE — Désinstaller + Bloquer avant reboot

**Scénario :** KB installée manuellement ou malgré le RMM. Serveur en pending reboot. Désinstaller sans reboot, cacher la KB, puis rebooter proprement.

```powershell
# ÉTAPE 1 — Identifier la KB non approuvée
Get-HotFix | Where-Object { $_.InstalledOn -gt (Get-Date).AddHours(-24) } |
    Select-Object HotFixID, InstalledOn | Sort-Object InstalledOn -Descending

$KB = "XXXXXXX"   # Remplacer par le numéro KB (ex: 5034441)

# ÉTAPE 2 — Désinstaller sans reboot
wusa.exe /uninstall /kb:$KB /quiet /norestart
# Attendre la fin de wusa.exe avant de continuer (2-5 min)

# Si wusa échoue : méthode alternative
$pkg = Get-WindowsPackage -Online | Where-Object { $_.PackageName -match $KB }
if ($pkg) { Remove-WindowsPackage -Online -PackageName $pkg.PackageName -NoRestart }

# ÉTAPE 3 — Cacher la KB (empêcher réinstallation automatique)

# Option A : PSWindowsUpdate
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module PSWindowsUpdate -Force -Scope AllUsers
}
Import-Module PSWindowsUpdate
Hide-WindowsUpdate -KBArticleID $KB -Confirm:$false
Get-WindowsUpdate -IsHidden | Where-Object { $_.KBArticleIDs -contains $KB }

# Option B : COM API (sans module externe)
$Session  = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$All      = $Searcher.Search("IsInstalled=0")
$Target   = $All.Updates | Where-Object { $_.KBArticleIDs -contains $KB }
if ($Target) { $Target.IsHidden = $true; Write-Host "KB$KB cachée." -ForegroundColor Green }

# ÉTAPE 4 — Valider avant reboot
$check = Get-HotFix -Id "KB$KB" -ErrorAction SilentlyContinue
if ($check) { Write-Host "⚠️ KB$KB encore présente — désinstallation incomplète." -ForegroundColor Red }
else        { Write-Host "✅ KB$KB désinstallée et cachée — prêt pour reboot." -ForegroundColor Green }

# ÉTAPE 5 — Reboot contrôlé
query user
Restart-Computer -Force

# APRÈS REBOOT — Confirmer que la KB ne revient pas
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5
Get-WindowsUpdate | Where-Object { $_.KBArticleIDs -contains $KB }
# → Ne doit PAS apparaître dans les updates disponibles
```

> ⚠️ **Ne jamais rebooter avant d'avoir caché la KB.** Windows Update peut la réinstaller automatiquement au prochain démarrage si elle n'est pas cachée.

### WSUS
```powershell
# Synchronisation WSUS (sur serveur WSUS)
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()
$wsus.GetSubscription().StartSynchronization()

# Statut clients WSUS
$wsus.GetComputerTargets() | Where-Object { $_.LastSyncTime -lt (Get-Date).AddDays(-7) } | Select-Object FullDomainName, LastSyncTime
# ⚠️ Clients sans sync depuis 7 jours → vérifier connectivité et service Windows Update
```

---

## SECTION 9 — EVENT LOGS — ÉVÉNEMENTS CRITIQUES

### Script d'analyse des événements critiques
```powershell
# Événements critiques dernières 24h
$Events = @(
    @{Log="System"; IDs=@(41,1001,1074,6008,7034,7036,7040)},  # Crashs, services
    @{Log="Application"; IDs=@(1000,1001,1002,1026)},             # Erreurs app
    @{Log="Security"; IDs=@(4625,4648,4720,4732,4756,4776)}       # Sécurité AD
)

foreach ($E in $Events) {
    Get-EventLog -LogName $E.Log -EntryType Error,Warning -InstanceId $E.IDs -After (Get-Date).AddHours(-24) -ErrorAction SilentlyContinue |
    Select-Object TimeGenerated, Source, EventID, Message | Format-Table -AutoSize
}
```

### Event IDs critiques à connaître
```
SYSTEM LOG :
41    → Kernel Power — crash/arrêt inattendu
1001  → Windows Error Reporting
1074  → Arrêt/reboot initié
6008  → Arrêt inattendu précédent
7034  → Service crashé inopinément
7036  → Service démarré/arrêté

SECURITY LOG :
4625  → Échec d'ouverture de session (bruteforce si répété)
4648  → Ouverture de session avec credentials explicites
4720  → Compte utilisateur créé
4732  → Membre ajouté au groupe Administrateurs locaux
4756  → Membre ajouté à un groupe universel
4776  → Validation credentials (Kerberos failure)

APPLICATION LOG :
1000  → Application crash
1001  → Application Hang
1026  → .NET Runtime error
```

---

## SECTION 10 — HEALTH CHECK SERVEUR (hérité V1)

### Script health check complet
```powershell
# ===== HEALTH CHECK SERVEUR =====
$Server = $env:COMPUTERNAME
Write-Host "=== HEALTH CHECK : $Server ===" -ForegroundColor Cyan

# CPU
$CPU = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 2 -MaxSamples 3
$CPUAvg = ($CPU.CounterSamples.CookedValue | Measure-Object -Average).Average
Write-Host "CPU Usage: $([math]::Round($CPUAvg,1))%" -ForegroundColor $(if ($CPUAvg -gt 70) {"Red"} else {"Green"})

# RAM
$OS = Get-CimInstance Win32_OperatingSystem
$RAMFree = [math]::Round($OS.FreePhysicalMemory/1MB, 1)
$RAMTotal = [math]::Round($OS.TotalVisibleMemorySize/1MB, 1)
$RAMPct = [math]::Round(($RAMFree/$RAMTotal)*100, 1)
Write-Host "RAM Free: ${RAMFree}GB / ${RAMTotal}GB ($RAMPct%)" -ForegroundColor $(if ($RAMPct -lt 20) {"Red"} else {"Green"})

# Disques
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $freePct = [math]::Round(($_.Free/($_.Used+$_.Free))*100,1)
    Write-Host "Disk $($_.Name): Free $freePct%" -ForegroundColor $(if ($freePct -lt 20) {"Red"} else {"Green"})
}

# Services arrêtés (auto-démarrage)
$StoppedSvcs = Get-Service | Where-Object { $_.Status -eq "Stopped" -and $_.StartType -eq "Automatic" }
if ($StoppedSvcs) { Write-Host "⚠️ Services arrêtés:" -ForegroundColor Red; $StoppedSvcs | Select-Object Name, DisplayName }

# Pending reboot
$PendingReboot = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
Write-Host "Pending Reboot: $PendingReboot" -ForegroundColor $(if ($PendingReboot) {"Yellow"} else {"Green"})

# Uptime
$Uptime = (Get-Date) - $OS.LastBootUpTime
Write-Host "Uptime: $($Uptime.Days)d $($Uptime.Hours)h $($Uptime.Minutes)m"
```

---

## SECTION 11 — SEUILS D'ALERTE

| Ressource | Avertissement | Critique | Action |
|---|---|---|---|
| CPU serveur | > 70% soutenu 10 min | > 90% soutenu 5 min | Analyser processus, escalade INFRA |
| RAM libre | < 20% | < 10% | Identifier processus gourmands, envisager upgrade |
| Espace disque C: | < 20% | < 10% | Nettoyage, extension volume ou migration |
| Espace disque Data | < 15% | < 8% | Ticket croissance stockage |
| DHCP utilisation | > 80% | > 90% | Étendre étendue ou créer nouvelle |
| AD Replication lag | > 5 min | > 15 min | dcdiag + repadmin |
| DFS Backlog | > 500 fichiers | > 1000 fichiers | Vérifier liens DFS et latence |
| Snapshot age | > 24h | > 48h | Supprimer après validation |
| Backup job failed | 1 jour | 2 jours | Escalade BackupDRMaster |

---

## SECTION 12 — TEMPLATES CW

### Note Interne CW — SysAdmin
```
Prise en connaissance de la demande et consultation de la documentation du client.

## Contexte
[Type d'intervention : Patching / AD / Exchange / DNS / Hyper-V / Autre]
[Serveur(s) concerné(s) : [NOM_SERVEUR]]
[Environnement : Production / Dev / Test]

## Pré-checks effectués
- Backup vérifié : [Oui/Non — date dernier succès]
- Snapshot créé : [Oui/Non — nom snapshot]
- Mode maintenance RMM : [Activé/Non requis]

## Timeline
- HH:MM — Début intervention
- HH:MM — [Action effectuée]
- HH:MM — [Résultat observé]
- HH:MM — Post-check complété

## Actions effectuées
- [Action 1 — résultat]
- [Action 2 — résultat]
- [Action 3 — résultat]

## Post-checks
- Services opérationnels : [Oui/Non]
- Event Log vérifié : [Aucune erreur / Erreurs mineures / Erreurs à surveiller]
- Fonctionnalité confirmée avec utilisateur : [Oui/Non/N.A.]

## Résolution
[Résolu / En cours / Escaladé — détails]

## Suivi
[Prochaine étape ou N/A]
```

### Discussion CW (client-safe)
```
Prise en connaissance de la demande et consultation de la documentation du client.

### TRAVAUX EFFECTUÉS
- Vérification préalable de l'environnement et des sauvegardes
- [Action 1 en langage client]
- [Action 2 en langage client]
- [Validation du bon fonctionnement]
- Confirmation auprès de l'utilisateur

### RÉSULTAT
[État final — service fonctionnel / en cours / planifié]

Durée : [X]h[XX]min
```

---

## SECTION 13 — ESCALADES

| Situation | Destination | Délai |
|---|---|---|
| DC down / réplication AD rompue | IT-UrgenceMaster → NOC | Immédiat |
| Ransomware / compromission compte | IT-SecurityMaster → SOC | Immédiat |
| Backup critique échoué 2 jours | IT-BackupDRMaster | Dans l'heure |
| Hyperviseur instable / VM crash répétés | IT-UrgenceMaster | Dans l'heure |
| Espace disque < 10% serveur prod | NOC + Chef d'équipe | Dans l'heure |
| Réseau site complet down | IT-UrgenceMaster → IT-NetworkMaster | Immédiat |
| Exchange Online indisponible (tous users) | IT-CloudMaster → IT-UrgenceMaster | Immédiat |
| RAID dégradé / disque SMART failure | IT-BackupDRMaster + INFRA | Dans l'heure |
| Modification GPO critique (sécurité) | Approbation superviseur requise | Avant action |

---

*BUNDLE_KP_SysAdmin_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
