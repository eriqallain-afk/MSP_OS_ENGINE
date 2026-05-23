# MSP Intelligence AI — Plateforme opérationnelle pour MSP

> **33 agents IA spécialisés** — conçus pour automatiser, structurer et accélérer toutes les opérations d'un Managed Service Provider.

---

## Ce que ça fait

MSP Intelligence AI couvre le cycle complet des opérations MSP : triage de tickets, support N1→N3, NOC, maintenance, sécurité, backup/DR, cloud, documentation client, rapports et conformité réglementaire. Les agents travaillent ensemble via un système de routing automatique et des playbooks multi-agents.

---

## Valeur ajoutée — Agents phares

### IT-OnOffBoarder — Transitions MSP complètes

**L'un des agents à plus haute valeur de la plateforme.**

Couvre les 4 scénarios de transition les plus chronophages en MSP :

| Scénario | Ce que l'agent fait |
|---|---|
| **Nouveau client MSP** | Découverte infra, baseline technique, déploiement outils RMM/EDR/Backup, SOC onboarding |
| **Départ client MSP** | Inventaire complet, révocation accès, handover propre, documentation remise |
| **Nouvel employé** | Création AD/M365, équipements, accès applicatifs, onboarding structuré |
| **Départ employé** | Révocation immédiate, récupération matériel, archivage données, audit accès |

**Valeur MSP concrète :**
- Un onboarding client prend normalement **12 heures** de travail technicien — réduit à **120 minutes** guidé par l'agent
- Zéro oubli sur les étapes critiques (accès MFA, Passportal, contrats NDA, baseline)
- Livrable Hudu directement généré à la fin de chaque transition
- Conforme aux exigences cyber-assurance (traçabilité d'accès, révocations documentées)

---

### IT-ComplianceMaster — Conformité réglementaire facturable

**L'agent qui transforme la conformité en revenu récurrent.**

Couvre 3 périmètres distincts sur 4 cadres réglementaires :

| Périmètre | Cadres couverts |
|---|---|
| **Client** | Loi 25 (Québec), PCI-DSS, HIPAA, cyber-assurance |
| **MSP sous-traitant** | Loi 25 sous-traitant de service, SOC 2 |
| **MSP chez le client** | Passportal, moindre privilège, trail d'audit, accès tiers |

**Valeur MSP concrète :**
- Rapports de conformité facturables (audit Loi 25, évaluation PCI, questionnaire cyber-assurance)
- Génère les preuves documentaires pour le renouvellement cyber-assurance client
- Détecte les écarts de conformité avant l'auditeur — le MSP devient le conseiller de référence
- Revenus additionnels estimés : 500–2 000 $/client/an en services de conformité facturés

---

## Les 33 agents — Vue d'ensemble

### Équipe OPS (5 agents — infrastructure interne)

| Agent | Rôle |
|---|---|
| `IT-OPS-RouterIA` | Point d'entrée — détecte l'intent, route vers le bon runbook |
| `IT-OPS-PlaybookRunner` | Exécute les playbooks step by step |
| `IT-OPS-DossierIA` | Archive chaque run, produit les livrables traçables |
| `IT-OPS-QAMaster` | Qualité plateforme — incidents, patterns, correctifs |
| `IT-OPS-SyncFactory` | Synchronisation produit → Factory |

### Équipe Métier (28 agents)

| Domaine | Agents |
|---|---|
| **Support** | IT-FrontLine, IT-Assistant-N2, IT-Assistant-N3 |
| **Infrastructure** | IT-SysAdmin, IT-TechOPS, IT-MaintenanceMaster, IT-NetworkMaster |
| **Sécurité & Conformité** | IT-SecurityMaster, **IT-ComplianceMaster** |
| **Backup & Cloud** | IT-BackupDRMaster, IT-CloudMaster |
| **Supervision** | IT-MonitoringMaster, IT-NOCDispatcher |
| **Commandement** | IT-Commandare-NOC, IT-Commandare-TECH, IT-Commandare-Infra, IT-Commandare-OPR |
| **Urgences** | IT-UrgenceMaster |
| **Transitions** | **IT-OnOffBoarder** *(IT-OnboardingMaster : legacy)* |
| **Documentation** | IT-ClientDocMaster, IT-TicketScribe, IT-KnowledgeKeeper |
| **Tickets & Rapports** | IT-TicketOpsAI, IT-ReportMaster |
| **Automatisation** | IT-ScriptMaster |
| **Assets & VoIP** | IT-AssetMaster, IT-VoIPMaster |
# MSP Intelligence AI — Platform

**Produit :** MSP Intelligence AI
**Produit par :** Factory EA|IA
**Domaine :** Opérations MSP (Managed Service Provider)
**Version :** 4.2
**Repo :** `eriqallain-afk/IT`

---

## Description

MSP Intelligence AI est une plateforme de **26 agents IA spécialisés** pour les opérations MSP. Elle automatise la gestion de tickets, les interventions terrain, le NOC, la maintenance, la sécurité et le reporting — directement intégrée dans ConnectWise Manage.

Le cœur du système est un **moteur d'auto-dispatch de runbooks** (`RUNBOOK_DISPATCH.yaml`) : l'agent détecte automatiquement le type de problème depuis le billet et charge le runbook opérationnel approprié sans commande manuelle.

---

## Architecture

```
Ticket / Alerte entrant
        ↓
IT-OPS-RouterIA        ← détecte l'intent, route
        ↓
Commandare approprié   ← orchestre la résolution
        ↓
Agent spécialiste      ← exécute avec runbook auto-dispatché
        ↓
IT-OPS-DossierIA       ← archive et produit les livrables
```

---

## Les 26 agents

### OPS — Moteur d'exécution (3)

| Agent | Rôle |
|---|---|
| `IT-OPS-RouterIA` | Point d'entrée — détecte l'intent, route vers agent/playbook |
| `IT-OPS-PlaybookRunner` | Exécute les playbooks step by step |
| `IT-OPS-DossierIA` | Archive chaque run, produit les livrables traçables |

### COMMANDARE — Orchestrateurs métier (4)

| Agent | Rôle |
|---|---|
| `IT-Commandare-NOC` | Alertes monitoring, gestion P1-P4 |
| `IT-Commandare-Infra` | Serveurs, DC, cloud |
| `IT-Commandare-TECH` | Troubleshooting, RCA |
| `IT-Commandare-OPR` | Gouvernance, changements |

### Terrain opérationnel (10)

| Agent | Rôle |
|---|---|
| `IT-FrontLine` | Premier contact client — triage N1 |
| `IT-Assistant-N2` | Support niveau 2 |
| `IT-Assistant-N3` | Support niveau 3 |
| `IT-TicketScribe` | Rédaction et documentation ConnectWise |
| `IT-MaintenanceMaster` | Patching, reboots, health checks |
| `IT-MonitoringMaster` | Supervision NOC, alertes |
| `IT-NOCDispatcher` | Dispatch NOC, escalades |
| `IT-UrgenceMaster` | Urgences P0/P1, gestion de crise |
| `IT-AssetMaster` | CMDB, inventaire |
| `IT-ClientDocMaster` | Documentation client (Hudu) |

### Infrastructure spécialisée (5)

| Agent | Rôle |
|---|---|
| `IT-CloudMaster` | Azure, M365, AWS, GCP |
| `IT-NetworkMaster` | Réseau, VLAN, VPN, WiFi |
| `IT-BackupDRMaster` | Veeam, Datto, Keepit |
| `IT-SecurityMaster` | SOC, EDR, incidents sécurité |
| `IT-SysAdmin` | Administration systèmes (Hyper-V, VMware, AD, SQL) |

### Gouvernance (4)

| Agent | Rôle |
|---|---|
| `IT-ScriptMaster` | Scripts PowerShell/Bash, automatisation |
| `IT-ReportMaster` | QBR, post-mortems, KPIs |
| `IT-VoIPMaster` | Téléphonie VoIP |
| `IT-KnowledgeKeeper` | Base de connaissance interne |

---

## Auto-dispatch de runbooks

Le système `00_INDEX/RUNBOOK_DISPATCH.yaml` (60 règles) détecte automatiquement le bon runbook depuis les données du billet ConnectWise :

```
Ticket reçu → matching patterns (sujet, description, type CW, sous-type, alerte)
           → Premier match par priorité → charge le runbook
           → Aucun match → menu /runbook (61 entrées) pour saisie manuelle
```

**60 règles couvrent :** Maintenance (8), Infra/AD/SQL/RDS/HyperV/Firewall (15), Cloud/M365 (5), Réseau/VPN (5), Backup/DR (4), Sécurité (3), Support (2), NOC (3), Monitoring (1).

---

## Playbooks actifs (10)

| Playbook | Usage |
|---|---|
| `INTAKE_ROUTE_EXECUTE` | Flux OPS standard |
| `IT_COMMANDARE_NOC` | Gestion alerte NOC |
| `IT_COMMANDARE_TECH` | Troubleshooting guidé |
| `IT_COMMANDARE_OPR` | Gouvernance et changements |
| `IT_CW_INTERVENTION_LIVE_CLOSE` | Intervention live → clôture CW |
| `IT_INCIDENT_TRIAGE` | Triage incident structuré |
| `IT_MSP_LIVE_ASSIST` | Assistance live technicien |
| `IT_MSP_TICKET_TO_KB` | Ticket → article base de connaissance |
| `IT_NOC_DISPATCH` | Dispatch NOC |
| `IT_NOC_HANDOFF` | Passation de quart NOC |

---

## Structure du repo

```
IT/
├── 20_Agents/          ← 33 agents (prompt, instructions, setup card, knowledge)
├── IT-SHARED/
│   ├── 10_RUNBOOKS/    ← Runbooks opérationnels par domaine
│   ├── 20_TEMPLATES/   ← Templates CW, email client, rapports, SOW
│   ├── 50_REFERENCE/   ← Guides de référence (Veeam, Azure, VLAN, etc.)
│   └── 60_BUNDLES/     ← Packs prêts à uploader dans GPT Editor
├── playbooks/          ← Workflows multi-agents (11 playbooks actifs)
├── 00_INDEX/           ← Index agents, intents, routing (87 intents couverts)
├── 00_FACTORY_SYNC/    ← Canal synchronisation produit → Factory
├── 99_STAGING/         ← Modules en préparation (MODULE_PROJETS)
└── scripts/
    └── validate_platform.sh  ← Validation plateforme en < 10 secondes
```

---

## Démarrage rapide

1. Ouvrir `20_Agents/{agent-id}/GPT_SETUP_CARD__{agent-id}_v1.md` — fiche de configuration complète
2. Copier `prompt.md` dans le champ Instructions du GPT Editor
3. Uploader le bundle correspondant depuis `IT-SHARED/60_BUNDLES/`
4. Lancer avec les conversation starters de la setup card

**Validation plateforme :**
```bash
bash scripts/validate_platform.sh
```

---

## Modules en développement

| Module | Statut | Description |
|---|---|---|
| **MODULE_PROJETS** | Staging (activation EA) | Pipeline ventes, estimation SOW, agent IT-ProjetSOW |

---

*MSP Intelligence AI v4.2 — 33 agents — eriqallain-afk/IT — 2026-05-19*
├── CLAUDE.md                    ← Lire en premier (lu automatiquement par Claude Code)
├── FACTORY_MANIFEST_IT.yaml     ← Source de vérité Factory
├── 00_INDEX/                    ← 7 fichiers d'index (agents, intents, routing, dispatch)
├── 00_DOCS/                     ← Documentation opérationnelle
├── 20_Agents/                   ← 26 agents (agent.yaml + prompt.md + contract.yaml)
├── IT-SHARED/
│   ├── 10_RUNBOOKS/             ← ~40 runbooks opérationnels
│   ├── 20_TEMPLATES/            ← 18 catégories de templates CW
│   ├── 30_SCRIPTS/              ← Scripts PowerShell/Bash
│   ├── 40_CHECKLISTS/           ← 13+ checklists
│   └── 60_BUNDLES/              ← 60+ bundles Knowledge Packs
├── playbooks/                   ← 10 playbooks actifs (playbooks.yaml)
├── 80_MACHINES/                 ← Hub routing local (26 routes)
└── 99_STAGING/                  ← Zone de validation avant activation
```

---

## Intégrations natives

| Système | Usage |
|---|---|
| ConnectWise Manage | Tickets, notes CW_DISCUSSION, dispatch, clôture |
| Azure AD / M365 | Gestion identités, compliance, Entra |
| Azure Cloud | Infrastructure cloud, ARM |
| N-able | RMM, monitoring, alertes |
| Datto | Backup BCDR, SIRIS |

---

## Sources de vérité

| Fichier | Rôle |
|---|---|
| `FACTORY_MANIFEST_IT.yaml` | Manifest officiel — lire avant toute création d'agent |
| `00_INDEX/agents_index.yaml` | Catalogue des 26 agents actifs |
| `00_INDEX/RUNBOOK_DISPATCH.yaml` | Moteur d'auto-dispatch (60 règles) |
| `00_INDEX/KNOWLEDGE_INDEX.yaml` | Mapping agent → Knowledge Pack |
| `CLAUDE.md` | Architecture et règles pour Claude Code |

---

*MSP Intelligence AI v4.2 — Produit par Factory EA|IA — 2026*
