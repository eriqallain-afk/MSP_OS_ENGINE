# BUNDLE RUNBOOK MAINTENANCE Patching-Windows V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-MaintenanceMaster, IT-Assistant-N3 | IT-SysAdmin
**Description :** Patching Windows Server — Planification, exécution, WSUS, reboot
**Mis à jour :** 2026-05-21

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__Windows_Patching -->
## RUNBOOK — Windows Server Patching (Complet)

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
        $Errors | Select TimeGenerated, Source, EventID, Message | Out-String -Width 300 | Write-Output
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
            $SearchResult.Updates | Select Title, IsDownloaded | Out-String -Width 300 | Write-Output
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
Get-HotFix -ComputerName "SRV01" | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-1)} | Out-String -Width 300 | Write-Output

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

$Report | Out-String -Width 300 | Write-Output
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
<!-- SOURCE: RUNBOOK__Windows_Patching_CW_RMM_OneByOne -->
## RUNBOOK — Patching CW RMM — 1 Serveur à la fois

# RUNBOOK — Windows Server Patching (ConnectWise RMM) — 1 serveur à la fois

## Principe (non négociable)
- **Lecture seule → patching → reboot (si requis) → postcheck**.
- **Un seul serveur critique à la fois** (DC/SQL/RDS/ERP).
- **Aucun script** qui redémarre une liste automatiquement.

## Préparation
1) Confirmer fenêtre + scope + ordre (recommandé) :
- SQL → App/Web → Print → File → DC
2) Confirmer backups/replication OK (si applicable).
3) Créer un dossier de preuves par serveur :
```powershell
$BaseOut = "$env:TEMP\\CW_Patching"
New-Item -ItemType Directory -Path $BaseOut -Force | Out-Null
```

## PRECHECK (à exécuter AVANT patching)
> Exécuter sur **le serveur ciblé** (RMM script ou session). Sauver l’output dans un fichier.

```powershell
param([string]$OutDir = "$env:TEMP\\CW_Patching")
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $OutDir "PRECHECK_$TS.log") -Append

"=== HOST ==="; hostname
"=== OS / UPTIME ==="; (Get-CimInstance Win32_OperatingSystem | Select-Object CSName,Caption,Version,LastBootUpTime)

"=== PENDING REBOOT (CBS/WU/FILE RENAME/CCM) ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== DISKS ==="; Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | Out-String -Width 300 | Write-Output

"=== TOP SERVICES (AUTO + NOT RUNNING) ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select-Object Name,Status,StartType | Out-String -Width 300 | Write-Output

"=== EVENTLOG (System/Application) last 2h: Error/Critical ==="
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Out-String -Width 300 | Write-Output
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Out-String -Width 300 | Write-Output

Stop-Transcript
"PRECHECK log: $OutDir"
```

## PATCHING (via ConnectWise RMM)
- Déclencher l’installation des updates (CU + sécurité) via **CW RMM**.
- **Ne pas** redémarrer automatiquement si c’est un serveur critique sans avoir le OK.

## REBOOT (si requis)
1) Confirmer : sessions / dépendances / approbation.
2) Redémarrer **le serveur courant** seulement.

## POSTCHECK (après reboot / après patch)
```powershell
param([string]$OutDir = "$env:TEMP\\CW_Patching")
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $OutDir "POSTCHECK_$TS.log") -Append

"=== HOST ==="; hostname
"=== OS / UPTIME ==="; (Get-CimInstance Win32_OperatingSystem | Select-Object CSName,Caption,Version,LastBootUpTime)

"=== PENDING REBOOT (CBS/WU/FILE RENAME/CCM) ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== DISKS ==="; Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | Out-String -Width 300 | Write-Output

"=== SERVICES (AUTO + NOT RUNNING) ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select-Object Name,Status,StartType | Out-String -Width 300 | Write-Output

"=== EVENTLOG (System/Application) last 1h: Error/Critical ==="
$Start=(Get-Date).AddHours(-1)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Out-String -Width 300 | Write-Output
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Out-String -Width 300 | Write-Output

Stop-Transcript
"POSTCHECK log: $OutDir"
```

## Closeout (ConnectWise)
- Utiliser :
  - `01_TEMPLATES_CW/TEMPLATE__CW_NOTE_INTERNE__TIMELINE.md`
  - `01_TEMPLATES_CW/TEMPLATE__CW_DISCUSSION__STAR.md`



---
<!-- SOURCE: RUNBOOK__WSUS_Maintenance_V1 -->
## RUNBOOK — WSUS Maintenance

[FICHIER NON TROUVÉ : /tmp/NEW_RUNBOOKS/INFRA/RUNBOOK__WSUS_Maintenance_V1.md]

---
<!-- SOURCE: RUNBOOK__PendingReboot_OneByOne -->
## RUNBOOK — Pending Reboot — Validation et Procédure

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
<!-- SOURCE: TEMPLATE_MAINTENANCE_MAJ-CVE-et-Planifiee_V1 -->
## TEMPLATE — Alerte CVE et Briefing Pré-Maintenance

# TEMPLATE_MAINTENANCE_MAJ-CVE-et-Planifiee_V1
**Agent :** IT-MaintenanceMaster, IT-Assistant-N3
**Usage :** Communication interne pour mise à jour CVE urgente + briefing pré-maintenance
**Mis à jour :** 2026-05-21

---

## PARTIE 1 — ALERTE CVE / PATCH URGENCE

```
═══════════════════════════════════════════════
ALERTE PATCH SÉCURITÉ URGENT
Date          : [YYYY-MM-DD]
Rédigé par    : [NOM TECHNICIEN]
Billet CW     : #[XXXXXX]
═══════════════════════════════════════════════

VULNÉRABILITÉ
CVE           : [CVE-YYYY-XXXXX]
CVSS Score    : [X.X] — [Critical / High / Medium]
Produit affecté : [Windows Server / Exchange / etc.]
Versions affectées : [Lister les versions]

DESCRIPTION FONCTIONNELLE
[Ce que la vulnérabilité permet — sans détails exploitables]

PATCH DISPONIBLE
Microsoft KB  : [KB XXXXXXX]
Source        : [URL Microsoft Security Update Guide]
Date de sortie : [Date]

CLIENTS AFFECTÉS (à vérifier dans CW/CMDB)
→ [Client 1] — [Versions détectées via RMM]
→ [Client 2]

PLAN D'ACTION
Priorité      : [Immédiat / Dans les 48h / Cycle normal]
Fenêtre requise : [Oui — après heures / Non — peut s'appliquer en production]
Rollback possible : [Oui (snapshot requis) / Non]

ACTIONS
[ ] Snapshot VMs critiques avant application
[ ] Appliquer via CW RMM / WSUS / Windows Update
[ ] Valider post-patch (Event Viewer + services)
[ ] Mettre à jour CMDB (date dernier patch)
[ ] Documenter dans CW avec résultats
═══════════════════════════════════════════════
```

---

## PARTIE 2 — BRIEFING PRÉ-MAINTENANCE (Équipe IT)

```
═══════════════════════════════════════════════
BRIEFING PRÉ-MAINTENANCE
Date/Heure    : [YYYY-MM-DD HH:MM]–[HH:MM]
Client        : [NOM]
Owner         : @[Technicien assigné]
Backup        : @[Technicien backup]
Billet CW     : #[XXXXXX]
Procédure     : [lien runbook ou playbook]
═══════════════════════════════════════════════

SCOPE
Serveurs/équipements : [Liste — sans IPs]
Ordre d'intervention : [Non-critiques → critiques]
Approbation reboots  : ☐ Reçue / ☐ À confirmer

POINTS D'ATTENTION
→ [Risque 1 — ex: SRV-SQL01 = serveur de production actif]
→ [Risque 2 — ex: Pas de DC secondaire]

PRÉREQUIS VALIDÉS
[ ] Backup/snapshot < 24h confirmé pour serveurs critiques
[ ] Fenêtre de maintenance approuvée par client
[ ] Accès admin validé (RDP/RMM)
[ ] NOC alerté — monitoring renforcé pendant la fenêtre
[ ] Plan de rollback documenté

COMMUNICATION
Début : Annonce Teams au canal [NOM CANAL]
Fin   : Email rapport client dans les [2h] post-maintenance
═══════════════════════════════════════════════
```


---
<!-- SOURCE: TEMPLATE_COM_Teams-Maintenance_V1 -->
## TEMPLATE — Communications Teams Maintenance

# TEMPLATE_COM_Teams-Maintenance_V1
**Agent :** IT-TicketScribe, IT-MaintenanceMaster
**Usage :** Annonces Teams — début, fin et incident pendant maintenance
**Mis à jour :** 2026-05-21

---

## ANNONCE DÉBUT DE MAINTENANCE

```
🔧 MAINTENANCE EN COURS
📅 [DATE] | ⏰ [HH:MM] – [HH:MM] (estimé)
📋 [Description courte — ex: Application des mises à jour Windows]

⚠️ Impact : [Service(s) temporairement indisponibles ou ralentis]
Toute interruption sera communiquée ici.

Merci de votre compréhension. 🙏
```

---

## ANNONCE FIN DE MAINTENANCE — SUCCÈS

```
✅ MAINTENANCE TERMINÉE
📅 [DATE] | ⏰ [HH:MM]
✔️ Mises à jour appliquées avec succès
✔️ Tous les services sont opérationnels

En cas d'anomalie, contactez le support : [info contact]
```

---

## ANNONCE FIN DE MAINTENANCE — AVEC SUIVI

```
⚠️ MAINTENANCE TERMINÉE — Suivi requis
📅 [DATE] | ⏰ [HH:MM]
✔️ [Services X, Y] : opérationnels
⏳ [Service Z] : [état actuel / action en cours]

Notre équipe surveille activement la situation.
Prochain point de communication : [HH:MM]
```

---

## ANNONCE INCIDENT PENDANT MAINTENANCE

```
🚨 INCIDENT DÉTECTÉ — MAINTENANCE [DATE]
⚠️ [Service X] : temporairement indisponible

Notre équipe technique traite la situation.
ETA retour à la normale : [heure estimée ou "sous X heures"]
Prochain point de communication : [HH:MM]
```

---

## RÉSOLUTION D'INCIDENT POST-MAINTENANCE

```
✅ RETOUR À LA NORMALE — [DATE] [HH:MM]
🔧 [Service X] : pleinement opérationnel depuis [HH:MM]
📋 Rapport détaillé disponible sur demande

Nous nous excusons pour la gêne occasionnée.
```


---
<!-- SOURCE: TEMPLATE_COM_Email-Interruption-Planifiee_V1 -->
## TEMPLATE — Email Interruption Planifiée

# TEMPLATE_COM_Email-Interruption-Planifiee_V1
**Agent :** IT-TicketScribe, IT-MaintenanceMaster
**Usage :** Email client — notification de fenêtre de maintenance planifiée (J-48h)
**Mis à jour :** 2026-05-21

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
<!-- SOURCE: CHECKLIST_MAINTENANCE_Pre-Maintenance_V1 -->
## CHECKLIST — Pré-Maintenance

# CHECKLIST_MAINTENANCE_Pre-Maintenance_V1
**Agent :** IT-MaintenanceMaster, IT-Assistant-N3
**Usage :** Avant toute maintenance planifiée (patching, redémarrage, déploiement)
**Mis à jour :** 2026-05-21

---

## PRÉ-MAINTENANCE — À compléter AVANT de commencer

### Contexte et autorisation
- [ ] Billet CW ouvert : #_______
- [ ] Fenêtre de maintenance confirmée : _______ à _______ (heure locale)
- [ ] Approbation reboots obtenue : ☐ Oui  ☐ Non requis
- [ ] Client informé (email/Teams J-48h) : ☐ Fait  ☐ Non requis
- [ ] Équipe IT briefée : ☐ Fait  ☐ Solo

### Backup et snapshots
- [ ] Backup récent confirmé (< 24h) pour chaque serveur critique
- [ ] Snapshot créé sur VMs critiques (avec nom conforme : @[Ticket]_Preboot_[VM]_SNAP_[Date])
- [ ] Point de restauration Datto validé (screenshot présent)
- [ ] Dernière restauration testée (mensuel) : ☐ OK  ☐ Non vérifié

### Vérifications système (par serveur)
- [ ] Espace disque > 10% libre sur C: et volumes data
- [ ] Services critiques démarrés et stables
- [ ] Pending reboot = False (ou reboot planifié dans cette fenêtre)
- [ ] Event Log : aucune erreur critique récente non résolue
- [ ] Sessions RDS actives vérifiées (si reboot prévu : utilisateurs avertis)

### Monitoring et accès
- [ ] Mode maintenance activé dans RMM (Datto RMM / N-able / CW RMM)
- [ ] Accès admin validé (RDP / RMM / Console)
- [ ] VPN connecté si intervention à distance
- [ ] Numéro de contact client d'urgence noté : _______

### Ordre d'intervention (pour plusieurs serveurs)
```
Ordre recommandé (critiques en dernier) :
1. Serveurs non-critiques / secondaires
2. Serveurs applicatifs (ERP, web, app)
3. Serveurs SQL / bases de données
4. Serveurs de fichiers
5. RDS / accès distant
6. Domain Controllers (en dernier — un seul à la fois)
```

### GO / NO-GO
- [ ] Toutes les cases ci-dessus validées → **GO**
- [ ] Au moins un item bloquant non résolu → **NO-GO — documenter dans CW et reprogrammer**


---
<!-- SOURCE: CHECKLIST_MAINTENANCE_Precheck-Generic_V1 -->
## CHECKLIST — Precheck Générique Serveur

# CHECKLIST — PRECHECK (Generic Windows Server)

- [ ] Uptime / last boot
- [ ] Pending reboot (CBS/WU/PendingFileRename/CCM)
- [ ] CPU/RAM (si perf incident)
- [ ] Disques (C: + volumes data) — espace libre
- [ ] Services critiques (selon rôle)
- [ ] Sessions (RDS) si reboot prévu
- [ ] Event Logs: System/Application (Errors/Critical sur 1–2h)
- [ ] Backups : dernier job OK (si maintenance)
- [ ] Monitoring: alertes actives vs baseline



---
<!-- SOURCE: CHECKLIST_MAINTENANCE_Postcheck-Generic_V1 -->
## CHECKLIST — Postcheck Générique Serveur

# CHECKLIST — POSTCHECK (Generic Windows Server)

- [ ] Host en ligne (ping/RMM)
- [ ] Services critiques OK
- [ ] Event Logs post-action: Kernel-Power, disk/NTFS, service failures
- [ ] Pending reboot = False (ou expliqué)
- [ ] App/partage/URL test rapide
- [ ] Monitoring back to green / alertes normalisées
- [ ] Backups: pas d'échec post-reprise

