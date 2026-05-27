# OPR-SLA-BreachPrevention_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-NOCDispatcher | @IT-TicketOpr | @IT-Commandare-OPR | @IT-FrontLine
**Scope :** Prévention des brèches SLA — identifier les tickets à risque, escalader avant dépassement, documenter les exceptions

---

## Objectif

Empêcher tout ticket de dépasser son délai SLA contractuel en détectant les risques de brèche avant qu'ils ne se produisent, en escaladant proactivement, en documentant les exceptions légitimes et en maintenant la visibilité opérationnelle sur tous les tickets à risque. Le SLA est un engagement contractuel — sa violation nuit à la confiance client et peut déclencher des pénalités.

---

## Définitions SLA standards MSP

| Priorité | Délai de réponse standard | Délai de résolution standard | Déclencheur d'alerte préventive |
|---|---|---|---|
| P1 — Critique | 15–30 min | 4h | À 50% du temps SLA écoulé (2h) |
| P2 — Élevé | 1–2h | 8h | À 50% du temps SLA écoulé (4h) |
| P3 — Standard | 4–8h | 24–48h | À 75% du temps SLA écoulé |
| P4 — Faible | 1 jour ouvrable | 72h–5 jours | À 75% du temps SLA écoulé |

> Les délais exacts varient selon le contrat client — vérifier dans CW → Companies → [Client] → SLA Agreement.

---

## Déclencheurs

- Alerte CW SLA (timer rouge ou orange dans la file de tickets)
- Aucune mise à jour sur un ticket depuis > 50% du délai SLA
- Ticket bloqué (waiting on vendor, waiting on client, waiting on approval)
- Changement de priorité ou d'impact (scope creep)
- Technicien propriétaire indisponible (absence, surcharge, handoff non effectué)
- Revue de file quotidienne (revue du matin — voir OPR-Weekly-OpsReview)

---

## Prérequis

- Accès à CW Manage (Service Desk → vue par SLA timer)
- Connaissance de la priorité, du SLA contractuel et du technicien propriétaire
- Capacité à escalader au besoin
- Journal de blocages documenté dans CW

---

## Procédure

### Étape 1 — Identifier les tickets à risque SLA

**Vue CW recommandée :**

```
CW → Service Desk → Board filtrée par :
  - SLA Status : Warning (orange) ou Breached (rouge)
  - Ou : Trier par "SLA Time Remaining" (croissant)
  - Filtre date de modification : > [X heures selon priorité]
```

**Indicateurs de risque à surveiller :**

```
⚠ Timer SLA > 50% écoulé sans note technique récente
⚠ Statut "Waiting on Vendor" depuis > 2h sans mise à jour
⚠ Aucune entrée de temps depuis > [seuil par priorité]
⚠ Technicien propriétaire non disponible (absence)
⚠ Ticket ouvert en dehors des heures ouvrables sans prise en charge nocturne
⚠ Impact initial sous-estimé (ticket P3 qui révèle un impact P2)
```

---

### Étape 2 — Évaluer le risque de chaque ticket

**Pour chaque ticket identifié à risque :**

```
1. Lire le titre, la description et les notes internes
2. Confirmer : Priorité actuelle est-elle correcte ? Impact réel est-il cohérent ?
3. Identifier le blocage : technique / fournisseur / client / décision / ressource
4. Calculer le temps restant avant brèche SLA
5. Confirmer si le technicien propriétaire est disponible et au courant
```

**Décision de priorisation :**

| Temps SLA restant | Action |
|---|---|
| > 50% | Surveiller — pas d'action immédiate requise |
| 25%–50% | Vérifier le statut — ajouter une note si aucune mise à jour récente |
| < 25% | Escalader si pas de résolution en vue — créer note + alerter le propriétaire |
| 0% (breach) | Escalade immédiate + documenter la brèche + notifier le client |

---

### Étape 3 — Actions selon le type de blocage

**Blocage technique (technicien bloqué) :**

```
1. Confirmer le dernier point avec le technicien propriétaire
2. Proposer une expertise supplémentaire (N2 → N3, ou agent spécialisé)
3. Documenter dans Note Interne : "SLA à risque — blocage technique — escalade vers [X] à [HH:MM]"
4. Si P1 : déclencher @IT-UrgenceMaster immédiatement
```

**Blocage fournisseur (Waiting on Vendor) :**

```
1. Vérifier le numéro de cas fournisseur documenté dans la note CW
2. Si aucun numéro : appeler le fournisseur maintenant et documenter l'échange
3. Relancer le fournisseur si délai dépasse leur engagement initial
4. Documenter : "Ticket en attente fournisseur [NOM] — cas #[X] — relance effectuée [HH:MM]"
5. Notifier le client : "Nous suivons activement ce dossier avec votre fournisseur — prochaine mise à jour à [HH:MM]"
6. Appliquer OPR-ClientCommunication-Cadence pour la cadence de mises à jour
```

**Blocage client (Waiting on Client) :**

```
1. Vérifier si une relance a été envoyée — si non : relancer maintenant
2. Documenter la relance dans CW avec heure et canal
3. Si le client ne répond pas depuis > 24h (P3/P4) ou > 2h (P1/P2) :
   → Escalader au gestionnaire de compte pour contact client direct
4. Documenter l'exception SLA : "Brèche SLA due à l'indisponibilité client — documentée et communiquée"
```

**Aucun propriétaire actif :**

```
1. Identifier le dernier technicien ayant travaillé sur le ticket
2. Si indisponible : assigner à un technicien disponible immédiatement
3. Effectuer un briefing rapide (5 min) — voir OPR-Handoff-ShiftChange si quart
4. Documenter le transfert dans CW
```

---

### Étape 4 — Documenter la situation SLA dans CW

```
Note Interne obligatoire pour tout ticket en alerte SLA :

Phrase d'ouverture : "Prise de connaissance de la demande et consultation de la documentation du client."

Corps :
SLA RISK REVIEW — [DATE] [HH:MM]
=================================
Temps SLA restant : [X minutes / heures]
Blocage identifié : [Type de blocage]
Dernière action effectuée : [Description + heure]
Action escalade prise : [Description]
Prochain check-in : [HH:MM]
Prochaine mise à jour client : [HH:MM]
```

---

### Étape 5 — Documenter une exception SLA (brèche légitime)

**Quand une brèche est inévitable malgré toutes les actions :**

```
Note Interne CW — Exception SLA :
===================================
TYPE D'EXCEPTION : [Attente client / Blocage fournisseur / Force majeure / Changement de scope]
RAISON DÉTAILLÉE : [Explication factuelle]
ACTIONS PRÉVENTIVES PRISES : [Relances, escalades, alternatives explorées]
DATE/HEURE DE LA BRÈCHE : [YYYY-MM-DD HH:MM]
NOTIFICATION CLIENT : [Oui — envoyée à HH:MM via [canal]]
APPROBATION GESTIONNAIRE : [Nom + date si requise par le contrat]
```

---

### Étape 6 — Communication client en cas de brèche imminente ou effective

```
Template — brèche imminente :
"Bonjour [Contact],
Nous souhaitons vous informer que votre dossier [sujet] nécessite plus de temps que prévu en raison de [raison en termes simples — ex. : l'intervention du fournisseur de votre équipement réseau].
Nos équipes restent mobilisées et l'objectif de résolution est [heure/date]. Nous vous tenons informé à [heure prochaine mise à jour].
L'équipe [Nom MSP]"

Template — brèche confirmée :
"Bonjour [Contact],
Le délai de résolution de votre dossier [sujet] a dépassé notre engagement initial en raison de [raison simple].
Nous vous présentons nos excuses pour ce délai. [Description de l'état actuel et de la prochaine étape.]
Prochain contact : [heure]. Référence : [Ticket #].
L'équipe [Nom MSP]"
```

---

## Livrables attendus

- Notes CW à jour sur chaque ticket en alerte SLA (raison + action + prochain check-in)
- Exceptions SLA documentées avec raison, actions et approbation
- Communications client envoyées pour toute brèche imminente ou effective
- Rapport de brèches SLA intégré dans le OPR-Monthly-Client-OpsPack

---

## Critères de clôture (DoD)

- [ ] Tous les tickets en alerte SLA identifiés lors de la revue
- [ ] Blocage de chaque ticket identifié et documenté dans CW
- [ ] Escalade effectuée si < 25% du délai SLA restant
- [ ] Propriétaire actif confirmé sur chaque ticket à risque
- [ ] Client notifié pour toute brèche imminente ou effective
- [ ] Exceptions SLA documentées avec raison factuelle et approbation si requise
- [ ] Aucun IP, credential ou détail interne dans les communications client

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| P1 à risque de brèche | @IT-UrgenceMaster | Immédiat |
| P2 en brèche confirmée | @IT-Commandare-OPR | Immédiat |
| Technicien propriétaire introuvable sur ticket P1 | @IT-Commandare-NOC | Immédiat |
| Même client avec > 3 brèches SLA ce mois | @IT-Commandare-OPR + QAMaster | Revue prioritaire |
| Brèche causée par un processus interne défaillant | @IT-OPS-QAMaster | Ouvrir Problem Record |

---

## Notes MSP

- **Prévention > réaction :** une revue de file à 9h chaque matin élimine 80% des brèches SLA imprévues
- **Le "Waiting on" ne suspend pas automatiquement le SLA** dans tous les contrats — vérifier chaque contrat client dans CW
- **Brèche documentée = brèche contrôlée :** une brèche avec communication client et plan d'action est infiniment moins dommageable qu'une brèche silencieuse découverte par le client
- **Récurrence :** si le même client ou le même type de ticket breach régulièrement → ouvrir un Problem Record (OPR-ProblemManagement-CAPA)
- Intégrer les statistiques de brèches SLA dans le **OPR-Monthly-Client-OpsPack** et le **OPR-QBR-DataCollection**

---

*OPR-SLA-BreachPrevention_V1 — IT MSP Intelligence Platform — 2026-05-23*
