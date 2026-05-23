# MAINT-WIN-Patching_Complet_V3
**Version :** 3.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Assistant-N3 | @IT-Commandare-NOC
**Département :** MAINTENANCE | **Domaine :** WIN (Windows Patching)
**Standards :** CIS Controls, NIST SP 800-40, ConnectWise RMM

---

## OBJECTIF

Procédure complète de patching Windows Server en environnement MSP.
Couvre : phases de déploiement, prioritisation CVSS, validation precheck/postcheck,
rollback, et conformité multi-client.

---

## MODÈLE DE DÉPLOIEMENT PAR PHASES (Best Practice MSP 2025)

> **Principe :** Ne jamais déployer sur tous les systèmes simultanément.
> Veeam / Datto confirme que 22% des incidents proviennent de patches non testés (2025 DBIR).

| Phase | Cible | Délai après Patch Tuesday | Critère de passage |
|---|---|---|---|
| 0 — Test | VM de test / Lab | J+0 (dès sortie) | Validation fonctionnelle 48h |
| 1 — Pilote | 10% des serveurs non-critiques | J+3 | 0 incident majeur 48h |
| 2 — Standard | 70% des serveurs | J+7 | 0 régression observée |
| 3 — Critique | DC, SQL, Exchange | J+14 | Après validation complète |
| 4 — Exceptions | Systèmes legacy / hors standard | Au cas par cas | Approbation EA |

---

## PRIORITISATION PAR SCORE CVSS

| Score CVSS | Catégorie | Délai de déploiement |
|---|---|---|
| 9.0–10.0 | Critique | 72h maximum (hors-cycle si nécessaire) |
| 7.0–8.9 | Élevé | 7 jours |
| 4.0–6.9 | Moyen | Prochain cycle mensuel |
| 0.1–3.9 | Faible | Trimestriel |

---

**ID :** RUNBOOK__Windows_Patching_COMPLET_V2
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Assistant-N3
**Scope :** Patching Windows Server — planification, exécution CW RMM (1 serveur à la fois), postcheck, pending reboot, rollback
**Version :** 3.0 | **Date :** 2026-04-13

---

## SECTIONS
1. [Pré-patching (T-7 jours)](#1-pré-patching)
2. [Exécution CW RMM — 1 serveur à la fois](#2-exécution-cw-rmm--1-serveur-à-la-fois) ← **Usage quotidien MSP**
3. [Exécution batch (multi-serveurs)](#3-exécution-batch-multi-serveurs) ← Environnements nombreux
4. [Pending Reboot — Diagnostic et résolution](#4-pending-reboot--diagnostic-et-résolution)
5. [Rollback](#5-rollback)
6. [Reporting et clôture CW](#6-reporting-et-clôture-cw)

---

## 1. PRÉ-PATCHING (T-7 jours)

### 1.1 Inventaire et planification

- [ ] Identifier les serveurs à patcher (par criticité)
- [ ] Vérifier le calendrier de change (blackout windows)
- [ ] Confirmer l'ordre de traitement recommandé :
  ```
  SQL → App/Web → Print → File → DC (en dernier)
  ```
- [ ] Notifier les stakeholders (fenêtre de maintenance, impact)
- [ ] Valider les backups récents (< 24h) sur tous les serveurs cibles
- [ ] Confirmer la réplication AD OK (si DC concerné)

### 1.2 Precheck automatisé (T-7j ou veille)

```powershell
param([string[]]$Servers = @("SRV01","SRV02","SRV03"))

foreach ($Server in $Servers) {
    Write-Host " " 
    Write-Host "=== Validation $Server ===" 
    
    # Espace disque C: (minimum 10 GB libre)
    $Disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='C:'"
    $FreeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
    Write-Host "Espace libre C: $FreeGB GB"

    # Pending reboot
    $PendingReboot = Invoke-Command -ComputerName $Server -ScriptBlock {
        Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    }
    Write-Host "Reboot pending: $PendingReboot"

    # Service Windows Update
    $WUService = Get-Service -ComputerName $Server -Name wuauserv
    Write-Host "WU Service: $($WUService.Status)"
    Write-Host " " 
}
```

---

## 2. EXÉCUTION CW RMM — 1 SERVEUR À LA FOIS

> **Usage MSP standard.** Principe non négociable :
> - Lecture seule → patching → reboot (si requis) → postcheck
> - **1 seul serveur critique à la fois** (DC / SQL / RDS / ERP)
> - Aucun script qui redémarre une liste automatiquement

### 2.1 Préparation

```powershell
# Créer le dossier de preuves
$BaseOut = "$env:TEMP\CW_Patching"
New-Item -ItemType Directory -Path $BaseOut -Force | Out-Null
```

### 2.2 PRECHECK (avant patching)

> Exécuter sur **le serveur ciblé** via RMM ou session admin.
> Lit le profil complet : HOST · UPTIME · RAM · DISQUES · PENDING REBOOT · **RÔLES DÉTECTÉS** · checks conditionnels par rôle · Event Log.

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

```

> ℹ️ Le script détecte automatiquement les rôles (DC, SQL, RDS, Print, Exchange, Hyper-V, Veeam)
> et exécute les validations spécifiques à chaque rôle détecté.
> Adapter les paramètres `-Billet` et `-Client` avant exécution.

### 2.3 PATCHING (via CW RMM)

- Déclencher l'installation des updates (CU + sécurité) via **CW RMM**.
- **Ne pas** redémarrer automatiquement un serveur critique sans approbation explicite.

### 2.4 REBOOT (si requis)

Avant de redémarrer :
- [ ] Confirmer les sessions actives (RDS / utilisateurs)
- [ ] Confirmer les dépendances (services dépendants sur d'autres serveurs)
- [ ] Obtenir l'approbation (si prod critique)

> `shutdown /r` enregistre le billet et la raison dans l'**Event ID 1074** du System log — traçabilité complète.

```powershell
# ── Depuis le serveur lui-même ─────────────────────────────
$ticket = "#XXXXX"
$raison = "Patching mensuel Windows"
shutdown /r /t 0 /c "Billet $ticket — $raison" /d p:4:1

# ── Depuis un poste admin (remote) ────────────────────────
Invoke-Command -ComputerName "SRV-NOM" -ScriptBlock {
    param($t, $r)
    shutdown /r /t 0 /c "Billet $t — $r" /d p:4:1
} -ArgumentList "#XXXXX", "Patching mensuel Windows"
```

> **Codes raison courants :**
> `p:4:1` = Maintenance planifiée (défaut MSP) · `p:2:4` = Reconfiguration OS · `p:2:17` = Service Pack

### 2.5 POSTCHECK (après reboot ou après patch)

> Même script que le PRECHECK — passer le paramètre `POST` pour identifier la phase dans le log.
> Valide : uptime mis à jour · RAM · disques · flags pending reboot effacés · rôles OK · Event Log post-reboot.

```powershell
# Exécuter le même script avec flag POST
# Copier le script PRECHECK_POSTCHECK_V3.ps1 et lancer :
.\SCRIPT_PRECHECK_POSTCHECK_V3.ps1 -Billet "#[XXXXX]" -Client "[Client]" POST
```

**Points de validation post-reboot :**
- [ ] Uptime remis à zéro (dernier reboot = maintenant)
- [ ] Flags CBS / WU / PFR effacés (ou noter lesquels restent actifs)
- [ ] RAM revenue à la normale
- [ ] Tous les services automatiques démarrés
- [ ] Aucune erreur/critique dans les logs post-reboot
- [ ] Rôles spécifiques validés (DC → réplication, SQL → instances running, RDS → accessible)
- [ ] Si flag CBS reste actif après reboot → prévoir un 2e reboot


---

## 3. EXÉCUTION BATCH (MULTI-SERVEURS)

> Pour les environnements avec de nombreux serveurs non-critiques.
> **Ne jamais utiliser sur DC / SQL / RDS sans supervision.**

### 3.1 Snapshot pré-patch (Azure VMs)

```powershell
param([string]$VMName, [string]$ResourceGroup = "RG-PROD")

$VM   = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
$Disk = Get-AzDisk -ResourceGroupName $VM.ResourceGroupName -DiskName $VM.StorageProfile.OsDisk.Name

$SnapshotConfig = New-AzSnapshotConfig `
    -SourceUri $Disk.Id `
    -CreateOption Copy `
    -Location $VM.Location

$SnapshotName = "$VMName-snap-$(Get-Date -Format yyyyMMddHHmm)"
New-AzSnapshot -Snapshot $SnapshotConfig -SnapshotName $SnapshotName -ResourceGroupName $ResourceGroup
Write-Host " " 
Write-Host "Snapshot cree: $SnapshotName"
```

### 3.2 Installation patches (PSWindowsUpdate)

```powershell
param([string[]]$Servers)

foreach ($Server in $Servers) {
    Write-Host " " 
    Write-Host "=== Patching $Server ==="
    Invoke-Command -ComputerName $Server -ScriptBlock {
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -AcceptAll -Install -Category 'Critical Updates','Security Updates' -AutoReboot:$false -Verbose
    }
}
```

### 3.3 Reboot séquentiel (attendre le retour avant de continuer)

```powershell
param([string[]]$Servers)

foreach ($Server in $Servers) {
    Write-Host "Reboot $Server..."
    Restart-Computer -ComputerName $Server -Force -Wait -For PowerShell -Timeout 600
    Write-Host " " 
    Write-Host "$Server est de retour."
    Start-Sleep -Seconds 120

    # Validation rapide post-reboot
    Invoke-Command -ComputerName $Server -ScriptBlock {
        $Services = @('W32Time','Dnscache','Netlogon')
        foreach ($Svc in $Services) {
            $Status = (Get-Service -Name $Svc -ErrorAction SilentlyContinue).Status
            Write-Host "$Svc : $Status"
        }
        $PR = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
        if ($PR) { Write-Host "ATTENTION : reboot additionnel requis" }
    }
}
```

---

## 4. PENDING REBOOT — DIAGNOSTIC ET RÉSOLUTION

> Cas isolé : un serveur affiche un pending reboot. Identifier la source avant d'agir.

### 4.1 Identifier la source

```powershell
"=== Pending reboot — sources ==="
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
    -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'

[pscustomobject]@{
    CBS_RebootPending          = $CBS
    WU_RebootRequired          = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending     = $CCM
    PendingReboot              = ($CBS -or $WU -or $PFR -or $CCM)
}

"=== Dernier boot ==="; (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
"=== Sessions actives ==="; query user
"=== Disques ==="; Get-PSDrive -PSProvider FileSystem |
    Select-Object Name, Free, @{n='FreeGB'; e={[math]::Round($_.Free/1GB,2)}} | Format-Table -AutoSize
```

### 4.2 Arbre de décision

| Source | Cause probable | Action |
|---|---|---|
| `CBS = True` | Composant Windows en attente | Reboot contrôlé — si persiste après 2 reboots : escalade |
| `WU = True` | Windows Update installé | Reboot contrôlé |
| `PFR = True` | Fichier en cours de remplacement | Reboot contrôlé |
| `CCM = True` | SCCM/ConfigMgr en attente | Reboot contrôlé |

**Si prod/critique :** valider fenêtre + dépendances + approbation avant reboot.
**Si DC :** exécuter le runbook DC PrePost avant et après.

### 4.3 Reboot contrôlé

> `shutdown /r` enregistre le billet et la raison dans l'**Event ID 1074** du System log — traçabilité complète.

```powershell
# ── Depuis le serveur ──────────────────────────────────────
$ticket = "#XXXXX"
$raison = "Pending reboot — [CBS / WindowsUpdate / PendingFileRename]"
shutdown /r /t 0 /c "Billet $ticket — $raison" /d p:4:1

# ── Depuis un poste admin (remote) ────────────────────────
Invoke-Command -ComputerName "SRV-NOM" -ScriptBlock {
    param($t, $r)
    shutdown /r /t 0 /c "Billet $t — $r" /d p:4:1
} -ArgumentList "#XXXXX", "Pending reboot — [raison]"
```

> **Codes raison courants :**
> `p:4:1` = Maintenance planifiée (défaut MSP) · `p:2:4` = Reconfiguration OS · `p:2:17` = Service Pack

### 4.4 Si le flag persiste après 2 reboots

Vérifier :
- Windows Update avec patch en attente (re-scan : `wuauclt /detectnow`)
- Installation ou rollback en cours (vérifier `%WINDIR%\WinSxS\pending.xml`)
- Corruption Software Distribution :
```powershell
Stop-Service wuauserv -Force
Rename-Item "$env:SystemRoot\SoftwareDistribution" "SoftwareDistribution.old"
Start-Service wuauserv
```
- Si `CBS` persiste : escalader — peut indiquer une corruption de composant Windows.

---

## 5. ROLLBACK

### 5.1 Azure VM — Restauration depuis snapshot

```powershell
param([string]$SnapshotName, [string]$VMName, [string]$ResourceGroup = "RG-PROD")

$Snapshot = Get-AzSnapshot -SnapshotName $SnapshotName -ResourceGroupName $ResourceGroup
Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Force

$VM        = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
$DiskConfig = New-AzDiskConfig -Location $VM.Location -CreateOption Copy -SourceResourceId $Snapshot.Id
$NewDisk    = New-AzDisk -Disk $DiskConfig -ResourceGroupName $ResourceGroup -DiskName "$VMName-rollback-osdisk"

Set-AzVMOSDisk -VM $VM -ManagedDiskId $NewDisk.Id -Name $NewDisk.Name
Update-AzVM -ResourceGroupName $ResourceGroup -VM $VM
Start-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
Write-Host " " 
Write-Host "Rollback termine — VM redemarree."
```

### 5.2 On-prem — Restauration depuis backup

1. Boot sur Windows Recovery Environment (WinRE)
2. Restaurer le System State depuis le dernier backup
3. Full BMR si nécessaire (Veeam, Windows Server Backup)

### 5.3 Désinstaller un patch spécifique (dernier recours)

```powershell
# Lister les patches installés récemment
Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-1)} | Format-Table -AutoSize

# Désinstaller un patch spécifique
wusa /uninstall /kb:XXXXXXX /quiet /norestart
```

---

## 6. REPORTING ET CLÔTURE CW

### 6.1 Rapport de conformité patches

```powershell
param([string[]]$Servers)

$Report = foreach ($Server in $Servers) {
    $Session = New-PSSession -ComputerName $Server
    $Result  = Invoke-Command -Session $Session -ScriptBlock {
        $Patches       = Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-30)}
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $SearchResult  = $UpdateSession.CreateUpdateSearcher().Search("IsInstalled=0 and Type='Software'")
        [pscustomobject]@{
            Serveur          = $env:COMPUTERNAME
            PatchesInstalles = $Patches.Count
            PatchesManquants = $SearchResult.Updates.Count
            DernierPatch     = ($Patches | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn
            Statut           = if ($SearchResult.Updates.Count -eq 0) {'Conforme'} else {'Non-conforme'}
        }
    }
    Remove-PSSession $Session
    $Result
}

$Report | Format-Table -AutoSize
$Report | Export-Csv "PatchReport-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
```

### 6.2 CW Note Interne — Phrase d'ouverture OBLIGATOIRE

```
Prise de connaissance de la demande et consultation de la documentation du client.
```

### 6.3 CW Discussion — Phrases d'ouverture OBLIGATOIRES

```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

TRAVAUX EFFECTUÉS :
• Precheck effectué — état initial documenté (services, disques, pending reboot, event logs)
• Patches CU + sécurité installés via CW RMM — [liste des serveurs]
• Reboot contrôlé effectué sur [serveurs redémarrés]
• Postcheck effectué — services opérationnels, aucune erreur critique
• [Résultats supplémentaires si applicable]

RÉSULTAT :
• Environnement patchré et opérationnel — [N] serveur(s) traités
• [Ou : Escalade requise / En attente d'approbation pour reboot]
```

---

## BONNES PRATIQUES

| Aspect | Standard |
|---|---|
| Fenêtre production | 2e dimanche du mois, 2h–6h |
| Dev/Test | 1er mercredi du mois, 20h–22h |
| Éviter | Fin de trimestre, lancement, période des Fêtes |
| Ordre serveurs | SQL → App/Web → Print → File → DC |
| Observation DEV | 48h minimum avant déploiement PROD |
| Backup requis | < 24h avant patching |
| Snapshot Azure | Obligatoire pré-patch |