# Knowledge Index — IT-AssistanTI_N3 (v2.0)

## Fichiers à uploader dans le GPT (Knowledge)

> ⚠️ Le prompt.md (30 430 octets) doit être en Knowledge — trop long pour le champ Instructions.

---

## 🔴 CRITIQUE

| Fichier | Chemin | Raison |
|---|---|---|
| `prompt.md` | `20_Agents/IT-AssistanTI_N3/prompt.md` | Toutes les commandes (/start, /close, /kb, /db, /runbook, /script), les runbooks intégrés, les scripts standards, les templates CW |

## 🟡 IMPORTANT — Runbooks opérationnels

| Fichier | Chemin IT-SHARED | Contenu |
|---|---|---|
| `RUNBOOK__Windows_Patching_CW_RMM_OneByOne.md` | `10_RUNBOOKS/MAINTENANCE/` | Patching Windows via CW RMM serveur par serveur |
| `RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md` | `10_RUNBOOKS/SUPPORT/` | Triage N1-N2-N3 — arbre de décision |
| `RUNBOOK__IT_CW_INTERVENTION_LIVE_CLOSE.md` | `10_RUNBOOKS/SUPPORT/` | Journal live + clôture CW |
| `RUNBOOK__DC_PrePost_Validation.md` | `10_RUNBOOKS/INFRA/` | Validation DC avant/après maintenance |
| `RUNBOOK__SQL_PrePost_Validation.md` | `10_RUNBOOKS/INFRA/` | Validation SQL avant/après maintenance |
| `RUNBOOK__M365_User_Management.md` | `10_RUNBOOKS/INFRA/` | Gestion utilisateurs M365 |
| `RUNBOOK__IT_NETWORK_DIAGNOSTIC_V1.md` | `10_RUNBOOKS/INFRA/` | Diagnostic réseau guidé |
| `RUNBOOK__IT_BACKUP_DR_TEST_V1.md` | `10_RUNBOOKS/INFRA/` | Test DR et validation backups |
| `RUNBOOK__IT_SECURITY_INCIDENT_RESPONSE.md` | `10_RUNBOOKS/SECURITY/` | Réponse incident sécurité |
| `RUNBOOK__Post_Shutdown_Electrical_Validation.md` | `10_RUNBOOKS/INFRA/` | Validation post-panne électrique |

## 🟡 IMPORTANT — Scripts PowerShell

| Fichier | Chemin IT-SHARED | Contenu |
|---|---|---|
| `POWERSHELL__Server_Management.md` | `30_SCRIPTS/` | Commandes PS gestion serveurs |
| `POWERSHELL__Event_Log_Analysis.md` | `30_SCRIPTS/` | Analyse Event Log Windows |
| `POWERSHELL__Template_Standard_v1.ps1` | `30_SCRIPTS/` | Template PS obligatoire |

## 🟢 OPTIONNEL

| Fichier | Chemin | Contenu |
|---|---|---|
| `RUNBOOK__M365_User_Onboarding.md` | `10_RUNBOOKS/INFRA/` | Onboarding M365 |
| `RUNBOOK__PendingReboot_OneByOne.md` | `10_RUNBOOKS/MAINTENANCE/` | Gestion reboots en attente |
| `RUNBOOK__Network_Setup.md` | `10_RUNBOOKS/INFRA/` | Configuration réseau |
| `RUNBOOK__NOC_Procedures.md` | `10_RUNBOOKS/NOC/` | Procédures NOC générales |
| `RUNBOOK__Alert_Response.md` | `10_RUNBOOKS/SECURITY/` | Réponse alertes |
| `NAMING_STANDARDS_v1.md` | `20_Agents/IT-MaintenanceMaster/02_TEMPLATES/06_NAMING_STANDARDS/` | Conventions nommage scripts/snapshots |
| `EXEMPLE_kb_brief_1683171.yaml` | `20_Agents/IT-AssistanTI_N3/04_EXEMPLES/` | Exemple concret output /kb |

## ❌ NE PAS UPLOADER

| Fichier | Raison |
|---|---|
| `agent.yaml` | Config machine |
| `contract.yaml` / `01_CONTRACT.yaml` | Schéma interne |
| `manifest.json` | Metadata machine |
| `00_INSTRUCTIONS.md` | Dans le champ Instructions GPT |
| `03_ORIGINAL_PROMPT.md` | Version obsolète |
| `README.md` et sous-README | Metadata vides |
| Sous-dossiers `00_REFERENCE_DATA`, `10_MEMORY`, `65_TEST` | Vides ou metadata |

> **Limite GPT Knowledge :** 20 fichiers max.
> Avec 🔴 + 🟡 : **14 fichiers** — dans les limites.

---
*Index v2.0 — 2026-03-20 — IT-AssistanTI_N3*
