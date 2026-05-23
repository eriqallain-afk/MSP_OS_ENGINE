# Knowledge Index — IT-UrgenceMaster (v1.1)

## Fichiers à uploader en Knowledge GPT (ordre de priorité)

| Priorité | Fichier | Source | Contenu |
|---|---|---|---|
| 🔴 Critique | `prompt.md` | Agent racine (553L) | Toutes les commandes, protocoles, notices Teams, GO/NO-GO, escalades, clôture CW |
| 🟠 Important | `TEMPLATE_DIAG_PostPanneHQ.md` | `knowledge/` | Protocole complet post-panne HQ — 11 sections |
| 🟠 Important | `TEMPLATE__FLAG_UP_AVERTISSEMENT.md` | `knowledge/` | Template Flag Up — CW + Teams + exemple réel |
| 🟠 Important | `BUNDLE_KP_UrgenceMaster_V1.md` | `knowledge/` | KnowledgePack — protocoles, GO/NO-GO, templates CW |
| 🟡 Optionnel | `RB-001_procedure-principale.md` | `02_RUNBOOKS/` | Procédures P1/P2 + script PRECHECK + SLA |
| 🟡 Optionnel | `CL-001_validation-principale.md` | `03_CHECKLISTS/` | Checklist complète A→H |
| 🟡 Optionnel | `EX-001_cas-nominal.md` | `04_EXEMPLES/` | 3 exemples réels : panne HQ GO, P1 NOC, Flag Up |
| 🟡 Optionnel | `TEMPLATE_BUNDLE_CW_CLOSE.md` | `IT-SHARED/` | Gabarits CW Discussion + Note Interne tous agents |
| 🟡 Optionnel | `KB-VEEAM-001_Probe-RMM-VMware.md` | `IT-SHARED/KB/` | KB Veeam — référence pour diagnostics backup |
| 🟡 Optionnel | `KB-WU-001_Windows-Update-Missing-DC.md` | `IT-SHARED/KB/` | KB Windows Update DC — référence |

## ❌ Ne pas uploader

| Fichier | Raison |
|---|---|
| `agent.yaml` | Config machine |
| `contract.yaml` | Schéma interne |
| `manifest.json` | Metadata machine |
| `00_INSTRUCTIONS.md` | Déjà dans le champ Instructions GPT |
| `01_CONTRACT.yaml` | Fichier legacy — remplacé par `contract.yaml` |
| `03_ORIGINAL_PROMPT.md` | Fichier legacy archivé |

## Web Search — activer pour UrgenceMaster

| Usage | Requête type |
|---|---|
| Portail Hydro-Québec | `hydroquebec.com/pannes` |
| Statut M365 | `admin.microsoft.com` → Service Health |
| Statut Azure | `status.azure.com` |

> **Limite GPT :** 20 fichiers max. Prioriser 🔴 → 🟠 → 🟡.
> Le `prompt.md` est le fichier le plus important — doit être en premier.

*Index v1.1 — 2026-03-24 — IT-UrgenceMaster*
