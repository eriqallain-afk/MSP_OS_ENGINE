# TRIAGE INITIAL — IT MSP Intelligence Library

## Résumé exécutif

- Éléments inventoriés : **320**

- Archives ZIP analysées : **10**

- Groupes/doublons candidats détectés : **59 éléments marqués**


## Comptage par type

| Type | Nombre |
|---|---:|
| RUNBOOK | 88 |
| TEMPLATE | 63 |
| BUNDLE | 43 |
| SCRIPT_LIBRARY | 31 |
| REFERENCE | 28 |
| KNOWLEDGEPACK | 24 |
| CHECKLIST | 19 |
| INDEX_ROUTING | 12 |
| KB_EXAMPLE | 6 |
| OTHER | 3 |
| EXAMPLE | 2 |
| POLICY_GUARDRAIL | 1 |

## Comptage par famille

| Famille | Nombre |
|---|---:|
| UNCLASSIFIED | 69 |
| SUPPORT_TICKETOPS | 41 |
| CLOUD_M365OPS | 36 |
| MAINT_SERVEROPS | 34 |
| REFERENCE | 24 |
| SCRIPTS | 20 |
| NOCOPS | 18 |
| NETWORKOPS | 17 |
| SECOPS | 17 |
| BACKUPDROPS | 12 |
| VIRTUALIZATIONOPS | 9 |
| DIRECTORYOPS | 9 |
| OPROPS | 6 |
| CHECKLISTS | 5 |
| CORE | 2 |
| CORE_GUARDRAILS | 1 |

## Actions de tri prioritaires

| Action | Nombre |
|---|---:|
| MAP_TO_OUTPUT_TYPE | 63 |
| NORMALIZE_AS_MANIFEST | 43 |
| CREATE_RUNBOOK_CARD | 40 |
| ARCHIVE_OR_COMPARE | 33 |
| CLASSIFY_SCRIPT_RISK | 31 |
| DEDUP_REFERENCE_LIBRARY | 28 |
| MAP_TO_AGENT_KP | 24 |
| MAP_TO_RUNBOOK_PHASE | 19 |
| SELECT_CANONICAL | 16 |
| MERGE_TO_MASTER_INDEX | 12 |
| MAP_AS_TEST_OR_KB | 8 |
| REVIEW | 3 |

## Structure cible recommandée

```text
IT-SHARED/
├── 00_POLICIES/
├── 00_INDEX/
├── 10_CATALOG/
├── 20_RUNBOOKS/
├── 30_SCRIPTS/
├── 40_CHECKLISTS/
├── 50_REFERENCE/
├── 60_BUNDLES/
├── 70_KNOWLEDGE/
├── 80_EXAMPLES_TESTS/
├── 90_KB/
└── 99_ARCHIVE_LEGACY/
```

## Règles de normalisation

1. Un runbook canonique par capacité. Les variantes `(1)`, `(2)` doivent être comparées puis archivées.

2. Un bundle doit devenir un manifeste de références, pas une copie complète de runbooks.

3. Les scripts doivent être classés par risque : `SAFE_READONLY`, `LOW_IMPACT_FIX`, `CONTROLLED_CHANGE`, `HIGH_RISK_CHANGE`.

4. Les templates doivent être mappés à un type de sortie : CW Note interne, CW Discussion, Teams, Rapport, KB, Hudu, QBR.

5. Les Knowledge Packs doivent être mappés aux agents consommateurs, puis reliés à des bundles et non à des copies libres.

6. `GUARDRAILS__IT_AGENTS_MASTER` doit être promu comme policy obligatoire de tous les bundles.


## Prochaine phase recommandée

- Phase 1 : déduplication des runbooks et choix des sources canoniques.

- Phase 2 : conversion des bundles en manifestes.

- Phase 3 : classification des scripts par risque et mapping vers runbooks.

- Phase 4 : mapping templates/checklists/références vers sorties et phases d’intervention.

- Phase 5 : création des bundles commerciaux Starter / Pro / MSP Suite / Enterprise.
