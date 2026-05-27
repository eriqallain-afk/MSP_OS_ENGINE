# OPR-ProblemManagement-CAPA_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-QAMaster | @IT-Commandare-OPR | @IT-KnowledgeKeeper | @IT-ReportMaster
**Scope :** Gestion des problèmes récurrents — analyse cause racine, actions correctives et préventives (CAPA), suivi et vérification

---

## Objectif

Transformer les incidents récurrents ou les patterns de défaillance en problèmes formels avec analyse de cause racine documentée, actions correctives et préventives assignées, et suivi jusqu'à la vérification complète. Réduire le volume d'incidents répétitifs, éliminer la dette technique invisible et démontrer l'amélioration continue au client.

---

## Définitions

| Terme | Définition |
|---|---|
| **Problème** | Cause sous-jacente d'un ou plusieurs incidents — peut être inconnu (problème connu) ou non encore identifié |
| **Erreur connue** | Problème dont la cause est documentée, même sans solution permanente disponible |
| **CAPA** | Corrective and Preventive Action — plan d'action structuré pour corriger et prévenir |
| **Workaround** | Solution temporaire permettant de rétablir le service sans résoudre la cause racine |

---

## Déclencheurs

- Même alerte ou même symptôme revient 3 fois ou plus dans les 90 jours
- Technicien applique le même correctif manuel pour la 2e fois
- Incident P1/P2 révèle un gap systémique (monitoring, processus, documentation)
- CAPA issu d'un PIR (OPR-PostIncident-Review) non résolu après 30 jours
- Dette technique documentée dans Hudu ou CW sans plan d'action actif
- QAMaster identifie un pattern lors de la revue qualité

---

## Prérequis

- Liste des incidents / tickets liés (IDs CW)
- Accès à Hudu pour lecture des actifs et KB existantes
- Propriétaire technique identifié pour l'analyse
- Accès au journal de tickets CW pour extraction du pattern
- Ticket "Problem Record" créé dans CW (type : Problem Management)

---

## Procédure

### Étape 1 — Constituer le dossier de problème

**1.1 — Identifier et regrouper les incidents liés**

```
CW → Service Desk → Rechercher par :
  - Même client + même type de symptôme dans les 90 jours
  - Même équipement ou même service mentionné
  - Même message d'erreur ou même alerte RMM

Documenter les incidents liés :
  Ticket #[ID1] — Date : [YYYY-MM-DD] — Résolution : [description courte]
  Ticket #[ID2] — Date : [YYYY-MM-DD] — Résolution : [description courte]
  Ticket #[ID3] — Date : [YYYY-MM-DD] — Résolution : [description courte]

Pattern identifié : [Fréquence, conditions, environnement]
```

**1.2 — Créer le Problem Record dans CW**

```
CW → + New Ticket
  Type : Problem Management
  Titre : "PROBLÈME — [CLIENT] — [Description courte du pattern]"
  Priorité : P2 (ou P1 si risque critique)
  Assigner à : Propriétaire technique + @IT-QAMaster
  Lier les tickets incidents : [IDs]
  Note Interne initiale : "Problem Record ouvert — pattern : [X occurrences en Y jours]"
```

---

### Étape 2 — Définir l'énoncé du problème

```
Rédiger l'énoncé du problème en deux versions :

VERSION INTERNE (technique) :
"Le service [X] sur le serveur [Y] du client [Z] tombe en panne [fréquence] à cause de [symptôme observable]. 
Le workaround actuel est [description du fix manuel]. 
La cause racine n'est pas encore résolue."

VERSION CLIENT-SAFE (pour communication) :
"Le service [ex. : système de fichiers partagés] du client [Z] connaît des interruptions périodiques 
nécessitant une intervention technique répétée. Nous avons ouvert un dossier de problème pour 
identifier et éliminer la cause permanente."
```

---

### Étape 3 — Analyse de cause racine (RCA)

**Méthode des 5 Pourquoi :**

```
Symptôme : [Description du comportement observable]

Pourquoi 1 : [Question] → [Réponse technique]
Pourquoi 2 : [Question] → [Réponse technique]
Pourquoi 3 : [Question] → [Réponse technique]
Pourquoi 4 : Pourquoi n'a-t-on pas détecté / prévenu cela ? → [Gap de monitoring / processus / KB]
Pourquoi 5 : Pourquoi ce gap existait-il ? → [Cause racine]

CAUSE RACINE : [Énoncé clair et vérifiable]
```

**Méthode diagramme d'Ishikawa (5M) — pour les problèmes complexes :**

```
Catégories à explorer :
  Méthode   : Procédures incorrectes ? Runbook absent ? Workaround inadapté ?
  Machine   : Matériel défaillant ? Configuration incorrecte ? EOL/EOS ?
  Matière   : Logiciel bogué ? Version incompatible ? Données corrompues ?
  Main d'œuvre : Formation insuffisante ? Turnover ? Erreur humaine récurrente ?
  Milieu    : Environnement instable ? Réseau non fiable ? Dépendance externe non contrôlée ?
```

**Workaround documenté (si la cause n'est pas encore résolue) :**

```
WORKAROUND ACTIF :
Description : [Étapes du correctif temporaire]
Temps requis : [X minutes]
Fréquence d'application : [ex. : toutes les 2 semaines]
Risque du workaround : [ex. : redémarrage du service — interruption de 3 min]
À appliquer par : [N'importe quel technicien / N2 minimum / N3 requis]
```

---

### Étape 4 — Définir le plan CAPA

**Format CAPA complet :**

```
CAPA PLAN — PROBLÈME [TICKET #] — [CLIENT]
===========================================

ACTIONS CORRECTIVES (éliminer la cause racine) :
+---+--------------------------------------------------+------------------+------------+--------------------------------+----------+
| # | Action                                           | Responsable      | ETA        | Méthode de vérification        | Statut   |
+---+--------------------------------------------------+------------------+------------+--------------------------------+----------+
| 1 | [Action technique précise]                       | @[Agent/Tech]    | YYYY-MM-DD | [Comment vérifier que c'est OK]| À faire  |
| 2 | [Action technique précise]                       | @[Agent/Tech]    | YYYY-MM-DD | [Méthode de vérification]      | À faire  |
+---+--------------------------------------------------+------------------+------------+--------------------------------+----------+

ACTIONS PRÉVENTIVES (éviter la récurrence sur d'autres systèmes) :
+---+--------------------------------------------------+------------------+------------+--------------------------------+----------+
| # | Action                                           | Responsable      | ETA        | Méthode de vérification        | Statut   |
+---+--------------------------------------------------+------------------+------------+--------------------------------+----------+
| 1 | [Ex. : Auditer tous les clients pour même risque]| @[Agent/Tech]    | YYYY-MM-DD | [Rapport d'audit]              | À faire  |
| 2 | [Ex. : Créer / mettre à jour le runbook]         | @IT-KnowledgeKeeper | YYYY-MM-DD | [Runbook publié dans Hudu]  | À faire  |
| 3 | [Ex. : Ajouter alerte monitoring]                | @IT-MonitoringMaster | YYYY-MM-DD | [Alerte test OK]            | À faire  |
+---+--------------------------------------------------+------------------+------------+--------------------------------+----------+

WORKAROUND À MAINTENIR JUSQU'À RÉSOLUTION :
[Description du workaround actif — voir Étape 3]
```

---

### Étape 5 — Notifier les parties prenantes

```
Notifier selon l'impact :

Si risque SLA ou impact client imminent :
→ @IT-Commandare-OPR + gestionnaire de compte
→ Communication client-safe si le problème génère des interruptions visibles

Si problème systémique multi-clients :
→ @IT-Commandare-OPR — revue tous les clients affectés
→ Priorité de résolution élevée

Si problème de connaissance ou processus :
→ @IT-KnowledgeKeeper — mise à jour KB / runbook
→ @IT-QAMaster — incident QA si le gap est lié à un processus défaillant
```

---

### Étape 6 — Suivi et vérification du CAPA

**Vérification à chaque action complétée :**

```
Pour chaque action CAPA marquée "Complétée" :
1. Appliquer la méthode de vérification définie (test, alerte, rapport, etc.)
2. Documenter le résultat dans la Note Interne du Problem Record
3. Attendre 30 jours sans récurrence avant de fermer l'action comme "Vérifiée"

Format de mise à jour du CAPA tracker dans CW :
"[Date] — Action #[X] complétée — [Description de la vérification] — Résultat : [OK/NOK]
 → Si NOK : [description du problème résiduel — action corrective ajoutée]"
```

**Clôture du Problem Record :**

```
Conditions de fermeture :
□ Toutes les actions CAPA sont "Vérifiées"
□ Aucune récurrence dans les 30 jours suivant la dernière action
□ KB / runbook mis à jour si applicable
□ Monitoring ajouté si applicable
□ Note de clôture dans CW : "Problème résolu — cause racine éliminée — vérification : [méthode + résultat]"
```

---

## Livrables attendus

| Livrable | Destination | Délai |
|---|---|---|
| Problem Record CW (ticket dédié) | CW Manage | Dès détection du pattern |
| Énoncé du problème (versions interne + client) | Note Interne CW | J+2 |
| RCA documenté (5 Pourquoi ou Ishikawa) | Note Interne CW + Hudu | J+5 |
| CAPA tracker avec owners et ETAs | Note Interne CW | J+5 |
| Workaround documenté | Hudu → [Client] → KB | Immédiat si applicable |
| KB / runbook mis à jour | Hudu | Selon ETA CAPA |
| Rapport client-safe si impact visible | Via gestionnaire de compte | J+3 |

---

## Critères de clôture (DoD)

- [ ] Pattern de récurrence documenté avec tickets liés
- [ ] Problem Record créé dans CW avec tous les incidents liés
- [ ] RCA complété : cause confirmée, probable, ou inconnue avec hypothèse
- [ ] Workaround documenté dans Hudu si pas encore résolu
- [ ] CAPA : chaque action a un propriétaire, une ETA et une méthode de vérification
- [ ] Parties prenantes notifiées si risque SLA ou impact client
- [ ] Aucune récurrence dans les 30 jours suivant la dernière action CAPA
- [ ] KB et/ou runbook mis à jour si un gap de connaissance était contributif
- [ ] Aucun secret, IP, credential dans les communications client

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| CAPA sans propriétaire assigné > 48h | @IT-Commandare-OPR | Immédiat |
| Récurrence malgré CAPA validé | @IT-Commandare-OPR + @IT-QAMaster | Revue urgente |
| Problème systémique affectant > 3 clients | @IT-Commandare-OPR | Immédiat — P1 potentiel |
| Client demande des comptes sur les récurrences | Gestionnaire de compte + @IT-Commandare-OPR | 4h |
| Problem Record ouvert > 60 jours sans progression | @IT-QAMaster | Incident QA |

---

## Notes MSP

- **La récurrence est un signal, pas une fatalité** — un problème récurrent non traité est de la dette opérationnelle visible par le client
- **Workaround ≠ solution** — documenter le workaround est un acte de transparence interne, pas une victoire
- **Priorité CAPA :** corrective d'abord (empêcher le prochain incident), préventive ensuite (étendre la protection à tous les clients similaires)
- **KB Hudu :** chaque Problem Record résolu doit laisser une trace dans Hudu — c'est la mémoire collective du MSP
- Intégrer le CAPA tracker dans le **OPR-Weekly-OpsReview** pour visibilité hebdomadaire de l'avancement

---

*OPR-ProblemManagement-CAPA_V1 — IT MSP Intelligence Platform — 2026-05-23*
