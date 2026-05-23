# Knowledge Index — IT-MaintenanceMaster (v3.0)

## Fichier principal à uploader en Knowledge GPT
**`prompt.md` EN PREMIER** (469L) — contient toutes les commandes, runbooks, standards PS

| Fichier | Source | Priorité |
|---|---|---|
| `prompt.md` | Agent racine | 🔴 Critique |
| `BUNDLE_KP_MaintenanceMaster_V1.md` | `IT-SHARED/60_BUNDLES/` | 🔴 Critique |

## Fichiers 05_KNOWLEDGE/ (uploader en Knowledge)
| Fichier | Contenu |
|---|---|
| `RUNBOOK__IT_INTERVENTION_LIVE.md` | Guide intervention live complet |
| `RUNBOOK__IT_CW_INTERVENTION_LIVE_CLOSE.md` | Clôture CW — livrables détaillés |
| `RUNBOOK__Windows_Patching.md` | Procédure patching Windows complète |
| `RUNBOOK__Windows_Patching_CW_RMM_OneByOne.md` | Patching via CW RMM serveur par serveur |
| `RUNBOOK__Post_Shutdown_Electrical_Validation.md` | Validation post-panne électrique |
| `POWERSHELL__Server_Management.md` | Bibliothèque commandes PS serveurs |
| `POWERSHELL__Event_Log_Analysis.md` | Analyse Event Log Windows |
| `IT-MaintenanceMaster__KnowledgePack_Supplement_v1.md` | Supplément Knowledge Pack |
| `exemple_patching_serveurs.md` | Exemple réel session patching |

## Fichiers 02_TEMPLATES/ (uploader en Knowledge)
| Fichier | Contenu |
|---|---|
| `CONTEXTS/SHARED/TEMPLATE__CW_NOTE_INTERNE.md` | Template Note Interne CW |
| `CONTEXTS/SHARED/TEMPLATE__CW_DISCUSSION.md` | Template Discussion STAR |
| `CONTEXTS/SHARED/TEMPLATE__EMAIL_CLIENT.md` | Template email client |
| `06_NAMING_STANDARDS/NAMING_STANDARDS_v1.md` | Conventions nommage |
| `04_POWERSHELL_LIBRARY/POWERSHELL__Template_Standard_v1.ps1` | Template PS obligatoire |

## Runbooks IT-SHARED (via BUNDLE_KP)
| Runbook | Chemin IT-SHARED |
|---|---|
| DC Pre/Post Validation | `10_RUNBOOKS/INFRA/RUNBOOK__DC_PrePost_Validation.md` |
| SQL Pre/Post Validation | `10_RUNBOOKS/INFRA/RUNBOOK__SQL_PrePost_Validation.md` |
| Backup DR Test | `10_RUNBOOKS/INFRA/RUNBOOK__IT_BACKUP_DR_TEST_V1.md` |
| AD Operations | `10_RUNBOOKS/INFRA/RUNBOOK_INFRA_AD-Operations_V1.md` |
| Incident Command | `10_RUNBOOKS/SUPPORT/RUNBOOK__IT_INCIDENT_COMMAND_V1.md` |

## Ne PAS uploader
- `agent.yaml`, `contract.yaml`, `manifest.json` — config machine
- `03_PROMPT_ARCHIVE.md` — version obsolète
- Sous-dossiers README vides

> **Limite GPT Knowledge :** 20 fichiers max — prioriser prompt.md + runbooks + templates CW

*Index v3.0 — 2026-03-22 — IT-MaintenanceMaster*
