# BUNDLE — BUNDLE_INFRA_VIRTUALISATION
**Bundle ID :** BUNDLE_INFRA_VIRTUALISATION
**Source ZIP :** INFRA_Virtualisation.zip
**Généré :** 2026-04-04T20:19:33Z

## Contenu (runbooks)
1. **RUNBOOK__HyperV_Operations_V1** — RUNBOOK — Hyper-V : Opérations & Maintenance (Maj: 2026-03-20 | Agents: IT-Assistant-N3, IT-SysAdmin)
2. **RUNBOOK__VMware_vSphere_Operations_V1** — RUNBOOK — VMware vSphere : Opérations & Maintenance (Maj: 2026-03-20 | Agents: IT-Assistant-N3, IT-SysAdmin)
3. **RUNBOOK__Vates_XCPng_Operations_V1** — RUNBOOK — Vates XCP-ng / Xen Orchestra : Opérations & Maintenance (Maj: 2026-03-20 | Agents: IT-Assistant-N3, IT-SysAdmin)

---

<!-- RUNBOOK_START: RUNBOOK__HyperV_Operations_V1 (INFRA__RUNBOOK__HyperV_Operations_V1.md) -->
# RUNBOOK — Hyper-V : Opérations & Maintenance
**ID :** RUNBOOK__HyperV_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-SysAdmin
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

## 7. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Hôte Hyper-V inaccessible (VMs down) | NOC | Immédiat |
| Espace datastore < 10% | NOC + INFRA | Dans l'heure |
| Corruption VHDX détectée | INFRA + BackupDR | Immédiat |
| Migration Live en échec répété | INFRA | Dans la journée |
<!-- RUNBOOK_END: RUNBOOK__HyperV_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__VMware_vSphere_Operations_V1 (INFRA__RUNBOOK__VMware_vSphere_Operations_V1.md) -->
# RUNBOOK — VMware vSphere : Opérations & Maintenance
**ID :** RUNBOOK__VMware_vSphere_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-SysAdmin
**Domaine :** INFRA — Virtualisation VMware
**Mis à jour :** 2026-03-20

---

## 1. HEALTH CHECK ESXI / VCENTER

### Vérifications critiques vCenter
```
1. vSphere Client → Menu → Hôtes et clusters
2. Vérifier que tous les hôtes ESXi sont verts (connectés)
3. Vérifier les alarmes actives : Menu → Alarmes
4. Vérifier l'utilisation globale CPU/RAM des clusters
5. Vérifier l'espace des datastores : Menu → Stockage
   → Seuil alerte : < 20% libre
   → Seuil critique : < 10% libre
```

### PowerShell via PowerCLI
```powershell
# Connexion vCenter
Connect-VIServer -Server "vcenter.domaine.com"

# État des hôtes ESXi
Get-VMHost | Select-Object Name, ConnectionState, PowerState,
    @{N='CPU_MHz_Used';E={$_.CpuUsageMhz}},
    @{N='CPU_MHz_Total';E={$_.CpuTotalMhz}},
    @{N='RAM_Used_GB';E={[math]::Round($_.MemoryUsageGB,1)}},
    @{N='RAM_Total_GB';E={[math]::Round($_.MemoryTotalGB,1)}} |
    Format-Table -AutoSize

# État de toutes les VMs
Get-VM | Select-Object Name, PowerState, NumCpu, MemoryGB,
    @{N='Host';E={$_.VMHost.Name}},
    @{N='Datastore';E={($_ | Get-Datastore).Name -join ','}} |
    Format-Table -AutoSize

# Snapshots existants
Get-VM | Get-Snapshot | Select-Object VM, Name, Created,
    @{N='Age_Jours';E={((Get-Date)-$_.Created).Days}},
    @{N='Size_GB';E={[math]::Round($_.SizeGB,2)}} |
    Sort-Object Age_Jours -Descending | Format-Table -AutoSize

# Datastores — espace libre
Get-Datastore | Select-Object Name,
    @{N='Free_GB';E={[math]::Round($_.FreeSpaceGB,1)}},
    @{N='Total_GB';E={[math]::Round($_.CapacityGB,1)}},
    @{N='Free_%';E={[math]::Round($_.FreeSpaceGB/$_.CapacityGB*100,0)}} |
    Format-Table -AutoSize
```

---

## 2. GESTION DES SNAPSHOTS VMWARE

```
⚠️ RÈGLE FONDAMENTALE :
   - Snapshot = protection temporaire UNIQUEMENT
   - Maximum 72h en production
   - Maximum 3 niveaux de snapshots imbriqués
   - Snapshot > 7 jours = risque de corruption et dégradation performances
   - NE JAMAIS prendre un snapshot sur un DC sans approuver avec INFRA
```

### Convention de nommage
```
@T12345_Preboot_SRV-APP01_SNAP_20260320_2145
```

### Créer un snapshot (PowerCLI)
```powershell
$VM = "SRV-APP01"
$Ticket = "T12345"
$Phase = "Preboot"
$SnapName = "@$Ticket`_$Phase`_$VM`_SNAP_$(Get-Date -Format 'yyyyMMdd_HHmm')"

New-Snapshot -VM $VM -Name $SnapName -Memory:$false -Quiesce:$true
Write-Host "Snapshot créé : $SnapName"
```

### Supprimer un snapshot
```powershell
# Supprimer un snapshot spécifique
Get-VM "SRV-APP01" | Get-Snapshot -Name "@T12345*" | Remove-Snapshot -Confirm:$false

# Supprimer TOUS les snapshots d'une VM
Get-VM "SRV-APP01" | Get-Snapshot | Remove-Snapshot -RemoveChildren -Confirm:$false
```

### Rollback vers un snapshot
```powershell
# ⚠️ ATTENTION : perd toutes les modifications depuis le snapshot
# Demander confirmation explicite avant d'exécuter
$VM = Get-VM "SRV-APP01"
$Snap = Get-Snapshot -VM $VM -Name "@T12345_Preboot*"
Set-VM -VM $VM -Snapshot $Snap -Confirm:$false
```

---

## 3. MIGRATION VMOTION

```powershell
# Migration à chaud (vMotion) — VM reste active
Move-VM -VM "SRV-APP01" -Destination (Get-VMHost "esxi02.domaine.com")

# Migration Storage vMotion — déplacer les disques
Move-VM -VM "SRV-APP01" -Datastore (Get-Datastore "DATASTORE_02")

# Migration complète (VM + disques)
Move-VM -VM "SRV-APP01" `
    -Destination (Get-VMHost "esxi02.domaine.com") `
    -Datastore (Get-Datastore "DATASTORE_02")

# Surveiller la progression
Get-Task | Where-Object {$_.Name -match "Relocate"} |
    Select-Object Name, State, PercentComplete, StartTime
```

---

## 4. MAINTENANCE HÔTE ESXI

```powershell
# Mettre l'hôte en mode maintenance (évacue les VMs automatiquement si DRS activé)
$Host = Get-VMHost "esxi01.domaine.com"
Set-VMHost -VMHost $Host -State Maintenance

# Vérifier que toutes les VMs sont migrées
Get-VM -Location $Host | Select-Object Name, PowerState

# Après maintenance — sortir du mode maintenance
Set-VMHost -VMHost $Host -State Connected
```

---

## 5. DÉPANNAGE — VM NE DÉMARRE PAS

```powershell
# Voir les événements vCenter pour cette VM
Get-VIEvent -Entity (Get-VM "SRV-APP01") -MaxSamples 50 |
    Where-Object {$_.GetType().Name -match "Event"} |
    Select-Object CreatedTime, FullFormattedMessage |
    Sort-Object CreatedTime -Descending | Format-List
```

### Erreurs courantes VMware

| Erreur | Cause probable | Action |
|---|---|---|
| `Cannot open the disk` | Fichier VMDK verrouillé | Chercher processus avec lock sur le fichier |
| `File not found` | VMDK manquant ou déplacé | Vérifier l'inventaire du datastore |
| `No more space available` | Datastore plein | Libérer de l'espace avant démarrage |
| `A general system error occurred` | Vérifier les logs vmware.log | cat /vmfs/volumes/datastore/VM/vmware.log |
| `Failed to lock the file` | Snapshot orphelin | Supprimer les fichiers .lck manuellement |

---

## 6. CERTIFICATS VCENTER — VÉRIFICATION

```powershell
# Vérifier l'expiration des certificats vCenter
$VCServer = Connect-VIServer "vcenter.domaine.com"
$cert = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
# Vérifier via navigateur ou via API REST :
# https://vcenter.domaine.com/rest/vcenter/certificate-management/vcenter/tls
```

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer des fichiers VMDK directement sur le datastore
   → Toujours passer par vSphere Client ou PowerCLI
⛔ NE JAMAIS mettre tous les hôtes ESXi en maintenance simultanément
⛔ NE JAMAIS laisser des snapshots > 72h en production
⛔ NE JAMAIS modifier la configuration réseau vSwitch sans backup de la config
⛔ NE JAMAIS changer le mode de stockage de Thin à Thick sur une VM active sans
   avoir vérifié l'espace disponible sur le datastore
⛔ NE JAMAIS éteindre de force (Power Off) une VM — toujours Shut Down OS en premier
```

---

## 8. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Hôte ESXi déconnecté de vCenter | NOC | Immédiat |
| Datastore < 10% libre | NOC + INFRA | Dans l'heure |
| vCenter inaccessible | NOC + INFRA | Immédiat |
| Corruption VMDK suspectée | INFRA + BackupDR | Immédiat |
<!-- RUNBOOK_END: RUNBOOK__VMware_vSphere_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__Vates_XCPng_Operations_V1 (INFRA__RUNBOOK__Vates_XCPng_Operations_V1.md) -->
# RUNBOOK — Vates XCP-ng / Xen Orchestra : Opérations & Maintenance
**ID :** RUNBOOK__Vates_XCPng_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-SysAdmin
**Domaine :** INFRA — Virtualisation Vates (XCP-ng)
**Mis à jour :** 2026-03-20

---

## 1. PRÉSENTATION XCP-ng / VATES

**XCP-ng** : Hyperviseur open-source basé sur Xen Project (Vates)
**Xen Orchestra (XO)** : Interface de gestion web (équivalent vCenter/Hyper-V Manager)
**XCP-ng Center** : Client desktop Windows (équivalent vSphere Client)

```
Accès :
- Interface web Xen Orchestra : https://[IP_XO]:443
- SSH hôte XCP-ng : ssh root@[IP_HOST]
- CLI hôte : xe (commandes depuis l'hôte)
```

---

## 2. HEALTH CHECK HÔTE XCP-ng

### Via SSH (hôte XCP-ng)
```bash
# État général de l'hôte
xe host-list params=name-label,enabled,memory-total,memory-free

# Liste des VMs et leur état
xe vm-list params=name-label,power-state,VCPUs-number,memory-static-max

# Espace disques (Storage Repositories)
xe sr-list params=name-label,type,physical-size,physical-utilisation

# Snapshots existants
xe snapshot-list params=name-label,snapshot-time,snapshot-of

# État des services hôte
service xapi status
service xenconsoled status

# Vérifier les logs d'erreurs récents
tail -100 /var/log/xensource.log | grep -i "error\|warning\|critical"
```

### Via Xen Orchestra (interface web)
```
1. Dashboard → Overview
   → VMs en état dégradé (rouge/orange)
   → Utilisation CPU/RAM globale
   → Alertes actives

2. Hosts → Sélectionner l'hôte
   → Onglet General : CPU, RAM, stockage
   → Onglet Logs : événements récents

3. Storage → Storage Repositories
   → Espace libre par SR (seuil : > 20%)
```

---

## 3. GESTION DES SNAPSHOTS XCP-ng

```
⚠️ RÈGLE FONDAMENTALE (identique VMware/Hyper-V) :
   - Snapshot = protection temporaire maximum 72h
   - Supprimer après validation du changement
   - NE JAMAIS snapshoter un DC
```

### Convention de nommage
```
@T12345_Preboot_SRV-APP01_SNAP_20260320_2145
```

### Créer un snapshot
```bash
# Via SSH sur l'hôte XCP-ng
VM_UUID=$(xe vm-list name-label="SRV-APP01" --minimal)
SNAP_NAME="@T12345_Preboot_SRV-APP01_SNAP_$(date +%Y%m%d_%H%M)"

xe vm-snapshot vm=$VM_UUID new-name-label="$SNAP_NAME"
echo "Snapshot créé : $SNAP_NAME"
```

### Lister les snapshots d'une VM
```bash
VM_UUID=$(xe vm-list name-label="SRV-APP01" --minimal)
xe snapshot-list snapshot-of=$VM_UUID params=name-label,snapshot-time
```

### Supprimer un snapshot
```bash
SNAP_UUID=$(xe snapshot-list name-label="@T12345_Preboot_SRV-APP01_SNAP_20260320_2145" --minimal)
xe snapshot-destroy uuid=$SNAP_UUID
```

### Restaurer depuis un snapshot
```bash
# ⚠️ La VM doit être éteinte avant le rollback
VM_UUID=$(xe vm-list name-label="SRV-APP01" --minimal)
SNAP_UUID=$(xe snapshot-list name-label="@T12345_Preboot*" --minimal)

xe snapshot-revert snapshot-uuid=$SNAP_UUID
echo "Rollback effectué"
```

---

## 4. MIGRATION VM (XO / XE)

```bash
# Migration à chaud entre hôtes (même pool)
VM_UUID=$(xe vm-list name-label="SRV-APP01" --minimal)
HOST_UUID=$(xe host-list name-label="xcp-host-02" --minimal)

xe vm-migrate vm=$VM_UUID host=$HOST_UUID live=true
```

### Via Xen Orchestra
```
1. VMs → Sélectionner la VM
2. Actions → Migrate
3. Choisir l'hôte de destination
4. Choisir le Storage Repository de destination
5. Confirmer → surveiller la progression
```

---

## 5. GESTION DES BACKUPS XCP-ng

### XO Backup intégré
```
Xen Orchestra → Backup → Backup Jobs
- Types : Full Backup, Delta Backup, Continuous Replication
- Sauvegardes vers : NFS, SMB, S3, Remote Storage

Vérifier les jobs :
1. Xen Orchestra → Backup → Backup Jobs
2. Vérifier Status : ✅ Success / ⚠️ Warning / ❌ Failed
3. Cliquer sur un job → Voir les logs de la dernière exécution
```

---

## 6. MISE À JOUR XCP-ng

```bash
# Sur l'hôte XCP-ng via SSH
# ⚠️ Migrer les VMs vers un autre hôte AVANT la mise à jour

# Mettre l'hôte en mode maintenance (via XO ou xe)
xe host-disable host=$(xe host-list --minimal)

# Appliquer les mises à jour
yum update -y

# Redémarrer l'hôte
reboot

# Après reboot — vérifier les services
service xapi status
xe host-list params=software-version
```

---

## 7. DÉPANNAGE — VM NE DÉMARRE PAS

```bash
# Voir les logs de la VM
VM_UUID=$(xe vm-list name-label="SRV-APP01" --minimal)
xe vm-param-get uuid=$VM_UUID param-name=last-boot-record

# Logs système XCP-ng
grep "SRV-APP01\|$VM_UUID" /var/log/xensource.log | tail -50

# Forcer le démarrage d'une VM bloquée
xe vm-reset-powerstate uuid=$VM_UUID --force
```

### Erreurs courantes

| Erreur | Cause | Action |
|---|---|---|
| `VDI_IN_USE` | Disque verrouillé par un snapshot | Supprimer les snapshots orphelins |
| `SR_FULL` | Storage Repository plein | Libérer de l'espace |
| `HOST_NOT_ENOUGH_FREE_MEMORY` | RAM insuffisante sur l'hôte | Migrer d'autres VMs |
| `XAPI_MISSING_PARAM` | Bug XAPI | Redémarrer le service XAPI |

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer des VDI (disques virtuels) directement depuis le SR sans passer par XO/xe
⛔ NE JAMAIS mettre à jour XCP-ng sans avoir migré les VMs actives
⛔ NE JAMAIS laisser des snapshots > 72h en production
⛔ NE JAMAIS modifier la configuration réseau de l'hôte via SSH directement
   → Utiliser Xen Orchestra pour les changements réseau
⛔ NE JAMAIS redémarrer le service XAPI sans avoir vérifié qu'aucune opération n'est en cours
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| XAPI inaccessible (hôte ne répond plus à XO) | NOC + INFRA | Immédiat |
| SR plein (espace < 10%) | NOC + INFRA | Dans l'heure |
| Corruption VDI | INFRA + BackupDR | Immédiat |
| Mise à jour bloquée | INFRA | Dans la journée |
<!-- RUNBOOK_END: RUNBOOK__Vates_XCPng_Operations_V1 -->

---
