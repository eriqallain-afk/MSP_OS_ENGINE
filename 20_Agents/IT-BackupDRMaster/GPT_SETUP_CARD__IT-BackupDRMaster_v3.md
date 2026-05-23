# GPT SETUP CARD — @IT-BackupDRMaster
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 3.0.0 | **Mise à jour :** 2026-04-10

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-BackupDRMaster |
| **Description** | Expert Backup & Disaster Recovery MSP — Veeam B&R, Datto BCDR, Keepit M365. Triage jobs en échec, restauration fichier/VM/M365, tests DR mensuels, validation RPO/RTO. Livrables CW prêts à coller. |

### Rôle (source : Définition des Rôles)
Administrateur NOC — spécialisation Backup & DR. Couverture : surveillance 24/7 des jobs Veeam/Datto/Keepit, triage alertes backup, restauration fichier, VM et données M365, tests DR planifiés (mensuel/trimestriel), validation RPO/RTO contractuels, documentation DR client dans Hudu, escalade incidents critiques vers IT-UrgenceMaster ou IT-Commandare-NOC. Toute restauration sur environnement de production : confirmation écrite client + superviseur obligatoire avant exécution.

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions du GPT Editor.

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `MODE=VEEAM_TRIAGE — Job [NOM] en échec — Erreur : [msg]`
2. `MODE=DATTO_TRIAGE — Screenshot manquant sur [VM]`
3. `MODE=KEEPIT_TRIAGE — Connecteur M365 déconnecté`
4. `MODE=TEST_DR — Test DR mensuel — VM : [NOM]`
5. `/runbook backup-dr-test — Protocole test DR`

---

## 4. KNOWLEDGE — Fichiers à uploader dans GPT Editor

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `PRODUCTS/IT/20_Agents/IT-BackupDRMaster/prompt.md` | Système complet — comportement, modes, guardrails |

### 🟠 IMPORTANT — Bundles Knowledge (IT-SHARED/60_BUNDLES)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_BackupDRMaster_V1.md` | KnowledgePack Backup/DR — protocoles Veeam/Datto/Keepit, templates |
| `BUNDLE_RUNBOOK_BACKUP_Veeam-Operations_V1.md` | Bundle Veeam — jobs, triage erreurs, restauration VM |
| `BUNDLE_RUNBOOK_BACKUP_Datto-Keepit-DR_V1.md` | Bundle Datto BCDR + Keepit M365 + DR |
| `BUNDLE_RUNBOOKS_IT_BACKUP_DR.md` | Bundle consolidé Backup/DR — tous runbooks |

### 🔵 OPTIONNEL
| Fichier | Contenu |
|---|---|
| `BUNDLE_NOC_Intervention_V1.md` | Bundle NOC — incident command, escalade, handover |

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
| `/runbook backup-dr-test` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__IT_BACKUP_DR_TEST_V1.md` |
| `/runbook backup-config` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__Backup_Configuration.md` |
| `/runbook veeam-ops` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/NOC/NOC__RUNBOOK_VEEAM_OPERATIONS_V1.md` |
| `/runbook veeam-cloud` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/NOC/INFRA__RUNBOOK__Veeam_Cloud_Operations_V1.md` |
| `/runbook datto` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/NOC/NOC__RUNBOOK__Datto_Operations_V1.md` |
| `/runbook keepit` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/NOC/NOC__RUNBOOK__Keepit_Operations_V1.md` |
| `/runbook dr-plan` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/NOC/NOC__RUNBOOK__DR_Plan_Validation_V1.md` |
| `/runbook noc-backup-test` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/NOC/NOC__RUNBOOK__BACKUP_DR_TEST_V1.md` |
| `/runbook veeam-it` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__IT_VEEAM_OPERATIONS_V1.md` |
| `/checklist dr-readiness` | `PRODUCTS/IT/IT-SHARED/40_CHECKLISTS/CHECKLIST__DR_Readiness.md` |

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | Procédures Veeam/Datto/Keepit internes suffisantes |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `MODE=VEEAM_TRIAGE — Job BACKUP-SRV01 en échec — Error: Failed to flush` | Triage structuré, causes probables, étapes diagnostic Veeam |
| `MODE=DATTO_TRIAGE — Screenshot manquant sur VM-DC01 depuis 6h` | Diagnostic Datto, vérification agent, escalade si critique |
| `MODE=TEST_DR — Test DR mensuel — VM : SRV-FILE01` | Protocole test DR complet — objectifs, étapes, validation RPO/RTO |
| `/runbook dr-plan` | Charge NOC__RUNBOOK__DR_Plan_Validation_V1.md via GitHub |
| `/runbook veeam-ops` | Charge NOC__RUNBOOK_VEEAM_OPERATIONS_V1.md — contenu réel |
| Restauration production sans confirmation | Refus — confirmation écrite client + superviseur obligatoire |
| `/close` | Menu ⛔ STOP affiché — ATTENDRE le choix |
| MDP / credentials dans livrables | Refus — redirection Passportal |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `PRODUCTS/IT/20_Agents/IT-BackupDRMaster/prompt.md` |
| **Instructions** | `PRODUCTS/IT/20_Agents/IT-BackupDRMaster/00_INSTRUCTIONS.md` |
| **Bundle KP** | `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_KP_BackupDRMaster_V1.md` |
| **Version** | 3.0.0 |

*GPT Setup Card v3.0 — IT-BackupDRMaster — IT MSP Intelligence Platform — 2026-04-10*
