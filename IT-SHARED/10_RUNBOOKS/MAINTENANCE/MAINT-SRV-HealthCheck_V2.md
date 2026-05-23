# MAINT-SRV-HealthCheck_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** MAINT | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__Server_Health_Check_V1
**Version :** 1.0 | **Agents :** IT-MaintenanceMaster, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** MAINTENANCE — Santé serveur
**Mis à jour :** 2026-03-20

---

## 1. SCRIPT HEALTH CHECK COMPLET

```powershell
#Requires -Version 5.1
# ============================================================
# Script  : AUDIT_HealthCheck_Server_v1.ps1
# Desc    : Health check serveur Windows complet
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Server  = $env:COMPUTERNAME
$DateTag = Get-Date -Format "yyyyMMdd_HHmm"
$LogDir  = "C:\IT_LOGS\AUDIT"
$LogFile = "$LogDir\AUDIT_HealthCheck_${Server}_${DateTag}.log"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
Start-Transcript -Path $LogFile

function Mask-IP { param([string]$Text)
    $Text = [regex]::Replace($Text, '\b(\d{1,3}\.){3}\d{1,3}\b', '[IP]')
    return $Text
}

Write-Host "=== HOSTNAME / OS ===" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    OS          = $os.Caption
    Version     = $os.Version
    LastReboot  = $os.LastBootUpTime
    Uptime_Days = [math]::Round(((Get-Date)-$os.LastBootUpTime).TotalDays,1)
} | Format-List

Write-Host "=== CPU ===" -ForegroundColor Cyan
Get-CimInstance Win32_Processor | Select-Object Name,
    @{N='Cores';E={$_.NumberOfCores}},
    @{N='Load%';E={$_.LoadPercentage}} | Format-Table -AutoSize

Write-Host "=== MÉMOIRE ===" -ForegroundColor Cyan
$os | Select-Object @{N='RAM_Total_GB';E={[math]::Round($_.TotalVisibleMemorySize/1MB,1)}},
    @{N='RAM_Free_GB';E={[math]::Round($_.FreePhysicalMemory/1MB,1)}},
    @{N='RAM_Used%';E={[math]::Round(($_.TotalVisibleMemorySize-$_.FreePhysicalMemory)/$_.TotalVisibleMemorySize*100,0)}} | Format-List

Write-Host "=== DISQUES ===" -ForegroundColor Cyan
Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} |
    Select-Object Name,
        @{N='Total_GB';E={[math]::Round(($_.Used+$_.Free)/1GB,1)}},
        @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
        @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} | Format-Table -AutoSize

Write-Host "=== PENDING REBOOT ===" -ForegroundColor Cyan
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -EA SilentlyContinue)
[pscustomobject]@{ CBS=$CBS; WU=$WU; PendingFileRename=$PFR; PendingReboot=($CBS -or $WU -or $PFR) } | Format-List

Write-Host "=== SERVICES CRITIQUES ===" -ForegroundColor Cyan
$CriticalServices = @(
    'Winmgmt','W32Time','Netlogon','DNS','NTDS',    # Base + DC
    'MSSQLSERVER','SQLSERVERAGENT',                  # SQL
    'W3SVC','WAS',                                   # IIS
    'TermService',                                   # RDS
    'wuauserv'                                       # Windows Update
)
Get-Service $CriticalServices -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType | Format-Table -AutoSize

Write-Host "=== WINDOWS UPDATE — DERNIÈRE INSTALLATION ===" -ForegroundColor Cyan
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 Description, HotFixID, InstalledOn | Format-Table

Write-Host "=== EVENTLOG SYSTEM — ERREURS (48h) ===" -ForegroundColor Cyan
$start = (Get-Date).AddHours(-48)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start; Level=1,2} -EA SilentlyContinue |
    Select-Object -First 30 TimeCreated, Id, ProviderName,
        @{N='Message';E={(Mask-IP $_.Message).Substring(0,[Math]::Min(200,$_.Message.Length))}} |
    Format-Table -Wrap

Write-Host "=== EVENTLOG APPLICATION — ERREURS (48h) ===" -ForegroundColor Cyan
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$start; Level=1,2} -EA SilentlyContinue |
    Select-Object -First 20 TimeCreated, Id, ProviderName,
        @{N='Message';E={(Mask-IP $_.Message).Substring(0,[Math]::Min(200,$_.Message.Length))}} |
    Format-Table -Wrap

Write-Host "=== INTERFACES RÉSEAU ===" -ForegroundColor Cyan
Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} |
    Select-Object Name, Status, LinkSpeed, MacAddress | Format-Table -AutoSize

Write-Host "[OK] Health check terminé. Log: $LogFile" -ForegroundColor Green
Stop-Transcript
```

---

## 2. INTERPRÉTATION DES RÉSULTATS

### Seuils d'alerte

| Indicateur | Normal | Attention | Critique |
|---|---|---|---|
| CPU | < 70% | 70-90% | > 90% |
| RAM libre | > 20% | 10-20% | < 10% |
| Disque C: libre | > 20% | 10-20% | < 10% |
| Uptime | < 90 jours | 90-180 jours | > 180 jours |
| Pending reboot | False | — | True depuis > 7 jours |

### Actions selon résultats

**CPU > 90% :**
```powershell
# Identifier le processus gourmand
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet
```

**RAM < 10% libre :**
```powershell
# Identifier les processus consommateurs de RAM
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name,
    @{N='RAM_MB';E={[math]::Round($_.WorkingSet/1MB,0)}}
```

**Disque critique :**
```powershell
# Top 20 dossiers les plus lourds
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue |
    Where-Object {-not $_.PSIsContainer} |
    Sort-Object Length -Descending | Select-Object -First 20 FullName,
    @{N='Size_MB';E={[math]::Round($_.Length/1MB,1)}}
```

---

## 3. ESCALADE

| Indicateur critique | Département | Délai |
|---|---|---|
| CPU > 90% persistant > 15 min | NOC | 30 min |
| Disque C: < 5% | NOC + INFRA | Dans l'heure |
| Service critique arrêté | NOC | 15 min |
| Erreurs critiques répétées Event Log | INFRA | Dans l'heure |
