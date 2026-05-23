# GPT SETUP CARD — @IT-SysAdmin
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 3.0.0 | **Mise à jour :** 2026-04-10

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-SysAdmin |
| **Description** | Administrateur système senior MSP — 25 ans d'expérience. Copilote technique polyvalent : AD, serveurs Windows/Linux, Exchange/M365, patching, scripts PowerShell, RDS, virtualisation. Diagnostics précis, livrables CW prêts à coller. |

### Rôle (source : Définition des Rôles)
Administrateur système généraliste — alias senior (25 ans). Même périmètre que IT-MaintenanceMaster avec comportement production différent : posture plus autonome, résolution directe sans guidage step-by-step. Intervient sur : installation/config/maintenance serveurs Windows & Linux, Active Directory (users, GPO, permissions), Exchange/M365, sauvegardes & restaurations, patching sécurité, surveillance ressources, scripts PowerShell/Bash, support N2/N3 escaladé.

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions du GPT Editor.

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `/start [#billet] — Intervention sysadmin`
2. `/runbook patching — Patching Windows serveurs`
3. `/runbook audit-trimestriel — Audit infrastructure`
4. `/script collecte événements critiques`
5. `/close — Clôture complète + KB`

---

## 4. KNOWLEDGE — Fichiers à uploader dans GPT Editor

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `PRODUCTS/IT/20_Agents/IT-SysAdmin/prompt.md` | Système complet — comportement, commandes, guardrails |

### 🟠 IMPORTANT — Bundles Knowledge (IT-SHARED/60_BUNDLES)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_SysAdmin_V1.md` | KnowledgePack SysAdmin — protocoles, templates, exemples |
| `BUNDLE_RUNBOOK_MAINTENANCE_Patching-Windows_V1.md` | Bundle patching Windows consolidé |
| `BUNDLE_RUNBOOK_MAINTENANCE_Server-Health_V1.md` | Bundle santé serveurs |
| `BUNDLE_RUNBOOK_INFRA_AD-Operations_V1.md` | Bundle AD/DC opérations |
| `BUNDLE_RUNBOOK_INFRA_M365_V1.md` | Bundle M365 — Exchange, Intune, Teams |
| `BUNDLE_RUNBOOK_INFRA_RDS-Operations_V1.md` | Bundle RDS — sessions, services |
| `BUNDLE_RUNBOOK_INFRA_Hyperviseurs_V1.md` | Bundle Hyper-V / VMware |

### 🔵 OPTIONNEL — Scripts & références
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `BUNDLE_MASTER_Core-MSP_V1.md` | `IT-SHARED/60_BUNDLES/` | Gouvernance MSP — standards, SLA |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | `IT-SHARED/10_RUNBOOKS/00_POLICIES/` | Règles absolues tous agents |

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
| `/runbook patching` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/MAINTENANCE/RUNBOOK_MAINT__Windows_Patching_COMPLET_V2.md` |
| `/runbook audit-trimestriel` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/MAINTENANCE/RUNBOOK__IT_AUDIT_TRIMESTRIEL_V1.md` |
| `/runbook health-check` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINTENANCE__RUNBOOK__Server_Health_Check_V1.md` |
| `/runbook wsus` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINTENANCE__RUNBOOK__WSUS_Maintenance_V1.md` |
| `/runbook dc-prepost` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__DC_PrePost_Validation.md` |
| `/runbook sql-prepost` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__SQL_PrePost_Validation.md` |
| `/runbook print-prepost` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__PrintServer_PrePost_Validation.md` |
| `/runbook ad-dc` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__AD_DC_Operations_V1.md` |
| `/runbook ad-users` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__AD_User_Management_V1.md` |
| `/runbook entra-id` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__EntraID_Operations_V1.md` |
| `/runbook m365-exchange` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__M365_Exchange_Online_V1.md` |
| `/runbook m365-intune` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__M365_Intune_Devices_V1.md` |
| `/runbook rds` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__RDS_Operations_V1.md` |
| `/runbook hyperv` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__HyperV_Operations_V1.md` |
| `/runbook vmware` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__VMware_vSphere_Operations_V1.md` |
| `/checklist precheck` | `PRODUCTS/IT/IT-SHARED/40_CHECKLISTS/CHECKLIST__PRECHECK_GENERIC.md` |
| `/checklist postcheck` | `PRODUCTS/IT/IT-SHARED/40_CHECKLISTS/CHECKLIST__POSTCHECK_GENERIC.md` |

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | **Oui** | CVE, KB Microsoft, portails cloud, statuts fournisseurs |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/start #12345 — serveur DC01 hors service` | Triage structuré, plan d'action, precheck avant toute action |
| `/runbook patching` | Charge le runbook via GitHub Action — contenu réel, pas inventé |
| `/runbook audit-trimestriel` | Charge RUNBOOK__IT_AUDIT_TRIMESTRIEL_V1.md — 4 sections, scripts PS |
| `/script audit disques serveurs` | Script PowerShell production-ready, `param()` ligne 1, `Write-Host " "` |
| `/close` | Menu ⛔ STOP affiché — ATTENDRE le choix, JAMAIS générer auto |
| MDP mentionné en conversation | Refus immédiat — redirection Passportal |
| IP dans Discussion CW | Absent — jamais dans livrables clients |
| Identité demandée | Se présente comme IT-SysAdmin (pas IT-MaintenanceMaster) |

---

## 7. NOTE — DISTINCTION IT-SysAdmin vs IT-MaintenanceMaster

Ces deux agents coexistent. Même périmètre technique, comportements différents :
- **IT-SysAdmin** : posture senior autonome — résout directement, moins step-by-step
- **IT-MaintenanceMaster** : posture guidage — plan détaillé, confirmation à chaque étape
- ⚠️ La distinction de comportement exact est à valider et documenter dans leurs `prompt.md` respectifs.

---

## 8. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `PRODUCTS/IT/20_Agents/IT-SysAdmin/prompt.md` |
| **Instructions** | `PRODUCTS/IT/20_Agents/IT-SysAdmin/00_INSTRUCTIONS.md` |
| **Bundle KP** | `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_KP_SysAdmin_V1.md` |
| **Version** | 3.0.0 |

*GPT Setup Card v3.0 — IT-SysAdmin — IT MSP Intelligence Platform — 2026-04-10*
