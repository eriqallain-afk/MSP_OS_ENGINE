param(
  [string]$TicketID = "TBD"
)

$ts = Get-Date -Format "yyyyMMdd_HHmm"
$root = "C:\IT_LOGS\DIAG"
New-Item -Path $root -ItemType Directory -Force | Out-Null
$log = Join-Path $root ("DIAG_{0}_{1}_{2}.log" -f $env:COMPUTERNAME,$TicketID,$ts)

Start-Transcript -Path $log -Force

Write-Host "=== CONTEXT ==="
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
[pscustomobject]@{
  Hostname   = $env:COMPUTERNAME
  Domain     = $cs.Domain
  OS         = $os.Caption
  LastBoot   = $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")
  UptimeDays = [math]::Round(((Get-Date)-$os.LastBootUpTime).TotalDays,2)
} | Format-List

Write-Host "`n=== CPU (samples) ==="

function Get-TotalCpuPct {
  try {
    # Plus précis si dispo
    return (Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'").PercentProcessorTime
  } catch {
    # Fallback ultra compatible
    $avg = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    return [int]([math]::Round($avg,0))
  }
}

$cpuSamples = @()
1..5 | ForEach-Object {
  $cpuSamples += (Get-TotalCpuPct)
  Start-Sleep -Seconds 2
}
$avgCpu = [math]::Round((($cpuSamples | Measure-Object -Average).Average),1)
"CPU Avg (5 samples): $avgCpu %" | Write-Host
"CPU Samples: $($cpuSamples -join ', ')" | Write-Host

Write-Host "`n=== TOP Processes (PerfFormattedData) ==="
$top = Get-CimInstance Win32_PerfFormattedData_PerfProc_Process |
  Where-Object { $_.Name -notmatch 'Idle|_Total' } |
  Sort-Object PercentProcessorTime -Descending |
  Select-Object -First 15 Name,IDProcess,PercentProcessorTime,WorkingSet,PrivateBytes

$top | Format-Table -AutoSize

Write-Host "`n=== TOP Processes details (path/command line) ==="
$top | ForEach-Object {
  $procId = $_.IDProcess
  $p = Get-CimInstance Win32_Process -Filter "ProcessId=$procId" -ErrorAction SilentlyContinue
  if($p){
    [pscustomobject]@{
      Name    = $_.Name
      ProcId  = $procId
      CPU_Pct = $_.PercentProcessorTime
      Path    = $p.ExecutablePath
      CmdLine = ($p.CommandLine | Select-Object -First 1)
    }
  }
} | Format-List

Write-Host "`n=== Services Auto STOPPED ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'} |
  Select-Object Name,Status,StartType | Format-Table -AutoSize

Write-Host "`n=== Windows Update / Defender quick status ==="
Get-Service wuauserv,UsoSvc,BITS -ErrorAction SilentlyContinue |
  Select-Object Name,Status,StartType | Format-Table -AutoSize

if(Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue){
  Get-MpComputerStatus | Select-Object AMServiceEnabled,AntispywareEnabled,AntivirusEnabled,RealTimeProtectionEnabled,QuickScanAge,FullScanAge | Format-List
} else {
  "Get-MpComputerStatus not available (Defender module missing or not Defender-managed)." | Write-Host
}

Write-Host "`n=== Pending reboot check ==="
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -EA SilentlyContinue)
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOps=$PFR} | Format-List

Write-Host "`n=== Event Logs (last 2 hours) - System/Application/Directory Service/DNS/DFSR ==="
$start = (Get-Date).AddHours(-2)
$logs = @("System","Application","Directory Service","DNS Server","DFS Replication")
foreach($ln in $logs){
  Write-Host "`n--- $ln (Errors) ---"
  try{
    Get-WinEvent -FilterHashtable @{LogName=$ln; Level=2; StartTime=$start} -MaxEvents 30 |
      Select-Object TimeCreated,Id,ProviderName,Message |
      Format-Table -Wrap
  } catch {
    "Log not accessible or not present: $ln" | Write-Host
  }
}

Write-Host "`n=== Security quick check (last 30 min): 4625/4768/4769 counts + top sources ==="
$secStart = (Get-Date).AddMinutes(-30)
$ids = @(4625,4768,4769)
foreach($id in $ids){
  try{
    $ev = Get-WinEvent -FilterHashtable @{LogName="Security"; Id=$id; StartTime=$secStart} -ErrorAction Stop
    "EventID ${id} count (30m): $($ev.Count)" | Write-Host
  } catch {
    "EventID ${id}: unable to query (permissions/log size)." | Write-Host
  }
}

# If 4625 exists, attempt parse IpAddress
try{
  $ev4625 = Get-WinEvent -FilterHashtable @{LogName="Security"; Id=4625; StartTime=$secStart} -MaxEvents 200 -ErrorAction Stop
  $ips = foreach($e in $ev4625){
    $x = [xml]$e.ToXml()
    ($x.Event.EventData.Data | Where-Object {$_.Name -eq "IpAddress"})."#text"
  }
  $ips | Where-Object { $_ -and $_ -notin @("-", "::1","127.0.0.1") } |
    Group-Object | Sort-Object Count -Descending | Select-Object -First 10 Count,Name |
    Format-Table -AutoSize
} catch {}

Write-Host "`n=== AD Replication summary ==="
try { repadmin /replsummary } catch { "repadmin failed" | Write-Host }
try { repadmin /showrepl } catch { "repadmin showrepl failed" | Write-Host }

Write-Host "`n=== DNS quick resolution test (local server) ==="
try{
  Resolve-DnsName -Name "google.com" -Server "127.0.0.1" -ErrorAction Stop | Select-Object -First 1 | Format-List
} catch {
  "Resolve-DnsName failed via 127.0.0.1 (DNS service issue possible)." | Write-Host
}

Stop-Transcript
Write-Host "`nDONE. Log file: $log"