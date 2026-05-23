#Requires -Version 5.1
# ============================================================
# Script  : SCRIPT_BACKUP_Veeam-JobStatus_V1.ps1
# Desc    : Vérification journalière des jobs Veeam
#           Statut, espace repository, snapshots
# Usage   : .\SCRIPT_BACKUP_Veeam-JobStatus_V1.ps1
#           Requiert : module Veeam.Backup.PowerShell
# ============================================================
[CmdletBinding()]
param(
    [string]$Ticket  = "T00000",
    [string]$OutDir  = "C:\IT_LOGS\BACKUP",
    [int]$FreePctMin = 20   # Seuil alerte espace libre (%)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Server  = $env:COMPUTERNAME
$DateTag = Get-Date -Format "yyyyMMdd_HHmm"
$LogFile = "$OutDir\BACKUP_VeeamStatus_${Server}_${Ticket}_${DateTag}.log"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
Start-Transcript -Path $LogFile

function Write-Section($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }

try {
    Write-Host "VEEAM JOB STATUS — $Server — $Ticket — $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Green

    # ── Module Veeam ──────────────────────────────────────
    if (-not (Get-Module Veeam.Backup.PowerShell -EA SilentlyContinue)) {
        Import-Module "C:\Program Files\Veeam\Backup and Replication\Console\Veeam.Backup.PowerShell.dll" -EA Stop
    }
    Connect-VBRServer -Server localhost

    # ── Service Veeam ─────────────────────────────────────
    Write-Section "SERVICE VEEAM"
    Get-Service VeeamBackupSvc -EA SilentlyContinue |
        Select-Object Name, Status, StartType | Format-Table -AutoSize

    # ── Statut derniers jobs ───────────────────────────────
    Write-Section "STATUT JOBS (dernière session)"
    $jobs = Get-VBRJob
    $noGo = $false
    foreach ($job in $jobs) {
        $lastSession = $job.FindLastSession()
        if ($lastSession) {
            $result = $lastSession.Result
            $color  = switch ($result) {
                "Success" { "Green" }
                "Warning" { "Yellow" }
                default   { "Red"; $noGo = $true }
            }
            Write-Host ("  [{0,-8}] {1,-40} | {2}" -f $result, $job.Name,
                $lastSession.EndTime.ToString('yyyy-MM-dd HH:mm')) -ForegroundColor $color
        } else {
            Write-Host ("  [NO_SESS] {0}" -f $job.Name) -ForegroundColor Gray
        }
    }

    # ── Repositories — espace libre ───────────────────────
    Write-Section "REPOSITORIES — ESPACE"
    $repos = Get-VBRBackupRepository
    foreach ($repo in $repos) {
        $total = [math]::Round($repo.Info.CachedTotalSpace/1GB,1)
        $free  = [math]::Round($repo.Info.CachedFreeSpace/1GB,1)
        $pct   = if ($total -gt 0) { [math]::Round($free/$total*100,0) } else { 0 }
        $color = if ($pct -lt 10) { "Red"; $noGo = $true } elseif ($pct -lt $FreePctMin) { "Yellow" } else { "Green" }
        Write-Host ("  {0,-35} | Free: {1,6} GB / {2,6} GB ({3}%)" -f $repo.Name, $free, $total, $pct) -ForegroundColor $color
    }

    # ── Snapshots existants ───────────────────────────────
    Write-Section "SNAPSHOTS EN COURS"
    $snaps = Get-VBRRestorePoint | Where-Object {$_.Name -match "SNAP|snap"}
    if ($snaps) {
        $snaps | Select-Object Name, CreationTime,
            @{N='Age_Jours';E={[math]::Round(((Get-Date)-$_.CreationTime).TotalDays,0)}} |
            Sort-Object Age_Jours -Descending | Format-Table -AutoSize
    } else {
        Write-Host "Aucun snapshot détecté." -ForegroundColor Green
    }

    # ── Résumé GO / NO-GO ─────────────────────────────────
    Write-Section "RÉSUMÉ"
    if ($noGo) {
        Write-Host "⚠️  NO-GO — Jobs en échec ou espace critique détecté" -ForegroundColor Red
    } else {
        Write-Host "✅ GO — Tous les jobs OK et espace suffisant" -ForegroundColor Green
    }

    Write-Host "`n[OK] Vérification Veeam terminée. Log : $LogFile" -ForegroundColor Green
}
catch {
    Write-Host "[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[STACK] $($_.ScriptStackTrace)" -ForegroundColor DarkRed
}
finally {
    try { Disconnect-VBRServer -EA SilentlyContinue } catch {}
    Stop-Transcript
}
