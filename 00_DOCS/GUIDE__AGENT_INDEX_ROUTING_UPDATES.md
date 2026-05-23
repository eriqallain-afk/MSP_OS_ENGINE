## Objectif

Ce guide décrit les fichiers à vérifier ou mettre à jour lorsqu’un nouvel agent est ajouté à FACTORY ou à un produit comme `IT`.

Il sert de checklist pour éviter les agents orphelins, les intents non routés, les catalogues incomplets et les Knowledge packs incohérents.

---

## Ordre de priorité des sources

1. Repo produit concerné, par exemple `eriqallain-afk/IT`
2. Repo global `eriqallain-afk/FACTORY`
3. Fichiers uploadés dans le GPT Editor
4. Conversation utilisateur

Si une information est absente ou contradictoire, utiliser `[À CONFIRMER]`.

---

## 1. Fichiers agent à créer ou vérifier

Pour un agent produit IT :

```text
20_Agents/<AgentID>/agent.yaml
20_Agents/<AgentID>/contract.yaml
20_Agents/<AgentID>/prompt.md
20_Agents/<AgentID>/04_KNOWLEDGE_INDEX.md
```

Vérifier :

- `actor_id` ou `id`
- `display_name`
- `team_id`
- `status`
- `description`
- `intents`
- `commands`
- `interfaces.contract`
- `interfaces.prompt`
- `guardrails`
- `escalades`

---

## 2. Index produit à mettre à jour

Pour le repo produit, par exemple `eriqallain-afk/IT` :

```text
00_INDEX/product.yaml
00_INDEX/agents.yaml
00_INDEX/agents_index.yaml
00_INDEX/intents.yaml
00_INDEX/gpt_catalog.yaml
00_INDEX/KNOWLEDGE_INDEX.yaml
00_INDEX/RUNBOOK_DISPATCH.yaml
80_MACHINES/hub_routing.yaml
```

Ajouter ou vérifier :

- l’agent dans `agents.yaml`
- l’agent dans `agents_index.yaml`
- ses intents dans `intents.yaml`
- son entrée GPT dans `gpt_catalog.yaml`
- ses fichiers Knowledge dans `KNOWLEDGE_INDEX.yaml`
- les routes intent → agent/runbook dans `hub_routing.yaml`
- les runbooks associés dans `RUNBOOK_DISPATCH.yaml`

---

## 3. Index FACTORY à mettre à jour

Pour le repo global `eriqallain-afk/FACTORY` :

```text
00_INDEX/agents.yaml
00_INDEX/agents_index.yaml
00_INDEX/agents_manifest.yaml
00_INDEX/intents.yaml
00_INDEX/gpt_catalog.yaml
00_INDEX/capability_map.yaml
00_INDEX/teams_index.yaml
00_INDEX/playbooks_index.yaml
00_INDEX/runbooks_index.yaml
80_MACHINES/hub_routing.yaml
80_MACHINES/products_routing.yaml
40_ROUTING/hub_routing.yaml
```

Ajouter ou vérifier :

- présence de l’agent dans les index agents;
- présence dans le manifest global;
- mapping des aliases et intents;
- capacités recommandées dans `capability_map.yaml`;
- visibilité dans `gpt_catalog.yaml`;
- routage produit dans `products_routing.yaml`;
- routage hub global si applicable.

---

## 4. Documents GPT Editor à vérifier

Dans le repo produit :

```text
00_DOCS/HOW_TO_CREATE_GPT.md
00_DOCS/PRODUCT_PRESENTATION__<product>.md
```

Dans le dossier agent :

```text
GPT_SETUP_CARD__<AgentID>_vX.md
GUIDE_UTILISATION__<AgentID>_vX.md
```

Vérifier que la GPT Setup Card contient :

- Name
- Description courte de moins de 300 caractères
- Instructions ou référence au prompt
- 5 conversation starters
- capabilities recommandées
- fichiers Knowledge à uploader
- tests de validation

---

## 5. Knowledge recommandé

Ordre conseillé pour un GPT agent :

1. `contract.yaml`
2. `04_KNOWLEDGE_INDEX.md`
3. Index produit pertinents
4. Routing produit
5. Index FACTORY pertinents
6. Catalogues GPT
7. Runbook dispatch
8. Runbooks opérationnels nécessaires
9. Guides `00_DOCS`

Ne pas uploader :

- fichiers de test;
- secrets;
- credentials;
- fichiers obsolètes;
- archives sauf besoin explicite.

---

## 6. Checklist Definition of Done

Avant de considérer l’ajout terminé :

- [ ] Agent créé avec `agent.yaml`, `contract.yaml`, `prompt.md`
- [ ] Agent présent dans l’index produit
- [ ] Agent présent dans l’index FACTORY si applicable
- [ ] Intents déclarés
- [ ] Routes configurées
- [ ] GPT catalog mis à jour
- [ ] Capability map mise à jour
- [ ] Knowledge index mis à jour
- [ ] Runbooks liés si nécessaires
- [ ] GPT Setup Card prête
- [ ] Guide utilisateur prêt
- [ ] Tests de validation définis
- [ ] Aucun secret ni credential
- [ ] Aucune ressource inventée

---

## 7. Format de note d’intégration

```yaml
integration_note:
  agent_id: "<AgentID>"
  product: "<PRODUCT_ID>"
  status: "ready|draft|blocked"
  files_added:
    - "<path>"
  files_updated:
    - "<path>"
  intents_added:
    - "<intent>"
  routing_updated:
    - "<path>"
  knowledge_files:
    - "<path>"
  tests:
    - name: "<test>"
      expected: "<expected behavior>"
  risks:
    - "<risk or none>"
  unknowns:
    - "<unknown or none>"
```