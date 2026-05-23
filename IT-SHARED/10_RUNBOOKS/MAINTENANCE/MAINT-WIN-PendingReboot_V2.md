# MAINT-WIN-PendingReboot_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** MAINT | **Source :** IT MSP Intelligence Platform

---

**Version :** 2.1 | **Date :** 2026-04-18
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Objectif
- Confirmer **pourquoi** le pending reboot est levé (CBS/WU/PendingFileRename/CCM).
- Appliquer un reboot **contrôlé** (si approuvé) et **re-valider**.

## PRECHECK — identifie la source

> Ce script détecte les flags de pending reboot, le profil du serveur (rôles),
> l'uptime, la RAM, les disques et les services critiques selon le rôle.

```powershell

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

Write-Host "  ► OBLIGATOIRE — Relever et documenter dans le billet :" -ForegroundColor Cyan
Write-Host "    · Last restart / LastBootUpTime : $($os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm'))"
Write-Host "    · Uptime actuel                 : $uptimeF"
Write-Host "    Ces deux valeurs doivent être revalidées en POSTCHECK après le redémarrage." -ForegroundColor Cyan

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
# 6H. SESSIONS UTILISATEURS ET FICHIERS OUVERTS
#     ⚠ CRITIQUE — RISQUE DE PERTE DE DONNÉES AVANT REBOOT
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  ⚠ SESSIONS ET FICHIERS OUVERTS — CRITIQUE AVANT REBOOT" -ForegroundColor Yellow
Write-Host $Sep

# Sessions locales et RDS (toujours, quel que soit le rôle)
Write-Host "  >> Sessions utilisateurs actives (locales + RDS) :"
try {
    $queryOut = query user 2>&1
    $hasActiveSessions = $false
    $queryOut | ForEach-Object { Write-Host "     $_" }
    if ($queryOut -match "\s+Active\s+|\s+Disc\s+") {
        $hasActiveSessions = $true
        $sessionCount = ($queryOut | Where-Object { $_ -match "Active|Disc" } | Measure-Object).Count
        Write-Host "  ⛔ $sessionCount SESSION(S) ACTIVE(S) — aviser les utilisateurs avant reboot" -ForegroundColor Red
        Write-Host "     Risque : travail non sauvegardé, processus interrompus, perte de données" -ForegroundColor Red
    } else {
        Write-Host "  ✓ Aucune session utilisateur active"
    }
} catch {
    Write-Host "  [À CONFIRMER] query user indisponible — vérifier manuellement" -ForegroundColor Yellow
}

# Sessions SMB réseau (partages)
Write-Host " "
Write-Host "  >> Sessions SMB réseau actives (partages) :"
try {
    $smbSessions = Get-SmbSession -ErrorAction SilentlyContinue
    if ($smbSessions -and ($smbSessions | Measure-Object).Count -gt 0) {
        $smbCount = ($smbSessions | Measure-Object).Count
        Write-Host "  ⛔ $smbCount SESSION(S) SMB ACTIVE(S)" -ForegroundColor Red
        Write-Host "     Risque : fichiers ouverts sur partages réseau — perte de données possible" -ForegroundColor Red
        $smbSessions | Select-Object ClientComputerName, ClientUserName,
            @{N="FichiersOuverts"; E={$_.NumOpens}},
            @{N="ConnexionSec";    E={[int]$_.SecondsActive}} |
            Sort-Object FichiersOuverts -Descending |
            Format-Table -AutoSize
    } else {
        Write-Host "  ✓ Aucune session SMB active"
    }
} catch {
    Write-Host "  [À CONFIRMER] Get-SmbSession indisponible" -ForegroundColor Yellow
}

# Fichiers ouverts sur partages réseau
Write-Host " "
Write-Host "  >> Fichiers ouverts sur les partages réseau :"
try {
    $openFiles = Get-SmbOpenFile -ErrorAction SilentlyContinue
    if ($openFiles -and ($openFiles | Measure-Object).Count -gt 0) {
        $fileCount = ($openFiles | Measure-Object).Count
        Write-Host "  ⛔ $fileCount FICHIER(S) OUVERT(S) SUR LES PARTAGES" -ForegroundColor Red
        Write-Host "     → Aviser les utilisateurs de sauvegarder avant le reboot" -ForegroundColor Red
        $openFiles |
            Select-Object ClientComputerName, ClientUserName,
                @{N="Fichier"; E={ ($_.Path -split '\')[-1] }},
                @{N="Chemin";  E={ $_.Path }} |
            Sort-Object ClientUserName |
            Select-Object -First 30 |
            Format-Table -AutoSize
        if ($fileCount -gt 30) {
            Write-Host "  ... (affichage limité à 30 — total : $fileCount fichiers)"
        }
    } else {
        Write-Host "  ✓ Aucun fichier ouvert sur les partages"
    }
} catch {
    Write-Host "  [À CONFIRMER] Get-SmbOpenFile indisponible" -ForegroundColor Yellow
}

# ─────────────────────────────────────────────────────────────
# 6I. PROCESSUS DE BACKUP EN COURS
#     ⚠ CRITIQUE — NE PAS REBOOTER SI BACKUP EN COURS
# ─────────────────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  ⚠ BACKUP EN COURS — CRITIQUE AVANT REBOOT" -ForegroundColor Yellow
Write-Host $Sep

$backupBloquant = $false

# Windows Server Backup (wbengine)
Write-Host "  >> Windows Server Backup (wbengine) :"
$wbengine = Get-Process -Name "wbengine" -ErrorAction SilentlyContinue
if ($wbengine) {
    $backupBloquant = $true
    $wbDuree = [int]((Get-Date) - $wbengine.StartTime).TotalMinutes
    Write-Host "  ⛔ WINDOWS SERVER BACKUP EN COURS (PID $($wbengine.Id) — $wbDuree min)" -ForegroundColor Red
    Write-Host "     → NE PAS redémarrer — attendre la fin du backup" -ForegroundColor Red
} else {
    Write-Host "  ✓ Aucun backup Windows Server en cours"
}

# Veeam — détection via processus (sans module)
Write-Host " "
Write-Host "  >> Veeam — jobs en cours (détection via processus) :"
$veeamProcs = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match "Veeam|VeeamAgent|VeeamGuestHelper|VeeamTransport"
}
if ($veeamProcs) {
    $jobsVeeam = $veeamProcs | Where-Object { $_.Name -match "VeeamAgent|VeeamGuestHelper|VeeamTransport" }
    if ($jobsVeeam) {
        $backupBloquant = $true
        Write-Host "  ⛔ PROCESSUS VEEAM ACTIFS — JOB PROBABLEMENT EN COURS" -ForegroundColor Red
        Write-Host "     → Vérifier console Veeam B&R → Jobs → Running avant reboot" -ForegroundColor Red
        $jobsVeeam | Select-Object Name, Id, CPU,
            @{N="DuréeMin"; E={[int]((Get-Date) - $_.StartTime).TotalMinutes}} |
            Format-Table -AutoSize
    } else {
        Write-Host "  ✓ Services Veeam actifs — aucun job de transfert détecté"
        Write-Host "     Confirmer dans la console Veeam que Jobs = Idle avant de rebooter"
    }
} else {
    Write-Host "  ✓ Aucun processus Veeam détecté"
}

# Tentative module Veeam (si disponible)
try {
    Add-PSSnapin VeeamPSSnapIn -ErrorAction Stop
    $runningJobs = Get-VBRBackupSession -ErrorAction SilentlyContinue |
        Where-Object { $_.State -in @("Working","Postprocessing") }
    if ($runningJobs) {
        $backupBloquant = $true
        Write-Host " "
        Write-Host "  ⛔ JOBS VEEAM EN COURS (via module PS) :" -ForegroundColor Red
        $runningJobs | Select-Object Name, JobType, State,
            @{N="DuréeMin"; E={[int]((Get-Date) - $_.CreationTime).TotalMinutes}} |
            Format-Table -AutoSize
    }
} catch {}

# Agents tiers (Datto, Acronis, Backup Exec, Commvault)
Write-Host " "
Write-Host "  >> Agents de backup tiers :"
$backupAgents = @{
    "CagService"        = "Datto BCDR Agent"
    "ShadowProtectSvc"  = "StorageCraft ShadowProtect"
    "BackupExecAgentBrowser" = "Veritas Backup Exec"
    "GxCVD"             = "Commvault"
    "AcronisAgent"      = "Acronis Backup"
    "AcrSch2Svc"        = "Acronis Scheduler"
}
$agentsTrouves = @()
foreach ($svcName in $backupAgents.Keys) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        $agentsTrouves += "$($backupAgents[$svcName]) ($svcName)"
    }
}
if ($agentsTrouves) {
    Write-Host "  ⚠ Agents de backup actifs détectés :" -ForegroundColor Yellow
    $agentsTrouves | ForEach-Object { Write-Host "     → $_" }
    Write-Host "     Vérifier qu'aucun job n'est en cours avant le reboot"
} else {
    Write-Host "  ✓ Aucun agent de backup tiers détecté en cours d'exécution"
}

# Récapitulatif backup
Write-Host " "
if ($backupBloquant) {
    Write-Host "  ⛔ BACKUP EN COURS — REBOOT BLOQUÉ" -ForegroundColor Red
    Write-Host "     Attendre la fin du backup avant de procéder" -ForegroundColor Red
} else {
    Write-Host "  ✓ Aucun backup bloquant détecté"
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

```


## Décision avant reboot — TABLE GO / NO-GO

> L'agent doit présenter cette table après le precheck et attendre la confirmation.

| Condition détectée | Décision | Action requise |
|---|---|---|
| Sessions utilisateurs actives | ⛔ **NO-GO** | Aviser les utilisateurs — attendre fermeture ou acceptation écrite |
| Fichiers ouverts sur partages SMB | ⛔ **NO-GO** | Aviser les utilisateurs — attendre fermeture ou acceptation écrite |
| Backup en cours (wbengine / Veeam / agent) | ⛔ **NO-GO** | Attendre la fin du backup — ne jamais interrompre |
| Serveur DC — sans validation réplication | ⛔ **NO-GO** | Exécuter runbook DC PrePost avant de procéder |
| Services critiques arrêtés (préexistants) | ⚠ **HOLD** | Valider avec le client avant de rebooter |
| Aucune des conditions ci-dessus | ✅ **GO** | Reboot autorisé après approbation explicite du technicien |

**Règle absolue :** en cas de NO-GO, l'agent génère un message clair et attend une réponse.
Il ne procède jamais au reboot automatiquement.

**Si sessions/fichiers ouverts et client accepte quand même le reboot :**
Documenter explicitement dans la Note Interne :
`⚠ Reboot effectué avec sessions actives — client informé et approbation reçue à [HH:MM]`

## REBOOT (manuel)
> Faire **uniquement** après approbation.
> `shutdown /r` enregistre le billet et la raison dans l'**Event ID 1074** du System log — traçabilité complète.

```powershell
# ── Depuis le serveur ──────────────────────────────────────
$ticket = "#XXXXX"
$raison = "Pending reboot — [CBS / WindowsUpdate / PendingFileRename]"
shutdown /r /t 0 /c "Billet $ticket — $raison" /d p:4:1

# ── Depuis un poste admin (remote) ────────────────────────
Invoke-Command -ComputerName "SRV-NAME" -ScriptBlock {
    param($t, $r)
    shutdown /r /t 0 /c "Billet $t — $r" /d p:4:1
} -ArgumentList "#XXXXX", "Pending reboot — [raison]"
```

> **Codes raison courants :**
> `p:4:1` = Maintenance planifiée (défaut MSP) · `p:2:4` = Reconfiguration OS · `p:2:17` = Service Pack

## POSTCHECK
Rejouer le PRECHECK + valider les services critiques.

### Uptime / Last restart — OBLIGATOIRE après reboot

Documenter explicitement dans le billet après le redémarrage :

```powershell
Get-CimInstance Win32_OperatingSystem |
    Select-Object CSName, Caption, Version,
        @{N='LastBoot';E={$_.LastBootUpTime}},
        @{N='UptimeDays';E={[math]::Round(((Get-Date)-$_.LastBootUpTime).TotalDays,2)}},
        @{N='UptimeHours';E={[math]::Round(((Get-Date)-$_.LastBootUpTime).TotalHours,2)}} |
    Format-List
```

**Critères attendus après reboot :**
- `LastBoot` = date/heure du redémarrage effectué (récente)
- `UptimeDays` proche de `0` — confirme que le reboot a bien eu lieu

> ⛔ Si `LastBoot` ne correspond pas au redémarrage effectué ou si `UptimeDays` > 1 → le serveur n'a pas redémarré comme prévu — investiguer avant de fermer le billet.

## Si pending reboot reste TRUE
- Noter quel flag reste TRUE.
- Vérifier :
  - Windows Update en attente (re-scan / redémarrage additionnel)
  - Installer/rollback en cours
  - Software distribution corruption
- Escalader si 2 reboots n'éteignent pas le flag **CBS**.
