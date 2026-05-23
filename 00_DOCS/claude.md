# CLAUDE.md — FACTORY

> Ce fichier est lu automatiquement par Claude Code à chaque session dans le repo Factory.
> Il décrit l'architecture de la Factory, ses produits, et les règles de workflow obligatoires.

---

## 1. IDENTITÉ DE LA FACTORY

| Champ | Valeur |
|---|---|
| **Nom** | Factory — AI Agent Team Builder |
| **Repo** | `eriqallain-afk/Factory` |
| **Rôle** | Concevoir, produire et maintenir des équipes d'agents IA par domaine |
| **Responsable** | EA (validation manuelle obligatoire pour toute activation) |

La Factory est le système qui **produit** des produits. Chaque produit est une équipe d'agents IA spécialisée dans un domaine métier. Les produits sont ensuite déployés dans leur propre repo.

---

## 2. PRODUITS DE LA FACTORY

| Produit | Repo | Statut | Description |
|---|---|---|---|
| **MSP Intelligence AI** | `eriqallain-afk/IT` | ✅ Actif | Plateforme agents IA pour opérations MSP — 32 agents |
| **Marketing IA** | `eriqallain-afk/IT` (branche `PRODUCT__MARKETING_FACTORY_IA`) | 🔄 En développement | Équipe de gestion marketing IA — premier client : EA pour lancer MSP Intelligence AI |

---

## 3. STRUCTURE DE LA FACTORY

```
Factory/
├── CLAUDE.md                    ← Ce fichier
├── 00_INDEX/                    ← Index global tous produits
├── 10_FRAMEWORK/                ← Framework de conception d'agents
│   ├── agent_template/          ← Template de base pour tout nouvel agent
│   ├── contract_schema.yaml     ← Schéma standard des contrats
│   └── quality_rules.md        ← Règles de qualité obligatoires
├── 20_AGENTS/                   ← Agents Factory internes (OPS)
│   └── OPS/                     ← Orchestrateurs Factory
├── 30_PRODUCTS/                 ← Un dossier par produit
│   ├── IT/                      ← Manifest et suivi produit IT
│   └── MARKETING/               ← Manifest et suivi produit Marketing
└── 99_STAGING/                  ← Zone de validation avant livraison
```

---

## 4. WORKFLOW DE LA FACTORY — RÈGLES OBLIGATOIRES

⚠️ **PROBLÈME CONNU** : L'orchestrateur a tendance à traiter les étapes trop rapidement, sans validation intermédiaire. Ce CLAUDE.md corrige ce comportement.

### 4.1 Les 5 phases de production

```
Phase 1 — BRIEF & ANALYSE
  → Lire le manifest du produit cible EN ENTIER
  → Identifier les besoins réels (pas supposés)
  → Valider que l'agent/livrable n'existe pas déjà
  → STOP — attendre validation EA si périmètre flou

Phase 2 — CONCEPTION
  → Rédiger le profil complet de l'agent (rôle, intents, contraintes)
  → Définir les inputs/outputs dans le contrat (contract.yaml)
  → Identifier les dépendances avec les autres agents
  → STOP — validation EA avant de passer au prompt

Phase 3 — PRODUCTION
  → Rédiger le prompt complet (pas un squelette, un prompt opérationnel)
  → Rédiger le knowledge pack si applicable
  → Chaque livrable doit être UTILISABLE directement — pas de placeholders
  → STOP — auto-review qualité avant livraison

Phase 4 — VALIDATION
  → Vérifier la cohérence avec les autres agents du produit
  → Vérifier les conventions de nommage
  → Vérifier que le manifest est mis à jour
  → Soumettre en 99_STAGING pour validation EA

Phase 5 — ACTIVATION
  → Validation EA obligatoire (auto_activation: false)
  → Mise à jour de l'index officiel
  → PR vers main du repo produit
```

### 4.2 Règle fondamentale : QUALITÉ > VITESSE

- **Jamais** livrer un livrable incomplet pour aller vite
- **Jamais** inventer une information manquante — demander ou signaler le gap
- **Jamais** passer à la phase suivante sans que la précédente soit complète
- Si un step produit un output insuffisant → itérer, ne pas continuer

### 4.3 Validation entre phases

Avant de passer d'une phase à la suivante, répondre explicitement à :
1. Le livrable de cette phase est-il complet et utilisable ?
2. Y a-t-il des dépendances non résolues ?
3. Le manifest du produit est-il encore cohérent ?

---

## 5. CONVENTIONS DE NOMMAGE FACTORY

### Agents par produit
- Format : `{PRODUIT}-{NomCamelCase}` (ex. `IT-MaintenanceMaster`, `MKTG-CampaignMaster`)
- OPS Factory interne : `FACTORY-OPS-{Nom}`

### Fichiers
- Manifests produit : `FACTORY_MANIFEST_{PRODUIT}.yaml`
- Knowledge Packs : `{PRODUIT}_{Agent}_KnowledgePack_v1/`
- Templates : `TEMPLATE_{SUJET}_v{N}.md`

### Branches Git
- Nouvelles features : `claude/{description-courte}`
- Nouveaux produits : `PRODUCT__{NOM_PRODUIT}`
- Ne jamais pousser sur `main` sans PR + validation EA

---

## 6. PRODUIT EN DÉVELOPPEMENT — MARKETING IA

### Contexte
L'objectif est de concevoir une **Équipe de Gestion Marketing IA** produite par la Factory. Le premier client est EA lui-même pour lancer **MSP Intelligence AI** sur le marché.

### Agents prévus (à concevoir)

| Agent | Rôle |
|---|---|
| `MKTG-StrategistMaster` | Stratégie marketing, positionnement, messaging |
| `MKTG-ContentMaster` | Création de contenu (textes, posts, articles) |
| `MKTG-CampaignMaster` | Gestion des campagnes (planning, exécution, suivi) |
| `MKTG-BrandMaster` | Identité de marque, cohérence visuelle et tonale |
| `MKTG-AnalyticsMaster` | KPIs marketing, rapports de performance |
| `MKTG-SEOMaster` | SEO, mots-clés, optimisation contenu |

### Problème à résoudre pour ce produit
MSP Intelligence AI (produit IT) a besoin d'être lancé sur le marché. La stratégie marketing, le positionnement et les contenus doivent être produits par l'équipe Marketing IA.

---

## 7. RÈGLES D'OR FACTORY

1. **Lire le manifest avant tout** — `FACTORY_MANIFEST_{PRODUIT}.yaml` est la source de vérité
2. **99_STAGING obligatoire** — aucun agent ne va directement en production
3. **EA valide** — `auto_activation: false` sur tous les produits
4. **Qualité du prompt** — un prompt opérationnel, pas un squelette
5. **Pas de doublons** — vérifier l'index avant de créer
6. **Itérer si insuffisant** — ne jamais avancer avec un livrable incomplet

---

*CLAUDE.md Factory v1.0 — Généré le 2026-05-16*
