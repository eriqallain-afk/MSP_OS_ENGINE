<#
SQL02_HEALTH_AND_UPDATES.ps1
Usage:
  .\SQL02_HEALTH_AND_UPDATES.ps1
Optional:
  .\SQL02_HEALTH_AND_UPDATES.ps1 -Days 180 -MaxUpdates 30 -OutDir "C:\Windows\Temp\CW_Reboot"
#>

[CmdletBinding()]
param(
  [int]$Days = 120,
  [int]$MaxUpdates = 25,
  [string]$OutDir = "$env:WINDIR\Temp\CW_Reboot"
)

function Write-Section($t){ Write-Host "`n=== $t ===" -ForegroundColor Cyan }

# --- Prepare transcript
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS  = Get-Date -Format "yyyyMMdd_HHmmss"
$Log = Join-Path $OutDir "SQL02_STANDARD_PLUS_UPDATES_$($env:COMPUTERNAME)_$TS.log"
Start-Transcript -Path $Log -Append | Out-Null

Write-Section "HOST / TIME"
Write-Host "ComputerName: $env:COMPUTERNAME"
Get-Date

Write-Section "OS / UPTIME / BUILD (UBR)"
$os = Get-CimInstance Win32_OperatingSystem
$cv = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
[pscustomobject]@{
  Caption        = $os.Caption
  Version        = $os.Version
  BuildNumber    = $cv.CurrentBuildNumber
  UBR            = $cv.UBR
  DisplayVersion = $cv.DisplayVersion
  LastBootUpTime = $os.LastBootUpTime
  Uptime         = (New-TimeSpan -Start $os.LastBootUpTime -End (Get-Date)).ToString()
} | Format-List

Write-Section "PENDING REBOOT FLAGS (deep)"
$flags = [ordered]@{
  CBS_RebootPending    = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending')
  WU_RebootRequired    = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
  CCM_RebootPending    = (Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending')
  UpdateExeVolatile    = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Updates\UpdateExeVolatile')
  Installer_InProgress = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress')
  Installer_RebootReq  = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\RebootRequired')
  pending_xml_exists   = (Test-Path 'C:\Windows\WinSxS\pending.xml')
}
$pfr = $null
try { $pfr = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue).PendingFileRenameOperations } catch {}
$flags['PendingFileRenameOps'] = [bool]$pfr
$flags.GetEnumerator() | Sort-Object Name | Format-Table Name,Value -Auto

Write-Section "DISKS"
Get-PSDrive -PSProvider FileSystem |
  Select-Object Name,
    @{n='UsedGB';e={[math]::Round($_.Used/1GB,2)}},
    @{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}},
    @{n='Free%';e={ if(($_.Used+$_.Free) -gt 0){[math]::Round(($_.Free/($_.Used+$_.Free))*100,2)} else {0}}} |
  Sort-Object Name | Format-Table -Auto

Write-Section "SQL SERVICES"
Get-Service MSSQLSERVER,SQLSERVERAGENT -ErrorAction SilentlyContinue |
  Select Name,Status,StartType | Format-Table -Auto

# --- SQL queries via .NET (no SSMS required)
function Invoke-SqlQuery {
  param([string]$Server="localhost",[string]$Query,[int]$TimeoutSeconds=15)
  $connStr = "Server=$Server;Integrated Security=True;TrustServerCertificate=True;Connection Timeout=$TimeoutSeconds;"
  $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
  $cmd  = $conn.CreateCommand()
  $cmd.CommandTimeout = $TimeoutSeconds
  $cmd.CommandText = $Query
  try {
    $conn.Open()
    $da = New-Object System.Data.SqlClient.SqlDataAdapter $cmd
    $dt = New-Object System.Data.DataTable
    [void]$da.Fill($dt)
    return $dt
  } finally {
    if ($conn.State -eq "Open") { $conn.Close() }
    $conn.Dispose()
  }
}

Write-Section "SQL VERSION / START TIME"
try {
  $dt = Invoke-SqlQuery -Query @"
SET NOCOUNT ON;
SELECT @@SERVERNAME AS ServerName,
       SERVERPROPERTY('ProductVersion') AS ProductVersion,
       SERVERPROPERTY('ProductLevel') AS ProductLevel,
       SERVERPROPERTY('Edition') AS Edition;
SELECT sqlserver_start_time FROM sys.dm_os_sys_info;
"@
  $dt | Format-Table -Auto
} catch {
  Write-Host "SQL connectivity failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Section "DB STATE (non-ONLINE)"
try {
  $dt = Invoke-SqlQuery -Query @"
SET NOCOUNT ON;
SELECT name, state_desc, recovery_model_desc
FROM sys.databases
WHERE state_desc <> 'ONLINE'
ORDER BY name;
"@
  if ($dt.Rows.Count -gt 0) { $dt | Format-Table -Auto } else { Write-Host "All databases ONLINE." }
} catch {}

Write-Section "BACKUP/RESTORE IN PROGRESS (NO-GO if any)"
try {
  $dt = Invoke-SqlQuery -Query @"
SET NOCOUNT ON;
SELECT DB_NAME(database_id) AS DB,
       session_id, command, status, start_time, percent_complete
FROM sys.dm_exec_requests
WHERE command LIKE 'BACKUP%' OR command LIKE 'RESTORE%';
"@
  if ($dt.Rows.Count -gt 0) { $dt | Format-Table -Auto } else { Write-Host "No BACKUP/RESTORE running." }
} catch {}

Write-Section "SQL AGENT JOBS RUNNING (current agent session only)"
try {
  $dt = Invoke-SqlQuery -Query @"
;WITH s AS (SELECT MAX(session_id) AS session_id FROM msdb.dbo.syssessions)
SELECT j.name AS JobName, a.start_execution_date,
       DATEDIFF(MINUTE, a.start_execution_date, GETDATE()) AS runtime_min
FROM msdb.dbo.sysjobactivity a
JOIN s ON a.session_id = s.session_id
JOIN msdb.dbo.sysjobs j ON a.job_id = j.job_id
WHERE a.start_execution_date IS NOT NULL
  AND a.stop_execution_date IS NULL
ORDER BY a.start_execution_date;
"@
  if ($dt.Rows.Count -gt 0) { $dt | Format-Table -Auto } else { Write-Host "No SQL Agent jobs running." }
} catch {}

Write-Section "LATEST INSTALLED UPDATES (HotFix/QFE)"
try {
  Get-HotFix |
    Sort-Object InstalledOn -Descending |
    Select-Object -First $MaxUpdates HotFixID,InstalledOn,Description,InstalledBy |
    Format-Table -Auto
} catch {
  Write-Host "Get-HotFix failed: $($_.Exception.Message)"
}

Write-Section "LATEST INSTALLED PACKAGES (DISM) - last $Days days (raw)"
# DISM est souvent le plus fiable pour LCUs/SSUs, on affiche brut (pas de parsing fragile).
try {
  $since = (Get-Date).AddDays(-$Days).ToString("MM/dd/yyyy")
  Write-Host "Filtering hint: look for Installed packages after ~$since"
  dism /online /get-packages | Out-String | Write-Host
} catch {
  Write-Host "DISM /get-packages failed: $($_.Exception.Message)"
}

Write-Section "WINDOWS UPDATE FAILURES (last $Days days) - WindowsUpdateClient"
try {
  $start = (Get-Date).AddDays(-$Days)
  Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-WindowsUpdateClient'; StartTime=$start} -ErrorAction SilentlyContinue |
    Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
    Select-Object -First 20 TimeCreated,Id,Message |
    Format-Table -Wrap
} catch {}

Write-Section "WINDOWS UPDATE OPERATIONAL (last 200 events) - quick view"
try {
  Get-WinEvent -LogName "Microsoft-Windows-WindowsUpdateClient/Operational" -MaxEvents 200 -ErrorAction SilentlyContinue |
    Select TimeCreated,Id,LevelDisplayName,Message |
    Format-Table -Wrap
} catch {
  Write-Host "Operational log not accessible: $($_.Exception.Message)"
}

Write-Section "SERVICING PROCESSES (TiWorker / TrustedInstaller)"
Get-Process TiWorker,TrustedInstaller -ErrorAction SilentlyContinue |
  Select Name,Id,CPU,PM,StartTime |
  Format-Table -Auto
Get-Service TrustedInstaller -ErrorAction SilentlyContinue |
  Select Name,Status,StartType |
  Format-Table -Auto

Write-Section "DONE"
Stop-Transcript | Out-Null
Write-Host "Log saved to: $Log" -ForegroundColor Green