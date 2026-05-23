<# 
PRECHECK - DC/DNS (Windows Server)
- Host/OS/Uptime/RebootPending
- Ressources (CPU/RAM/Disk)
- Services critiques DC
- AD Replication (repadmin)
- dcdiag /q
- SYSVOL/NETLOGON shares
- Event logs: System, Application, Directory Service, DNS Server, DFS Replication (erreurs/critiques)

Usage (par défaut):
  powershell.exe -ExecutionPolicy Bypass -File .\PRECHECK_DC.ps1

Optionnel:
  .\PRECHECK_DC.ps1 -HoursEvents 4 -SkipDcDiag
#>

[CmdletBinding()]
param(
  [int]$HoursEvents = 2,
  [switch]$SkipDcDiag
)

$ErrorActionPreference = 'Continue'

function New-OutDir {
  param([string]$Base = "$env:WINDIR\Temp\CW_Patching")
  $srv = $env:COMPUTERNAME
  $ts  = Get-Date -Format "yyyyMMdd_HHmmss"
  $out = Join-Path $Base "$srv\PRECHECK_$ts"
  New-Item -ItemType Directory -Path $out -Force | Out-Null
  return $out
}

function Get-PendingReboot {
  $CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
  $WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
  $PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
  $CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'
  [pscustomobject]@{
    CBS_RebootPending              = $CBS
    WU_RebootRequired              = $WU
    PendingFileRenameOperations    = $PFR
    CCMClientRebootPending         = $CCM
    PendingReboot                  = ($CBS -or $WU -or $PFR -or $CCM)
  }
}

function Get-Disks {
  Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID, VolumeName,
      @{n='SizeGB';e={[math]::Round($_.Size/1GB,2)}},
      @{n='FreeGB';e={[math]::Round($_.FreeSpace/1GB,2)}},
      @{n='FreePct';e={ if($_.Size){ [math]::Round(($_.FreeSpace/$_.Size)*100,2)} else {0}}}
}

function Get-Resources {
  $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty LoadPercentage
  $os  = Get-CimInstance Win32_OperatingSystem
  $totalGB = [math]::Round($os.TotalVisibleMemorySize/1MB,2)
  $freeGB  = [math]::Round($os.FreePhysicalMemory/1MB,2)
  [pscustomobject]@{
    CpuLoadPct = $cpu
    RamTotalGB = $totalGB
    RamFreeGB  = $freeGB
    RamFreePct = if($totalGB){ [math]::Round(($freeGB/$totalGB)*100,2)} else {0}
  }
}

function Get-RecentEvents {
  param(
    [string]$LogName,
    [int]$HoursBack = 2,
    [int]$Max = 50
  )
  $start = (Get-Date).AddHours(-$HoursBack)
  try {
    Get-WinEvent -FilterHashtable @{LogName=$LogName; StartTime=$start} -ErrorAction Stop |
      Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
      Select-Object -First $Max TimeCreated, Id, LevelDisplayName, ProviderName, Message
  } catch {
    [pscustomobject]@{ TimeCreated=(Get-Date); Id=0; LevelDisplayName="Error"; ProviderName="Get-RecentEvents"; Message="Failed to query $LogName : $($_.Exception.Message)" }
  }
}

function Get-WindowsUpdatePending {
  # Sans module PSWindowsUpdate : utilise COM Microsoft.Update
  try {
    $session  = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $result   = $searcher.Search("IsInstalled=0 and Type='Software'")
    $pending  = @()
    for ($i=0; $i -lt $result.Updates.Count; $i++){
      $u = $result.Updates.Item($i)
      $pending += [pscustomobject]@{
        Title = $u.Title
        RebootRequired = $u.RebootRequired
      }
    }
    [pscustomobject]@{
      PendingCount = $result.Updates.Count
      Updates      = $pending | Select-Object -First 20
    }
  } catch {
    [pscustomobject]@{
      PendingCount = -1
      Updates      = @()
      Error        = $_.Exception.Message
    }
  }
}

# ---------------- MAIN ----------------
$outDir = New-OutDir
$ts     = Get-Date -Format "yyyyMMdd_HHmmss"
$trans  = Join-Path $outDir "PRECHECK_Transcript_$ts.log"
Start-Transcript -Path $trans -Append | Out-Null

Write-Host "Output folder: $outDir"

# Host/OS/Uptime
$os = Get-CimInstance Win32_OperatingSystem
$hostInfo = [pscustomobject]@{
  Hostname       = $env:COMPUTERNAME
  Domain         = $env:USERDNSDOMAIN
  OS             = $os.Caption
  Version        = $os.Version
  LastBootUpTime = $os.LastBootUpTime
  Uptime         = (New-TimeSpan -Start $os.LastBootUpTime -End (Get-Date)).ToString()
}

# Pending reboot
$pendingReboot = Get-PendingReboot

# Ressources
$resources = Get-Resources
$disks     = Get-Disks

# Services critiques DC/DNS
$dcServices = Get-Service NTDS,DNS,Netlogon,KDC,W32Time -ErrorAction SilentlyContinue |
  Select-Object Name, Status, StartType

# SYSVOL/NETLOGON shares
$shares = (cmd.exe /c 'net share') 2>&1

# AD Replication
$repSummaryPath = Join-Path $outDir "repadmin_replsummary_$ts.txt"
$showReplPath   = Join-Path $outDir "repadmin_showrepl_$ts.txt"
(cmd.exe /c 'repadmin /replsummary') 2>&1 | Out-File -FilePath $repSummaryPath -Encoding UTF8
(cmd.exe /c 'repadmin /showrepl * /csv') 2>&1 | Out-File -FilePath $showReplPath -Encoding UTF8

# DCDIAG (erreurs only)
$dcdiagPath = Join-Path $outDir "dcdiag_q_$ts.txt"
if (-not $SkipDcDiag) {
  (cmd.exe /c 'dcdiag /q') 2>&1 | Out-File -FilePath $dcdiagPath -Encoding UTF8
} else {
  "SKIPPED (SkipDcDiag)" | Out-File -FilePath $dcdiagPath -Encoding UTF8
}

# Event logs
$events = [ordered]@{
  System          = Get-RecentEvents -LogName 'System' -HoursBack $HoursEvents -Max 50
  Application     = Get-RecentEvents -LogName 'Application' -HoursBack $HoursEvents -Max 50
  DirectoryService= Get-RecentEvents -LogName 'Directory Service' -HoursBack $HoursEvents -Max 50
  DNSServer       = Get-RecentEvents -LogName 'DNS Server' -HoursBack $HoursEvents -Max 50
  DFSReplication  = Get-RecentEvents -LogName 'DFS Replication' -HoursBack $HoursEvents -Max 50
}

# Windows Updates (pending)
$wuPending = Get-WindowsUpdatePending

# Build Summary
$summary = [pscustomobject]@{
  Timestamp      = (Get-Date).ToString("s")
  OutDir         = $outDir
  HostInfo       = $hostInfo
  PendingReboot  = $pendingReboot
  Resources      = $resources
  Disks          = $disks
  DcServices     = $dcServices
  SharesRaw      = $shares -join "`r`n"
  RepadminFiles  = @{
    ReplSummary = $repSummaryPath
    ShowReplCsv = $showReplPath
  }
  DcdiagFile     = $dcdiagPath
  Events         = $events
  WindowsUpdate  = $wuPending
}

# Save summary
$summaryPath = Join-Path $outDir "PRECHECK_Summary_$ts.json"
$summary | ConvertTo-Json -Depth 6 | Out-File -FilePath $summaryPath -Encoding UTF8

# Quick GO/NoGO hints
$diskRed = $disks | Where-Object { $_.FreePct -lt 15 }
$svcBad  = $dcServices | Where-Object { $_.Status -ne 'Running' -and $_.StartType -eq 'Automatic' }

Write-Host "=== QUICK FLAGS ==="
Write-Host ("PendingReboot: " + $pendingReboot.PendingReboot)
Write-Host ("Disk <15% free: " + ($diskRed.Count -gt 0))
Write-Host ("Critical DC services not running: " + ($svcBad.Count -gt 0))
Write-Host ("WU PendingCount: " + $wuPending.PendingCount)
Write-Host "Summary JSON: $summaryPath"

Stop-Transcript | Out-Null

# Return object for RMM capture
$summary