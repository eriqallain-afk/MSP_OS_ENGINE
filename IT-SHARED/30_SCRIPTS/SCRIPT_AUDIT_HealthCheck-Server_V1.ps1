#Requires -Version 5.1
# ============================================================
# Script  : SCRIPT_AUDIT_HealthCheck-Server_V1.ps1
# Desc    : Health check complet Windows Server — lecture seule
#           Output : TXT log + résumé console
# Usage   : .\SCRIPT_AUDIT_HealthCheck-Server_V1.ps1
#           .\SCRIPT_AUDIT_HealthCheck-Server_V1.ps1 -Ticket "T12345" -HoursEvents 4
# ============================================================
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Ticket      = "T00000",
    [int]$HoursEvents    = 24,
    [string]$OutDir      = "C:\IT_LOGS\AUDIT"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Server  = $env:COMPUTERNAME
$DateTag = Get-Date -Format "yyyyMMdd_HHmm"
$LogFile = "$OutDir\AUDIT_HC_${Server}_${Ticket}_${DateTag}.log"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
Start-Transcript -Path $LogFile

function Write-Section($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }
function Mask-IP($Text) {
    $t = [regex]::Replace($Text, '\b(\d{1,3}\.){3}\d{1,3}\b', '[IP]')
    return $t
}

try {
    Write-Host "HEALTH CHECK — $Server — $Ticket — $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Green

    # ── OS / Uptime ────────────────────────────────────────
    Write-Section "HOST / OS / UPTIME"
    $os = Get-CimInstance Win32_OperatingSystem
    [pscustomobject]@{
        Hostname    = $Server
        OS          = $os.Caption
        Version     = $os.Version
        LastBoot    = $os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm')
        Uptime_Days = [math]::Round(((Get-Date)-$os.LastBootUpTime).TotalDays,1)
    } | Format-List

    # ── CPU ────────────────────────────────────────────────
    Write-Section "CPU"
    Get-CimInstance Win32_Processor |
        Select-Object Name, NumberOfCores, @{N='Load%';E={$_.LoadPercentage}} | Format-Table -AutoSize

    # ── RAM ────────────────────────────────────────────────
    Write-Section "RAM"
    [pscustomobject]@{
        Total_GB = [math]::Round($os.TotalVisibleMemorySize/1MB,1)
        Free_GB  = [math]::Round($os.FreePhysicalMemory/1MB,1)
        Used_PCT = [math]::Round(($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/$os.TotalVisibleMemorySize*100,0)
    } | Format-List

    # ── DISQUES ────────────────────────────────────────────
    Write-Section "DISQUES"
    Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} |
        Select-Object Name,
            @{N='Total_GB';E={[math]::Round(($_.Used+$_.Free)/1GB,1)}},
            @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
            @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} |
        Format-Table -AutoSize

    # ── PENDING REBOOT ─────────────────────────────────────
    Write-Section "PENDING REBOOT"
    $CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    $WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    $PFR = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
        -Name PendingFileRenameOperations -EA SilentlyContinue)
    $pending = $CBS -or $WU -or $PFR
    [pscustomobject]@{CBS=$CBS; WU=$WU; PendingFileRename=$PFR; PendingReboot=$pending} | Format-List
    if ($pending) { Write-Host "⚠️  REBOOT EN ATTENTE" -ForegroundColor Yellow }

    # ── SERVICES AUTO ARRÊTÉS ──────────────────────────────
    Write-Section "SERVICES AUTO NON DÉMARRÉS"
    $stopped = Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'}
    if ($stopped) { $stopped | Select-Object Name, DisplayName | Format-Table -AutoSize }
    else { Write-Host "Aucun service Auto arrêté." -ForegroundColor Green }

    # ── PATCHS RÉCENTS ─────────────────────────────────────
    Write-Section "PATCHS INSTALLÉS (30 derniers jours)"
    Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-30)} |
        Sort-Object InstalledOn -Descending |
        Select-Object Description, HotFixID, InstalledOn | Format-Table -AutoSize

    # ── EVENT LOG ERREURS ──────────────────────────────────
    Write-Section "EVENT LOG — ERREURS/CRITIQUES ($HoursEvents h)"
    $start = (Get-Date).AddHours(-$HoursEvents)
    foreach ($log in @('System','Application')) {
        Write-Host "--- $log ---"
        $events = Get-WinEvent -FilterHashtable @{LogName=$log; StartTime=$start; Level=1,2} -EA SilentlyContinue |
            Select-Object -First 15 TimeCreated, Id, ProviderName,
                @{N='Msg';E={$m=$_.Message; if($m.Length -gt 150){$m.Substring(0,150)+'...'}else{$m}}}
        if ($events) { $events | Format-Table -Wrap }
        else { Write-Host "Aucune erreur." -ForegroundColor Green }
    }

    # ── RÉSEAU ─────────────────────────────────────────────
    Write-Section "INTERFACES RÉSEAU"
    Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} |
        Select-Object Name, Status, LinkSpeed | Format-Table -AutoSize

    Write-Host "`n[OK] Health check terminé. Log : $LogFile" -ForegroundColor Green
}
catch {
    Write-Host "[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[STACK] $($_.ScriptStackTrace)" -ForegroundColor DarkRed
}
finally {
    Stop-Transcript
}
