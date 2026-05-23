# INFRA-SRV-SQL_PrePost_Validation_V2
**Version :** 3.0 | **Date :** 2026-05-21 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## PRECHECK — Avant reboot SQL Server

> Script unique — lecture seule. Exécuter via RMM ou PSRemoting.

```powershell
# ============================================================
# PRECHECK SQL SERVER — Avant reboot
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
    OS         = $os.Caption
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
if ($CBS -or $WU -or $PFR) {
    $flags = @(); if($CBS){$flags+="CBS"}; if($WU){$flags+="WU"}; if($PFR){$flags+="PFR"}
    Write-Host "  ⚠ FLAGS ACTIFS : $($flags -join ' · ')" -ForegroundColor Yellow
    if (($flags | Measure-Object).Count -ge 2) {
        Write-Host "  ⚠ Plusieurs flags — 2e reboot peut être nécessaire" -ForegroundColor Yellow
    }
}

# ── 3. SERVICES SQL ──────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SERVICES SQL SERVER"
Write-Host $Sep
$sqlSvcs = Get-Service | Where-Object { $_.Name -match '^MSSQL|^SQLAGENT|^SQLAgent|^SQLTELEMETRY|^MSSQLFDLauncher' } | Sort-Object Name
if ($sqlSvcs) {
    $sqlSvcs | Select-Object Name, Status, StartType | Out-String -Width 300 | Write-Output
    $notRunning = $sqlSvcs | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' }
    if ($notRunning) {
        Write-Host "  ⚠ Services AUTO non démarrés :" -ForegroundColor Yellow
        $notRunning | ForEach-Object { Write-Host "    → $($_.Name)" -ForegroundColor Yellow }
    } else {
        Write-Host "  ✓ Tous les services SQL automatiques sont Running"
    }
} else {
    Write-Host "  ⚠ Aucun service SQL détecté" -ForegroundColor Yellow
}

# ── 4. JOBS SQL AGENT EN COURS ───────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  JOBS SQL AGENT — EN COURS"
Write-Host $Sep
try {
    Import-Module SqlServer -EA Stop
    $instanceName = if ((Get-Service MSSQLSERVER -EA SilentlyContinue)) { $env:COMPUTERNAME } `
                    else { "$env:COMPUTERNAME\$((Get-Service | Where-Object {$_.Name -match '^MSSQL\$'} | Select-Object -First 1).Name -replace '^MSSQL\$','')" }
    $runningJobs = Get-SqlAgentJob -ServerInstance $instanceName -EA SilentlyContinue |
        Where-Object { $_.CurrentRunStatus -eq 'Executing' }
    if ($runningJobs) {
        Write-Host "  ⚠ JOBS EN COURS — vérifier avant reboot :" -ForegroundColor Yellow
        $runningJobs | Select-Object Name, CurrentRunStatus, LastRunDate | Out-String -Width 300 | Write-Output
    } else {
        Write-Host "  ✓ Aucun job SQL Agent en cours d'exécution"
    }
} catch {
    Write-Host "  Module SqlServer non disponible — vérifier manuellement dans SSMS : SQL Agent > Jobs" -ForegroundColor Yellow
}

# ── 5. CONNECTIVITÉ SQL ──────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  CONNECTIVITÉ SQL (test local)"
Write-Host $Sep
try {
    if (Get-Command Invoke-Sqlcmd -EA SilentlyContinue) {
        $r = Invoke-Sqlcmd -Query "SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version" -QueryTimeout 5
        Write-Host "  ✓ Connexion SQL OK — $($r.ServerName)" -ForegroundColor Green
    } else {
        $cn = New-Object System.Data.SqlClient.SqlConnection
        $cn.ConnectionString = "Server=localhost;Database=master;Integrated Security=True;Connection Timeout=5"
        $cn.Open()
        $cmd = $cn.CreateCommand(); $cmd.CommandText = "SELECT @@SERVERNAME"
        $name = $cmd.ExecuteScalar(); $cn.Close()
        Write-Host "  ✓ Connexion SQL OK (.NET) — $name" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⛔ CONNEXION SQL ÉCHOUÉE : $_" -ForegroundColor Red
}

# ── 6. EVENT LOG SQL (2h) ────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  EVENT LOG — Application SQL (2 dernières heures)"
Write-Host $Sep
$Start = (Get-Date).AddHours(-2)
try {
    $events = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} -EA SilentlyContinue |
        Where-Object { $_.LevelDisplayName -in 'Error','Critical' -and
                       ($_.ProviderName -match 'MSSQL|SQLSERVERAGENT|SQL' -or $_.Message -match 'SQL') }
    if ($events) {
        $events | Select-Object -First 20 TimeCreated, Id, ProviderName,
            @{N='Message';E={$_.Message.Substring(0,[math]::Min(100,$_.Message.Length))}} |
            Out-String -Width 300 | Write-Output
    } else {
        Write-Host "  ✓ Aucune erreur SQL dans les 2 dernières heures"
    }
} catch { Write-Host "  [À CONFIRMER] Impossible de lire le journal Application" -ForegroundColor Yellow }

# ── RÉSUMÉ ───────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  RÉSUMÉ PRECHECK SQL"
Write-Host $Sep
Write-Host "  Serveur  : $env:COMPUTERNAME"
Write-Host "  LastBoot : $($os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm')) — Uptime : $("{0}j {1}h" -f [int]$uptime.TotalDays, $uptime.Hours)"
Write-Host "  Reboot   : $($CBS -or $WU -or $PFR)"
Write-Host $Sep
```

---

## POSTCHECK — Après reboot SQL Server

> Script unique — valide le reboot ET l'état SQL en une passe.

```powershell
# ============================================================
# POSTCHECK SQL SERVER — Après reboot
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

# ── 3. SERVICES SQL ──────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SERVICES SQL — Post-reboot"
Write-Host $Sep
$sqlSvcs = Get-Service | Where-Object { $_.Name -match '^MSSQL|^SQLAGENT|^SQLAgent|^MSSQLFDLauncher' } | Sort-Object Name
$sqlSvcs | Select-Object Name, Status, StartType | Out-String -Width 300 | Write-Output
$notRunning = $sqlSvcs | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' }
if ($notRunning) {
    Write-Host "  ⛔ Services SQL AUTO non démarrés :" -ForegroundColor Red
    $notRunning | ForEach-Object { Write-Host "    → $($_.Name)" -ForegroundColor Red }
} else {
    Write-Host "  ✓ Tous les services SQL automatiques sont Running" -ForegroundColor Green
}

# ── 4. CONNECTIVITÉ SQL ──────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  CONNECTIVITÉ SQL — Post-reboot"
Write-Host $Sep
try {
    if (Get-Command Invoke-Sqlcmd -EA SilentlyContinue) {
        $r = Invoke-Sqlcmd -Query "SELECT @@SERVERNAME AS ServerName, GETDATE() AS PostRebootTime" -QueryTimeout 10
        Write-Host "  ✓ Connexion SQL OK — $($r.ServerName) — $($r.PostRebootTime)" -ForegroundColor Green
    } else {
        $cn = New-Object System.Data.SqlClient.SqlConnection
        $cn.ConnectionString = "Server=localhost;Database=master;Integrated Security=True;Connection Timeout=10"
        $cn.Open()
        $cmd = $cn.CreateCommand(); $cmd.CommandText = "SELECT @@SERVERNAME"
        $name = $cmd.ExecuteScalar(); $cn.Close()
        Write-Host "  ✓ Connexion SQL OK (.NET) — $name" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⛔ CONNEXION SQL ÉCHOUÉE : $_" -ForegroundColor Red
    Write-Host "     Vérifier le service MSSQLSERVER / attendre le démarrage complet" -ForegroundColor Red
}

# ── 5. EVENT LOG POST-REBOOT (1h) ────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  EVENT LOG — Application SQL (1 heure post-reboot)"
Write-Host $Sep
$Start = (Get-Date).AddHours(-1)
try {
    $events = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} -EA SilentlyContinue |
        Where-Object { $_.LevelDisplayName -in 'Error','Critical' -and
                       ($_.ProviderName -match 'MSSQL|SQLSERVERAGENT|SQL' -or $_.Message -match 'SQL') }
    if ($events) {
        Write-Host "  ⚠ Erreurs SQL post-reboot :" -ForegroundColor Yellow
        $events | Select-Object -First 20 TimeCreated, Id, ProviderName,
            @{N='Message';E={$_.Message.Substring(0,[math]::Min(100,$_.Message.Length))}} |
            Out-String -Width 300 | Write-Output
    } else {
        Write-Host "  ✓ Aucune erreur SQL dans la dernière heure" -ForegroundColor Green
    }
} catch { Write-Host "  [À CONFIRMER] Impossible de lire le journal" -ForegroundColor Yellow }

# ── RÉSUMÉ POSTCHECK ─────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  RÉSUMÉ POSTCHECK SQL"
Write-Host $Sep
$ok = $true
if ($uptime.TotalHours -ge 2)                                           { $ok = $false; Write-Host "  ⚠ Uptime élevé — reboot à confirmer" -ForegroundColor Yellow }
if ($CBS -or $WU -or $PFR)                                              { Write-Host "  ⚠ Flags pending encore actifs" -ForegroundColor Yellow }
if ($notRunning -and ($notRunning | Measure-Object).Count -gt 0)        { $ok = $false; Write-Host "  ⛔ Services SQL non démarrés" -ForegroundColor Red }
if ($ok) {
    Write-Host "  ✅ POSTCHECK OK — Reboot confirmé, services SQL Running, connexion OK" -ForegroundColor Green
    Write-Host "     Documenter dans le billet et fermer le ticket." -ForegroundColor Cyan
}
Write-Host $Sep
```

---

## Note opérationnelle

- Certains environnements (CU/patch) nécessitent **2 reboots** — documenter la raison (flags restants).
- Si connexion SQL échoue après reboot : attendre 2-3 min (SQL Server démarre lentement après boot à froid).
- Si SQL Agent ne démarre pas automatiquement : `Start-Service SQLSERVERAGENT` ou nom de l'instance.
