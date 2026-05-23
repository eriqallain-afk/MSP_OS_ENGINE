<#
PRECHECK - Windows Server (File/Generic + DC auto-detect)
Ticket: #
Servers: %Servername%

Exécution:
  .\PRECHECK_Server.ps1
ou
  .\PRECHECK_Server.ps1 -OutRoot "C:\Temp\CW_PRECHECK" -HoursEvents 4 -TopEvents 60 -FreePctThreshold 15

Notes:
- Read-only (aucune modification)
- Compatible Set-StrictMode (tableaux normalisés + variables initialisées)
#>

[CmdletBinding()]
param(
  [string]$OutRoot = "$env:TEMP\CW_PRECHECK",
  [int]$HoursEvents = 2,
  [int]$TopEvents = 40,
  [int]$FreePctThreshold = 15
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Write-Section([string]$Title) {
  return "`n==================== $Title ====================`n"
}

function Save-Object {
  param(
    [Parameter(Mandatory=$true)]$Obj,
    [Parameter(Mandatory=$true)][string]$PathNoExt
  )
  try {
    $Obj | ConvertTo-Json -Depth 8 | Out-File ($PathNoExt + ".json") -Encoding UTF8
  } catch {
    # Some objects don't serialize well; ignore JSON if needed.
    "JSON export failed: $($_.Exception.Message)" | Out-File ($PathNoExt + ".json_error.txt") -Encoding UTF8
  }
  try {
    $Obj | Out-String -Width 4096 | Out-File ($PathNoExt + ".txt") -Encoding UTF8
  } catch {
    "TXT export failed: $($_.Exception.Message)" | Out-File ($PathNoExt + ".txt_error.txt") -Encoding UTF8
  }
}

function Get-PendingReboot {
  $CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
  $WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
  $PFR = $false
  try {
    $p = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
    $PFR = ($null -ne $p)
  } catch { }
  $CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'

  [pscustomobject]@{
    CBS_RebootPending           = [bool]$CBS
    WU_RebootRequired           = [bool]$WU
    PendingFileRenameOperations = [bool]$PFR
    CCMClientRebootPending      = [bool]$CCM
    PendingReboot               = [bool]($CBS -or $WU -or $PFR -or $CCM)
  }
}

# --- Setup output
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
$HostName = $env:COMPUTERNAME

New-Item -ItemType Directory -Path $OutRoot -Force | Out-Null
$OutDir = Join-Path $OutRoot "$HostName`_$TS"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

$Transcript = Join-Path $OutDir "PRECHECK_TRANSCRIPT_$HostName`_$TS.log"
Start-Transcript -Path $Transcript -Append | Out-Null

try {
  Write-Output (Write-Section "HOST / OS / UPTIME")
  $os = Get-CimInstance Win32_OperatingSystem
  $cs = Get-CimInstance Win32_ComputerSystem
  $uptime = (Get-Date) - $os.LastBootUpTime

  $hostInfo = [pscustomobject]@{
    ComputerName    = $HostName
    Domain          = $cs.Domain
    Manufacturer    = $cs.Manufacturer
    Model           = $cs.Model
    OS              = $os.Caption
    OSVersion       = $os.Version
    OSBuildNumber   = $os.BuildNumber
    LastBootUpTime  = $os.LastBootUpTime
    UptimeDays      = [math]::Round($uptime.TotalDays, 2)
    LoggedOnUser    = $cs.UserName
  }
  $hostInfo | Format-List
  Save-Object $hostInfo (Join-Path $OutDir "01_HostInfo")

  Write-Output (Write-Section "PATCH CONTEXT (last hotfixes)")
  $hotfix = @()
  try {
    $hotfix = @(Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 20 HotFixID, Description, InstalledOn)
  } catch {
    $hotfix = @([pscustomobject]@{ Error = $_.Exception.Message })
  }
  $hotfix | Format-Table -AutoSize
  Save-Object $hotfix (Join-Path $OutDir "01b_Hotfix_Last20")

  Write-Output (Write-Section "RESOURCES (CPU/RAM) + DISKS")
  $cpu = @()
  try {
    $cpu = @(Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed)
  } catch {
    $cpu = @([pscustomobject]@{ Error = $_.Exception.Message })
  }

  $mem = [pscustomobject]@{
    TotalGB = [math]::Round($cs.TotalPhysicalMemory/1GB,2)
    FreeGB  = [math]::Round(($os.FreePhysicalMemory*1KB)/1GB,2)
  }

  $drives = @()
  try {
    $drives = @(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
      Select-Object DeviceID, VolumeName,
        @{n="SizeGB";e={[math]::Round($_.Size/1GB,2)}},
        @{n="FreeGB";e={[math]::Round($_.FreeSpace/1GB,2)}},
        @{n="FreePct";e={ if($_.Size){ [math]::Round(($_.FreeSpace/$_.Size)*100,2) } else { 0 } }})
  } catch {
    $drives = @([pscustomobject]@{ Error = $_.Exception.Message })
  }

  $cpu | Format-Table -AutoSize
  $mem | Format-List
  $drives | Sort-Object DeviceID | Format-Table -AutoSize

  Save-Object $cpu    (Join-Path $OutDir "02_CPU")
  Save-Object $mem    (Join-Path $OutDir "03_Memory")
  Save-Object $drives (Join-Path $OutDir "04_Disks")

  Write-Output (Write-Section "NETWORK (IPs/DNS/GW)")
  $net = @()
  try {
    $net = @(Get-NetIPConfiguration |
      Where-Object { $_.IPv4Address -ne $null } |
      Select-Object InterfaceAlias,
        @{n="IPv4";e={$_.IPv4Address.IPAddress}},
        @{n="GW";e={$_.IPv4DefaultGateway.NextHop}},
        @{n="DNSServers";e={($_.DNSServer.ServerAddresses -join ", ")}})
  } catch {
    $net = @([pscustomobject]@{ Error = $_.Exception.Message })
  }
  $net | Format-Table -AutoSize
  Save-Object $net (Join-Path $OutDir "05_Network")

  Write-Output (Write-Section "PENDING REBOOT")
  $pending = Get-PendingReboot
  $pending | Format-List
  Save-Object $pending (Join-Path $OutDir "06_PendingReboot")

  Write-Output (Write-Section "SERVICES (AUTO but NOT RUNNING)")
  $svc = @()
  try {
    $svc = @(Get-Service |
      Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' } |
      Select-Object Name, DisplayName, Status, StartType)
  } catch {
    $svc = @([pscustomobject]@{ Error = $_.Exception.Message })
  }
  $svc | Format-Table -AutoSize
  Save-Object $svc (Join-Path $OutDir "07_Services_AutoNotRunning")

  Write-Output (Write-Section "EVENT LOGS (System/Application) last N hours: Error/Critical")
  $start = (Get-Date).AddHours(-[math]::Abs($HoursEvents))

  $sysEvents = @()
  $appEvents = @()

  try {
    $sysEvents = @(Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start} -ErrorAction Stop |
      Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
      Select-Object -First $TopEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message)
  } catch {
    $sysEvents = @([pscustomobject]@{ Error = $_.Exception.Message })
  }

  try {
    $appEvents = @(Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$start} -ErrorAction Stop |
      Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
      Select-Object -First $TopEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message)
  } catch {
    $appEvents = @([pscustomobject]@{ Error = $_.Exception.Message })
  }

  $sysEvents | Format-Table -Wrap
  $appEvents | Format-Table -Wrap
  Save-Object $sysEvents (Join-Path $OutDir "08_SystemEvents_ErrCrit")
  Save-Object $appEvents (Join-Path $OutDir "09_AppEvents_ErrCrit")

  # --- Role detection (DC)
  $isDC = $false
  try {
    $isDC = ((Get-Service -Name NTDS -ErrorAction SilentlyContinue) -ne $null)
  } catch { $isDC = $false }

  if ($isDC) {
    Write-Output (Write-Section "ROLE: DOMAIN CONTROLLER - SERVICES + SHARES")
    $dcSvc = @()
    try {
      $dcSvc = @(Get-Service NTDS,DNS,Netlogon,KDC,W32Time -ErrorAction Stop | Select-Object Name, Status, StartType)
    } catch {
      $dcSvc = @([pscustomobject]@{ Error = $_.Exception.Message })
    }
    $dcSvc | Format-Table -AutoSize
    Save-Object $dcSvc (Join-Path $OutDir "10_DC_Services")

    # Quick share visibility (SYSVOL/NETLOGON expected)
    try {
      $shares = cmd /c 'net share' 2>&1
      $shares | Out-File (Join-Path $OutDir "11_DC_netshare.txt") -Encoding UTF8
    } catch {
      "net share failed: $($_.Exception.Message)" | Out-File (Join-Path $OutDir "11_DC_netshare_ERROR.txt") -Encoding UTF8
    }

    Write-Output (Write-Section "ROLE: DOMAIN CONTROLLER - AD REPLICATION (repadmin /replsummary)")
    try {
      $repl = cmd /c 'repadmin /replsummary' 2>&1
      $repl | Out-File (Join-Path $OutDir "12_DC_repadmin_replsummary.txt") -Encoding UTF8
    } catch {
      "repadmin failed: $($_.Exception.Message)" | Out-File (Join-Path $OutDir "12_DC_repadmin_ERROR.txt") -Encoding UTF8
    }

    Write-Output (Write-Section "ROLE: DOMAIN CONTROLLER - DCDIAG (/q errors only)")
    try {
      $dcdiag = cmd /c 'dcdiag /q' 2>&1
      $dcdiag | Out-File (Join-Path $OutDir "13_DC_dcdiag_q.txt") -Encoding UTF8
    } catch {
      "dcdiag failed: $($_.Exception.Message)" | Out-File (Join-Path $OutDir "13_DC_dcdiag_ERROR.txt") -Encoding UTF8
    }

    Write-Output (Write-Section "ROLE: DOMAIN CONTROLLER - TIME STATUS (w32tm)")
    try {
      $w32 = cmd /c 'w32tm /query /status' 2>&1
      $w32 | Out-File (Join-Path $OutDir "13b_DC_w32tm_status.txt") -Encoding UTF8
    } catch {
      "w32tm failed: $($_.Exception.Message)" | Out-File (Join-Path $OutDir "13b_DC_w32tm_ERROR.txt") -Encoding UTF8
    }

    Write-Output (Write-Section "ROLE: DOMAIN CONTROLLER - DNS Server log last N hours: Error/Critical")
    $dnsEvents = @()
    try {
      $dnsEvents = @(Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$start} -ErrorAction Stop |
        Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
        Select-Object -First $TopEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message)
    } catch {
      $dnsEvents = @([pscustomobject]@{ Error = $_.Exception.Message })
    }
    $dnsEvents | Format-Table -Wrap
    Save-Object $dnsEvents (Join-Path $OutDir "14_DC_DNSEvents_ErrCrit")
  }
  else {
    Write-Output (Write-Section "ROLE: FILE/GENERIC - SMB SHARES (non-admin)")
    $smb = @()
    try {
      $smb = @(Get-SmbShare -ErrorAction Stop |
        Where-Object { $_.Name -notin @('ADMIN$','C$','IPC$') -and $_.Name -notmatch '^\w\$$' } |
        Select-Object Name, Path, Description, EncryptData, FolderEnumerationMode, ConcurrentUserLimit)
    } catch {
      $smb = @([pscustomobject]@{ Error = $_.Exception.Message })
    }
    $smb | Format-Table -AutoSize
    Save-Object $smb (Join-Path $OutDir "10_File_SmbShares")
  }

  # --- QUICK FLAGS (GO/NO-GO)
  Write-Output (Write-Section "QUICK FLAGS (GO/NO-GO hints)")

  # Variables intermédiaires (StrictMode friendly)
  $lowDisks = @()
  try {
    $lowDisks = @(
      $drives |
        Where-Object { ($_ | Get-Member -Name FreePct -MemberType NoteProperty,Property) -and $_.FreePct -lt $FreePctThreshold } |
        Select-Object DeviceID, FreeGB, FreePct
    )
  } catch {
    $lowDisks = @([pscustomobject]@{ Error = $_.Exception.Message })
  }

  $flags = [pscustomobject]@{
    PendingReboot      = [bool]$pending.PendingReboot
    LowDiskAnyDrive    = [bool](@($lowDisks).Count -gt 0 -and -not (@($lowDisks)[0].PSObject.Properties.Name -contains 'Error'))
    LowDiskList        = $lowDisks

    AutoServicesDown   = [int](@($svc).Count)
    SystemErrCritCnt   = [int](@($sysEvents).Count)
    AppErrCritCnt      = [int](@($appEvents).Count)

    IsDomainController = [bool]$isDC
    EventsWindowHours  = [int]$HoursEvents
    DiskFreePctThresh  = [int]$FreePctThreshold
  }

  $flags | Format-List
  Save-Object $flags (Join-Path $OutDir "99_QuickFlags")
}
finally {
  Stop-Transcript | Out-Null
}

# Zip output
$zipPath = Join-Path $OutRoot "$HostName`_$TS`_PRECHECK.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force -ErrorAction SilentlyContinue }
Compress-Archive -Path (Join-Path $OutDir "*") -DestinationPath $zipPath -Force

"`nPRECHECK completed."
"Output folder: $OutDir"
"ZIP package : $zipPath"