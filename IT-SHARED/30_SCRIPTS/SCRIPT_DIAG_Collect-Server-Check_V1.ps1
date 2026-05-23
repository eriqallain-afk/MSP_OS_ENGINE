<#!
.SYNOPSIS
  Collecte read-only (PRECHECK/POSTCHECK) pour un serveur Windows.

.DESCRIPTION
  - Aucun changement, aucune remédiation, aucun reboot.
  - Écrit les preuves dans des fichiers texte.

.PARAMETER ComputerName
  Nom du serveur (par défaut: localhost).

.PARAMETER Stage
  PRECHECK ou POSTCHECK.

.PARAMETER Role
  Generic | DC | SQL | PRINT

.PARAMETER OutDir
  Dossier de sortie.
#!>

[CmdletBinding()]
param(
  [string]$ComputerName = "localhost",
  [ValidateSet('PRECHECK','POSTCHECK')] [string]$Stage = 'PRECHECK',
  [ValidateSet('Generic','DC','SQL','PRINT')] [string]$Role = 'Generic',
  [string]$OutDir = "$env:TEMP\\IT_VALIDATIONS"
)

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
$Prefix = "$($ComputerName)_$($Role)_$($Stage)_$TS"

$log = Join-Path $OutDir "$Prefix.log"
Start-Transcript -Path $log -Append | Out-Null

"=== HOST ==="; hostname
"=== OS / UPTIME ==="; Get-CimInstance Win32_OperatingSystem | Select-Object CSName,Caption,Version,LastBootUpTime

"=== PENDING REBOOT (CBS/WU/FILE RENAME/CCM) ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== DISKS ==="; Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | Format-Table -Auto

"=== SERVICES (AUTO + NOT RUNNING) ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select-Object Name,Status,StartType | Format-Table -Auto

"=== EVENTLOG (System/Application) last 2h: Error/Critical ==="
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap

switch ($Role) {
  'DC' {
    "=== DC: SERVICES ==="; Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Format-Table Name,Status,StartType
    "=== DC: SYSVOL/NETLOGON ==="; cmd /c "net share | findstr /I \"SYSVOL NETLOGON\""
    "=== DC: REPLSUMMARY ==="; cmd /c "repadmin /replsummary"
  }
  'SQL' {
    "=== SQL: SERVICES ==="; Get-Service | Where-Object {$_.Name -match '^MSSQL' -or $_.Name -match '^SQL'} | Sort-Object Name | Format-Table Name,Status,StartType
  }
  'PRINT' {
    "=== PRINT: SPOOLER ==="; Get-Service Spooler | Format-Table Name,Status,StartType
  }
}

Stop-Transcript | Out-Null
"Saved: $log"
