# CL-001 — Checklist Triage NOC et Shift Handover
**Agent :** @IT-Commandare-NOC | **Type :** NOC Operations
**Version :** 1.0 | **Mis à jour :** 2026-03-28

## TRIAGE ALERTE ENTRANTE

### Classification
- [ ] Source identifiée (RMM / SIEM / Auvik / appel / ticket CW)
- [ ] Client identifié dans ConnectWise
- [ ] Site impacté identifié
- [ ] Domaine classifié (réseau | vpn | backup | monitoring | voip | urgence)
- [ ] Sévérité assignée (P1 / P2 / P3 / P4)

### Corrélation (obligatoire P1/P2, recommandé P3)
- [ ] Alertes actives vérifiées pour le même client
- [ ] Alertes actives vérifiées pour le même site
- [ ] Même type d'alerte vérifié sur d'autres clients
- [ ] Si corrélation : sévérité remontée et billet parent créé

### Communication P1/P2
- [ ] Notice Teams publiée dans le canal NOC (< 5 min P1 / < 15 min P2)
- [ ] Sous-agent approprié mobilisé
- [ ] Client notifié (email ou appel selon sévérité)

### Documentation
- [ ] Billet CW créé ou mis à jour
- [ ] Chronologie horodatée dans la note interne
- [ ] Sous-agent assigné documenté
- [ ] Prochaine action et ETA documentés

---

## SHIFT HANDOVER (fin de quart)

### Avant de quitter
- [ ] Tous les incidents P1/P2 actifs documentés avec statut et prochaine action
- [ ] Alertes non résolues listées avec contexte
- [ ] Maintenances planifiées dans les 12 prochaines heures identifiées
- [ ] Notes de quart rédigées (observations, anomalies, tendances)
- [ ] Handover transmis au quart entrant (oral + écrit)

### Validation handover
- [ ] Quart entrant confirme réception et compréhension
- [ ] P1 actif : superviseur informé de la passation
- [ ] P2 actif : dernier statut client envoyé dans les 30 dernières minutes
- [ ] Aucun incident actif "sans propriétaire" après la passation

---

## CLÔTURE INCIDENT

### Validation technique
- [ ] Service rétabli et fonctionnel (confirmé par monitoring)
- [ ] Client confirme le retour à la normale
- [ ] Aucune alerte résiduelle active pour le même périmètre
- [ ] Cause identifiée et documentée (ou RCA planifié)

### Documentation clôture
- [ ] Note interne CW complète (chronologie, actions, résolution)
- [ ] Discussion CW client-safe rédigée
- [ ] Notice Teams de clôture publiée
- [ ] KB requis si nouveau type d'incident → @IT-KnowledgeKeeper

---
*CL-001 — @IT-Commandare-NOC — Version 1.0*
