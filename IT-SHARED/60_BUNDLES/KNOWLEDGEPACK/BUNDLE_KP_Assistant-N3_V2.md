# BUNDLE_KP_Assistant-N3_V2
**Agent :** @IT-Assistant-N3
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** AD avancé (réplication, FSMO, tombstone), Exchange Online avancé, virtualisation avancée (cluster, HA, migration), réseau avancé (BGP, VLAN, diagnostics), PowerShell avancé (remoting, DSC), scripts de déploiement, diagnostic avancé (dumps, perfmon), architecture review, runbooks V1, templates de fermeture, escalades.

---

## SECTION 1 — ACTIVE DIRECTORY AVANCÉ

### Réplication AD
```powershell
# État complet de la réplication
repadmin /showrepl /csv > "C:\Temp\Replication_$(Get-Date -Format 'yyyyMMdd').csv"
repadmin /replsummary

# Réplication depuis/vers un DC spécifique
repadmin /showrepl [NOM_DC] /verbose

# Forcer réplication dans tous les sens
repadmin /syncall /AdeP  # A=cross-site, d=ID Distinguished, e=entreprise, P=push

# Statistiques de réplication par NC
repadmin /showrepl * /csv | ConvertFrom-Csv | 
    Select-Object "Destination DSA", "Naming Context", "Number of Failures", "Last Failure Status" |
    Where-Object { $_."Number of Failures" -gt 0 }

# Identifier les DC qui ne se répliquent plus (lingering objects risk)
repadmin /showrepl * /errorsonly

# Tester la réplication entre deux DCs
repadmin /replicate [DC_DEST] [DC_SOURCE] "DC=[DOMAINE],DC=local"
```

### FSMO Roles
```powershell
# Identifier les détenteurs de rôles FSMO
netdom query fsmo

# Vérifier via PowerShell
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster

# Transférer un rôle FSMO (gracieusement — le DC source doit être disponible)
Move-ADDirectoryServerOperationMasterRole -Identity "[DC_DESTINATION]" -OperationMasterRole PDCEmulator -Confirm:$false
# OperationMasterRole : PDCEmulator | RIDMaster | InfrastructureMaster | SchemaMaster | DomainNamingMaster

# Saisir un rôle FSMO (SEIZE — uniquement si le DC source est définitivement mort)
# Via ntdsutil :
# ntdsutil → "roles" → "connections" → "connect to server [DC_DEST]" → "quit" → "seize [NOM_ROLE]"
# ⚠️ SEIZE est irréversible — ne jamais remettre le DC source en ligne après
```

### Tombstone et récupération
```powershell
# Vérifier la durée de vie Tombstone
(Get-ADObject "CN=Directory Service,CN=Windows NT,CN=Services,$(([ADSI]"LDAP://RootDSE").configurationNamingContext)" -Properties tombstoneLifetime).tombstoneLifetime
# Par défaut : 180 jours (forêts modernes) ou 60 jours (forêts anciennes)

# Récupérer un objet AD supprimé (si dans la Corbeille AD)
# Activer la Corbeille AD si pas encore fait :
Enable-ADOptionalFeature "Recycle Bin Feature" -Scope ForestOrConfigurationSet -Target "[DOMAINE].local" -Confirm:$false

# Restaurer un utilisateur supprimé depuis la Corbeille
$deletedUser = Get-ADObject -Filter { sAMAccountName -eq "[prenom.nom]" } -IncludeDeletedObjects -Properties *
Restore-ADObject $deletedUser.ObjectGUID

# Si Corbeille AD non activée et objet dans tombstone :
# → Méthode Authoritative Restore depuis backup AD
# → Requiert ntdsutil en DSRM (Directory Services Restore Mode)
# → ⚠️ Escalade INFRA requise
```

### Diagnostic santé AD complet
```powershell
# DCDiag complet sur tous les DCs
dcdiag /test:replications /test:services /test:fsmo /test:dns /test:netlogons /test:ridmanager /v /e

# Netlogon et SYSVOL
net share | findstr /i "sysvol netlogon"
Get-ChildItem "\\[DOMAINE]\SYSVOL\[DOMAINE]\Policies" | Measure-Object  # Doit correspondre entre tous les DCs

# Audit des GPO dans SYSVOL vs AD
$adGPOs = (Get-GPO -All).Count
$sysvolGPOs = (Get-ChildItem "\\[DOMAINE]\SYSVOL\[DOMAINE]\Policies" -Directory | Where-Object { $_.Name -ne "PolicyDefinitions" }).Count
if ($adGPOs -ne $sysvolGPOs) { Write-Host "AVERTISSEMENT : $adGPOs GPOs dans AD mais $sysvolGPOs dans SYSVOL" -ForegroundColor Yellow }
```

---

## SECTION 2 — EXCHANGE ONLINE AVANCÉ

### Migration et hybrid
```powershell
# Prérequis Hybrid Configuration Wizard (HCW)
# → Exchange Server on-prem + Exchange Online → HCW déployé sur Exchange on-prem
# → Vérifier : Test-OAuthConnectivity -Service EWS -TargetUri https://outlook.office365.com

# Migrer des boîtes aux lettres vers Exchange Online (Cutover ou Hybrid)
# Connexion Exchange Online
Connect-ExchangeOnline -UserPrincipalName "[ADMIN]@[DOMAINE].com"

# Vérifier le statut d'une migration en cours
Get-MigrationBatch | Select-Object Identity, Status, TotalCount, SyncedCount, FailedCount

# Détails d'une migration utilisateur
Get-MigrationUser -Identity "[user]@[DOMAINE].com" | Select-Object Identity, Status, Error, DataConsistencyScore

# Finaliser une migration batch
Complete-MigrationBatch -Identity "[NOM_BATCH]"

# Rapport de migration
Get-MigrationUserStatistics -Identity "[user]@[DOMAINE].com" | Select-Object PercentageComplete, BytesTransferred, Items
```

### Transport Rules et Connectors
```powershell
# Lister les règles de transport
Get-TransportRule | Select-Object Name, State, Priority, Description | Sort-Object Priority

# Créer une règle de transport (exemple : disclaimer d'entreprise)
New-TransportRule -Name "[NOM_REGLE]" `
    -FromScope InOrganization `
    -ApplyHtmlDisclaimerText "<br><br>[TEXTE_DISCLAIMER]" `
    -ApplyHtmlDisclaimerLocation Append `
    -ApplyHtmlDisclaimerFallbackAction Wrap

# Connecteurs de réception et d'envoi
Get-ReceiveConnector | Select-Object Name, Enabled, Bindings, RemoteIPRanges
Get-SendConnector | Select-Object Name, Enabled, AddressSpaces, SmartHosts

# Tester un connecteur d'envoi
Test-SendConnector -Sender "[test]@[DOMAINE].com" -Recipients "[test@externe.com]"

# Domaine accepté
Get-AcceptedDomain | Select-Object Name, DomainName, DomainType, Default
```

---

## SECTION 3 — VIRTUALISATION AVANCÉE

### Clustering Hyper-V
```powershell
# Statut cluster
Get-Cluster | Select-Object Name, Domain, SharedVolumesRoot
Get-ClusterNode | Select-Object Name, State, NodeWeight

# Ressources cluster
Get-ClusterResource | Select-Object Name, ResourceType, State, OwnerGroup, OwnerNode

# VMs sur le cluster
Get-ClusterGroup | Where-Object { $_.GroupType -eq "VirtualMachine" } |
    Select-Object Name, State, OwnerNode

# Santé du cluster
Test-Cluster -Node @("[NOEUD1]","[NOEUD2]") -Include "Network","Inventory","Storage"

# Volumes partagés cluster (CSV)
Get-ClusterSharedVolume | Select-Object Name, State, @{N='OwnerNode';E={$_.OwnerNode.Name}}
Get-ClusterSharedVolumeState | Select-Object Name, Node, VolumeOffset, FriendlyVolumeName
```

### Live Migration et HA
```powershell
# Live Migration (VM en production, zéro downtime)
Move-VM -Name "[NOM_VM]" -DestinationHost "[HOST_DESTINATION]" -Verbose
# Si stockage aussi à migrer :
Move-VM -Name "[NOM_VM]" -DestinationHost "[HOST_DESTINATION]" -IncludeStorage -DestinationStoragePath "[CHEMIN_DEST]"

# Migration rapide (quelques secondes de downtime)
Move-VMStorage -VMName "[NOM_VM]" -DestinationStoragePath "[CHEMIN_DEST]"

# Configuration HA pour VM
Set-VM -Name "[NOM_VM]" -AutomaticStartAction Start -AutomaticStartDelay 30 -AutomaticStopAction Save

# Drain un noeud pour maintenance
Suspend-ClusterNode -Name "[NOEUD]" -Drain
# Vérifier que toutes les VMs ont migré
Get-ClusterGroup | Where-Object { $_.OwnerNode.Name -eq "[NOEUD]" -and $_.GroupType -eq "VirtualMachine" }
# Reprendre le noeud après maintenance
Resume-ClusterNode -Name "[NOEUD]" -Failback Immediate

# Storage vMotion (déplacer le stockage de la VM sans l'éteindre)
Move-VMStorage -VMName "[NOM_VM]" -DestinationStoragePath "[NOUVEAU_CHEMIN_CSV]"
```

---

## SECTION 4 — RÉSEAU AVANCÉ

### VLAN et Trunk
```powershell
# Windows — VLAN sur carte réseau (via Hyper-V switch ou NIC teaming)
# Hyper-V VM — assigner VLAN à une carte réseau virtuelle
Set-VMNetworkAdapterVlan -VMName "[NOM_VM]" -VMNetworkAdapterName "[NOM_ADAPTATEUR]" -Access -VlanId [ID_VLAN]

# Vérifier VLAN configuré
Get-VMNetworkAdapterVlan -VMName "[NOM_VM]" | Select-Object VMName, OperationMode, AccessVlanId, AllowedVlanIdList

# Trunk (plusieurs VLANs sur un adaptateur)
Set-VMNetworkAdapterVlan -VMName "[NOM_VM]" -VMNetworkAdapterName "[NOM_ADAPTATEUR]" `
    -Trunk -AllowedVlanIdList "10,20,30,100" -NativeVlanId 1
```

### Diagnostics réseau avancés
```powershell
# Analyse de paquets avec Wireshark (commande netsh)
# Capture sur interface
netsh trace start capture=yes IPv4.Address=[IP_A_CAPTURER] tracefile=C:\Temp\capture.etl
# Arrêter la capture
netsh trace stop
# Convertir en PCAP (avec etl2pcapng ou Wireshark)

# Statistiques réseau détaillées
netstat -an | Group-Object { $_ -split '\s+' | Select-Object -Last 1 } | 
    Select-Object Name, Count | Sort-Object Count -Descending

# Bande passante réseau temps réel
$counter = Get-Counter '\Network Interface(*)\Bytes Total/sec' -SampleInterval 2 -MaxSamples 5
$counter.CounterSamples | Where-Object { $_.InstanceName -notlike "*loopback*" } |
    Select-Object InstanceName, @{N='Mbps';E={[math]::Round($_.CookedValue * 8 / 1MB, 2)}}

# MTU et fragmentation
ping -f -l 1472 [IP_DESTINATION]   # 1472 + 28 bytes header = 1500 MTU standard
ping -f -l 1400 [IP_DESTINATION]   # Si fragments → problème MTU

# DNS avancé — lookup DNSSEC
Resolve-DnsName [DOMAINE].com -Type DNSKEY -Server 8.8.8.8
Resolve-DnsName [DOMAINE].com -DnssecOk -Server 8.8.8.8

# Routage et tables
Get-NetRoute | Sort-Object RouteMetric | Select-Object DestinationPrefix, NextHop, RouteMetric, InterfaceAlias | Format-Table
```

### ACL et firewall
```powershell
# Règles Windows Firewall avancées
Get-NetFirewallRule | Where-Object { $_.Enabled -eq "True" -and $_.Direction -eq "Inbound" } |
    Select-Object Name, DisplayName, Action, Protocol, Profile | Format-Table

# Vérifier si un port est bloqué
Test-NetConnection [IP_DESTINATION] -Port [PORT] -InformationLevel Detailed

# Ajouter règle firewall
New-NetFirewallRule -DisplayName "[NOM_REGLE]" `
    -Direction Inbound -Protocol TCP -LocalPort [PORT] -Action Allow `
    -Profile Domain,Private

# Audit connexions sortantes bloquées (event log)
Get-WinEvent -LogName "Security" -FilterHashtable @{Id=5157} -MaxEvents 20 |
    Select-Object TimeCreated, Message
```

---

## SECTION 5 — POWERSHELL AVANCÉ

### Remoting (PSRemoting)
```powershell
# Activer PSRemoting sur cibles (via GPO ou manuellement)
Enable-PSRemoting -Force

# Session distante interactive
Enter-PSSession -ComputerName [NOM_SERVEUR] -Credential (Get-Credential)

# Exécution sur plusieurs machines en parallèle
$servers = @("[SERVEUR1]","[SERVEUR2]","[SERVEUR3]")
$sessions = New-PSSession -ComputerName $servers -Credential (Get-Credential)
Invoke-Command -Session $sessions -ScriptBlock {
    Get-Service | Where-Object { $_.Status -eq "Stopped" -and $_.StartType -eq "Automatic" }
} | Select-Object PSComputerName, Name, Status

# Fan-out — script complexe sur liste de serveurs
$results = Invoke-Command -ComputerName $servers -ThrottleLimit 10 -ScriptBlock {
    param($ScriptParam)
    # Votre code ici
    $env:COMPUTERNAME
} -ArgumentList "valeur"

# Déconnexion propre
Remove-PSSession -Session $sessions
```

### DSC (Desired State Configuration)
```powershell
# Vérifier conformité DSC d'un noeud
Get-DscConfigurationStatus -CimSession [NOM_SERVEUR] | Select-Object Status, StartDate, Type, Error

# Forcer re-application de la configuration DSC
Invoke-DscResource -ModuleName PSDesiredStateConfiguration -Name Service `
    -Property @{Name="[NOM_SERVICE]"; State="Running"; Ensure="Present"} -Method Set

# Configuration DSC simple (exemple — service doit être démarré)
Configuration EnsureServiceRunning {
    param ([string[]]$ComputerName)
    Node $ComputerName {
        Service EnsureWinRM {
            Name = "WinRM"
            State = "Running"
            Ensure = "Present"
        }
    }
}
EnsureServiceRunning -ComputerName "[NOM_SERVEUR]"
Start-DscConfiguration -Path .\EnsureServiceRunning -Wait -Verbose -Force
```

### Modules personnalisés
```powershell
# Structure d'un module PowerShell
# C:\Program Files\WindowsPowerShell\Modules\[NomModule]\
# ├── [NomModule].psd1  (manifest)
# └── [NomModule].psm1  (code)

# Créer un manifest de module
New-ModuleManifest -Path "C:\Modules\MSPTools\MSPTools.psd1" `
    -RootModule "MSPTools.psm1" `
    -ModuleVersion "1.0.0" `
    -Author "IT MSP" `
    -Description "Outils MSP personnalisés"

# Importer et inspecter un module
Import-Module MSPTools -Force
Get-Module MSPTools | Select-Object Name, Version, ExportedFunctions
Get-Command -Module MSPTools

# Publier sur dépôt interne (NuGet/PowerShell Gallery interne)
Register-PSRepository -Name "InternalRepo" -SourceLocation "[URL_REPO]" -InstallationPolicy Trusted
Publish-Module -Name MSPTools -Repository InternalRepo
```

---

## SECTION 6 — SCRIPTS DE DÉPLOIEMENT

### Onboarding serveur complet
```powershell
# ===== ONBOARDING NOUVEAU SERVEUR WINDOWS =====
param(
    [string]$NewServerName,
    [string]$DomainName = "[DOMAINE].local",
    [string]$OUPath = "OU=Serveurs,DC=[DOMAINE],DC=local",
    [string]$AdminEmail = "[ADMIN]@[DOMAINE].com"
)

Write-Host "=== ONBOARDING : $NewServerName ===" -ForegroundColor Cyan

# 1. Renommer le serveur
Rename-Computer -NewName $NewServerName -Force -Restart
# ⚠️ Attendre redémarrage avant de continuer

# 2. Configurer NTP
w32tm /config /manualpeerlist:"[NTP_SERVER]" /syncfromflags:manual /reliable:YES /update
Restart-Service w32tm
w32tm /resync

# 3. Joindre au domaine
Add-Computer -DomainName $DomainName -OUPath $OUPath -Credential (Get-Credential) -Restart

# 4. Post-join : activer RMM, antivirus, outils de gestion
# (à personnaliser selon outils MSP)

# 5. Activer WinRM / PSRemoting
Enable-PSRemoting -Force
Set-WSManQuickConfig -Force

# 6. Configurer Windows Firewall
Set-NetFirewallProfile -Profile Domain,Private -Enabled True
# Autoriser ping
New-NetFirewallRule -DisplayName "Allow ICMPv4" -Protocol ICMPv4 -IcmpType 8 -Action Allow -Profile Any

# 7. Activer Event Logging étendu
wevtutil sl Security /ms:1073741824  # 1 GB Security log
wevtutil sl System /ms:209715200     # 200 MB System log
wevtutil sl Application /ms:209715200

# 8. Désactiver services inutiles (selon rôle)
Set-Service -Name "Fax" -StartupType Disabled
Set-Service -Name "XblAuthManager" -StartupType Disabled

Write-Host "Onboarding terminé. Vérifier dans AD que le compte est dans la bonne OU." -ForegroundColor Green
```

### Déploiement rôle Windows (exemple : DHCP)
```powershell
# Installer et configurer DHCP Server
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Add-DhcpServerInDC -DnsName "[NOM_SERVEUR].[DOMAINE].local" -IPAddress "[IP_SERVEUR]"
Set-DhcpServerv4DnsSetting -ComputerName "[NOM_SERVEUR]" -DynamicUpdates Always -DeleteDnsRROnLeaseExpiry $true

# Créer une étendue
Add-DhcpServerv4Scope -Name "[NOM_ETENDUE]" `
    -StartRange "[IP_DEBUT]" -EndRange "[IP_FIN]" `
    -SubnetMask "[MASQUE]" -State Active `
    -ComputerName "[NOM_SERVEUR]"

# Options DHCP (passerelle, DNS)
Set-DhcpServerv4OptionValue -ScopeId "[IP_ETENDUE]" `
    -Router "[IP_PASSERELLE]" `
    -DnsServer "[IP_DNS1]","[IP_DNS2]" `
    -ComputerName "[NOM_SERVEUR]"

# Autoriser sur le DC (si DHCP est sur membre de domaine)
Add-DhcpServerInDC -DnsName "[NOM_SERVEUR].[DOMAINE].local"
```

---

## SECTION 7 — DIAGNOSTIC AVANCÉ

### Analyse dump mémoire (WinDbg basique)
```
ANALYSE DUMP MÉMOIRE — WORKFLOW :

1. Localiser le fichier dump
   → C:\Windows\MEMORY.DMP (full dump)
   → C:\Windows\Minidump\*.dmp (mini dumps)
   → Taille : mini ~1MB, kernel = RAM utilisée, full = RAM totale

2. Ouvrir avec WinDbg (Windows Debugging Tools)
   → Fichier → Ouvrir le fichier crash dump
   → Attendre le chargement des symboles

3. Commandes WinDbg essentielles :
   !analyze -v          → Analyse automatique (lancer EN PREMIER)
   !process 0 0         → Lister les processus au moment du crash
   !thread              → Threads actifs
   lmvm [nom_driver]    → Info sur un pilote spécifique
   kn                   → Call stack du thread courant
   .logopen C:\Temp\dump_analysis.txt → Sauvegarder l'analyse

4. Identifier le pilote coupable :
   Dans la sortie !analyze -v → chercher "DRIVER_NAME:" ou "IMAGE_NAME:"
   → Si c'est un driver Microsoft → patch/update Windows
   → Si c'est un driver tiers → mise à jour ou désinstallation du driver
```

```powershell
# Forcer création d'un dump complet (pour analyse planifiée)
# Via WMI :
$wmiClass = Get-WmiObject Win32_OSRecoveryConfiguration -EnableAllPrivileges
$wmiClass.DebugInfoType = 1  # 1=MiniDump, 2=KernelDump, 3=FullDump
$wmiClass.Put()

# Vérifier configuration dump
Get-WmiObject Win32_OSRecoveryConfiguration | Select-Object DebugInfoType, ExpandedMiniDumpDirectory

# Analyser les BSOD récents via Event Log
Get-WinEvent -LogName System -FilterHashtable @{LogName='System'; Id=@(41,1001,6008)} -MaxEvents 20 |
    Select-Object TimeCreated, Id, Message | Format-Table -Wrap
```

### Perfmon et baseline de performance
```powershell
# Créer un data collector set pour baseline
$dcSet = New-Object -ComObject Pla.DataCollectorSet
$dcSet.DisplayName = "MSP_Baseline_$(Get-Date -Format 'yyyyMMdd')"
$dcSet.Duration = 3600  # 1 heure

# Compteurs à capturer
$counters = @(
    '\Processor(_Total)\% Processor Time',
    '\Memory\Available MBytes',
    '\PhysicalDisk(_Total)\Avg. Disk Queue Length',
    '\PhysicalDisk(_Total)\% Disk Time',
    '\Network Interface(*)\Bytes Total/sec',
    '\System\Processor Queue Length',
    '\System\Context Switches/sec'
)

# Via Get-Counter pour analyse immédiate
$baseline = Get-Counter -Counter $counters -SampleInterval 10 -MaxSamples 12
$baseline.CounterSamples | Select-Object Path, @{N='Avg';E={($baseline.CounterSamples | Where-Object Path -eq $_.Path | Measure-Object CookedValue -Average).Average}}

# Seuils d'intervention :
# Processor Time > 80% soutenu → investigation processus
# Disk Queue Length > 2 → bottleneck I/O
# Available MBytes < 512 (serveur) → pression mémoire
# Context Switches > 10000/sec → contention CPU
```

### Événements Windows avancés
```powershell
# Analyse complète event log
function Get-CriticalEvents {
    param([string]$ComputerName = $env:COMPUTERNAME, [int]$HoursBack = 24)
    
    $start = (Get-Date).AddHours(-$HoursBack)
    
    $criticalEvents = @(
        @{Log="System"; IDs=@(41,1001,1074,6008,7034,7036,2004)},
        @{Log="Application"; IDs=@(1000,1001,1002,1026,20)},
        @{Log="Security"; IDs=@(4625,4648,4720,4732,4756,4723,4724)}
    )
    
    foreach ($e in $criticalEvents) {
        try {
            Get-WinEvent -ComputerName $ComputerName -FilterHashtable @{
                LogName=$e.Log; Id=$e.IDs; StartTime=$start
            } -ErrorAction SilentlyContinue |
            Select-Object TimeCreated, LogName, Id, LevelDisplayName, Message |
            Where-Object { $_.LevelDisplayName -in @("Critical","Error","Warning") }
        } catch {}
    }
}
Get-CriticalEvents -ComputerName "[NOM_SERVEUR]" -HoursBack 24 | Format-Table -Wrap
```

---

## SECTION 8 — ARCHITECTURE REVIEW N3

### Points à vérifier lors d'une architecture review
```
IDENTITÉ ET ACCÈS :
[ ] Active Directory : DCs dans chaque site, FSMO sur DCs stables
[ ] Comptes admin dédiés (pas les comptes utilisateurs pour l'admin)
[ ] MFA activé pour tous les accès distants et admin
[ ] Politique de mot de passe AD (longueur 14+, pas d'expiration si MFA)
[ ] LAPS déployé sur tous les postes/serveurs
[ ] Entra Connect configuré et synchronisé

RÉSEAU :
[ ] Segmentation réseau (VLAN serveurs, VLAN postes, VLAN invités)
[ ] Firewall entre segments critiques
[ ] Pas de RDP exposé directement sur Internet
[ ] VPN avec MFA pour accès remote
[ ] NTP synchronisé depuis source fiable

VIRTUALISATION :
[ ] Au moins 2 hôtes Hyper-V (HA) pour les charges critiques
[ ] Stockage sur NAS/SAN (pas disque local)
[ ] Snapshots automatiques désactivés en production (sauf pré-maintenance)
[ ] Hyperviseur patché (mensuel minimum)

BACKUP :
[ ] Règle 3-2-1 respectée (3 copies, 2 supports, 1 hors-site)
[ ] Backup testé (SureBackup ou test manuel mensuel)
[ ] RTO/RPO documentés et testés
[ ] Backup M365 actif (KeepIT ou équivalent)

SÉCURITÉ :
[ ] Antivirus EDR sur tous les serveurs et postes
[ ] Windows Defender activé même avec AV tiers
[ ] Legacy auth bloqué (M365)
[ ] Conditional Access policies actives
[ ] Audit logs activés et conservés > 90 jours

MONITORING :
[ ] RMM avec alertes sur services critiques
[ ] Alertes disque, CPU, RAM, backup
[ ] Event log critique surveillé
```

---

## SECTION 9 — RUNBOOKS HÉRITÉS V1 (enrichis)

### /runbook ad — Active Directory (hérité V1)
```powershell
# GESTION UTILISATEURS AD
# Créer un compte :
New-ADUser -Name "Prénom Nom" -SamAccountName "prenom.nom" -UserPrincipalName "prenom.nom@[DOMAINE].com" `
    -Path "OU=Utilisateurs,DC=[DOMAINE],DC=local" -Enabled $true `
    -AccountPassword (Read-Host -AsSecureString) -ChangePasswordAtLogon $true

# Désactiver + déplacer vers OU désactivés :
Disable-ADAccount -Identity "prenom.nom"
Move-ADObject -Identity (Get-ADUser "prenom.nom").DistinguishedName -TargetPath "OU=Comptes_Desactives,DC=[DOMAINE],DC=local"

# Réinitialiser MDP (vérifier identité AVANT) :
Set-ADAccountPassword "prenom.nom" -Reset -NewPassword (Read-Host -AsSecureString)
Set-ADUser "prenom.nom" -ChangePasswordAtLogon $true
Unlock-ADAccount "prenom.nom"

# Groupes d'un utilisateur :
(Get-ADUser "prenom.nom" -Properties MemberOf).MemberOf | ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object

# Escalade : SOC si compromission compte admin | NOC si problème réplication | INFRA si modification GPO
```

### /runbook rds — RDS / RemoteApp (hérité V1)
```powershell
# HEALTH CHECK RDS
Get-Service TermService,SessionEnv,UmRdpService | Select-Object Name,Status | Format-Table
query session
query user

# UTILISATEUR NE PEUT PAS SE CONNECTER
# "Access denied"          → Vérifier groupe "Remote Desktop Users" dans AD
# "Connection was denied"  → Vérifier GPO "Allow log on through RDS"
# "Remote computer not found" → Vérifier DNS + connectivité + RD Gateway

# SESSIONS FANTÔMES
query session /server:[NOM_HOST]   # identifier les sessions "Disc"
Reset-Session [ID] /server:[NOM_HOST]
# ⛔ NE PAS déconnecter la session Console (ID 0)

# REBOOT SESSION HOST
Set-RDSessionHost -SessionHost "[NOM.domaine.com]" -NewConnectionAllowed No -ConnectionBroker "[BROKER.domaine.com]"
# → Attendre fin des sessions → reboot → réactiver : -NewConnectionAllowed Yes
```

### /runbook veeam — Veeam Backup (hérité V1)
```
VÉRIFICATION MATINALE
VBR Console → Home → Last 24 Hours
✅ Success | ⚠️ Warning → lire détail | ❌ Failed → intervention

ERREURS FRÉQUENTES
"Unable to connect"    → Service VeeamGuestHelper sur la VM cible
"Snapshot not found"   → vSphere → supprimer snapshots orphelins
"Insufficient space"   → purge restore points anciens
"Access denied"        → droits compte service VEEAM
"VSS snapshot failed"  → vssadmin list writers sur la VM cible
"Network error"        → Test-NetConnection vers cible port 445 + 6160

RESTAURATION FICHIER
VBR → Backups → VM → Restore guest files → Windows
→ Point de restauration → Copy to (emplacement alternatif)
⛔ NE PAS restaurer à l'emplacement original sans confirmation client
```

### /runbook onedrive — OneDrive / SharePoint Sync (hérité V1)
```powershell
# RÉINITIALISER ONEDRIVE
Get-Process "OneDrive" | Stop-Process -Force
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset
# → Attendre 2 min → OneDrive se relance automatiquement

# CARACTÈRES INTERDITS DANS LES NOMS
# " * : < > ? / \ |  ← renommer le fichier
# Noms réservés : CON, PRN, AUX, NUL, COM1-9, LPT1-9 ← renommer

# SHAREPOINT ACCÈS REFUSÉ
# → Vérifier groupe SharePoint (Membres / Visiteurs / Propriétaires)
# → NE PAS briser l'héritage des permissions sur les sous-dossiers
```

---

## SECTION 10 — TEMPLATES DE FERMETURE DE BILLET (hérité V1)

### Bloc escalade NOC (dans CW avant transfert)
```
[TRANSFERT → DÉPARTEMENT NOC]
Billet : #[XXXXXX] | Priorité : P[1/2] | [YYYY-MM-DD HH:MM]
Symptôme : [Description précise]
Impact : [Utilisateurs affectés / Services impactés]
Actions N2/N3 tentées :
  1. [Action — résultat]
  2. [Action — résultat]
Assets : [Liste]
```

### Bloc escalade SOC
```
[TRANSFERT → DÉPARTEMENT SOC]
Billet : #[XXXXXX] | Priorité : P[1/2] | [YYYY-MM-DD HH:MM]
Type : ☐ Phishing  ☐ Compromission  ☐ Ransomware  ☐ Autre
Compte affecté : [voir Passportal]
Actions effectuées :
  ☐ Compte désactivé  ☐ Sessions révoquées  ☐ Règles Outlook vérifiées
```

### Note Interne N3 — Intervention complexe
```
Prise en connaissance de la demande et consultation de la documentation du client.

## INTERVENTION N3 — [TYPE]
Billet : #[XXXXXX] | Client : [NOM] | Priorité : P[X]

## Diagnostic avancé
Outils utilisés : [WinDbg / perfmon / repadmin / dcdiag / autre]
Observations :
- [Observation 1]
- [Observation 2]
- [Log/Event pertinent]

## Cause identifiée
[Cause technique précise]

## Solution appliquée
[Description technique complète de la résolution]

## Tests de validation
- [Test 1 — résultat]
- [Test 2 — résultat]

## Recommandations architecture
- [Recommandation pour éviter la récurrence]
- [Amélioration à planifier]

## Durée : [HH:MM]
```

---

## SECTION 11 — CHECKLIST INTERVENTION N3

```
KICKOFF    : Lire billet CW → Consulter Hudu → Confirmer fenêtre + approbations
PRECHECK   : Ping/RMM → CPU/RAM/Disk → Services → Pending Reboot → Event Logs → Backup
INTERVENTION : 1 action à la fois → documenter au fil de l'eau → [À CONFIRMER] si pas de preuve
POSTCHECK  : Services OK → App fonctionnelle → Event Logs → Monitoring vert → Snapshot supprimé
CLOSEOUT   : CW Note Interne → CW Discussion client-safe → Email si requis → Mode maintenance OFF
```

---

## SECTION 12 — ESCALADES

| Situation | Destination | Délai |
|---|---|---|
| P1 automatique (DC down, réseau site, ransomware) | IT-Commandare-NOC | Immédiat |
| P2→P1 dégradation | IT-Commandare-NOC ou TECH | Dans l'heure |
| Compte compromis (règles Outlook, transferts) | SOC | Immédiat |
| Backup job critique en échec > 24h | IT-BackupDRMaster | Dans l'heure |
| Problème réseau site | IT-NetworkMaster | 30 min |
| FSMO à transférer (seize) | INFRA + Approbation superviseur | Avant action |
| Cluster instable | INFRA + Chef d'équipe | Dans l'heure |
| Architecture review — changements majeurs | Chef d'équipe + Client | Planifié |

---

*BUNDLE_KP_Assistant-N3_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
