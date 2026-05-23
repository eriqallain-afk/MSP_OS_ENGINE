# MAINT-SRV-PrintServer_PrePost_V1
**Version :** 2.0 | **Date :** 2026-05-21 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** MAINT | **Source :** IT MSP Intelligence Platform

---

**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## PRECHECK — Avant reboot Print Server

> Script unique — lecture seule. Exécuter via RMM ou PSRemoting.

```powershell
# ============================================================
# PRECHECK PRINT SERVER — Avant reboot
# Impact  : Lecture seule
# Usage   : RMM ou PSRemoting — Out-String (compatible RMM)
# ============================================================
$Sep = "=" * 60

# ── 1. HOST / OS / UPTIME — OBLIGATOIRE ─────────────────────
Write-Host $Sep
Write-Host "  HOST / OS / UPTIME — OBLIGATOIRE"
Write-Host $Sep
$os     = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
[pscustomobject]@{
    Hostname   = $env:COMPUTERNAME
    LastBoot   = $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")
    Uptime     = "{0}j {1}h {2}min" -f [int]$uptime.TotalDays, $uptime.Hours, $uptime.Minutes
    UptimeDays = [math]::Round($uptime.TotalDays, 1)
} | Out-String -Width 300 | Write-Output
Write-Host "  ► Documenter LastBoot + Uptime dans le billet (valider en postcheck)" -ForegroundColor Cyan

# ── 2. PENDING REBOOT FLAGS ──────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  PENDING REBOOT FLAGS"
Write-Host $Sep
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -EA SilentlyContinue) -ne $null
[pscustomobject]@{ CBS=$CBS; WU=$WU; PendingFileRename=$PFR; RebootRequis=($CBS -or $WU -or $PFR) } | Out-String -Width 300 | Write-Output

# ── 3. SERVICE SPOOLER ───────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SERVICE SPOOLER"
Write-Host $Sep
$spooler = Get-Service Spooler -EA SilentlyContinue
if ($spooler) {
    $color = if ($spooler.Status -eq 'Running') { 'Green' } else { 'Red' }
    Write-Host "  Spooler : $($spooler.Status) / $($spooler.StartType)" -ForegroundColor $color
} else {
    Write-Host "  ⚠ Service Spooler non trouvé" -ForegroundColor Yellow
}

# ── 4. IMPRIMANTES + QUEUES ──────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  IMPRIMANTES PARTAGÉES + QUEUES"
Write-Host $Sep
try {
    $printers = Get-Printer -EA Stop
    $shared = $printers | Where-Object { $_.Shared -eq $true }
    Write-Host "  Total imprimantes : $($printers.Count) — Partagées : $($shared.Count)"
    $printers | Select-Object Name, Shared, PrinterStatus, DriverName |
        Sort-Object Name | Out-String -Width 300 | Write-Output

    # Jobs en cours dans les queues
    $allJobs = @()
    foreach ($p in $printers.Name) {
        $jobs = Get-PrintJob -PrinterName $p -EA SilentlyContinue
        if ($jobs) { $allJobs += $jobs }
    }
    if ($allJobs) {
        Write-Host "  ⚠ $($allJobs.Count) JOB(S) EN ATTENTE DANS LES QUEUES :" -ForegroundColor Yellow
        $allJobs | Select-Object Id, PrinterName, DocumentName, JobStatus, Size |
            Out-String -Width 300 | Write-Output
        Write-Host "  ► Aviser les utilisateurs ou purger les queues avant le reboot" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ Aucun job en attente dans les queues"
    }
} catch {
    Write-Host "  Module PrintManagement non disponible — vérification manuelle recommandée" -ForegroundColor Yellow
}

# ── 5. EVENT LOG PrintService (6h) ──────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  EVENT LOG — PrintService (6 dernières heures)"
Write-Host $Sep
try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName='Microsoft-Windows-PrintService/Operational'
        StartTime=(Get-Date).AddHours(-6)
    } -EA SilentlyContinue | Where-Object { $_.LevelDisplayName -in 'Error','Critical','Warning' }
    if ($events) {
        $events | Select-Object -First 20 TimeCreated, Id, ProviderName,
            @{N='Message';E={$_.Message.Substring(0,[math]::Min(100,$_.Message.Length))}} |
            Out-String -Width 300 | Write-Output
    } else {
        Write-Host "  ✓ Aucun événement Error/Warning PrintService dans les 6 dernières heures"
    }
} catch { Write-Host "  [À CONFIRMER] Journal PrintService/Operational non disponible" -ForegroundColor Yellow }

# ── RÉSUMÉ ───────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  RÉSUMÉ PRECHECK PRINT SERVER"
Write-Host $Sep
Write-Host "  Serveur  : $env:COMPUTERNAME"
Write-Host "  LastBoot : $($os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm'))"
Write-Host "  Reboot   : $($CBS -or $WU -or $PFR)"
Write-Host $Sep
```

---

## POSTCHECK — Après reboot Print Server

> Script unique — valide le reboot ET l'état du Print Server en une passe.

```powershell
# ============================================================
# POSTCHECK PRINT SERVER — Après reboot
# Impact  : Lecture seule
# ============================================================
$Sep = "=" * 60

# ── 1. REBOOT CONFIRMÉ ───────────────────────────────────────
Write-Host $Sep
Write-Host "  REBOOT CONFIRMÉ — HOST / OS / UPTIME"
Write-Host $Sep
$os     = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    LastBoot    = $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")
    UptimeHours = [math]::Round($uptime.TotalHours, 2)
} | Out-String -Width 300 | Write-Output
if ($uptime.TotalHours -lt 2) {
    Write-Host "  ✓ REBOOT CONFIRMÉ — LastBoot récent" -ForegroundColor Green
} else {
    Write-Host "  ⚠ UptimeHours = $([math]::Round($uptime.TotalHours,1))h — vérifier que le bon serveur a rebooté" -ForegroundColor Yellow
}
Write-Host "  ► Documenter LastBoot dans le billet" -ForegroundColor Cyan

# ── 2. PENDING REBOOT FLAGS ──────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  PENDING REBOOT FLAGS — Post-reboot"
Write-Host $Sep
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -EA SilentlyContinue) -ne $null
[pscustomobject]@{ CBS=$CBS; WU=$WU; PendingFileRename=$PFR; EncoreRequis=($CBS -or $WU -or $PFR) } | Out-String -Width 300 | Write-Output
if ($CBS -or $WU -or $PFR) {
    Write-Host "  ⚠ FLAGS ENCORE ACTIFS — 2e reboot peut être nécessaire" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Flags pending reboot retombés à False" -ForegroundColor Green
}

# ── 3. SERVICE SPOOLER ───────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SERVICE SPOOLER — Post-reboot"
Write-Host $Sep
$spooler = Get-Service Spooler -EA SilentlyContinue
if ($spooler) {
    $color = if ($spooler.Status -eq 'Running') { 'Green' } else { 'Red' }
    Write-Host "  Spooler : $($spooler.Status) / $($spooler.StartType)" -ForegroundColor $color
    if ($spooler.Status -ne 'Running') {
        Write-Host "  ⛔ Spooler non Running — démarrer : Start-Service Spooler" -ForegroundColor Red
    }
}

# ── 4. IMPRIMANTES VISIBLES ──────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  IMPRIMANTES — Visibilité post-reboot"
Write-Host $Sep
try {
    $printers = Get-Printer -EA Stop
    $shared    = $printers | Where-Object { $_.Shared -eq $true }
    Write-Host "  Imprimantes : $($printers.Count) — Partagées : $($shared.Count)"
    $printers | Select-Object Name, Shared, PrinterStatus | Sort-Object Name |
        Out-String -Width 300 | Write-Output
    $errPrinters = $printers | Where-Object { $_.PrinterStatus -notin @('Normal','Idle') }
    if ($errPrinters) {
        Write-Host "  ⚠ Imprimantes en état anormal :" -ForegroundColor Yellow
        $errPrinters | ForEach-Object { Write-Host "    → $($_.Name) : $($_.PrinterStatus)" -ForegroundColor Yellow }
    } else {
        Write-Host "  ✓ Toutes les imprimantes en état Normal/Idle" -ForegroundColor Green
    }
} catch { Write-Host "  Module PrintManagement non disponible — vérification manuelle" -ForegroundColor Yellow }

# ── 5. EVENT LOG POST-REBOOT (1h) ────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  EVENT LOG — PrintService (1 heure post-reboot)"
Write-Host $Sep
try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName='Microsoft-Windows-PrintService/Operational'
        StartTime=(Get-Date).AddHours(-1)
    } -EA SilentlyContinue | Where-Object { $_.LevelDisplayName -in 'Error','Critical' }
    if ($events) {
        Write-Host "  ⚠ Erreurs PrintService post-reboot :" -ForegroundColor Yellow
        $events | Select-Object -First 10 TimeCreated, Id,
            @{N='Message';E={$_.Message.Substring(0,[math]::Min(100,$_.Message.Length))}} |
            Out-String -Width 300 | Write-Output
    } else {
        Write-Host "  ✓ Aucune erreur PrintService dans la dernière heure" -ForegroundColor Green
    }
} catch { Write-Host "  [À CONFIRMER] Journal PrintService non disponible" -ForegroundColor Yellow }

# ── RÉSUMÉ POSTCHECK ─────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  RÉSUMÉ POSTCHECK PRINT SERVER"
Write-Host $Sep
$ok = $true
if ($uptime.TotalHours -ge 2)                   { $ok = $false; Write-Host "  ⚠ Uptime élevé — reboot à confirmer" -ForegroundColor Yellow }
if ($CBS -or $WU -or $PFR)                      { Write-Host "  ⚠ Flags pending encore actifs" -ForegroundColor Yellow }
if ($spooler -and $spooler.Status -ne 'Running'){ $ok = $false; Write-Host "  ⛔ Spooler non Running" -ForegroundColor Red }
if ($ok) {
    Write-Host "  ✅ POSTCHECK OK — Reboot confirmé, Spooler Running, imprimantes visibles" -ForegroundColor Green
    Write-Host "     Documenter dans le billet et fermer le ticket." -ForegroundColor Cyan
}
Write-Host $Sep
```

---

## Si une imprimante ne répond plus après reboot

1. Vérifier connectivité réseau : `Test-Connection <IP-imprimante> -Count 2`
2. Cycle power sur l'imprimante (débrancher / rebrancher)
3. Redémarrer le spooler : `Restart-Service Spooler`
4. Si le port TCP/IP ne répond plus : vérifier IP fixe vs DHCP sur l'imprimante
