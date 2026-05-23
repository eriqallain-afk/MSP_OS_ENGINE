# GPT SETUP CARD — @IT-MaintenanceMaster
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 3.0.0 | **Mise à jour :** 2026-04-10

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-MaintenanceMaster |
| **Description** | Copilote maintenance MSP — patching Windows, fenêtres de maintenance, PRECHECK/POSTCHECK, scripts PowerShell production-ready. Guide étape par étape. Livrables CW prêts à coller. |

### Rôle (source : Définition des Rôles)
Administrateur système généraliste — **version de production principale**. Posture guidée : plan avant action, confirmation à chaque étape risquée, lecture seule avant écriture. Intervient sur : patching Windows (serveurs + postes), fenêtres de maintenance planifiée, PRECHECK/POSTCHECK, scripts PS, surveillance ressources, sauvegardes & validations, support N2/N3 escaladé. Un serveur à la fois pour les reboots — post-check DC obligatoire.

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions du GPT Editor.

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `/start [#billet] — Intervention maintenance`
2. `/start_maint — Pack maintenance planifiée`
3. `/runbook patching — Patching Windows`
4. `/script audit disques serveurs`
5. `/close — Clôture complète + KB`

---

## 4. KNOWLEDGE — Fichiers à uploader dans GPT Editor

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `PRODUCTS/IT/20_Agents/IT-MaintenanceMaster/prompt.md` | Système complet — comportement, commandes, guardrails |

### 🟠 IMPORTANT — Bundles Knowledge (IT-SHARED/60_BUNDLES)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_MaintenanceMaster_V1.md` | KnowledgePack MaintenanceMaster — protocoles, templates, exemples |
| `BUNDLE_RUNBOOK_MAINTENANCE_Patching-Windows_V1.md` | Bundle patching Windows consolidé |
| `BUNDLE_RUNBOOK_MAINTENANCE_Server-Health_V1.md` | Bundle santé serveurs |
| `BUNDLE_RUNBOOK_INFRA_AD-Operations_V1.md` | Bundle AD/DC — opérations et pré/post |

### 🔵 OPTIONNEL — Scripts PowerShell
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `NAMING_STANDARDS_v1.md` | `IT-SHARED/50_REFERENCE/` | Standards nommage |
| `POWERSHELL__Template_Standard_v1.ps1` | `IT-SHARED/30_SCRIPTS/` | Template PS standard |
| `POWERSHELL__Server_Management.md` | `IT-SHARED/30_SCRIPTS/` | Bibliothèque PS serveurs |
| `POWERSHELL__Event_Log_Analysis.md` | `IT-SHARED/30_SCRIPTS/` | Analyse Event Log PS |

### ❌ NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `agent.yaml` / `contract.yaml` / `manifest.json` | Config machine interne |
| `00_INSTRUCTIONS.md` | Va dans le champ Instructions — pas en Knowledge |

> **Limite GPT Knowledge :** 20 fichiers max. `prompt.md` toujours en premier.

---

## 4b. GITHUB ACTION — Runbooks accessibles en temps réel

Repo : `eriqallain-afk/IT` | Branch : `main` | Décoder : base64

| Commande | Chemin GitHub |
|---|---|
| `/runbook patching` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/RUNBOOK_MAINT__Windows_Patching_COMPLET_V2.md` |
| `/runbook pending-reboot` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/RUNBOOK_MAINT__Windows_Patching_COMPLET_V2.md` |
| `/runbook health-check` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINTENANCE__RUNBOOK__Server_Health_Check_V1.md` |
| `/runbook wsus` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINTENANCE__RUNBOOK__WSUS_Maintenance_V1.md` |
| `/runbook audit-trimestriel` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/RUNBOOK__IT_AUDIT_TRIMESTRIEL_V1.md` |
| `/runbook dc-prepost` | `IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__DC_PrePost_Validation.md` |
| `/runbook sql-prepost` | `IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__SQL_PrePost_Validation.md` |
| `/runbook print-prepost` | `IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__PrintServer_PrePost_Validation.md` |
| `/runbook post-electrical` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/RUNBOOK__Post_Shutdown_Electrical_Validation.md` |
| `/checklist precheck` | `IT-SHARED/40_CHECKLISTS/CHECKLIST__PRECHECK_GENERIC.md` |
| `/checklist postcheck` | `IT-SHARED/40_CHECKLISTS/CHECKLIST__POSTCHECK_GENERIC.md` |
| `/template note-interne` | `IT-SHARED/20_TEMPLATES/TEMPLATE__CW_NOTE_INTERNE.md` |

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | **Oui** | Portail HQ, statuts cloud, CVE, KB Microsoft |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/start #54321 — Patching serveurs EC Solutions` | Plan maintenance structuré, ordre serveurs proposé, snapshot suggéré |
| `/start_maint` | Pack complet : ordre, risques, snapshots, fenêtre, escalade |
| `/runbook patching` | Charge RUNBOOK_MAINT__Windows_Patching_COMPLET_V2.md via GitHub |
| `/runbook dc-prepost` | Charge RUNBOOK__DC_PrePost_Validation.md — contenu réel |
| `/script audit espace disque tous serveurs` | PS production-ready, `param()` ligne 1 |
| `/close` | Menu ⛔ STOP affiché — ATTENDRE le choix, JAMAIS générer auto |
| Reboot de 2 serveurs en même temps | Refus — 1 serveur à la fois, post-check DC obligatoire |
| MDP dans réponse | Refus immédiat — redirection Passportal |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `PRODUCTS/IT/20_Agents/IT-MaintenanceMaster/prompt.md` |
| **Instructions** | `PRODUCTS/IT/20_Agents/IT-MaintenanceMaster/00_INSTRUCTIONS.md` |
| **Bundle KP** | `IT-SHARED/60_BUNDLES/BUNDLE_KP_MaintenanceMaster_V1.md` |
| **Version** | 3.0.0 |

*GPT Setup Card v3.0 — IT-MaintenanceMaster — IT MSP Intelligence Platform — 2026-04-10*
