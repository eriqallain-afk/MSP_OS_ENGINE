# AGENT BOOK — Tier MSP Suite
**ID :** AGENT_BOOK_MSP_Suite_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Agents couverts :** IT-AssetMaster · IT-ClientDocMaster · IT-KnowledgeKeeper · IT-SysAdmin · IT-ScriptMaster · IT-Commandare-Infra · IT-Commandare-NOC · IT-Commandare-OPR · IT-Commandare-TECH

---

## Ce tier comprend

Le MSP Suite ajoute la couche de gouvernance, de documentation client, de gestion des actifs et de commandement opérationnel. Les agents Commandare coordonnent les autres agents et assurent l'uniformité CW. IT-SysAdmin et IT-ScriptMaster offrent une autonomie technique complète. Ce tier est conçu pour les MSP gérant plusieurs clients avec des équipes structurées NOC/INFRA.

| Agent | Rôle | Audience |
|---|---|---|
| IT-AssetMaster | Inventaire, EOL, licences depuis CW/CMDB | Ops / Asset managers |
| IT-ClientDocMaster | Fiches techniques Hudu par objet | Documentation |
| IT-KnowledgeKeeper | Articles KB, runbooks, SOPs | Gestion des connaissances |
| IT-SysAdmin | Technicien senior polyvalent N2/N3 | Tech senior / Infrastructure |
| IT-ScriptMaster | Scripts PowerShell/Bash production-ready | Automatisation |
| IT-Commandare-Infra | Commandement incidents infrastructure P1/P2 | Gestionnaire incidents |
| IT-Commandare-NOC | Commandement NOC : triage, routing, handover | NOC command |
| IT-Commandare-OPR | Commandement opérations : DoD, clôture, communications | Opérations |
| IT-Commandare-TECH | Triage technique : classification N1/N2/N3/SOC | Coordination technique |

---

## IT-AssetMaster

> **Rôle :** Hub de gestion des actifs MSP. Produit inventaires, rapports EOL/EOS et conformité licences depuis ConnectWise uniquement.

**Audience :** Ops, asset managers, coordonnateurs — pour audits et recommandations matérielles.

**Déclencheur typique :** Audit d'inventaire client, matériel en fin de vie à identifier, conformité licences à vérifier.

### Capacités principales
- Inventaire matériel et logiciel depuis CMDB CW (source unique)
- Rapport EOL (End of Life) vs EOS (End of Support) — distinction obligatoire
- Audit licences : actives, expirées, surplus
- Audit CMDB complet : cohérence + gaps
- Marqueurs `[À CONFIRMER]` pour actifs non vérifiés
- Zéro donnée financière/contractuelle dans les livrables client

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/inventaire [client]` | Audit inventaire matériel et logiciel | Audit client |
| `/eol [client]` | Rapport EOL/EOS équipements | Revue fin de vie |
| `/licences [client]` | Rapport conformité licences | Audit licences |
| `/audit [client]` | Audit CMDB complet : conformité + gaps | Revue globale |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Rapport d'inventaire (tableau par catégorie)
- Rapport EOL avec recommandations de remplacement
- Rapport de conformité licences
- Rapport d'audit CMDB

### 🔧 Pistes d'amélioration
- Ajouter `/recommandation [client]` : plan de renouvellement priorisé avec budget estimé
- Ajouter intégration automatique avec découverte RMM pour comparer avec CMDB
- Ajouter alerte sur licences non assignées > 90 jours

---

## IT-ClientDocMaster

> **Rôle :** Spécialiste documentation client. Transforme briefs et conversations en fiches Hudu par objet (serveurs, hyperviseurs, firewalls, NAS, UPS, etc.).

**Audience :** Équipe documentation, techniciens qui documentent après intervention.

**Déclencheur typique :** Nouvelle configuration à documenter, audit documentation client Hudu, brief reçu d'IT-TicketScribe.

### Capacités principales
- Conversion conversation → fiche Hudu structurée
- Types de fiches : serveur, hyperviseur, NAS, firewall, commutateur, UPS, poste, application
- Liens bidirectionnels (parent ↔ enfant, upstream ↔ downstream)
- Zéro credential/MDP dans Hudu → Passportal uniquement
- Zéro IP interne dans Notes-Editor → champs réseau dédiés
- Zéro invention → `[À COMPLÉTER]` pour info inconnue
- Hudu ≠ CW : Hudu = état existant, CW = actions réalisées

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/analyse [texte]` | Conversation brute → fiches Hudu | Dépouillement après intervention |
| `/brief [texte]` | Brief structuré → extraction + fiche Hudu | Brief TicketScribe reçu |
| `/hyperviseur [contexte]` | Fiche hyperviseur (Hyper-V/VMware/XCP-ng) | Doc hyperviseur |
| `/nas [contexte]` | Fiche NAS | Doc NAS |
| `/audit [client]` | Audit documentation Hudu client | Vérification doc client |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Fiches Hudu prêtes à coller (format Markdown structuré)
- Rapport d'audit documentation

### 🔧 Pistes d'amélioration
- Ajouter `/update [fiche]` : mise à jour d'une fiche Hudu existante après changement
- Ajouter indicateur de fraîcheur : date de dernière modification et vérification dans l'audit
- Standardiser le format de chaque type de fiche avec un en-tête version/date

---

## IT-KnowledgeKeeper

> **Rôle :** Gardien de la base de connaissances. Crée et structure articles KB, runbooks et SOPs depuis briefs et résolutions d'incidents.

**Audience :** Équipe gestion des connaissances, techniciens en fin d'incident.

**Déclencheur typique :** Incident résolu avec nouvelle solution, nouveau processus à documenter, brief reçu d'IT-TicketScribe `/kb`.

### Capacités principales
- Articles KB depuis résolutions d'incidents
- Runbooks de procédures détaillées
- SOPs structurées
- Identification cause racine réelle (pas le symptôme)
- Zéro IP dans KB, zéro credentials
- Mise à jour de l'index KB
- Périmètre strict IT/MSP uniquement

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/kb [brief]` | Article KB depuis brief ou notes CW | Incident résolu → KB |
| `/runbook [sujet]` | Créer runbook de procédure | Nouvelle procédure |
| `/sop [sujet]` | Créer SOP structurée | Nouveau processus |
| `/index` | Mettre à jour l'index KB | Après création article |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Article KB (Markdown, prêt pour base de connaissances)
- Runbook structuré
- SOP
- Mise à jour index

### 🔧 Pistes d'amélioration
- Ajouter `/deprecate [article]` : marquer un article KB obsolète avec redirection vers le nouveau
- Ajouter `/revue [sujet]` : revue d'un article existant et proposition de mise à jour
- Ajouter métadonnées : version, date création, dernière révision, auteur, tags

---

## IT-SysAdmin

> **Rôle :** Administrateur système senior polyvalent (25 ans d'expérience simulée). Diagnostic autonome, exécution rigoureuse des runbooks, couverture N2/N3 complète.

**Audience :** Tech senior, ingénieurs infrastructure — interventions complexes multi-domaines.

**Déclencheur typique :** Billet N3, maintenance complexe, diagnostic multi-serveurs, intervention infrastructure autonome.

### Capacités principales
- AD/DC : opérations avancées, réplication, FSMO, intégrité NTDS, validation pré/post
- Windows Server : patching complet + RMM, WSUS, reboots contrôlés
- SQL Server, RDS/RemoteApp, Hyper-V, VMware, XCP-ng
- M365 : Exchange, Intune, Entra ID
- Veeam backup management
- Serveurs d'impression, GPO, DNS, DHCP
- Health checks + MasterScript diagnostic
- Scripts PowerShell production-ready (param() ligne 1)
- Exécution runbook étape par étape sans sauter d'étape sans accord

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/start [#billet]` | Nouvelle intervention : triage + plan | Début de billet |
| `/start_maint` | Pack maintenance : ordre serveurs + snapshots | Maintenance planifiée |
| `/script [desc]` | Script PowerShell production-ready | Automatisation |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Diagnostic technique complet
- Plan de maintenance (ordre + snapshots)
- Health check structuré (T4 CW_NOTE_DIAGNOSTIC)
- Script PowerShell dans bloc séparé
- Notice Teams
- Note interne + Discussion CW

### Règles critiques
- **1 serveur à la fois** — obligatoire
- **Snapshot DC interdit** → Windows Server Backup
- **Reboot documenté :** `shutdown /r /t 0 /c "Billet #XXXXX — [raison]" /d p:4:1`
- Runbook = étape par étape, **aucun saut sans accord explicite**

### 🔧 Pistes d'amélioration
- Ajouter `/mastescript [serveur]` : lance le diagnostic MasterScript et formate directement en T4 CW
- Ajouter `/order [liste-serveurs]` : détermine l'ordre optimal de traitement (DC en premier, puis dépendances)
- Renforcer la liaison avec IT-Commandare-TECH pour les escalades techniques automatiques

---

## IT-ScriptMaster

> **Rôle :** Expert en automatisation. Génère des scripts PowerShell/Bash/RMM production-ready, audite les scripts existants, extrait des snippets de bibliothèque.

**Audience :** Techniciens en automatisation, équipe infrastructure.

**Déclencheur typique :** Besoin d'automatisation, script à auditer avant déploiement RMM, extraction d'un snippet réutilisable.

### Capacités principales
- Scripts PowerShell production-ready (standards MSP stricts)
- Scripts Bash
- Scripts compatibles déploiement RMM
- Audit qualité + sécurité + conformité RMM
- Extraction de snippets de bibliothèque MSP
- Scripts precheck/postcheck standardisés
- Headers de conformité avec standards

### Standards PowerShell obligatoires
- `param()` **ligne 1 absolue** (avant tout commentaire)
- `[AllowEmptyString()]` sur tous les paramètres string
- `Write-Host ""` interdit → utiliser `Write-Host " "` (avec espace)
- Zéro credentials dans les scripts
- Blocs séparés : script dans `powershell`, explication en texte

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/script [description]` | Générer script PS/Bash production-ready | Nouveau script |
| `/audit [script]` | Audit qualité + sécurité + RMM | Script existant à vérifier |
| `/lib [catégorie]` | Extraire snippets bibliothèque MSP | Réutilisation |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Script production dans bloc `powershell` séparé
- Rapport d'audit (qualité, sécurité, recommandations)
- Snippets extraits de bibliothèque
- Note interne CW

### 🔧 Pistes d'amélioration
- Ajouter `/test [script]` : génère un script de test/validation pour valider un script principal
- Ajouter `/version [script]` : ajout automatique d'un header de versionnement (v1.0 → v1.1 avec changelog)
- Ajouter vérification automatique des bonnes pratiques RMM à l'audit (sortie codes exit standardisés)

---

## IT-Commandare-Infra

> **Rôle :** Commandant d'incidents infrastructure P1/P2. Analyse, détermine le domaine et la sévérité, mobilise les spécialistes, coordonne la résolution.

**Audience :** Gestionnaires d'incidents, coordonnateurs infrastructure, chefs d'équipe INFRA.

**Déclencheur typique :** Incident P1/P2 infrastructure déclaré (DC, SQL, virtualisation, réseau, backup).

### Capacités principales
- Analyse d'incident infra P1 : réponse < 5 minutes
- Classification domaine : DC, SQL, virtualisation, réseau, backup
- Mobilisation de spécialistes (INFRA, NOC, SOC)
- Validation post-incident obligatoire
- Règle 1 serveur à la fois — enforcement
- Snapshot DC interdit — enforcement
- Escalade NOC, INFRA, SOC selon domaine

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/triage [incident]` | Analyse : domaine + sévérité + plan + spécialiste | Incident infra déclaré |
| `/escalade [domaine]` | Bloc CW de transfert structuré | Escalade vers spécialiste |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Analyse d'incident (domaine, sévérité, plan)
- Assignation spécialiste documentée
- Bloc d'escalade CW prêt à coller
- Note de coordination

### 🔧 Pistes d'amélioration
- Ajouter `/status [incident]` : mise à jour de statut toutes les Xh en format CW pour les stakeholders
- Ajouter matrice domaine/spécialiste sous forme de tableau dans les instructions pour routing instantané
- Ajouter trigger automatique vers IT-UrgenceMaster pour les pannes électriques ou multi-sites

---

## IT-Commandare-NOC

> **Rôle :** Commandant NOC. Classifie, priorise et route les incidents NOC. Aucun P1/P2 sans propriétaire. Gestion des passations de quart.

**Audience :** Command staff NOC, chefs de shift.

**Déclencheur typique :** Alerte NOC à classifier, P1 non assigné, passation de quart, multi-alertes même client.

### Capacités principales
- Triage et priorisation d'alertes NOC
- Détection multi-alertes : même client/site = incident multi-composants
- P1 orphelin > 10 min → escalade automatique
- Règle absolue : jamais acquitter P1 sans investigation
- Passation de quart documentée
- Protocole frontdoor (premier contact)
- Coordination INFRA, sécurité, backup

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/triage [alerte]` | Classifier + priorité + plan + routing | Alerte NOC reçue |
| `/dispatch [ticket]` | Dispatcher l'incident | Ticket à assigner |
| `/handover` | Passation de quart : tickets actifs | Changement de shift |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Classification d'alerte (priorité, domaine, routing)
- Rapport de passation de quart
- Note d'incident command
- Log de coordination

### Règles critiques
- **Zéro P1/P2 sans propriétaire** — tolérance zéro
- **Jamais acquitter P1 sans investigation**
- P1 orphelin > 10 min → escalade IT-Commandare-Infra + chef d'équipe

### 🔧 Pistes d'amélioration
- Ajouter `/orphans` : liste tous P1/P2 sans propriétaire actif en temps réel
- Ajouter `/p1-timeline [ticket]` : chronologie rapide de l'incident P1 pour communication direction
- Ajouter détection pattern : 3 alertes même client en 1h → escalade automatique Commandare-Infra

---

## IT-Commandare-OPR

> **Rôle :** Commandant opérations. Spécialiste clôture CW, communication client, validation DoD (Definition of Done) avant fermeture de billet.

**Audience :** Gestionnaires d'opérations, équipe clôture billets, coordonnateurs MSP.

**Déclencheur typique :** Billet à fermer, communication client à rédiger, validation DoD requise, post-mortem à initier.

### Capacités principales
- Livrables CW Standard (Note, Discussion, Email) — STAR method
- Validation DoD avant toute clôture (cause racine + Note + Discussion)
- Post-mortem obligatoire pour P1/P2
- Phrases d'ouverture imposées pour Discussion et Email
- Zéro IP dans livrables clients
- Notices Teams générées mot pour mot
- Transfert vers KB après clôture

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/note [contexte]` | CW Note Interne | Documentation interne |
| `/discussion [contexte]` | CW Discussion (STAR, client-safe) | Communication billet |
| `/email [contexte]` | Email client professionnel | Suivi ou clôture |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Clôture complète avec validation DoD | Fermeture billet |

### Sorties CW
- Note interne (technique, factuelle)
- Discussion (STAR, 4+ bullets, client-safe)
- Email client professionnel
- Notice Teams
- Validation DoD avec checklist
- Handoff KB

### Règles critiques
- **Discussion :** `Prise en connaissance de la demande et consultation de la documentation.` + `Connexion au RMM et analyse de l'état global et de la présence d'alerte.`
- DoD = cause racine identifiée + Note + Discussion complète
- Post-mortem obligatoire P1/P2 → IT-ReportMaster

### 🔧 Pistes d'amélioration
- Ajouter validation automatique DoD : vérifier présence Note + Discussion avant `/close`
- Ajouter `/satisfaction [billet]` : demande de satisfaction client (CSAT) prête à envoyer
- Ajouter score de qualité de clôture (auto-évaluation : complétude Note, longueur Discussion, présence recommandation)

---

## IT-Commandare-TECH

> **Rôle :** Commandant triage technique. Classifie les tickets complexes N1/N2/N3/SOC, coordonne le confinement initial pour incidents sécurité, génère les blocs CW de transfert.

**Audience :** Coordinateurs techniques, triageurs d'incidents.

**Déclencheur typique :** Ticket complexe à classifier, incident sécurité à router, escalade technique à documenter.

### Capacités principales
- Classification N1/N2/N3/SOC des tickets
- Incident sécurité P1 : isolation immédiate avant escalade SecurityMaster
- Génération de blocs CW de transfert structurés
- Escalade réseau/backup/VPN → NOC
- Escalade infrastructure → INFRA
- Escalade sécurité → SecurityMaster

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/triage [ticket]` | Classifier + priorité + routing N1/N2/N3/SOC | Ticket complexe à router |
| `/soc [alerte]` | Incident sécurité : identification → confinement | Alerte sécurité |
| `/escalade [domaine]` | Bloc CW de transfert structuré | Escalade à documenter |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Analyse de triage technique (niveau, domaine, routing)
- Bloc de transfert CW structuré (prêt à coller)
- Note d'isolation initiale (sécurité)
- Note interne CW

### 🔧 Pistes d'amélioration
- Ajouter scoring CVSS de base dans le triage sécurité (critère objectif de sévérité)
- Ajouter `/matrice` : afficher la matrice de classification N1/N2/N3/SOC sous forme de tableau
- Ajouter checklist de confinement initial pour SOC en attendant IT-SecurityMaster

---

## Index des commandes — Tier MSP Suite

| Agent | Commande | Description |
|---|---|---|
| IT-AssetMaster | `/inventaire [client]` | Audit inventaire matériel et logiciel |
| IT-AssetMaster | `/eol [client]` | Rapport EOL/EOS équipements |
| IT-AssetMaster | `/licences [client]` | Rapport conformité licences |
| IT-AssetMaster | `/audit [client]` | Audit CMDB complet |
| IT-AssetMaster | `/close` | Menu de clôture CW |
| IT-ClientDocMaster | `/analyse [texte]` | Conversation → fiches Hudu |
| IT-ClientDocMaster | `/brief [texte]` | Brief → fiche Hudu |
| IT-ClientDocMaster | `/hyperviseur [contexte]` | Fiche hyperviseur |
| IT-ClientDocMaster | `/nas [contexte]` | Fiche NAS |
| IT-ClientDocMaster | `/audit [client]` | Audit documentation Hudu |
| IT-ClientDocMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-ClientDocMaster | `/close` | Menu de clôture CW |
| IT-KnowledgeKeeper | `/kb [brief]` | Article KB depuis brief |
| IT-KnowledgeKeeper | `/runbook [sujet]` | Créer runbook procédure |
| IT-KnowledgeKeeper | `/sop [sujet]` | Créer SOP structurée |
| IT-KnowledgeKeeper | `/index` | Mettre à jour index KB |
| IT-KnowledgeKeeper | `/close` | Menu de clôture CW |
| IT-SysAdmin | `/start [#billet]` | Triage + plan d'intervention |
| IT-SysAdmin | `/start_maint` | Pack maintenance multi-serveurs |
| IT-SysAdmin | `/script [desc]` | Script PowerShell production-ready |
| IT-SysAdmin | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-SysAdmin | `/close` | Menu de clôture CW |
| IT-ScriptMaster | `/script [description]` | Générer script PS/Bash |
| IT-ScriptMaster | `/audit [script]` | Audit qualité + sécurité + RMM |
| IT-ScriptMaster | `/lib [catégorie]` | Extraire snippets bibliothèque |
| IT-ScriptMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-ScriptMaster | `/close` | Menu de clôture CW |
| IT-Commandare-Infra | `/triage [incident]` | Analyse incident : domaine + sévérité + plan |
| IT-Commandare-Infra | `/escalade [domaine]` | Bloc CW de transfert structuré |
| IT-Commandare-Infra | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-Commandare-Infra | `/close` | Menu de clôture CW |
| IT-Commandare-NOC | `/triage [alerte]` | Classifier + priorité + routing |
| IT-Commandare-NOC | `/dispatch [ticket]` | Dispatcher l'incident |
| IT-Commandare-NOC | `/handover` | Passation de quart |
| IT-Commandare-NOC | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-Commandare-NOC | `/close` | Menu de clôture CW |
| IT-Commandare-OPR | `/note [contexte]` | CW Note Interne |
| IT-Commandare-OPR | `/discussion [contexte]` | CW Discussion STAR |
| IT-Commandare-OPR | `/email [contexte]` | Email client professionnel |
| IT-Commandare-OPR | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-Commandare-OPR | `/close` | Clôture complète avec DoD |
| IT-Commandare-TECH | `/triage [ticket]` | Classifier + routing N1/N2/N3/SOC |
| IT-Commandare-TECH | `/soc [alerte]` | Incident sécurité : identification + confinement |
| IT-Commandare-TECH | `/escalade [domaine]` | Bloc CW de transfert structuré |
| IT-Commandare-TECH | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-Commandare-TECH | `/close` | Menu de clôture CW |

---

*AGENT_BOOK_MSP_Suite_V1 — IT MSP Intelligence — 2026-05-14*
