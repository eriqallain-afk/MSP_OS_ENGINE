Write-Host "=== POST-BOOT VALIDATION ===" -ForegroundColor Cyan

# Boot time (vérifie que ça a bien rebooté récemment)
systeminfo | findstr /i "Boot Time"

# Pending reboot
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -EA SilentlyContinue)
[pscustomobject]@{CBS=$CBS; WU=$WU; PendingFileRename=$PFR; PendingAny=($CBS -or $WU -or $PFR)} | Format-List

# Disque C:
Get-PSDrive C | Format-Table -AutoSize

# SQL services
Get-Service | Where-Object {
  $_.Name -match '^MSSQL' -or $_.Name -match '^SQLAgent' -or $_.Name -in 'SQLBrowser','SQLWriter'
} | Select Name,Status,StartType | Sort Name | Format-Table -AutoSize