# MAINT-WIN-PendingReboot_V2
**Version :** 3.0 | **Date :** 2026-05-21 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** MAINT | **Source :** IT MSP Intelligence Platform

---

**Version :** 3.0 | **Date :** 2026-05-21
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Objectif

**Phase 1 — Script universel :** À exécuter sur TOUT serveur, quel que soit le rôle.
Détecte l'état, les ressources (uptime, CPU, RAM, disques), les flags pending reboot et les rôles actifs.
À la fin, le script affiche le ou les runbooks de Phase 2 à consulter.

**Phase 2 — Runbook par rôle :** Selon le ou les rôles détectés en Phase 1,
consulter le runbook spécialisé associé. Plusieurs rôles = plusieurs runbooks.

---

## PHASE 1 — PRECHECK UNIVERSEL

> Lecture seule — aucun changement. Exécuter via RMM ou PSRemoting.
> Sortie : `Out-String -Width 300 | Write-Output` (compatible N-able, CW Automate, ScreenConnect).

```powershell
# ============================================================
# PHASE 1 — Precheck universel — Pending Reboot / Windows Server
# Version : 3.0 — 2 phases : universel → routing rôle
# Usage   : RMM ou PSRemoting — lecture seule
# Sortie  : Out-String -Width 300 (compatible consoles RMM)
# ============================================================
param(
    [string]$Billet = "[À CONFIRMER]",
    [string]$Client = "[À CONFIRMER]",
    [string]$OutDir = "$env:TEMP\CW_Patching"
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

# ── 1. HOST / OS / UPTIME — OBLIGATOIRE ─────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  HOST / OS / UPTIME — OBLIGATOIRE (documenter dans le billet)"
Write-Host $Sep
$os     = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
$uptimeF = "{0}j {1}h {2}min" -f [int]$uptime.TotalDays, $uptime.Hours, $uptime.Minutes
[pscustomobject]@{
    Hostname   = $env:COMPUTERNAME
    OS         = $os.Caption
    Version    = $os.Version
    Build      = $os.BuildNumber
    LastReboot = $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")
    Uptime     = $uptimeF
    UptimeDays = [math]::Round($uptime.TotalDays, 1)
} | Out-String -Width 300 | Write-Output
Write-Host "  ► OBLIGATOIRE — Documenter LastReboot + Uptime dans le billet avant de procéder." -ForegroundColor Cyan
if ($uptime.TotalDays -gt 30) {
    Write-Host "  ⚠ UPTIME > 30 JOURS — redémarrage probablement requis depuis longtemps" -ForegroundColor Yellow
}

# ── 2. CPU ───────────────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  CPU"
Write-Host $Sep
$cpus = Get-CimInstance Win32_Processor
[pscustomobject]@{
    Modèle      = ($cpus | Select-Object -First 1).Name.Trim()
    Sockets     = ($cpus | Measure-Object).Count
    CoresTotal  = ($cpus | Measure-Object NumberOfCores -Sum).Sum
    LogicalProc = ($cpus | Measure-Object NumberOfLogicalProcessors -Sum).Sum
    "Load%"     = [math]::Round(($cpus | Measure-Object LoadPercentage -Average).Average, 0)
} | Out-String -Width 300 | Write-Output
$cpuLoad = [math]::Round(($cpus | Measure-Object LoadPercentage -Average).Average, 0)
if ($cpuLoad -gt 85) {
    Write-Host "  ⚠ CPU > 85% ($cpuLoad%) — vérifier les processus actifs avant reboot" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ CPU charge : $cpuLoad%"
}

# ── 3. MÉMOIRE RAM ───────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  MÉMOIRE RAM"
Write-Host $Sep
$cs      = Get-CimInstance Win32_ComputerSystem
$ramTot  = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
$ramLib  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$ramUsed = [math]::Round($ramTot - $ramLib, 1)
$ramPct  = [math]::Round(($ramUsed / $ramTot) * 100, 0)
[pscustomobject]@{
    TotalGB = $ramTot; UsedGB = $ramUsed; FreeGB = $ramLib; "Used%" = "$ramPct%"
} | Out-String -Width 300 | Write-Output
if ($ramPct -gt 90) {
    Write-Host "  ⚠ RAM > 90% — vérifier avant intervention" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ RAM : $ramUsed/$ramTot GB ($ramPct% utilisé)"
}

# ── 4. DISQUES ───────────────────────────────────────────────
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
    Out-String -Width 300 | Write-Output
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } | ForEach-Object {
    $pct = [math]::Round($_.Free/($_.Used+$_.Free)*100,0)
    if ($pct -lt 10) { Write-Host "  ⛔ Disque $($_.Name): $pct% libre — CRITIQUE" -ForegroundColor Red }
    elseif ($pct -lt 20) { Write-Host "  ⚠ Disque $($_.Name): $pct% libre — Attention" -ForegroundColor Yellow }
}

# ── 5. PENDING REBOOT FLAGS ──────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  PENDING REBOOT FLAGS"
Write-Host $Sep
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -EA SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'
$anyPending = $CBS -or $WU -or $PFR -or $CCM
[pscustomobject]@{
    CBS_RebootPending           = $CBS
    WU_RebootRequired           = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending      = $CCM
    "-- REBOOT REQUIS --"       = $anyPending
} | Out-String -Width 300 | Write-Output
if ($anyPending) {
    $flagsActifs = @()
    if ($CBS) { $flagsActifs += "CBS" }
    if ($WU)  { $flagsActifs += "WU" }
    if ($PFR) { $flagsActifs += "PFR" }
    if ($CCM) { $flagsActifs += "CCM" }
    Write-Host "  ⚠ FLAGS ACTIFS : $($flagsActifs -join ' · ')" -ForegroundColor Yellow
    if ($CBS -and $WU -and $PFR) {
        Write-Host "  ⚠ 3 FLAGS SIMULTANÉS — 2e reboot peut être nécessaire" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✓ Aucun pending reboot flag actif"
}

# ── 6. DÉTECTION DES RÔLES ───────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  PROFIL SERVEUR — RÔLES DÉTECTÉS"
Write-Host $Sep
$svcDC        = Get-Service -Name 'NTDS'            -EA SilentlyContinue
$svcDNS       = Get-Service -Name 'DNS'             -EA SilentlyContinue
$svcDHCP      = Get-Service -Name 'DHCPServer'      -EA SilentlyContinue
$svcSQL       = Get-Service | Where-Object { $_.Name -match '^MSSQL\$|^MSSQLSERVER$' }
$svcRDS       = Get-Service -Name 'TermService'     -EA SilentlyContinue
$svcPrint     = Get-Service -Name 'Spooler'         -EA SilentlyContinue
$svcIIS       = Get-Service -Name 'W3SVC'           -EA SilentlyContinue
$svcExchTrans = Get-Service -Name 'MSExchangeTransport' -EA SilentlyContinue
$svcExchIS    = Get-Service -Name 'MSExchangeIS'    -EA SilentlyContinue
$svcVeeam     = Get-Service | Where-Object { $_.Name -match 'VeeamBackup|VeeamNFS' }
$svcHyperV    = Get-Service -Name 'vmms'            -EA SilentlyContinue
$svcWsus      = Get-Service -Name 'WsusService'     -EA SilentlyContinue
$svcSCCM      = Get-Service -Name 'SMS_EXECUTIVE'   -EA SilentlyContinue
$svcFSRM      = Get-Service -Name 'srmsvc'          -EA SilentlyContinue
$roles = @()
if ($svcDC    -and $svcDC.Status    -eq 'Running') { $roles += "DOMAIN CONTROLLER (AD DS)" }
if ($svcDNS   -and $svcDNS.Status   -eq 'Running') { $roles += "DNS SERVER" }
if ($svcDHCP  -and $svcDHCP.Status  -eq 'Running') { $roles += "DHCP SERVER" }
if ($svcSQL)                                        { $roles += "SQL SERVER ($($svcSQL.Name -join ', '))" }
if ($svcRDS   -and $svcRDS.Status   -eq 'Running') { $roles += "REMOTE DESKTOP SERVICES (RDS)" }
if ($svcPrint -and $svcPrint.Status -eq 'Running') { $roles += "PRINT SERVER" }
if ($svcIIS   -and $svcIIS.Status   -eq 'Running') { $roles += "IIS / WEB SERVER" }
if ($svcExchTrans -or $svcExchIS)                   { $roles += "EXCHANGE SERVER" }
if ($svcVeeam)                                      { $roles += "VEEAM BACKUP SERVER" }
if ($svcHyperV -and $svcHyperV.Status -eq 'Running') { $roles += "HYPER-V HOST" }
if ($svcWsus  -and $svcWsus.Status  -eq 'Running') { $roles += "WSUS SERVER" }
if ($svcSCCM  -and $svcSCCM.Status  -eq 'Running') { $roles += "SCCM / MECM SERVER" }
if ($svcFSRM  -and $svcFSRM.Status  -eq 'Running') { $roles += "FILE SERVER (FSRM)" }
if ($roles.Count -eq 0)                             { $roles += "SERVEUR MEMBRE (rôle non détecté)" }
Write-Host "  RÔLES DÉTECTÉS : $($roles -join ' | ')"

# ── 7. SESSIONS UTILISATEURS + SMB (tous serveurs) ───────────
Write-Host " "
Write-Host $Sep
Write-Host "  SESSIONS ET FICHIERS OUVERTS — CRITIQUE AVANT REBOOT" -ForegroundColor Yellow
Write-Host $Sep
try {
    $queryOut = query user 2>&1
    $queryOut | ForEach-Object { Write-Host "     $_" }
    $sessionCount = ($queryOut | Where-Object { $_ -match "Active|Disc" } | Measure-Object).Count
    if ($sessionCount -gt 0) {
        Write-Host "  ⛔ $sessionCount SESSION(S) ACTIVE(S) — aviser les utilisateurs avant reboot" -ForegroundColor Red
    } else {
        Write-Host "  ✓ Aucune session utilisateur active"
    }
} catch { Write-Host "  [À CONFIRMER] query user indisponible" -ForegroundColor Yellow }

try {
    $smbSessions = Get-SmbSession -EA SilentlyContinue
    $smbCount    = ($smbSessions | Measure-Object).Count
    if ($smbCount -gt 0) {
        Write-Host "  ⛔ $smbCount SESSION(S) SMB ACTIVE(S)" -ForegroundColor Red
        $smbSessions | Select-Object ClientComputerName, ClientUserName,
            @{N="FilesOpen"; E={$_.NumOpens}} |
            Sort-Object FilesOpen -Descending |
            Out-String -Width 300 | Write-Output
    } else {
        Write-Host "  ✓ Aucune session SMB active"
    }
} catch { Write-Host "  [À CONFIRMER] Get-SmbSession indisponible" -ForegroundColor Yellow }

# ── 8. BACKUP EN COURS (tous serveurs) ───────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  BACKUP EN COURS — CRITIQUE AVANT REBOOT" -ForegroundColor Yellow
Write-Host $Sep
$backupBloquant = $false
$wbe = Get-Process -Name "wbengine" -EA SilentlyContinue
if ($wbe) {
    $backupBloquant = $true
    Write-Host "  ⛔ WINDOWS SERVER BACKUP EN COURS (PID $($wbe.Id) — $([int]((Get-Date)-$wbe.StartTime).TotalMinutes) min)" -ForegroundColor Red
} else {
    Write-Host "  ✓ Aucun Windows Server Backup en cours"
}
$veeamProcs = Get-Process -EA SilentlyContinue | Where-Object { $_.Name -match "VeeamAgent|VeeamGuestHelper|VeeamTransport" }
if ($veeamProcs) {
    $backupBloquant = $true
    Write-Host "  ⛔ PROCESSUS VEEAM ACTIFS — job probablement en cours" -ForegroundColor Red
    $veeamProcs | Select-Object Name, Id, @{N='DuréeMin';E={[int]((Get-Date)-$_.StartTime).TotalMinutes}} |
        Out-String -Width 300 | Write-Output
} else {
    Write-Host "  ✓ Aucun processus Veeam de transfert détecté"
}
try {
    Add-PSSnapin VeeamPSSnapIn -EA Stop
    $runningJobs = Get-VBRBackupSession | Where-Object { $_.State -in @("Working","Postprocessing") }
    if ($runningJobs) {
        $backupBloquant = $true
        Write-Host "  ⛔ JOBS VEEAM EN COURS (module PS) :" -ForegroundColor Red
        $runningJobs | Select-Object Name, JobType, State | Out-String -Width 300 | Write-Output
    }
} catch {}
if ($backupBloquant) {
    Write-Host "  ⛔ BACKUP EN COURS — NE PAS REBOUTER" -ForegroundColor Red
} else {
    Write-Host "  ✓ Aucun backup bloquant détecté"
}

# ── 9. SERVICES AUTO NON DÉMARRÉS ────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SERVICES AUTOMATIQUES NON DÉMARRÉS"
Write-Host $Sep
$svcStop = Get-Service | Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' }
if ($svcStop) {
    $svcStop | Select-Object Name, DisplayName, Status | Out-String -Width 300 | Write-Output
} else {
    Write-Host "  ✓ Tous les services automatiques sont démarrés"
}

# ── 10. HOTFIXES RÉCENTS (30 derniers jours) ──────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  HOTFIXES RÉCENTS (30 derniers jours)"
Write-Host $Sep
$hotfixes = Get-HotFix | Where-Object { $_.InstalledOn -gt (Get-Date).AddDays(-30) } | Sort-Object InstalledOn -Descending
if ($hotfixes) {
    $hotfixes | Select-Object HotFixID, InstalledOn, Description | Out-String -Width 300 | Write-Output
} else {
    Write-Host "  Aucun hotfix installé dans les 30 derniers jours" -ForegroundColor Yellow
}

# ── 11. EVENT LOG — System + Application (2h) ─────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  EVENT LOG — System + Application (2 dernières heures)"
Write-Host $Sep
$logStart = (Get-Date).AddHours(-2)
foreach ($log in @('System','Application')) {
    Write-Host "  >> $log :"
    try {
        $events = Get-WinEvent -FilterHashtable @{LogName=$log; StartTime=$logStart} -EA SilentlyContinue |
            Where-Object { $_.LevelDisplayName -in 'Error','Critical' }
        if ($events) {
            $events | Select-Object -First 20 TimeCreated, Id, ProviderName,
                @{N='Message';E={$_.Message.Substring(0,[math]::Min(120,$_.Message.Length))}} |
                Out-String -Width 300 | Write-Output
        } else {
            Write-Host "     ✓ Aucune erreur/critique sur les 2 dernières heures"
        }
    } catch { Write-Host "     [À CONFIRMER] Impossible de lire le journal $log" -ForegroundColor Yellow }
}

# ── 12. RÉSUMÉ + ROUTING PHASE 2 ──────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  RÉSUMÉ PHASE 1 — $Phase"
Write-Host $Sep
Write-Host "  Serveur  : $env:COMPUTERNAME"
Write-Host "  Billet   : $Billet — Client : $Client"
Write-Host "  LastBoot : $($os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm')) — Uptime : $uptimeF"
Write-Host "  CPU      : $cpuLoad%  |  RAM : $ramUsed/$ramTot GB ($ramPct%)"
Write-Host "  Reboot   : $anyPending"
Write-Host "  Rôles    : $($roles -join ' | ')"
Write-Host "  Log      : $LogFile"
Write-Host " "

# Routing automatique Phase 2
Write-Host $Sep
Write-Host "  ROUTING — PHASE 2 (runbooks à consulter selon rôle)"
Write-Host $Sep
$routingMap = [ordered]@{
    'DOMAIN CONTROLLER' = 'INFRA-AD-DC_PrePost_Validation_V2'
    'DNS SERVER'        = 'INFRA-AD-DC_PrePost_Validation_V2'
    'HYPER-V HOST'      = 'INFRA-SRV-HyperV_Operations_V2 (Section 5 — Precheck reboot)'
    'SQL SERVER'        = 'INFRA-SRV-SQL_PrePost_Validation_V2'
    'REMOTE DESKTOP'    = 'INFRA-SRV-RDS_Operations_V2'
    'PRINT SERVER'      = 'MAINT-SRV-PrintServer_PrePost_V1'
    'VEEAM'             = 'INFRA-BACKUP-Veeam_Operations_V2 (vérifier jobs actifs)'
    'EXCHANGE'          = 'Section inline Phase 2 ci-dessous'
    'WSUS'              = 'Section inline Phase 2 ci-dessous'
    'IIS'               = 'Section inline Phase 2 ci-dessous'
}
$routed = $false
foreach ($role in $roles) {
    foreach ($key in $routingMap.Keys) {
        if ($role -match $key) {
            Write-Host ("  → {0,-35} : {1}" -f $role, $routingMap[$key]) -ForegroundColor Cyan
            $routed = $true
        }
    }
}
if (!$routed) {
    Write-Host "  ✓ Serveur membre — aucune Phase 2 requise. Procéder si GO." -ForegroundColor Green
}
Write-Host $Sep

Stop-Transcript
```

---

## Décision GO / NO-GO

| Condition détectée | Décision | Action requise |
|---|---|---|
| Sessions utilisateurs actives | ⛔ **NO-GO** | Aviser les utilisateurs — attendre fermeture ou acceptation écrite |
| Fichiers ouverts sur partages SMB | ⛔ **NO-GO** | Aviser les utilisateurs — attendre fermeture ou acceptation écrite |
| Backup en cours (wbengine / Veeam) | ⛔ **NO-GO** | Attendre la fin du backup — ne jamais interrompre |
| Rôle DC sans validation réplication | ⛔ **NO-GO** | Consulter `INFRA-AD-DC_PrePost_Validation_V2` d'abord |
| Rôle Hyper-V avec VMs Running | ⛔ **NO-GO** | Migrer/arrêter les VMs — consulter `INFRA-SRV-HyperV_Operations_V2` |
| Services critiques arrêtés (préexistants) | ⚠ **HOLD** | Valider avec le client avant de rebooter |
| Aucune des conditions ci-dessus | ✅ **GO** | Reboot autorisé après approbation explicite |

**Règle absolue :** en cas de NO-GO, l'agent génère un message clair et attend la confirmation.
Il ne procède jamais au reboot automatiquement.

**Si sessions/fichiers ouverts et client accepte quand même :**
`⚠ Reboot effectué avec sessions actives — client informé et approbation reçue à [HH:MM]`

---

## ROUTING — Phase 2 (table de référence)

| Rôle détecté | Runbook Phase 2 |
|---|---|
| DOMAIN CONTROLLER | `INFRA-AD-DC_PrePost_Validation_V2` |
| DNS SERVER | `INFRA-AD-DC_PrePost_Validation_V2` (DNS checks inclus) |
| HYPER-V HOST | `INFRA-SRV-HyperV_Operations_V2` — Section 5 (precheck reboot) |
| SQL SERVER | `INFRA-SRV-SQL_PrePost_Validation_V2` |
| REMOTE DESKTOP SERVICES | `INFRA-SRV-RDS_Operations_V2` |
| PRINT SERVER | `MAINT-SRV-PrintServer_PrePost_V1` |
| VEEAM BACKUP SERVER | `INFRA-BACKUP-Veeam_Operations_V2` |
| EXCHANGE SERVER | Section inline Phase 2 ci-dessous |
| WSUS / SCCM | Section inline Phase 2 ci-dessous |
| IIS / WEB SERVER | Section inline Phase 2 ci-dessous |
| SERVEUR MEMBRE | Aucune Phase 2 requise — GO si Phase 1 OK |

> **Rôles multiples (ex. Hyper-V + Veeam) :** consulter chaque runbook associé.
> Le rôle le plus critique conditionne le GO/NO-GO final.

---

## REBOOT (manuel)

> Faire **uniquement** après approbation explicite.
> `shutdown /r` enregistre dans l'**Event ID 1074** (System log) — traçabilité complète.

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

> **Codes raison :** `p:4:1` = Maintenance planifiée (défaut MSP) · `p:2:4` = Reconfiguration OS

---

## POSTCHECK — OBLIGATOIRE après reboot

Relancer la Phase 1 avec le paramètre POST, puis documenter dans le billet.

```powershell
# Vérification uptime post-reboot
Get-CimInstance Win32_OperatingSystem |
    Select-Object CSName, Caption, Version,
        @{N='LastBoot';E={$_.LastBootUpTime}},
        @{N='UptimeDays';E={[math]::Round(((Get-Date)-$_.LastBootUpTime).TotalDays,2)}},
        @{N='UptimeHours';E={[math]::Round(((Get-Date)-$_.LastBootUpTime).TotalHours,2)}} |
    Out-String -Width 300 | Write-Output
```

**Critères attendus :**
- `LastBoot` = date/heure du redémarrage effectué (récente) ✓
- `UptimeDays` proche de `0` — confirme que le reboot a bien eu lieu ✓

> ⛔ Si `LastBoot` ne correspond pas ou `UptimeDays` > 1 → le serveur n'a pas redémarré — investiguer avant de fermer le billet.

---

## PHASE 2 — Checks inline (rôles sans runbook dédié)

> Consulter ces sections uniquement si le rôle a été détecté en Phase 1
> et qu'aucun runbook dédié n'existe pour ce rôle.

### Exchange Server

```powershell
Write-Host "=== EXCHANGE SERVER — Checks spécifiques ===" -ForegroundColor Cyan
@('MSExchangeTransport','MSExchangeIS','MSExchangeADTopology',
  'MSExchangeFrontEndTransport','MSExchangeMailboxAssistants') | ForEach-Object {
    $s = Get-Service -Name $_ -EA SilentlyContinue
    if ($s) {
        $color = if ($s.Status -eq 'Running') { 'Green' } else { 'Red' }
        Write-Host "  $($_.PadRight(40)) $($s.Status)" -ForegroundColor $color
    }
}
Write-Host "  >> ⚠ Vérifier les queues de transport avant reboot"
Write-Host "     Commande (Exchange Management Shell) : Get-Queue"
```

### WSUS Server

```powershell
Write-Host "=== WSUS — Checks spécifiques ===" -ForegroundColor Cyan
$wsus = Get-Service -Name 'WsusService' -EA SilentlyContinue
if ($wsus) {
    Write-Host "  WsusService : $($wsus.Status)"
    Write-Host "  >> Vérifier qu'aucune synchronisation ou approbation n'est en cours"
    Write-Host "     Console WSUS → Synchronizations / Approvals avant reboot"
}
```

### IIS / Web Server

```powershell
Write-Host "=== IIS — Checks spécifiques ===" -ForegroundColor Cyan
try {
    Import-Module WebAdministration -EA Stop
    Get-WebSite | Select-Object Name, State, PhysicalPath |
        Out-String -Width 300 | Write-Output
    Write-Host "  >> Vérifier qu'aucune transaction critique n'est en cours"
} catch {
    Write-Host "  Module WebAdministration non disponible — vérification manuelle" -ForegroundColor Yellow
}
```

---

## Si pending reboot reste TRUE après reboot

- Noter quel flag reste TRUE (CBS / WU / PFR / CCM).
- Vérifier Windows Update en attente (re-scan / redémarrage additionnel).
- Si CBS persiste après 2 reboots → investiguer corruption WinSxS.
- Escalader si CBS reste actif après 2 cycles complets.
