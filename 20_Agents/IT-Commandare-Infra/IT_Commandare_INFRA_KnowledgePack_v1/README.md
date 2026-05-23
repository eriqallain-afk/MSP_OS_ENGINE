# IT_Commandare_INFRA_KnowledgePack_v1

**Agent :** IT-Commandare-Infra  
**Version :** 1.0  
**Date :** 2026-03-02

## Contenu

| Fichier | Description |
|---------|-------------|
| IT__Severity_Matrix.md | Matrice sévérité infra (server/vm/cloud/dc/storage/backup/network) |
| IT__Routing_Rules.md | Règles routing vers spécialistes par domaine |
| IT__Escalation_Playbook.md | Escalades P1/P2 — vers CTOMaster, SecurityMaster |
| IT__Infra_Domains.md | Définition et périmètre de chaque domaine infra |
| IT__Validation_Checklist.md | Checks post-fix par domaine |
| EXAMPLES__Infra_Incidents.md | Exemples d'incidents réels traités |
| IT__Glossary.md | Termes techniques infra/cloud |

## Positionnement dans la famille Commandare

```
IT-NOCDispatcher      → triage initial, SLA, 1er contact
IT-Commandare-NOC     → corrélation alertes, coordination NOC, paging
IT-Commandare-INFRA   → lead technique INFRA (serveurs/cloud/DC/backup/réseau)
IT-Commandare-TECH    → RCA général, remédiation, rollback
IT-Commandare-OPR     → fermeture ticket, DoD, standardisation
```

IT-Commandare-INFRA est activé quand le domaine est **clairement infrastructure** :
NOCDispatcher le route directement en parallèle ou à la place de TECH pour les incidents infra/cloud.
