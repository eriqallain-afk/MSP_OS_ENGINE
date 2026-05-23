# INFRA-SRV-VMware_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__VMware_vSphere_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-MaintenanceMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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

## 8. PANNE CONTRÔLEUR RAID / ALERTE HARDWARE ESXI

> **P1 immédiat.** Un contrôleur RAID défaillant peut entraîner la perte du datastore et de toutes les VMs hébergées dessus. **Évacuer les VMs avant que l'hôte tombe.**

### 8.1 Détecter l'alerte RAID

**Via vSphere Client :**
1. Host → Monitor → Hardware Health → Storage Controllers
2. Chercher status `Critical` / `Warning` / `Degraded` sur le contrôleur RAID
3. Vérifier les datastores hébergés sur cet hôte — sont-ils accessibles ?

**Via SSH sur l'hôte ESXi :**
```bash
# État santé hardware complet
esxcli hardware ipmi sel list | tail -20

# Contrôleurs de stockage détectés
esxcli storage core adapter list

# Périphériques de stockage et état
esxcli storage core device list | grep -i "status\|model\|state"

# Logs hardware récents
grep -i "raid\|storage\|error\|warning" /var/log/vmkernel.log | tail -30
```

**Via outil vendor (ILO / iDRAC / XCC) :**
- HP : accéder à iLO → IML (Integrated Management Log) — chercher RAID / Array Controller
- Dell : accéder à iDRAC → Storage → Controllers
- Lenovo : accéder à XClarity Controller → Storage

### 8.2 Triage — Niveau de criticité

| Symptôme | Criticité | Action |
|---|---|---|
| RAID dégradé — 1 disque manquant | 🔴 P1 | Évacuer VMs immédiatement — remplacer disque |
| Contrôleur non répondant | 🔴 P1 | Évacuer VMs immédiatement — escalade vendor |
| Datastore inaccessible / unmounted | 🔴 P1 | VMs peut-être perdues — activer plan DR |
| Alerte predictive (SMART warn) | ⚠️ P2 | Planifier remplacement disque — surveiller |
| RAID rebuild en cours | ⚠️ P2 | NE PAS rebooter — surveiller jusqu'à 100% |

### 8.3 Évacuation VMs — Priorité absolue

> ⛔ NE PAS mettre l'hôte en maintenance avant d'avoir confirmé que les VMs critiques sont migrées.

```powershell
Connect-VIServer -Server "vcenter.domaine.com"

# Lister les VMs sur l'hôte à risque
$hote = Get-VMHost "esxi-hote-problematique.domaine.com"
Get-VM -Location $hote | Select-Object Name, PowerState, @{N='Host';E={$_.VMHost}}

# vMotion VM par VM vers un hôte sain
Move-VM -VM "SRV-CRITIQUE-01" -Destination (Get-VMHost "esxi-sain.domaine.com") -Confirm:$false

# Storage vMotion si le datastore est à risque (migration des disques)
Move-VM -VM "SRV-APP01" -Datastore (Get-Datastore "DATASTORE_SAIN") -Confirm:$false
```

**Si vMotion impossible (hôte non répondant) :**
- VMs avec haute disponibilité (HA) → redémarreront automatiquement sur un autre hôte
- VMs sans HA → enregistrer leur config depuis un autre hôte si le datastore est encore lisible
- Activer le runbook DR si perte de données confirmée

### 8.4 Mise en maintenance et escalade vendor

```bash
# Depuis vSphere Client : hôte → Actions → Maintenance Mode → Enter
# OU via PowerCLI :
Set-VMHost -VMHost "esxi-hote-problematique.domaine.com" -State Maintenance
```

**Escalade vendor obligatoire :**
- Ouvrir un ticket hardware avec le vendor (HP/Dell/Lenovo)
- Fournir : modèle serveur, numéro de série, IML/logs contrôleur, symptômes
- Demander remplacement du disque ou du contrôleur en onsite si P1

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Hôte ESXi déconnecté de vCenter | NOC | Immédiat |
| Datastore < 10% libre | NOC + INFRA | Dans l'heure |
| vCenter inaccessible | NOC + INFRA | Immédiat |
| Corruption VMDK suspectée | INFRA + BackupDR | Immédiat |
| RAID dégradé / contrôleur en erreur | INFRA + Vendor hardware | Immédiat |
| Datastore inaccessible — VMs perdues | INFRA + BackupDR + NOC | Immédiat |
