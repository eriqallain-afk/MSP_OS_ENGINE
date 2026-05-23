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
