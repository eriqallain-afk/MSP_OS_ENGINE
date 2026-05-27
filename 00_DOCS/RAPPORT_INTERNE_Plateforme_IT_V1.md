# RAPPORT INTERNE — Plateforme MSP Intelligence AI
**Version :** 1.0 | **Date :** 2026-05-23 | **Statut :** ACTIF
**Produit :** MSP Intelligence AI | **Repo :** `eriqallain-afk/IT`
**Destinataire :** EA (Product Owner) | **Classification :** Confidentiel

---

## TABLE DES MATIÈRES

1. [Synthèse exécutive](#1-synthèse-exécutive)
2. [Architecture plateforme](#2-architecture-plateforme)
3. [Inventaire complet des 33 agents](#3-inventaire-complet-des-33-agents)
4. [Couverture des domaines](#4-couverture-des-domaines)
5. [État des gammes commerciales](#5-état-des-gammes-commerciales)
6. [Décisions d'architecture en attente](#6-décisions-darchitecture-en-attente)
7. [Métriques plateforme](#7-métriques-plateforme)
8. [Actions prioritaires et next steps](#8-actions-prioritaires-et-next-steps)

---

## 1. SYNTHÈSE EXÉCUTIVE

MSP Intelligence AI est une plateforme de 33 agents IA spécialisés couvrant l'ensemble des opérations d'un MSP (Managed Service Provider). Les agents couvrent le support N1 à N3, l'infrastructure serveur et cloud, le NOC, la maintenance planifiée, la sécurité, la conformité réglementaire et les opérations documentaires.

### État à la date du rapport

| Indicateur | Valeur | Note |
|---|---|---|
| Agents actifs | 32 | 1 legacy (IT-OnboardingMaster) |
| Agents en staging | 2 | IT-UpdaterMaster, MODULE_PROJETS |
| Intents couverts | 87 | Via MASTER_DISPATCH_INDEX_V2.yaml |
| Runbooks validés | 123 | Dans IT-SHARED/10_RUNBOOKS/ |
| Templates | 90 | Dans IT-SHARED/20_TEMPLATES/ |
| Scripts PowerShell | 24 | Dans IT-SHARED/30_SCRIPTS/ |
| Playbooks actifs | 26 | Dans playbooks/playbooks.yaml |
| Score qualité plateforme | Non calculé | Aucun incident loggué à ce jour |
| Décisions architecture pendantes | 2 ADR actives | ADR-011, ADR-012 |

### Points d'attention prioritaires

1. **RouterIA — test en conditions réelles requis** : le merge PR#53 sur `main` (2026-05-22) a consolidé la matrix intents avec les 11 runbooks WKS et les 4 intents compliance. Les tests valides sur 5-10 cas réels n'ont pas encore été effectués. Ce résultat conditionne l'architecture Pro/MSP (ADR-012).
2. **Commandare-Compliance — à créer** : le 5e agent Commandare (ComplianceMaster + SecurityMaster + ReportMaster) est identifié dans ADR-011 mais non encore construit.
3. **IT-OPS-SyncFactory — sync Factory non encore effectuée** : le CLAUDE.md Factory n'a pas encore été copié dans le repo `eriqallain-afk/Factory`.
4. **Experts chevronnés (ADR-012) — construction suspendue** : 6 agents IT-Expert-* identifiés mais construction bloquée en attente des résultats RouterIA.

---

## 2. ARCHITECTURE PLATEFORME

### 2.1 Schéma des couches

```
┌─────────────────────────────────────────────────────────────────────┐
│                      COUCHE OPS (infrastructure plateforme)          │
│  Jamais exposés directement aux techniciens                          │
│                                                                       │
│  IT-OPS-RouterIA          ← Point d'entrée — détecte l'intent        │
│  IT-OPS-PlaybookRunner    ← Exécute les playbooks step by step       │
│  IT-OPS-DossierIA         ← Archive chaque run                       │
│  IT-OPS-QAMaster          ← Qualité plateforme                       │
│  IT-OPS-SyncFactory       ← Sync Produit → Factory                   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ route + runbook injecté
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    COUCHE MÉTIER (28 agents)                          │
│                                                                       │
│  SUPPORT (4)         INFRA (6)           NOC (3)                     │
│  FrontLine           SysAdmin            NOCDispatcher               │
│  Assistant-N2        TechOPS             MonitoringMaster            │
│  Assistant-N3        CloudMaster         UrgenceMaster               │
│  TicketOpsAI         MaintenanceMaster                               │
│                      BackupDRMaster      SÉCURITÉ (2)                │
│                      NetworkMaster       SecurityMaster              │
│                                          ComplianceMaster            │
│  COMMANDARE (4)      OPR (6)                                         │
│  Commandare-Infra    TicketScribe        LEGACY (1)                  │
│  Commandare-NOC      KnowledgeKeeper     OnboardingMaster            │
│  Commandare-TECH     ReportMaster                                    │
│  Commandare-OPR      AssetMaster                                     │
│                      ClientDocMaster                                 │
│                      OnOffBoarder                                    │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │ chargent dynamiquement via getFileContent
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    COUCHE RESSOURCES PARTAGÉES                        │
│                    IT-SHARED/                                         │
│                                                                       │
│  10_RUNBOOKS/   ← 123 runbooks (INFRA, MAINT, SUPPORT, NOC, SEC,    │
│                    OPR, WKS)                                          │
│  20_TEMPLATES/  ← 90 templates (CW, COM, maintenance, KB, rapports, │
│                    sécurité...)                                       │
│  30_SCRIPTS/    ← 24 scripts PowerShell (Out-String -Width 300       │
│                    standard RMM — ADR-002)                            │
│  40_CHECKLISTS/ ← Checklists de validation par domaine               │
│  50_REFERENCE/  ← VLAN standards, severity matrix, références        │
│  60_BUNDLES/    ← Knowledge Pack bundles enrichis                    │
│  70_KNOWLEDGE/  ← Fichiers de connaissance partagés                  │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    COUCHE ORCHESTRATION                               │
│                                                                       │
│  playbooks/playbooks.yaml   ← 26 playbooks multi-agents              │
│  00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml ← 87 intents → runbooks      │
│  00_INDEX/intents.yaml      ← Registre des intents                   │
│  80_MACHINES/hub_routing.yaml ← Routing machines                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Principe de routing (ADR-010)

Le **RouterIA** est le point d'entrée de toute interaction. Il :
1. Détecte l'intent via `MASTER_DISPATCH_INDEX_V2.yaml` (87 intents couverts)
2. Résout le chemin du runbook via `INTENT_RUNBOOK_MATRIX_V1.md`
3. Charge le runbook via `getFileContent` et l'injecte dans la réponse de l'agent métier

**Conséquence critique (ADR-010)** : un runbook non enregistré dans la matrix est opérationnellement inexistant — le RouterIA ne peut pas le trouver. La mise à jour de la matrix est bloquante, pas documentaire.

### 2.3 Conventions de qualité actives

| ADR | Titre | Impact |
|---|---|---|
| ADR-001 | Séparation IT-SHARED / 20_Agents / playbooks | Architecture fondamentale |
| ADR-002 | `Out-String -Width 300 \| Write-Output` obligatoire RMM | Tous scripts PowerShell |
| ADR-003 | Scripts PRECHECK et POSTCHECK unifiés (un seul bloc) | Runbooks infra |
| ADR-004 | Architecture 2-phases MAINT-WIN-PendingReboot | Routing selon rôle serveur |
| ADR-005 | LastBoot/Uptime obligatoires dans tout PRECHECK/POSTCHECK | Traçabilité SLA |
| ADR-006 | Contenu script toujours inline (jamais chemin fichier) | 5 agents concernés |
| ADR-007 | "Raison de l'étape suivante" obligatoire | Tous agents opérationnels |
| ADR-008 | Framework prompting 4 couches (Output Policy) | Standard tous nouveaux agents |
| ADR-009 | Runbooks WKS dans SUPPORT/WKS/ | 11 runbooks, convention SUP-WKS- |
| ADR-010 | Mise à jour INTENT_RUNBOOK_MATRIX obligatoire et bloquante | Tout ajout de runbook |

---

## 3. INVENTAIRE COMPLET DES 33 AGENTS

### 3.1 Agents OPS (5) — Infrastructure plateforme

> Ces 5 agents ne sont jamais exposés directement aux techniciens. Ils constituent l'infrastructure d'exécution de la plateforme.

| ID | Rôle | Statut | Description | Fonctions clés |
|---|---|---|---|---|
| `IT-OPS-RouterIA` | Point d'entrée | `active` | Détecte l'intent entrant, résout le runbook via MASTER_DISPATCH_INDEX_V2.yaml, route vers l'agent métier en injectant le runbook | 87 intents couverts, routing Discovery-first si rôle serveur non confirmé |
| `IT-OPS-PlaybookRunner` | Exécuteur playbooks | `active` | Déroule les playbooks step by step, assemble les handoffs inter-agents | 26 playbooks actifs |
| `IT-OPS-DossierIA` | Archivage | `active` | Archive chaque run, produit les livrables traçables, packaging dossier client | Traçabilité complète par intervention |
| `IT-OPS-QAMaster` | Qualité plateforme | `active` | Analyse incidents 00_QA/, détecte patterns systémiques, propose correctifs soumis à EA, revue pre-activation des nouveaux agents | Dashboard `00_QA/scores/quality_dashboard.yaml` |
| `IT-OPS-SyncFactory` | Sync Factory | `active` | Monitore les changements structurels du produit, génère rapports outbox FACTORY_SYNC pour l'agent Factory | Sync Produit → `eriqallain-afk/Factory` |

---

### 3.2 Agents SUPPORT (4)

| ID | Rôle | Statut | Description | Commandes clés | Runbooks clés |
|---|---|---|---|---|---|
| `IT-FrontLine` | Premier contact, triage N1 | `active` | Premier contact client — réception billets MSPBOT ou appel, triage guidé, escalade si hors scope | `/start`, `/triage`, `/escalade`, `/close` | SUP-N1N2-SupportTriage_V2, SUP-OPS-CW_Dispatch_V2, SUP-WKS-* (11) |
| `IT-Assistant-N2` | Mentorat N2 | `active` | Guide les techniciens N1/N2 étape par étape en support téléphonique, garde-fous hors-scope, message chef d'équipe | `/chef`, `/escalade`, `/plan` | SUP-N2-Support_V2, runbooks WKS |
| `IT-Assistant-N3` | Analyse technique avancée | `active` | Incidents complexes, diagnostic multi-domaines, architecture, scripts PowerShell inline (compatibles RMM) | `/diagnostic`, `/script`, `/rca` | Tous runbooks INFRA, SUPPORT, SEC |
| `IT-TicketOpr` | Cycle complet ticket | `active` | Triage, analyse, clôture CW, mémo Teams, rapports, vérification scripts, analyse risques — cycle complet ticket MSP | `/start`, `/analyse`, `/script`, `/close`, `/risques`, `/rapport-client`, `/rapport-coordo`, `/kb-check` | SUP-OPS-CW_InterventionLive_Close_V2, SUP-OPS-TicketToKB_V2 |

---

### 3.3 Agents INFRASTRUCTURE (6)

| ID | Rôle | Statut | Description | Commandes clés | Runbooks clés |
|---|---|---|---|---|---|
| `IT-SysAdmin` | Administration systèmes | `active` | Serveurs, AD, Hyper-V, VMware, Veeam, SentinelOne, CVE, firewalls, patching, M365, Azure, Linux — généraliste senior | Scripts inline RMM obligatoires | INFRA-AD-DC_Operations_V3, INFRA-SRV-HyperV_Operations_V2, INFRA-SRV-SQL_PrePost_Validation_V2, MAINT-WIN-PendingReboot_V2 |
| `IT-TechOnsite` | Opérations terrain | `active` | Déploiement postes, remplacement hardware, migration logicielle, déménagement, config périphériques. Precheck/postcheck systématiques | `/precheck`, `/postcheck`, `/deploy` | INFRA-SRV-HealthCheck_Template_V1, SUP-WKS-Onboarding_Poste_V1 |
| `IT-CloudMaster` | Cloud / M365 | `active` | Azure, Exchange Online, Intune, Teams, SharePoint, OneDrive — gestion complète tenant M365 | `/diagnostic`, `/remediation` | INFRA-M365-UserManagement_V2, INFRA-M365-Exchange_Online_V2, INFRA-M365-Intune_Devices_V2, INFRA-M365-Teams_SharePoint_OneDrive_V2 |
| `IT-MaintenanceMaster` | Maintenance planifiée | `active` | Patching Windows planifié, snapshots, prechecks, postchecks, rapports maintenance. Standard CW RMM | `/precheck`, `/patch`, `/postcheck`, `/rapport` | MAINT-WIN-Patching_CW-RMM_V3, MAINT-WIN-Patching_Complet_V3, MAINT-SRV-AuditTrimestriel_V2 |
| `IT-BackupDRMaster` | Backup / DR | `active` | Veeam, Datto, Keepit, Veeam Cloud — validation jobs, restauration, tests DR, conformité rétention | `/validation`, `/restore`, `/dr-test` | NOC-BACKUP-Veeam_Operations_V2, NOC-BACKUP-Datto_Operations_V2, NOC-BACKUP-DR_Test_V2, NOC-BACKUP-DR_Plan_Validation_V2 |
| `IT-NetworkMaster` | Réseau | `active` | LAN/WAN, Firewall (Fortinet, Meraki, SonicWall, WatchGuard, UniFi, MikroTik), WiFi, VPN infrastructure | `/diagnostic`, `/config`, `/vlan` | INFRA-NET-Fortinet_Operations_V2, INFRA-NET-Meraki_Operations_V2, INFRA-NET-SonicWall_Operations_V2, INFRA-NET-NetworkDiagnostic_V2 |

---

### 3.4 Agents NOC (3)

| ID | Rôle | Statut | Description | Commandes clés | Runbooks clés |
|---|---|---|---|---|---|
| `IT-NOCDispatcher` | Dispatch NOC | `active` | Premier point de qualification des alertes et tickets entrants — prioritisation, assignation, SLA, escalade | `/qualif`, `/dispatch`, `/sla`, `/escalade` | NOC-OPS-Dispatch_V2, NOC-OPS-FrontDoor_V2, RUNBOOK__IT_MSP_CONNECTWISE_DISPATCH_V1 |
| `IT-MonitoringMaster` | Supervision NOC | `active` | Supervision IT via RMM (N-able principalement), analyse alertes RMM, CW Automate, Auvik | `/analyse-alerte`, `/diagnostic-rmm` | NOC-RMM-NAble_Operations_V2, NOC-RMM-CWRMM_Auvik_Operations_V2, NOC-OPS-CommandCenter_V2 |
| `IT-UrgenceMaster` | Urgences P0/P1 | `active` | Gestion de crise P1/P2 en temps réel — qualification urgence, go/no-go, notice Teams, escalade, communications live | `/go-nogo`, `/notice`, `/escalade-p1` | NOC-OPS-IncidentCommand_V2, MAINT-SRV-PostShutdown_Electrical_V2 |

---

### 3.5 Agents SÉCURITÉ (2)

| ID | Rôle | Statut | Description | Commandes clés | Runbooks clés |
|---|---|---|---|---|---|
| `IT-SecurityMaster` | Cybersécurité / SOC | `active` | Incidents cyber, SIEM, EDR, forensics, threat hunting, hardening, audit sécurité, incident response | `/triage-soc`, `/containment`, `/forensics`, `/audit` | SEC-SECU-IncidentResponse_V3, SEC-SECU-AlertResponse_V2, SEC-SECU-SecurityAudit_V2 |
| `IT-ComplianceMaster` | Conformité réglementaire | `active` | 3 périmètres : client (Loi 25, PCI-DSS, HIPAA, cyber-assurance), MSP interne (Loi 25, SOC 2), MSP chez client (moindre privilège, trail). Audit 5 piliers. | `/audit`, `/rapport-compliance`, `/remediation` | SEC-COMPLIANCE-5Piliers_Framework_V1, SEC-ENTRA-SecurityCompliance_V1, SEC-M365-Compliance_Purview_V2, SEC-PURVIEW-ComplianceAudit_V1 |

---

### 3.6 Agents COMMANDARE (4) — Staging, valeur réelle avec Claude API

> Les Commandare sont des agents de fusion cross-domaine. Sur ChatGPT, ils consolident le raisonnement multi-domaine sans vraie orchestration inter-agents. Leur valeur réelle est avec Claude API (orchestration native). Statut : actifs dans le repo, mais en staging pratique.

| ID | Rôle | Statut | Domaines couverts | Runbooks clés |
|---|---|---|---|---|
| `IT-Commandare-Infra` | Orchestration infra | `active` | SysAdmin + CloudMaster + NetworkMaster + VoIPMaster — incidents infra complexes | Tous runbooks INFRA |
| `IT-Commandare-NOC` | Orchestration NOC | `active` | MaintenanceMaster + BackupDRMaster + MonitoringMaster + NOCDispatcher + UrgenceMaster | Tous runbooks NOC + MAINT |
| `IT-Commandare-TECH` | Orchestration support technique | `active` | FrontLine + N2 + N3 + TechOPS + ScriptMaster — support N1-N3 + SOC | SUP-OPS-CommandareTech_V1 |
| `IT-Commandare-OPR` | Orchestration opérations | `active` | ReportMaster + AssetMaster + ClientDocMaster + KnowledgeKeeper + OnOffBoarder + TicketScribe | SUP-OPS-CommandareOPR_V1 |

---

### 3.7 Agents OPR / OPÉRATIONS (6)

| ID | Rôle | Statut | Description | Commandes clés | Runbooks clés |
|---|---|---|---|---|---|
| `IT-TicketScribe` | Rédaction CW | `active` | Rédaction professionnelle CW Notes, discussions client, emails, documentation CW — livrables copiables directement | `/note-interne`, `/discussion`, `/email` | SUP-OPS-CW_InterventionLive_Close_V2 |
| `IT-KnowledgeKeeper` | Base de connaissance | `active` | Transformation incidents résolus en articles KB Hudu, détection patterns récurrents, suggestion intents → QAMaster | `/capitalise`, `/search-kb`, `/suggest-intent` | SUP-OPS-TicketToKB_V2, OPR-ProblemManagement-CAPA_V1 |
| `IT-ReportMaster` | Rapports et KPIs | `active` | QBR, postmortem, rapport mensuel, KPIs client — livrables facturables | `/qbr`, `/postmortem`, `/mensuel`, `/kpi` | OPR-QBR-DataCollection_V1, OPR-PostIncident-Review-P1P2_V1, OPR-Monthly-Client-OpsPack_V1 |
| `IT-AssetMaster` | CMDB / Actifs | `active` | Gestion CMDB, licences, inventaire actifs, réconciliation CW-Hudu-RMM | `/inventaire`, `/audit-cmdb`, `/reconciliation` | MAINT-OPS-CMDB_AssetAudit_V1, OPR-CMDB-Reconciliation-CW-Hudu-RMM_V1 |
| `IT-ClientDocMaster` | Documentation client | `active` | Fiches client Hudu, edocs, documentation opérationnelle structurée | `/fiche-client`, `/edoc`, `/hudu` | OPR-ClientCommunication-Cadence_V1 |
| `IT-OnOffBoarder` | Transitions MSP | `active` | 4 scénarios : nouveau client (découverte infra, SOC, outils), départ client (inventaire, révocation), nouvel employé (AD, M365, équipements), départ employé (révocation, récupération) | `/onboard-client`, `/offboard-client`, `/onboard-employe`, `/offboard-employe` | INFRA-M365-UserOnboarding_V2, SUP-WKS-Offboarding_V1, SUP-WKS-Onboarding_Poste_V1 |

---

### 3.8 Agent LEGACY (1)

| ID | Rôle | Statut | Note |
|---|---|---|---|
| `IT-OnboardingMaster` | Onboarding client (legacy) | `legacy` | Remplacé par IT-OnOffBoarder (scénario `nouveau_client`). Conserver pour référence — ne pas modifier. Superseded_by : IT-OnOffBoarder |

---

### 3.9 Agents en STAGING (non encore activés)

| ID | Dossier | Description |
|---|---|---|
| `IT-UpdaterMaster` *(draft)* | 99_STAGING/Draft/ | Agent de mise à jour plateforme — périmètre exact à définir |
| `MODULE_PROJETS` *(draft)* | 99_STAGING/Draft/ | Module gestion de projets / SOW — spec v1 disponible, playbook IT_PROJET_SOW actif |

> Règle absolue : aucun agent de staging ne peut être activé sans validation EA explicite.

---

## 4. COUVERTURE DES DOMAINES

### 4.1 Domaines bien couverts

| Domaine | Niveau de couverture | Justification |
|---|---|---|
| **Support N1-N3** | Fort | 4 agents dédiés (FrontLine, N2, N3, TicketOpsAI) + 11 runbooks WKS + routing complet. Cycle ticket complet du triage à la clôture KB |
| **Maintenance / Patching** | Fort | MaintenanceMaster + runbooks V3 (CW RMM, WSUS, PendingReboot 2-phases). Standard precheck/postcheck unifié (ADR-003/004/005) |
| **Backup / DR** | Fort | BackupDRMaster couvre Veeam, Datto, Keepit, Veeam Cloud. 9 runbooks NOC-BACKUP dédiés incluant DR_Plan_Validation et Restore_Test |
| **Réseau** | Fort | NetworkMaster couvre 6 constructeurs firewall (Fortinet, Meraki, SonicWall, WatchGuard, UniFi, MikroTik). Runbooks V2 pour chacun |
| **M365 / Azure** | Fort | CloudMaster + runbooks V2 couvrant Exchange, Intune, Teams/SharePoint, UserManagement, UserOnboarding |
| **Compliance** | Bien couvert | ComplianceMaster — 3 périmètres, 5 piliers, Loi 25/PCI/HIPAA/cyber-assurance. 5 runbooks SEC dédiés + Entra/Purview |
| **Opérations documentaires** | Fort | TicketScribe + KnowledgeKeeper + ReportMaster + ClientDocMaster. Templates CW complets (16 catégories) |
| **Transitions MSP** | Fort | OnOffBoarder couvre 4 scénarios complets — supersède l'ancien OnboardingMaster |

### 4.2 Domaines à couverture légère ou en construction

| Domaine | Niveau actuel | Lacune identifiée |
|---|---|---|
| **VoIP / UC** | Léger | IT-VoIPMaster actif dans l'index, mais non listé dans l'inventaire principal CLAUDE.md. 1 seul runbook (INFRA-VOIP-Diagnostic_V2). Couverture limitée aux diagnostics de base |
| **Commandare (fusion cross-domaine)** | Partiel | 4 Commandare existent mais leur valeur est conditionnelle à Claude API. Sur ChatGPT sans orchestration native, la fusion est un compromis. Commandare-Compliance manquant |
| **ScriptMaster** | Agent présent, sous-utilisé | IT-ScriptMaster actif mais absent des playbooks principaux comme acteur direct. Capacité scripting absorbée par les agents spécialistes (SysAdmin, N3, etc.) via ADR-006 |
| **Projets / SOW** | En staging | MODULE_PROJETS en draft. Playbook IT_PROJET_SOW actif mais agent dédié non encore activé |
| **Monitoring avancé (SIEM)** | Couverture partielle | MonitoringMaster couvre N-able / RMM. Pas d'agent ou runbook dédié SIEM/SOAR au-delà de SecurityMaster |
| **Experts chevronnés (Pro tier)** | Non construit | 6 IT-Expert-* identifiés dans ADR-012 mais construction suspendue |

### 4.3 Agent IT-VoIPMaster — note spécifique

IT-VoIPMaster est présent dans `agents_index.yaml` avec statut `active` et intents `voip`, `telephonie`, `teams_phone`, `3cx`, `uc`, `sip`. Il est absent du CLAUDE.md principal (section 3 — liste des 28 agents métier). Le CLAUDE.md liste 28 agents métier mais en réalité 29 agents métier sont enregistrés dans l'index si l'on compte VoIPMaster. Ce point requiert réconciliation.

---

## 5. ÉTAT DES GAMMES COMMERCIALES

### 5.1 Architecture de tiering (ADR-011 — ACTIF)

Le tiering suit deux axes indépendants (orthogonaux) :
- **Axe commercial** : ce que le MSP paie (Starter / Pro / MSP / Enterprise)
- **Axe compétence** : ce que le technicien est qualifié pour faire (N1 / N2 / N3 / Architecte)

Un grand MSP peut avoir des N1 (accès Starter) et des architectes (accès Enterprise) simultanément.

### 5.2 Composition des forfaits

#### Starter — Tickets quotidiens, routing manuel

| Agent | Capacité |
|---|---|
| IT-FrontLine | Triage, premier contact, escalade |
| IT-Assistant-N2 | Mentorat N2, guide étape par étape |
| IT-TicketOpr | Cycle complet ticket — triage à clôture KB |
| IT-TicketScribe | Rédaction CW Notes, discussions, emails |

**Principe :** accès aux agents de support quotidien. Routing manuel (le tech choisit son agent). Pas de RouterIA automatique.

---

#### Pro — Support technique complet N2→N3

Contient tout le Starter, plus :

| Agent | Capacité ajoutée |
|---|---|
| IT-Assistant-N3 | Analyse avancée, incidents complexes |
| IT-SysAdmin | Serveurs, AD, GPO, DNS/DHCP, Hyper-V, SQL |
| IT-TechOnsite | Opérations terrain, déploiement, migration |
| IT-MaintenanceMaster | Patching planifié, préchecks, postchecks |
| IT-BackupDRMaster | Veeam, Datto, Keepit, restauration, DR |
| IT-NetworkMaster | Réseau, firewalls multi-constructeurs, VPN |

**Note ADR-012 :** 6 agents IT-Expert-* (Expert-Support, Expert-Infra, Expert-NOC, Expert-SOC, Expert-Compliance, Expert-OPR) sont prévus pour le niveau Pro comme alternative plus compacte aux spécialistes granulaires. **Construction suspendue en attente des tests RouterIA.**

---

#### MSP — Automatisation + NOC + livrables clients

Contient tout le Pro, plus :

| Agent | Capacité ajoutée |
|---|---|
| IT-OPS-RouterIA | Routing automatique (87 intents) |
| IT-NOCDispatcher | Qualification alertes, SLA, dispatch |
| IT-MonitoringMaster | Supervision RMM (N-able), alertes |
| IT-CloudMaster | Azure, Exchange, Intune, Teams, SharePoint |
| IT-UrgenceMaster | Gestion crises P0/P1 |
| IT-OnOffBoarder | Transitions MSP (4 scénarios) |
| IT-ReportMaster | QBR, postmortem, rapport mensuel |
| IT-AssetMaster | CMDB, licences, inventaire |
| IT-ClientDocMaster | Documentation Hudu, fiches client |

**Principe :** routing automatique activé. Le MSP n'a plus à choisir son agent — le RouterIA route selon l'intent détecté. NOC complet opérationnel.

---

#### Enterprise — Fusion cross-domaine + compliance + Claude API optionnel

Contient tout le MSP, plus :

| Agent | Capacité ajoutée |
|---|---|
| IT-Commandare-Infra | Orchestration infra cross-domaine |
| IT-Commandare-NOC | Orchestration NOC cross-domaine |
| IT-Commandare-TECH | Orchestration support N1-N3 + SOC |
| IT-Commandare-OPR | Orchestration opérations admin |
| IT-Commandare-Compliance *(à créer)* | Compliance + sécurité + rapports |
| IT-ComplianceMaster | Conformité Loi 25, PCI, HIPAA, audit |
| IT-SecurityMaster | SOC, SIEM, EDR, incident response |
| IT-ScriptMaster | Automatisation avancée PowerShell/Bash |

**Principe :** sur ChatGPT, les Commandare fonctionnent comme agents de fusion (raisonnement cross-domaine, chargement dynamique runbooks). Avec Claude API, orchestration native possible — valeur maximale.

### 5.3 Protection par axe compétence (3 couches)

1. **Accès** : le MSP partage seulement les GPTs du niveau du technicien — un N2 ne voit jamais Commandare-Infra
2. **Déclaration `/start`** : chaque agent évalue la compétence déclarée au démarrage et adapte le guidage
3. **Garde-fou agent** : les agents avancés détectent un profil junior et bloquent les actions hors compétence avec redirect vers chef d'équipe

---

## 6. DÉCISIONS D'ARCHITECTURE EN ATTENTE

### 6.1 ADR-011 — Tiering double axe (ACTIF — conséquences en cours)

**Statut :** ADR approuvée et documentée (2026-05-23). Implémentation partielle.

**Éléments restants à implémenter :**
- Commandare-Compliance : 5e agent Commandare à créer (ComplianceMaster + SecurityMaster + ReportMaster)
- Refactoring des Commandare actuels en agents fusion "architecte senior" (prévu phase Enterprise uniquement)
- Standardisation du bloc déclaration compétence `/start` pour tous les agents (non encore fait)

**Décision pendante EA :**
- Périmètre exact et prompt de Commandare-Compliance
- Séquencement de la construction (avant ou après tests RouterIA ?)

---

### 6.2 ADR-012 — Experts chevronnés (ACTIF — construction SUSPENDUE)

**Statut :** ADR approuvée (2026-05-23). **Construction des 6 agents IT-Expert-* bloquée.**

**Condition de déclenchement :** résultats des tests RouterIA en conditions réelles (5-10 cas minimum).

| Scénario RouterIA | Conséquence sur ADR-012 |
|---|---|
| RouterIA route correctement → 8/10 cas | Spécialistes granulaires suffisent pour Pro. Experts chevronnés optionnels (offre valeur ajoutée mais pas critiques) |
| RouterIA insuffisant (< 6/10) | Construire les 6 Experts en priorité — ils deviennent la solution pragmatique pour Pro/MSP |

**Les 6 experts identifiés :**

| Expert | Agents absorbés | Niveau cible |
|---|---|---|
| `IT-Expert-Support` | Assistant-N2, N3, FrontLine, TechOPS, ScriptMaster | Pro |
| `IT-Expert-Infra` | SysAdmin, CloudMaster, NetworkMaster, VoIPMaster, ScriptMaster | Pro |
| `IT-Expert-NOC` | MaintenanceMaster, BackupDRMaster, MonitoringMaster, NOCDispatcher, UrgenceMaster, ScriptMaster | Pro/MSP |
| `IT-Expert-SOC` | SecurityMaster, ScriptMaster | Pro/MSP |
| `IT-Expert-Compliance` | ComplianceMaster, ReportMaster | Pro/MSP |
| `IT-Expert-OPR` | AssetMaster, ClientDocMaster, KnowledgeKeeper, OnOffBoarder, TicketScribe, ReportMaster | Pro |

**Principe de conception :** chaque Expert est léger dans son prompt de base — il ne charge pas les runbooks à l'avance, il sait quoi charger via `getFileContent` selon le contexte.

---

### 6.3 RouterIA — Tests en conditions réelles (PRIORITÉ LANCEMENT)

**Statut :** tests non effectués. Template TEMPLATE_TEST_RouterIA_V1.md disponible dans IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS/.

**Contexte :** les tests antérieurs au 2026-05-23 portaient sur une version de la matrix sans les 11 runbooks WKS ni les 4 intents compliance — ils sont invalidés. Les tests valides commencent après merge PR#53 sur main (effectué 2026-05-22).

**Domaines à tester (5-10 cas) :**
- Support N1/N2 (ex. poste lent, problème Outlook)
- Infrastructure serveur (ex. pending reboot, HyperV)
- Compliance (ex. audit Loi 25, cyber-assurance)
- Backup/DR (ex. validation job Veeam)
- NOC (ex. alerte RMM N-able)

**Impact :** ce résultat détermine si Experts chevronnés (ADR-012) sont construits en priorité.

---

### 6.4 Commandare-Compliance — À créer

**Statut :** identifié dans ADR-011. Non commencé.

**Périmètre :** fusion ComplianceMaster + SecurityMaster + ReportMaster.

**Usage cible :** Enterprise — architecte senior capable de conduire un audit compliance complet avec investigation sécurité et production du rapport facturable.

**Prérequis :** décision EA sur périmètre exact + prompt. Construction après validation du pattern Commandare sur les 4 existants.

---

### 6.5 Autres décisions pendantes

| Sujet | Décision requise | Assigné |
|---|---|---|
| Format Knowledge Packs agents | Standardiser ou laisser flexible par agent ? | EA |
| Versioning bundles IT-SHARED/60_BUNDLES | Quand bumper la version ? | EA |
| Archivage ADR remplacées | Délai avant archivage ? | EA |
| Standardisation bloc `/start` compétence | Même format pour tous les agents | EA |
| IT-UpdaterMaster (staging) | Périmètre, prompt, activation | EA |
| MODULE_PROJETS (staging) | Finaliser spec, activer agent IT-ProjetSOW | EA |
| Réconciliation VoIPMaster | Confirmer position dans CLAUDE.md (29 agents métier ou 28 ?) | EA |

---

## 7. MÉTRIQUES PLATEFORME

### 7.1 Agents

| Catégorie | Nombre | Détail |
|---|---|---|
| Total agents | 33 | Inventaire officiel CLAUDE.md |
| Agents actifs | 32 | 33 − 1 legacy (IT-OnboardingMaster) |
| Agents OPS | 5 | RouterIA, PlaybookRunner, DossierIA, QAMaster, SyncFactory |
| Agents métier actifs | 27 | 28 − 1 legacy |
| Agents Commandare | 4 | En staging pratique — valeur réelle avec Claude API |
| Agents en staging repo | 2 | IT-UpdaterMaster, MODULE_PROJETS (Draft/) |
| Agents legacy | 1 | IT-OnboardingMaster → superseded par IT-OnOffBoarder |

> **Note :** IT-VoIPMaster est actif dans agents_index.yaml mais absent de la liste officielle CLAUDE.md (section 3). Ce point requiert réconciliation (voir section 8).

### 7.2 Ressources IT-SHARED

| Ressource | Nombre | Emplacement |
|---|---|---|
| Runbooks (fichiers .md) | 123 | IT-SHARED/10_RUNBOOKS/ |
| Templates (fichiers .md) | 90 | IT-SHARED/20_TEMPLATES/ (16 catégories) |
| Scripts PowerShell (.ps1) | 24 | IT-SHARED/30_SCRIPTS/ |
| Runbooks WKS | 11 | IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/ |
| Runbooks INFRA | 29 | IT-SHARED/10_RUNBOOKS/INFRA/ |
| Runbooks MAINT | 9 | IT-SHARED/10_RUNBOOKS/MAINTENANCE/ |
| Runbooks SUPPORT (hors WKS) | 9 | IT-SHARED/10_RUNBOOKS/SUPPORT/ |
| Runbooks NOC | 14 | IT-SHARED/10_RUNBOOKS/NOC/ |
| Runbooks SECURITY | 8 | IT-SHARED/10_RUNBOOKS/SECURITY/ |
| Runbooks OPR | 11 | IT-SHARED/10_RUNBOOKS/OPR/ |

### 7.3 Routing et playbooks

| Ressource | Valeur | Source |
|---|---|---|
| Intents couverts (RouterIA) | 87 | MASTER_DISPATCH_INDEX_V2.yaml |
| Playbooks actifs | 26 | playbooks/playbooks.yaml |
| ADR actives | 10 | ARCHITECTURE_DECISION_LOG.md (ADR-001 à ADR-010) |
| ADR en cours | 2 | ADR-011, ADR-012 (2026-05-23) |

### 7.4 Qualité plateforme

| Indicateur | Valeur | Note |
|---|---|---|
| Score global plateforme | Non calculé | Dashboard initialisé — 0 incident loggué |
| Incidents critiques 30j | 0 | — |
| Incidents totaux 30j | 0 | — |
| Correctifs pending EA | 0 | — |
| Agents avec score calculé | 0 | — |
| Dernière revue complète | Non effectuée | Dashboard généré 2026-05-17 |

> **Interprétation :** le dashboard QA est initialisé mais vierge — la plateforme n'a pas encore généré d'incidents traçables. Cela reflète soit l'absence d'utilisation en production, soit l'absence de logging. Recommandation : logguer les premiers cas d'utilisation réels pour établir une baseline qualité.

---

## 8. ACTIONS PRIORITAIRES ET NEXT STEPS

### P0 — Bloquant lancement

| # | Action | Responsable | Contexte |
|---|---|---|---|
| 1 | **Tester RouterIA sur 5-10 cas réels** | EA | Utiliser TEMPLATE_TEST_RouterIA_V1.md. Résultats conditionnent ADR-012. Domaines : support, serveur, compliance, backup, NOC |
| 2 | **Réconcilier le count agents** | EA | VoIPMaster présent dans agents_index.yaml mais absent de CLAUDE.md section 3. Confirmer : 28 ou 29 agents métier ? Mettre à jour CLAUDE.md en conséquence |

### P1 — Architecture

| # | Action | Responsable | Contexte |
|---|---|---|---|
| 3 | **Créer Commandare-Compliance** | EA + Claude Code | Périmètre : ComplianceMaster + SecurityMaster + ReportMaster. Prompt architecte senior, chargement dynamique runbooks SEC + OPR-PostIncident |
| 4 | **Décider sort des Experts chevronnés (ADR-012)** | EA | Après résultats RouterIA test. Si RouterIA insuffisant → construire IT-Expert-* en priorité |
| 5 | **Standardiser bloc `/start` compétence** | EA | Même format déclaration compétence pour tous les agents — requis pour protection axe compétence (ADR-011) |

### P2 — Opérationnel

| # | Action | Responsable | Contexte |
|---|---|---|---|
| 6 | **Copier CLAUDE_FACTORY.md dans repo Factory** | EA (manuel) | Action manuelle requise — copier `00_DOCS/CLAUDE_FACTORY.md` dans `eriqallain-afk/Factory` |
| 7 | **Activer MODULE_PROJETS** | EA | Spec v1 disponible. Playbook IT_PROJET_SOW actif. Valider et activer l'agent IT-ProjetSOW |
| 8 | **Établir baseline qualité QA** | EA | Logger les 5-10 premiers cas d'utilisation réels dans 00_QA/incidents/ pour établir un score de base |
| 9 | **Évaluer IT-UpdaterMaster** | EA | Agent en staging depuis Draft/. Définir périmètre et décider activation ou archivage |

### P3 — Documentaire

| # | Action | Responsable | Contexte |
|---|---|---|---|
| 10 | **[DOC_SYNC] Mettre à jour CLAUDE.md section 3** | EA | Si VoIPMaster confirmé dans les 28 agents métier — actualiser la liste officielle |
| 11 | **Documenter décision Format Knowledge Packs** | EA | ADR pendante — standardiser ou laisser flexible |
| 12 | **Documenter décision Versioning bundles** | EA | ADR pendante — politique de version bumping |

---

## ANNEXE — Récapitulatif des playbooks actifs (26)

| ID Playbook | Description |
|---|---|
| INTAKE_ROUTE_EXECUTE | Flux standard : route → exécute → archive |
| IT_ASSET_LOOKUP_V1 | Trouver et livrer le bon asset IT-SHARED |
| IT_CHANGE_EXEC | Planifier/exécuter un change → validations → reporting → archive |
| IT_COMMANDARE_NOC | Commandare NOC : triage/diagnostic, sévérité, plan de réponse |
| IT_COMMANDARE_OPR | Commandare OPR : gouvernance ops, communication, coordination |
| IT_COMMANDARE_TECH | Commandare TECH : troubleshooting/RCA, plan de remediation |
| IT_CW_INTERVENTION_LIVE_CLOSE | ConnectWise : journal LIVE + closeout CW + KB |
| IT_INCIDENT_TRIAGE | NOC triage → dispatch → remediation → reporting → archive |
| IT_MSP_LIVE_ASSIST | Assistance MSP temps réel (appel/chat/remote) : triage guidé |
| IT_MSP_TICKET_TO_KB | Ticket MSP → diagnostic → communication → knowledge |
| IT_NOC_DISPATCH | NOC dispatch : prioriser/assigner/escalader, suivre SLA |
| IT_NOC_HANDOFF | Handoff NOC (fin de quart/escalade) → synthèse → reporting |
| IT_MAINT_PATCH_REBOOT_VALIDATE | Maintenance Windows (patching via CW RMM) : plan → precheck → patch → postcheck |
| IT_POST_SHUTDOWN_VALIDATE | Post-shutdown électrique : baseline réseau/stockage/virtualisation |
| IT_SECURITY_INCIDENT_RESPONSE | Réponse incident sécurité : triage → containment → investigation |
| IT_FRONTLINE_CALL_TO_CLOSE | Flux première ligne (FrontLine) : réception billet → escalade |
| IT_URGENCE_PANNE_HQ | Flux urgence P1/P2 en live : qualification → notice Teams → escalade |
| IT_COMMANDARE_INFRA | Commandare INFRA : triage incident infra/cloud, mobilise spécialistes |
| IT_BACKUP_DR_TRIAGE | Backup/DR : triage job → diagnostic → restauration → rapport |
| IT_PROJET_SOW | Opportunité projet → escalade ventes → estimation → SOW → validation EA |
| IT_CLOUD_SUPPORT | Cloud/M365 : diagnostic → résolution → communication client → KB |
| IT_MONITORING_ALERT | Alerte monitoring : analyse → dispatch → validation → rapport |
| IT_SCRIPT_REQUEST | Demande script : conception → validation → documentation → déploiement |
| IT_VOIP_SUPPORT | VoIP : diagnostic → résolution → validation → clôture CW |
| IT_ASSET_MANAGEMENT | Asset/CMDB : inventaire → audit → rapport → mise à jour CMDB |
| IT_DOC_PRODUCTION | Documentation client : analyse → fiches Hudu → validation → publication |
| IT_TICKETOPS_FULL_FLOW | MSP TicketOps AI — cycle complet : start → triage → analyse → close → rapport → archive |

---

*EA\|IA — RAPPORT INTERNE Plateforme IT V1 — 2026-05-23 — Confidentiel*
