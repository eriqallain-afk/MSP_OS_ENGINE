# INFRA-SRV-HyperV_Operations_V2
**Version :** 2.2 | **Date :** 2026-05-21 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__HyperV_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-MaintenanceMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — Virtualisation Hyper-V
**Mis à jour :** 2026-03-20

---

## 1. HEALTH CHECK HÔTE HYPER-V

```powershell
Start-Transcript -Path "C:\IT_LOGS\AUDIT\HyperV_HealthCheck_$(Get-Date -Format 'yyyyMMdd_HHmm').log"

# Ressources hôte
Write-Host "=== RESSOURCES HÔTE ===" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
Get-VMHost | Select-Object Name,
    @{N='CPU_LogicalProc';E={$_.LogicalProcessorCount}},
    @{N='RAM_Total_GB';E={[math]::Round($_.MemoryCapacity/1GB,1)}} | Out-String -Width 300 | Write-Output

# RAM disponible hôte
[pscustomobject]@{
    RAM_Free_GB = [math]::Round($os.FreePhysicalMemory/1MB,1)
    RAM_Total_GB = [math]::Round($os.TotalVisibleMemorySize/1MB,1)
} | Out-String -Width 300 | Write-Output

# État de toutes les VMs
Write-Host "=== ÉTAT DES VMs ===" -ForegroundColor Cyan
Get-VM | Select-Object Name, State, CPUUsage,
    @{N='MemAssigned_GB';E={[math]::Round($_.MemoryAssigned/1GB,2)}},
    @{N='MemDemand_GB';E={[math]::Round($_.MemoryDemand/1GB,2)}},
    Uptime | Out-String -Width 300 | Write-Output

# Snapshots existants (attention aux snapshots anciens)
Write-Host "=== SNAPSHOTS ===" -ForegroundColor Cyan
Get-VMSnapshot -VMName * | Select-Object VMName, Name, CreationTime,
    @{N='Age_Jours';E={((Get-Date)-$_.CreationTime).Days}} |
    Sort-Object Age_Jours -Descending | Out-String -Width 300 | Write-Output

# Stockage datastores
Write-Host "=== STOCKAGE ===" -ForegroundColor Cyan
Get-VMHost | Select-Object -ExpandProperty HostHardDiskDrives |
    Get-Disk | Get-Partition | Get-Volume |
    Where-Object {$_.DriveLetter} |
    Select-Object DriveLetter,
        @{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}},
        @{N='Free_GB';E={[math]::Round($_.SizeRemaining/1GB,1)}},
        @{N='Free_%';E={[math]::Round($_.SizeRemaining/$_.Size*100,0)}} |
    Out-String -Width 300 | Write-Output

# Services Hyper-V
Write-Host "=== SERVICES ===" -ForegroundColor Cyan
Get-Service -Name vmms,vmcompute,vhdsvc,vmicheartbeat |
    Select-Object Name, Status, StartType | Out-String -Width 300 | Write-Output

Stop-Transcript
```

---

## 2. GESTION DES SNAPSHOTS

```
⚠️ RÈGLE FONDAMENTALE SUR LES SNAPSHOTS :
   - Snapshot AVANT maintenance → supprimer dans les 72h
   - Snapshot APRÈS validation → supprimer immédiatement
   - Snapshot > 7 jours = problème → investiguer immédiatement
   - Snapshot sur DC = dangereux (USN rollback) → éviter, utiliser Windows Server Backup
```

### Convention de nommage (conforme NAMING_STANDARDS)
```
@T12345_Preboot_SRV-APP01_SNAP_20260320_2145
@T12345_Postpatch_SRV-APP01_SNAP_20260320_2230
```

### Créer un snapshot
```powershell
# ⚠️ Confirmer que la VM n'est pas un DC avant de créer un snapshot
$VMName = "SRV-APP01"
$Ticket = "T12345"
$Phase = "Preboot"
$SnapName = "@$Ticket`_$Phase`_$VMName`_SNAP_$(Get-Date -Format 'yyyyMMdd_HHmm')"

Checkpoint-VM -Name $VMName -SnapshotName $SnapName
Write-Host "Snapshot créé : $SnapName"
```

### Supprimer un snapshot (après validation)
```powershell
# Lister les snapshots d'une VM
Get-VMSnapshot -VMName "SRV-APP01" | Select-Object Name, CreationTime

# Supprimer un snapshot spécifique
Remove-VMSnapshot -VMName "SRV-APP01" -Name "@T12345_Preboot_SRV-APP01_SNAP_20260320_2145"

# ⚠️ La suppression fusionne les deltas — peut prendre du temps sur gros disques
# Surveiller l'espace disque pendant l'opération
```

### Supprimer TOUS les snapshots d'une VM (attention)
```powershell
# ⚠️ Valider les changements AVANT de supprimer tous les checkpoints
Get-VMSnapshot -VMName "SRV-APP01" | Remove-VMSnapshot
```

---

## 3. MIGRATION VM À CHAUD (LIVE MIGRATION)

```powershell
# Prérequis : Hyper-V cluster ou Live Migration configurée
# ⚠️ Vérifier l'espace disponible sur l'hôte de destination

# Migrer une VM vers un autre hôte
Move-VM -Name "SRV-APP01" -DestinationHost "NOM_HOTE_DESTINATION" -IncludeStorage `
    -DestinationStoragePath "D:\Hyper-V\VMs"

# Vérifier la progression
Get-VM -Name "SRV-APP01" | Select-Object Name, State, ComputerName
```

---

## 4. DÉPANNAGE VM NE DÉMARRE PAS

```powershell
# Vérifier l'état de la VM
Get-VM "SRV-APP01" | Select-Object Name, State, Status, CPUUsage

# Voir les événements Hyper-V liés à cette VM
Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-Hyper-V-Worker-Admin'
    StartTime=(Get-Date).AddHours(-2)
} | Where-Object {$_.Message -match "SRV-APP01"} |
    Select-Object TimeCreated, Message | Out-String -Width 300 | Write-Output
```

### États courants et actions

| État VM | Signification | Action |
|---|---|---|
| `Off` | Arrêtée normalement | Démarrer si planifié |
| `Saved` | Hibernée | `Resume-VM` ou `Start-VM` |
| `Paused` | Suspendue | `Resume-VM` |
| `Critical` | Ressources insuffisantes | Vérifier RAM/CPU/stockage hôte |
| `Running` mais figée | Problème OS invité | Vérifier l'intégration Hyper-V |

---

## 5. PRECHECK AVANT REBOOT DE L'HÔTE HYPER-V

> Exécuter ce script **en lecture seule** avant toute décision. Il couvre l'ensemble des points critiques d'un hôte Hyper-V : VMs, stockage, backups, snapshots, services, uptime.

```powershell
# ============================================================
# PRECHECK HÔTE HYPER-V — Avant reboot
# Impact  : Lecture seule — aucun changement appliqué
# Usage   : RMM ou session PSRemoting sur l'hôte
# Sortie  : Out-String -Width 300 | Write-Output (compatible RMM)
#           Évite les pertes de sortie Format-List/Table dans CW/N-able
# ============================================================
$Sep = "=" * 60

# ── 1. HOST / OS / UPTIME ────────────────────────────────────
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
    UptimeDays = [math]::Round($uptime.TotalDays,1)
} | Out-String -Width 300 | Write-Output
Write-Host "  ► Documenter LastBoot + Uptime dans le billet (valider en postcheck)" -ForegroundColor Cyan

# ── 2. ÉTAT DE TOUTES LES VMs ────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  VMs — ÉTAT COMPLET"
Write-Host $Sep
$vms = Get-VM
$vmsRunning = $vms | Where-Object { $_.State -eq 'Running' }
$vmsOther   = $vms | Where-Object { $_.State -notin @('Running','Off') }

$vms | Select-Object Name, State,
    @{N='CPUUsage%';E={$_.CPUUsage}},
    @{N='MemAssignedGB';E={[math]::Round($_.MemoryAssigned/1GB,1)}},
    @{N='UptimeH';E={[math]::Round($_.Uptime.TotalHours,1)}},
    @{N='ReplicationMode';E={$_.ReplicationMode}},
    @{N='ReplicationHealth';E={$_.ReplicationHealth}} |
    Out-String -Width 300 | Write-Output

Write-Host "  VMs Running    : $($vmsRunning.Count)"
Write-Host "  VMs Autres états (Saved/Paused/Critical) : $($vmsOther.Count)"
if ($vmsOther) {
    Write-Host "  ⚠ VMs en état anormal :" -ForegroundColor Yellow
    $vmsOther | ForEach-Object { Write-Host "    → $($_.Name) : $($_.State)" -ForegroundColor Yellow }
}
if ($vmsRunning.Count -gt 0) {
    Write-Host "  ⛔ $($vmsRunning.Count) VM(S) EN COURS — migrer ou arrêter avant reboot hôte" -ForegroundColor Red
} else {
    Write-Host "  ✓ Aucune VM Running" -ForegroundColor Green
}

# ── 3. SNAPSHOTS EN PRODUCTION ───────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SNAPSHOTS — VÉRIFICATION"
Write-Host $Sep
$snaps = Get-VMSnapshot -VMName * -ErrorAction SilentlyContinue
if ($snaps) {
    $snaps | Select-Object VMName, Name, CreationTime,
        @{N='AgeH';E={[math]::Round(((Get-Date)-$_.CreationTime).TotalHours,1)}} |
        Sort-Object AgeH -Descending | Out-String -Width 300 | Write-Output
    $old = $snaps | Where-Object { ((Get-Date)-$_.CreationTime).TotalHours -gt 72 }
    if ($old) {
        Write-Host "  ⛔ $($old.Count) SNAPSHOT(S) > 72H — risque de croissance AVHD incontrôlée" -ForegroundColor Red
    } else {
        Write-Host "  ⚠ Snapshots présents — vérifier avant reboot" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✓ Aucun snapshot en production" -ForegroundColor Green
}

# ── 4. STOCKAGE HÔTE ─────────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  STOCKAGE HÔTE"
Write-Host $Sep
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } |
    Select-Object Name,
        @{N='TotalGB';E={[math]::Round(($_.Used+$_.Free)/1GB,1)}},
        @{N='UsedGB'; E={[math]::Round($_.Used/1GB,1)}},
        @{N='FreeGB'; E={[math]::Round($_.Free/1GB,1)}},
        @{N='Free%';  E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} |
    Out-String -Width 300 | Write-Output

Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } | ForEach-Object {
    $pct = [math]::Round($_.Free/($_.Used+$_.Free)*100,0)
    if ($pct -lt 10) { Write-Host "  ⛔ Disque $($_.Name): FREE% = $pct% — CRITIQUE" -ForegroundColor Red }
    elseif ($pct -lt 20) { Write-Host "  ⚠ Disque $($_.Name): FREE% = $pct% — Attention" -ForegroundColor Yellow }
}

# ── 5. BACKUP EN COURS ───────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  BACKUP EN COURS — CRITIQUE"
Write-Host $Sep
$backupBloquant = $false

# Windows Server Backup
$wbe = Get-Process -Name "wbengine" -ErrorAction SilentlyContinue
if ($wbe) {
    $backupBloquant = $true
    Write-Host "  ⛔ WINDOWS SERVER BACKUP EN COURS (PID $($wbe.Id) — $([int]((Get-Date)-$wbe.StartTime).TotalMinutes) min)" -ForegroundColor Red
} else { Write-Host "  ✓ Aucun Windows Server Backup en cours" -ForegroundColor Green }

# Veeam processus actifs
$veeamProcs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "VeeamAgent|VeeamGuestHelper|VeeamTransport" }
if ($veeamProcs) {
    $backupBloquant = $true
    Write-Host "  ⛔ PROCESSUS VEEAM ACTIFS — job probablement en cours" -ForegroundColor Red
    $veeamProcs | Select-Object Name, Id, @{N='DuréeMin';E={[int]((Get-Date)-$_.StartTime).TotalMinutes}} | Out-String -Width 300 | Write-Output
} else { Write-Host "  ✓ Aucun processus Veeam de transfert détecté" -ForegroundColor Green }

# Tentative module Veeam
try {
    Add-PSSnapin VeeamPSSnapIn -ErrorAction Stop
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
    Write-Host "  ✓ Aucun backup bloquant détecté" -ForegroundColor Green
}

# ── 6. PENDING REBOOT FLAGS ──────────────────────────────────
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
} else { Write-Host "  ✓ Aucun pending reboot flag" -ForegroundColor Green }

# ── 7. SERVICES HYPER-V ──────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SERVICES HYPER-V"
Write-Host $Sep
@('vmms','vmcompute','nvspwmi','vmsmp','HvHost','vmickvpexchange','vmicheartbeat','vmicshutdown','vmicvmsession') |
    ForEach-Object {
        $s = Get-Service -Name $_ -EA SilentlyContinue
        if ($s) {
            $color = if ($s.Status -eq 'Running') { 'Green' } else { 'Yellow' }
            Write-Host "  $($_.PadRight(30)) $($s.Status)" -ForegroundColor $color
        }
    }

# ── 8. RÉSUMÉ GO / NO-GO ────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  RÉSUMÉ GO / NO-GO"
Write-Host $Sep
$noGo = @()
if ($vmsRunning.Count -gt 0) { $noGo += "VMs Running ($($vmsRunning.Count))" }
if ($backupBloquant)          { $noGo += "Backup en cours" }
$oldSnaps = if($snaps){$snaps | Where-Object {((Get-Date)-$_.CreationTime).TotalHours -gt 72}} else {@()}
if ($oldSnaps.Count -gt 0)    { $noGo += "Snapshots > 72h ($($oldSnaps.Count))" }

if ($noGo.Count -gt 0) {
    Write-Host "  ⛔ NO-GO — Blocages détectés :" -ForegroundColor Red
    $noGo | ForEach-Object { Write-Host "    → $_" -ForegroundColor Red }
} else {
    Write-Host "  ✅ GO — Aucun blocage détecté" -ForegroundColor Green
    Write-Host "     Arrêter ou migrer les VMs, puis procéder au reboot hôte" -ForegroundColor Cyan
}
Write-Host $Sep
```

### Décision GO / NO-GO

| Condition | Décision | Action |
|---|---|---|
| VMs en état Running | ⛔ NO-GO | Migrer (Live Migration) ou arrêter proprement avant reboot |
| Backup en cours (Veeam / WSB) | ⛔ NO-GO | Attendre la fin — ne jamais interrompre |
| Snapshots > 72h | ⚠ HOLD | Supprimer ou valider avant reboot |
| Disque hôte < 10% libre | ⛔ NO-GO | Libérer espace avant reboot |
| Aucune des conditions ci-dessus | ✅ GO | Reboot autorisé après approbation explicite |



## 6. POSTCHECK APRÈS REBOOT DE L'HÔTE HYPER-V

> Un seul script — valide le reboot ET l'état des VMs en une passe.
> Exécuter immédiatement après le retour en ligne de l'hôte.

```powershell
# ============================================================
# POSTCHECK HÔTE HYPER-V — Après reboot
# Impact  : Lecture seule
# Usage   : RMM ou PSRemoting — Out-String (compatible RMM)
# ============================================================
$Sep = "=" * 60

# ── 1. REBOOT CONFIRMÉ — OBLIGATOIRE ────────────────────────
Write-Host $Sep
Write-Host "  REBOOT CONFIRMÉ — HOST / OS / UPTIME"
Write-Host $Sep
$os     = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
[pscustomobject]@{
    Hostname   = $env:COMPUTERNAME
    LastBoot   = $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")
    UptimeHours= [math]::Round($uptime.TotalHours, 2)
    UptimeDays = [math]::Round($uptime.TotalDays, 2)
} | Out-String -Width 300 | Write-Output
if ($uptime.TotalHours -lt 2) {
    Write-Host "  ✓ REBOOT CONFIRMÉ — LastBoot récent ($($os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm')))" -ForegroundColor Green
} else {
    Write-Host "  ⚠ UptimeHours = $([math]::Round($uptime.TotalHours,1))h — vérifier que le bon serveur a été rebooté" -ForegroundColor Yellow
}
Write-Host "  ► Documenter LastBoot dans le billet (valider = date du reboot effectué)" -ForegroundColor Cyan

# ── 2. PENDING REBOOT FLAGS — doivent être False ────────────
Write-Host " "
Write-Host $Sep
Write-Host "  PENDING REBOOT FLAGS — Vérification post-reboot"
Write-Host $Sep
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -EA SilentlyContinue) -ne $null
[pscustomobject]@{
    CBS_RebootPending = $CBS; WU_RebootRequired = $WU; PendingFileRename = $PFR
    "RebootEncoreRequis" = ($CBS -or $WU -or $PFR)
} | Out-String -Width 300 | Write-Output
if ($CBS -or $WU -or $PFR) {
    $flags = @(); if($CBS){$flags+="CBS"}; if($WU){$flags+="WU"}; if($PFR){$flags+="PFR"}
    Write-Host "  ⚠ FLAGS ENCORE ACTIFS : $($flags -join ' · ') — 2e reboot peut être nécessaire" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Tous les flags pending reboot sont retombés à False" -ForegroundColor Green
}

# ── 3. SERVICE HYPER-V ───────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  SERVICE HYPER-V (vmms)"
Write-Host $Sep
$vmms = Get-Service vmms -EA SilentlyContinue
if ($vmms) {
    $color = if ($vmms.Status -eq 'Running') { 'Green' } else { 'Red' }
    Write-Host "  vmms : $($vmms.Status) / $($vmms.StartType)" -ForegroundColor $color
    if ($vmms.Status -ne 'Running') {
        Write-Host "  ⛔ vmms n'est pas Running — démarrer manuellement : Start-Service vmms" -ForegroundColor Red
    }
} else {
    Write-Host "  ⚠ Service vmms non trouvé" -ForegroundColor Yellow
}

# ── 4. ÉTAT DE TOUTES LES VMs ────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  VMs — ÉTAT POST-REBOOT"
Write-Host $Sep
$vms = Get-VM -EA SilentlyContinue
if ($vms) {
    $vms | Select-Object Name, State, Status,
        @{N='CPUUsage%';E={$_.CPUUsage}},
        @{N='MemAssignedGB';E={[math]::Round($_.MemoryAssigned/1GB,1)}},
        @{N='UptimeH';E={[math]::Round($_.Uptime.TotalHours,2)}} |
        Out-String -Width 300 | Write-Output

    $notRunning = $vms | Where-Object { $_.State -ne 'Running' }
    $notNormal  = $vms | Where-Object { $_.Status -ne 'Operating normally' -and $_.Status -ne 'Fonctionnement normal' }

    if ($notRunning) {
        Write-Host "  ⛔ VMs PAS en état Running :" -ForegroundColor Red
        $notRunning | ForEach-Object { Write-Host "    → $($_.Name) : $($_.State)" -ForegroundColor Red }
    } else {
        Write-Host "  ✓ Toutes les VMs sont en état Running ($($vms.Count)/$($vms.Count))" -ForegroundColor Green
    }
    if ($notNormal) {
        Write-Host "  ⚠ VMs avec statut anormal :" -ForegroundColor Yellow
        $notNormal | ForEach-Object { Write-Host "    → $($_.Name) : $($_.Status)" -ForegroundColor Yellow }
    }
} else {
    Write-Host "  ⚠ Aucune VM détectée ou module Hyper-V non chargé" -ForegroundColor Yellow
}

# ── 5. RÉSUMÉ POSTCHECK ──────────────────────────────────────
Write-Host " "
Write-Host $Sep
Write-Host "  RÉSUMÉ POSTCHECK HYPER-V"
Write-Host $Sep
$ok = $true
if ($uptime.TotalHours -ge 2)                   { $ok = $false; Write-Host "  ⚠ Uptime élevé — reboot à confirmer" -ForegroundColor Yellow }
if ($CBS -or $WU -or $PFR)                      { Write-Host "  ⚠ Flags pending reboot encore actifs" -ForegroundColor Yellow }
if ($vmms -and $vmms.Status -ne 'Running')      { $ok = $false; Write-Host "  ⛔ vmms non Running" -ForegroundColor Red }
if ($vms -and ($vms | Where-Object { $_.State -ne 'Running' })) {
    $ok = $false
    Write-Host "  ⛔ Une ou plusieurs VMs pas en état Running" -ForegroundColor Red
}
if ($ok) {
    Write-Host "  ✅ POSTCHECK OK — Reboot hôte confirmé, vmms Running, VMs Running" -ForegroundColor Green
    Write-Host "     Documenter dans le billet et fermer le ticket." -ForegroundColor Cyan
}
Write-Host $Sep
```

### Critères de clôture du billet

| Critère | Attendu |
|---|---|
| `LastBoot` | = date/heure du reboot effectué |
| `UptimeHours` | < 2h (reboot récent confirmé) |
| Flags CBS/WU/PFR | Tous `False` |
| `vmms` | `Running` |
| Toutes les VMs | `State = Running` + `Status = Fonctionnement normal` |

> Si un flag reste `True` après le reboot → 2e reboot peut être nécessaire (CBS persistant = possible corruption WinSxS).

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS créer un snapshot sur un DC (risque USN rollback, corruption AD)
   → Utiliser Windows Server Backup pour les DCs
⛔ NE JAMAIS laisser un snapshot > 72h en production
⛔ NE JAMAIS supprimer les fichiers .AVHD/.AVHDX manuellement — utiliser Hyper-V Manager
⛔ NE JAMAIS déplacer des VHD/VHDX manuellement pendant que la VM tourne
⛔ NE JAMAIS augmenter la RAM dynamique maximum au-delà de la RAM physique disponible
⛔ NE JAMAIS configurer les VMs avec plus de vCPU que le ratio recommandé (4:1 max)
```

---

## 8. CRASH HÔTE — DC EN VM / POST-PANNE STOCKAGE

> **Scénario P1 typique :** hôte Hyper-V seul avec DC en VM — panne RAID/disque avec "Lost Delayed Write Data" / "Delayed Write Failed". Risque élevé de corruption NTDS.

### 8.1 Alertes précurseurs — reconnaître le scénario

Ces alertes dans l'Event Log de l'hôte (System) annoncent une panne imminente :
```
Hardware Issue - Fatal Firmware Error
Fault Tolerance Disk - Lost Delayed Write Data
Hardware Issue - Delayed Write Failed - Data Loss could have occurred
```
→ **Si ces alertes apparaissent : évacuer les VMs immédiatement, ne pas attendre le crash.**

### 8.2 Retour en ligne de l'hôte — diagnostic RAID d'abord

1. Vérifier l'accès IPMI / iLO / iDRAC — état du contrôleur RAID et des disques
2. Si RAID dégradé (1 disque) : hôte peut redémarrer — vérifier intégrité avant de démarrer les VMs
3. Si contrôleur mort : hôte ne démarrera pas correctement — escalade vendor immédiate

```powershell
# Sur l'hôte — vérifier les volumes de stockage
Get-Volume | Select-Object DriveLetter, FileSystem, HealthStatus, OperationalStatus, Size, SizeRemaining
Get-Disk | Select-Object Number, FriendlyName, HealthStatus, OperationalStatus
```

### 8.3 État des VMs au retour de l'hôte

```powershell
Get-VM | Select-Object Name, State, Status, Uptime
```

| État VM | Signification | Action |
|---|---|---|
| `Off` | Éteinte proprement ou crash | Démarrer avec précautions |
| `Saved` | État sauvegardé avant panne | ⛔ Supprimer le saved state — ne pas reprendre |
| `Critical` | Stockage toujours inaccessible | Résoudre le RAID avant tout |
| `Paused` | VM suspendue automatiquement | Vérifier pourquoi avant de reprendre |

**Supprimer un saved state avant démarrage :**
```powershell
# ⚠ Ne jamais reprendre un saved state après panne de stockage — BSOD quasi-certain
Stop-VM -Name "SRV-DC01" -TurnOff    # force off si en saved state
# OU via Hyper-V Manager : clic droit VM → Delete Saved State
```

### 8.4 Démarrage du DC VM — précautions NTDS

> "Lost Delayed Write Data" = données en cache RAID non écrites sur disque. Le NTDS.dit **peut être corrompu**.

**Démarrer la VM et observer :**
- BSOD `KERNEL_DATA_INPAGE_ERROR` / `NTFS_FILE_SYSTEM` → aller à §8.5 (DSRM)
- Démarrage normal → valider AD **avant** d'autoriser les connexions utilisateurs

**Si démarrage normal — valider avant de laisser circuler le trafic :**
```powershell
# Intégrité NTDS
ntdsutil "activate instance ntds" "files" "integrity" quit quit

# Événements AD au démarrage
Get-EventLog -LogName "Directory Service" -EntryType Error,Warning -Newest 20

# Réplication (si autre DC disponible)
repadmin /replsummary
repadmin /showrepl

# Services critiques
Get-Service NTDS, NETLOGON, kdc, W32Time, DNS | Select-Object DisplayName, Status
```

### 8.5 DC VM — démarrage impossible / NTDS corrompu

**Démarrer en DSRM (Directory Services Restore Mode) :**
1. Dans Hyper-V Manager → Media → DVD → Image ISO Windows Server (ou menu démarrage)
2. F8 au boot → Repair Your Computer → DSRM
3. Mot de passe DSRM requis (dans Passportal)

```cmd
rem Tentative de récupération NTDS en DSRM
ntdsutil "activate instance ntds" "files" "integrity" quit quit
ntdsutil "activate instance ntds" "files" "recover" quit quit
```

**Si `recover` échoue → restauration depuis backup obligatoire :**
- Veeam : restore VM depuis le dernier backup réussi → vérifier la date
- Datto : instant restore ou bare metal
- ⛔ Si backup est plus vieux que la tombstone lifetime (180j par défaut) : risque de conflit AD

### 8.6 Ordre de démarrage des VMs post-incident

```
1. DC (obligatoire en premier)
2. DNS / DHCP (si serveur séparé)
3. Serveurs applicatifs critiques
4. Serveurs de fichiers
5. Autres VMs
```

> Valider que le DC est pleinement opérationnel (NETLOGON + réplication) avant de démarrer les VMs suivantes.

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Hôte Hyper-V inaccessible (VMs down) | NOC | Immédiat |
| Espace datastore < 10% | NOC + INFRA | Dans l'heure |
| Corruption VHDX détectée | INFRA + BackupDR | Immédiat |
| Migration Live en échec répété | INFRA | Dans la journée |
| RAID dégradé / Lost Delayed Write — DC en VM | INFRA + NOC + Vendor hardware | Immédiat |
| NTDS corrompu — DC ne démarre pas | INFRA + BackupDR | Immédiat |
