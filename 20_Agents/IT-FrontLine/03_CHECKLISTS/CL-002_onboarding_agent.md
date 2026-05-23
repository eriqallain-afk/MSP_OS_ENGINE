# CL-002 — Checklist Onboarding Agent FrontLine
**Usage :** Configuration initiale du GPT dans GPT Editor

## Configuration GPT Editor
- [ ] Name : `IT-AssistanTI_FrontLine`
- [ ] Description : copiée depuis `GPT_SETUP_CARD`
- [ ] Instructions : contenu de `00_INSTRUCTIONS.md` collé
- [ ] Knowledge uploadé dans l'ordre :
  - [ ] 🔴 `prompt.md` (471L) — EN PREMIER
  - [ ] 🔴 `BUNDLE_KP_AssistanTI-FrontLine_V1.md`
  - [ ] 🟠 `RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md`
  - [ ] 🟠 `REFERENCE__SLA_FrontLine.md`
  - [ ] 🟠 `REFERENCE__Scripts_FrontLine.md`
  - [ ] 🟠 `TEMPLATE__CW_NOTE_INTERNE_FrontLine.md`
  - [ ] 🟠 `TEMPLATE__CW_DISCUSSION_STAR_FrontLine.md`
  - [ ] 🟠 `TEMPLATE__CW_NOTE_TRIAGE.md`
- [ ] Web Search : OFF
- [ ] DALL·E : OFF
- [ ] Code Interpreter : OFF
- [ ] Conversation Starters configurés (4 — voir SETUP_CARD)

## Tests de validation post-configuration
- [ ] `/appel` → menu billet existant/nouveau affiché
- [ ] `/ticket #T99999` → plan d'action immédiat affiché
- [ ] MDP sans identité → refus avec message poli
- [ ] P1 mentionné → escalade immédiate (pas de tentative de résolution)
- [ ] `/close` → Note Interne + Discussion STAR générées

## Ajouts 00_INDEX complétés
- [ ] `agents.yaml` — entrée ajoutée
- [ ] `agents_index.yaml` — entrée ajoutée
- [ ] `gpt_catalog.yaml` — entrée ajoutée
- [ ] `intents.yaml` — intents ajoutés
- [ ] `KNOWLEDGE_INDEX.yaml` — consumers mis à jour
- [ ] `product.yaml` — agent count mis à jour
- [ ] `hub_routing.yaml` — route frontline ajoutée
- [ ] `playbooks.yaml` — playbook IT_FRONTLINE_CALL_TO_CLOSE ajouté
