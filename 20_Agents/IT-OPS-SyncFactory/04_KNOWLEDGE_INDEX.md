# 04_KNOWLEDGE_INDEX — IT-OPS-SyncFactory

> Index de toutes les sources de connaissance utilisées par cet agent.
> Mis à jour à chaque ajout de fichier dans 05_KNOWLEDGE/ ou changement de source.

## Sources externes (repo IT — getFileContent)

| Fichier | Rôle | Priorité |
|---|---|---|
| `FACTORY_MANIFEST_IT.yaml` | Source de vérité du produit — référence principale | P0 |
| `00_INDEX/agents_index.yaml` | Index officiel des agents actifs | P0 |
| `00_FACTORY_SYNC/CURRENT_STATE.yaml` | Dernier état synchronisé avec la Factory | P0 |
| `99_STAGING/Draft/` | Modules en préparation (scan du dossier) | P1 |
| `playbooks/playbooks.yaml` | Playbooks actifs | P1 |
| `00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` | Routing intent → runbook | P2 |

## Sources produites (outputs de cet agent)

| Fichier | Description |
|---|---|
| `00_FACTORY_SYNC/CURRENT_STATE.yaml` | État produit mis à jour après chaque /sync |
| `00_FACTORY_SYNC/outbox/FACTORY_SYNC_{date}.yaml` | Rapport de synchronisation pour la Factory |
| `00_FACTORY_SYNC/CHANGELOG.md` | Journal chronologique des changements transmis |

## Guardrails & Politiques

| Fichier | Description |
|---|---|
| `IT-SHARED/10_RUNBOOKS/00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md` | Guardrails master — chargé en priorité |

## Notes
- Cet agent ne dispose pas de fichiers 05_KNOWLEDGE/ locaux — toutes les sources sont lues en temps réel via getFileContent
- Le delta est calculé en comparant FACTORY_MANIFEST_IT.yaml (vérité) vs CURRENT_STATE.yaml (dernier connu)
