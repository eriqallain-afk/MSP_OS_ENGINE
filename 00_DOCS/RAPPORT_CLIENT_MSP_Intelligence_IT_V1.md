# MSP Intelligence IT — Présentation Produit
## Document de présentation client — EA|IA

> **Version :** 1.0 | **Date :** 2026-05-23 | **Confidentiel**

---

## TABLE DES MATIÈRES

1. [Résumé exécutif](#1-résumé-exécutif)
2. [Le problème MSP sans IA](#2-le-problème-msp-sans-ia)
3. [MSP Intelligence IT — Vue d'ensemble](#3-msp-intelligence-it--vue-densemble)
4. [Les 4 gammes en détail](#4-les-4-gammes-en-détail)
5. [Les 9 modules](#5-les-9-modules)
6. [Ce que l'agent produit concrètement](#6-ce-que-lagent-produit-concrètement)
7. [Intégration dans le workflow MSP](#7-intégration-dans-le-workflow-msp)
8. [Comment démarrer](#8-comment-démarrer)
9. [Annexe — Répertoire complet des 33 agents](#9-annexe--répertoire-complet-des-33-agents)

---

## 1. Résumé exécutif

**MSP Intelligence IT** est une plateforme de 33 agents IA spécialisés, conçue exclusivement pour les opérations des fournisseurs de services gérés (MSP).

Chaque agent est configuré pour le contexte MSP : ConnectWise Manage, N-able, ScreenConnect, Hudu, Veeam, Datto, Active Directory, Microsoft 365, Entra ID, Purview. Les agents produisent des livrables directement utilisables — notes CW, discussions client, messages Teams, scripts PowerShell, runbooks, rapports, audits de conformité — sans reformatage manuel requis.

**Périmètre de la plateforme :**

| Composante | Quantité |
|---|---|
| Agents IA spécialisés | 33 (5 OPS infrastructure + 28 métier) |
| Runbooks validés | 91 |
| Templates (CW, discussion, Teams, rapports, postmortems, QBR, KB) | 65 |
| Scripts PowerShell | 28 |
| Intents routés automatiquement | 87 |

**Disponible en 4 gammes :** STARTER — PRO — MSP — ENTERPRISE

**Résultat attendu :** Les techniciens cessent d'improviser la documentation et les communications. Le temps de rédaction post-intervention passe de 25 minutes à moins d'une minute. La qualité est uniforme quel que soit le technicien sur le ticket.

---

## 2. Le problème MSP sans IA

### Ce qui se passe aujourd'hui dans la plupart des MSP

Un technicien ferme un ticket. Avant de passer au suivant, il doit :

- Rédiger la note interne CW (ce qui a été fait, comment, pourquoi)
- Rédiger la discussion client (même information, reformatée pour le client)
- Envoyer un message Teams au chef d'équipe si escalade requise
- Produire un rapport si c'est un ticket P1
- Chercher le bon runbook si c'est un problème récurrent

**Résultat observé :**

| Symptôme | Impact |
|---|---|
| Notes CW variables selon le technicien | Historique client non fiable, difficultés lors des audits |
| Communications client improvisées | Ton et qualité inconsistants, risque de plaintes |
| Recherche de runbook manuelle | Temps perdu, procédures parfois ignorées |
| Onboarding lent des N1/N2 | Dépendance aux seniors pour les cas standard |
| Documentation post-intervention longue | 20-30 min par ticket complexe, non facturable |

### Ce qui manque

Pas d'outil spécialisé MSP. ChatGPT ou Claude direct exigent de tout configurer, de reformuler les prompts à chaque fois, et ne connaissent pas ConnectWise, N-able ou Veeam de façon opérationnelle.

Les agents MSP Intelligence IT résolvent ce problème : ils connaissent déjà le contexte, les formats, les outils et les procédures. Le technicien donne la commande, l'agent produit le livrable.

---

## 3. MSP Intelligence IT — Vue d'ensemble

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    TECHNICIEN / NOC                      │
│         (ChatGPT, Claude.ai, ou API Claude)              │
└──────────────────────┬──────────────────────────────────┘
                       │
             ┌─────────▼──────────┐
             │  IT-OPS-RouterIA   │  ← Point d'entrée automatique
             │  87 intents routés │    (Gamme MSP et +)
             └─────────┬──────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   ┌────▼────┐   ┌─────▼────┐  ┌────▼────┐
   │ Agents  │   │ Runbooks │  │Scripts  │
   │ métier  │   │  91      │  │  PS 28  │
   │  28     │   └──────────┘  └─────────┘
   └─────────┘
```

### Philosophie opérationnelle

- **Pas de génération approximative.** Les agents suivent des runbooks validés et des templates testés.
- **Pas de configuration par l'utilisateur.** Les guardrails MSP sont intégrés à chaque agent.
- **Livrables prêts à coller.** Note CW, discussion client, message Teams — générés en une commande.
- **Traçabilité.** Chaque run est archivé par IT-OPS-DossierIA.

### Équipes

**Équipe OPS — 5 agents (infrastructure interne de la plateforme)**

| Agent | Rôle |
|---|---|
| IT-OPS-RouterIA | Point d'entrée — détecte l'intent, charge le runbook, route vers l'agent |
| IT-OPS-PlaybookRunner | Exécute les playbooks multi-agents step by step |
| IT-OPS-DossierIA | Archive chaque run, produit les livrables traçables |
| IT-QAMaster | Qualité plateforme — incidents, patterns, correctifs |
| IT-OPS-SyncFactory | Synchronisation produit, rapports de mise à jour |

**Équipe Métier — 28 agents** (détail par gamme à la section 4)

---

## 4. Les 4 gammes en détail

---

### STARTER

**Profil cible :** MSP de 1 à 5 techniciens. Objectif immédiat : structurer le support quotidien, éliminer la documentation manuelle, uniformiser les notes CW.

**Agents inclus (4) :**

| Agent | Rôle principal |
|---|---|
| **IT-FrontLine** | Premier contact client — triage tickets entrants, classification priorité, premier diagnostic |
| **IT-Assistant-N2** | Support niveau 2 — résolution tickets standard avec mentorat intégré et garde-fous hors-scope |
| **IT-TicketOpr** | Analyse et traitement intelligent des tickets — triage, runbook suggéré, scripts PowerShell inline, menus de clôture CW |
| **IT-TicketScribe** | Rédaction et documentation — notes CW, discussions client, rapports post-intervention |

**Ce que ça change dès la semaine 1 :**
- Le technicien ouvre `IT-TicketOpr` sur le ticket, tape `/start`, reçoit une analyse structurée avec le runbook suggéré.
- À la fermeture, `/close` génère le menu de clôture CW complet, prêt à coller.
- `IT-TicketScribe` produit la note interne et la communication client en parallèle.

---

### PRO

**Profil cible :** MSP avec équipe technique complète (N1/N2/N3). Objectif : couvrir l'ensemble du support technique, la maintenance planifiée, les sauvegardes, le réseau.

**Agents inclus : tout STARTER +**

| Agent | Rôle principal |
|---|---|
| **IT-Assistant-N3** | Support niveau 3 — escalades complexes, AD/Azure/M365/Hyper-V/VMware |
| **IT-SysAdmin** | Administration systèmes — AD, GPO, M365, Entra ID, politiques |
| **IT-TechOnsite** | Opérations terrain — interventions sur site, procédures de dépannage avancées |
| **IT-MaintenanceMaster** | Maintenance planifiée — prechecks, snapshots, patching, postchecks, rapports |
| **IT-BackupDRMaster** | Backup et reprise après sinistre — validation Veeam/Datto, tests DR, procédures |
| **IT-NetworkMaster** | Réseau — VLAN, VPN, WiFi, Firewall, configuration Switch |

**Ajout clé — IT-MaintenanceMaster :**
Gestion complète des fenêtres de maintenance : prechecks automatisés, instructions snapshot VM, séquence de patching, postchecks de validation, rapport de maintenance généré automatiquement pour le client et pour l'interne.

---

### MSP

**Profil cible :** MSP avec opérations NOC, clients multiples, besoin d'automatisation du routing et de reporting client régulier.

**Agents inclus : tout PRO +**

| Agent | Rôle principal |
|---|---|
| **IT-OPS-RouterIA** | Routing automatique — 87 intents détectés, runbook chargé, agent ciblé |
| **IT-NOCDispatcher** | Dispatch NOC — gestion des escalades, assignation, suivi |
| **IT-MonitoringMaster** | Supervision NOC — alertes, analyse d'incidents, procédures de réponse |
| **IT-CloudMaster** | Infrastructure cloud — Azure, AWS, M365, gestion ressources |
| **IT-UrgenceMaster** | Urgences P0/P1 — gestion de crise, format incident structuré, communication |
| **IT-OnOffBoarder** | Transitions MSP — onboarding/offboarding client et employé (4 scénarios couverts) |
| **IT-ReportMaster** | Rapports et KPIs — rapports mensuels client, QBR, tableaux de bord |
| **IT-AssetMaster** | CMDB — gestion des actifs, inventaire, cycle de vie |

**Ajout clé — IT-OPS-RouterIA :**
Le technicien décrit l'incident en langage naturel. RouterIA détecte l'intent parmi 87 scénarios couverts, charge automatiquement le runbook correspondant et route vers l'agent approprié. Aucune navigation manuelle dans les menus.

---

### ENTERPRISE

**Profil cible :** MSP avec obligations de conformité (Loi 25, PCI, HIPAA, cyber-assurance), clients dans des secteurs réglementés, ou MSP souhaitant intégrer la plateforme via l'API Claude.

**Agents inclus : tout MSP +**

| Agent | Rôle principal |
|---|---|
| **IT-ComplianceMaster** | Audit conformité 5 piliers, audit Entra ID, audit Purview, rapport client facturable |
| **IT-SecurityMaster** | Sécurité — audit, réponse aux incidents, SOC, renseignement sur les menaces |

**Fonctions exclusives ENTERPRISE :**
- Audit de conformité structuré sur 5 piliers (détail section 5, Module 09)
- Audit Entra ID complet (politiques d'accès, MFA, PIM, Conditional Access)
- Audit Purview (classification des données, DLP, rétention)
- Rapport d'audit client facturable généré automatiquement
- Orchestration Claude API pour intégrations personnalisées

---

## 5. Les 9 modules

Les modules regroupent les agents par domaine opérationnel. Un MSP peut identifier rapidement les modules couverts par sa gamme.

---

### Module 01 — NOC & Urgence

**Couverture :** Détection d'incidents, escalades NOC, gestion de crise P0/P1, dispatch.

**Agents :** IT-MonitoringMaster, IT-NOCDispatcher, IT-UrgenceMaster, IT-Commandare-NOC

**Cas d'usage :** Alerte critique à 2h du matin. IT-MonitoringMaster analyse l'alerte, détermine la sévérité, génère la procédure de réponse. Si P1 confirmé, IT-UrgenceMaster prend en charge avec le format d'incident structuré et la communication client prête.

---

### Module 02 — Support technique N1/N2/N3

**Couverture :** Triage tickets entrants, résolution N2 standard avec mentorat, escalades N3 complexes.

**Agents :** IT-FrontLine, IT-Assistant-N2, IT-Assistant-N3, IT-TicketOpr, IT-TicketScribe

**Cas d'usage :** Ticket entrant — IT-FrontLine classe, IT-TicketOpr analyse et suggère le runbook, IT-Assistant-N2 guide la résolution avec garde-fous, IT-TicketScribe documente.

---

### Module 03 — Infrastructure (AD / Azure / M365)

**Couverture :** Administration Active Directory, Azure, Microsoft 365, Entra ID, GPO, politiques.

**Agents :** IT-SysAdmin, IT-CloudMaster, IT-Commandare-Infra

**Cas d'usage :** Création d'un utilisateur M365 avec boîte Exchange, licences et groupes. IT-SysAdmin génère la séquence PowerShell complète et la checklist de validation post-création.

---

### Module 04 — Maintenance, Patching & Backup/DR

**Couverture :** Fenêtres de maintenance planifiées, patching serveurs/postes, validation sauvegardes, tests de reprise.

**Agents :** IT-MaintenanceMaster, IT-BackupDRMaster

**Cas d'usage :** Maintenance mensuelle d'un serveur Windows. IT-MaintenanceMaster produit : checklist pre-maintenance, instructions snapshot, séquence de patching, procédure de rollback, checklist post-maintenance, rapport de maintenance client.

---

### Module 05 — Sécurité (Audit / IR / SOC)

**Couverture :** Audits de sécurité, réponse aux incidents, threat intelligence, hardening.

**Agents :** IT-SecurityMaster, IT-Commandare-TECH

**Cas d'usage :** Détection d'activité suspecte sur un compte M365. IT-SecurityMaster guide la réponse : isolation, investigation, containment, rapport d'incident structuré.

---

### Module 06 — Knowledge & Documentation (KB / Hudu / CW / QBR)

**Couverture :** Base de connaissance, documentation client Hudu, notes CW, rapports QBR.

**Agents :** IT-KnowledgeKeeper, IT-ClientDocMaster, IT-ReportMaster, IT-TicketScribe

**Cas d'usage :** Fin de trimestre. IT-ReportMaster génère le QBR complet : résumé des incidents, uptime, tendances, recommandations, prêt pour la présentation client.

---

### Module 07 — Réseau & VoIP (Firewall / Switch / VPN)

**Couverture :** Configuration réseau, VLAN, VPN site-à-site, WiFi, Firewall, téléphonie VoIP 3CX.

**Agents :** IT-NetworkMaster, IT-VoIPMaster

**Cas d'usage :** Mise en place d'un VLAN invité avec isolation. IT-NetworkMaster produit la configuration Cisco/Meraki/Fortinet, la procédure de test, et la documentation à verser dans Hudu.

---

### Module 08 — Scripting & Automatisation (PowerShell / RMM)

**Couverture :** Scripts PowerShell pour RMM (N-able, ConnectWise Automate, Datto RMM), automatisation opérationnelle.

**Agents :** IT-ScriptMaster, IT-TicketOpr (commande `/script`)

**Cas d'usage :** IT-TicketOpr — commande `/script` sur un ticket de nettoyage disque. Génère un script PowerShell complet, signé pour déploiement RMM, avec gestion d'erreurs et logging.

---

### Module 09 — Compliance & Audit (5 Piliers / Entra / Purview)

**Couverture :** Audit de conformité structuré sur 5 piliers, audit Entra ID, audit Purview, rapport client facturable. Périmètres : Loi 25 (Québec), PCI-DSS, HIPAA, cyber-assurance.

**Agent :** IT-ComplianceMaster

**Les 5 piliers d'audit :**

| Pilier | Description |
|---|---|
| **Lifecycle Risk** | Gestion du cycle de vie des actifs — postes, serveurs, licences hors support |
| **Governance Integrity** | Gouvernance IT — politiques, documentation, contrôles d'accès |
| **Continuity Assurance** | Continuité des opérations — backup, DR, RPO/RTO documentés |
| **Exposure Surface** | Surface d'exposition — vulnérabilités, ports exposés, identités à risque |
| **Operational Drift** | Dérive opérationnelle — écarts entre la configuration documentée et la réalité |

**Livrable :** Rapport d'audit client structuré, gap analysis, plan de remédiation priorisé — directement facturable comme service de conseil.

---

## 6. Ce que l'agent produit concrètement

### IT-TicketOpr — Exemple de flux complet

**Commandes disponibles :**

| Commande | Output |
|---|---|
| `/start` | Triage structuré du ticket + runbook suggéré + niveau de priorité |
| `/script` | Script PowerShell complet prêt pour déploiement RMM |
| `/close` | Menu de clôture CW structuré (temps, résolution, catégorie, note) |
| `/analyse` | Analyse approfondie de l'incident — causes probables, historique |
| `/risques` | Évaluation des risques associés à l'incident |
| `/rapport-client` | Rapport d'incident formaté pour communication client |
| `/rapport-coordo` | Rapport de coordination pour chef d'équipe ou NOC |

**Exemple — `/close` sur un ticket de panne réseau :**

```
NOTE INTERNE CW (prête à coller)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Type : Panne réseau — Switch de distribution
Symptôme initial : Perte de connectivité partielle — VLAN 20 (Finance)
Diagnostic : Port trunk dégradé — interface Gi0/1 en err-disabled
Action corrective : Shutdown / no shutdown interface + vérification SFP
Validation : Connectivité VLAN 20 restaurée — ping 0% perte
Durée : 45 min
Impact client : 8 postes Finance hors ligne 45 minutes

DISCUSSION CLIENT (prête à coller)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bonjour [Client],

Suite à votre ticket #12345 — nous avons identifié et résolu une
interruption de connectivité affectant le département Finance.

Cause : Un port réseau sur l'équipement de distribution est entré
en état d'erreur, bloquant le trafic vers 8 postes.

Action : Le port a été réinitialisé et la connectivité est
pleinement restaurée depuis 14h32.

Aucune perte de données. Aucune action requise de votre part.
Nous surveillons l'équipement pour détecter toute récurrence.

[Technicien] — Équipe Support MSP
```

---

### IT-Assistant-N2 — Mentorat intégré

Quand un technicien N2 ouvre `IT-Assistant-N2` sur un ticket, l'agent pose 3 questions structurées avant de répondre :

1. Est-ce la première fois que tu traites ce type de problème ?
2. Quel est ton niveau de confort avec cette technologie (1-5) ?
3. Le client est-il en ligne avec toi en ce moment ?

Ces réponses calibrent le niveau de détail des instructions (étape par étape vs résumé), le ton (client au téléphone vs travail en autonomie) et les garde-fous activés (hors scope N2 → message `/chef` généré automatiquement).

**Commande `/chef` — message prêt pour chef d'équipe :**
```
Bonjour [Chef],

Je travaille sur le ticket #12346 — [Client] — problème de
synchronisation OneDrive persistant après tentatives standard N2.

Contexte : [résumé structuré de ce qui a été tenté]
Blocage : Accès aux logs d'audit M365 requis — hors accès N2
Action demandée : Escalade N3 ou accès temporaire console admin

Disponible pour passation immédiate.
[Technicien N2]
```

---

### IT-MaintenanceMaster — Output maintenance planifiée

Pour une fenêtre de maintenance standard, IT-MaintenanceMaster produit dans l'ordre :

1. **Checklist pre-maintenance** — vérifications à effectuer 24h et 1h avant
2. **Instructions snapshot** — commandes Hyper-V/VMware/Veeam selon l'environnement
3. **Séquence de patching** — ordre des serveurs, timing, points de validation intermédiaires
4. **Procédure de rollback** — étapes si un patch cause une régression
5. **Checklist post-maintenance** — validations de services, tests fonctionnels
6. **Rapport de maintenance** — document client et document interne

---

### IT-ComplianceMaster — Rapport d'audit facturable

Structure du rapport généré :

```
RAPPORT D'AUDIT DE CONFORMITÉ — [CLIENT] — [DATE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SOMMAIRE EXÉCUTIF
Score global : 67/100
Piliers critiques : Exposure Surface (42/100), Operational Drift (51/100)
Piliers conformes : Continuity Assurance (84/100)

PILIER 1 — LIFECYCLE RISK : 71/100
[analyse détaillée + liste des actifs hors support]

PILIER 2 — GOVERNANCE INTEGRITY : 68/100
[analyse + lacunes documentées]

PILIER 3 — CONTINUITY ASSURANCE : 84/100
[analyse + validation DR]

PILIER 4 — EXPOSURE SURFACE : 42/100
[analyse + vulnérabilités identifiées — CRITIQUE]

PILIER 5 — OPERATIONAL DRIFT : 51/100
[analyse + écarts configuration/documentation]

PLAN DE REMÉDIATION
Priorité 1 (0-30 jours) : [liste actions critiques]
Priorité 2 (30-90 jours) : [liste actions importantes]
Priorité 3 (90-180 jours) : [liste améliorations planifiées]
```

---

## 7. Intégration dans le workflow MSP

### Outils MSP supportés

| Outil | Mode d'intégration |
|---|---|
| **ConnectWise Manage** | Templates de notes, discussions, timesheet entries — format natif CW |
| **N-able N-central / N-sight** | Scripts PowerShell générés pour déploiement direct via RMM |
| **ScreenConnect** | Procédures d'intervention à distance documentées |
| **Hudu** | Documentation structurée prête pour import dans les articles Hudu |
| **Veeam / Datto** | Runbooks de validation spécifiques, commandes CLI incluses |
| **ChatGPT** | Déploiement via GPT personnalisés — chaque agent est un GPT configurable |
| **Claude.ai** | Utilisation directe dans l'interface Claude (Pro ou Team) |
| **API Claude** | Orchestration programmatique — Gamme ENTERPRISE |

### Modes de déploiement

**Mode ChatGPT (Gamme STARTER à MSP) :**
Chaque agent est déployé comme un GPT personnalisé dans ChatGPT. Le technicien ouvre le GPT correspondant au contexte, colle l'information du ticket, donne la commande.

**Mode Claude.ai :**
Utilisation directe dans l'interface Claude.ai avec les prompts agents configurés. Idéal pour les équipes avec abonnement Claude Pro ou Team.

**Mode API Claude (Gamme ENTERPRISE) :**
Intégration directe dans les outils internes du MSP via l'API Anthropic. Possibilité d'automatiser le routing IT-OPS-RouterIA et de connecter les agents aux systèmes RMM et PSA.

### Flux de travail type — Technicien N2, ticket entrant

```
1. Ticket entrant dans ConnectWise
   ↓
2. Technicien ouvre IT-TicketOpr → commande /start
   ↓
3. Triage structuré + runbook suggéré affiché (< 30 secondes)
   ↓
4. Technicien suit le runbook, résout l'incident
   ↓
5. Commande /close → menu de clôture CW généré
   ↓
6. Technicien colle la note CW + la discussion client
   ↓
7. Ticket fermé — documentation complète — < 2 minutes de rédaction
```

**Avant :** 20-30 minutes de documentation par ticket complexe
**Après :** 1-2 minutes — livrable prêt à coller

---

## 8. Comment démarrer

### Étape 1 — Choisir la gamme

Identifiez la gamme correspondant à votre profil :

| Gamme | Profil MSP |
|---|---|
| STARTER | 1-5 techniciens, objectif documentation et support N2 |
| PRO | Équipe complète N1/N2/N3, maintenance et réseau couverts |
| MSP | Opérations NOC, clients multiples, automatisation routing |
| ENTERPRISE | Conformité réglementaire, clients secteurs réglementés, intégration API |

### Étape 2 — Déploiement des agents

Les agents sont livrés sous forme de prompts configurés, prêts à déployer dans :
- ChatGPT (GPT personnalisés)
- Claude.ai (instructions système)
- API Claude (Gamme ENTERPRISE)

Délai de mise en route : **moins d'une journée** pour STARTER. Une semaine pour MSP/ENTERPRISE incluant la personnalisation des templates aux noms et formats du MSP.

### Étape 3 — Personnalisation

Les templates CW et les communications client sont adaptés aux formats utilisés par votre MSP : en-têtes, signatures, nomenclature des catégories CW, noms des équipes.

### Étape 4 — Formation

Pas de formation longue requise. Les agents sont conçus pour être utilisables immédiatement par un technicien N2 sans documentation préalable. Les commandes `/start`, `/close`, `/script` sont intuitives.

Un kit de démarrage est fourni : 1 fiche de référence rapide par agent (commandes, cas d'usage, exemples).

---

## 9. Annexe — Répertoire complet des 33 agents

### Équipe OPS — Infrastructure interne (5 agents)

| Agent | Rôle | Gamme |
|---|---|---|
| IT-OPS-RouterIA | Routing automatique des intents — 87 scénarios | MSP+ |
| IT-OPS-PlaybookRunner | Exécution des playbooks multi-agents | Interne |
| IT-OPS-DossierIA | Archivage et traçabilité des runs | Interne |
| IT-QAMaster | Qualité plateforme — incidents et correctifs | Interne |
| IT-OPS-SyncFactory | Synchronisation et rapports de mise à jour | Interne |

### Équipe Métier — Agents opérationnels (28 agents)

| Agent | Rôle | Module | Gamme min. |
|---|---|---|---|
| IT-FrontLine | Premier contact, triage tickets entrants | 02 | STARTER |
| IT-Assistant-N2 | Support N2 avec mentorat et garde-fous | 02 | STARTER |
| IT-TicketOpr | Traitement intelligent des tickets, scripts inline | 02 | STARTER |
| IT-TicketScribe | Rédaction notes CW, discussions, rapports | 02/06 | STARTER |
| IT-Assistant-N3 | Support N3 — escalades complexes | 02 | PRO |
| IT-SysAdmin | Administration AD, Azure, M365, Entra | 03 | PRO |
| IT-TechOnsite | Opérations terrain, interventions sur site | 02 | PRO |
| IT-MaintenanceMaster | Maintenance planifiée, patching, rapports | 04 | PRO |
| IT-BackupDRMaster | Backup, DR, Veeam, Datto | 04 | PRO |
| IT-NetworkMaster | Réseau, VLAN, VPN, Firewall, Switch | 07 | PRO |
| IT-NOCDispatcher | Dispatch NOC, escalades, assignation | 01 | MSP |
| IT-MonitoringMaster | Supervision NOC, analyse alertes | 01 | MSP |
| IT-CloudMaster | Infrastructure cloud — Azure, AWS, M365 | 03 | MSP |
| IT-UrgenceMaster | Urgences P0/P1, gestion de crise | 01 | MSP |
| IT-OnOffBoarder | Transitions onboarding/offboarding client et employé | 02 | MSP |
| IT-ReportMaster | Rapports clients, KPIs, QBR | 06 | MSP |
| IT-AssetMaster | CMDB, gestion des actifs, cycle de vie | 03 | MSP |
| IT-SecurityMaster | Sécurité, incidents, SOC, threat intel | 05 | ENTERPRISE |
| IT-ComplianceMaster | Audit conformité 5 piliers, Entra, Purview | 09 | ENTERPRISE |
| IT-VoIPMaster | Téléphonie VoIP, 3CX, configuration | 07 | PRO |
| IT-ScriptMaster | Scripts PowerShell, automatisation | 08 | PRO |
| IT-KnowledgeKeeper | Base de connaissance, documentation interne | 06 | MSP |
| IT-ClientDocMaster | Documentation client Hudu, procédures | 06 | MSP |
| IT-Commandare-NOC | Commandement NOC | 01 | MSP |
| IT-Commandare-TECH | Commandement technique | 02 | PRO |
| IT-Commandare-Infra | Commandement infrastructure | 03 | PRO |
| IT-Commandare-OPR | Commandement opérations | 02 | MSP |
| IT-OnboardingMaster | Découverte client MSP (legacy — remplacé par IT-OnOffBoarder) | 02 | PRO |

---

### Ressources incluses par gamme

| Ressource | STARTER | PRO | MSP | ENTERPRISE |
|---|---|---|---|---|
| Runbooks validés | 22 | 55 | 78 | 91 |
| Templates CW/client | 20 | 38 | 55 | 65 |
| Scripts PowerShell | 8 | 18 | 24 | 28 |
| Intents routés auto | — | — | 87 | 87 |
| Modules couverts | 2 | 5 | 8 | 9 |

---

*EA|IA — MSP Intelligence IT V1 — 2026-05-23*
*Document confidentiel — Reproduction interdite sans autorisation*
