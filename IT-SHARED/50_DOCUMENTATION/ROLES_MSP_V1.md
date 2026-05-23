# Révision des rôles MSP par département
**Version :** 1.0 | **Date :** 2026-05-15
**Source :** Document de référence organisationnel — Eric Allain
**Note :** N1 remplacé par IT-FrontLine selon nomenclature de la plateforme

---

## Niveaux de support informatique en MSP : IT-FrontLine, N2, N3

Le support informatique en entreprise (notamment chez les MSP — Managed Service Providers) s'organise en trois niveaux hiérarchiques. Chaque niveau correspond à un degré d'expertise croissant et traite des problématiques de complexité différente.

---

### Niveau IT-FrontLine — Premier contact et résolution rapide

Le IT-FrontLine constitue la porte d'entrée de toute demande d'assistance. Ces techniciens accueillent, qualifient et traitent les incidents les plus courants.

**Agent associé :** IT-AssistanTI-FrontLine

**Tâches associées :**
- Réception et enregistrement des tickets de support
- Réinitialisation de mots de passe
- Création et gestion de comptes utilisateurs
- Assistance sur l'utilisation des applications métier
- Résolution des problèmes de connectivité basiques (Wi-Fi, VPN)
- Dépannage d'imprimantes et périphériques
- Installation et configuration de logiciels standards
- Escalade vers le N2 si le problème dépasse leur périmètre

---

### Niveau N2 — Expertise technique intermédiaire

Le N2 intervient lorsque le problème résiste au premier niveau. Ces administrateurs possèdent une connaissance approfondie des systèmes et infrastructures.

**Agent associé :** IT-AssistanTI-N2

**Tâches associées :**
- Réinitialisation de mots de passe (cas complexes)
- Création et gestion de comptes utilisateurs (cas avancés)
- Assistance sur l'utilisation des applications métier
- Résolution des problèmes de connectivité basiques (Wi-Fi, VPN)
- Dépannage d'imprimantes et périphériques
- Installation et configuration de logiciels standards
- Administration et configuration avancée des systèmes (Active Directory, serveurs, etc.)
- Maintenance préventive et mises à jour des infrastructures
- Gestion des incidents réseau plus élaborés (pare-feu, VLAN, routage)
- Analyse des logs et identification des causes racines
- Documentation des procédures pour enrichir la base de connaissances IT-FrontLine
- Escalade vers le N3 pour les cas critiques ou architecturaux

---

### Niveau N3 — Ingénierie et résolution approfondie

Le N3 regroupe les experts et ingénieurs spécialisés. Ils traitent les problèmes les plus complexes et interviennent sur l'architecture des systèmes.

**Agents associés :** IT-AssistanTI-N3 · IT-UrgenceMaster

**Tâches associées :**
- Résolution d'incidents critiques impactant l'infrastructure
- Conception et optimisation des architectures informatiques
- Développement de correctifs, scripts ou solutions sur mesure
- Interaction avec les éditeurs et constructeurs (support tiers)
- Analyse de performance et capacity planning
- Mise en œuvre de projets d'évolution technique
- Définition des standards et bonnes pratiques pour les niveaux inférieurs

### Synthèse comparative — Niveaux de support

| Niveau | Focus principal | Posture |
|---|---|---|
| IT-FrontLine | Incidents courants, premier contact | Accueil, qualification, résolution rapide |
| N2 | Incidents complexes, administration | Diagnostic approfondi, maintenance |
| N3 | Architecture, incidents critiques | Expertise, ingénierie, évolution |

Cette organisation pyramidale permet de résoudre rapidement les demandes courantes tout en réservant le temps des experts aux cas véritablement complexes.

---

## Administrateur Système Général (IT-MaintenanceMaster)

L'administrateur système généraliste assure le bon fonctionnement quotidien des environnements informatiques. Il intervient sur un large spectre de technologies.

**Agent associé :** IT-SysAdmin · IT-MaintenanceMaster

**Tâches associées :**
- Installation, configuration et maintenance des serveurs (Windows, Linux)
- Gestion d'Active Directory : utilisateurs, groupes, GPO, permissions
- Administration des services de messagerie (Exchange, Microsoft 365)
- Gestion des sauvegardes et validation des restaurations
- Application des correctifs et mises à jour de sécurité
- Surveillance des ressources système (CPU, RAM, stockage)
- Rédaction et mise à jour de la documentation technique
- Support de niveau 2/3 pour les incidents escaladés
- Automatisation des tâches répétitives via scripts (PowerShell, Bash)

---

## Administrateur Infrastructure (IT-Commandare-Infra · IT-CloudMaster · IT-VoIPMaster)

L'administrateur infrastructure se concentre sur les fondations technologiques : réseau, stockage, virtualisation et hébergement. Son rôle est plus orienté architecture.

**Agents associés :** IT-Commandare-Infra · IT-CloudMaster · IT-VoIPMaster

**Tâches associées :**
- Conception, déploiement et maintenance des infrastructures réseau (switches, routeurs, pare-feu)
- Administration des plateformes de virtualisation (VMware, Hyper-V, Proxmox)
- Gestion des environnements cloud (Azure, AWS, GCP)
- Configuration et optimisation des solutions de stockage (SAN, NAS)
- Planification de la capacité et évolution des ressources
- Mise en œuvre de la haute disponibilité et du PRA/PCA
- Gestion des interconnexions site-à-site et VPN
- Supervision des performances réseau et optimisation de la bande passante
- Collaboration avec les équipes projet pour les déploiements majeurs

---

## Administrateur NOC — Network Operations Center (IT-Commandare-NOC · IT-NetworkMaster · IT-MonitoringMaster · IT-BackupDRMaster)

L'administrateur NOC travaille au sein du centre d'opérations réseau. Son rôle est proactif : surveiller, détecter et réagir aux incidents avant qu'ils n'impactent les utilisateurs.

**Agents associés :** IT-Commandare-NOC · IT-NetworkMaster · IT-MonitoringMaster · IT-BackupDRMaster

**Tâches associées :**
- Surveillance 24/7 des infrastructures via outils de monitoring (Zabbix, PRTG, Nagios, Datadog)
- Détection et qualification des alertes réseau et système
- Réponse initiale aux incidents : diagnostic rapide et premières actions correctives
- Escalade vers les équipes spécialisées selon les procédures établies
- Suivi des SLA et respect des engagements de disponibilité
- Communication proactive avec les clients lors d'incidents majeurs
- Exécution des procédures de maintenance planifiée
- Tenue des journaux d'incidents et rapports d'activité
- Coordination avec les équipes terrain pour les interventions physiques

---

## Administrateur SOC — Security Operations Center (IT-SecurityMaster)

L'administrateur SOC opère au sein du centre d'opérations de sécurité. Sa mission est de protéger l'organisation contre les cybermenaces en détectant et répondant aux incidents de sécurité.

**Agent associé :** IT-SecurityMaster

**Tâches associées :**
- Surveillance continue des événements de sécurité via SIEM (Splunk, Sentinel, QRadar)
- Analyse et triage des alertes de sécurité (vrais positifs vs faux positifs)
- Investigation des incidents : analyse forensique préliminaire, identification des IOC
- Réponse aux incidents de sécurité selon les playbooks établis
- Chasse aux menaces proactive (threat hunting)
- Gestion et optimisation des outils de détection (EDR, IDS/IPS, pare-feu)
- Veille sur les vulnérabilités et menaces émergentes
- Rédaction de rapports d'incidents et recommandations de remédiation
- Participation aux exercices de simulation d'attaque (red team/blue team)
- Sensibilisation des utilisateurs aux bonnes pratiques de sécurité

### Synthèse comparative — Administrateurs spécialisés

| Rôle | Focus principal | Posture |
|---|---|---|
| Sys Admin Général | Systèmes et services | Polyvalent, opérationnel |
| Admin Infrastructure | Réseau, virtualisation, cloud | Architecte, évolutif |
| Admin NOC | Disponibilité et performance | Réactif, monitoring |
| Admin SOC | Sécurité et menaces | Défensif, analytique |

---

## Rôles spécialisés OPR — Environnement MSP

Ces trois rôles représentent des fonctions transversales essentielles qui soutiennent l'ensemble des équipes techniques et assurent la qualité opérationnelle du MSP.

### Asset Manager — Gestionnaire des actifs informatiques (IT-AssetMaster)

L'Asset Manager est responsable du cycle de vie complet des actifs informatiques : matériels, logiciels et licences. Il garantit une visibilité totale sur le parc et optimise les investissements.

**Agent associé :** IT-AssetMaster

**Tâches associées :**
- Inventaire et suivi de l'ensemble du parc informatique (postes, serveurs, équipements réseau, mobiles)
- Gestion des licences logicielles et conformité (audits, renouvellements, optimisation)
- Administration de l'outil ITSM/CMDB (ServiceNow, GLPI, Freshservice, etc.)
- Suivi du cycle de vie des équipements : acquisition, déploiement, maintenance, retrait
- Gestion des contrats fournisseurs, garanties et renouvellements
- Planification des remplacements et budgétisation des achats
- Reporting sur l'utilisation des actifs et recommandations d'optimisation
- Coordination avec les équipes techniques pour les déploiements et mises au rebut
- Gestion des stocks et logistique du matériel

---

### Scripteur — Automation Engineer (IT-ScriptMaster)

Le Scripteur est le spécialiste de l'automatisation. Il développe des scripts et outils pour éliminer les tâches répétitives, améliorer l'efficacité et réduire les erreurs humaines.

**Agent associé :** IT-ScriptMaster

**Tâches associées :**
- Développement de scripts d'automatisation (PowerShell, Python, Bash)
- Création et maintenance des scripts de déploiement RMM (Datto, ConnectWise, NinjaOne)
- Automatisation des tâches récurrentes : onboarding, maintenance, reporting
- Développement d'outils internes pour les équipes de support
- Intégration d'API entre les différentes plateformes du MSP
- Test, validation et documentation des scripts avant mise en production
- Optimisation des scripts existants pour améliorer performance et fiabilité
- Support aux équipes N2/N3 pour les besoins d'automatisation ponctuels
- Veille technologique sur les outils et méthodes d'automatisation

---

### Responsable de la documentation (IT-ClientDocMaster)

Le Responsable de la documentation garantit que l'information technique est accessible, à jour et exploitable. Il structure le savoir collectif et facilite le travail de toutes les équipes.

**Agent associé :** IT-ClientDocMaster

**Tâches associées :**
- Création et maintenance de la base de connaissances (KB)
- Rédaction et mise à jour des procédures opérationnelles standards (SOP)
- Documentation des environnements clients : architectures, configurations, contacts
- Standardisation des formats et templates documentaires
- Audit régulier de la documentation existante (exactitude, pertinence, obsolescence)
- Formation des équipes aux bonnes pratiques de documentation
- Coordination avec les techniciens pour capturer les connaissances terrain
- Gestion des accès et organisation de la plateforme documentaire (Confluence, IT Glue, Hudu)
- Création de guides utilisateurs et documentation client
- Reporting sur la couverture documentaire et identification des lacunes

### Synthèse comparative — Rôles OPR

| Rôle | Focus principal | Posture |
|---|---|---|
| Asset Manager | Parc, licences, cycle de vie | Gestion, conformité, optimisation |
| Scripteur | Automatisation, efficacité | Développement, intégration |
| Responsable documentation | Connaissance, procédures | Organisation, qualité, accessibilité |

Ces trois rôles, bien que souvent sous-estimés, sont des multiplicateurs de force pour un MSP : ils permettent aux équipes techniques de travailler plus efficacement, de réduire les erreurs et d'assurer une qualité de service constante.

---

## Rôles de gestion de l'information

### Responsable de la base de connaissances (IT-KnowledgeKeeper)

Le Knowledge Manager est le gardien du savoir collectif. Il structure, enrichit et maintient la base de connaissances pour que chaque technicien accède rapidement à l'information dont il a besoin.

**Agent associé :** IT-KnowledgeKeeper

**Tâches associées :**
- Création et structuration de la base de connaissances (IT Glue, Hudu, Confluence, etc.)
- Rédaction et mise à jour des articles techniques et procédures
- Standardisation des formats, templates et conventions de nommage
- Audit régulier du contenu : exactitude, pertinence, obsolescence
- Identification des lacunes documentaires et priorisation des créations
- Coordination avec les équipes techniques pour capturer les résolutions d'incidents
- Formation des collaborateurs aux bonnes pratiques de documentation
- Gestion des accès, permissions et organisation des espaces
- Suivi des métriques d'utilisation de la KB (articles consultés, recherches infructueuses)
- Promotion de la culture de partage des connaissances au sein de l'organisation

---

### Responsable des rapports (IT-ReportMaster)

Le Responsable des rapports transforme les données brutes en insights actionnables. Il fournit aux équipes et à la direction une visibilité claire sur la performance, les tendances et les axes d'amélioration.

**Agent associé :** IT-ReportMaster

**Tâches associées :**
- Conception et production des rapports opérationnels (tickets, SLA, temps de résolution)
- Création de tableaux de bord pour le suivi en temps réel (Power BI, Grafana, etc.)
- Analyse des tendances : volumes d'incidents, récurrence, causes racines
- Génération des rapports clients : revues de service, rapports mensuels/trimestriels
- Suivi des KPI et métriques de performance des équipes
- Identification des anomalies et alertes sur les dérives de performance
- Automatisation de la collecte et de la génération des rapports
- Collaboration avec les équipes pour définir les indicateurs pertinents
- Présentation des analyses lors des comités de pilotage et revues internes
- Recommandations d'amélioration basées sur les données collectées

---

### Scribe (IT-TicketScribe)

Le Scribe assure la traçabilité et la qualité de la documentation opérationnelle en temps réel. Il capture l'information lors des interventions, réunions et projets pour que rien ne se perde.

**Agent associé :** IT-TicketScribe

**Tâches associées :**
- Prise de notes structurées lors des réunions techniques et comités
- Documentation des interventions majeures et post-mortems d'incidents
- Rédaction des comptes-rendus de réunions clients et internes
- Communication client (courriel)
- Transcription des procédures communiquées oralement par les experts
- Mise en forme et intégration du contenu dans les outils documentaires
- Suivi des actions décidées et relance des responsables
- Assistance à la création de documentation technique (schémas, guides)
- Vérification de la cohérence et de la clarté des documents produits
- Archivage et classement des documents selon les normes établies
- Support aux équipes projet pour la documentation des livrables

### Synthèse comparative — Gestion de l'information

| Rôle | Focus principal | Posture |
|---|---|---|
| Knowledge Manager | Savoir collectif, KB | Structuration, qualité, accessibilité |
| Reporting Manager | Données, performance | Analyse, visibilité, aide à la décision |
| Scribe | Documentation temps réel, capture | Traçabilité, support |

Ces rôles forment un écosystème d'information essentiel : le Scribe capture, le Knowledge Manager structure et pérennise, le Reporting Manager analyse et valorise. Ensemble, ils garantissent que le MSP apprend de son expérience et améliore continuellement ses services.

---

*ROLES_MSP_V1 — IT MSP Intelligence — 2026-05-15 — Source : Document organisationnel Eric Allain*
