# OPR-Handoff-ShiftChange_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-NOCDispatcher | @IT-Commandare-NOC | @IT-Commandare-OPR | @IT-UrgenceMaster
**Scope :** Passation de quart NOC/MSP — résumé des incidents actifs, alertes, clients en cours, actions en attente

---

## Objectif

Assurer une transition sans faille entre les quarts de travail NOC et MSP. Le technicien entrant doit pouvoir reprendre immédiatement le contexte opérationnel sans lacune d'information. Aucun incident actif, aucune alerte en cours et aucune action critique ne doit être oublié lors d'une passation.

---

## Déclencheurs

- Fin de quart planifiée (matin → après-midi, après-midi → soir, soir → nuit, etc.)
- Changement de technicien de garde en urgence
- Passation lors d'un incident P1/P2 actif
- Fin de semaine — passation vers la garde weekend
- Retour de congé — passation vers le technicien de retour

---

## Prérequis

- Accès à ConnectWise Manage (vue des tickets ouverts)
- Accès à la console NOC (N-able, LogicMonitor ou équivalent)
- Accès à la liste des clients en attente d'action (CW → Service Desk → [filtre: En cours / En attente])
- 15 minutes minimum réservées avant la fin du quart pour préparer le briefing
- Le technicien entrant disponible pour la passation (pas de transition silencieuse)

---

## Procédure

### Étape 1 — Préparer le résumé de quart (technicien sortant)

**15 minutes avant la fin du quart, remplir le formulaire de passation :**

```
PASSATION DE QUART — [DATE] [HEURE]
Technicien sortant : [Nom]
Technicien entrant : [Nom]
Quart couvert : [ex. 08h00 – 16h00]
============================================

1. INCIDENTS ACTIFS (P1/P2)
   □ Aucun
   □ [Ticket #] — Client : [NOM] — Statut : [EN COURS / EN ATTENTE] — Propriétaire : [NOM]
     Contexte : [Résumé en 2–3 lignes]
     Dernière action : [Quoi + quand]
     Prochaine action : [Quoi + par qui + ETA]
     Client notifié : [Oui / Non — dernier contact à [HH:MM]]

2. TICKETS EN COURS (P3/P4 avec action immédiate requise)
   □ Aucun
   □ [Ticket #] — Client : [NOM] — Sujet : [DESCRIPTION COURTE]
     Bloqué sur : [raison] — Action requise : [quoi]

3. ALERTES NOC ACTIVES
   □ Aucune
   □ [Alerte] — Client : [NOM] — Serveur/Service : [NOM] — Depuis : [HH:MM]
     Statut : [Acknowledged / En cours d'investigation / En attente vendeur]
     À surveiller : [Oui / Non — condition de déclenchement]

4. CLIENTS AU TÉLÉPHONE OU EN ATTENTE DE RAPPEL
   □ Aucun
   □ [NOM CLIENT] — Contact : [NOM] — Raison : [DESCRIPTION] — Rappel requis avant : [HH:MM]

5. ACTIONS EN ATTENTE (maintenance, scripts, approbations)
   □ Aucune
   □ [Description] — Client : [NOM] — ETA : [date/heure] — Propriétaire : [NOM]

6. INFORMATIONS CONTEXTUELLES IMPORTANTES
   □ Aucune
   □ [Client X] a une maintenance planifiée ce soir à [HH:MM]
   □ [Client Y] — escalade en cours avec le fournisseur [NOM] — numéro de cas : [#]
   □ [Technicien Z] est indisponible jusqu'à [date] — escalades vers [NOM]

7. POINTS DE VIGILANCE
   □ [Système / Client] à surveiller particulièrement pendant ce quart — raison : [X]
   □ Fenêtre de changement planifiée pour [HH:MM] — technicien responsable : [NOM]
```

---

### Étape 2 — Passation verbale (ou Teams/message écrit)

```
Format de passation en 5 minutes :

1. Incidents actifs : [nombre] — les plus critiques en premier
2. Alertes NOC en cours : [nombre et nature]
3. Clients à rappeler : [qui + urgence]
4. Ce que le technicien entrant DOIT faire dans la prochaine heure
5. Ce qu'il doit surveiller tout au long du quart
```

---

### Étape 3 — Documenter la passation dans CW

```
CW → Service Desk → Ticket de quart (ou Note sur chaque ticket actif)

Pour chaque ticket P1/P2 actif :
→ Ajouter une Note Interne : "Passation à [Technicien entrant] à [HH:MM] — contexte : [résumé]"

Pour le journal de quart :
→ Ticket de type "Internal" dédié aux passations de quart
   (Créer si inexistant — voir gestionnaire de quart)
```

---

### Étape 4 — Prise en charge par le technicien entrant

```
Technicien entrant — vérifications obligatoires dans les 15 premières minutes :

□ Lire le résumé de passation
□ Confirmer la compréhension des incidents P1/P2 actifs
□ Vérifier les alertes NOC actives dans la console
□ Vérifier les tickets CW en statut "In Progress" assignés à l'équipe
□ Confirmer les rappels clients programmés
□ Poser les questions de clarification au technicien sortant AVANT qu'il parte

Si passation silencieuse (technicien sortant indisponible) :
→ Appliquer ce runbook en mode autonome — consulter le journal de quart dans CW
→ Si incident P1/P2 actif sans contexte : escalader à @IT-Commandare-NOC immédiatement
```

---

### Étape 5 — Passation lors d'un incident P1/P2 actif

**Protocole spécial — ne jamais laisser un P1 sans propriétaire :**

```
1. Technicien sortant : documenter l'état exact dans la Note Interne CW
   - Timeline des actions effectuées
   - Hypothèse de cause actuelle
   - Prochaine action planifiée (quoi + dans combien de temps)
   - Clients notifiés (heure du dernier contact + heure du prochain)

2. Briefing verbal OBLIGATOIRE de 10 minutes minimum
   - Ne pas partir avant que le technicien entrant confirme qu'il a compris

3. Technicien entrant : ajouter une Note Interne
   "Passation reçue à [HH:MM] — prise en charge confirmée — [Nom]"

4. Escalader à @IT-Commandare-NOC si la complexité dépasse le niveau du quart
```

---

## Livrables attendus

| Livrable | Destination | Obligatoire |
|---|---|---|
| Formulaire de passation rempli | Note CW ou journal de quart | Oui |
| Note interne sur chaque ticket P1/P2 actif | CW Manage | Oui |
| Confirmation verbale / écrite du technicien entrant | Teams / Slack / verbal | Oui |
| Alertes NOC reconnues et transférées | Console NOC | Oui |

---

## Critères de clôture (DoD)

- [ ] Formulaire de passation complété (tous les 7 points)
- [ ] Technicien entrant a confirmé la réception et la compréhension
- [ ] Chaque ticket P1/P2 actif a une note de passation dans CW
- [ ] Alertes NOC actives ont été présentées et transférées
- [ ] Rappels clients planifiés ont été communiqués
- [ ] Technicien sortant disponible 15 min après la fin du quart en cas de question urgente

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| P1 actif sans technicien entrant disponible | @IT-Commandare-NOC | Immédiat |
| Technicien entrant ne répond pas | @IT-Commandare-OPR | 15 min avant fin de quart |
| Passation impossible (urgence) | Technicien sortant reste jusqu'à résolution ou remplacement | Immédiat |
| Contexte incident incompris par le technicien entrant | Appel conférence 3 parties : sortant + entrant + @IT-Commandare-NOC | Immédiat |

---

## Notes MSP

- **Règle absolue :** un technicien ne quitte jamais son quart avec un P1/P2 actif sans que son remplaçant soit briefé et confirmé
- **Journal de quart :** maintenir un ticket CW "Journal de quart [semaine X]" pour traçabilité — utile pour les revues hebdomadaires OPR
- **Garde weekend :** passation renforcée obligatoire — inclure les contacts d'urgence de tous les clients actifs
- **Passation silencieuse (équipe réduite) :** si aucun technicien entrant n'est disponible, escalader à @IT-Commandare-NOC pour décision de couverture
- Intégrer les incidents passés de quart dans le **OPR-Weekly-OpsReview** pour analyse de pattern

---

*OPR-Handoff-ShiftChange_V1 — IT MSP Intelligence Platform — 2026-05-23*
