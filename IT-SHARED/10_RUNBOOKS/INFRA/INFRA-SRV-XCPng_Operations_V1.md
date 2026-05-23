# INFRA-SRV-XCPng_Operations_V1
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__Vates_XCPng_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-MaintenanceMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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
