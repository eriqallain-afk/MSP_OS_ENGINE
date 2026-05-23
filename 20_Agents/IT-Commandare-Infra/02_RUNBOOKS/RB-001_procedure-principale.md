# RB-001 — Triage Incident Infrastructure P1/P2
**Agent :** IT-Commandare-Infra | **Usage :** Incident infra entrant

---

## Étapes de triage

1. **Confirmer le périmètre** — 1 VM ? Site entier ? Service spécifique ?
2. **Identifier la couche** — réseau / hyperviseur / OS / application / backup
3. **Évaluer la sévérité** — P1/P2/P3/P4 selon matrice
4. **Isoler si compromission** suspectée → escalade IT-SecurityMaster
5. **Mobiliser le spécialiste** avec contexte complet
6. **Mettre à jour CW** toutes les 15 min (P1) ou 30 min (P2)

---

## Arbre de décision rapide

```
DC / AD inaccessible        → IT-MaintenanceMaster + IT-NetworkMaster (P1)
VM critique down            → IT-MaintenanceMaster (P1/P2)
Azure / M365 inaccessible   → IT-CloudMaster (P1/P2)
Réseau infra / WAN          → IT-NetworkMaster (P1/P2)
Backup KO + données à risque → IT-BackupDRMaster (P1/P2)
Capacité ≥ 95%              → IT-MaintenanceMaster (P2/P3)
Sécurité suspectée          → IT-SecurityMaster en lead (P1)
```

---

## Matrice sévérité infra

| Sév. | Critères | SLA réponse |
|---|---|---|
| P1 | DC down, réseau core, Azure tenant inaccessible, stockage corrompu | < 5 min |
| P2 | Réplication AD dégradée, backup KO 24h+, VM dégradée, disk ≥ 95% | < 15 min |
| P3 | Snapshot échoué, service secondaire arrêté, disk ≥ 85% | < 1h |
| P4 | Alerte informationnelle, capacity planning | < 4h |

---

## Communication P1/P2

- Client notifié immédiatement (P1) ou dans 30 min (P2)
- IT-Commandare-OPR pour la clôture formelle
- Mises à jour toutes les 30 min (P1) jusqu'à stabilisation
