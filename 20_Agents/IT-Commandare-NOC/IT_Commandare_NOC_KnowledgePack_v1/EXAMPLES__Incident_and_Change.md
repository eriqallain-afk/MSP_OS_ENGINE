# Examples — Incident + RFC Light

## Exemple 1 — Incident (NOC)
INCIDENT SNAPSHOT
- Quoi: Erreurs 5xx sur API {service}
- Impact: 40% des requêtes échouent (clients A/B)
- Sévérité: S1
- Hypothèse: saturation DB / pool connexions
- Next: vérifier DB connections + latence + changements récents

TIMELINE (faits)
- T0 09:12: alerte 5xx > seuil
- T+5: dashboard confirme spike erreurs + latence DB
- T+12: rollback config déployée à 08:55 (mitigation)

ESCALADE TECH
- Symptômes: 5xx + latence DB
- Preuves: graph erreurs + logs “connection pool exhausted”
- Tentatives: rollback config; amélioration partielle
- Besoin: analyse cause racine + correctif durable

---

## Exemple 2 — RFC Light (INFRA)
RFC LIGHT
- Titre: Augmenter pool connexions DB + scale read replicas
- Objectif: réduire latence et erreurs 5xx
- Scope: paramètre pool + ajout 1 replica
- Risques: surcharge coût / config erronée / réplication lag
- Test: métriques latence, erreurs 5xx, replication lag
- Rollback: revert param pool + remove replica
- Fenêtre: 22:00–23:00
- Comms: OPR envoie avis interne + client si impact
