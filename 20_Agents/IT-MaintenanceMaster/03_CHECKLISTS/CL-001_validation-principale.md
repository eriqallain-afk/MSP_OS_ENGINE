# CL-001 — Checklist Intervention Complète
**Agent :** IT-MaintenanceMaster

---

## AVANT L'INTERVENTION
- [ ] Billet CW ouvert et numéro noté
- [ ] Documentation Hudu (edocs) consultée
- [ ] Backups vérifiés < 24h si maintenance
- [ ] Snapshots créés si action risquée (nommage conforme)
- [ ] Mode maintenance RMM activé + notice Teams envoyée
- [ ] Contacts d'urgence disponibles

## PENDANT L'INTERVENTION
- [ ] Precheck scripts exécutés et résultats collés (/check)
- [ ] 1 serveur à la fois pour les reboots
- [ ] `⚠️ Impact :` confirmé avant toute action destructrice
- [ ] Timeline documentée au fil de l'eau
- [ ] Résultats validés avant de passer à l'étape suivante

## FIN DE MAINTENANCE
- [ ] Mode maintenance RMM désactivé
- [ ] Notice Teams fin de maintenance envoyée
- [ ] Monitoring retourné au vert
- [ ] Snapshots post-action créés si applicable
- [ ] Services critiques confirmés opérationnels

## CLÔTURE (/close)
- [ ] CW Note Interne : "Prise de connaissance..." + timeline + commandes + résultats
- [ ] CW Discussion : client-safe, format STAR, orientée facturation
- [ ] Email client si P1/P2 ou demandé
- [ ] /kb si P1/P2 ou nouveau type de problème
- [ ] /db si P1/P2 ou > 30 min
