<#  CW_PRECHECK_HYPERV_ASCII.ps1
    Hyper-V Host precheck - ASCII report (CW RMM friendly)
    Output: REPORT_HYPERV_*.txt + SUMMARY_*.json
#>

param(
  [string]$OutDir = "$env:TEMP\CW_PRECHECK_HYPERV",
  [int]$EventHours = 24,
  [int]$MaxEvents = 60,
  [int]$MinDiskFreePctNoGo = 15,
  [int]$MaxVmNotRunningNoGo = 0,   # if >0 VMs not running => NO-GO (set 0 to be strict)
  [switch]$TreatSnapshotsAsNoGo     # by default snapshots are WARN, not NO-GO
)

function KV($k, $v) { "{0,-28} : {1}" -f $k, $v }

function Get-PendingReboot {
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

$ts  = Get-Date -Format "yyyyMMdd_HHmmss"
$srv = $env:COMPUTERNAME
$root = Join-Path $OutDir "${srv}_$ts"
New-Item -ItemType Directory -Path $root -Force | Out-Null

$report = Join-Path $root "REPORT_HYPERV_$ts.txt"
$json   = Join-Path $root "SUMMARY_HYPERV_$ts.json"

$sb = New-Object System.Text.StringBuilder

# ---- Header
$sb.AppendLine("============================================================") | Out-Null
$sb.AppendLine("HYPER-V HOST PRECHECK (ASCII)") | Out-Null
$sb.AppendLine("Host: $srv   Timestamp: $ts") | Out-Null
$sb.AppendLine("============================================================") | Out-Null

# ---- Host / OS / Uptime
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$uptime = (Get-Date) - $os.LastBootUpTime

$sb.AppendLine("") | Out-Null
$sb.AppendLine("---- HOST / OS / UPTIME ------------------------------------") | Out-Null
$sb.AppendLine((KV "Domain" $cs.Domain)) | Out-Null
$sb.AppendLine((KV "OS" $os.Caption)) | Out-Null
$sb.AppendLine((KV "Version" $os.Version)) | Out-Null
$sb.AppendLine((KV "Build" $os.BuildNumber)) | Out-Null
$sb.AppendLine((KV "LastBoot" $os.LastBootUpTime)) | Out-Null
$sb.AppendLine((KV "UptimeHours" ([math]::Round($uptime.TotalHours,2)))) | Out-Null

# ---- Resources
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$memTotalGB = [math]::Round($os.TotalVisibleMemorySize/1MB,2)
$memFreeGB  = [math]::Round($os.FreePhysicalMemory/1MB,2)
$memUsedPct = if ($memTotalGB -gt 0) { [math]::Round((($memTotalGB-$memFreeGB)/$memTotalGB)*100,2) } else { $null }

$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
  Select-Object DeviceID,
    @{n="SizeGB";e={[math]::Round($_.Size/1GB,2)}},
    @{n="FreeGB";e={[math]::Round($_.FreeSpace/1GB,2)}},
    @{n="FreePct";e={ if($_.Size){[math]::Round(($_.FreeSpace/$_.Size)*100,2)} else {$null}}}

$sb.AppendLine("") | Out-Null
$sb.AppendLine("---- RESOURCES ---------------------------------------------") | Out-Null
$sb.AppendLine((KV "CpuLoadPct" $cpu.LoadPercentage)) | Out-Null
$sb.AppendLine((KV "MemTotalGB" $memTotalGB)) | Out-Null
$sb.AppendLine((KV "MemFreeGB"  $memFreeGB)) | Out-Null
$sb.AppendLine((KV "MemUsedPct" $memUsedPct)) | Out-Null

$sb.AppendLine("") | Out-Null
$sb.AppendLine("Disk summary:") | Out-Null
foreach ($d in ($disks | Sort-Object FreePct)) {
  $sb.AppendLine(("  {0,3}  SizeGB={1,8}  FreeGB={2,8}  FreePct={3,6}" -f $d.DeviceID, $d.SizeGB, $d.FreeGB, $d.FreePct)) | Out-Null
}
$minFree = ($disks | Measure-Object -Property FreePct -Minimum).Minimum

# ---- Pending reboot
$pr = Get-PendingReboot
$sb.AppendLine("") | Out-Null
$sb.AppendLine("---- PENDING REBOOT ----------------------------------------") | Out-Null
$sb.AppendLine((KV "PendingReboot" $pr.PendingReboot)) | Out-Null
$sb.AppendLine((KV "CBS_RebootPending" $pr.CBS_RebootPending)) | Out-Null
$sb.AppendLine((KV "WU_RebootRequired" $pr.WU_RebootRequired)) | Out-Null
$sb.AppendLine((KV "PendingFileRenameOps" $pr.PendingFileRenameOperations)) | Out-Null
$sb.AppendLine((KV "CCM_RebootPending" $pr.CCMClientRebootPending)) | Out-Null

# ---- Services auto stopped (unexpected)
$autoStopped = Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' } |
  Select-Object -First 80 Name, Status, StartType
$sb.AppendLine("") | Out-Null
$sb.AppendLine("---- SERVICES (Automatic but not Running) -------------------") | Out-Null
$sb.AppendLine((KV "AutoStoppedCount" $autoStopped.Count)) | Out-Null
foreach ($s in $autoStopped) {
  $sb.AppendLine(("  {0,-40} {1,-10} {2}" -f $s.Name, $s.Status, $s.StartType)) | Out-Null
}

# ---- Hyper-V core checks
$sb.AppendLine("") | Out-Null
$sb.AppendLine("---- HYPER-V CHECKS ----------------------------------------") | Out-Null

$vmms = Get-Service vmms -ErrorAction SilentlyContinue
$sb.AppendLine((KV "VMMS_Status" ($(if($vmms){$vmms.Status}else{"UNKNOWN"})))) | Out-Null

$vmCount = $null
$vmNotRunning = @()
$snapCount = $null
$snapList = @()

if (Get-Command Get-VM -ErrorAction SilentlyContinue) {
  try {
    $vms = Get-VM
    $vmCount = $vms.Count
    $sb.AppendLine((KV "VM_Count" $vmCount)) | Out-Null

    $nr = $vms | Where-Object { $_.State -ne "Running" }
    $vmNotRunning = @($nr | Select-Object -ExpandProperty Name)
    $sb.AppendLine((KV "VM_NotRunning_Count" $vmNotRunning.Count)) | Out-Null

    $sb.AppendLine("VM list (top 50):") | Out-Null
    foreach ($v in ($vms | Sort-Object Name | Select-Object -First 50)) {
      $sb.AppendLine(("  {0,-35} State={1,-10} Status={2}" -f $v.Name, $v.State, $v.Status)) | Out-Null
    }

    if (Get-Command Get-VMSnapshot -ErrorAction SilentlyContinue) {
      $sn = Get-VMSnapshot -ErrorAction SilentlyContinue
      $snapCount = $sn.Count
      $sb.AppendLine((KV "Snapshot_Count" $snapCount)) | Out-Null
      $snapList = @($sn | Select-Object VMName, Name, CreationTime)
      if ($snapCount -gt 0) {
        $sb.AppendLine("Snapshots (top 50):") | Out-Null
        foreach ($s in ($sn | Sort-Object CreationTime -Descending | Select-Object -First 50)) {
          $sb.AppendLine(("  VM={0,-30} Snap={1,-30} Created={2}" -f $s.VMName, $s.Name, $s.CreationTime)) | Out-Null
        }
      }
    } else {
      $sb.AppendLine("Get-VMSnapshot not available (ok).") | Out-Null
    }
  } catch {
    $sb.AppendLine(("Hyper-V cmdlets failed: {0}" -f $_.Exception.Message)) | Out-Null
  }
} else {
  $sb.AppendLine("Hyper-V module/cmdlets not available (Get-VM missing).") | Out-Null
}

# ---- Hyper-V event logs (Admin channels)
$sb.AppendLine("") | Out-Null
$sb.AppendLine("---- EVENT LOGS (Hyper-V + System/Application) -------------") | Out-Null
$start = (Get-Date).AddHours(-[math]::Abs($EventHours))

function Add-EventBlock([string]$logName, [string]$label) {
  try {
    $ev = Get-WinEvent -FilterHashtable @{LogName=$logName; StartTime=$start } -ErrorAction SilentlyContinue |
      Where-Object { $_.LevelDisplayName -in 'Error','Critical','Warning' } |
      Select-Object -First $MaxEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message
    $sb.AppendLine((KV $label $ev.Count)) | Out-Null
    foreach ($e in $ev) {
      $msg = ($e.Message -replace "\s+"," ").Trim()
      if ($msg.Length -gt 200) { $msg = $msg.Substring(0,200) + "..." }
      $sb.AppendLine(("  {0} ID={1} {2} {3}" -f $e.TimeCreated, $e.Id, $e.LevelDisplayName, $msg)) | Out-Null
    }
    $sb.AppendLine("") | Out-Null
    return $ev.Count
  } catch {
    $sb.AppendLine((KV $label "N/A")) | Out-Null
    $sb.AppendLine("") | Out-Null
    return $null
  }
}

$hvVmmsCount  = Add-EventBlock "Microsoft-Windows-Hyper-V-VMMS/Admin"   "HV-VMMS(Admin) Events"
$hvWorkCount  = Add-EventBlock "Microsoft-Windows-Hyper-V-Worker/Admin" "HV-Worker(Admin) Events"

# System/Application err/crit counts
try {
  $sysEv = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start } -ErrorAction SilentlyContinue |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First $MaxEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message
  $appEv = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$start } -ErrorAction SilentlyContinue |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First $MaxEvents TimeCreated, Id, ProviderName, LevelDisplayName, Message
  $sysCnt = $sysEv.Count
  $appCnt = $appEv.Count
  $sb.AppendLine((KV "SystemErrCritCount" $sysCnt)) | Out-Null
  $sb.AppendLine((KV "AppErrCritCount" $appCnt)) | Out-Null
} catch {
  $sysCnt = $null; $appCnt = $null
  $sb.AppendLine("System/Application event read failed.") | Out-Null
}

# ---- GO/NO-GO
$reasons = @()

if ($pr.PendingReboot) { $reasons += "PendingReboot=TRUE" }
if ($minFree -lt $MinDiskFreePctNoGo) { $reasons += "DiskMinFreePct<$MinDiskFreePctNoGo (=$minFree)" }
if (-not $vmms -or $vmms.Status -ne "Running") { $reasons += "VMMS_NotRunning" }

if ($vmNotRunning -and $vmNotRunning.Count -gt $MaxVmNotRunningNoGo) {
  $reasons += ("VM_NotRunning_Count>{0} (={1})" -f $MaxVmNotRunningNoGo, $vmNotRunning.Count)
}

if ($snapCount -ne $null -and $snapCount -gt 0 -and $TreatSnapshotsAsNoGo) {
  $reasons += ("SnapshotsPresent (={0})" -f $snapCount)
}

# Hyper-V admin events are WARN by default; you can treat as NO-GO if you want:
# if (($hvVmmsCount -gt 0) -or ($hvWorkCount -gt 0)) { $reasons += "HyperV_AdminEventsPresent" }

$status = if ($reasons.Count -gt 0) { "NO-GO" } else { "GO" }

$sb.AppendLine("") | Out-Null
$sb.AppendLine("---- SUMMARY (GO / NO-GO) -----------------------------------") | Out-Null
$sb.AppendLine((KV "Status" $status)) | Out-Null
$sb.AppendLine((KV "Reasons" ($(if($reasons.Count){$reasons -join " | "}else{"(none)"})))) | Out-Null
$sb.AppendLine((KV "DiskMinFreePct" $minFree)) | Out-Null
$sb.AppendLine((KV "PendingReboot" $pr.PendingReboot)) | Out-Null
$sb.AppendLine((KV "VM_Count" $vmCount)) | Out-Null
$sb.AppendLine((KV "VM_NotRunning_Count" ($vmNotRunning.Count))) | Out-Null
$sb.AppendLine((KV "Snapshot_Count" $snapCount)) | Out-Null
$sb.AppendLine("============================================================") | Out-Null

# write report
$sb.ToString() | Out-File -FilePath $report -Encoding ascii

# write json summary
$summary = [pscustomobject]@{
  ComputerName = $srv
  Timestamp    = $ts
  Role         = "HyperV"
  Status       = $status
  Reasons      = $reasons
  LastBoot     = $os.LastBootUpTime
  UptimeHours  = [math]::Round($uptime.TotalHours,2)
  PendingReboot = [bool]$pr.PendingReboot
  DiskMinFreePct = $minFree
  VMMS_Status  = $(if($vmms){$vmms.Status.ToString()}else{"UNKNOWN"})
  VM_Count     = $vmCount
  VM_NotRunning = $vmNotRunning
  Snapshot_Count = $snapCount
  ReportPath   = $report
  OutputFolder = $root
}
$summary | ConvertTo-Json -Depth 6 | Out-File -FilePath $json -Encoding utf8

"HyperV PRECHECK done. Report: $report"
"Output folder: $root"