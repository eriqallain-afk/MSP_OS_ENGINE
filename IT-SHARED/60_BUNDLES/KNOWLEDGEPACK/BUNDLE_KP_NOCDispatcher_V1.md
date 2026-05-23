# BUNDLE_KP_NOCDispatcher_V1
**Agent :** @IT-Commandare-NOCDispatcher | **Mis à jour :** 2026-03-29 | IT-MaintenanceMaster | IT-SysAdmin

## MATRICE DE PRIORITÉ DISPATCH

| Priorité | Critères | SLA réponse | SLA résolution | Assignation |
|---|---|---|---|---|
| P1 | Service critique down, multi-users impactés, sécurité active | < 15 min | 4h | Commandare + senior immédiat |
| P2 | Service dégradé, groupe impacté, backup critique | < 30 min | 8h | Technicien N2/N3 assigné |
| P3 | Utilisateur unique, problème fonctionnel | < 2h | 24h | Technicien N2 disponible |
| P4 | Demande de service, planification | < 4h | 72h | File d'attente standard |

## ROUTING PAR DOMAINE

| Domaine | Agent cible | Intents |
|---|---|---|
| Support utilisateur | @IT-Commandare-TECH | helpdesk, poste, imprimante, accès |
| Réseau / VPN / firewall | @IT-Commandare-NOC | réseau, vpn, wan, switch |
| Serveurs / VMs / cloud | @IT-Commandare-Infra | serveur, vm, azure, dc |
| Sécurité | @IT-SecurityMaster | phishing, malware, breach |
| Maintenance / patching | @IT-MaintenanceMaster | patching, maintenance |
| Urgence P1/P2 live | @IT-UrgenceMaster | panne, urgence, p1 |

## PROTOCOLE ESCALADE SLA
```
SI ticket approche 80% du SLA sans résolution :
1. Notifier le technicien assigné
2. SI pas de réponse en 15 min → réassigner
3. SI SLA dépassé → escalader au Commandare du domaine
4. Documenter chaque escalade dans la note interne CW
```

## SHIFT HANDOVER
```
Fin de quart obligatoire :
- Lister tous les tickets P1/P2 actifs avec statut et prochaine action
- Identifier les tickets proches du SLA
- Transmettre les maintenances planifiées dans les 12h
- Le quart entrant confirme réception
```

---
*BUNDLE_KP_NOCDispatcher_V1 — Version 1.0*
