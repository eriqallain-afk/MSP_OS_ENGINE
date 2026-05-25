# OPR-Weekly-OpsReview_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-Commandare-OPR | @IT-NOCDispatcher | @IT-OPS-QAMaster | @IT-ReportMaster
**Scope :** Revue opérationnelle hebdomadaire — état de santé de la semaine, incidents ouverts, tickets en attente, actions prioritaires semaine suivante

---

## Objectif

Produire chaque semaine un état de santé opérationnel complet de la plateforme MSP : incidents de la semaine, tickets ouverts à risque, CAPA en cours, alertes non résolues, SLA à surveiller, et plan d'action pour la semaine suivante. Cette revue est le pilier du management opérationnel hebdomadaire.

---

## Déclencheurs

- Déclenchement hebdomadaire planifié : chaque vendredi à 16h (ou dernier jour ouvrable de la semaine)
- Début de semaine : revue de file lundi matin 9h (version allégée)
- Demande de @IT-Commandare-OPR pour état opérationnel ad hoc
- Semaine avec incident P1/P2 — revue renforcée obligatoire

---

## Prérequis

- Accès à ConnectWise Manage (Service Desk)
- Accès à la console NOC (N-able ou équivalent)
- Liste des CAPA ouverts (OPR-ProblemManagement-CAPA)
- Résumé des passations de quart de la semaine
- Données SLA de la semaine (CW → Reports → SLA)

---

## Procédure

### Étape 1 — Bilan des incidents de la semaine

```
CW → Service Desk → Filtrer : Semaine courante + Priorité P1 et P2

Pour chaque incident majeur :
□ Ticket #[ID] — Client : [NOM] — Résolu : [Oui/Non]
  Durée : [X heures] | Cause : [résumé court]
  PIR transmis : [Oui/Non] | CAPA ouvert : [Oui/Non]

Résumé de la semaine :
  P1 cette semaine : [X] — résolus : [X]
  P2 cette semaine : [X] — résolus : [X]
  Brèches SLA : [X] — raisons : [résumé]
```

---

### Étape 2 — État des tickets ouverts

```
CW → Service Desk → Tous les tickets "Open" ou "In Progress"

MÉTRIQUES À CAPTURER :
□ Total tickets ouverts (tous clients confondus)
□ Tickets ouverts par priorité : P1 / P2 / P3 / P4
□ Tickets ouverts depuis > 5 jours (P3) ou > 2 jours (P2)
□ Tickets sans activité depuis > 24h (à risque SLA ou orphelins)
□ Tickets en "Waiting on Vendor" > 48h sans mise à jour
□ Tickets sans propriétaire assigné

TOP 5 TICKETS À SURVEILLER LA SEMAINE PROCHAINE :
+---+--------+----------+---------------------------+---------------+--------------------+
| # | Ticket | Client   | Sujet                     | SLA restant   | Blocage            |
+---+--------+----------+---------------------------+---------------+--------------------+
| 1 | #XXXXX | [NOM]    | [Description courte]      | [X heures]    | [Type de blocage]  |
| 2 | #XXXXX | [NOM]    | [Description courte]      | [X heures]    | [Type de blocage]  |
+---+--------+----------+---------------------------+---------------+--------------------+
```

---

### Étape 3 — Alertes NOC en cours

```
Console NOC → Alertes actives → Non acquittées ou en investigation

Pour chaque alerte persistante :
□ Alerte : [Description] | Client : [NOM] | Depuis : [HH:MM]
  Statut : [Acknowledged / En investigation / En attente]
  Technicien responsable : [NOM]
  Prochaine action : [Description + ETA]

Alertes nouvelles cette semaine (non liées à un incident P1/P2) :
□ [Nombre] alertes traitées automatiquement
□ [Nombre] alertes nécessitant intervention manuelle
□ Alertes récurrentes : [Description — à transformer en Problem Record si > 3x]
```

---

### Étape 4 — Suivi des CAPA ouverts

```
Liste des Problem Records actifs et CAPA en cours :

+--------+----------+-------------------------------------+------------------+------------+----------+
| Ticket | Client   | Problème                            | Responsable CAPA | ETA        | Statut   |
+--------+----------+-------------------------------------+------------------+------------+----------+
| #XXXXX | [NOM]    | [Description courte du problème]    | @[Agent/Tech]    | YYYY-MM-DD | En cours |
| #XXXXX | [NOM]    | [Description courte]                | @[Agent/Tech]    | YYYY-MM-DD | En retard|
+--------+----------+-------------------------------------+------------------+------------+----------+

CAPA en retard (ETA dépassée) :
→ Pour chaque CAPA en retard : confirmer nouvelle ETA ou escalader à @IT-Commandare-OPR
```

---

### Étape 5 — Revue SLA de la semaine

```
CW → Reports → SLA → Semaine courante

□ Taux de conformité SLA global cette semaine : [X%]
□ Brèches SLA cette semaine : [X]
  - [Ticket #] — Client : [NOM] — Raison : [type de blocage]
  - Exception documentée : [Oui/Non]
□ Tendance : amélioration / stable / dégradation vs. semaine précédente
□ Clients avec SLA à risque semaine prochaine (tickets P2/P3 en cours)
```

---

### Étape 6 — Maintenance planifiée — validation

```
Travaux planifiés pour la semaine suivante :

□ [Nom maintenance] — Client : [NOM] — Date : [YYYY-MM-DD] — Fenêtre : [HH:MM–HH:MM]
  Technicien assigné : [NOM]
  Prérequis validés : [Oui/Non — backup < 24h / approbation client / rollback planifié]
  Communication client envoyée (J-3) : [Oui/Non]

□ Conflits de planification détectés : [Oui/Non — décrire si Oui]
```

---

### Étape 7 — Points d'amélioration et actions prioritaires

```
ACTIONS PRIORITAIRES POUR LA SEMAINE PROCHAINE :
+---+--------------------------------------------+------------------+------------+
| # | Action                                     | Responsable      | ETA        |
+---+--------------------------------------------+------------------+------------+
| 1 | [Action critique — ticket / CAPA / process]| @[Agent/Tech]    | YYYY-MM-DD |
| 2 | [Action importante]                        | @[Agent/Tech]    | YYYY-MM-DD |
| 3 | [Action de suivi]                          | @[Agent/Tech]    | YYYY-MM-DD |
+---+--------------------------------------------+------------------+------------+

POINTS D'AMÉLIORATION IDENTIFIÉS CETTE SEMAINE :
□ [Ex. : Même type d'alerte réseau sur 3 clients — à investiguer en Problem Record]
□ [Ex. : 2 tickets orphelins découverts — processus de passation à renforcer]
□ [Ex. : Runbook manquant pour [scénario] — créer cette semaine]
```

---

### Étape 8 — Documenter et diffuser

```
Format de diffusion de la revue hebdomadaire :

Option A — Note CW sur le ticket "OPS Weekly Review [Semaine X]" :
  → Créer un ticket Internal hebdomadaire dédié à la revue ops
  → Note Interne avec le rapport complet
  → Assigner à @IT-Commandare-OPR pour validation

Option B — Message Teams / Slack (équipe NOC/OPR) :
  → Résumé exécutif en 10 lignes max
  → Lien vers la note CW complète

DIFFUSION RECOMMANDÉE :
  □ @IT-Commandare-OPR — destinataire principal
  □ @IT-Commandare-NOC — pour les alertes et incidents NOC
  □ @IT-OPS-QAMaster — pour les patterns et CAPA
  □ Gestionnaires de compte — résumé exécutif uniquement (version client-safe)
```

---

## Template — Résumé exécutif hebdomadaire

```
REVUE OPS — SEMAINE DU [DD/MM] AU [DD/MM/AAAA]
================================================

SANTÉ GLOBALE : [Vert / Orange / Rouge]
  Vert   = Aucun P1, SLA > 95%, aucun CAPA en retard
  Orange = 1 P1 résolu ou SLA 85-95% ou CAPA en retard
  Rouge  = P1 actif ou SLA < 85% ou brèches non documentées

INCIDENTS :
  P1 cette semaine : [X] | P2 : [X]
  Brèches SLA : [X] (documentées : [X])

TICKETS OUVERTS : [X total] — dont [X] à surveiller en priorité

ALERTES NOC ACTIVES : [X]

CAPA EN COURS : [X] — en retard : [X]

MAINTENANCE SEMAINE PROCHAINE : [X travaux planifiés]

ACTION #1 PRIORITAIRE : [Description — Responsable — ETA]
```

---

## Livrables attendus

| Livrable | Destination | Fréquence |
|---|---|---|
| Rapport de revue hebdomadaire complet | Ticket CW Internal | Hebdomadaire (vendredi) |
| Résumé exécutif | @IT-Commandare-OPR + gestionnaires de compte | Hebdomadaire |
| Liste des actions prioritaires avec owners | Note CW + diffusion équipe | Hebdomadaire |
| Mise à jour CAPA tracker | CW (tickets Problem Record) | Hebdomadaire |

---

## Critères de clôture (DoD)

- [ ] Incidents P1/P2 de la semaine recensés et statut PIR vérifié
- [ ] Tickets ouverts à risque SLA identifiés et propriétaire confirmé
- [ ] Alertes NOC actives documentées avec responsable et prochaine action
- [ ] CAPA en cours mis à jour — retards identifiés et escaladés
- [ ] SLA de la semaine mesuré et commenté
- [ ] Maintenance semaine suivante validée (prérequis + communication client)
- [ ] Actions prioritaires définies avec owners et ETAs
- [ ] Rapport diffusé à @IT-Commandare-OPR avant fin de journée vendredi

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| Santé globale Rouge (P1 actif ou SLA < 85%) | @IT-Commandare-OPR | Immédiat — revue d'urgence |
| CAPA en retard > 1 semaine | @IT-Commandare-OPR + propriétaire du CAPA | Lors de la revue |
| Alerte NOC active depuis > 48h sans résolution | @IT-MonitoringMaster + @IT-Commandare-NOC | Immédiat |
| Pattern récurrent détecté (3e semaine consécutive) | @IT-OPS-QAMaster — ouvrir Problem Record | Avant la fin de la revue |
| Revue non effectuée depuis > 2 semaines | @IT-Commandare-OPR | Notification automatique requise |

---

## Notes MSP

- **Cadence minimale :** 1 revue hebdomadaire complète (vendredi) + 1 revue allégée de file (lundi matin)
- **Revue du lundi (15 min) :** focus uniquement sur les tickets urgents de la semaine, les alertes NOC actives et les maintenances planifiées — pas de rapport formel requis
- **Indicateur de santé globale :** Vert/Orange/Rouge est un signal rapide pour @IT-Commandare-OPR — ne pas hésiter à passer en Orange dès le moindre doute
- **Historique :** conserver les rapports hebdomadaires dans CW 4 semaines glissantes — utile pour le OPR-Monthly-Client-OpsPack
- Ce runbook alimente directement le **OPR-Monthly-Client-OpsPack** (4 revues hebdomadaires = 1 pack mensuel)

---

*OPR-Weekly-OpsReview_V1 — IT MSP Intelligence Platform — 2026-05-23*
