# MODULE_PROJETS — Spécification v1.0

> **STATUT : EN PRÉPARATION — Activation future par EA**
> Date de rédaction : 2026-05-19
> Auteur : Claude Code / Session Factory

---

## 1. Objectif du module

Le MODULE_PROJETS ferme la boucle entre le **service delivery MSP** et la **génération de revenus projets**.

Les agents terrain détectent quotidiennement des besoins de projets chez les clients (migrations, upgrades, sécurité, cloud, etc.) qui ne sont pas couverts par les contrats de service courants. Sans pipeline structuré, ces opportunités sont perdues ou traitées de façon informelle.

Le module introduit :
- Un **pipeline structuré** (`/ventes/`) pour capturer et tracer ces opportunités
- Une **commande unifiée** (`/escalade-ventes`) dans les agents terrain pour créer les entrées pipeline
- Un **agent dédié** (`IT-ProjetSOW`) pour analyser, estimer et rédiger les SOW facturables
- Un **flux de validation EA** avant toute soumission client

---

## 2. Composants du module

### 2.1 Agent — IT-ProjetSOW (staging)

Fichier : `99_STAGING/Draft/MODULE_PROJETS/IT-ProjetSOW/`

Responsabilités :
- Lire les opportunités dans `/ventes/opportunities/`
- Analyser les besoins, identifier les lacunes et risques
- Produire des estimations structurées (fourchettes avec hypothèses)
- Rédiger des SOW clients complets en 7 sections
- Préparer les soumissions clients (email + document)
- Gérer le pipeline (`/pipeline`, `/close`)

Commandes : `/lire`, `/analyser`, `/estimer`, `/sow`, `/soumettre`, `/pipeline`, `/close`

### 2.2 Pipeline ventes — /ventes/ (PRET)

Fichier : `ventes/` (racine du repo — structure permanente)

```
ventes/
├── README.md                 ← Documentation pipeline
├── SCHEMA_OPPORTUNITY.yaml   ← Schéma de référence pour les agents terrain
├── ACCESS_CONTROL.md         ← Permissions lecture/écriture par agent
├── opportunities/            ← Fichiers écrits par les agents terrain (via /escalade-ventes)
├── estimations/              ← Estimations générées par IT-ProjetSOW
└── approved/                 ← Projets approuvés par le client
```

### 2.3 Commande /escalade-ventes (A INTEGRER)

Template : `99_STAGING/Draft/MODULE_PROJETS/ESCALADE_VENTES_template.md`

Commande à ajouter dans les 10 agents terrain autorisés. Permet à chaque agent de créer un fichier `OPP-{CLIENT}-{DATE}.yaml` structuré dans `/ventes/opportunities/` lorsqu'un besoin de projet est détecté.

---

## 3. Agents autorisés — /escalade-ventes

Les 10 agents suivants recevront la commande `/escalade-ventes` lors de l'activation :

| Agent | Contexte de détection typique |
|---|---|
| `IT-FrontLine` | Triage initial — demandes hors support standard |
| `IT-Assistant-N2` | Analyse N2 — dégradation, dette technique |
| `IT-Assistant-N3` | Analyse N3 — incidents complexes, lacunes critiques |
| `IT-SysAdmin` | Audits systèmes — end-of-life, migrations requises |
| `IT-MaintenanceMaster` | Patching — infrastructure obsolète, upgrades majeurs |
| `IT-OnOffBoarder` | Onboarding/offboarding — lacunes `/gap` → opportunités |
| `IT-NetworkMaster` | Interventions réseau — redesign, VLAN, SD-WAN |
| `IT-SecurityMaster` | Audits sécurité — remédiation, compliance, EDR |
| `IT-BackupDRMaster` | Validations backup — PRA manquant, RTO/RPO non conformes |
| `IT-CloudMaster` | Provisioning cloud — migrations, M365, Azure |

---

## 4. Flux complet

```
[Agent terrain]
     │
     │ Détecte besoin projet pendant intervention / ticket / audit
     │
     ▼
/escalade-ventes
     │
     │ Crée ventes/opportunities/OPP-{CLIENT}-{DATE}.yaml
     │ (selon SCHEMA_OPPORTUNITY.yaml)
     │
     ▼
[IT-ProjetSOW]
     │
     ├─ /lire [OPP-id]      → Lecture et résumé
     ├─ /analyser [OPP-id]  → Besoins, lacunes, risques, portée
     ├─ /estimer [OPP-id]   → Estimation fourchette + hypothèses
     │                         → ventes/estimations/{OPP-id}_SOW.md
     └─ /sow [OPP-id]       → SOW complet 7 sections
          │
          ▼
     /soumettre [OPP-id]
          │
          │ ⚠️ VALIDATION EA OBLIGATOIRE (prix + contenu SOW)
          │
          ▼
     Soumission client (email + document)
          │
          ├─ Approuvé → ventes/approved/{OPP-id}_approved.yaml
          └─ Refusé  → /close [OPP-id] raison: refus_client
```

### Flux spécial — IT-OnOffBoarder → /ventes/

Quand IT-OnOffBoarder exécute un onboarding client :
1. La phase `/gap` identifie les lacunes infrastructure
2. La phase `/upgrade` produit un plan d'amélioration
3. Ces lacunes alimentent automatiquement une opportunité dans `/ventes/`
4. IT-ProjetSOW reçoit le handoff YAML d'IT-OnOffBoarder comme contexte additionnel

---

## 5. Ce qui est PRET maintenant

| Composant | Statut | Chemin |
|---|---|---|
| Structure `/ventes/` | PRET | `ventes/` |
| `SCHEMA_OPPORTUNITY.yaml` | PRET | `ventes/SCHEMA_OPPORTUNITY.yaml` |
| `ACCESS_CONTROL.md` | PRET | `ventes/ACCESS_CONTROL.md` |
| Agent IT-ProjetSOW (staging) | PRET — staging | `99_STAGING/Draft/MODULE_PROJETS/IT-ProjetSOW/` |
| Template `/escalade-ventes` | PRET — template | `99_STAGING/Draft/MODULE_PROJETS/ESCALADE_VENTES_template.md` |
| Spec module | PRET | Ce fichier |

---

## 6. Ce qui reste à faire avant activation

### Actions EA (validation / décision)

- [ ] Valider cette spec complète
- [ ] Valider les prix et processus SOW
- [ ] Décider du moment d'activation (sprint / release)

### Actions techniques (après validation EA)

- [ ] Ajouter `/escalade-ventes` dans les 10 agents terrain (prompts + agent.yaml)
  - Référence : `ESCALADE_VENTES_template.md`
  - Agents : FrontLine, N2, N3, SysAdmin, MaintenanceMaster, OnOffBoarder, NetworkMaster, SecurityMaster, BackupDRMaster, CloudMaster
- [ ] Créer templates SOW dans `IT-SHARED/20_TEMPLATES/`
  - `SOW_TEMPLATE.md`
  - `ESTIMATION_GUIDE.md`
  - `EMAIL_SOUMISSION_SOW.md`
- [ ] Déplacer `IT-ProjetSOW` de staging vers `20_Agents/IT-ProjetSOW/`
- [ ] Changer `status: staging` → `status: active` dans `agent.yaml`
- [ ] Mettre à jour `00_INDEX/agents_index.yaml` — ajouter IT-ProjetSOW (agent #33)
- [ ] Mettre à jour `FACTORY_MANIFEST_IT.yaml` — 32 → 33 agents
- [ ] Mettre à jour `00_INDEX/intents.yaml` — ajouter intents projet/sow/estimation
- [ ] Mettre à jour `00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` — routing ventes/projet
- [ ] Créer playbook `IT_VENTES_PROJET_SOW` dans `playbooks/playbooks.yaml`

### Tests avant activation

- [ ] Test end-to-end : IT-FrontLine → /escalade-ventes → IT-ProjetSOW → /sow → soumission
- [ ] Test flux IT-OnOffBoarder → /ventes/opportunities/
- [ ] Valider format YAML des opportunités vs SCHEMA_OPPORTUNITY.yaml
- [ ] Valider guardrails (pas de prix fixes, validation EA, pas de données sensibles)

---

## 7. Relation avec IT-OnOffBoarder

IT-OnOffBoarder est l'agent de transitions MSP (onboarding/offboarding client et employé). Il est le **principal fournisseur d'opportunités** pour IT-ProjetSOW :

- **Phase /gap** (onboarding) → Identifie les lacunes infrastructure du client entrant
- **Phase /upgrade** (onboarding) → Propose un plan d'amélioration chiffré
- Ces données sont directement converties en `OPP-{CLIENT}-{DATE}.yaml` dans `/ventes/`
- IT-ProjetSOW lit le handoff YAML d'IT-OnOffBoarder pour enrichir son analyse

Cette intégration évite la double saisie et garantit que chaque onboarding génère automatiquement une opportunité de projet tracée dans le pipeline.

---

## 8. Contraintes et garde-fous

- **Prix** : Jamais de montant fixe sans validation EA — toujours des fourchettes avec hypothèses
- **SOW client** : Langage non-technique, bénéfices business, zéro donnée technique sensible
- **Credentials / IPs / CVE** : Jamais dans les livrables clients
- **[À VALIDER]** : Tout champ non confirmé — jamais inventer
- **Activation** : `auto_activation: false` — EA valide manuellement chaque activation

---

*MODULE_PROJETS__SPEC_v1.md — MSP Intelligence AI — 2026-05-19*
