# AUDIT — Agents 20_Agents/
**Date :** 2026-05-16
**Branche :** claude/add-ticketops-ai-agent-gmUm4
**Agents audités :** 27

---

## Résumé exécutif

| Agent | Instructions OK | Doublon prompt.md | > 8000 chars | agent.yaml sync | Nettoyage requis |
|---|---|---|---|---|---|
| IT-AssetMaster | ✅ 6135 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Desc OK / Sans date | ⚠️ Dupe instructions + v1 card |
| IT-Assistant-N2 | ✅ 5128 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ 2 SETUP_CARDs |
| IT-Assistant-N3 | ✅ 6740 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ 2 SETUP_CARDs + règle "1 serveur" |
| IT-BackupDRMaster | ✅ 6384 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + 2 SETUP_CARDs |
| IT-ClientDocMaster | ✅ 5947 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ 2 SETUP_CARDs + KP local = IT-SHARED |
| IT-CloudMaster | ✅ 6802 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + prompt_V3 |
| IT-Commandare-Infra | ✅ 6226 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + règle "1 serveur" |
| IT-Commandare-NOC | ✅ 6129 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + prompt_V3 |
| IT-Commandare-OPR | ✅ 6055 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions |
| IT-Commandare-TECH | ✅ 5988 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions |
| IT-FrontLine | ✅ 5824 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ 2 SETUP_CARDs |
| IT-KnowledgeKeeper | ✅ 5676 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + V3prompt |
| IT-MaintenanceMaster | ✅ 6589 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Desc = SysAdmin / Sans date | ⚠️ Règle "1 serveur" (x2) + fichiers locaux |
| IT-MonitoringMaster | ✅ 5963 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + _prompt.md |
| IT-NOCDispatcher | ✅ 6001 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + _prompt.md |
| IT-NetworkMaster | ✅ 6339 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + _prompt.md |
| IT-OPS-DossierIA | ✅ 2077 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ 00_instruction.md (lowercase) |
| IT-OPS-PlaybookRunner | ✅ 2188 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ 00_instruction.md (lowercase) |
| IT-OPS-RouterIA | ✅ 2566 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ 00_instruction.md (lowercase) |
| IT-ReportMaster | ✅ 5874 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ✅ Minimal |
| IT-ScriptMaster | ✅ 6108 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + _prompt.md + dossiers dupliqués |
| IT-SecurityMaster | ✅ 6502 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + _prompt.md |
| IT-SysAdmin | ✅ 7303 c | ⚠️ Contenu différent | ❌ Non | ❌ Desc = MaintenanceMaster | ⚠️ Règle "1 serveur" + fichiers locaux IT-SHARED |
| IT-TicketOpr | ✅ 7034 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ 00_INDEX dupliqué + 99_TEST |
| IT-TicketScribe | ✅ 5869 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ✅ Minimal |
| IT-UrgenceMaster | ✅ 5816 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + règle "1 serveur" |
| IT-VoIPMaster | ✅ 5735 c | ⚠️ Contenu différent | ❌ Non | ⚠️ Sans date | ⚠️ Dupe instructions + _prompt.md |

**Légende :** ✅ OK | ⚠️ À surveiller/nettoyer | ❌ Problème critique

**Note globale :** Aucun agent ne dépasse la limite de 8 000 caractères pour `00_INSTRUCTIONS.md`. Tous les `prompt.md` ont un contenu différent de `00_INSTRUCTIONS.md` (ils contiennent le prompt GPT complet). Aucun `agent.yaml` ne contient un champ `date` — problème systémique.

---

## Détail par agent

---

### IT-AssetMaster
**00_INSTRUCTIONS.md :** 6 135 chars ✅ OK
**prompt.md :** Présent — contenu unique (14 346 chars — prompt GPT complet, différent)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-AssetMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 2 versions — `GPT_SETUP_CARD__IT-AssetMaster.md` (v1) + `GPT_SETUP_CARD__IT-AssetMaster_v3.md` (v3) → garder `GPT_SETUP_CARD__IT-AssetMaster_v3.md`
**05_KNOWLEDGE :** Uniquement `README.md` (259 chars — stub)
**Fichiers locaux à archiver :** `IT-AssetMaster_00_INSTRUCTIONS.md`, `GPT_SETUP_CARD__IT-AssetMaster.md` (v1)
**Actions requises :**
- [ ] Archiver `IT-AssetMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `GPT_SETUP_CARD__IT-AssetMaster.md` (v1 obsolète, garder _v3)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-Assistant-N2
**00_INSTRUCTIONS.md :** 5 128 chars ✅ OK
**prompt.md :** Présent — contenu unique (33 900 chars — prompt GPT complet)
**Doublons instructions :** Aucun
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 2 versions — `GPT_SETUP_CARD__IT-AssistanTI_N2.md` (v1) + `GPT_SETUP_CARD__IT-AssistanTI_N2_v3.md` (v3) → garder `_v3.md`
**05_KNOWLEDGE :** Uniquement `README.md` (263 chars — stub)
**Fichiers locaux à archiver :** `GPT_SETUP_CARD__IT-AssistanTI_N2.md` (v1), `Config_GPT_Editor_TEMPLATE.txt`
**Actions requises :**
- [ ] Archiver `GPT_SETUP_CARD__IT-AssistanTI_N2.md` (v1 obsolète)
- [ ] Évaluer `Config_GPT_Editor_TEMPLATE.txt` (fichier de configuration non standard)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-Assistant-N3
**00_INSTRUCTIONS.md :** 6 740 chars ✅ OK
**prompt.md :** Présent — contenu unique (46 582 chars — prompt GPT complet)
**Doublons instructions :** Aucun
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 2 versions — `GPT_SETUP_CARD__IT-AssistanTI_N3.md` (v1) + `GPT_SETUP_CARD__IT-AssistanTI_N3_v3.md` (v3) → garder `_v3.md`
**05_KNOWLEDGE :** Uniquement `README.md`
**Fichiers locaux à archiver :** `GPT_SETUP_CARD__IT-AssistanTI_N3.md` (v1), `03_ORIGINAL_PROMPT.md`, `03_PROMPT_ARCHIVE.md`
**Actions requises :**
- [ ] ⚠️ Contient "1 serveur à la fois" dans `00_INSTRUCTIONS.md` — règle de patching dépassée à mettre à jour
- [ ] Archiver `GPT_SETUP_CARD__IT-AssistanTI_N3.md` (v1 obsolète)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-BackupDRMaster
**00_INSTRUCTIONS.md :** 6 384 chars ✅ OK
**prompt.md :** Présent — contenu unique (12 347 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-BackupDRMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 2 versions — `GPT_SETUP_CARD__IT-BackupDRMaster.md` (v1) + `GPT_SETUP_CARD__IT-BackupDRMaster_v3.md` (v3) → garder `_v3.md`
**05_KNOWLEDGE :** Uniquement `README.md` (265 chars — stub)
**legacy `knowledge/` :** `CHECKLIST__DR_Readiness.md` (équivalent archivé dans IT-SHARED/40_CHECKLISTS/99_ARCHIVE), `RUNBOOK__Backup_Configuration.md` (non trouvé dans IT-SHARED)
**Fichiers locaux à archiver :** `IT-BackupDRMaster_00_INSTRUCTIONS.md`, `GPT_SETUP_CARD__IT-BackupDRMaster.md` (v1)
**Actions requises :**
- [ ] Archiver `IT-BackupDRMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `GPT_SETUP_CARD__IT-BackupDRMaster.md` (v1 obsolète)
- [ ] Évaluer `knowledge/CHECKLIST__DR_Readiness.md` — version archivée dans IT-SHARED, envisager suppression locale
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-ClientDocMaster
**00_INSTRUCTIONS.md :** 5 947 chars ✅ OK
**prompt.md :** Présent — contenu unique (38 970 chars)
**Doublons instructions :** Aucun
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 2 versions — `GPT_SETUP_CARD__IT-ClientDocMaster.md` (v1) + `GPT_SETUP_CARD__IT-ClientDocMaster_v3.md` (v3) → garder `_v3.md`
**05_KNOWLEDGE :** Uniquement `README.md`
**legacy `knowledge/` :** `BUNDLE_KP_ClientDocMaster_V1.md` — équivalent trouvé dans `IT-SHARED/60_BUNDLES/KNOWLEDGEPACK/`
**Fichiers locaux à archiver :** `GPT_SETUP_CARD__IT-ClientDocMaster.md` (v1), `knowledge/BUNDLE_KP_ClientDocMaster_V1.md` (doublon IT-SHARED)
**Actions requises :**
- [ ] Archiver `GPT_SETUP_CARD__IT-ClientDocMaster.md` (v1 obsolète)
- [ ] Supprimer ou remplacer par référence `knowledge/BUNDLE_KP_ClientDocMaster_V1.md` (doublon de IT-SHARED)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-CloudMaster
**00_INSTRUCTIONS.md :** 6 802 chars ✅ OK
**prompt.md :** Présent — contenu unique (11 769 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-CloudMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-CloudMaster.md`
**Fichiers supplémentaires :** `prompt_IT-CloudMaster_V3.md` — ancienne version de prompt à archiver
**05_KNOWLEDGE :** Uniquement `README.md`
**legacy `knowledge/` :** `REFERENCE__Cloud_Admin_Portals.md` (archivé dans IT-SHARED/50_REFERENCE/99_ARCHIVE), `RUNBOOK__M365_User_Management.md`, `RUNBOOK__Quick_Start.md`
**Fichiers locaux à archiver :** `IT-CloudMaster_00_INSTRUCTIONS.md`, `prompt_IT-CloudMaster_V3.md`
**Actions requises :**
- [ ] Archiver `IT-CloudMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `prompt_IT-CloudMaster_V3.md` (ancienne version)
- [ ] Évaluer `knowledge/REFERENCE__Cloud_Admin_Portals.md` — version archivée dans IT-SHARED
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-Commandare-Infra
**00_INSTRUCTIONS.md :** 6 226 chars ✅ OK
**prompt.md :** Présent — contenu unique (12 146 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-Commandare-Infra_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-Commandare-Infra.md`
**KnowledgePack local :** `IT_Commandare_INFRA_KnowledgePack_v1/` (dossier avec EXAMPLES, Routing_Rules, Severity_Matrix, README)
**05_KNOWLEDGE :** Uniquement `README.md`
**Fichiers locaux à archiver :** `IT-Commandare-Infra_00_INSTRUCTIONS.md`, `PATCH__intents_yaml.md` (patch appliqué ?)
**Actions requises :**
- [ ] ⚠️ Contient "1 serveur à la fois" dans `00_INSTRUCTIONS.md` — règle de patching dépassée à mettre à jour
- [ ] Archiver `IT-Commandare-Infra_00_INSTRUCTIONS.md` (doublon)
- [ ] Vérifier si `PATCH__intents_yaml.md` a été appliqué — si oui, archiver
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-Commandare-NOC
**00_INSTRUCTIONS.md :** 6 129 chars ✅ OK
**prompt.md :** Présent — contenu unique (11 351 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-Commandare-NOC_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-Commandare-NOC.md`
**Fichiers supplémentaires :** `prompt_IT-Commandare-NOC_V3.md` — ancienne version de prompt à archiver; `02-Prompt-interne.md`, `03-Variantes-prompt.md`, `04-Amorces.md`, `05-Exemples-usage.md`, `06-Changelog.md` (série de fichiers de développement prompt)
**KnowledgePack local :** `IT_Commandare_NOC_KnowledgePack_v1/` (Comms_Templates, Escalation_Playbook, Glossary, Routing_Rules, Severity_Matrix, README)
**legacy `knowledge/` :** `CHECKLIST__Shift_Handover.md`, `REFERENCE__SLA_Matrix.md` (archivé IT-SHARED/50_REFERENCE), `RUNBOOK__NOC_Procedures.md`
**Fichiers locaux à archiver :** `IT-Commandare-NOC_00_INSTRUCTIONS.md`, `prompt_IT-Commandare-NOC_V3.md`
**Actions requises :**
- [ ] Archiver `IT-Commandare-NOC_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `prompt_IT-Commandare-NOC_V3.md` (ancienne version)
- [ ] Évaluer `knowledge/REFERENCE__SLA_Matrix.md` — équivalent archivé dans IT-SHARED
- [ ] Clarifier si les fichiers `02-` à `06-` sont actifs ou archivables
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-Commandare-OPR
**00_INSTRUCTIONS.md :** 6 055 chars ✅ OK
**prompt.md :** Présent — contenu unique (11 639 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-Commandare-OPR_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-Commandare-OPR.md`
**Fichiers supplémentaires :** `02-Prompt-interne.md`, `03-Variantes-prompt.md`, `04-Amorces.md`, `05-Exemples-usage.md`, `06-Changelog.md` (série de fichiers de développement prompt)
**KnowledgePack local :** `IT_Commandare_OPR_KnowledgePack_v1/` (CMDB_Standards, Comms_Templates, Glossary, KPI_Definitions, Postmortem_Template, Routing_Rules, Severity_Matrix)
**Fichiers locaux à archiver :** `IT-Commandare-OPR_00_INSTRUCTIONS.md`
**Actions requises :**
- [ ] Archiver `IT-Commandare-OPR_00_INSTRUCTIONS.md` (doublon)
- [ ] Clarifier si les fichiers `02-` à `06-` sont actifs ou archivables
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-Commandare-TECH
**00_INSTRUCTIONS.md :** 5 988 chars ✅ OK
**prompt.md :** Présent — contenu unique (11 795 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-Commandare-TECH_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-Commandare-TECH.md`
**Fichiers supplémentaires :** `02-Prompt-interne.md`, `03-Variantes-prompt.md`, `04-Amorces.md`, `05-Exemples-usage.md`, `06-Changelog.md` (série de fichiers de développement prompt)
**KnowledgePack local :** `IT_Commandare_TECH_KnowledgePack_v1/` (Escalation_Playbook, Glossary, KPI_Definitions, Postmortem_Template, Routing_Rules, Severity_Matrix)
**legacy `knowledge/` :** `RUNBOOK__Network_Setup.md` (non trouvé dans IT-SHARED)
**Fichiers locaux à archiver :** `IT-Commandare-TECH_00_INSTRUCTIONS.md`
**Actions requises :**
- [ ] Archiver `IT-Commandare-TECH_00_INSTRUCTIONS.md` (doublon)
- [ ] Clarifier si les fichiers `02-` à `06-` sont actifs ou archivables
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-FrontLine
**00_INSTRUCTIONS.md :** 5 824 chars ✅ OK
**prompt.md :** Présent — contenu unique (21 745 chars)
**Doublons instructions :** Aucun
**agent.yaml :** Version 1.1.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 2 versions — `GPT_SETUP_CARD__IT-AssistanTI_FrontLine.md` (v1) + `GPT_SETUP_CARD__IT-AssistanTI_FrontLine_v3.md` (v3) → garder `_v3.md`
**05_KNOWLEDGE :** Absent (dossier inexistant)
**legacy `knowledge/` :** `REFERENCE__SLA_FrontLine.md`, `REFERENCE__Scripts_FrontLine.md` (non trouvés dans IT-SHARED)
**Fichiers locaux à archiver :** `GPT_SETUP_CARD__IT-AssistanTI_FrontLine.md` (v1)
**Actions requises :**
- [ ] Archiver `GPT_SETUP_CARD__IT-AssistanTI_FrontLine.md` (v1 obsolète)
- [ ] Créer le dossier `05_KNOWLEDGE/` (absent alors que standard)
- [ ] Évaluer si `knowledge/REFERENCE__SLA_FrontLine.md` et `REFERENCE__Scripts_FrontLine.md` doivent migrer vers IT-SHARED
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-KnowledgeKeeper
**00_INSTRUCTIONS.md :** 5 676 chars ✅ OK
**prompt.md :** Présent — contenu unique (10 855 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-KnowledgeKeeper_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-KnowledgeKeeper.md`
**Fichiers supplémentaires :** `IT-KnowledgeKeeper_V3prompt.md` — ancienne version de prompt à archiver
**05_KNOWLEDGE :** Uniquement `README.md` (267 chars — stub)
**Fichiers locaux à archiver :** `IT-KnowledgeKeeper_00_INSTRUCTIONS.md`, `IT-KnowledgeKeeper_V3prompt.md`
**Actions requises :**
- [ ] Archiver `IT-KnowledgeKeeper_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `IT-KnowledgeKeeper_V3prompt.md` (ancienne version de prompt)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-MaintenanceMaster
**00_INSTRUCTIONS.md :** 6 589 chars ✅ OK
**prompt.md :** Présent — contenu unique (26 248 chars)
**Doublons instructions :** Aucun
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier — ⚠️ **description identique à IT-SysAdmin**
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-MaintenanceMaster_v3.md` ✅
**05_KNOWLEDGE :** Riche — 12 fichiers : KnowledgePack V2, BUNDLE__IT_SECURITY (= IT-SHARED/60_BUNDLES/99_ARCHIVE), NAMING_STANDARDS_v1 (= IT-SHARED/20_TEMPLATES/13_NAMING_STANDARDS), RUNBOOKS Patching/Incident/CW/Shutdown
**legacy `knowledge/` :** `GUIDE_IMPLEMENTATION.md`, `README.md`
**Fichiers locaux à archiver :**
- `05_KNOWLEDGE/BUNDLE__IT_SECURITY.md` — équivalent archivé dans IT-SHARED
- `05_KNOWLEDGE/NAMING_STANDARDS_v1.md` — équivalent dans IT-SHARED/20_TEMPLATES/13_NAMING_STANDARDS
**Actions requises :**
- [ ] ⚠️ Contient "1 serveur à la fois" dans `00_INSTRUCTIONS.md` (2 occurrences) — règle de patching dépassée à mettre à jour
- [ ] ❌ Corriger la description dans `agent.yaml` (identique à IT-SysAdmin — erreur de copier-coller)
- [ ] Archiver `05_KNOWLEDGE/BUNDLE__IT_SECURITY.md` (doublon IT-SHARED/60_BUNDLES/99_ARCHIVE)
- [ ] Archiver `05_KNOWLEDGE/NAMING_STANDARDS_v1.md` (doublon IT-SHARED)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-MonitoringMaster
**00_INSTRUCTIONS.md :** 5 963 chars ✅ OK
**prompt.md :** Présent — contenu unique (11 904 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-MonitoringMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-MonitoringMaster.md`
**Fichiers supplémentaires :** `IT-MonitoringMaster_prompt.md` — ancienne version de prompt
**05_KNOWLEDGE :** Uniquement `README.md` (269 chars — stub)
**legacy `knowledge/` :** `RUNBOOK__Alert_Response.md` (non trouvé dans IT-SHARED)
**Fichiers locaux à archiver :** `IT-MonitoringMaster_00_INSTRUCTIONS.md`, `IT-MonitoringMaster_prompt.md`
**Actions requises :**
- [ ] Archiver `IT-MonitoringMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `IT-MonitoringMaster_prompt.md` (ancienne version de prompt)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-NOCDispatcher
**00_INSTRUCTIONS.md :** 6 001 chars ✅ OK
**prompt.md :** Présent — contenu unique (10 026 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-NOCDispatcher_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-NOCDispatcher.md`
**Fichiers supplémentaires :** `IT-NOCDispatcher_prompt.md` — ancienne version de prompt; `02-Prompt-interne.md`, `03-Variantes-prompt.md`, `04-Amorces.md`, `05-Exemples-usage.md`, `06-Changelog.md`
**05_KNOWLEDGE :** Uniquement `README.md`
**legacy `knowledge/` :** `CHECKLIST__Shift_Handover.md`, `REFERENCE__SLA_Matrix.md` (archivé IT-SHARED/50_REFERENCE), `RUNBOOK__NOC_Procedures.md`
**Fichiers locaux à archiver :** `IT-NOCDispatcher_00_INSTRUCTIONS.md`, `IT-NOCDispatcher_prompt.md`
**Actions requises :**
- [ ] Archiver `IT-NOCDispatcher_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `IT-NOCDispatcher_prompt.md` (ancienne version de prompt)
- [ ] Évaluer `knowledge/REFERENCE__SLA_Matrix.md` — équivalent archivé dans IT-SHARED
- [ ] Clarifier si les fichiers `02-` à `06-` sont actifs ou archivables
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-NetworkMaster
**00_INSTRUCTIONS.md :** 6 339 chars ✅ OK
**prompt.md :** Présent — contenu unique (11 529 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-NetworkMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-NetworkMaster.md`
**Fichiers supplémentaires :** `IT-NetworkMaster_prompt.md` — ancienne version de prompt
**05_KNOWLEDGE :** Uniquement `README.md`
**legacy `knowledge/` :** `RUNBOOK__Network_Setup.md` (non trouvé dans IT-SHARED)
**Fichiers locaux à archiver :** `IT-NetworkMaster_00_INSTRUCTIONS.md`, `IT-NetworkMaster_prompt.md`
**Actions requises :**
- [ ] Archiver `IT-NetworkMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `IT-NetworkMaster_prompt.md` (ancienne version de prompt)
- [ ] Évaluer `knowledge/RUNBOOK__Network_Setup.md` — candidat à publier dans IT-SHARED si pertinent
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-OPS-DossierIA
**00_INSTRUCTIONS.md :** 2 077 chars ✅ OK (format plus compact — agent OPS)
**prompt.md :** Présent — contenu unique (2 361 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` (2077 c) ET `00_instruction.md` (753 c, lowercase) — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** `setupCard.md` (format différent des autres agents — 1 version)
**05_KNOWLEDGE :** Absent (structure différente pour agents OPS)
**Fichiers locaux à archiver :** `00_instruction.md` (lowercase, ancienne version), `PromptInterneActuel.rtf` (format RTF non standard)
**Actions requises :**
- [ ] Archiver `00_instruction.md` (doublon lowercase)
- [ ] Convertir ou archiver `PromptInterneActuel.rtf` (format RTF non standard)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-OPS-PlaybookRunner
**00_INSTRUCTIONS.md :** 2 188 chars ✅ OK (format compact — agent OPS)
**prompt.md :** Présent — contenu unique (2 835 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` (2188 c) ET `00_instruction.md` (992 c, lowercase) — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** `setupCard.md` (format différent — 1 version)
**05_KNOWLEDGE :** Absent
**Fichiers locaux à archiver :** `00_instruction.md` (lowercase, ancienne version), `PromptInterneActuel.rtf`
**Actions requises :**
- [ ] Archiver `00_instruction.md` (doublon lowercase)
- [ ] Convertir ou archiver `PromptInterneActuel.rtf` (format RTF non standard)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-OPS-RouterIA
**00_INSTRUCTIONS.md :** 2 566 chars ✅ OK (format compact — agent OPS)
**prompt.md :** Présent — contenu unique (4 848 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` (2566 c) ET `00_instruction.md` (2147 c, lowercase) — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** `setupCard.md` (format différent — 1 version)
**05_KNOWLEDGE :** Absent
**Fichiers locaux à archiver :** `00_instruction.md` (lowercase), `PromptInterneActuel.md` (ancienne version nommée différemment)
**Actions requises :**
- [ ] Archiver `00_instruction.md` (doublon lowercase)
- [ ] Archiver `PromptInterneActuel.md` (ancienne version)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-ReportMaster
**00_INSTRUCTIONS.md :** 5 874 chars ✅ OK
**prompt.md :** Présent — contenu unique (12 016 chars)
**Doublons instructions :** Aucun
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-ReportMaster.md` ✅
**05_KNOWLEDGE :** Uniquement `README.md`
**Fichiers locaux à archiver :** Aucun identifié
**Actions requises :**
- [ ] Ajouter un champ `date` dans `agent.yaml`
- [ ] ℹ️ Agent le plus propre — structure minimale et cohérente

---

### IT-ScriptMaster
**00_INSTRUCTIONS.md :** 6 108 chars ✅ OK
**prompt.md :** Présent — contenu unique (9 895 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-ScriptMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-ScriptMaster.md`
**Fichiers supplémentaires :** `IT-ScriptMaster_prompt.md` — ancienne version de prompt
**Structure dossiers :** ⚠️ Dossiers dupliqués : `02_RUNBOOKS` ET `03_RUNBOOKS`, `02_TEMPLATES` ET `01_TEMPLATES`, `03_CHECKLISTS` ET `04_CHECKLISTS`, `04_EXEMPLES` ET `06_EXEMPLES`
**05_KNOWLEDGE :** Uniquement `README.md`
**Fichiers locaux à archiver :** `IT-ScriptMaster_00_INSTRUCTIONS.md`, `IT-ScriptMaster_prompt.md`
**Actions requises :**
- [ ] Archiver `IT-ScriptMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `IT-ScriptMaster_prompt.md` (ancienne version de prompt)
- [ ] ⚠️ Consolider la structure de dossiers dupliqués (02_RUNBOOKS/03_RUNBOOKS, 02_TEMPLATES/01_TEMPLATES, etc.)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-SecurityMaster
**00_INSTRUCTIONS.md :** 6 502 chars ✅ OK
**prompt.md :** Présent — contenu unique (11 632 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-SecurityMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-SecurityMaster.md`
**Fichiers supplémentaires :** `IT-SecurityMaster_prompt.md` — ancienne version de prompt
**05_KNOWLEDGE :** Uniquement `README.md`
**legacy `knowledge/` :** `RUNBOOK__Security_Audit.md` (non trouvé dans IT-SHARED)
**Fichiers locaux à archiver :** `IT-SecurityMaster_00_INSTRUCTIONS.md`, `IT-SecurityMaster_prompt.md`
**Actions requises :**
- [ ] Archiver `IT-SecurityMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `IT-SecurityMaster_prompt.md` (ancienne version de prompt)
- [ ] Évaluer `knowledge/RUNBOOK__Security_Audit.md` — candidat à publier dans IT-SHARED
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-SysAdmin
**00_INSTRUCTIONS.md :** 7 303 chars ✅ OK (proche de la limite — surveiller)
**prompt.md :** Présent — contenu unique (24 109 chars)
**Doublons instructions :** Aucun
**agent.yaml :** Version 2.0.0 — aucune date — ❌ **description identique à IT-MaintenanceMaster**
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-SysAdmin_v3.md` ✅
**05_KNOWLEDGE :** 14 fichiers riches : BUNDLE__IT_SECURITY (= IT-SHARED/60_BUNDLES/99_ARCHIVE), NAMING_STANDARDS_v1 (= IT-SHARED), TEMPLATE__CW_DISCUSSION/NOTE_INTERNE/EMAIL_CLIENT (= IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/99_ARCHIVE), TEMPLATE__Server_Health_Check (= IT-SHARED/20_TEMPLATES/14_TEMPLATE_HEALTH), multiple RUNBOOKS
**legacy `knowledge/` :** `GUIDE_IMPLEMENTATION.md`, `NAMING_STANDARDS_v1.md` (= IT-SHARED), `README.md`
**Fichiers locaux à archiver :**
- `05_KNOWLEDGE/BUNDLE__IT_SECURITY.md` — doublon IT-SHARED/60_BUNDLES/99_ARCHIVE
- `05_KNOWLEDGE/NAMING_STANDARDS_v1.md` — doublon IT-SHARED/20_TEMPLATES/13_NAMING_STANDARDS
- `05_KNOWLEDGE/TEMPLATE__CW_DISCUSSION.md` — archivé dans IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/99_ARCHIVE
- `05_KNOWLEDGE/TEMPLATE__CW_NOTE_INTERNE.md` — archivé dans IT-SHARED
- `05_KNOWLEDGE/TEMPLATE__EMAIL_CLIENT.md` — archivé dans IT-SHARED
- `knowledge/NAMING_STANDARDS_v1.md` — doublon IT-SHARED
**Actions requises :**
- [ ] ⚠️ Contient "1 serveur à la fois" dans `00_INSTRUCTIONS.md` — règle de patching dépassée à mettre à jour
- [ ] ❌ Corriger la description dans `agent.yaml` (identique à IT-MaintenanceMaster — erreur de copier-coller)
- [ ] Archiver les 5 fichiers locaux en doublon avec IT-SHARED (voir liste ci-dessus)
- [ ] 00_INSTRUCTIONS.md à 7303 chars — à surveiller (proche de 8000)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-TicketOpr
**00_INSTRUCTIONS.md :** 7 034 chars ✅ OK (à surveiller — proche de 8000)
**prompt.md :** Présent — contenu unique (16 594 chars)
**Doublons instructions :** Aucun
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-TicketOpr.md` ✅
**Dossiers supplémentaires :** `00_INDEX/` et `01_CONTRACT.yaml` (fichiers supplémentaires spécifiques à cet agent) + `99_TEST/` (dossier de test en plus de `65_TEST/`)
**05_KNOWLEDGE :** `KNOWLEDGE_INDEX.md` (394 chars) + `README.md` — plus structuré que la moyenne
**Fichiers locaux à archiver :** `99_TEST/` (doublon de `65_TEST/` ?)
**Actions requises :**
- [ ] Vérifier si `99_TEST/` et `65_TEST/` ont le même usage — consolider
- [ ] Vérifier `01_CONTRACT.yaml` vs `contract.yaml` à la racine — doublon possible
- [ ] 00_INSTRUCTIONS.md à 7034 chars — à surveiller (proche de 8000)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-TicketScribe
**00_INSTRUCTIONS.md :** 5 869 chars ✅ OK
**prompt.md :** Présent — contenu unique (18 384 chars)
**Doublons instructions :** Aucun
**agent.yaml :** Version 2.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-TicketScribe.md` ✅
**05_KNOWLEDGE :** Uniquement `README.md`
**Fichiers locaux à archiver :** Aucun identifié
**Actions requises :**
- [ ] Ajouter un champ `date` dans `agent.yaml`
- [ ] ℹ️ Agent propre — structure minimale et cohérente

---

### IT-UrgenceMaster
**00_INSTRUCTIONS.md :** 5 816 chars ✅ OK
**prompt.md :** Présent — contenu unique (15 970 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-UrgenceMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.2.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-UrgenceMaster.md`
**Fichiers supplémentaires :** `IT-UrgenceMaster_prompt.md` — ancienne version de prompt; `AUDIT__IT-UrgenceMaster.md` (audit précédent)
**05_KNOWLEDGE :** Uniquement `README.md`
**legacy `knowledge/` :** `BUNDLE_KP_UrgenceMaster_V1.md` (= IT-SHARED/60_BUNDLES/KNOWLEDGEPACK), `TEMPLATE_DIAG_PostPanneHQ.md`, `TEMPLATE__FLAG_UP_AVERTISSEMENT.md`
**Fichiers locaux à archiver :** `IT-UrgenceMaster_00_INSTRUCTIONS.md`, `IT-UrgenceMaster_prompt.md`
**Actions requises :**
- [ ] ⚠️ Contient "1 serveur à la fois" dans `00_INSTRUCTIONS.md` — règle de patching dépassée à mettre à jour
- [ ] Archiver `IT-UrgenceMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `IT-UrgenceMaster_prompt.md` (ancienne version de prompt)
- [ ] Archiver `knowledge/BUNDLE_KP_UrgenceMaster_V1.md` — doublon IT-SHARED/60_BUNDLES/KNOWLEDGEPACK
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

### IT-VoIPMaster
**00_INSTRUCTIONS.md :** 5 735 chars ✅ OK
**prompt.md :** Présent — contenu unique (12 665 chars)
**Doublons instructions :** `00_INSTRUCTIONS.md` ET `IT-VoIPMaster_00_INSTRUCTIONS.md` — conserver `00_INSTRUCTIONS.md`
**agent.yaml :** Version 1.0.0 — aucune date dans le fichier
**GPT_SETUP_CARD :** 1 version — `GPT_SETUP_CARD__IT-VoIPMaster.md`
**Fichiers supplémentaires :** `IT-VoIPMaster_prompt.md` — ancienne version de prompt
**05_KNOWLEDGE :** Uniquement `README.md`
**Fichiers locaux à archiver :** `IT-VoIPMaster_00_INSTRUCTIONS.md`, `IT-VoIPMaster_prompt.md`
**Actions requises :**
- [ ] Archiver `IT-VoIPMaster_00_INSTRUCTIONS.md` (doublon)
- [ ] Archiver `IT-VoIPMaster_prompt.md` (ancienne version de prompt)
- [ ] Ajouter un champ `date` dans `agent.yaml`

---

## Synthèse des problèmes

### Problèmes par type (fréquence décroissante)

| Type de problème | Nb agents touchés | Agents |
|---|---|---|
| **`agent.yaml` sans champ `date`** | 27/27 | Tous |
| **`prompt.md` présent mais différent de `00_INSTRUCTIONS.md`** | 27/27 | Tous (comportement normal — prompt.md = GPT complet) |
| **Fichier `{agent}_00_INSTRUCTIONS.md` en doublon** | 16/27 | AssetMaster, BackupDRMaster, CloudMaster, Commandare-Infra, Commandare-NOC, Commandare-OPR, Commandare-TECH, KnowledgeKeeper, MonitoringMaster, NOCDispatcher, NetworkMaster, ScriptMaster, SecurityMaster, UrgenceMaster, VoIPMaster, BackupDRMaster |
| **Ancien fichier `_prompt.md` ou `_V3prompt.md` non archivé** | 9/27 | CloudMaster, Commandare-NOC, KnowledgeKeeper, MonitoringMaster, NOCDispatcher, NetworkMaster, ScriptMaster, SecurityMaster, UrgenceMaster, VoIPMaster |
| **`00_instruction.md` (lowercase) en doublon** | 3/27 | OPS-DossierIA, OPS-PlaybookRunner, OPS-RouterIA |
| **2 versions de GPT_SETUP_CARD** | 7/27 | AssetMaster, Assistant-N2, Assistant-N3, BackupDRMaster, ClientDocMaster, FrontLine, (SysAdmin — déjà v3 seulement) |
| **Règle "1 serveur à la fois" dépassée** | 5/27 | Assistant-N3, Commandare-Infra, MaintenanceMaster (x2), SysAdmin, UrgenceMaster |
| **Description `agent.yaml` incorrecte/copiée** | 2/27 | IT-SysAdmin et IT-MaintenanceMaster (descriptions identiques) |
| **Fichiers locaux en doublon avec IT-SHARED** | 5/27 | SysAdmin (5 fichiers), MaintenanceMaster (2 fichiers), ClientDocMaster (KP), UrgenceMaster (KP), BackupDRMaster (checklist) |
| **Structure de dossiers anormale** | 2/27 | ScriptMaster (dossiers numérotés dupliqués), TicketOpsAI (99_TEST en plus de 65_TEST) |
| **`PromptInterneActuel.rtf` (format non standard)** | 2/27 | OPS-DossierIA, OPS-PlaybookRunner |
| **`05_KNOWLEDGE` absent** | 4/27 | FrontLine, OPS-DossierIA, OPS-PlaybookRunner, OPS-RouterIA |
| **00_INSTRUCTIONS proche de 8000 chars (>7000)** | 2/27 | SysAdmin (7303 c), TicketOpsAI (7034 c) |

### Priorités d'action recommandées

**CRITIQUE (à faire en priorité) :**
1. ❌ Corriger les descriptions identiques dans `agent.yaml` de IT-SysAdmin et IT-MaintenanceMaster
2. ⚠️ Mettre à jour la règle "1 serveur à la fois" dans les 5 agents concernés (Assistant-N3, Commandare-Infra, MaintenanceMaster, SysAdmin, UrgenceMaster)
3. ⚠️ Surveiller IT-SysAdmin (7303 c) et IT-TicketOpr (7034 c) — prochaine mise à jour risque de dépasser 8000 c

**NETTOYAGE (par batch) :**
4. Archiver les 16 fichiers `{agent}_00_INSTRUCTIONS.md` en doublon
5. Archiver les ~10 fichiers `{agent}_prompt.md` ou `_V3prompt.md` obsolètes
6. Archiver les versions v1 des GPT_SETUP_CARD pour 7 agents
7. Archiver les 3 `00_instruction.md` (lowercase) pour les agents OPS

**SYSTÉMIQUE :**
8. Ajouter un champ `date` dans tous les `agent.yaml` (27/27 manquants)
9. Publier dans IT-SHARED les runbooks locaux uniques avant de les retirer des dossiers agents

---
*Rapport généré le 2026-05-16 — Audit automatisé via analyse structurelle des 27 dossiers agents*
