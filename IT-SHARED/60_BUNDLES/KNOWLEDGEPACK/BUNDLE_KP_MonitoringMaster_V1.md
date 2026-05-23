# BUNDLE_KP_MonitoringMaster_V1
**Agent :** @IT-MonitoringMaster | **Mis à jour :** 2026-03-29 | IT-MaintenanceMaster | IT-SysAdmin

## SEUILS STANDARD MSP

| Métrique | Warning | Critical | Fréquence | Action |
|---|---|---|---|---|
| CPU (avg 15min) | > 80% | > 95% | 5 min | Identifier processus → escalade |
| RAM | > 85% | > 95% | 5 min | Identifier consommateur |
| Disk libre | < 20% | < 10% | 15 min | Nettoyage ou escalade |
| Disk growth | > 5GB/j | > 15GB/j | 1h | Investiguer source |
| Services critiques | Dégradé | Arrêté | 2 min | Redémarrer → escalade si récurrent |
| Latence LAN | > 20ms | > 100ms | 5 min | Vérifier switch/câblage |
| Latence WAN | > 50ms | > 200ms | 5 min | Vérifier lien opérateur |
| Backup last success | > 24h | > 48h | 1h | Alerte → BackupDRMaster |
| SSL expiry | 30 jours | 7 jours | 24h | Planifier renouvellement |
| Patch compliance | < 90% | < 75% | 24h | Alerter MaintenanceMaster |
| Device offline | > 15min | > 30min | 5 min | Vérifier alimentation/réseau |

## TUNING ALERTES — RÉDUCTION DU BRUIT
```
RÈGLE : Si une alerte se déclenche > 5 fois en 24h sans action requise = faux positif
→ Ajuster le seuil OU ajouter une exclusion OU augmenter la durée

EXEMPLES DE TUNING :
- CPU spike pendant backup nocturne → exclusion par plage horaire
- Disk temp plein puis libéré → seuil sur durée (>30min) pas sur pic
- Service redémarré automatiquement → alerte seulement si >3 redémarrages/24h
```

## MAINTENANCE WINDOWS (configuration monitoring)
```
Avant maintenance planifiée :
1. Activer le mode maintenance sur les assets concernés dans le RMM
2. Documenter la fenêtre (client, serveurs, heure début/fin)
3. Vérifier que les alertes sont suspendues
4. Post-maintenance : désactiver le mode maintenance
5. Vérifier qu'aucune alerte n'a été manquée pendant la fenêtre
```

## HANDOFF
| Vers | Quand |
|---|---|
| @IT-Commandare-NOCDispatcher | Alerte active à dispatcher |
| @IT-Commandare-NOC | Incident P1/P2 confirmé |
| @IT-ReportMaster | Données pour rapport mensuel |

---
*BUNDLE_KP_MonitoringMaster_V1 — Version 1.0*
