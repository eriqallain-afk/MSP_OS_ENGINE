# GUIDE — Veeam Best Practices MSP
> **Version :** 1.0 | **Date :** 2026-05-19 | **Usage :** Référence pour IT-BackupDRMaster, IT-SysAdmin
> **Agents :** IT-BackupDRMaster | IT-SysAdmin | IT-MonitoringMaster

---

## 1. Règles fondamentales Veeam MSP

### Règle 3-2-1
- **3** copies des données
- **2** supports différents (local + cloud/bande)
- **1** copie hors site

### Rétention recommandée par type de client
| Type client | Rétention locale | Rétention cloud | Fréquence |
|---|---|---|---|
| PME standard | 14 jours | 30 jours | Daily |
| Réglementé (santé, finance) | 30 jours | 365 jours | Daily + Weekly |
| Critique (DC, SQL prod) | 7 jours | 90 jours | Daily + hebdo |

---

## 2. Configuration jobs recommandée

### Backup VM (VMware/Hyper-V)
```
Mode          : Incremental (Forever Forward Incremental recommandé)
Compression   : Optimal
Déduplication : Activée
Fenêtre       : 22:00–06:00 (hors heures d'affaires)
Retry         : 3 tentatives, 10 min d'intervalle
Notification  : Email sur échec (obligatoire)
```

### Backup Agent (serveurs physiques)
```
Mode          : Incremental
Application-aware : Activé (SQL, Exchange, AD)
VSS           : Activé — valider compatibilité antivirus
```

---

## 3. Erreurs fréquentes et causes

| Erreur | Cause probable | Action |
|---|---|---|
| `Failed to retrieve object hierarchy` | Probe RMM sur port SSH VMware | Vérifier polling RMM — réduire fréquence |
| `VSSControl: Timed out` | Antivirus bloquant VSS | Exclusions AV pour Veeam + VSS writers |
| `Unable to truncate transaction logs` | Permissions SQL insuffisantes | Vérifier compte service Veeam sur SQL |
| `Repository out of space` | Rétention mal configurée | Revoir politique de rétention |
| `Network timeout` | WAN instable ou MTU | Ping test + vérifier MTU entre sites |

---

## 4. Checklist post-installation

- [ ] Job de backup configuré avec fenêtre hors heures
- [ ] Notifications email activées (succès ET échec)
- [ ] Test de restauration effectué (au moins 1 VM ou fichier)
- [ ] Rétention validée selon politique client
- [ ] Repository espace libre > 20%
- [ ] Veeam ONE ou alertes RMM configurées pour les échecs

---

## 5. Validation rapide (lecture seule)

```powershell
# Vérifier les jobs et dernières sessions
Get-VBRJob | Select-Object Name, JobType, IsScheduleEnabled, @{N='LastResult';E={$_.GetLastResult()}}

# Sessions des dernières 24h
Get-VBRBackupSession | Where-Object {$_.CreationTime -gt (Get-Date).AddHours(-24)} | 
  Select-Object JobName, CreationTime, Result, Progress | Sort-Object CreationTime -Descending
```

---

## 6. Escalades

| Situation | Action |
|---|---|
| Backup critique échoué > 24h | Escalade IT-UrgenceMaster si impact RPO |
| Perte de données confirmée | IT-BackupDRMaster + notification EA |
| Repository plein | IT-SysAdmin pour expansion stockage |

---

*GUIDE Veeam Best Practices v1.0 — IT-SHARED/50_REFERENCE — MSP Intelligence AI — 2026-05-19*
