# BUNDLE_RUNBOOKS_IT_INFRA
**Bundle Runbooks — IT MSP Intelligence Platform**
**Catégorie :** Infrastructure — Serveurs, DC, SQL, Patching, Post-panne
**Agents consommateurs :** @IT-MaintenanceMaster | @IT-Assistant-N3 | @IT-Commandare-Infra | @IT-UrgenceMaster
**Version :** 1.0 | **Date :** 2026-04-04
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Repo GitHub :** `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_INFRA.md`

> Ce bundle regroupe tous les runbooks de la catégorie **Infrastructure — Serveurs, DC, SQL, Patching, Post-panne**.
> Uploader en Knowledge dans les GPT agents indiqués.
> Les runbooks sont à jour — source canonique dans GitHub.

---

## RB-INFRA-001 — Windows Server Patching

# RUNBOOK - Windows Server Patching

## Pré-patching (T-7 jours)

### 1. Inventaire et planification
- [ ] Identifier serveurs à patcher (par criticité)
- [ ] Vérifier change calendrier (blackout windows)
- [ ] Notifier stakeholders (maintenance window)
- [ ] Backup validation récente

### 2. Pre-checks automatisés
```powershell
# Script pre-patch validation
$Servers = @("SRV01", "SRV02", "SRV03")

foreach ($Server in $Servers) {
    Write-Host "=== Validation $Server ==="
    
    # 1. Disk space (minimum 10GB libre)
    $Disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='C:'"
    $FreeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
    Write-Host "Espace libre C: $FreeGB GB" -ForegroundColor $(if($FreeGB -gt 10){'Green'}else{'Red'})
    
    # 2. Pending reboot check
    $PendingReboot = Invoke-Command -ComputerName $Server -ScriptBlock {
        Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    }
    Write-Host "Reboot pending: $PendingReboot" -ForegroundColor $(if(!$PendingReboot){'Green'}else{'Yellow'})
    
    # 3. Windows Update service
    $WUService = Get-Service -ComputerName $Server -Name wuauserv
    Write-Host "WU Service: $($WUService.Status)" -ForegroundColor $(if($WUService.Status -eq 'Running'){'Green'}else{'Yellow'})
    
    # 4. Last successful backup
    try {
        $LastBackup = Get-WBSummary -ComputerName $Server | Select -ExpandProperty LastSuccessfulBackupTime
        $DaysSince = (Get-Date) - $LastBackup
        Write-Host "Last backup: $($DaysSince.Days) days ago" -ForegroundColor $(if($DaysSince.Days -le 1){'Green'}else{'Yellow'})
    } catch {
        Write-Host "Backup info unavailable" -ForegroundColor Red
    }
    
    Write-Host ""
}
```

## Maintenance Window (Jour J)

### Phase 1: Snapshot/Backup (T-30min)
```powershell
# Azure VMs: Create snapshot
$VM = Get-AzVM -ResourceGroupName "RG-PROD" -Name "SRV01"
$Disk = Get-AzDisk -ResourceGroupName $VM.ResourceGroupName -DiskName $VM.StorageProfile.OsDisk.Name

$SnapshotConfig = New-AzSnapshotConfig `
    -SourceUri $Disk.Id `
    -CreateOption Copy `
    -Location $VM.Location

$SnapshotName = "$($VM.Name)-snapshot-$(Get-Date -Format yyyyMMddHHmm)"
New-AzSnapshot -Snapshot $SnapshotConfig -SnapshotName $SnapshotName -ResourceGroupName $VM.ResourceGroupName

Write-Host "Snapshot créé: $SnapshotName" -ForegroundColor Green
```

### Phase 2: Installation patches

**Option A: WSUS (recommandé pour domaines)**
```powershell
# Approuver patches dans WSUS
$WSUS = Get-WsusServer -Name "WSUS01" -PortNumber 8530
$TargetGroup = $WSUS.GetComputerTargetGroups() | Where-Object {$_.Name -eq "Production Servers"}

# Approuver tous les patches critiques
$Updates = $WSUS.GetUpdates() | Where-Object {
    $_.UpdateClassificationTitle -eq "Critical Updates" -and
    $_.IsApproved -eq $false -and
    $_.CreationDate -gt (Get-Date).AddDays(-30)
}

foreach ($Update in $Updates) {
    $Update.Approve("Install", $TargetGroup)
    Write-Host "Approved: $($Update.Title)"
}

# Forcer detection sur serveurs cibles
Invoke-Command -ComputerName $Servers -ScriptBlock {
    wuauclt /detectnow /reportnow
}
```

**Option B: PSWindowsUpdate (direct download)**
```powershell
# Installer module si nécessaire
Install-Module -Name PSWindowsUpdate -Force

# Installer patches critiques et de sécurité
foreach ($Server in $Servers) {
    Write-Host "=== Patching $Server ===" -ForegroundColor Cyan
    
    Invoke-Command -ComputerName $Server -ScriptBlock {
        Import-Module PSWindowsUpdate
        
        # Download et install
        Get-WindowsUpdate -AcceptAll -Install -Category 'Critical Updates','Security Updates' -AutoReboot:$false -Verbose
    }
}
```

### Phase 3: Reboot orchestration
```powershell
# Reboot séquentiel (attendre que chaque serveur revienne avant le suivant)
foreach ($Server in $Servers) {
    Write-Host "Reboot $Server..." -ForegroundColor Yellow
    
    # Reboot
    Restart-Computer -ComputerName $Server -Force -Wait -For PowerShell -Timeout 600
    
    Write-Host "$Server is back online" -ForegroundColor Green
    
    # Wait 2 minutes pour services
    Start-Sleep -Seconds 120
    
    # Validation post-reboot
    Invoke-Command -ComputerName $Server -ScriptBlock {
        # Check critical services
        $CriticalServices = @('W32Time', 'Dnscache', 'Netlogon')
        foreach ($Svc in $CriticalServices) {
            $Status = (Get-Service -Name $Svc).Status
            if ($Status -ne 'Running') {
                Write-Warning "$Svc is $Status"
            }
        }
        
        # Check pending reboot
        $PendingReboot = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
        if ($PendingReboot) {
            Write-Warning "Additional reboot may be required"
        }
    }
}
```

## Post-patching validation

### 1. Services validation
```powershell
$CriticalServices = @(
    'W32Time',      # Time sync
    'Dnscache',     # DNS
    'Netlogon',     # Domain auth
    'Server',       # File sharing
    'Workstation',  # Network
    'MSSQLSERVER',  # SQL (si applicable)
    'W3SVC'         # IIS (si applicable)
)

foreach ($Server in $Servers) {
    Write-Host "=== $Server Services ===" -ForegroundColor Cyan
    
    Invoke-Command -ComputerName $Server -ScriptBlock {
        param($Services)
        foreach ($Svc in $Services) {
            try {
                $Status = (Get-Service -Name $Svc -ErrorAction SilentlyContinue).Status
                $Color = if($Status -eq 'Running'){'Green'}else{'Red'}
                Write-Host "$Svc : $Status" -ForegroundColor $Color
            } catch {
                Write-Host "$Svc : Not installed" -ForegroundColor Gray
            }
        }
    } -ArgumentList (,$CriticalServices)
}
```

### 2. Event Log review
```powershell
foreach ($Server in $Servers) {
    Write-Host "=== $Server Recent Errors ===" -ForegroundColor Cyan
    
    # System errors in last hour
    $Errors = Get-EventLog -ComputerName $Server -LogName System -EntryType Error -After (Get-Date).AddHours(-1) -ErrorAction SilentlyContinue
    
    if ($Errors) {
        $Errors | Select TimeGenerated, Source, EventID, Message | Format-Table -AutoSize
    } else {
        Write-Host "No errors found" -ForegroundColor Green
    }
}
```

### 3. Patch compliance
```powershell
foreach ($Server in $Servers) {
    Write-Host "=== $Server Patch Status ===" -ForegroundColor Cyan
    
    $Session = New-PSSession -ComputerName $Server
    Invoke-Command -Session $Session -ScriptBlock {
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        
        # Rechercher patches manquants
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        Write-Host "Patches manquants: $($SearchResult.Updates.Count)" -ForegroundColor $(if($SearchResult.Updates.Count -eq 0){'Green'}else{'Yellow'})
        
        if ($SearchResult.Updates.Count -gt 0) {
            $SearchResult.Updates | Select Title, IsDownloaded | Format-Table -AutoSize
        }
    }
    Remove-PSSession $Session
}
```

### 4. Application smoke tests
```powershell
# Exemple: Test web application
foreach ($Server in @("WEB01", "WEB02")) {
    $URL = "https://$Server/healthcheck"
    
    try {
        $Response = Invoke-WebRequest -Uri $URL -UseBasicParsing -TimeoutSec 10
        if ($Response.StatusCode -eq 200) {
            Write-Host "$Server web app: OK" -ForegroundColor Green
        } else {
            Write-Host "$Server web app: Status $($Response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "$Server web app: FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Exemple: Test SQL connection
foreach ($Server in @("SQL01", "SQL02")) {
    try {
        $Connection = New-Object System.Data.SqlClient.SqlConnection
        $Connection.ConnectionString = "Server=$Server;Database=master;Integrated Security=True;Connection Timeout=5"
        $Connection.Open()
        Write-Host "$Server SQL: OK" -ForegroundColor Green
        $Connection.Close()
    } catch {
        Write-Host "$Server SQL: FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}
```

## Rollback procedure

### Si problème détecté post-patching

**Azure VM: Restore depuis snapshot**
```powershell
$SnapshotName = "SRV01-snapshot-202401151430"
$Snapshot = Get-AzSnapshot -SnapshotName $SnapshotName -ResourceGroupName "RG-PROD"

# Stop VM
Stop-AzVM -ResourceGroupName "RG-PROD" -Name "SRV01" -Force

# Swap OS disk
$VM = Get-AzVM -ResourceGroupName "RG-PROD" -Name "SRV01"
$DiskConfig = New-AzDiskConfig -Location $VM.Location -CreateOption Copy -SourceResourceId $Snapshot.Id
$NewDisk = New-AzDisk -Disk $DiskConfig -ResourceGroupName "RG-PROD" -DiskName "SRV01-rollback-osdisk"

Set-AzVMOSDisk -VM $VM -ManagedDiskId $NewDisk.Id -Name $NewDisk.Name
Update-AzVM -ResourceGroupName "RG-PROD" -VM $VM

# Start VM
Start-AzVM -ResourceGroupName "RG-PROD" -Name "SRV01"
```

**On-prem: Restore depuis backup**
1. Boot sur Windows Recovery
2. Restore System State depuis dernier backup
3. Ou full BMR si nécessaire

**Uninstall specific patch** (dernier recours)
```powershell
# Lister patches installés récemment
Get-HotFix -ComputerName "SRV01" | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-1)} | Format-Table -AutoSize

# Uninstall patch spécifique
wusa /uninstall /kb:5034441 /quiet /norestart
```

## Reporting

### Patch compliance report
```powershell
$Report = foreach ($Server in $Servers) {
    $Session = New-PSSession -ComputerName $Server
    
    $Result = Invoke-Command -Session $Session -ScriptBlock {
        # Get installed patches
        $Patches = Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-30)}
        
        # Check for missing patches
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        [PSCustomObject]@{
            Server = $env:COMPUTERNAME
            PatchesInstalled = $Patches.Count
            PatchesMissing = $SearchResult.Updates.Count
            LastPatchDate = ($Patches | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn
            CompliantStatus = if($SearchResult.Updates.Count -eq 0){'Compliant'}else{'Non-Compliant'}
        }
    }
    
    Remove-PSSession $Session
    $Result
}

$Report | Format-Table -AutoSize
$Report | Export-Csv "PatchReport-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
```

### Email notification
```powershell
$Body = @"
<h2>Patching Summary - $(Get-Date -Format "yyyy-MM-dd")</h2>
<h3>Servers Patched</h3>
<table border='1'>
<tr><th>Server</th><th>Patches Installed</th><th>Status</th></tr>
"@

foreach ($Item in $Report) {
    $StatusColor = if($Item.CompliantStatus -eq 'Compliant'){'green'}else{'red'}
    $Body += "<tr><td>$($Item.Server)</td><td>$($Item.PatchesInstalled)</td><td style='color:$StatusColor'>$($Item.CompliantStatus)</td></tr>"
}

$Body += "</table>"

Send-MailMessage `
    -From "noreply@company.com" `
    -To "it-team@company.com" `
    -Subject "Patching Report - $(Get-Date -Format 'yyyy-MM-dd')" `
    -Body $Body `
    -BodyAsHtml `
    -SmtpServer "smtp.company.com"
```

## Best Practices

### Scheduling
- **Production:** 2e dimanche du mois, 2h-6h
- **Dev/Test:** 1er mercredi du mois, 20h-22h
- **Éviter:** Fin de trimestre, lancement produit, période des Fêtes

### Staggering
- **Tier 1:** Dev/Test servers
- **Tier 2:** Non-critical production (wait 24h)
- **Tier 3:** Critical production (wait 48h)

### Testing
- Toujours tester patches en DEV avant PROD
- Minimum 48h observation en DEV
- Application smoke tests automatisés

### Backup verification
- Valider backup succès < 24h
- Test restore mensuel
- Snapshots pré-patch (Azure VMs)

### Change management
- CAB approval pour production
- Rollback plan documenté
- Stakeholder notification 48h avant

### Monitoring
- Alert si services critical down post-reboot
- Performance baseline comparison
- Event log monitoring (System/Application errors)


---

## RB-INFRA-002 — Pending Reboot — Validation + Reboot contrôlé

# RUNBOOK — Pending Reboot (Windows) — Validation + reboot 1 serveur à la fois

## Objectif
- Confirmer **pourquoi** le pending reboot est levé (CBS/WU/PendingFileRename/CCM).
- Appliquer un reboot **contrôlé** (si approuvé) et **re-valider**.

## PRECHECK — identifie la source
```powershell
"=== Pending reboot flags ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== Last boot ==="; (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
"=== Sessions (RDS) ==="; query user
"=== Disks ==="; Get-PSDrive -PSProvider FileSystem | Select Name,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | ft -Auto
```

## Décision
- Si **prod/critique** : valider fenêtre + dépendances + approbation.
- Si DC : exécuter le runbook DC avant et après.

## REBOOT (manuel)
> Faire **uniquement** après approbation.

```powershell
# Option 1: depuis le serveur
Restart-Computer -Force

# Option 2: depuis un poste admin
Restart-Computer -ComputerName "SRV-NAME" -Force
```

## POSTCHECK
Rejouer le PRECHECK + valider les services critiques.

## Si pending reboot reste TRUE
- Noter quel flag reste TRUE.
- Vérifier :
  - Windows Update en attente (re-scan / redémarrage additionnel)
  - Installer/rollback en cours
  - Software distribution corruption
- Escalader si 2 reboots n'éteignent pas le flag **CBS**.



---

## RB-INFRA-003 — Domain Controller — Precheck / Postcheck (AD/DNS)

# RUNBOOK — Domain Controller (AD DS/DNS) — Precheck/Postcheck

## Services critiques
```powershell
Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Format-Table Name,Status,StartType
net share | findstr /I "SYSVOL NETLOGON"
```

## Réplication AD
```powershell
repadmin /replsummary
repadmin /syncall /AdeP
```

## Santé AD (rapide)
```powershell
# dcdiag peut être long; utiliser /q pour erreurs seulement
$OutDir = "$env:TEMP\\DC_CHECK"; New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
dcdiag /q | Out-File (Join-Path $OutDir "dcdiag_q_$TS.txt")
"dcdiag_q saved to $OutDir"
```

## DNS (erreurs récentes)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Rejouer services + replsummary.
- Vérifier que SYSVOL/NETLOGON partagés.
- Confirmer qu'aucun nouvel event critique (Directory Service/System).



---

## RB-INFRA-004 — SQL Server — Precheck / Postcheck

# RUNBOOK — SQL Server — Precheck/Postcheck

## Services
```powershell
Get-Service | Where-Object {$_.Name -match '^MSSQL' -or $_.Name -match '^SQL'} | Sort-Object Name | Format-Table Name,Status,StartType
```

## Connectivité (local)
> Option A : `Invoke-Sqlcmd` si module dispo.

```powershell
if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
  Invoke-Sqlcmd -Query "SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version" | Format-Table -Auto
} else {
  "Invoke-Sqlcmd indisponible — fallback .NET"
  $cn = New-Object System.Data.SqlClient.SqlConnection
  $cn.ConnectionString = "Server=localhost;Database=master;Integrated Security=True;Connection Timeout=5"
  $cn.Open();
  $cmd = $cn.CreateCommand();
  $cmd.CommandText = "SELECT @@SERVERNAME AS ServerName";
  $r = $cmd.ExecuteScalar();
  $cn.Close();
  "ServerName=$r"
}
```

## Journaux Windows (SQL-related)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} |
  Where-Object { $_.LevelDisplayName -in 'Error','Critical' -and ($_.ProviderName -match 'MSSQL|SQLSERVERAGENT|SQL' -or $_.Message -match 'SQL') } |
  Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Services MSSQL/Agent running.
- Test SELECT OK.
- Vérifier EventLog 1h post.

## Note opérationnelle
- Certains environnements (CU/patch) peuvent nécessiter **2 reboots**. Documenter la raison (pending reboot flags).



---

## RB-INFRA-005 — Print Server — Precheck / Postcheck

# RUNBOOK — Print Server — Precheck/Postcheck

## Spooler + queues
```powershell
Get-Service Spooler | Format-Table Name,Status,StartType

# Requiert module PrintManagement sur serveur / RSAT
try {
  Get-Printer | Select-Object Name,Shared,PrinterStatus | Sort-Object Name | Format-Table -Auto
} catch {
  "Get-Printer indisponible (module PrintManagement manquant)."
}
```

## Event logs PrintService
```powershell
$Start=(Get-Date).AddHours(-6)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PrintService/Operational'; StartTime=$Start} |
  Where-Object {$_.LevelDisplayName -in 'Error','Critical','Warning'} |
  Select-Object -First 50 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Spooler running.
- Queues visibles.
- Si imprimante intermittente : valider connectivité (ping) + cycle power (débrancher/rebrancher) si requis.



---

## RB-INFRA-006 — Post-Shutdown Électrique — Reprise infrastructure

# RUNBOOK — Post-Shutdown Électrique (reprise infra) — NOC/MSP

## Objectif
Assurer une reprise **stable** après retour du courant : réseau → stockage → virtualisation → services critiques → monitoring → rapport.

## Ordre de validation (priorité)
1) **Énergie/UPS/PDU** (événements power, batterie)
2) **Réseau** (FW/ISP/VPN/DNS/DHCP/NTP)
3) **Stockage** (SAN/NAS/RAID/SMART)
4) **Virtualisation** (vCenter/hosts/datastores)
5) **Services** (AD/DNS → SQL/IIS/File/RDS → apps)
6) **Backups** (dernier job + pas d'échec post-reprise)
7) **Monitoring** (alertes, ack, retour au vert)

## 1) UPS / Power events
- Vérifier logs UPS (power fail/restore, batteries faibles).
- Si UPS faible : noter le risque + recommander remplacement.

## 2) Réseau baseline (read-only)
```powershell
"=== DNS / Gateway quick checks ==="
ipconfig /all
nslookup google.com
route print | findstr /I "0.0.0.0"

"=== Time sync ==="
w32tm /query /status
w32tm /query /source
```

## 3) Stockage
- Sur SAN/NAS : état contrôleurs, disques, volumes, iSCSI, alertes.
- Vérifier que les datastores sont montés **avant** vCenter/ESXi dépendants.

## 4) Virtualisation (VMware vSphere)
- **Ordre recommandé** : SAN/NAS → ESXi hosts → vCenter.
- Si vCenter est parti avant le SAN :
  - redémarrer vCenter **après** confirmation datastores.
  - au besoin redémarrer les hosts ESXi (1 à la fois) si incohérences.
- Valider : cluster, hosts connected, datastores OK, VMs up.

## 5) Services critiques Windows (par rôle)
- DC: voir `RUNBOOK__DC_PrePost_Validation.md`
- SQL: voir `RUNBOOK__SQL_PrePost_Validation.md`
- Print: voir `RUNBOOK__PrintServer_PrePost_Validation.md`

## 6) Monitoring
- Lister les alertes apparues depuis le retour du courant.
- Distinguer :
  - alertes transitoires (boot) vs. anomalies persistantes
- Normaliser/ack une fois validé.

## 7) Rapport (CW)
- CW_NOTE_INTERNE : timeline + validations + anomalies + suivis.
- CW_DISCUSSION (STAR) : résultat + actions clés.



---

## RB-INFRA-007 — Déploiement serveur

# RUNBOOK — Déploiement Infrastructure (Serveur / VM / Service)
**ID :** RUNBOOK__Deployment | **Version :** 2.0
**Agent owner :** IT-Commandare-Infra | **Équipe :** TEAM__IT
**Domaine :** INFRA — Déploiement
**Date révision :** 2026-03-13

---

## ⚠️ GARDE-FOUS — OBLIGATOIRES
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement le déploiement lié au billet actif.
Demandes hors déploiement infra → refus et redirection.

**Données sensibles :**
- ❌ Jamais : credentials de déploiement, clés SSH, certificats privés, IPs dans livrables client
- ❌ Dans livrables client : noms de domaine internes, chemins de configuration
- Remplacer par `[CONFIG MASQUÉE]` dans outputs client-safe

**Actions destructrices :**
- Avant déploiement PROD → `⚠️ Impact : modification de l'environnement de production` + validation
- Rollback planifié obligatoire documenté avant exécution

---

## 1. Objectif
Standardiser le déploiement de nouveaux serveurs, VMs ou services dans l'environnement client :
- Serveurs Windows Server (physiques ou virtuels)
- VMs Hyper-V ou VMware
- Rôles Windows (AD DS, DNS, DHCP, IIS, RDS, Print)
- Services Cloud (Azure IaaS/PaaS)

---

## 2. Déclencheurs
- Nouveau serveur commandé pour un client
- Migration vers virtualisation
- Ajout d'un rôle sur un serveur existant
- Onboarding client complet (infrastructure initiale)

---

## 3. Phase 1 — Pré-déploiement (T-48h minimum)

### 3.1 Collecte des exigences
```yaml
client         : [nom]
ticket_id      : [CW-XXXXXX]
type_serveur   : [physique / VM / cloud]
os             : [Windows Server 2019 / 2022]
rôles          : [DC / DNS / DHCP / IIS / RDS / Print / File / SQL]
ressources     : [vCPU, RAM, disques — tailles]
réseau         : [VLAN, IPs statiques — [À CONFIRMER]]
domaine        : [workgroup / domaine existant / nouveau domaine]
backup         : [politique backup à créer après déploiement]
fenetre        : [date / horaire approuvé]
```

### 3.2 Pré-checks environnement
```powershell
# Ressources disponibles sur l'hôte Hyper-V (lecture seule)
Get-VM | Select-Object Name, State, @{n='RAM_GB';e={$_.MemoryAssigned/1GB}} | Format-Table -Auto
Get-VMHost | Select-Object Name, @{n='RAM_Dispo_GB';e={[math]::Round($_.MemoryAvailable/1GB,1)}} | Format-Table

# Espace datastore
Get-Volume | Select-Object DriveLetter, FileSystemLabel,
  @{n='Total_GB';e={[math]::Round($_.Size/1GB,1)}},
  @{n='Libre_GB';e={[math]::Round($_.SizeRemaining/1GB,1)}} |
  Format-Table -Auto
```

---

## 4. Phase 2 — Déploiement

### 4.1 Checklist déploiement VM Windows Server

**Création de la VM :**
- [ ] Nom conforme au standard : `[SITE]-SVR-[RÔLE][NUM]` (ex: `CLT-SVR-DC01`)
- [ ] Génération 2 (UEFI) si OS >= 2016
- [ ] vCPU / RAM selon spécifications validées
- [ ] Disque OS : minimum 80 GB | disques données séparés
- [ ] Snapshot pre-déploiement créé : `@[BILLET]_PreDeployment_[SERVEUR]_SNAP_[DATE]`

**Installation OS :**
- [ ] ISO Windows Server (version approuvée)
- [ ] Partition système : 60 GB min | reste sur D:
- [ ] Activation Windows (KMS ou MAK selon client)
- [ ] Windows Update : niveau CU courant appliqué

**Configuration post-installation :**
```powershell
# Renommer le serveur (⚠️ Impact : redémarrage requis)
Rename-Computer -NewName "NOM-SERVEUR" -Force
# Configurer fuseau horaire
Set-TimeZone -Name "Eastern Standard Time"
# Vérifier activation Windows
(Get-WmiObject -Class SoftwareLicensingProduct -Filter "Name like 'Windows%'" |
  Where-Object {$_.LicenseStatus -eq 1}).Name
```

**Jonction au domaine :**
```powershell
# ⚠️ Impact : redémarrage requis — validation obligatoire avant
Add-Computer -DomainName "[DOMAINE]" -Restart
```

### 4.2 Installation des rôles
```powershell
# Exemple : installer le rôle DNS + RSAT
# ⚠️ Impact : redémarrage possible selon la configuration
Install-WindowsFeature -Name DNS -IncludeManagementTools -Restart:$false
Install-WindowsFeature -Name RSAT-DNS-Server
```

### 4.3 Snapshot post-déploiement
```
Nom obligatoire : @[BILLET]_PostDeployment_[SERVEUR]_SNAP_[YYYYMMDD_HHMM]
À créer AVANT de configurer les rôles
```

---

## 5. Phase 3 — Validation post-déploiement

```powershell
# Health check complet (lecture seule)
[pscustomobject]@{
  Hostname    = $env:COMPUTERNAME
  OS          = (Get-CimInstance Win32_OperatingSystem).Caption
  RAM_GB      = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
  Uptime      = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
  Domaine     = (Get-CimInstance Win32_ComputerSystem).Domain
  Activation  = if ((Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" |
                  Where-Object LicenseStatus -eq 1)) {'Activé'} else {'Non activé'}
}
# Disques
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{n='Libre_GB';e={[math]::Round($_.Free/1GB,1)}} | Format-Table
# Services auto non démarrés
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Format-Table Name, Status
```

### Checklist validation finale
- [ ] Serveur joignable depuis les postes clients
- [ ] Nom DNS résolu correctement
- [ ] Jonction domaine confirmée (`whoami /fqdn`)
- [ ] Rôles installés et fonctionnels
- [ ] Backup configuré (ticket séparé si nécessaire)
- [ ] Agent RMM/EDR installé et actif
- [ ] Monitoring configuré dans ConnectWise RMM
- [ ] Documentation CW complète

---

## 6. Livrables CW

### Note interne
```
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Déploiement : [nom serveur — sans IP]
Rôles installés : [liste]
Jonction domaine : [FAIT / [À CONFIRMER]]
Snapshot post-déploiement : [nom snapshot]
Agent RMM/EDR : [FAIT / [À CONFIRMER]]
Backup : [configuré / ticket à créer]
Anomalies : [aucune / détails]
```

### Discussion client (client-safe)
```
- Analyse de la demande et préparation de l'environnement.
- Déploiement du nouveau serveur selon les spécifications convenues.
- Installation des rôles requis et validation du bon fonctionnement.
- Protection et supervision activées.
- Prochaine étape : [formation / configuration applicative / surveillance].
```

---

## 7. Escalade
- Problème jonction domaine persistant → `IT-Commandare-TECH`
- Déploiement Azure / hybride → `IT-CloudMaster`
- Architecture complexe multi-sites → `IT-CTOMaster`


---

## RB-INFRA-008 — Quick Start intervention

# RUNBOOK — Quick Start Cloud / M365 / Azure
**ID :** RUNBOOK__Quick_Start | **Version :** 2.0
**Agent owner :** IT-CloudMaster | **Équipe :** TEAM__IT
**Domaine :** INFRA — Cloud & M365
**Date révision :** 2026-03-13

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
- Configuration hybride complexe (ADFS, Azure AD Connect) → `IT-CTOMaster`


---
