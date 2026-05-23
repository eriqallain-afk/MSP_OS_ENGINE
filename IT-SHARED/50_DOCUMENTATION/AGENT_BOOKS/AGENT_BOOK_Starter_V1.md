# AGENT BOOK — Tier Starter
**ID :** AGENT_BOOK_Starter_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Agents couverts :** IT-FrontLine · IT-Assistant-N2 · IT-TicketScribe

---

## Ce tier comprend

Le Starter couvre la réception, le support N1/N2 guidé et la documentation de base des billets. C'est le point d'entrée de tout technicien dans l'écosystème IA : les agents guident étape par étape, génèrent les livrables CW prêts à coller, et assurent une communication uniforme vers le client.

| Agent | Rôle | Audience |
|---|---|---|
| IT-FrontLine | Réception et triage des billets entrants | N1/N2 — Frontdesk |
| IT-Assistant-N2 | Copilote live pour support N2 (client en ligne) | N1/N2 — Techniciens helpdesk |
| IT-TicketScribe | Scribe — transforme les notes brutes en livrables CW | Toute l'équipe |

---

## IT-FrontLine

> **Rôle :** Agent de la queue téléphonique. Le client est au téléphone. Entre les appels, traite les billets MSPBOT reçus via Microsoft Teams.

**Audience :** Technicien N1/N2 connecté à la queue téléphonique — frontdesk, première ligne.

**Distinction avec IT-Assistant-N2 :** FrontLine = client au téléphone (rythme live, script d'accueil, pas de silence). Assistant-N2 = copilote technique pour une résolution N2 plus approfondie.

**Deux modes de travail :**
- **Appel entrant** : client en ligne → pace rapide, `/appel` immédiat, transfert structuré si hors N2
- **Entre les appels** : billets MSPBOT (Teams) → `/ticket #XXXXX`, documentation CW complète

### Capacités principales
- Script d'accueil téléphonique avec identification caller (nom, entreprise, billet)
- Résolution N2 en scope : MDP, comptes, WiFi, logiciels, VPN, OneDrive, SharePoint
- Traitement des billets MSPBOT (Microsoft Teams) entre les appels
- Détection multi-utilisateurs : 5+ usagers impactés → NOCDispatcher automatiquement
- Escalade P1 immédiate avec protocole de notification
- Génération de notes de triage CW structurées avant tout transfert

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/appel` | Script d'accueil + identification caller | Dès qu'un appel entre |
| `/ticket #XXXXX` | Traitement billet N2 : plan immédiat | Billet reçu de MSPBOT |
| `/triage` | Note CW de triage avant transfert | Avant toute escalade |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Besoin de procédure |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Note interne de triage (avec catégorie, priorité, impact, plan)
- Routing documenté avant transfert
- Discussion client-safe si billet résolu

### 🔧 Pistes d'amélioration
- Ajouter `/bulk [contexte]` pour les journées de réception massive (panne de site, migration)
- Enrichir le script `/appel` avec validation de l'identité client (sécurité)
- Ajouter une commande `/escalade [agent]` avec bloc CW de transfert pré-rempli, prêt à coller

---

## IT-Assistant-N2

> **Rôle :** Mentor et filet de sécurité pour techniciens N2 en début de carrière. Guide étape par étape, détecte quand la situation dépasse les compétences du tech, prépare les communications vers le chef d'équipe.

**Audience :** Technicien N2 junior — sortant de formation, premiers mois en poste.

**Déclencheur typique :** Billet ouvert, tech incertain sur la marche à suivre, client en attente, besoin d'une procédure pas-à-pas ou d'un avis avant d'agir.

**Priorités de l'agent (dans l'ordre) :**
1. Guider — procédure adaptée au niveau du tech
2. Protéger — détecter quand ça dépasse les compétences et le dire clairement
3. Communiquer — préparer le message au chef d'équipe quand requis

### Capacités principales
- Évaluation du niveau de confort du tech au démarrage (première fois sur ce type de billet ?)
- Guidance numérotée avec explication du POURQUOI à chaque étape
- Gestion AD : réinitialisation compte, déverrouillage, groupes, MDP expiré
- M365 : licences, Outlook, boîte partagée, calendrier, délégation
- VPN, OneDrive, SharePoint, RDS, imprimantes
- Génération de blocs CW (Discussion, Note) prêts à coller
- Chargement automatique de runbooks selon le contexte détecté
- Message chef d'équipe généré mot pour mot (avis préventif ou escalade)

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/start [#billet]` | Évaluation du tech + plan immédiat | Début de billet |
| `/guide [étape ou sujet]` | Étapes numérotées avec explication du POURQUOI | Besoin de procédure |
| `/chef [situation]` | Message prêt à envoyer au chef d'équipe | Avis préventif ou escalade |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/call [résumé]` | Résumé de fin d'appel + Note CW | Fin d'appel |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Discussion CW (formulation client-safe, phrase d'ouverture obligatoire, min 4 bullets)
- Note interne technique
- Message chef d'équipe (avis préventif ou escalade) — prêt à envoyer via Teams
- Bloc de transfert si escalade

### Règles de production
- **Blocs séparés obligatoires** : script PowerShell dans son bloc, explication en texte, livrable CW dans son propre bloc
- Phrase d'ouverture Discussion : `Prise en connaissance de la demande et consultation de la documentation.`
- Jamais d'IP ni credentials dans les livrables client

### 🔧 Pistes d'amélioration
- Ajouter `/call [résumé]` : génère un résumé de fin d'appel + note CW en 30 secondes
- Ajouter des modèles de phrases pour mettre un client en attente (`« Je vous mets en attente 2 minutes... »`)
- Intégrer un bloc de validation post-résolution : « Le problème est-il résolu pour l'usager ? »

---

## IT-TicketScribe

> **Rôle :** Scribe IA. Transforme notes brutes, conversations et contextes en livrables CW propres, uniformes et prêts à envoyer.

**Audience :** Tous les techniciens — utilisé en fin d'intervention pour documenter et fermer proprement.

**Déclencheur typique :** Fin d'appel, fin d'intervention, besoin de rédiger une communication client ou une note interne.

### Capacités principales
- Note Interne CW (technique, complète, factuelle)
- Discussion CW (client-safe, STAR, 4+ bullets minimum)
- Email professionnel client
- Brief Hudu pour IT-ClientDocMaster
- Brief KB pour IT-KnowledgeKeeper
- Respect strict du format CW Standard : phrase d'ouverture imposée, aucune IP, aucun credential

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/note [contexte]` | CW Note Interne technique | Documentation interne |
| `/discussion [contexte]` | CW Discussion client-safe (STAR) | Communication billet client |
| `/email [contexte]` | Email client professionnel | Suivi ou clôture par courriel |
| `/edocs [contexte]` | Brief pour IT-ClientDocMaster (fiche Hudu) | Nouvelle config à documenter |
| `/kb` | Brief pour IT-KnowledgeKeeper | Nouvelle procédure/fix à archiver |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW complet | Fin d'intervention |

### Sorties CW
- Note interne, Discussion, Email
- Brief Hudu (transmission à IT-ClientDocMaster)
- Brief KB (transmission à IT-KnowledgeKeeper)

### Règles de production
- Discussion : phrase d'ouverture `Prise en connaissance de la demande...` + min 4 bullets
- Jamais d'IP/credentials dans les livrables externes
- Blocs séparés : livrable CW dans son propre bloc `text`, script dans `powershell`

### 🔧 Pistes d'amélioration
- Ajouter `/memo [destinataire]` : mémo interne court (NOC, coordonnateur, équipe)
- Ajouter `/teams [contexte]` : notice Teams pour mise à jour d'équipe
- Ajouter une validation automatique de qualité avant livraison : longueur Note, présence phrase d'ouverture Discussion, absence d'IP/credentials

---

## Index des commandes — Tier Starter

| Agent | Commande | Description |
|---|---|---|
| IT-FrontLine | `/appel` | Script d'accueil et identification caller |
| IT-FrontLine | `/ticket #XXXXX` | Traitement billet N2 avec plan immédiat |
| IT-FrontLine | `/triage` | Note CW de triage avant transfert |
| IT-FrontLine | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-FrontLine | `/close` | Menu de clôture CW |
| IT-Assistant-N2 | `/start [#billet]` | Initialiser intervention avec plan |
| IT-Assistant-N2 | `/guide [étape]` | Étapes numérotées détaillées |
| IT-Assistant-N2 | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-Assistant-N2 | `/close` | Menu de clôture CW |
| IT-TicketScribe | `/note [contexte]` | CW Note Interne |
| IT-TicketScribe | `/discussion [contexte]` | CW Discussion client-safe |
| IT-TicketScribe | `/email [contexte]` | Email client professionnel |
| IT-TicketScribe | `/edocs [contexte]` | Brief Hudu (IT-ClientDocMaster) |
| IT-TicketScribe | `/kb` | Brief KB (IT-KnowledgeKeeper) |
| IT-TicketScribe | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-TicketScribe | `/close` | Menu de clôture CW complet |

---

*AGENT_BOOK_Starter_V1 — IT MSP Intelligence — 2026-05-14*
