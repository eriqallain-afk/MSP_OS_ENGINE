# CLAUDE.md — MSP Intelligence AI (Produit IT)

> Ce fichier est lu automatiquement par Claude Code à chaque session.
> Il décrit l'architecture complète du produit IT pour éviter toute improvisation.

---

## 1. IDENTITÉ DU PRODUIT

| Champ | Valeur |
|---|---|
| **Nom produit** | MSP Intelligence AI |
| **Code repo** | `eriqallain-afk/IT` |
| **Produit par** | Factory (repo `eriqallain-afk/Factory`) |
| **Version manifest** | 4.2 |
| **Responsable** | EA (validation manuelle obligatoire pour toute activation) |

MSP Intelligence AI est une plateforme de **33 agents IA** pour les opérations MSP (Managed Service Provider). Elle automatise la gestion de tickets, les interventions terrain, le NOC, la maintenance, la sécurité et le reporting.

---

## 2. STRUCTURE DU REPO

```
IT/
├── CLAUDE.md                    ← Ce fichier
├── FACTORY_MANIFEST_IT.yaml     ← Source de vérité du produit (lire avant toute création)
├── README.md
├── 00_DOCS/                     ← Documentation générale (voir section 9)
├── 00_INDEX/                    ← Index agents, intents, routing
│   ├── agents_index.yaml        ← Index officiel des agents actifs
│   ├── intents.yaml             ← Registre des intents couverts
│   └── MASTER_DISPATCH_INDEX_V2.yaml  ← Routing automatique intent → runbook (87 intents)
├── 00_QA/                       ← Qualité plateforme (géré par IT-OPS-QAMaster)
│   ├── incidents/               ← Incidents loggués par agents et techniciens
│   ├── scores/                  ← Dashboard qualité
│   └── fixes/                   ← Correctifs pending (EA) et applied
├── 20_Agents/                   ← Tous les agents (33 total)
├── IT-SHARED/                   ← Ressources partagées (runbooks, templates, checklists)
├── playbooks/                   ← Playbooks YAML d'exécution
│   └── playbooks.yaml
├── 80_MACHINES/                 ← Hub routing et config machines
│   └── hub_routing.yaml
├── 99_STAGING/                  ← Zone de staging (validation avant activation)
└── scripts/                     ← Scripts utilitaires
```

---

## 3. LES 33 AGENTS

### Équipe OPS (5 agents — infrastructure interne)

| Agent | Rôle |
|---|---|
| `IT-OPS-RouterIA` | Point d'entrée — détecte l'intent et route vers l'agent/playbook |
| `IT-OPS-PlaybookRunner` | Exécute les playbooks step by step |
| `IT-OPS-DossierIA` | Archive chaque run, produit les livrables traçables |
| `IT-OPS-QAMaster` | Qualité plateforme — incidents, patterns, correctifs, revue pre-activation |
| `IT-OPS-SyncFactory` | Synchronisation Produit → Factory — analyse les changements, génère les rapports de sync |

### Équipe Métier (28 agents)

| Agent | Domaine |
|---|---|
| `IT-FrontLine` | Premier contact client, triage tickets |
| `IT-Assistant-N2` | Support niveau 2 |
| `IT-Assistant-N3` | Support niveau 3 |
| `IT-SysAdmin` | Administration systèmes |
| `IT-TechOnsite` | Opérations techniques terrain |
| `IT-MaintenanceMaster` | Maintenance planifiée, patching |
| `IT-MonitoringMaster` | Supervision NOC, alertes |
| `IT-NetworkMaster` | Réseau, VLAN, VPN, WiFi |
| `IT-SecurityMaster` | Sécurité, incidents, compliance |
| `IT-BackupDRMaster` | Backup et reprise après sinistre |
| `IT-CloudMaster` | Infrastructure cloud |
| `IT-VoIPMaster` | Téléphonie VoIP |
| `IT-AssetMaster` | CMDB, gestion des actifs |
| `IT-ScriptMaster` | Automatisation, scripts PowerShell/Bash |
| `IT-TicketOpr` | Analyse et traitement intelligent des tickets |
| `IT-TicketScribe` | Rédaction et documentation tickets |
| `IT-NOCDispatcher` | Dispatch NOC, escalades |
| `IT-UrgenceMaster` | Urgences P0/P1, gestion de crise |
| `IT-Commandare-NOC` | Commandement NOC |
| `IT-Commandare-TECH` | Commandement technique |
| `IT-Commandare-Infra` | Commandement infrastructure |
| `IT-Commandare-OPR` | Commandement opérations |
| `IT-OnboardingMaster` | Découverte et onboarding client MSP (legacy — voir IT-OnOffBoarder) |
| `IT-OnOffBoarder` | Transitions MSP — onboarding/offboarding client et employé (4 scénarios) |
| `IT-ComplianceMaster` | Conformité réglementaire — Loi 25, PCI, HIPAA, cyber-assurance (3 périmètres) |
| `IT-ClientDocMaster` | Documentation client |
| `IT-ReportMaster` | Rapports et KPIs |
| `IT-KnowledgeKeeper` | Base de connaissance, documentation interne |

> **Total : 33 agents (5 OPS + 28 métier)**

---

## 4. STRUCTURE D'UN AGENT

```
20_Agents/{agent-id}/
├── agent.yaml               ← Identité, rôle, statut, version
├── prompt.md                ← System prompt complet
├── contract.yaml            ← Schéma inputs/outputs
├── 04_KNOWLEDGE_INDEX.md    ← Index de toutes les sources de connaissance
├── 05_KNOWLEDGE/            ← Fichiers de connaissance spécifiques
└── IT_{Agent}_KnowledgePack_v1/  ← Knowledge Pack structuré (si applicable)
```

---

## 5. RÈGLES ABSOLUES

> **Procédure canonique complète (création / modification / suppression) :**
> `00_DOCS/PROCEDURE_CREATION_AGENT_V1.md` — lire avant toute action sur un agent.

### Avant de créer un agent
1. **Lire `FACTORY_MANIFEST_IT.yaml`** en entier — source de vérité
2. **Vérifier `00_INDEX/agents_index.yaml`** — l'agent n'existe pas déjà ?
3. **Passer par `99_STAGING/`** — jamais d'activation directe sans validation EA
4. **Suivre `00_DOCS/PROCEDURE_CREATION_AGENT_V1.md`** — 20 étapes, 6 phases

### Avant de modifier un agent
1. Vérifier le `status` dans `agent.yaml` — ne jamais modifier un agent `archived`
2. Incrémenter la version dans `agent.yaml`
3. Mettre à jour `04_KNOWLEDGE_INDEX.md` si des fichiers de connaissance changent

### Après toute création ou modification
> **Consulter `00_INDEX/DOC_SYNC_MATRIX.md`** — ce fichier liste exactement quels
> documents doivent être mis à jour selon le type de changement effectué.
> Tout document non mis à jour doit être signalé en `next_actions` avec le préfixe `[DOC_SYNC]`.

### Conventions de nommage
- Agents : `IT-{NomCamelCase}` (ex. `IT-MaintenanceMaster`)
- OPS : `IT-OPS-{Nom}` (ex. `IT-OPS-RouterIA`)
- Knowledge Packs : `IT_{Agent}_KnowledgePack_v1/`
- Fichiers KP : `IT__{Sujet}.md` (double underscore)
- Playbooks : `IT_{DOMAINE}_{ACTION}` en majuscules (ex. `IT_MAINT_PATCH_REBOOT_VALIDATE`)

### Branches Git
- Branche de développement active : `claude/add-ticketops-ai-agent-gmUm4`
- Ne jamais pousser directement sur `main` sans PR
- `auto_activation: false` — validation EA obligatoire

---

## 6. IT-SHARED — Ressources communes

`IT-SHARED/` contient toutes les ressources partagées entre agents :

| Dossier | Contenu |
|---|---|
| `RUNBOOKS/` | Runbooks opérationnels (réseau, sécurité, maintenance, etc.) |
| `TEMPLATES/` | Templates CW_DISCUSSION, CW_NOTE_INTERNE, EMAIL_CLIENT |
| `CHECKLISTS/` | Checklists de validation par domaine |
| `REFERENCES/` | Documents de référence (VLAN standards, severity matrix, etc.) |
| `SCRIPTS/` | Scripts PowerShell/Bash réutilisables |
| `BUNDLES/` | Knowledge Pack bundles enrichis par agent |

Avant de créer un nouveau runbook/template/checklist, **vérifier que ça n'existe pas dans IT-SHARED**.

---

## 7. PLAYBOOKS

Les playbooks définissent les workflows multi-agents. Fichier principal : `playbooks/playbooks.yaml`.

Playbooks actifs (11) couvrent : patching, intervention live, dispatch NOC, onboarding client, security incident, backup validation, etc.

---

## 8. 00_QA — Système de qualité plateforme

Géré par `IT-OPS-QAMaster`. Tout technicien peut logguer un incident.

| Dossier | Contenu |
|---|---|
| `00_QA/incidents/[agent-id]/` | Incidents loggués — format `YYYY-MM-DD_type-court.md` |
| `00_QA/scores/quality_dashboard.yaml` | Score qualité par agent + plateforme globale |
| `00_QA/fixes/pending/` | Correctifs proposés par QAMaster — **en attente validation EA** |
| `00_QA/fixes/applied/` | Correctifs validés et appliqués |

Règle : **aucun correctif n'est appliqué sans validation EA explicite.**

---

## 9. 00_DOCS — Documentation générale

| Fichier | Contenu | Usage |
|---|---|---|
| `00_DOCS/CLAUDE_FACTORY.md` | CLAUDE.md de la Factory — à copier manuellement dans `eriqallain-afk/Factory` | Donne à Claude Code le contexte Factory (workflow 5 phases, 2 produits, règles qualité) |
| `00_DOCS/HOW_TO_CREATE_GPT.md` | Procédure de création d'un GPT ChatGPT depuis un agent | Référence pour déployer un agent sur la plateforme ChatGPT (GPT editor) |

> `CLAUDE_FACTORY.md` n'est **pas encore copié** dans le repo Factory — action manuelle requise par EA.

---

## 10. QUALITÉ ATTENDUE

- Les outputs agents doivent être **complets et directement utilisables** (pas "décrire ce qu'il faudrait faire")
- Les templates CW doivent inclure le contenu mot pour mot
- Les runbooks doivent avoir des commandes concrètes, pas des placeholders
- Toute erreur P0/P1 déclenche `IT-UrgenceMaster` avec format `🔴 P1 — Panne en cours — [CLIENT]`

---

*CLAUDE.md v2.1 — MSP Intelligence AI — Mis à jour le 2026-05-23*
