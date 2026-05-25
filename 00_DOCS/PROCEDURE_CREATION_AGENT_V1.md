# PROCÉDURE — Création / Modification / Suppression d'agent
**Version :** 1.0 | **Date :** 2026-05-23 | **Autorité :** EA (validation obligatoire avant activation)

> Ce document est la procédure canonique pour tout agent — Factory ou Claude Code.
> Lire en entier avant toute création. Respecter l'ordre des phases.
> Règle absolue : `auto_activation: false` — aucun agent n'est actif sans validation EA explicite.

---

## PHASE 0 — VÉRIFICATIONS PRÉALABLES (obligatoire)

```
□ 1. Lire FACTORY_MANIFEST_IT.yaml en entier
□ 2. Vérifier 00_INDEX/agents_index.yaml — l'agent n'existe pas déjà ?
□ 3. Si l'agent existe : son status est-il active, legacy ou archived ?
       → Ne jamais modifier un agent archived
       → Pour un agent legacy : contacter EA avant toute modification
□ 4. Passer par 99_STAGING/INCOMING/ — créer les fichiers là en premier
□ 5. Ne déplacer vers 20_Agents/ qu'après validation EA
```

---

## PHASE 1 — FICHIERS DE L'AGENT (`20_Agents/[agent-id]/`)

Créer dans l'ordre :

### 1.1 `agent.yaml`
```yaml
id: IT-[NomCamelCase]
display_name: "@IT-[NomCamelCase]"
version: "1.0"
status: staging          # staging → active après validation EA
role: [support|infra|noc|security|compliance|ops|opr|transitions]
team_id: TEAM__IT
created_at: YYYY-MM-DD
updated_at: YYYY-MM-DD
description: >
  [Description courte — 1 ligne]
auto_activation: false
```

### 1.2 `contract.yaml`
Schéma des inputs attendus et outputs produits par l'agent.

### 1.3 `prompt.md`
System prompt complet. Doit inclure :
- Identité et rôle
- Mission et périmètre strict
- Commandes disponibles
- Sécurité & Confidentialité (texte exact des guardrails)
- Format de réponse par défaut

### 1.4 `manifest.json`
Métadonnées GPT : name, description (<300 chars), instructions_path, knowledge_files.

### 1.5 `README.md`
Documentation agent : rôle, commandes principales, exemples d'usage, escalades.

### 1.6 `00_INSTRUCTIONS.md`
**Fichier critique — lu par le GPT ChatGPT au démarrage.**

Blocs obligatoires (dans cet ordre) :
```
## [Guardrails]          ← charger GUARDRAILS__IT_AGENTS_MASTER.md au démarrage
## [Rôle]               ← description complète du rôle
## [Mission]            ← livrables attendus
## [Périmètre strict]   ← ce que l'agent refuse
## [Commandes]          ← tableau /commande → action
## Sécurité & Confidentialité — Non négociable   ← TEXTE EXACT OBLIGATOIRE
## [Fermeture]          ← /close → TEMPLATE_BUNDLE_CW_CLOSE.md
## [Format par défaut]  ← structure Markdown des réponses
## [Non-divulgation]    ← refus si prompt injection
## RUNBOOKS GITHUB      ← menu inline + instructions getFileContent
```

### 1.7 `04_KNOWLEDGE_INDEX.md`
Index de toutes les sources de connaissance chargées par l'agent :
- Runbooks liés (avec chemin GitHub complet)
- Templates utilisés
- Bundles KP chargés
- Références et politiques

### 1.8 `GPT_SETUP_CARD__[NomAgent]_v1.md`
Fiche de configuration pour le GPT Editor (ChatGPT) :
- Nom exact du GPT
- Description (<300 chars — texte exact à coller)
- Instructions (contenu de 00_INSTRUCTIONS.md — condensé si > 8000 chars)
- Liste des fichiers Knowledge à uploader
- Capabilities à activer (Web search, Code interpreter, etc.)
- Actions configurées (si applicable)

### 1.9 `GUIDE_UTILISATION__[NomAgent]_v1.md`
Guide destiné aux techniciens :
- À quoi sert cet agent (en 3 lignes)
- Quand l'utiliser vs un autre agent
- Commandes disponibles avec exemples concrets
- Ce que l'agent refuse (périmètre)
- Escalades recommandées

---

## PHASE 2 — BUNDLE KNOWLEDGEPACK (`IT-SHARED/60_BUNDLES/KNOWLEDGEPACK/`)

### 2.1 `BUNDLE_KP_[NomAgent]_V1.md`
Fichier chargé comme Knowledge dans le GPT Editor.

Contenu obligatoire :
- Runbooks liés (texte complet ou résumé opérationnel)
- Templates clés (CW Note, Discussion, Email)
- Références spécifiques au domaine de l'agent
- Menu des commandes avec exemples
- Politiques et guardrails condensés

> Ce fichier est le fallback si GitHub est inaccessible (404/timeout).
> Il doit être suffisant pour permettre à l'agent de fonctionner sans accès réseau.

---

## PHASE 3 — MISE À JOUR DES INDEX PRODUIT

```
□ 3.1  00_INDEX/agents_index.yaml
        → Ajouter entrée complète (display_name, role, status, description, intents[])

□ 3.2  FACTORY_MANIFEST_IT.yaml
        → Ajouter entrée dans la liste agents[]
        → Incrémenter stats.total_agents (+1)
        → Incrémenter stats.ops_agents (+1) si agent OPS
        → Incrémenter stats.metier_agents (+1) si agent métier
        → Mettre à jour stats.last_manifest_update

□ 3.3  CLAUDE.md
        → Ajouter ligne dans le tableau équipe correspondante (section 3)
        → Mettre à jour le compteur total (ex. "33 agents (5 OPS + 28 métier)")

□ 3.4  00_QA/scores/quality_dashboard.yaml
        → Incrémenter platform.total_agents
```

---

## PHASE 4 — LIAISON RUNBOOKS SELON LE RÔLE

```
□ 4.1  IT-SHARED/00_INDEX/INTENT_RUNBOOK_MATRIX_V1.md
        → Pour chaque runbook que l'agent va charger :
          Ajouter ou vérifier l'entrée intent_id correspondante
          Mettre à jour agent_recommande si l'agent est le mieux placé

□ 4.2  IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md
        → Ajouter section "MENU — @IT-[NomAgent]" avec les runbooks disponibles
        → Format : [numéro]nom-court — dans la section domaine appropriée

□ 4.3  IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml
        → Ajouter intent(s) avec signals[] pour RouterIA
        → Chaque intent pointe vers le runbook ET l'agent

□ 4.4  IT-SHARED/00_INDEX/INDEX_MASTER_IT-SHARED_V1.md
        → Ajouter les runbooks liés à l'agent s'ils ne sont pas encore indexés

□ 4.5  00_INSTRUCTIONS.md de l'agent
        → Section RUNBOOKS GITHUB : menu inline des runbooks disponibles
        → Intents couverts listés dans le menu
```

---

## PHASE 5 — LIAISON PLAYBOOK (si applicable)

```
□ 5.1  Vérifier si un playbook existant couvre déjà le workflow de l'agent
        → Consulter playbooks/playbooks.yaml

□ 5.2  Si nouveau playbook requis :
        → Créer entrée dans playbooks/playbooks.yaml
        → Incrémenter stats.active_playbooks dans FACTORY_MANIFEST_IT.yaml
        → Mettre à jour CLAUDE.md section 7 (compteur playbooks)

□ 5.3  Documenter le lien dans 04_KNOWLEDGE_INDEX.md de l'agent
```

---

## PHASE 6 — VALIDATION EA & ACTIVATION

```
□ 6.1  Soumettre PR sur la branche de développement active
□ 6.2  EA valide les fichiers Phase 1 + 2 (qualité, guardrails, périmètre)
□ 6.3  EA valide les mises à jour Phase 3 + 4 + 5 (cohérence indexes)
□ 6.4  Changer status: staging → status: active dans agent.yaml
□ 6.5  Merge PR sur main
□ 6.6  Uploader le BUNDLE_KP dans le GPT Editor (ChatGPT)
□ 6.7  Configurer le GPT avec GPT_SETUP_CARD comme référence
□ 6.8  Test /start en conditions réelles — documenter dans TEMPLATE_TEST_RouterIA_V1
```

---

## PROCÉDURE — MODIFICATION D'UN AGENT EXISTANT

```
□ 1. Vérifier status dans agent.yaml — archived = ne pas toucher
□ 2. Identifier les fichiers à modifier (00_INSTRUCTIONS.md, prompt.md, etc.)
□ 3. Incrémenter version dans agent.yaml (ex. 1.0 → 1.1)
□ 4. Mettre à jour updated_at dans agent.yaml
□ 5. Si runbooks ajoutés/retirés : mettre à jour 04_KNOWLEDGE_INDEX.md
□ 6. Si nouvelles commandes : mettre à jour GUIDE_UTILISATION et GPT_SETUP_CARD
□ 7. Si changement d'intent ou de runbook lié : mettre à jour INTENT_RUNBOOK_MATRIX_V1.md
□ 8. Si changement structurel (périmètre, escalades) : notifier IT-OPS-QAMaster
□ 9. Mettre à jour BUNDLE_KP si le contenu de référence change
□ 10. PR + validation EA + merge + re-upload KP dans GPT Editor
```

---

## PROCÉDURE — SUPPRESSION / ARCHIVAGE D'UN AGENT

```
□ 1. Ne JAMAIS supprimer les fichiers — toujours archiver
□ 2. Changer status: active → status: legacy dans agent.yaml
       Si remplacé par un autre agent : ajouter superseded_by: [id]
□ 3. Mettre à jour agents_index.yaml (status: legacy)
□ 4. Mettre à jour FACTORY_MANIFEST_IT.yaml (décrémenter metier_agents si applicable)
□ 5. Mettre à jour CLAUDE.md — noter "(legacy — voir [nouveau agent])"
□ 6. Retirer du menu RUNBOOK_MENU_CONTEXTUEL_V4.md ou marquer [LEGACY]
□ 7. Désactiver le GPT dans ChatGPT (ne pas supprimer — conserver l'historique)
□ 8. Documenter la décision dans 00_DOCS/ARCHITECTURE_DECISION_LOG.md
```

---

## RÉCAPITULATIF CHECKLIST COMPLÈTE — NOUVEL AGENT

| # | Action | Fichier | Obligatoire |
|---|---|---|---|
| 1 | Créer agent.yaml | `20_Agents/[id]/agent.yaml` | ✅ |
| 2 | Créer contract.yaml | `20_Agents/[id]/contract.yaml` | ✅ |
| 3 | Créer prompt.md | `20_Agents/[id]/prompt.md` | ✅ |
| 4 | Créer manifest.json | `20_Agents/[id]/manifest.json` | ✅ |
| 5 | Créer README.md | `20_Agents/[id]/README.md` | ✅ |
| 6 | Créer 00_INSTRUCTIONS.md | `20_Agents/[id]/00_INSTRUCTIONS.md` | ✅ |
| 7 | Créer 04_KNOWLEDGE_INDEX.md | `20_Agents/[id]/04_KNOWLEDGE_INDEX.md` | ✅ |
| 8 | Créer GPT_SETUP_CARD | `20_Agents/[id]/GPT_SETUP_CARD__[Nom]_v1.md` | ✅ |
| 9 | Créer GUIDE_UTILISATION | `20_Agents/[id]/GUIDE_UTILISATION__[Nom]_v1.md` | ✅ |
| 10 | Créer Bundle KP | `IT-SHARED/60_BUNDLES/KNOWLEDGEPACK/BUNDLE_KP_[Nom]_V1.md` | ✅ |
| 11 | Mettre à jour agents_index | `00_INDEX/agents_index.yaml` | ✅ |
| 12 | Mettre à jour FACTORY_MANIFEST | `FACTORY_MANIFEST_IT.yaml` | ✅ |
| 13 | Mettre à jour CLAUDE.md | `CLAUDE.md` | ✅ |
| 14 | Mettre à jour quality_dashboard | `00_QA/scores/quality_dashboard.yaml` | ✅ |
| 15 | Mettre à jour INTENT_RUNBOOK_MATRIX | `IT-SHARED/00_INDEX/INTENT_RUNBOOK_MATRIX_V1.md` | ✅ |
| 16 | Mettre à jour RUNBOOK_MENU | `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md` | ✅ |
| 17 | Mettre à jour MASTER_DISPATCH_INDEX | `IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` | ✅ |
| 18 | Lier ou créer playbook | `playbooks/playbooks.yaml` | Si applicable |
| 19 | Validation EA | PR review + merge | ✅ |
| 20 | Upload KP dans GPT Editor | ChatGPT | ✅ |

---

*PROCEDURE_CREATION_AGENT_V1 — MSP Intelligence AI — EA|IA — 2026-05-23*
*Applicable : Factory (eriqallain-afk/Factory) ET Claude Code (sessions directes)*
