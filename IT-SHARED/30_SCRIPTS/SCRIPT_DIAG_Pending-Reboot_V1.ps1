#Requires -Version 5.1
# ============================================================
# Script  : SCRIPT_DIAG_Pending-Reboot_V1.ps1
# Desc    : Vérification complète des flags Pending Reboot Windows
#           Fusion de : DIAGNOSTIC_FLAGS, DIAGNOSTIC_PENDING-REBOOT, Deep_Check
# Usage   : Exécuter localement ou via CW RMM sur le serveur cible
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Server  = $env:COMPUTERNAME
$DateTag = Get-Date -Format "yyyyMMdd_HHmm"
$LogDir  = "C:\IT_LOGS\DIAG"
$LogFile = "$LogDir\DIAG_PendingReboot_${Server}_${DateTag}.log"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
Start-Transcript -Path $LogFile -Append

Write-Host "=== PENDING REBOOT — $Server — $(Get-Date -Format 'yyyy-MM-dd HH:mm') ===" -ForegroundColor Cyan

try {
    # ── Flags registre ──────────────────────────────────────
    $flags = [ordered]@{
        CBS_RebootPending    = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending')
        WU_RebootRequired    = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
        CCM_RebootPending    = (Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending')
        UpdateExeVolatile    = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Updates\UpdateExeVolatile')
        Installer_InProgress = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress')
        Installer_RebootReq  = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\RebootRequired')
        Pending_xml_exists   = (Test-Path 'C:\Windows\WinSxS\pending.xml')
    }

    # PendingFileRenameOperations
    $pfr = $null
    try {
        $p = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
            -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
        if ($p) { $pfr = $p.PendingFileRenameOperations }
    } catch {}
    $flags['PendingFileRenameOps'] = [bool]$pfr

    $flags.GetEnumerator() | Sort-Object Name | Format-Table Name, Value -AutoSize

    # ── Résumé GO / NO-GO ────────────────────────────────────
    $pendingReboot = $flags.Values -contains $true
    if ($pendingReboot) {
        Write-Host "⚠️  PENDING REBOOT : TRUE — Un reboot est en attente." -ForegroundColor Yellow
        Write-Host "   Sources actives :"
        $flags.GetEnumerator() | Where-Object {$_.Value -eq $true} |
            ForEach-Object { Write-Host "   → $($_.Name)" -ForegroundColor Yellow }
    } else {
        Write-Host "✅ PENDING REBOOT : FALSE — Aucun reboot en attente." -ForegroundColor Green
    }

    # ── Dernier reboot ───────────────────────────────────────
    Write-Host "`n=== DERNIER REBOOT ===" -ForegroundColor Cyan
    $lastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $uptime   = ((Get-Date) - $lastBoot).TotalDays
    [pscustomobject]@{
        LastBoot   = $lastBoot.ToString('yyyy-MM-dd HH:mm')
        Uptime_Days = [math]::Round($uptime, 1)
    } | Format-List

    # ── Sessions actives (impact reboot) ─────────────────────
    Write-Host "=== SESSIONS ACTIVES ===" -ForegroundColor Cyan
    try { query user 2>$null } catch { Write-Host "N/A" }
}
catch {
    Write-Host "[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Host "=== Fin : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan
    Write-Host "Log : $LogFile"
    Stop-Transcript
}
