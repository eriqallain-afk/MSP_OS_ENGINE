# GPT SETUP CARD — @IT-AssistanTI_N3
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 3.0.0 | **Mise à jour :** 2026-04-10

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-AssistanTI_N3 |
| **Description** | Technicien expert N3 MSP — incidents complexes et architecture : AD/DC, RDS, Exchange, VMware/Hyper-V, SQL Server, scripts PowerShell production-ready, RCA. Intervient sur ce que N2 ne peut pas résoudre. Livrables CW complets. |

### Rôle (source : Définition des Rôles)
Niveau 3 — ingénierie et résolution approfondie. Experts et ingénieurs spécialisés. Couverture : incidents critiques infrastructure, architecture informatique, correctifs & scripts sur mesure, interactions éditeurs (support tiers), analyse performance, capacity planning, projets d'évolution, définition des standards. En contexte MSP + urgence (IT-UrgenceMaster) : gestion P1/P2, panne HQ, GO-NO-GO. Post-check AD obligatoire après tout reboot serveur.

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions du GPT Editor.

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `/start [#billet] — Incident N3 critique`
2. `/runbook dc-prepost — Problème DC/AD`
3. `/runbook rds — Session RDS bloquée`
4. `/runbook hyperv — VM non démarrée`
5. `/script collecte logs événements critiques`
6. `/close — Clôture avec CW complet`

---

## 4. KNOWLEDGE — Fichiers à uploader dans GPT Editor

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `PRODUCTS/IT/20_Agents/IT-AssistanTI_N3/prompt.md` | Système complet — comportement, commandes, guardrails |

### 🟠 IMPORTANT — Bundles Knowledge (IT-SHARED/60_BUNDLES)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_AssistanTI-N3_V1.md` | KnowledgePack N3 — protocoles, résolutions avancées, templates |
| `BUNDLE_RUNBOOK_INFRA_AD-Operations_V1.md` | Bundle AD/DC — opérations, réplication, dépannage |
| `BUNDLE_RUNBOOK_INFRA_RDS-Operations_V1.md` | Bundle RDS — sessions, profils, services |
| `BUNDLE_RUNBOOK_INFRA_Hyperviseurs_V1.md` | Bundle Hyper-V / VMware — VMs, snapshots, migration |
| `BUNDLE_RUNBOOK_INFRA_M365_V1.md` | Bundle M365 — Exchange, Intune, Teams avancé |
| `BUNDLE_RUNBOOK_SUPPORT_Triage-KB_V1.md` | Bundle triage N3 — RCA, escalade, KB |

### 🔵 OPTIONNEL
| Fichier | Contenu |
|---|---|
| `BUNDLE_RUNBOOK_INFRA_Firewall-VPN_V1.md` | Firewalls — Fortinet, SonicWall, WatchGuard, Meraki |
| `BUNDLE_RUNBOOK_BACKUP_Veeam-Operations_V1.md` | Veeam — jobs, restauration VM |

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
| `/runbook dc-prepost` | `IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__DC_PrePost_Validation.md` |
| `/runbook sql-prepost` | `IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__SQL_PrePost_Validation.md` |
| `/runbook ad-dc` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__AD_DC_Operations_V1.md` |
| `/runbook ad-users` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__AD_User_Management_V1.md` |
| `/runbook entra-id` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__EntraID_Operations_V1.md` |
| `/runbook rds` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__RDS_Operations_V1.md` |
| `/runbook hyperv` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__HyperV_Operations_V1.md` |
| `/runbook vmware` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__VMware_vSphere_Operations_V1.md` |
| `/runbook xcpng` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__Vates_XCPng_Operations_V1.md` |
| `/runbook m365-exchange` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__M365_Exchange_Online_V1.md` |
| `/runbook m365-teams` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__M365_Teams_SharePoint_OneDrive_V1.md` |
| `/runbook triage` | `IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md` |
| `/runbook backup-dr-test` | `IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__IT_BACKUP_DR_TEST_V1.md` |
| `/script ps-snippets` | `IT-SHARED/30_SCRIPTS/LIBRARY__PowerShell_Snippets.md` |
| `/checklist precheck` | `IT-SHARED/40_CHECKLISTS/CHECKLIST__PRECHECK_GENERIC.md` |
| `/checklist postcheck` | `IT-SHARED/40_CHECKLISTS/CHECKLIST__POSTCHECK_GENERIC.md` |

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | **Oui** | CVE, KB Microsoft, documentation constructeurs, support tiers |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/start #77010 — DC01 ne répond plus` | Triage P1, plan de diagnostic AD structuré, precheck avant action |
| `/runbook dc-prepost` | Charge RUNBOOK__DC_PrePost_Validation.md via GitHub — contenu réel |
| `/runbook hyperv` | Charge INFRA__RUNBOOK__HyperV_Operations_V1.md |
| `/script analyse réplication AD` | PS production-ready, `param()` ligne 1, `[AllowEmptyString()]` si string |
| Problème architectural (redesign réseau) | Traité en mode ingénierie — pas d'escalade, RCA complet |
| `/close` | Menu ⛔ STOP affiché — ATTENDRE le choix |
| MDP dans réponse | Refus — redirection Passportal |
| Reboot de 2 DCs simultanément | Refus — 1 DC à la fois, post-check AD obligatoire |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `20_Agents/IT-AssistanTI_N3/prompt.md` |
| **Instructions** | `20_Agents/IT-AssistanTI_N3/00_INSTRUCTIONS.md` |
| **Bundle KP** | `IT-SHARED/60_BUNDLES/BUNDLE_KP_AssistanTI-N3_V1.md` |
| **Version** | 3.0.0 |

*GPT Setup Card v3.0 — IT-AssistanTI_N3 — IT MSP Intelligence Platform — 2026-04-10*
