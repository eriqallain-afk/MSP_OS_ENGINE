# Knowledge Index — IT-NOCDispatcher (v2.0)

## Fichier principal à uploader en Knowledge GPT
| Fichier | Source | Contenu |
|---|---|---|
| `BUNDLE_KP_NOCDispatcher_V1.md` | `IT-SHARED/60_BUNDLES/` | KnowledgePack complet — SLA, routing, runbooks NOC, shift handover |

> Le `prompt.md` (97L) va dans le champ **Instructions** du GPT Editor.

## Fichiers locaux knowledge/
| Fichier | Contenu |
|---|---|
| `knowledge/REFERENCE__SLA_Matrix.md` | Matrice SLA MSP — P1 à P4, délais, escalades |
| `knowledge/RUNBOOK__NOC_Procedures.md` | Procédures NOC — triage, corrélation, dispatch |
| `knowledge/CHECKLIST__Shift_Handover.md` | Checklist passation de quart NOC |

## Références IT-SHARED (via BUNDLE_KP)
| Référence | Chemin IT-SHARED |
|---|---|
| SLA Matrix | `50_REFERENCE/REFERENCE_MASTER_SLA-Matrix_V1.md` |
| Routing Rules | `50_REFERENCE/REFERENCE_MASTER_Routing-Rules_V1.md` |
| Severity Matrix | `50_REFERENCE/REFERENCE_MASTER_Severity-Matrix_V1.md` |
| Runbook Triage N1/N2/N3 | `10_RUNBOOKS/SUPPORT/RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md` |
| Runbook CW Dispatch | `10_RUNBOOKS/SUPPORT/RUNBOOK__IT_MSP_CONNECTWISE_DISPATCH_V1.md` |
| Checklist Kickoff Ticket | `40_CHECKLISTS/CHECKLIST_CW_Kickoff-Ticket_V1.md` |
| Checklist Shift Handover | `40_CHECKLISTS/CHECKLIST_NOC_Shift-Handover_V1.md` |
| Template Escalade | `20_TEMPLATES/TEMPLATE_SUPPORT_Escalade-et-Service-Restaure_V1.md` |

## Ne PAS uploader
- `agent.yaml`, `contract.yaml`, `manifest.json` — config machine
- Sous-dossiers README — metadata vides

*Index v2.0 — 2026-03-22 — IT-NOCDispatcher*
