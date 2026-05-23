# RUNBOOK — Cycle de vie d'un agent (ajout / modification / activation)
> **Version :** 1.0 | **Date :** 2026-05-19
> **Usage :** Référence obligatoire lors de tout ajout ou modification d'un agent MSP Intelligence AI
> **Agents :** IT-OPS-RouterIA | IT-OPS-QAMaster | IT-OPS-SyncFactory

---

## Contexte

Ce runbook définit la liste exhaustive des fichiers à créer ou mettre à jour selon le type d'opération effectuée sur un agent de la plateforme. Il est la source de vérité pour garantir la cohérence entre les 32 agents, les index, la Factory et la documentation.

> **Règle absolue :** `auto_activation: false` — aucun agent ne passe en `status: active` sans validation EA explicite.

---

## SCÉNARIO A — Ajout d'un nouvel agent

### A1. Fichiers à créer (structure minimale obligatoire)

```
20_Agents/{agent-id}/
├── agent.yaml               ← Identité, rôle, status: staging, version: 1.0
├── prompt.md                ← System prompt complet (~8000 chars)
├── contract.yaml            ← Inputs/outputs attendus
├── 00_INSTRUCTIONS.md       ← Config GPT : nom + description <300 chars + instructions
└── 04_KNOWLEDGE_INDEX.md    ← Index des sources de connaissance de l'agent
```

> **Si `status: staging`** → créer dans `99_STAGING/Draft/{module}/{agent-id}/` et non dans `20_Agents/`.

### A2. Contenu obligatoire de `00_INSTRUCTIONS.md`

- **Nom** : affiché dans GPT Editor
- **Description** : < 300 caractères
- **Instructions** : ~8000 caractères incluant obligatoirement :
  - Bloc `## Sécurité & Confidentialité — Non négociable`
  - Bloc `## RUNBOOKS GITHUB` avec menu contextuel adapté à l'agent (chemins GitHub exacts)

### A3. Index et registres à mettre à jour

| Fichier | Champ à ajouter |
|---|---|
| `00_INDEX/agents_index.yaml` | Nouvelle entrée complète (display_name, team_id, role, status, description, intents) |
| `FACTORY_MANIFEST_IT.yaml` | `agents_count` +1 + entrée dans `agents` list + `required_files` |
| `00_INDEX/gpt_catalog.yaml` | Nouvelle entrée (agent_id, display_name, description, paths, instructions) |
| `00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` | Intents de l'agent → entrées dans la section appropriée |
| `CLAUDE.md` (section 3) | Ajouter l'agent dans le tableau de l'équipe concernée |

### A4. Qualité plateforme

| Fichier | Action |
|---|---|
| `00_QA/scores/quality_dashboard.yaml` | Ajouter entrée agent avec score initial |
| `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md` | Ajouter commandes agent si elles sont exposées aux autres agents |

### A5. Sync Factory

| Fichier | Action |
|---|---|
| `00_FACTORY_SYNC/CURRENT_STATE.yaml` | Incrémenter `agents_count`, ajouter à `recent_changes` |
| `00_FACTORY_SYNC/CHANGELOG.md` | Ajouter entrée `[ADDED] {agent-id}` avec date |

### A6. Routing

- Vérifier que chaque intent de l'agent est présent dans `MASTER_DISPATCH_INDEX_V2.yaml`
- Vérifier que le routing `hub_routing.yaml` (80_MACHINES) n'a pas besoin de mise à jour
- Si le nouvel agent introduit un nouveau runbook/template : l'ajouter dans `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md`

---

## SCÉNARIO B — Modification d'un agent existant

### B1. Dans le dossier de l'agent

| Fichier | Action |
|---|---|
| `agent.yaml` | Incrémenter `version` (ex. 1.0 → 1.1) + mettre à jour `last_updated` |
| `prompt.md` | Modifier le contenu — ne jamais supprimer les blocs sécurité |
| `00_INSTRUCTIONS.md` | Mettre à jour si les commandes, le périmètre ou les guardrails changent |
| `04_KNOWLEDGE_INDEX.md` | Mettre à jour si des fichiers de connaissance sont ajoutés/supprimés |

### B2. Index et registres à mettre à jour (si applicable)

| Condition | Fichier | Action |
|---|---|---|
| Changement de rôle ou d'intents | `agents_index.yaml` | Mettre à jour `role`, `intents` |
| Changement de rôle ou d'intents | `MASTER_DISPATCH_INDEX_V2.yaml` | Mettre à jour ou ajouter les intents |
| Changement de fichiers requis | `FACTORY_MANIFEST_IT.yaml` | Mettre à jour `required_files` |
| Changement de chemins | `gpt_catalog.yaml` | Mettre à jour les chemins |
| Nouveau runbook/template | `RUNBOOK_MENU_CONTEXTUEL_V4.md` | Ajouter la commande |

### B3. Sync Factory

| Fichier | Action |
|---|---|
| `00_FACTORY_SYNC/CURRENT_STATE.yaml` | Mettre à jour `last_sync_date`, ajouter à `recent_changes` |
| `00_FACTORY_SYNC/CHANGELOG.md` | Ajouter entrée `[MODIFIED] {agent-id} — {description courte}` |

### B4. QA

- Si la modification corrige un bug connu → créer un fichier dans `00_QA/fixes/applied/`
- Si la modification change le comportement → mettre à jour le score dans `00_QA/scores/quality_dashboard.yaml`

---

## SCÉNARIO C — Activation d'un agent staging → active

> Requiert **validation EA explicite** avant toute action.

### Checklist d'activation

```
[ ] EA a approuvé l'activation (validation documentée)
[ ] agent.yaml : status: staging → status: active
[ ] Déplacer le dossier de 99_STAGING/Draft/{module}/ → 20_Agents/
[ ] agents_index.yaml : status: staging → status: active
[ ] FACTORY_MANIFEST_IT.yaml : agents_count +1 (si était en staging hors compte)
[ ] gpt_catalog.yaml : vérifier que les chemins pointent vers 20_Agents/ (pas 99_STAGING/)
[ ] 00_FACTORY_SYNC/CURRENT_STATE.yaml : mettre à jour agents_count + recent_changes
[ ] 00_FACTORY_SYNC/CHANGELOG.md : [ACTIVATED] {agent-id}
[ ] 00_QA/scores/quality_dashboard.yaml : ajouter/activer l'entrée
[ ] CLAUDE.md : vérifier que l'agent figure dans le tableau (section 3)
[ ] Tester le routing : soumettre un intent → vérifier que RouterIA atteint l'agent
```

---

## SCÉNARIO D — Archivage d'un agent

> Requiert **validation EA explicite** avant toute action.

### Checklist d'archivage

```
[ ] EA a approuvé l'archivage
[ ] agent.yaml : status: active → status: archived
[ ] agents_index.yaml : status: archived (ne jamais supprimer l'entrée)
[ ] FACTORY_MANIFEST_IT.yaml : agents_count -1 + noter dans archived_agents
[ ] MASTER_DISPATCH_INDEX_V2.yaml : retirer ou rediriger les intents orphelins
[ ] gpt_catalog.yaml : marquer deprecated
[ ] 00_FACTORY_SYNC/CHANGELOG.md : [ARCHIVED] {agent-id}
[ ] Documenter la raison dans 00_QA/incidents/ si l'archivage suit un problème qualité
```

---

## Rappel — Règle DOC_SYNC_MATRIX

Consulter `00_INDEX/DOC_SYNC_MATRIX.md` pour confirmer la liste complète des fichiers à synchroniser selon le type de changement. Ce runbook est la vue opérationnelle ; DOC_SYNC_MATRIX est la matrice de référence formelle.

---

## Checklist rapide (impression / usage live)

```
AJOUT AGENT
  [ ] 5 fichiers créés dans 20_Agents/ (agent.yaml, prompt.md, contract.yaml, 00_INSTRUCTIONS.md, 04_KNOWLEDGE_INDEX.md)
  [ ] agents_index.yaml mis à jour
  [ ] FACTORY_MANIFEST_IT.yaml mis à jour (agents_count, agents list, required_files)
  [ ] gpt_catalog.yaml mis à jour
  [ ] MASTER_DISPATCH_INDEX_V2.yaml — intents ajoutés
  [ ] CLAUDE.md section 3 mis à jour
  [ ] quality_dashboard.yaml — entrée ajoutée
  [ ] RUNBOOK_MENU_CONTEXTUEL_V4.md — commandes ajoutées si applicable
  [ ] 00_FACTORY_SYNC/ mis à jour (CURRENT_STATE + CHANGELOG)

MODIFICATION AGENT
  [ ] agent.yaml — version incrémentée
  [ ] prompt.md / 00_INSTRUCTIONS.md — mis à jour
  [ ] 04_KNOWLEDGE_INDEX.md — mis à jour si nécessaire
  [ ] Index mis à jour si intents/rôle/chemins changent
  [ ] 00_FACTORY_SYNC/CHANGELOG.md — entrée ajoutée

ACTIVATION STAGING
  [ ] Validation EA documentée
  [ ] Dossier déplacé vers 20_Agents/
  [ ] agent.yaml + agents_index.yaml : status: active
  [ ] Tous les chemins mis à jour (gpt_catalog, FACTORY_MANIFEST)
  [ ] Routing testé
```

---

*RUNBOOK Agent Lifecycle v1.0 — IT-SHARED/10_RUNBOOKS/00_POLICIES — MSP Intelligence AI — 2026-05-19*
