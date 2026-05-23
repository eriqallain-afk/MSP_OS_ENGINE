#Requires -Version 5.1
# ============================================================
# Script  : SCRIPT_AUDIT_AD-Health_V1.ps1
# Desc    : Audit santé Active Directory — lecture seule
#           Réplication, FSMO, services, comptes inactifs
# Usage   : .\SCRIPT_AUDIT_AD-Health_V1.ps1
#           .\SCRIPT_AUDIT_AD-Health_V1.ps1 -Ticket "T12345" -InactiveDays 90
# ============================================================
[CmdletBinding()]
param(
    [string]$Ticket      = "T00000",
    [int]$InactiveDays   = 90,
    [string]$OutDir      = "C:\IT_LOGS\AUDIT"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Server  = $env:COMPUTERNAME
$DateTag = Get-Date -Format "yyyyMMdd_HHmm"
$LogFile = "$OutDir\AUDIT_AD_${Server}_${Ticket}_${DateTag}.log"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
Start-Transcript -Path $LogFile

function Write-Section($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }

try {
    Write-Host "AUDIT AD — $Server — $Ticket — $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Green

    Write-Section "SERVICES DC"
    Get-Service NTDS,DNS,Netlogon,KDC,W32Time -EA SilentlyContinue |
        Select-Object Name, Status, StartType | Format-Table -AutoSize

    Write-Section "SYSVOL / NETLOGON"
    net share 2>$null | Select-String "SYSVOL|NETLOGON"

    Write-Section "RÔLES FSMO"
    netdom query fsmo 2>$null

    Write-Section "RÉPLICATION AD"
    repadmin /replsummary 2>$null

    Write-Section "ERREURS RÉPLICATION"
    repadmin /showrepl 2>$null | Select-String -Pattern "error|fail|Last attempt|Last success" |
        Select-Object -First 30 | ForEach-Object { $_.Line }

    Write-Section "DCDIAG (erreurs uniquement)"
    $dcdiag = dcdiag /q 2>&1
    if ($dcdiag) { $dcdiag } else { Write-Host "Aucune erreur dcdiag." -ForegroundColor Green }

    Write-Section "SYNCHRONISATION HEURE"
    w32tm /query /status 2>$null

    Write-Section "COMPTES INACTIFS ($InactiveDays jours)"
    try {
        Search-ADAccount -AccountInactive -TimeSpan (New-TimeSpan -Days $InactiveDays) -UsersOnly |
            Where-Object {$_.Enabled} |
            Get-ADUser -Properties LastLogonDate,Department |
            Select-Object Name, SamAccountName, LastLogonDate, Department |
            Sort-Object LastLogonDate | Format-Table -AutoSize
    } catch { Write-Host "Module AD non disponible sur ce serveur." -ForegroundColor Yellow }

    Write-Section "COMPTES ADMIN DOMAINE"
    try {
        Get-ADGroupMember "Domain Admins" |
            Get-ADUser -Properties LastLogonDate, Enabled |
            Select-Object Name, SamAccountName, Enabled, LastLogonDate | Format-Table -AutoSize
    } catch { Write-Host "Module AD non disponible." -ForegroundColor Yellow }

    Write-Section "EVENT LOG Directory Service (24h)"
    $start = (Get-Date).AddHours(-24)
    Get-WinEvent -FilterHashtable @{LogName='Directory Service'; StartTime=$start; Level=1,2} -EA SilentlyContinue |
        Select-Object -First 20 TimeCreated, Id, Message | Format-List

    Write-Host "`n[OK] Audit AD terminé. Log : $LogFile" -ForegroundColor Green
}
catch {
    Write-Host "[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Stop-Transcript
}
