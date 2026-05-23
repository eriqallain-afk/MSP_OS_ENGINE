# NOC-BACKUP-Datto_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

# PARTIE 1 — DATTO BCDR (SIRIS / ALTO)
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## 1.1 ACCÈS CONSOLE DATTO BACKUP

| Méthode | Accès |
|---|---|
| **Partner Portal** | https://partners.datto.com |
| **Interface locale appareil** | https://[IP_DATTO] (réseau local) |
| **Datto RMM (si intégré)** | Via le portail RMM |

---

## 1.2 VÉRIFICATION JOURNALIÈRE DES BACKUPS

```
Partner Portal → Devices → [Appareil Datto] → Backups

Vérifier pour chaque agent :
✅ Success (vert) → OK
⚠️ Warning → Lire le détail — souvent tolérable (fichiers locked)
❌ Failed → Intervention requise

Points de vérification :
→ Dernier backup réussi (date/heure)
→ Backup local OK + Backup cloud OK
→ Vérification screenshot (Datto prend un screenshot de la VM bootée)
   ✅ Screenshot présent = backup bootable
   ❌ Screenshot absent ou écran noir = problème d'intégrité
```

---

## 1.3 BACKUPS EN ÉCHEC — CODES D'ERREUR COURANTS

| Erreur | Cause probable | Action |
|---|---|---|
| `VSS Error` | VSS defaillant sur la machine | Vérifier VSS sur la machine cible |
| `Snapshot failed` | Driver Datto ou conflit snapshot | Vérifier le driver Datto Agent |
| `Network timeout` | Connectivité vers l'appareil Datto | Vérifier réseau entre Datto et la machine |
| `Agent not responding` | Service Datto Agent arrêté | Redémarrer le service Datto Backup Agent |
| `Insufficient space` | Disque Datto plein | Vérifier espace local + cloud |
| `Backup queue full` | Trop de backups en attente | Forcer un backup complet |

### Redémarrer le service Datto Agent
```powershell
# Sur la machine protégée par Datto
Get-Service -Name "Backup Agent Service" | Restart-Service -Force
# OU selon la version :
Get-Service | Where-Object {$_.Name -match "Datto\|Backup Agent"} | Restart-Service
```

---

## 1.4 RESTAURATION DATTO

### Restauration de fichiers/dossiers
```
1. Partner Portal → Devices → [Appareil Datto] → Restore
2. Sélectionner l'agent (machine source)
3. Sélectionner le point de restauration (date/heure)
4. Choisir : File Restore
5. Naviguer → sélectionner les fichiers → Restore
6. Options : restaurer sur la machine d'origine OU télécharger localement
```

### Virtualization locale (Datto Instant Virtualization)
```
⚠️ Utiliser si la machine physique est HS — démarrer la VM depuis le backup

1. Partner Portal → Devices → [Appareil Datto] → Restore → Virtualize
2. Sélectionner le point de restauration
3. "Local Virtualize" → la VM démarre sur l'appliance Datto locale
4. Connexion via lien fourni dans le portail

⚠️ Performance réduite vs la machine physique
⚠️ Durée maximale recommandée : 72h (solution temporaire)
⚠️ NE PAS modifier des données critiques en mode virtualization sans plan de restauration définitive
```

### Bare Metal Restore (BMR)
```
Pour restauration sur nouveau hardware :
1. Partner Portal → Devices → [Appareil Datto] → Restore → Bare Metal Restore
2. Télécharger l'ISO de restauration Datto
3. Booter le nouveau serveur depuis l'ISO
4. Suivre l'assistant de restauration

⚠️ Durée selon la taille : compter 2-8h pour un serveur standard
⚠️ Valider les licences Windows après la restauration
```

---

## 1.5 VÉRIFICATION STOCKAGE ET RÉTENTION

```
Partner Portal → Devices → [Appareil Datto] → Storage
→ Espace local utilisé / disponible
→ Espace cloud utilisé

⚠️ Alerter si local > 80% utilisé
Action : Partner Portal → Settings → Retention Settings → ajuster la rétention
OU : contacter Datto pour extension de stockage cloud
```

---

# PARTIE 2 — DATTO RMM

## 2.1 ACCÈS DATTO RMM

| Accès | URL |
|---|---|
| **Portail Datto RMM** | https://[votre-domaine].centrastage.net |
| **Desktop Agent** | Application locale sur les postes |

---

## 2.2 HEALTH CHECK DATTO RMM

```
Dashboard → Devices
→ Devices Online / Offline
→ Alertes actives (rouge/orange)

Sites → [Client] → Devices
→ Statut par appareil : Online, Offline, Maintenance

Alerts → Active Alerts
→ Trier par priorité et type
→ Acknowledge les alertes traitées
```

---

## 2.3 SCRIPTS ET AUTOMATISATION DATTO RMM

```
Jobs → Create Job
→ Sélectionner les cibles (1 device, site, ou groupe)
→ Choisir le composant (script PS, batch, package)
→ Planifier ou exécuter maintenant

Bibliothèque de composants :
ComStore → rechercher par catégorie
→ Patch Management, Software Install, Cleanup, Monitoring
```

---

## 2.4 MODE MAINTENANCE (SUPPRESSION ALERTES PENDANT MAINTENANCE)

```
⚠️ TOUJOURS activer le mode maintenance avant une intervention planifiée

Device → [Appareil] → Maintenance → Enable Maintenance Mode
→ Durée : en minutes
→ Les alertes sont suspendues pendant la durée définie

Après l'intervention :
Device → [Appareil] → Maintenance → Disable Maintenance Mode

⛔ NE JAMAIS oublier de désactiver le mode maintenance après intervention
   Les alertes réelles seraient ignorées
```

---

## 2.5 ALERTES DATTO RMM — TYPES ET ACTIONS

| Type d'alerte | Action standard |
|---|---|
| Offline Device | Vérifier alimentation, réseau, puis escalader |
| Disk Usage > 90% | Nettoyage immédiat → escalade INFRA |
| High CPU / Memory | Investiguer processus → escalade si persistant |
| Patch Status Failed | Vérifier WSUS / Windows Update |
| Backup Failed | Vérifier Datto BCDR / Veeam |
| Security Alert (AV/EDR) | Escalade SOC immédiate |
| Service Down | Redémarrer le service → escalade si récurrent |

---

## 3. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer un point de restauration Datto manuellement
⛔ NE JAMAIS laisser le mode Virtualization actif > 72h sans plan de sortie
⛔ NE JAMAIS modifier les politiques de rétention sans approbation et impact évalué
⛔ NE PAS ignorer les erreurs de screenshot Datto — signe que le backup n'est pas bootable
⛔ NE JAMAIS oublier de désactiver le mode maintenance RMM
```

---

## 4. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Backup en échec machine critique > 24h | NOC + BackupDR | Dans l'heure |
| Appareil Datto BCDR inaccessible | NOC + BackupDR | Immédiat |
| Stockage local Datto > 90% | BackupDR + INFRA | Dans l'heure |
| Restauration en cours (machine HS) | BackupDR + INFRA | Suivi continu |
