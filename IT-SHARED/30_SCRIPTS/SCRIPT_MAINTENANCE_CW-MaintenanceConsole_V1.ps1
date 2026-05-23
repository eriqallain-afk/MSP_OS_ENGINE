<# 
CW_MaintenanceConsole.ps1
Menu-driven precheck/validation orchestrator (GO/NO-GO) for MSP maintenance.
- Remote execution via PSRemoting (Invoke-Command).
- Outputs per server: TXT + JSON + consolidated CSV.
ASCII-only outputs inside reports.

USAGE:
  powershell -ExecutionPolicy Bypass -File .\CW_MaintenanceConsole.ps1
OPTIONAL:
  -OutputRoot "C:\Temp\CW_OUT"
  -DefaultEventHours 24
#>

[CmdletBinding()]
param(
  [string]$OutputRoot = ".\OUTPUT",
  [int]$DefaultEventHours = 24
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ----------------------------- CONFIG -----------------------------
# Add/adjust your fleet here
$ServerCatalog = @(
  [pscustomobject]@{ Name="AZ-S-DC01";    DefaultRole="DC"     }
  [pscustomobject]@{ Name="AZ-S-DC02";    DefaultRole="DC"     }
  [pscustomobject]@{ Name="AZ-S-FS01";    DefaultRole="File"   }
  [pscustomobject]@{ Name="AZ-S-PRT01";   DefaultRole="Print"  }
  [pscustomobject]@{ Name="DAG-S-RODC01"; DefaultRole="RODC"   }
  [pscustomobject]@{ Name="MIS-S-RODC02"; DefaultRole="RODC"   }
  [pscustomobject]@{ Name="MIS-S-HV01";   DefaultRole="HyperV" }
)

# Thresholds for GO/NO-GO
$Threshold = [pscustomobject]@{
  DiskMinFreePct_NoGo = 15
  MaxErrCrit_System_NoGo = 1   # if > this => NO-GO (tune to taste)
  MaxErrCrit_App_NoGo    = 1
}

# Services commonly OK to be Stopped even if Automatic (environment-dependent!)
# Put only the ones you KNOW are acceptable in your MSP baseline.
$ExpectedStoppedServices = @{
  "Common" = @("RemoteRegistry","edgeupdate","edgeupdatem","GoogleUpdaterService","GoogleUpdaterInternalService")
  "DC"     = @()  # keep empty unless you have a known baseline
  "RODC"   = @()
  "File"   = @()
  "Print"  = @()
  "HyperV" = @()
}

# ----------------------------- HELPERS -----------------------------
function New-RunFolder {
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  $root = Join-Path $OutputRoot "RUN_$ts"
  New-Item -ItemType Directory -Path $root -Force | Out-Null
  return $root
}

function Write-AsciiReport {
  param(
    [Parameter(Mandatory)] [string]$Path,
    [Parameter(Mandatory)] [string[]]$Lines
  )
  $Lines -join "`r`n" | Out-File -FilePath $Path -Encoding ascii
}

function Read-Choice {
  param([string]$Prompt, [string]$Default = "")
  $v = Read-Host $Prompt
  if ([string]::IsNullOrWhiteSpace($v)) { return $Default }
  return $v
}

function Select-FromList {
  param(
    [Parameter(Mandatory)] [string]$Title,
    [Parameter(Mandatory)] [object[]]$Items,
    [Parameter(Mandatory)] [string]$DisplayProperty,
    [switch]$Multi
  )

  Write-Host ""
  Write-Host $Title -ForegroundColor Cyan
  Write-Host ("-" * 60)

  for ($i=0; $i -lt $Items.Count; $i++) {
    $label = $Items[$i].$DisplayProperty
    Write-Host ("[{0}] {1}" -f ($i+1), $label)
  }

  if ($Multi) {
    $raw = Read-Host "Enter numbers comma-separated (e.g. 1,3,5) or 'all'"
    if ($raw -match '^(all|ALL)$') { return $Items }
    $idx = $raw.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ - 1 }
    return $idx | Where-Object { $_ -ge 0 -and $_ -lt $Items.Count } | ForEach-Object { $Items[$_] }
  } else {
    $raw = Read-Host "Enter number"
    if ($raw -notmatch '^\d+$') { return $null }
    $i = [int]$raw - 1
    if ($i -lt 0 -or $i -ge $Items.Count) { return $null }
    return $Items[$i]
  }
}

function Get-PendingReboot_Local {
  $CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
  $WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
  $PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
  $CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'
  [pscustomobject]@{
    CBS_RebootPending           = $CBS
    WU_RebootRequired           = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending      = $CCM
    PendingReboot               = ($CBS -or $WU -or $PFR -or $CCM)
  }
}

function Get-Resources_Local {
  $os = Get-CimInstance Win32_OperatingSystem
  $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
  $uptime = (Get-Date) - $os.LastBootUpTime

  $memTotalGB = [math]::Round($os.TotalVisibleMemorySize/1MB,2)
  $memFreeGB  = [math]::Round($os.FreePhysicalMemory/1MB,2)
  $memUsedPct = if ($memTotalGB -gt 0) { [math]::Round((($memTotalGB-$memFreeGB)/$memTotalGB)*100,2) } else { $null }

  $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,
      @{n="SizeGB";e={[math]::Round($_.Size/1GB,2)}},
      @{n="FreeGB";e={[math]::Round($_.FreeSpace/1GB,2)}},
      @{n="FreePct";e={ if($_.Size){[math]::Round(($_.FreeSpace/$_.Size)*100,2)} else {$null}}}

  [pscustomobject]@{
    LastBoot     = $os.LastBootUpTime
    UptimeHours  = [math]::Round($uptime.TotalHours,2)
    CpuLoadPct   = $cpu.LoadPercentage
    MemTotalGB   = $memTotalGB
    MemFreeGB    = $memFreeGB
    MemUsedPct   = $memUsedPct
    Disks        = $disks
    DiskMinFreePct = ($disks | Measure-Object -Property FreePct -Minimum).Minimum
  }
}

function Get-EventCounts_Local {
  param([int]$EventHours = 24, [int]$MaxEvents = 40)
  $start = (Get-Date).AddHours(-[math]::Abs($EventHours))

  $sysEv = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start } -ErrorAction SilentlyContinue |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First $MaxEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message

  $appEv = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$start } -ErrorAction SilentlyContinue |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First $MaxEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message

  [pscustomobject]@{
    SystemErrCritCount = $sysEv.Count
    AppErrCritCount    = $appEv.Count
    SystemTop          = $sysEv
    AppTop             = $appEv
  }
}

function Get-AutoStoppedServices_Local {
  $autoStopped = Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' } |
    Select-Object Name, DisplayName, Status, StartType
  return $autoStopped
}

function Infer-Role_FromName {
  param([string]$ComputerName, [string]$RequestedRole)
  if ($RequestedRole -and $RequestedRole -ne "Auto") { return $RequestedRole }

  $n = $ComputerName.ToUpperInvariant()
  if ($n -match "RODC") { return "RODC" }
  if ($n -match "DC")   { return "DC" }
  if ($n -match "FS")   { return "File" }
  if ($n -match "PRT|PRINT") { return "Print" }
  if ($n -match "HV|HYPERV") { return "HyperV" }
  return "Auto"
}

# ----------------------------- ROLE CHECKS (LOCAL) -----------------------------
function RoleCheck_DC_Local {
  param([int]$EventHours = 24)

  $out = [ordered]@{}
  $out["RepadminReplSummary"] = (cmd /c "repadmin /replsummary") 2>&1
  $out["W32tmStatus"]         = (cmd /c "w32tm /query /status") 2>&1

  # SYSVOL GPT.INI check (Default Domain Policy)
  try {
    $dnsDomain = $env:USERDNSDOMAIN
    if ([string]::IsNullOrWhiteSpace($dnsDomain)) { $dnsDomain = (Get-CimInstance Win32_ComputerSystem).Domain }
    $gpt = "\\$dnsDomain\sysvol\$dnsDomain\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\gpt.ini"
    $out["SysvolGptPath"] = $gpt
    $out["SysvolGptAccessible"] = (Test-Path $gpt)
  } catch { $out["SysvolGptAccessible"] = $false }

  # Optional quick parse: any "fails/total" > 0 will be flagged in summary by Validate stage.
  return [pscustomobject]$out
}

function RoleCheck_RODC_Local {
  param([int]$EventHours = 24)
  # Same as DC checks, but RODC is inbound-only; still useful
  return (RoleCheck_DC_Local -EventHours $EventHours)
}

function RoleCheck_File_Local {
  $out = [ordered]@{}
  # Shares
  try {
    if (Get-Command Get-SmbShare -ErrorAction SilentlyContinue) {
      $out["SmbShareCount"] = (Get-SmbShare | Where-Object { $_.Name -notmatch '^\w\$$' }).Count
    } else {
      $out["SmbShareCount"] = $null
    }
  } catch { $out["SmbShareCount"] = $null }

  # Sessions / Open files (counts)
  try {
    if (Get-Command Get-SmbSession -ErrorAction SilentlyContinue) {
      $out["SmbSessionCount"] = (Get-SmbSession -ErrorAction SilentlyContinue).Count
    }
    if (Get-Command Get-SmbOpenFile -ErrorAction SilentlyContinue) {
      $out["SmbOpenFileTop30"] = (Get-SmbOpenFile -ErrorAction SilentlyContinue | Select-Object -First 30).Count
    }
  } catch {}

  # VSS writers (stable?)
  try {
    $vss = (cmd /c "vssadmin list writers") 2>&1
    $bad = @()
    foreach ($line in $vss) {
      if ($line -match "State:\s+\[(\d+)\]\s+(.+)$") {
        $state = $Matches[2].Trim()
        if ($state -notmatch "^Stable") { $bad += $state }
      }
    }
    $out["VssWritersNotStable"] = ($bad | Select-Object -Unique)
  } catch { $out["VssWritersNotStable"] = @("UNKNOWN") }

  return [pscustomobject]$out
}

function RoleCheck_Print_Local {
  param([int]$EventHours = 24, [int]$MaxEvents = 40)

  $out = [ordered]@{}
  $spooler = Get-Service Spooler -ErrorAction SilentlyContinue
  $out["SpoolerStatus"] = if ($spooler) { $spooler.Status.ToString() } else { "UNKNOWN" }

  # Spool folder size hint
  try {
    $spoolPath = Join-Path $env:WINDIR "System32\spool\PRINTERS"
    $out["SpoolFolder"] = $spoolPath
    if (Test-Path $spoolPath) {
      $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
      $bytes = ($files | Measure-Object -Property Length -Sum).Sum
      $out["SpoolFilesCount"] = $files.Count
      $out["SpoolFilesSizeMB"] = [math]::Round(([double]$bytes)/1MB,2)
    }
  } catch {}

  # Printer count
  try {
    if (Get-Command Get-Printer -ErrorAction SilentlyContinue) {
      $out["PrinterCount"] = (Get-Printer -ErrorAction SilentlyContinue).Count
    } else {
      $out["PrinterCount"] = $null
    }
  } catch { $out["PrinterCount"] = $null }

  # PrintService events count (warn+err+crit)
  try {
    $start = (Get-Date).AddHours(-[math]::Abs($EventHours))
    $logName = "Microsoft-Windows-PrintService/Operational"
    $pe = Get-WinEvent -FilterHashtable @{LogName=$logName; StartTime=$start } -ErrorAction SilentlyContinue |
      Where-Object { $_.LevelDisplayName -in 'Error','Critical','Warning' } |
      Select-Object -First $MaxEvents TimeCreated, Id, LevelDisplayName, Message
    $out["PrintServiceEventsCount"] = $pe.Count
  } catch { $out["PrintServiceEventsCount"] = $null }

  return [pscustomobject]$out
}

function RoleCheck_HyperV_Local {
  $out = [ordered]@{}
  # Host service
  $vmms = Get-Service vmms -ErrorAction SilentlyContinue
  $out["VMMS_Status"] = if ($vmms) { $vmms.Status.ToString() } else { "UNKNOWN" }

  # VMs + snapshots (if module available)
  try {
    if (Get-Command Get-VM -ErrorAction SilentlyContinue) {
      $vms = Get-VM
      $out["VM_Count"] = $vms.Count
      $out["VM_NotRunning"] = ($vms | Where-Object { $_.State -ne "Running" } | Select-Object -ExpandProperty Name)
      if (Get-Command Get-VMSnapshot -ErrorAction SilentlyContinue) {
        $sn = Get-VMSnapshot -ErrorAction SilentlyContinue
        $out["Snapshot_Count"] = $sn.Count
        $out["Snapshot_List"] = $sn | Select-Object VMName, Name, CreationTime
      } else {
        $out["Snapshot_Count"] = $null
      }
    } else {
      $out["VM_Count"] = $null
    }
  } catch {}

  return [pscustomobject]$out
}

# ----------------------------- PRECHECK CORE (LOCAL) -----------------------------
function Invoke-Precheck_Local {
  param(
    [string]$Role = "Auto",
    [int]$EventHours = 24,
    [int]$MaxEvents = 40,
    [int]$DiskMinFreePct_NoGo = 15,
    [string[]]$ExpectedStoppedCommon = @(),
    [string[]]$ExpectedStoppedRole = @()
  )

  $cs = Get-CimInstance Win32_ComputerSystem
  $os = Get-CimInstance Win32_OperatingSystem
  $resources = Get-Resources_Local
  $pending = Get-PendingReboot_Local
  $events = Get-EventCounts_Local -EventHours $EventHours -MaxEvents $MaxEvents
  $autoStopped = Get-AutoStoppedServices_Local

  # filter expected stopped services
  $expected = @($ExpectedStoppedCommon + $ExpectedStoppedRole) | Where-Object { $_ } | Select-Object -Unique
  $unexpected = @()
  foreach ($s in $autoStopped) {
    if ($expected -notcontains $s.Name) { $unexpected += $s }
  }

  # role checks
  $roleData = $null
  switch ($Role) {
    "DC"     { $roleData = RoleCheck_DC_Local -EventHours $EventHours }
    "RODC"   { $roleData = RoleCheck_RODC_Local -EventHours $EventHours }
    "File"   { $roleData = RoleCheck_File_Local }
    "Print"  { $roleData = RoleCheck_Print_Local -EventHours $EventHours -MaxEvents $MaxEvents }
    "HyperV" { $roleData = RoleCheck_HyperV_Local }
    default  { $roleData = [pscustomobject]@{} }
  }

  # flags
  $reasons = @()
  if ($pending.PendingReboot) { $reasons += "PendingReboot=TRUE" }
  if ($resources.DiskMinFreePct -lt $DiskMinFreePct_NoGo) { $reasons += ("DiskMinFreePct<{0} (={1})" -f $DiskMinFreePct_NoGo, $resources.DiskMinFreePct) }
  if ($events.SystemErrCritCount -gt $Threshold.MaxErrCrit_System_NoGo) { $reasons += ("SystemErrCrit>{0} (={1})" -f $Threshold.MaxErrCrit_System_NoGo, $events.SystemErrCritCount) }
  if ($events.AppErrCritCount -gt $Threshold.MaxErrCrit_App_NoGo) { $reasons += ("AppErrCrit>{0} (={1})" -f $Threshold.MaxErrCrit_App_NoGo, $events.AppErrCritCount) }
  if ($unexpected.Count -gt 0) { $reasons += ("AutoServicesUnexpected>0 (={0})" -f $unexpected.Count) }

  # HyperV hints
  if ($Role -eq "HyperV") {
    if ($roleData.VMMS_Status -ne "Running") { $reasons += "VMMS_NotRunning" }
    if ($roleData.VM_NotRunning -and $roleData.VM_NotRunning.Count -gt 0) {
      # treat as WARN by default, but keep reason as visibility
      $reasons += ("VM_NotRunning_Count={0}" -f $roleData.VM_NotRunning.Count)
    }
  }

  $status = if ($reasons.Count -gt 0) { "NO-GO" } else { "GO" }

  [pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    Domain       = $cs.Domain
    OS           = $os.Caption
    Role         = $Role
    LastBoot     = $resources.LastBoot
    UptimeHours  = $resources.UptimeHours
    PendingReboot = [bool]$pending.PendingReboot
    DiskMinFreePct = $resources.DiskMinFreePct
    AutoServicesUnexpectedCount = $unexpected.Count
    SystemErrCritCount = $events.SystemErrCritCount
    AppErrCritCount    = $events.AppErrCritCount
    Status       = $status
    Reasons      = $reasons
    Details = [pscustomobject]@{
      Resources = $resources
      Pending   = $pending
      Events    = $events
      AutoServicesStoppedAll = $autoStopped
      AutoServicesUnexpected = $unexpected
      RoleData  = $roleData
    }
  }
}

# ----------------------------- VALIDATION (LOCAL) -----------------------------
function Invoke-Validation_Local {
  param([string]$Role="Auto", [int]$EventHours=24)

  $out = [ordered]@{}
  switch ($Role) {
    "DC" { 
      $out["RepadminShowrepl"] = (cmd /c "repadmin /showrepl") 2>&1
      $out["DCDIAG_Q"]         = (cmd /c "dcdiag /q") 2>&1
      $out["W32tmStatus"]      = (cmd /c "w32tm /query /status") 2>&1
      $out["SysvolGptCheck"]   = (cmd /c "cmd /c dir \\regal.local\sysvol\regal.local\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\gpt.ini") 2>&1
      $out["DFSR_Events_50"]   = (cmd /c 'wevtutil qe "DFS Replication" /c:50 /f:text') 2>&1
      $out["GP_Events_50"]     = (cmd /c 'wevtutil qe System /q:"*[System[Provider[@Name=''Microsoft-Windows-GroupPolicy'']]]" /c:50 /f:text') 2>&1
    }
    "RODC" {
      $out["RepadminShowrepl"] = (cmd /c "repadmin /showrepl") 2>&1
      $out["DCDIAG_Q"]         = (cmd /c "dcdiag /q") 2>&1
      $out["W32tmStatus"]      = (cmd /c "w32tm /query /status") 2>&1
      $out["SysvolGptCheck"]   = (cmd /c "cmd /c dir \\regal.local\sysvol\regal.local\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\gpt.ini") 2>&1
      $out["DFSR_Events_50"]   = (cmd /c 'wevtutil qe "DFS Replication" /c:50 /f:text') 2>&1
    }
    "File" {
      $out["SmbSessions"]      = (powershell -NoProfile -Command "Get-SmbSession | Select ClientComputerName,ClientUserName,NumOpens,Dialect,SessionId | Format-Table -AutoSize | Out-String") 2>&1
      $out["SmbOpenFilesTop50"]= (powershell -NoProfile -Command "Get-SmbOpenFile | Select -First 50 ClientComputerName,ClientUserName,ShareRelativePath,FileId | Format-Table -AutoSize | Out-String") 2>&1
      $out["VSSWriters"]       = (cmd /c "vssadmin list writers") 2>&1
    }
    "Print" {
      $out["Spooler"]          = (cmd /c "sc query Spooler") 2>&1
      $out["PrintService_Events_50"] = (cmd /c 'wevtutil qe "Microsoft-Windows-PrintService/Operational" /c:50 /f:text') 2>&1
    }
    "HyperV" {
      $out["VMMS"]             = (cmd /c "sc query vmms") 2>&1
      if (Get-Command Get-VM -ErrorAction SilentlyContinue) {
        $out["VM_List"]        = (Get-VM | Select Name,State,Status,Uptime,CPUUsage,MemoryAssigned | Format-Table -AutoSize | Out-String)
        if (Get-Command Get-VMSnapshot -ErrorAction SilentlyContinue) {
          $out["Snapshots"]    = (Get-VMSnapshot | Select VMName,Name,CreationTime | Format-Table -AutoSize | Out-String)
        }
      }
    }
    default { $out["Info"] = "No validation for role=Auto" }
  }
  return [pscustomobject]$out
}

# ----------------------------- REMOTE WRAPPERS -----------------------------
function Invoke-Remote {
  param(
    [Parameter(Mandatory)] [string]$ComputerName,
    [Parameter(Mandatory)] [scriptblock]$ScriptBlock,
    [Parameter(Mandatory)] [hashtable]$ArgumentList,
    [pscredential]$Credential = $null
  )

  $icmParams = @{
    ComputerName = $ComputerName
    ScriptBlock  = $ScriptBlock
    ArgumentList = @($ArgumentList)
  }
  if ($Credential) { $icmParams.Credential = $Credential }
  Invoke-Command @icmParams
}

# ----------------------------- MAIN APP -----------------------------
$runRoot = New-RunFolder
Write-Host ""
Write-Host ("Output folder: {0}" -f (Resolve-Path $runRoot)) -ForegroundColor Yellow

# credential prompt (optional)
$useCred = Read-Choice "Use alternate credentials? (y/N)" "N"
$cred = $null
if ($useCred -match '^(y|Y)$') { $cred = Get-Credential }

# select servers
$targets = Select-FromList -Title "Select server(s)" -Items $ServerCatalog -DisplayProperty "Name" -Multi
if (-not $targets -or $targets.Count -eq 0) { Write-Host "No server selected. Exiting."; exit 1 }

# role selection mode
$roleMode = Read-Choice "Role mode: (1)=Use catalog defaults, (2)=Auto infer, (3)=Prompt per server" "1"

# action
$action = Read-Choice "Action: (1)=PRECHECK, (2)=VALIDATION only, (3)=PRECHECK then conditional VALIDATION" "3"
$eventHours = [int](Read-Choice "Event window hours" $DefaultEventHours)

$results = @()

foreach ($t in $targets) {
  $server = $t.Name
  Write-Host ""
  Write-Host ("=== {0} ===" -f $server) -ForegroundColor Cyan

  # determine role
  $role = $t.DefaultRole
  if ($roleMode -eq "2") {
    $role = Infer-Role_FromName -ComputerName $server -RequestedRole "Auto"
    if ($role -eq "Auto") { $role = $t.DefaultRole }
  }
  elseif ($roleMode -eq "3") {
    $role = Read-Choice ("Role for {0} (DC/RODC/File/Print/HyperV/Auto)" -f $server) $t.DefaultRole
    if ([string]::IsNullOrWhiteSpace($role)) { $role = $t.DefaultRole }
  }

  # remote scriptblock will run local functions (we serialize only what we need)
  $precheckSb = {
    param($args)
    # re-declare minimal deps inside remote session
    $Threshold = $args.Threshold

    function Get-PendingReboot_Local {
      $CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
      $WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
      $PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
      $CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'
      [pscustomobject]@{
        CBS_RebootPending           = $CBS
        WU_RebootRequired           = $WU
        PendingFileRenameOperations = $PFR
        CCMClientRebootPending      = $CCM
        PendingReboot               = ($CBS -or $WU -or $PFR -or $CCM)
      }
    }

    function Get-Resources_Local {
      $os = Get-CimInstance Win32_OperatingSystem
      $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
      $uptime = (Get-Date) - $os.LastBootUpTime

      $memTotalGB = [math]::Round($os.TotalVisibleMemorySize/1MB,2)
      $memFreeGB  = [math]::Round($os.FreePhysicalMemory/1MB,2)
      $memUsedPct = if ($memTotalGB -gt 0) { [math]::Round((($memTotalGB-$memFreeGB)/$memTotalGB)*100,2) } else { $null }

      $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID,
          @{n="SizeGB";e={[math]::Round($_.Size/1GB,2)}},
          @{n="FreeGB";e={[math]::Round($_.FreeSpace/1GB,2)}},
          @{n="FreePct";e={ if($_.Size){[math]::Round(($_.FreeSpace/$_.Size)*100,2)} else {$null}}}

      [pscustomobject]@{
        LastBoot     = $os.LastBootUpTime
        UptimeHours  = [math]::Round($uptime.TotalHours,2)
        CpuLoadPct   = $cpu.LoadPercentage
        MemTotalGB   = $memTotalGB
        MemFreeGB    = $memFreeGB
        MemUsedPct   = $memUsedPct
        Disks        = $disks
        DiskMinFreePct = ($disks | Measure-Object -Property FreePct -Minimum).Minimum
      }
    }

    function Get-EventCounts_Local {
      param([int]$EventHours = 24, [int]$MaxEvents = 40)
      $start = (Get-Date).AddHours(-[math]::Abs($EventHours))
      $sysEv = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start } -ErrorAction SilentlyContinue |
        Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
        Select-Object -First $MaxEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message
      $appEv = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$start } -ErrorAction SilentlyContinue |
        Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
        Select-Object -First $MaxEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message
      [pscustomobject]@{
        SystemErrCritCount = $sysEv.Count
        AppErrCritCount    = $appEv.Count
        SystemTop          = $sysEv
        AppTop             = $appEv
      }
    }

    function Get-AutoStoppedServices_Local {
      Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' } |
        Select-Object Name, DisplayName, Status, StartType
    }

    function RoleCheck_HyperV_Local {
      $out = [ordered]@{}
      $vmms = Get-Service vmms -ErrorAction SilentlyContinue
      $out["VMMS_Status"] = if ($vmms) { $vmms.Status.ToString() } else { "UNKNOWN" }
      try {
        if (Get-Command Get-VM -ErrorAction SilentlyContinue) {
          $vms = Get-VM
          $out["VM_Count"] = $vms.Count
          $out["VM_NotRunning"] = ($vms | Where-Object { $_.State -ne "Running" } | Select-Object -ExpandProperty Name)
          if (Get-Command Get-VMSnapshot -ErrorAction SilentlyContinue) {
            $sn = Get-VMSnapshot -ErrorAction SilentlyContinue
            $out["Snapshot_Count"] = $sn.Count
          }
        }
      } catch {}
      [pscustomobject]$out
    }

    function RoleCheck_Print_Local {
      param([int]$EventHours = 24, [int]$MaxEvents = 40)
      $out = [ordered]@{}
      $spooler = Get-Service Spooler -ErrorAction SilentlyContinue
      $out["SpoolerStatus"] = if ($spooler) { $spooler.Status.ToString() } else { "UNKNOWN" }
      try {
        $start = (Get-Date).AddHours(-[math]::Abs($EventHours))
        $logName = "Microsoft-Windows-PrintService/Operational"
        $pe = Get-WinEvent -FilterHashtable @{LogName=$logName; StartTime=$start } -ErrorAction SilentlyContinue |
          Where-Object { $_.LevelDisplayName -in 'Error','Critical','Warning' } |
          Select-Object -First $MaxEvents TimeCreated, Id, LevelDisplayName, Message
        $out["PrintServiceEventsCount"] = $pe.Count
      } catch { $out["PrintServiceEventsCount"] = $null }
      [pscustomobject]$out
    }

    function RoleCheck_File_Local {
      $out = [ordered]@{}
      try {
        if (Get-Command Get-SmbSession -ErrorAction SilentlyContinue) {
          $out["SmbSessionCount"] = (Get-SmbSession -ErrorAction SilentlyContinue).Count
        }
      } catch {}
      try {
        $vss = (cmd /c "vssadmin list writers") 2>&1
        $bad = @()
        foreach ($line in $vss) {
          if ($line -match "State:\s+\[(\d+)\]\s+(.+)$") {
            $state = $Matches[2].Trim()
            if ($state -notmatch "^Stable") { $bad += $state }
          }
        }
        $out["VssWritersNotStable"] = ($bad | Select-Object -Unique)
      } catch { $out["VssWritersNotStable"] = @("UNKNOWN") }
      [pscustomobject]$out
    }

    function RoleCheck_DC_Local {
      $out = [ordered]@{}
      $out["RepadminReplSummary"] = (cmd /c "repadmin /replsummary") 2>&1
      $out["W32tmStatus"]         = (cmd /c "w32tm /query /status") 2>&1
      try {
        $dnsDomain = $env:USERDNSDOMAIN
        if ([string]::IsNullOrWhiteSpace($dnsDomain)) { $dnsDomain = (Get-CimInstance Win32_ComputerSystem).Domain }
        $gpt = "\\$dnsDomain\sysvol\$dnsDomain\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\gpt.ini"
        $out["SysvolGptPath"] = $gpt
        $out["SysvolGptAccessible"] = (Test-Path $gpt)
      } catch { $out["SysvolGptAccessible"] = $false }
      [pscustomobject]$out
    }

    $cs = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem
    $resources = Get-Resources_Local
    $pending = Get-PendingReboot_Local
    $events = Get-EventCounts_Local -EventHours $args.EventHours -MaxEvents $args.MaxEvents
    $autoStopped = Get-AutoStoppedServices_Local

    $expected = @($args.ExpectedStoppedCommon + $args.ExpectedStoppedRole) | Where-Object { $_ } | Select-Object -Unique
    $unexpected = @()
    foreach ($s in $autoStopped) { if ($expected -notcontains $s.Name) { $unexpected += $s } }

    $roleData = switch ($args.Role) {
      "DC"     { RoleCheck_DC_Local }
      "RODC"   { RoleCheck_DC_Local }
      "File"   { RoleCheck_File_Local }
      "Print"  { RoleCheck_Print_Local -EventHours $args.EventHours -MaxEvents $args.MaxEvents }
      "HyperV" { RoleCheck_HyperV_Local }
      default  { [pscustomobject]@{} }
    }

    $reasons = @()
    if ($pending.PendingReboot) { $reasons += "PendingReboot=TRUE" }
    if ($resources.DiskMinFreePct -lt $args.DiskMinFreePct_NoGo) { $reasons += ("DiskMinFreePct<{0} (={1})" -f $args.DiskMinFreePct_NoGo,$resources.DiskMinFreePct) }
    if ($events.SystemErrCritCount -gt $Threshold.MaxErrCrit_System_NoGo) { $reasons += ("SystemErrCrit>{0} (={1})" -f $Threshold.MaxErrCrit_System_NoGo,$events.SystemErrCritCount) }
    if ($events.AppErrCritCount -gt $Threshold.MaxErrCrit_App_NoGo) { $reasons += ("AppErrCrit>{0} (={1})" -f $Threshold.MaxErrCrit_App_NoGo,$events.AppErrCritCount) }
    if ($unexpected.Count -gt 0) { $reasons += ("AutoServicesUnexpected>0 (={0})" -f $unexpected.Count) }

    if ($args.Role -eq "HyperV") {
      if ($roleData.VMMS_Status -ne "Running") { $reasons += "VMMS_NotRunning" }
      if ($roleData.VM_NotRunning -and $roleData.VM_NotRunning.Count -gt 0) {
        $reasons += ("VM_NotRunning_Count={0}" -f $roleData.VM_NotRunning.Count)
      }
    }

    $status = if ($reasons.Count -gt 0) { "NO-GO" } else { "GO" }

    [pscustomobject]@{
      ComputerName = $env:COMPUTERNAME
      Domain       = $cs.Domain
      OS           = $os.Caption
      Role         = $args.Role
      LastBoot     = $resources.LastBoot
      UptimeHours  = $resources.UptimeHours
      PendingReboot = [bool]$pending.PendingReboot
      DiskMinFreePct = $resources.DiskMinFreePct
      AutoServicesUnexpectedCount = $unexpected.Count
      SystemErrCritCount = $events.SystemErrCritCount
      AppErrCritCount    = $events.AppErrCritCount
      Status       = $status
      Reasons      = $reasons
      Details = [pscustomobject]@{
        Resources = $resources
        Pending   = $pending
        Events    = $events
        AutoServicesStoppedAll = $autoStopped
        AutoServicesUnexpected = $unexpected
        RoleData  = $roleData
      }
    }
  }

  $validationSb = {
    param($args)

    function Invoke-Validation_Local {
      param([string]$Role="Auto", [int]$EventHours=24)
      $out = [ordered]@{}
      switch ($Role) {
        "DC" {
          $out["RepadminShowrepl"] = (cmd /c "repadmin /showrepl") 2>&1
          $out["DCDIAG_Q"]         = (cmd /c "dcdiag /q") 2>&1
          $out["W32tmStatus"]      = (cmd /c "w32tm /query /status") 2>&1
          $out["SysvolGptCheck"]   = (cmd /c "cmd /c dir \\regal.local\sysvol\regal.local\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\gpt.ini") 2>&1
          $out["DFSR_Events_50"]   = (cmd /c 'wevtutil qe "DFS Replication" /c:50 /f:text') 2>&1
          $out["GP_Events_50"]     = (cmd /c 'wevtutil qe System /q:"*[System[Provider[@Name=''Microsoft-Windows-GroupPolicy'']]]" /c:50 /f:text') 2>&1
        }
        "RODC" {
          $out["RepadminShowrepl"] = (cmd /c "repadmin /showrepl") 2>&1
          $out["DCDIAG_Q"]         = (cmd /c "dcdiag /q") 2>&1
          $out["W32tmStatus"]      = (cmd /c "w32tm /query /status") 2>&1
          $out["SysvolGptCheck"]   = (cmd /c "cmd /c dir \\regal.local\sysvol\regal.local\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\gpt.ini") 2>&1
          $out["DFSR_Events_50"]   = (cmd /c 'wevtutil qe "DFS Replication" /c:50 /f:text') 2>&1
        }
        "File" {
          $out["SmbSessions"]      = (powershell -NoProfile -Command "Get-SmbSession | Select ClientComputerName,ClientUserName,NumOpens,Dialect,SessionId | Format-Table -AutoSize | Out-String") 2>&1
          $out["SmbOpenFilesTop50"]= (powershell -NoProfile -Command "Get-SmbOpenFile | Select -First 50 ClientComputerName,ClientUserName,ShareRelativePath,FileId | Format-Table -AutoSize | Out-String") 2>&1
          $out["VSSWriters"]       = (cmd /c "vssadmin list writers") 2>&1
        }
        "Print" {
          $out["Spooler"]          = (cmd /c "sc query Spooler") 2>&1
          $out["PrintService_Events_50"] = (cmd /c 'wevtutil qe "Microsoft-Windows-PrintService/Operational" /c:50 /f:text') 2>&1
        }
        "HyperV" {
          $out["VMMS"]             = (cmd /c "sc query vmms") 2>&1
          if (Get-Command Get-VM -ErrorAction SilentlyContinue) {
            $out["VM_List"]        = (Get-VM | Select Name,State,Status,Uptime,CPUUsage,MemoryAssigned | Format-Table -AutoSize | Out-String)
            if (Get-Command Get-VMSnapshot -ErrorAction SilentlyContinue) {
              $out["Snapshots"]    = (Get-VMSnapshot | Select VMName,Name,CreationTime | Format-Table -AutoSize | Out-String)
            }
          }
        }
        default { $out["Info"] = "No validation for role=Auto" }
      }
      [pscustomobject]$out
    }

    Invoke-Validation_Local -Role $args.Role -EventHours $args.EventHours
  }

  # build args
  $role = $role.Trim()
  if ($role -eq "Auto") { $role = Infer-Role_FromName -ComputerName $server -RequestedRole "Auto"; if ($role -eq "Auto") { $role = $t.DefaultRole } }

  $args = @{
    Role = $role
    EventHours = $eventHours
    MaxEvents  = 40
    DiskMinFreePct_NoGo = $Threshold.DiskMinFreePct_NoGo
    ExpectedStoppedCommon = $ExpectedStoppedServices["Common"]
    ExpectedStoppedRole   = $ExpectedStoppedServices[$role]
    Threshold = $Threshold
  }

  $serverFolder = Join-Path $runRoot $server
  New-Item -ItemType Directory -Path $serverFolder -Force | Out-Null

  if ($action -eq "2") {
    $val = Invoke-Remote -ComputerName $server -ScriptBlock $validationSb -ArgumentList @{ Role=$role; EventHours=$eventHours } -Credential $cred
    $valPath = Join-Path $serverFolder ("VALIDATION_{0}.txt" -f $role)
    $valJson = Join-Path $serverFolder ("VALIDATION_{0}.json" -f $role)

    # write
    $lines = @("VALIDATION ROLE=$role SERVER=$server", ("-"*60))
    foreach ($p in $val.PSObject.Properties) {
      $lines += ""
      $lines += ("[{0}]" -f $p.Name)
      $v = $p.Value
      if ($v -is [string[]]) { $lines += $v }
      elseif ($v -is [string]) { $lines += $v.Split("`n") }
      else { $lines += ($v | Out-String).Split("`n") }
    }
    Write-AsciiReport -Path $valPath -Lines $lines
    $val | ConvertTo-Json -Depth 6 | Out-File $valJson -Encoding utf8

    $results += [pscustomobject]@{ ComputerName=$server; Role=$role; Status="VALIDATION"; Reasons=@(); OutputFolder=$serverFolder }
    continue
  }

  # PRECHECK
  $pre = Invoke-Remote -ComputerName $server -ScriptBlock $precheckSb -ArgumentList $args -Credential $cred

  $prePath = Join-Path $serverFolder ("PRECHECK_{0}.txt" -f $role)
  $preJson = Join-Path $serverFolder ("PRECHECK_{0}.json" -f $role)

  # Build ASCII report
  $lines = @()
  $lines += "============================================================"
  $lines += ("PRECHECK SERVER={0} ROLE={1}" -f $server,$role)
  $lines += ("Timestamp: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
  $lines += "============================================================"
  $lines += ""
  $lines += ("Status : {0}" -f $pre.Status)
  $lines += ("Reasons: {0}" -f (if($pre.Reasons.Count){$pre.Reasons -join " | "}else{"(none)"}))
  $lines += ""
  $lines += ("LastBoot     : {0}" -f $pre.LastBoot)
  $lines += ("UptimeHours  : {0}" -f $pre.UptimeHours)
  $lines += ("PendingReboot: {0}" -f $pre.PendingReboot)
  $lines += ("DiskMinFreePct: {0}" -f $pre.DiskMinFreePct)
  $lines += ("AutoServicesUnexpectedCount: {0}" -f $pre.AutoServicesUnexpectedCount)
  $lines += ("SystemErrCritCount: {0}" -f $pre.SystemErrCritCount)
  $lines += ("AppErrCritCount   : {0}" -f $pre.AppErrCritCount)
  $lines += ""
  $lines += "---- DISKS ----"
  foreach ($d in $pre.Details.Resources.Disks) {
    $lines += ("  {0} SizeGB={1} FreeGB={2} FreePct={3}" -f $d.DeviceID,$d.SizeGB,$d.FreeGB,$d.FreePct)
  }
  $lines += ""
  $lines += "---- AUTO SERVICES UNEXPECTED (first 30) ----"
  $take = @($pre.Details.AutoServicesUnexpected | Select-Object -First 30)
  foreach ($s in $take) { $lines += ("  {0} ({1}) Status={2}" -f $s.Name,$s.DisplayName,$s.Status) }
  $lines += ""
  $lines += "---- ROLE DATA (summary) ----"
  $lines += (($pre.Details.RoleData | Out-String).Split("`n"))
  $lines += "============================================================"

  Write-AsciiReport -Path $prePath -Lines $lines
  $pre | ConvertTo-Json -Depth 8 | Out-File $preJson -Encoding utf8

  Write-Host ("PRECHECK => {0} ({1})" -f $pre.Status, ($pre.Reasons -join " | ")) -ForegroundColor (if($pre.Status -eq "GO"){"Green"}else{"Red"})

  # conditional VALIDATION
  if ($action -eq "3" -and $pre.Status -eq "NO-GO") {
    $doVal = Read-Choice ("Run VALIDATION for {0} now? (y/N)" -f $server) "N"
    if ($doVal -match '^(y|Y)$') {
      $val = Invoke-Remote -ComputerName $server -ScriptBlock $validationSb -ArgumentList @{ Role=$role; EventHours=$eventHours } -Credential $cred
      $valPath = Join-Path $serverFolder ("VALIDATION_{0}.txt" -f $role)
      $valJson = Join-Path $serverFolder ("VALIDATION_{0}.json" -f $role)

      $vLines = @("VALIDATION ROLE=$role SERVER=$server", ("-"*60))
      foreach ($p in $val.PSObject.Properties) {
        $vLines += ""
        $vLines += ("[{0}]" -f $p.Name)
        $v = $p.Value
        if ($v -is [string[]]) { $vLines += $v }
        elseif ($v -is [string]) { $vLines += $v.Split("`n") }
        else { $vLines += ($v | Out-String).Split("`n") }
      }
      Write-AsciiReport -Path $valPath -Lines $vLines
      $val | ConvertTo-Json -Depth 6 | Out-File $valJson -Encoding utf8
      Write-Host "VALIDATION saved." -ForegroundColor Yellow
    }
  }

  $results += [pscustomobject]@{
    ComputerName = $server
    Role         = $role
    Status       = $pre.Status
    Reasons      = ($pre.Reasons -join " | ")
    OutputFolder = $serverFolder
  }
}

# Consolidated summary
$csv = Join-Path $runRoot "SUMMARY.csv"
$results | Export-Csv -NoTypeInformation -Path $csv -Encoding utf8
Write-Host ""
Write-Host ("Consolidated summary: {0}" -f $csv) -ForegroundColor Yellow

Write-Host ""
Write-Host "DONE." -ForegroundColor Green