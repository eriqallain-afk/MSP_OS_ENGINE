# CHANGELOG — Synchronisation Produit IT → Factory

> Journal des changements structurels transmis à la Factory.
> Géré par : IT-OPS-SyncFactory via `/sync`
> Format : entrées chronologiques inversées (plus récent en haut)

---

## [2026-05-19] — MODULE_PROJETS connexion complète + runbook cycle de vie agent

- [ADDED] `IT-SHARED/10_RUNBOOKS/00_POLICIES/RUNBOOK__AGENT_LIFECYCLE_V1.md` — procédure ajout/modification/activation/archivage agent (4 scénarios, checklists)
- [ADDED] `IT-SHARED/10_RUNBOOKS/PROJET/PROJET-SOW_Process_V1.md` — runbook SOW 7 phases
- [ADDED] `IT-SHARED/20_TEMPLATES/16_TEMPLATE_PROJET/TEMPLATE_SOW_CLIENT_V1.md` — template SOW client
- [ADDED] `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE_CW_PROJET_SOW_V1.md` — template CW Discussion + Note
- [ADDED] `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS/TEMPLATE_RAPPORT_PIPELINE_PROJETS_V1.md` — template rapport pipeline
- [MODIFIED] `playbooks/playbooks.yaml` — playbook `IT_PROJET_SOW` ajouté (8 steps)
- [MODIFIED] `IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` — 3 intents MODULE_PROJETS ajoutés
- [MODIFIED] `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md` — section PLATEFORME + section MODULE PROJETS

---

## [2026-05-19] — IT-OPS-SyncFactory + 00_FACTORY_SYNC + correctifs root_IA

- [ADDED] Agent `IT-OPS-SyncFactory` (v1.0.0) — monitoring changements produit → Factory
- [ADDED] `00_FACTORY_SYNC/` — canal Produit→Factory (README, CURRENT_STATE, CHANGELOG, FACTORY_CONFIG)
- [FIXED] Dernière référence `root_IA` remplacée dans BUNDLE__INFRA_Firewall.md
- [MODIFIED] `FACTORY_MANIFEST_IT.yaml` — agents_count: 32 (4 OPS + 28 métier)

---

## [2026-05-19] — MODULE_PROJETS (staging) + audit plateforme complet

- [ADDED] Module staging MODULE_PROJETS : agent `IT-ProjetSOW`, pipeline `/ventes/`, spec complète
- [ADDED] `ventes/` — répertoire pipeline avec SCHEMA_OPPORTUNITY, ACCESS_CONTROL, 3 sous-dossiers
- [ADDED] `99_STAGING/Draft/MODULE_PROJETS/` — spec + agent + template ESCALADE_VENTES
- [ADDED] `IT-SHARED/20_TEMPLATES/15_TEMPLATE_TICKETOPS/ESCALADE_VENTES.md`
- [MODIFIED] `00_INDEX/agents_index.yaml` — 32 agents (IT-OnboardingMaster + IT-TechOPS ajoutés)
- [MODIFIED] `00_INDEX/gpt_catalog.yaml` — 27/27 agents avec chemins complets + instructions
- [MODIFIED] `00_INDEX/DOC_SYNC_MATRIX.md` — règle 00_INSTRUCTIONS.md ajoutée
- [FIXED] Audit 11 findings : chemins Azure, compteurs, fichiers manquants

---

## [2026-05-19] — Standardisation 00_INSTRUCTIONS.md (32 agents)

- [ADDED] `20_Agents/IT-ComplianceMaster/00_INSTRUCTIONS.md`
- [ADDED] `20_Agents/IT-OPS-QAMaster/00_INSTRUCTIONS.md`
- [ADDED] `20_Agents/IT-OnOffBoarder/00_INSTRUCTIONS.md`
- [ADDED] `00_DOCS/META_TEMPLATE__Produit_IA_Vertical_v1.md` — scaffold réutilisable vertical AI
- [ADDED] `IT-SHARED/80_EXEMPLES/README.md`
- [MODIFIED] `00_INDEX/gpt_catalog.yaml` — instructions paths ajoutés pour 11 agents
- Blocs sécurité + RUNBOOKS GITHUB standardisés sur tous les agents

---

## [2026-05-19] — Initialisation du canal Factory Sync

- Création du dossier `00_FACTORY_SYNC/` et de sa structure
- Création de l'agent `IT-OPS-SyncFactory` (v1.0.0)
- Génération du premier `CURRENT_STATE.yaml` (32 agents actifs, 1 module staging)
- Création de `FACTORY_CONFIG__IT_Product_v1.md` pour injection dans agents Factory
- Canal Produit → Factory opérationnel

---
