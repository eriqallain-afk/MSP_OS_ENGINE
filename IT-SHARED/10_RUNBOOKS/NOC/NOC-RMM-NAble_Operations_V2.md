# NOC-RMM-NAble_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__NAble_RMM_Operations_V1
**Version :** 1.0 | **Agents :** IT-MonitoringMaster, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** NOC — RMM
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS N-ABLE

| Produit | Accès |
|---|---|
| **N-sight RMM** | https://[votre-domaine].systemmonitor.eu.com |
| **N-central** | https://[serveur-ncentral] |

---

## 2. HEALTH CHECK MATINAL N-ABLE

```
Dashboard → Overview
→ Devices Online/Offline/Failed
→ Alertes actives (Critical/Warning)
→ Patch Status : appareils avec patchs manquants

Sites → [Client]
→ Statut par appareil
→ Alertes non acquittées
```

---

## 3. ALERTES N-ABLE — TRAITEMENT

### Acquitter une alerte
```
1. Dashboard → Active Alerts
2. Sélectionner l'alerte → Acknowledge
3. Ajouter un commentaire : "Billet #XXXXXX — en investigation"
4. Traiter l'alerte → Mark as Resolved une fois résolu
```

### Types d'alertes et actions standard

| Type | Seuil typique | Action |
|---|---|---|
| CPU High | > 90% pendant 15 min | Vérifier processus → escalade NOC |
| Disk Space Low | < 10% libre | Nettoyage → escalade INFRA |
| Service Down | Service critique arrêté | Redémarrer → escalade si récurrent |
| Backup Failed | Job Veeam/Datto en échec | Voir runbook backup |
| Device Offline | Plus de heartbeat | Vérifier réseau/alimentation |
| Patch Missing | Patchs critiques manquants | Planifier patching |
| AV/EDR Alert | Menace détectée | Escalade SOC immédiate |

---

## 4. MODE MAINTENANCE N-ABLE

```
⚠️ OBLIGATOIRE avant toute intervention planifiée

N-sight RMM :
1. Devices → [Appareil] → Maintenance
2. Enable Maintenance → durée en minutes
3. Confirmer → les alertes sont suspendues

N-central :
1. Devices → [Appareil] → Actions → Set Maintenance Mode
2. Durée → Confirm

⚠️ TOUJOURS désactiver après l'intervention
```

---

## 5. DÉPLOIEMENT DE SCRIPTS DEPUIS N-ABLE

```
N-sight RMM → Script Manager
1. Sélectionner le ou les appareils cibles
2. Run Task → Script / PowerShell
3. Coller ou choisir le script
4. Exécuter → surveiller les résultats dans Task History

N-central :
1. Configuration → Scheduled Tasks → Add Automation Policy
2. Script Repository → choisir ou uploader le script
3. Assigner aux appareils cibles
4. Voir les résultats dans : Reports → Script Results
```

---

## 6. GESTION DES PATCHS WINDOWS

```
N-sight RMM → Patch Management
→ Approuver les patchs : Security → Approve
→ Planifier le déploiement : Schedule → fenêtre de maintenance

Rapports de patch :
Reports → Patch Status Report → par client
→ Appareils non patchés depuis > 30 jours (attention particulière)
→ Patchs critiques manquants (CVSS > 7.0)
```

---

## 7. RAPPORT MENSUEL N-ABLE

```
Reports → All Reports
→ Device Availability : temps de disponibilité par appareil
→ Patch Compliance : % de conformité patchs
→ Alert Summary : nombre d'alertes par type
→ Performance : CPU/RAM/Disk moyens

Export en PDF pour rapport client mensuel
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS ignorer les alertes Critical sans les acquitter et documenter
⛔ NE JAMAIS exécuter des scripts sur plusieurs clients simultanément sans test préalable
⛔ NE JAMAIS supprimer un appareil de N-able sans désinstaller l'agent d'abord
⛔ NE PAS oublier de désactiver le mode maintenance après intervention
   Les alertes réelles seraient ignorées silencieusement
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| > 20 appareils offline simultanément | NOC | Immédiat |
| Alerte sécurité AV/EDR | SOC | Immédiat |
| N-central/N-sight inaccessible | NOC + INFRA | 30 min |
| Disque critique sur serveur PROD | NOC + INFRA | Dans l'heure |
