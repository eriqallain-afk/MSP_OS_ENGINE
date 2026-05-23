# INFRA-SRV-HyperV_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
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
    @{N='RAM_Total_GB';E={[math]::Round($_.MemoryCapacity/1GB,1)}} | Format-List

# RAM disponible hôte
[pscustomobject]@{
    RAM_Free_GB = [math]::Round($os.FreePhysicalMemory/1MB,1)
    RAM_Total_GB = [math]::Round($os.TotalVisibleMemorySize/1MB,1)
} | Format-List

# État de toutes les VMs
Write-Host "=== ÉTAT DES VMs ===" -ForegroundColor Cyan
Get-VM | Select-Object Name, State, CPUUsage,
    @{N='MemAssigned_GB';E={[math]::Round($_.MemoryAssigned/1GB,2)}},
    @{N='MemDemand_GB';E={[math]::Round($_.MemoryDemand/1GB,2)}},
    Uptime | Format-Table -AutoSize

# Snapshots existants (attention aux snapshots anciens)
Write-Host "=== SNAPSHOTS ===" -ForegroundColor Cyan
Get-VMSnapshot -VMName * | Select-Object VMName, Name, CreationTime,
    @{N='Age_Jours';E={((Get-Date)-$_.CreationTime).Days}} |
    Sort-Object Age_Jours -Descending | Format-Table -AutoSize

# Stockage datastores
Write-Host "=== STOCKAGE ===" -ForegroundColor Cyan
Get-VMHost | Select-Object -ExpandProperty HostHardDiskDrives |
    Get-Disk | Get-Partition | Get-Volume |
    Where-Object {$_.DriveLetter} |
    Select-Object DriveLetter,
        @{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}},
        @{N='Free_GB';E={[math]::Round($_.SizeRemaining/1GB,1)}},
        @{N='Free_%';E={[math]::Round($_.SizeRemaining/$_.Size*100,0)}} |
    Format-Table -AutoSize

# Services Hyper-V
Write-Host "=== SERVICES ===" -ForegroundColor Cyan
Get-Service -Name vmms,vmcompute,vhdsvc,vmicheartbeat |
    Select-Object Name, Status, StartType | Format-Table -AutoSize

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
    Select-Object TimeCreated, Message | Format-List
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

```powershell
# ⚠️ AVANT de reboôter l'hôte :
# 1. Migrer ou éteindre TOUTES les VMs
# 2. Vérifier qu'il n'y a plus de VMs en état Running

# Sauvegarder toutes les VMs (Saved State)
Get-VM | Where-Object {$_.State -eq 'Running'} | Save-VM
# OU les éteindre proprement
Get-VM | Where-Object {$_.State -eq 'Running'} | Stop-VM -Force

# Vérifier qu'aucune VM ne tourne
Get-VM | Select-Object Name, State | Where-Object {$_.State -ne 'Off'}
```

---

## 6. NE PAS FAIRE

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
