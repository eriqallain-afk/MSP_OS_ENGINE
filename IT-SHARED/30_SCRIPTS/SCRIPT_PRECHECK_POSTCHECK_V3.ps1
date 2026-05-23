
# ============================================================
# PRECHECK / POSTCHECK — Patching Windows Server
# Version : 3.0 — Avec détection de rôles
# Usage   : Exécuter localement sur le serveur cible via RMM
#           ou session PSRemoting.
# Impact  : Lecture seule — aucun changement appliqué
# ============================================================
param(
    [string]$Billet  = "[À CONFIRMER]",
    [string]$Client  = "[À CONFIRMER]",
    [string]$OutDir  = "$env:TEMP\CW_Patching"
)

#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$Phase   = if ($args -contains "POST") { "POSTCHECK" } else { "PRECHECK" }
$TS      = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = Join-Path $OutDir "${Phase}_${TS}.log"
Start-Transcript -Path $LogFile -Append

$Sep = "=" * 60

# ─────────────────────────────────────────────────────────────
# 1. HOST / OS / UPTIME
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  HOST / OS / UPTIME"
Write-Host $Sep
$os      = Get-CimInstance Win32_OperatingSystem
$uptime  = (Get-Date) - $os.LastBootUpTime
$uptimeF = "{0}j {1}h {2}min" -f [int]$uptime.TotalDays, $uptime.Hours, $uptime.Minutes

[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    OS          = $os.Caption
    Version     = $os.Version
    Build       = $os.BuildNumber
    LastReboot  = $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")
    Uptime      = $uptimeF
    UptimeDays  = [math]::Round($uptime.TotalDays, 1)
} | Format-List

if ($uptime.TotalDays -gt 30) {
    Write-Host "  ⚠ UPTIME > 30 JOURS — redémarrage probablement requis depuis longtemps" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────────────────────
# 2. MÉMOIRE RAM
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  MÉMOIRE RAM"
Write-Host $Sep
$cs     = Get-CimInstance Win32_ComputerSystem
$ramTot = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
$ramLib = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$ramUsed= [math]::Round($ramTot - $ramLib, 1)
$ramPct = [math]::Round(($ramUsed / $ramTot) * 100, 0)

[pscustomobject]@{
    TotalGB    = $ramTot
    UsedGB     = $ramUsed
    FreeGB     = $ramLib
    UsedPct    = "$ramPct%"
} | Format-List

if ($ramPct -gt 90) {
    Write-Host "  ⚠ RAM > 90% — vérifier avant intervention" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────────────────────
# 3. DISQUES
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  DISQUES"
Write-Host $Sep
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } |
    Select-Object Name,
        @{N='TotalGB'; E={[math]::Round(($_.Used+$_.Free)/1GB,1)}},
        @{N='UsedGB';  E={[math]::Round($_.Used/1GB,1)}},
        @{N='FreeGB';  E={[math]::Round($_.Free/1GB,1)}},
        @{N='Free%';   E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} |
    Format-Table -AutoSize

# ─────────────────────────────────────────────────────────────
# 4. PENDING REBOOT — 4 FLAGS
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  PENDING REBOOT FLAGS"
Write-Host $Sep
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'
$anyPending = $CBS -or $WU -or $PFR -or $CCM

[pscustomobject]@{
    CBS_RebootPending           = $CBS
    WU_RebootRequired           = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending      = $CCM
    "-- REBOOT REQUIS --"       = $anyPending
} | Format-List

if ($anyPending) {
    $flagsActifs = @()
    if ($CBS) { $flagsActifs += "CBS" }
    if ($WU)  { $flagsActifs += "WU" }
    if ($PFR) { $flagsActifs += "PFR" }
    if ($CCM) { $flagsActifs += "CCM" }
    Write-Host "  ⚠ FLAGS ACTIFS : $($flagsActifs -join ' · ')" -ForegroundColor Yellow
    if ($CBS -and $WU -and $PFR) {
        Write-Host "  ⚠ 3 FLAGS SIMULTANÉS — 2e reboot peut être nécessaire après le 1er" -ForegroundColor Yellow
    }
}

# ─────────────────────────────────────────────────────────────
# 5. DÉTECTION DES RÔLES SERVEUR
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  PROFIL SERVEUR — DÉTECTION DES RÔLES"
Write-Host $Sep

# Détection par services clés
$svcDC        = Get-Service -Name 'NTDS'            -ErrorAction SilentlyContinue
$svcDNS       = Get-Service -Name 'DNS'             -ErrorAction SilentlyContinue
$svcDHCP      = Get-Service -Name 'DHCPServer'      -ErrorAction SilentlyContinue
$svcSQL       = Get-Service | Where-Object { $_.Name -match '^MSSQL\$|^MSSQLSERVER$' }
$svcSQLAgent  = Get-Service | Where-Object { $_.Name -match '^SQLAGENT|^SQLAgent' }
$svcRDS       = Get-Service -Name 'TermService'     -ErrorAction SilentlyContinue
$svcRDCB      = Get-Service -Name 'TSGateway'       -ErrorAction SilentlyContinue
$svcPrint     = Get-Service -Name 'Spooler'         -ErrorAction SilentlyContinue
$svcIIS       = Get-Service -Name 'W3SVC'           -ErrorAction SilentlyContinue
$svcExchTrans = Get-Service -Name 'MSExchangeTransport' -ErrorAction SilentlyContinue
$svcExchIS    = Get-Service -Name 'MSExchangeIS'    -ErrorAction SilentlyContinue
$svcVeeam     = Get-Service | Where-Object { $_.Name -match 'VeeamBackup|VeeamNFS' }
$svcHyperV    = Get-Service -Name 'vmms'            -ErrorAction SilentlyContinue
$svcWsus      = Get-Service -Name 'WsusService'     -ErrorAction SilentlyContinue
$svcSCCM      = Get-Service -Name 'SMS_EXECUTIVE'   -ErrorAction SilentlyContinue
$svcFileServer= Get-Service -Name 'LanmanServer'    -ErrorAction SilentlyContinue
$svcFSRM      = Get-Service -Name 'srmsvc'          -ErrorAction SilentlyContinue

# Construire le profil de rôles
$roles = @()
if ($svcDC   -and $svcDC.Status   -eq 'Running') { $roles += "DOMAIN CONTROLLER (AD DS)" }
if ($svcDNS  -and $svcDNS.Status  -eq 'Running') { $roles += "DNS SERVER" }
if ($svcDHCP -and $svcDHCP.Status -eq 'Running') { $roles += "DHCP SERVER" }
if ($svcSQL)                                      { $roles += "SQL SERVER ($($svcSQL.Name -join ', '))" }
if ($svcRDS  -and $svcRDS.Status  -eq 'Running') { $roles += "REMOTE DESKTOP SERVICES (RDS)" }
if ($svcPrint -and $svcPrint.Status -eq 'Running') { $roles += "PRINT SERVER" }
if ($svcIIS  -and $svcIIS.Status  -eq 'Running') { $roles += "IIS / WEB SERVER" }
if ($svcExchTrans -or $svcExchIS)                 { $roles += "EXCHANGE SERVER" }
if ($svcVeeam)                                    { $roles += "VEEAM BACKUP SERVER" }
if ($svcHyperV -and $svcHyperV.Status -eq 'Running') { $roles += "HYPER-V HOST" }
if ($svcWsus -and $svcWsus.Status -eq 'Running') { $roles += "WSUS SERVER" }
if ($svcSCCM -and $svcSCCM.Status -eq 'Running') { $roles += "SCCM / MECM SERVER" }
if ($svcFSRM -and $svcFSRM.Status -eq 'Running') { $roles += "FILE SERVER (FSRM)" }
if ($roles.Count -eq 0)                           { $roles += "SERVEUR MEMBRE (rôle non détecté)" }

Write-Host "  RÔLES DÉTECTÉS :"
$roles | ForEach-Object { Write-Host "    ► $_" }

# ─────────────────────────────────────────────────────────────
# 6. CHECKS CONDITIONNELS PAR RÔLE
# ─────────────────────────────────────────────────────────────

# ── 6A. DOMAIN CONTROLLER ────────────────────────────────────
if ($svcDC -and $svcDC.Status -eq 'Running') {
    Write-Host " "
    Write-Host $Sep
    Write-Host "  DOMAIN CONTROLLER — CHECKS SPÉCIFIQUES"
    Write-Host $Sep

    Write-Host "  >> Rôles FSMO détenus sur ce DC :"
    try {
        $domain  = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        $forest  = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
        [pscustomobject]@{
            PDC_Emulator        = $domain.PdcRoleOwner.Name
            RID_Master          = $domain.RidRoleOwner.Name
            Infra_Master        = $domain.InfrastructureRoleOwner.Name
            Schema_Master       = $forest.SchemaRoleOwner.Name
            DomainNaming_Master = $forest.NamingRoleOwner.Name
        } | Format-List
    } catch {
        Write-Host "  [À CONFIRMER] Impossible de lire les rôles FSMO : $_" -ForegroundColor Yellow
    }

    Write-Host "  >> Services AD critiques :"
    @('NTDS','Netlogon','DFSR','DNS','W32Time','KDC') | ForEach-Object {
        $s = Get-Service -Name $_ -ErrorAction SilentlyContinue
        $status = if ($s) { $s.Status } else { "Non installé" }
        $color  = if ($status -eq 'Running') { 'Green' } else { 'Yellow' }
        Write-Host "     $_ : $status" -ForegroundColor $color
    }

    Write-Host "  >> Réplication AD (résumé) :"
    try {
        $repl = repadmin /replsummary 2>&1
        $repl | Select-Object -First 20 | ForEach-Object { Write-Host "     $_" }
    } catch {
        Write-Host "  [À CONFIRMER] repadmin non disponible dans ce contexte" -ForegroundColor Yellow
    }

    Write-Host "  >> Sessions Netlogon actives :"
    try { nltest /server:$env:COMPUTERNAME /dclist:$env:USERDOMAIN 2>&1 | Select-Object -First 10 | ForEach-Object { Write-Host "     $_" } }
    catch { Write-Host "  [À CONFIRMER] nltest indisponible" -ForegroundColor Yellow }
}

# ── 6B. SQL SERVER ────────────────────────────────────────────
if ($svcSQL) {
    Write-Host " "
    Write-Host $Sep
    Write-Host "  SQL SERVER — CHECKS SPÉCIFIQUES"
    Write-Host $Sep

    Write-Host "  >> Instances SQL détectées :"
    $svcSQL | Select-Object Name, Status, StartType | Format-Table -AutoSize

    Write-Host "  >> SQL Agent :"
    if ($svcSQLAgent) {
        $svcSQLAgent | Select-Object Name, Status | Format-Table -AutoSize
    } else {
        Write-Host "  SQL Agent non détecté" -ForegroundColor Yellow
    }

    # Connexion SQL pour lister les bases
    Write-Host "  >> Bases de données (via SqlServer module si disponible) :"
    try {
        Import-Module SqlServer -ErrorAction Stop
        $instanceName = if ($svcSQL[0].Name -eq 'MSSQLSERVER') { $env:COMPUTERNAME } else { "$env:COMPUTERNAME\$($svcSQL[0].Name.Replace('MSSQL$',''))" }
        Get-SqlDatabase -ServerInstance $instanceName -ErrorAction SilentlyContinue |
            Select-Object Name, Status, RecoveryModel,
                @{N='SizeMB';E={[math]::Round($_.Size,0)}} |
            Format-Table -AutoSize
    } catch {
        Write-Host "  Module SqlServer non disponible — vérification manuelle recommandée" -ForegroundColor Yellow
        Write-Host "  Instances : $($svcSQL.Name -join ', ')"
    }
}

# ── 6C. RDS ───────────────────────────────────────────────────
if ($svcRDS -and $svcRDS.Status -eq 'Running') {
    Write-Host " "
    Write-Host $Sep
    Write-Host "  REMOTE DESKTOP SERVICES — CHECKS SPÉCIFIQUES"
    Write-Host $Sep

    Write-Host "  >> Sessions actives (query user) :"
    try {
        query user 2>&1 | ForEach-Object { Write-Host "     $_" }
    } catch {
        Write-Host "  [À CONFIRMER] query user indisponible" -ForegroundColor Yellow
    }

    Write-Host "  >> Services RDS critiques :"
    @('TermService','SessionEnv','UmRdpService','RpcSs') | ForEach-Object {
        $s = Get-Service -Name $_ -ErrorAction SilentlyContinue
        $status = if ($s) { $s.Status } else { "Non installé" }
        Write-Host "     $_ : $status"
    }

    Write-Host "  >> ⚠ AVERTISSEMENT : vérifier que les sessions utilisateurs sont terminées avant reboot"
}

# ── 6D. PRINT SERVER ──────────────────────────────────────────
if ($svcPrint -and $svcPrint.Status -eq 'Running') {
    Write-Host " "
    Write-Host $Sep
    Write-Host "  PRINT SERVER — CHECKS SPÉCIFIQUES"
    Write-Host $Sep

    Write-Host "  >> Imprimantes partagées :"
    try {
        Get-Printer | Where-Object { $_.Shared -eq $true } |
            Select-Object Name, ShareName, DriverName, PortName, PrinterStatus |
            Format-Table -AutoSize
    } catch {
        Write-Host "  [À CONFIRMER] Get-Printer non disponible" -ForegroundColor Yellow
    }

    Write-Host "  >> Jobs en attente dans le spooler :"
    try {
        $jobs = Get-PrintJob -PrinterName * -ErrorAction SilentlyContinue
        if ($jobs) { $jobs | Format-Table -AutoSize }
        else { Write-Host "  Aucun job en attente" }
    } catch { Write-Host "  Impossible de lire le spooler" -ForegroundColor Yellow }
}

# ── 6E. EXCHANGE ──────────────────────────────────────────────
if ($svcExchTrans -or $svcExchIS) {
    Write-Host " "
    Write-Host $Sep
    Write-Host "  EXCHANGE SERVER — CHECKS SPÉCIFIQUES"
    Write-Host $Sep

    @('MSExchangeTransport','MSExchangeIS','MSExchangeADTopology','MSExchangeFrontEndTransport','MSExchangeMailboxAssistants') | ForEach-Object {
        $s = Get-Service -Name $_ -ErrorAction SilentlyContinue
        if ($s) { Write-Host "  $($_.PadRight(40)) $($s.Status)" }
    }

    Write-Host "  >> ⚠ Vérifier les queues de transport Exchange avant reboot"
    Write-Host "     Commande : Get-Queue (dans Exchange Management Shell)"
}

# ── 6F. HYPER-V ───────────────────────────────────────────────
if ($svcHyperV -and $svcHyperV.Status -eq 'Running') {
    Write-Host " "
    Write-Host $Sep
    Write-Host "  HYPER-V HOST — CHECKS SPÉCIFIQUES"
    Write-Host $Sep

    Write-Host "  >> VMs hébergées :"
    try {
        Get-VM | Select-Object Name, State, CPUUsage,
            @{N='MemAssignedGB';E={[math]::Round($_.MemoryAssigned/1GB,1)}},
            @{N='UptimeH';E={[math]::Round($_.Uptime.TotalHours,1)}} |
            Format-Table -AutoSize
    } catch {
        Write-Host "  [À CONFIRMER] Get-VM indisponible — vérifier module Hyper-V" -ForegroundColor Yellow
    }

    Write-Host "  >> ⚠ AVERTISSEMENT : sauvegarder ou migrer les VMs critiques avant reboot de l'hôte"
}

# ── 6G. VEEAM ─────────────────────────────────────────────────
if ($svcVeeam) {
    Write-Host " "
    Write-Host $Sep
    Write-Host "  VEEAM BACKUP SERVER — CHECKS SPÉCIFIQUES"
    Write-Host $Sep

    $svcVeeam | Select-Object Name, Status | Format-Table -AutoSize

    Write-Host "  >> ⚠ Vérifier qu'aucun job de sauvegarde n'est en cours avant le reboot"
    Write-Host "     Console Veeam → Jobs → vérifier statut Running / Idle"
}

# ─────────────────────────────────────────────────────────────
# 7. SERVICES AUTO NON DÉMARRÉS
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SERVICES AUTOMATIQUES NON DÉMARRÉS"
Write-Host $Sep
$svcStop = Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' }
if ($svcStop) {
    $svcStop | Select-Object Name, DisplayName, Status | Format-Table -AutoSize
} else {
    Write-Host "  ✓ Tous les services automatiques sont démarrés"
}

# ─────────────────────────────────────────────────────────────
# 8. HOTFIXES RÉCENTS (30 derniers jours)
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  HOTFIXES RÉCENTS (30 derniers jours)"
Write-Host $Sep
$cutoff = (Get-Date).AddDays(-30)
$hotfixes = Get-HotFix | Where-Object { $_.InstalledOn -gt $cutoff } | Sort-Object InstalledOn -Descending
if ($hotfixes) {
    $hotfixes | Select-Object HotFixID, InstalledOn, Description | Format-Table -AutoSize
} else {
    Write-Host "  Aucun hotfix installé dans les 30 derniers jours" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────────────────────
# 9. EVENT LOG — ERREURS / CRITIQUES
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  EVENT LOG — System + Application (2 dernières heures)"
Write-Host $Sep
$logStart = (Get-Date).AddHours(-2)
foreach ($log in @('System','Application')) {
    Write-Host "  >> $log :"
    try {
        $events = Get-WinEvent -FilterHashtable @{LogName=$log; StartTime=$logStart} -ErrorAction SilentlyContinue |
            Where-Object { $_.LevelDisplayName -in 'Error','Critical' }
        if ($events) {
            $events | Select-Object -First 20 TimeCreated, Id, ProviderName,
                @{N='Message';E={$_.Message.Substring(0,[math]::Min(120,$_.Message.Length))}} |
                Format-Table -Wrap
        } else {
            Write-Host "     ✓ Aucune erreur/critique sur les 2 dernières heures"
        }
    } catch {
        Write-Host "     [À CONFIRMER] Impossible de lire le journal $log" -ForegroundColor Yellow
    }
}

# ─────────────────────────────────────────────────────────────
# 10. RÉSUMÉ RAPIDE
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  RÉSUMÉ RAPIDE — $Phase"
Write-Host $Sep
Write-Host "  Serveur    : $env:COMPUTERNAME"
Write-Host "  Uptime     : $uptimeF"
Write-Host "  RAM        : $ramUsed/$ramTot GB ($ramPct% utilisé)"
Write-Host "  Reboot req : $anyPending"
Write-Host "  Rôles      : $($roles -join ' | ')"
Write-Host "  Billet     : $Billet — Client : $Client"
Write-Host "  Log        : $LogFile"
Write-Host $Sep
Write-Host " "

Stop-Transcript
