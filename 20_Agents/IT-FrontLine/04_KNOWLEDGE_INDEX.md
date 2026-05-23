# Knowledge Index — IT-AssistanTI_FrontLine (v1.1)

## Fichiers Knowledge GPT — ordre d'upload

| Priorité | Fichier | Source | Contenu |
|---|---|---|---|
| 🔴 Critique | `prompt.md` | Agent racine (471L) | Système complet : modes, menus, arbres de décision, scripts d'appel |
| 🔴 Critique | `BUNDLE_KP_AssistanTI-FrontLine_V1.md` | `IT-SHARED/60_BUNDLES/` | KnowledgePack helpdesk |
| 🟠 Important | `REFERENCE__SLA_FrontLine.md` | `knowledge/` | SLA, scope, escalades |
| 🟠 Important | `REFERENCE__Scripts_FrontLine.md` | `knowledge/` | Scripts PS AD/imprimante/Outlook/VPN/poste |
| 🟠 Important | `TEMPLATE__CW_NOTE_INTERNE_FrontLine.md` | `02_TEMPLATES/` | Note Interne CW |
| 🟠 Important | `TEMPLATE__CW_DISCUSSION_STAR_FrontLine.md` | `02_TEMPLATES/` | Discussion STAR CW |
| 🟠 Important | `TEMPLATE__CW_NOTE_TRIAGE.md` | `02_TEMPLATES/` | Triage avant transfert |
| 🟠 Important | `RB-001_procedure-principale.md` | `02_RUNBOOKS/` | Runbooks flux + arbres + escalade sécurité |
| 🟠 Important | `RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT/` | Triage N1/N2/N3 |
| 🟡 Optionnel | `REFERENCE__SLA_Matrix.md` | `IT-SHARED/50_REFERENCE/` | SLA globale MSP |
| 🟡 Optionnel | `EX-001_cas-nominal.md` | `04_EXEMPLES/` | Exemple complet |

## Fichiers 00_INDEX_PATCHES/ (à appliquer manuellement)

| Fichier PATCH | Cible |
|---|---|
| `PATCH__agents_yaml.md` | `00_INDEX/agents.yaml` |
| `PATCH__agents_index_yaml.md` | `00_INDEX/agents_index.yaml` |
| `PATCH__gpt_catalog_yaml.md` | `00_INDEX/gpt_catalog.yaml` |
| `PATCH__intents_yaml.md` | `00_INDEX/intents.yaml` |
| `PATCH__KNOWLEDGE_INDEX_yaml.md` | `00_INDEX/KNOWLEDGE_INDEX.yaml` |
| `PATCH__product_yaml.md` | `00_INDEX/product.yaml` |
| `PATCH__hub_routing_yaml.md` | `80_MACHINES/hub_routing.yaml` |
| `PATCH__playbooks_yaml.md` | `playbooks/playbooks.yaml` |

## Ne PAS uploader en Knowledge GPT
- `agent.yaml`, `contract.yaml`, `manifest.json` — config machine
- `00_INSTRUCTIONS.md` — dans le champ Instructions GPT
- Dossier `00_INDEX_PATCHES/` — patches de déploiement uniquement

*v1.1 — 2026-03-22 — IT-AssistanTI_FrontLine*
