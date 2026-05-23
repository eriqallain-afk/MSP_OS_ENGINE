<#
.SYNOPSIS
    MAINT-SRV-MasterScript_V1.ps1 — Diagnostic snapshot universel MSP
.DESCRIPTION
    Bloc 1 : Ressources systeme + detection automatique des roles
    Bloc 2 : Checks specifiques par role detecte
    Bloc 3 : Rapport texte structure pret a coller dans CW Discussion
    Read-only — aucune modification systeme.
.PARAMETER TicketContext
    Contexte du billet (optionnel). Ex: "replication AD", "lenteur serveur"
.PARAMETER TechName
    Nom du technicien (optionnel).
.PARAMETER HoursEvents
    Fenetre event logs en heures (defaut: 24)
.NOTES
    Version : 1.0 — 2026-05-14
    Usage   : IT-SysAdmin, IT-MaintenanceMaster, IT-AssistanTI_N3
    Charger via : getFileContent(path="IT-SHARED/30_SCRIPTS/MAINT-SRV-MasterScript_V1.ps1")
#>
[CmdletBinding()]
param(
    [string]$TicketContext = "",
    [string]$TechName      = "",
    [int]   $HoursEvents   = 24
)

$ErrorActionPreference = "SilentlyContinue"
$report = [System.Text.StringBuilder]::new()

function r  { param([string]$l = "") [void]$report.AppendLine($l) }
function rs { param([string]$t)      r ""; r ("=" * 62); r "  $t"; r ("=" * 62) }
function rh { param([string]$t)      r ""; r "--- $t ---" }

# ============================================================
# EN-TETE
# ============================================================
r "RAPPORT DIAGNOSTIC SERVEUR — $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
if ($TechName)     { r "Technicien     : $TechName" }
if ($TicketContext) { r "Contexte billet: $TicketContext" }
r ("=" * 62)

# ============================================================
# BLOC 1A — SYSTEME DE BASE
# ============================================================
rs "SYSTEME"

$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$uptime = (Get-Date) - $os.LastBootUpTime

r "Hostname    : $env:COMPUTERNAME"
r "Domaine     : $($cs.Domain)"
r "OS          : $($os.Caption)"
r "Uptime      : $([int]$uptime.TotalDays)j $($uptime.Hours)h $($uptime.Minutes)m"
r "Dernier boot: $($os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm'))"

# CPU
rh "CPU"
try {
    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time' `
        -SampleInterval 2 -MaxSamples 3 -EA Stop).CounterSamples.CookedValue |
        Measure-Object -Average
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    r "Modele      : $($cpu.Name.Trim())"
    r "Utilisation : $([math]::Round($cpuLoad.Average,1))%  ($($cpu.NumberOfLogicalProcessors) coeurs logiques)"
} catch { r "[WARN] Lecture CPU impossible" }

# RAM
rh "MEMOIRE"
$ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$ramFree  = [math]::Round($os.FreePhysicalMemory     / 1MB, 1)
$ramUsed  = [math]::Round($ramTotal - $ramFree, 1)
$ramPct   = if ($ramTotal -gt 0) { [math]::Round($ramUsed / $ramTotal * 100, 1) } else { 0 }
$ramFlag  = if ($ramPct -gt 90) { " [CRITIQUE]" } elseif ($ramPct -gt 80) { " [ATTENTION]" } else { "" }
r "Total  : ${ramTotal} GB  |  Utilisee : ${ramUsed} GB ($ramPct%)  |  Libre : ${ramFree} GB$ramFlag"

# Disques
rh "DISQUES"
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $tot  = [math]::Round($_.Size      / 1GB, 1)
    $free = [math]::Round($_.FreeSpace / 1GB, 1)
    $pct  = if ($tot -gt 0) { [math]::Round(($tot - $free) / $tot * 100, 1) } else { 0 }
    $flag = if ($pct -gt 85) { " [CRITIQUE]" } elseif ($pct -gt 75) { " [ATTENTION]" } else { "" }
    r "$($_.DeviceID)  Total: ${tot}GB  |  Libre: ${free}GB ($([math]::Round(100-$pct,1))%)$flag"
}

# Reboot en attente
rh "REBOOT EN ATTENTE"
$rebootReasons = @()
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending")           { $rebootReasons += "CBS" }
if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA SilentlyContinue) { $rebootReasons += "PendingFileRename" }
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")          { $rebootReasons += "WindowsUpdate" }
if ($rebootReasons) { r "[ATTENTION] Reboot en attente : $($rebootReasons -join ', ')" }
else                { r "OK — Aucun reboot en attente" }

# ============================================================
# BLOC 1B — DETECTION DES ROLES
# ============================================================
rs "ROLES DETECTES"

$roles = @{
    DC        = $false
    SQL       = $false
    RDS       = $false
    HyperV    = $false
    Print     = $false
    IIS       = $false
    Veeam     = $false
    Datto     = $false
}

# Detection via services (compatible toutes versions Windows Server)
if (Get-Service "NTDS"             -EA SilentlyContinue) { $roles.DC     = $true }
if (Get-Service "MSSQLSERVER","MSSQL`$*" -EA SilentlyContinue | Where-Object Status -eq "Running") { $roles.SQL = $true }
if (Get-Service "TermService"      -EA SilentlyContinue) { $roles.RDS    = $true }
if (Get-Service "vmms"             -EA SilentlyContinue) { $roles.HyperV = $true }
if (Get-Service "Spooler"          -EA SilentlyContinue) { $roles.Print  = $true }
if (Get-Service "W3SVC"            -EA SilentlyContinue) { $roles.IIS    = $true }
if (Get-Service "VeeamBackupSvc"   -EA SilentlyContinue) { $roles.Veeam  = $true }
if (Get-Service "Datto*"           -EA SilentlyContinue) { $roles.Datto  = $true }

# Affichage roles
$activeRoles = $roles.GetEnumerator() | Where-Object Value | ForEach-Object { $_.Key }
if ($activeRoles) { r "Roles actifs : $($activeRoles -join ', ')" }
else              { r "Serveur membre standard (aucun role specifique detecte)" }

# ============================================================
# BLOC 1C — SERVICES AUTO ARRETES
# ============================================================
rs "SERVICES AUTO ARRETES"
$stopped = Get-Service | Where-Object { $_.StartType -eq "Automatic" -and $_.Status -ne "Running" }
if ($stopped) {
    $stopped | ForEach-Object { r "[ARRETE] $($_.DisplayName)  [$($_.Name)]" }
} else { r "OK — Aucun service Auto arrete" }

# ============================================================
# BLOC 1D — EVENEMENTS (derniers $HoursEvents h)
# ============================================================
rs "EVENEMENTS CRITIQUES (${HoursEvents}h)"
$since = (Get-Date).AddHours(-$HoursEvents)
foreach ($log in @("System","Application")) {
    try {
        $evts = Get-WinEvent -FilterHashtable @{LogName=$log; Level=1,2; StartTime=$since} -MaxEvents 200 -EA Stop
        if ($evts) {
            r "$log — $($evts.Count) erreur(s) :"
            $evts | Group-Object ProviderName | Sort-Object Count -Desc | Select-Object -First 8 |
                ForEach-Object { r "  [$($_.Count)x]  $($_.Name)" }
        } else { r "$log — OK (aucune erreur)" }
    } catch { r "$log — Aucune erreur detectee" }
}

# ============================================================
# BLOC 2 — CHECKS PAR ROLE
# ============================================================

# ── DOMAIN CONTROLLER ────────────────────────────────────────
if ($roles.DC) {
    rs "ACTIVE DIRECTORY / DOMAIN CONTROLLER"

    rh "Services AD"
    foreach ($svc in @("NTDS","NETLOGON","kdc","W32Time","DNS")) {
        $s = Get-Service $svc -EA SilentlyContinue
        if ($s) {
            $icon = if ($s.Status -eq "Running") { "OK  " } else { "[!!]" }
            r "$icon $($s.DisplayName) : $($s.Status)"
        }
    }

    rh "Replication AD (repadmin /replsummary)"
    try {
        $repl = repadmin /replsummary 2>&1
        $replErr = $repl | Where-Object { $_ -match "error|fail|0x[0-9a-fA-F]" }
        if ($replErr) { $replErr | ForEach-Object { r "[!!] $_" } }
        else          { r "OK — Aucune erreur de replication detectee" }
    } catch { r "[WARN] repadmin non disponible" }

    rh "SYSVOL"
    $sysvolPath = "\\$env:COMPUTERNAME\SYSVOL"
    if (Test-Path $sysvolPath) { r "OK — SYSVOL accessible : $sysvolPath" }
    else                       { r "[!!] SYSVOL inaccessible : $sysvolPath" }

    rh "Synchronisation temps (W32tm)"
    $w32 = w32tm /query /status 2>&1 | Select-String "Source|Offset|Stratum"
    $w32 | ForEach-Object { r "  $_" }

    rh "Evenements AD specifiques (${HoursEvents}h)"
    try {
        $adEvts = Get-WinEvent -FilterHashtable @{LogName="Directory Service"; Level=1,2; StartTime=$since} -MaxEvents 20 -EA Stop
        if ($adEvts) {
            $adEvts | Group-Object ProviderName | ForEach-Object { r "  [$($_.Count)x] $($_.Name)" }
        } else { r "OK — Aucune erreur dans Directory Service" }
    } catch { r "OK — Aucune erreur detectee dans Directory Service" }
}

# ── SQL SERVER ───────────────────────────────────────────────
if ($roles.SQL) {
    rs "SQL SERVER"

    rh "Instances SQL"
    Get-Service -Name "MSSQLSERVER","MSSQL*" -EA SilentlyContinue |
        Where-Object { $_.Name -match "MSSQL" } | ForEach-Object {
            $icon = if ($_.Status -eq "Running") { "OK  " } else { "[!!]" }
            r "$icon $($_.DisplayName) : $($_.Status)"
        }

    rh "SQL Agent"
    Get-Service -Name "SQLSERVERAGENT","SQLAgent*" -EA SilentlyContinue | ForEach-Object {
        $icon = if ($_.Status -eq "Running") { "OK  " } else { "[!!]" }
        r "$icon $($_.DisplayName) : $($_.Status)"
    }

    rh "Evenements SQL (${HoursEvents}h)"
    try {
        $sqlEvts = Get-WinEvent -FilterHashtable @{LogName="Application"; ProviderName="MSSQLSERVER","MSSQL*"; Level=1,2; StartTime=$since} -MaxEvents 20 -EA Stop
        if ($sqlEvts) { $sqlEvts | ForEach-Object { r "  [!!] $($_.TimeCreated.ToString('HH:mm')) $($_.Message.Split("`n")[0])" } }
        else          { r "OK — Aucune erreur SQL dans Application log" }
    } catch { r "OK — Aucun evenement SQL critique" }
}

# ── RDS ──────────────────────────────────────────────────────
if ($roles.RDS) {
    rs "REMOTE DESKTOP SERVICES"

    rh "Services RDS"
    foreach ($svc in @("TermService","UmRdpService","SessionEnv")) {
        $s = Get-Service $svc -EA SilentlyContinue
        if ($s) {
            $icon = if ($s.Status -eq "Running") { "OK  " } else { "[!!]" }
            r "$icon $($s.DisplayName) : $($s.Status)"
        }
    }

    rh "Sessions actives"
    try {
        $sessions = query session 2>&1 | Where-Object { $_ -match "Active|Disc" }
        r "Sessions : $($sessions.Count) active(s)/deconnectee(s)"
        $sessions | Select-Object -First 10 | ForEach-Object { r "  $_" }
    } catch { r "[WARN] query session non disponible" }
}

# ── HYPER-V ──────────────────────────────────────────────────
if ($roles.HyperV) {
    rs "HYPER-V"

    rh "Etat des VMs"
    try {
        $vms = Get-VM -EA Stop
        $vms | Group-Object State | ForEach-Object { r "$($_.Name) : $($_.Count) VM(s)" }

        $notRunning = $vms | Where-Object { $_.State -ne "Running" }
        if ($notRunning) {
            r ""
            $notRunning | ForEach-Object { r "  [!!] VM hors ligne : $($_.Name)  [$($_.State)]" }
        }
    } catch { r "[WARN] Get-VM non disponible (Hyper-V module)" }

    rh "Snapshots anciens (>72h)"
    try {
        $oldSnaps = Get-VM -EA Stop | Get-VMSnapshot |
            Where-Object { $_.CreationTime -lt (Get-Date).AddHours(-72) }
        if ($oldSnaps) {
            $oldSnaps | ForEach-Object {
                r "  [!!] $($_.VMName)  —  $($_.Name)  —  $($_.CreationTime.ToString('yyyy-MM-dd HH:mm'))"
            }
        } else { r "OK — Aucun snapshot de plus de 72h" }
    } catch { r "[WARN] Impossible de lister les snapshots" }
}

# ── VEEAM ────────────────────────────────────────────────────
if ($roles.Veeam) {
    rs "VEEAM BACKUP"
    $v = Get-Service "VeeamBackupSvc" -EA SilentlyContinue
    $icon = if ($v.Status -eq "Running") { "OK  " } else { "[!!]" }
    r "$icon Veeam Backup Service : $($v.Status)"
    r "→ Verifier les jobs dans la console Veeam (GUI ou PowerShell Veeam)"
}

# ── DATTO ────────────────────────────────────────────────────
if ($roles.Datto) {
    rs "DATTO BACKUP"
    Get-Service "Datto*" -EA SilentlyContinue | ForEach-Object {
        $icon = if ($_.Status -eq "Running") { "OK  " } else { "[!!]" }
        r "$icon $($_.DisplayName) : $($_.Status)"
    }
    r "→ Verifier le portail Datto pour l'etat des jobs"
}

# ── PRINT SERVER ─────────────────────────────────────────────
if ($roles.Print) {
    rs "PRINT SERVER"

    $spooler = Get-Service "Spooler" -EA SilentlyContinue
    $icon = if ($spooler.Status -eq "Running") { "OK  " } else { "[!!]" }
    r "$icon Spouleur : $($spooler.Status)"

    rh "Files d'impression"
    try {
        $jobs = Get-PrintJob -EA Stop
        if ($jobs) {
            r "[!!] $($jobs.Count) job(s) en attente :"
            $jobs | Select-Object -First 10 | ForEach-Object {
                r "  $($_.PrinterName)  —  $($_.DocumentName)  —  $($_.JobStatus)"
            }
        } else { r "OK — Aucun job bloque" }
    } catch { r "→ Verifier Print Management pour les files bloquees" }
}

# ============================================================
# BLOC 3 — PIED DE PAGE
# ============================================================
r ""
r ("=" * 62)
r "FIN DU RAPPORT — $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
r "Roles detectes : $(if ($activeRoles) { $activeRoles -join ', ' } else { 'Aucun role specifique' })"
r ("=" * 62)

# Sortie console — pret a coller dans CW Discussion
Write-Host $report.ToString()
