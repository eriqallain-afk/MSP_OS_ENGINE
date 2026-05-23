# IT MSP Intelligence — Fiche Produit Starter V1

> **Édition : Mai 2026 | Version : 1.0 | Confidentiel — Usage Interne & Demo**

---

## Section 1 — Le produit Starter en une page

### Opère comme un MSP de 20 personnes dès le premier jour.

Tu viens de décrocher ton premier client. Ou ton cinquième. Tu travailles seul, avec un partenaire, ou avec une petite équipe de techniciens. Tu sais faire le travail — mais entre les billets, la documentation, les rapports, et les appels clients, il te manque du temps et de la structure.

**IT MSP Intelligence — Starter** est conçu pour ça.

C'est un système de 7 agents IA spécialisés, chacun ayant un rôle précis dans ton opération. Ensemble, ils forment une équipe virtuelle qui :
- Répond aux appels et gère les billets comme un N1 expérimenté
- Structure chaque intervention en note CW professionnelle
- Transforme chaque ticket résolu en article de base de connaissances
- Documente chaque client automatiquement dans Hudu
- Génère un rapport Discovery facturable dès le premier onboarding

**Ce que le tech peut faire dès le premier jour :**

- Ouvrir un billet structuré en 30 secondes avec `/ticket`
- Lancer un appel support guidé avec `/appel`
- Démarrer un déploiement avec `/start deploiement`
- Capturer une procédure après chaque intervention avec `/capture`
- Générer la documentation client avec `/doc`
- Lancer une Discovery complète avec `/start`

Pas de formation de 3 mois. Pas de consultant externe. Tu as les outils d'un MSP mature — dès aujourd'hui.

---

## Section 2 — Les 7 agents inclus dans Starter

| Agent | Rôle | Commande clé |
|---|---|---|
| **IT-FrontLine** | Support utilisateur — appels, billets, reset MDP, Outlook, imprimantes | `/appel`, `/ticket` |
| **IT-TechOPS** | Opérations terrain — déploiements, migrations, configs, precheck/postcheck | `/start deploiement` |
| **IT-TicketOpsAI** | Qualité des billets — triage, notes CW, fermeture propre, Definition of Done | `/triage`, `/close` |
| **IT-OPS-RouterIA** | Intelligence de routage — sélectionne le bon agent ou runbook automatiquement | automatique |
| **IT-KnowledgeKeeper** | Capitalisation — transforme chaque intervention résolue en article KB | `/capture` |
| **IT-ClientDocMaster** | Documentation client — fiches client, procédures, synchronisation Hudu | `/doc` |
| **IT-OnboardingMaster** | Discovery client — rapport "Mise à niveau" facturable en deux phases | `/start`, `/livraison` |

### Détail des agents

#### IT-FrontLine
L'agent de première ligne. Il gère les appels entrants, guide le tech pendant une intervention en direct, et produit une note CW structurée à la fin. Il connaît les scénarios les plus fréquents : reset de mot de passe, problèmes Outlook, imprimante déconnectée, OneDrive qui ne synchronise pas. Il ne remplace pas le tech — il l'assiste en temps réel.

#### IT-TechOPS
L'agent opérationnel terrain. Quand il faut déployer un poste, migrer un utilisateur, configurer un appareil réseau ou valider une installation, IT-TechOPS guide le tech étape par étape avec des prechecks, des étapes claires, et des postchecks. Il réduit les erreurs et garantit que chaque intervention est traçable.

#### IT-TicketOpsAI
L'agent qualité. Il analyse un ticket brut, le classe, détecte les informations manquantes, et produit une note CW conforme aux standards professionnels. Il applique la Definition of Done à chaque fermeture de billet : la note est complète, le client a été informé, la KB est à jour.

#### IT-OPS-RouterIA
L'agent d'intelligence centrale. Tu décris ta situation, il sélectionne le bon agent ou le bon runbook. Pas besoin de savoir quel outil utiliser — le routeur le sait pour toi. Chargé automatiquement à chaque session.

#### IT-KnowledgeKeeper
L'agent de capitalisation. Après chaque intervention résolue, il transforme les notes du tech en article de base de connaissances structuré. À la fin de l'année, ton MSP a une KB complète et réutilisable — sans effort manuel supplémentaire.

#### IT-ClientDocMaster
L'agent documentation. Il maintient les fiches client à jour dans Hudu : contacts, matériel, logiciels, procédures spécifiques, accès. Chaque intervention peut enrichir la documentation. Le prochain tech qui intervient chez ce client part préparé.

#### IT-OnboardingMaster
L'agent Discovery. Il guide le tech à travers deux phases d'analyse complète d'un nouvel environnement client. Le résultat : une baseline documentée dans Hudu et une présentation "Mise à niveau" professionnelle, livrable et facturable au client.

---

## Section 3 — Les runbooks Starter (procédures opérationnelles)

Les runbooks sont des procédures structurées que les agents utilisent automatiquement. En Starter, tu as accès aux runbooks suivants :

### Support & Triage
| Runbook | Description |
|---|---|
| `SUP-N1N2-SupportTriage` | Triage initial — classification, urgence, assignation |
| `SUP-N2-Support` | Résolution N2 — escalade structurée avec documentation |
| `SUP-OPS-CW_Dispatch` | Dispatch ConnectWise — création et assignation de billets |

### Communication & Fermeture
| Runbook | Description |
|---|---|
| `SUP-OPS-CW_InterventionLive_Close` | Fermeture propre après intervention en direct |
| `SUP-OPS-TicketToKB` | Conversion d'un ticket résolu en article KB |

### M365 Utilisateur
| Runbook | Description |
|---|---|
| `SUP-M365-OneDrive_SharePoint_Sync` | Dépannage OneDrive et SharePoint — synchronisation et accès |

### Réseau & VPN
| Runbook | Description |
|---|---|
| `SUP-NET-VPN_Troubleshooting` | Dépannage VPN — connectivité, credentials, routage |
| `INFRA-NET-NetworkDiagnostic` | Diagnostic réseau général — ping, tracert, DNS, DHCP |

### Serveur (lecture seule)
| Runbook | Description |
|---|---|
| `MAINT-SRV-HealthCheck` | Vérification santé serveur — lecture seule, aucun changement |

### Discovery
| Runbook | Description |
|---|---|
| `RUNBOOK__SERVER_ROLE_DISCOVERY` | Découverte des rôles serveur — inventaire et baseline |

> **Note :** Les runbooks Starter sont classés `SAFE_READONLY` ou `LOW_RISK`. Aucun runbook Starter ne modifie les systèmes sans confirmation explicite du tech.

---

## Section 4 — Templates inclus

Chaque agent dispose de templates de communication prêts à l'emploi. En Starter, tu as accès aux templates suivants :

| Template | Usage | Agent |
|---|---|---|
| **CW Note Interne** | Note technique pour les billets ConnectWise — détails techniques, actions, résolution | IT-TicketOpsAI |
| **CW Discussion (client-safe)** | Note visible par le client — langage simplifié, sans jargon technique | IT-FrontLine |
| **Email client simple** | Confirmation d'intervention, suivi, fermeture — ton professionnel et clair | IT-FrontLine |
| **Teams Notice — Maintenance** | Avis de maintenance planifiée pour le channel Teams du client | IT-TechOPS |
| **Teams Notice — Incident** | Communication d'incident en cours — transparence et mise à jour | IT-FrontLine |
| **KB Article** | Article de base de connaissances structuré — titre, symptômes, solution, prévention | IT-KnowledgeKeeper |
| **Rapport Discovery Interne** | Baseline technique complète pour usage interne et Hudu | IT-OnboardingMaster |
| **Présentation "Mise à niveau" Client** | Rapport Discovery formalisé, livrable au client — facturable | IT-OnboardingMaster |
| **Fiche Client Hudu** | Fiche structurée pour Hudu — contacts, matériel, licences, procédures | IT-ClientDocMaster |
| **Precheck/Postcheck Déploiement** | Checklist avant et après intervention terrain | IT-TechOPS |

---

## Section 5 — Le service Discovery (add-on facturable)

### L'opportunité : transformer chaque nouvel onboarding en revenu immédiat

Le service Discovery est guidé par **IT-OnboardingMaster** en deux phases structurées.

#### Phase 1 — Terrain (sur site ou à distance)

Le tech parcourt l'environnement client avec IT-OnboardingMaster comme guide :

- **Réseau :** topologie, matériel actif, VLANs, DNS, DHCP, pare-feu
- **Serveurs :** rôles, OS, performances, dernières mises à jour, état backup
- **Backup :** solution en place, dernière validation, RPO/RTO réels vs contrat
- **Sécurité :** antivirus, MFA, politiques de mot de passe, accès admin
- **Licences :** M365, logiciels métier, contrats, dates d'expiration
- **Contacts :** décideur, contact technique, fournisseurs tiers

Durée estimée : 2 à 4 heures selon la taille de l'environnement.

#### Phase 2 — Validation RMM (automatisée)

IT-OnboardingMaster guide la validation via le RMM du MSP :
- Confirmation des assets inventoriés
- Vérification des alertes actives
- Validation de la couverture de monitoring
- Identification des lacunes de protection

#### Livrables

| Livrable | Destination | Contenu |
|---|---|---|
| **Baseline interne** | Hudu | Documentation complète de l'environnement, prête pour les interventions futures |
| **Présentation "Mise à niveau"** | Client | Rapport professionnel : état actuel, risques identifiés, recommandations priorisées |

#### Tarification

| | Montant |
|---|---|
| Coût Discovery pour le MSP | **249$/onboarding** |
| Prix de revente au client | **1,500$ à 5,000$** selon la complexité |
| Marge brute sur un onboarding typique (2,500$) | **~2,250$** |

#### ROI Discovery

Le premier onboarding Discovery paie **6 à 20 mois** d'abonnement Starter.

Un MSP avec 5 nouveaux clients par an génère **7,500$ à 25,000$** en revenus Discovery — avec le même abonnement à 299$/mois.

---

## Section 6 — Ce que Starter NE fait PAS (honnêteté produit)

IT MSP Intelligence — Starter est conçu pour les opérations courantes d'un MSP de 1 à 5 techniciens. Il n'est pas conçu pour les opérations avancées d'infrastructure.

**Hors scope Starter :**

| Capacité | Disponible en |
|---|---|
| Patching serveur automatisé (Windows Update, WSUS) | Pro, MSP Suite |
| Virtualisation (VMware, Hyper-V, migrations) | Pro, MSP Suite |
| Backup & Disaster Recovery (configuration, tests, validation) | Pro, MSP Suite |
| Changements de configuration firewall (règles, VPN site-à-site) | Pro, MSP Suite |
| Incident response critique (ransomware, breach) | Enterprise |
| Reporting exécutif automatisé (QBR, MBR) | Starter Strategic, Pro |
| Intégrations PSA avancées (automatisation billable) | MSP Suite |

**Pourquoi cette transparence ?**

Un Starter qui tente une opération hors scope sans les guardrails appropriés risque des erreurs coûteuses. IT-OPS-RouterIA détectera automatiquement les demandes hors scope et avertira le tech — mais la liste ci-dessus établit les limites claires dès le départ.

---

## Section 7 — Les gardes-fous (sécurité du produit)

La sécurité n'est pas une option — c'est un composant du produit.

### Guardrail maître

Un guardrail maître est chargé automatiquement à chaque session. Il définit :
- Le périmètre autorisé de l'agent actif
- Les actions qui nécessitent une confirmation explicite
- Les actions qui sont interdites en Starter

### Détection hors scope

Quand un tech soumet une demande hors scope (ex. : "configure le firewall"), l'agent :
1. Refuse d'exécuter la demande
2. Explique pourquoi c'est hors scope
3. Oriente vers la ressource appropriée (Pro, consultant, escalade)

Ce comportement est **obligatoire et non contournable**.

### Principe de confirmation

**Jamais d'action irréversible sans confirmation explicite.**

Avant toute action qui modifie un système (même en lecture seule étendue), l'agent présente :
- Ce qu'il va faire
- L'impact attendu
- Une demande de confirmation du tech

### Classification des scripts par risque

| Niveau | Description | Disponible en Starter |
|---|---|---|
| `SAFE_READONLY` | Lecture seule — aucun changement possible | Oui |
| `LOW_RISK` | Changements réversibles mineurs | Oui, avec confirmation |
| `MEDIUM_RISK` | Changements avec impact potentiel | Non — Pro et + |
| `HIGH_RISK` | Changements critiques d'infrastructure | Non — MSP Suite et + |
| `CRITICAL` | Incident response, DR, sécurité avancée | Non — Enterprise |

### Protection des credentials

**JAMAIS de credentials dans les livrables.**

Aucun mot de passe, clé API, token ou credential ne peut apparaître dans :
- Les notes CW générées
- Les articles KB
- Les rapports Discovery
- Les emails ou communications client

Les agents sont configurés pour détecter et supprimer toute tentative d'inclusion de credentials dans les outputs.

---

## Section 8 — ROI Starter

### Le calcul conservateur

| Poste | Calcul | Valeur mensuelle |
|---|---|---|
| Abonnement Starter Operations | — | -299$/mois |
| Temps économisé (5h/sem × 4 sem) | 20h × 40$/h | +800$/mois |
| Réduction des litiges (notes CW pro) | Estimé conservateur | +100$/mois |
| Capitalisation KB (réutilisation) | Estimé conservateur | +150$/mois |
| **ROI mensuel net (sans Discovery)** | | **+751$/mois** |

### Avec un seul Discovery

| Scénario | Montant |
|---|---|
| Discovery facturé au client | 2,500$ |
| Coût Discovery (abonnement) | 249$ |
| Marge brute | 2,251$ |
| Équivalent en mois d'abonnement | **7,5 mois payés** |

**Conclusion :** Avec un seul onboarding Discovery par trimestre, le Starter est autofinancé et génère un profit net — même pour un MSP solo.

### Projection annuelle

| Volume Discovery | Revenu Discovery | Coût abonnement annuel | ROI |
|---|---|---|---|
| 2 onboardings/an | 5,000$ | 3,588$ | +1,412$ |
| 5 onboardings/an | 12,500$ | 3,588$ | +8,912$ |
| 10 onboardings/an | 25,000$ | 3,588$ | +21,412$ |

*Calcul basé sur un prix Discovery moyen de 2,500$ et un abonnement Starter Operations à 299$/mois.*

---

## Section 9 — Comment démarrer

### En 3 étapes, en moins d'une journée

**Étape 1 — Accès à la plateforme**

L'onboarding MSP comprend la configuration initiale de la plateforme :
- Création des 7 agents GPT dans ton espace OpenAI
- Chargement des instructions et des guardrails
- Configuration du routeur IA
- Test de chaque agent

Durée : 1 heure guidée avec un spécialiste IT MSP Intelligence.
Coût : 1,500$ (ou inclus selon le palier d'entrée choisi).

**Étape 2 — Configuration des 7 agents**

Lors de la session d'onboarding, chaque agent est configuré selon ton contexte :
- Ton PSA (ConnectWise, Autotask, etc.)
- Ton RMM
- Ton outil de documentation (Hudu, IT Glue, etc.)
- Tes standards de communication (langue, ton, templates)

**Étape 3 — Premier cas réel**

Commence avec IT-FrontLine sur le prochain appel entrant, ou lance IT-OnboardingMaster sur ton prochain nouveau client.

Les deux premiers cas sont assistés par l'équipe IT MSP Intelligence — tu n'es jamais seul lors du démarrage.

---

## Section 10 — Feuille de prix Starter

### Plans mensuels

| Plan | Agents inclus | Fonctionnalités clés | Prix |
|---|---|---|---|
| **Starter Operations** | 7 agents | Runbooks, templates, support quotidien | **299$/mois** |
| **Starter Intelligence** | 7 agents | Operations + qualité billets, DoD, CAPA, métriques | **449$/mois** |
| **Starter Strategic** | 7 agents | Intelligence + rapports exécutifs mensuels, QBR automatisé | **599$/mois** |

### Add-ons

| Service | Description | Prix |
|---|---|---|
| **Discovery Add-on** | IT-OnboardingMaster + baseline interne + présentation client | **249$/onboarding** |
| **Onboarding plateforme** | Setup complet + formation 1h + 2 premiers cas assistés | **1,500$** |

### Comparaison des plans Starter

| Fonctionnalité | Operations | Intelligence | Strategic |
|---|---|---|---|
| 7 agents Starter | Oui | Oui | Oui |
| Runbooks Starter | Oui | Oui | Oui |
| Templates de communication | Oui | Oui | Oui |
| Discovery add-on disponible | Oui | Oui | Oui |
| Qualité billets & DoD | Non | Oui | Oui |
| CAPA & analyse récurrence | Non | Oui | Oui |
| Métriques opérationnelles | Non | Oui | Oui |
| Rapports exécutifs mensuels | Non | Non | Oui |
| QBR automatisé | Non | Non | Oui |
| Tableau de bord client | Non | Non | Oui |

### Engagement et conditions

- Engagement : mensuel, annuel disponible (2 mois offerts)
- Paiement : carte de crédit, facturation mensuelle
- Annulation : 30 jours de préavis
- Support : email + Teams, délai de réponse 24h ouvrables

---

## Résumé — Pourquoi Starter ?

> **Le problème des petits MSPs n'est pas le manque de compétences. C'est le manque de structure, de temps, et d'outils pour opérer comme une organisation mature.**

IT MSP Intelligence — Starter résout ce problème en donnant à un MSP de 1 à 5 techniciens les mêmes outils, les mêmes processus, et la même qualité de documentation qu'un MSP de 20 personnes — pour 299$/mois.

- Tes billets sont mieux documentés.
- Tes clients reçoivent des communications professionnelles.
- Chaque intervention enrichit ta base de connaissances.
- Chaque nouveau client génère un rapport Discovery facturable.
- Ton MSP grandit avec une structure solide dès le premier jour.

**C'est ça, la promesse Starter.**

---

*Document confidentiel — IT MSP Intelligence | Version 1.0 | Mai 2026*
*Pour toute question : sales@itmspintelligence.com*
