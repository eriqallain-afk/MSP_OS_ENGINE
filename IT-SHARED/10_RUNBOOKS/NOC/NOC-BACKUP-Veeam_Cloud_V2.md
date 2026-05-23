# NOC-BACKUP-Veeam_Cloud_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__Veeam_Cloud_Operations_V1
**Version :** 1.0 | **Agents :** IT-BackupDRMaster, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — Backup Cloud
**Mis à jour :** 2026-03-20

---

## 1. PRÉSENTATION VEEAM CLOUD CONNECT

Veeam Cloud Connect permet de sauvegarder vers le cloud d'un fournisseur MSP
et d'effectuer des restaurations depuis le cloud (Disaster Recovery as a Service).

**Composants :**
- **Cloud Repository** : stockage cloud des backups off-site
- **Cloud Host** : hôte de réplication/restauration cloud
- **Service Provider Console** : portail MSP de gestion centralisée

---

## 2. ACCÈS ET GESTION

| Accès | Description |
|---|---|
| **VBR Console** | Console Veeam locale — configuration des jobs cloud |
| **Veeam Service Provider Console** | https://[URL_VSPC] — portail MSP centralisé |
| **Veeam Cloud Connect portail** | Interface client (si déployé) |

---

## 3. CONFIGURATION D'UN JOB BACKUP VERS LE CLOUD

```
Dans VBR Console (côté client) :
1. Backup Jobs → New Backup Job → [Nom] → Next
2. Virtual Machines : sélectionner les VMs à sauvegarder
3. Storage : choisir le Cloud Repository (fournisseur)
   → Celui-ci apparaît si le Cloud Connect est configuré
4. Guest Processing : activer VSS application-aware
5. Schedule : planification (ex: quotidien 22h)
6. Retention : nombre de points de restauration à conserver
7. Finish → Run Now (pour tester)
```

---

## 4. VÉRIFICATION DES BACKUPS CLOUD

```
VBR Console → Home → Last 24 Hours
→ Filtrer par Repository : Cloud Repository

Veem Service Provider Console :
VSPC → Companies → [Client] → Protected Data
→ Backup size
→ Dernière synchronisation réussie
→ Points de restauration disponibles
```

---

## 5. RESTAURATION DEPUIS LE CLOUD

### Restauration de fichiers
```
VBR Console → Backups → Cloud → [Backup]
→ Clic droit → Restore guest files
→ Sélectionner le point de restauration cloud
→ Browser → naviguer → Restore

⚠️ La restauration depuis le cloud est plus lente (dépend de la bande passante)
Compter : ~50-200 MB/s selon la connexion
```

### Failover vers le Cloud (Disaster Recovery)
```
⚠️ Procédure d'urgence — VM démarre dans le cloud du fournisseur

VBR Console → Backups → Cloud → [VM] → Failover to Cloud
→ Sélectionner le point de restauration
→ La VM démarre dans l'infrastructure cloud
→ Accès via VPN ou Direct Connect au fournisseur

Failback (retour au site primaire) :
1. VBR Console → Home → [VM en cours de Failover] → Failback to Production
2. Choisir la VM cible (restauration sur le site original)
3. Commiter le Failback une fois validé
```

---

## 6. SURVEILLANCE VIA SERVICE PROVIDER CONSOLE

```
VSPC → Alarms
→ Backup Jobs Failed
→ License Usage
→ Storage Usage Warnings

VSPC → Reporting → Backup Status Report
→ Export PDF/HTML pour rapport client
```

---

## 7. GESTION DES QUOTAS CLOUD

```
Si le quota de stockage cloud est dépassé :
1. VSPC → Companies → [Client] → Edit → Cloud Resources → Adjust quota
2. OU supprimer d'anciens points de restauration dans VBR
3. Vérifier la politique de rétention (durée et nombre de points)
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer un Cloud Repository actif sans avoir vérifié les dépendances
⛔ NE JAMAIS laisser un Failover actif > 72h sans plan de Failback validé
⛔ NE PAS ignorer les alertes de quota dépassé (les backups s'arrêtent)
⛔ NE JAMAIS modifier les paramètres de bande passante Cloud Connect en heures de production
   sans préavis au client
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Synchronisation cloud en échec > 48h | BackupDR | Dans l'heure |
| Quota cloud dépassé | BackupDR + TECH | Dans la journée |
| Failover cloud activé | BackupDR + INFRA | Suivi immédiat |
| Restauration urgente depuis cloud | BackupDR | Immédiat |
