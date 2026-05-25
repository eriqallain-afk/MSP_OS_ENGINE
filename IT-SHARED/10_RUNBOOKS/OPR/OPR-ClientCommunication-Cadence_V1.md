# OPR-ClientCommunication-Cadence_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-FrontLine | @IT-TicketScribe | @IT-NOCDispatcher | @IT-UrgenceMaster | @IT-Commandare-OPR
**Scope :** Cadence de communication proactive avec les clients MSP — incidents, maintenance, délais, dépendances fournisseurs

---

## Objectif

Garantir que chaque client reçoit des mises à jour claires, opportunes et en langage non technique sur l'état de ses incidents, travaux de maintenance et demandes en cours. La cadence de communication est un engagement SLA implicite du MSP — son absence est perçue comme de l'incompétence, même si la résolution technique progresse.

---

## Déclencheurs

- Incident P1 ou P2 ouvert avec impact client confirmé
- Client qui demande un statut (appel, email, CW)
- Ticket bloqué ou en attente fournisseur depuis > 4h (P3) ou > 2h (P2)
- Fenêtre de maintenance qui approche (J-3), qui débute ou se termine
- Travaux dépassant la durée estimée initiale (scope creep)
- Client qui attend une approbation de notre part ou de la sienne
- Fin d'incident — confirmation de résolution requise

---

## Prérequis

- Ticket CW ouvert avec statut, priorité et propriétaire identifiés
- Connaissance de l'impact actuel (utilisateurs affectés, services hors ligne)
- Prochaine action technique identifiée (ou blocage documenté)
- Canal de communication client confirmé (CW Discussion / email / Teams — voir Hudu → [Client] → Contacts)
- Confirmation que le contenu est client-safe (voir grille ci-dessous)

---

## Cadence minimale par priorité

| Priorité | Cadence minimale | Déclencheur additionnel |
|---|---|---|
| P1 — Critique | Toutes les 30–60 min | À chaque changement de statut, même mineur |
| P2 — Élevé | Toutes les 2–4h | À chaque escalade ou changement de statut |
| P3 — Standard | À chaque étape majeure ou quotidien si > 24h ouvert | Quand le ticket est bloqué |
| P4 — Faible | À la résolution | Si délai dépasse l'ETA initiale |
| Maintenance planifiée | J-3 (annonce) + début + fin | Si durée ou scope change |

---

## Procédure

### Étape 1 — Préparer la mise à jour

```
1. Confirmer le statut du ticket : Priorité, Statut, Propriétaire, Heure d'ouverture
2. Définir l'impact actuel : combien d'utilisateurs / services affectés
3. Identifier la prochaine action technique concrète
4. Calculer l'ETA de prochaine communication (ou de résolution si proche)
5. Identifier le canal approuvé pour ce client (CW / email / Teams / téléphone)
   → Voir Hudu → [Client] → Communication Preferences
```

---

### Étape 2 — Rédiger la mise à jour client-safe

**Structure standard — toute communication client :**

```
SITUATION :
[Résumé en 1–2 phrases — ce qui se passe, sans jargon technique ni détails internes]
Ex. : Nous intervenons actuellement sur une interruption de service affectant votre système de messagerie.

IMPACT :
[Qui est affecté et comment — en termes business, pas techniques]
Ex. : Les envois et réceptions d'emails sont temporairement indisponibles pour l'ensemble de votre équipe.

ACTION EN COURS :
[Ce que l'équipe fait maintenant — sans commandes, IPs ni noms de serveurs]
Ex. : Notre équipe technique est en intervention active pour rétablir le service.

PROCHAINE MISE À JOUR :
[Heure concrète — jamais "dans quelques heures"]
Ex. : Nous vous donnons une mise à jour dans 30 minutes ou avant si le service est rétabli.
```

---

### Étape 3 — Vérification client-safe avant envoi

**Retirer OBLIGATOIREMENT les éléments suivants avant tout envoi client :**

```
⛔ Adresses IP (192.168.x.x, 10.x.x.x, IP publiques internes)
⛔ Noms de serveurs internes (SRV-AD01, DC-PROD, NAS-01)
⛔ Noms d'utilisateurs techniques ou comptes de service
⛔ Credentials, mots de passe, tokens, clés API
⛔ Commandes PowerShell, CMD, Bash, scripts
⛔ Logs d'erreur bruts ou messages d'exception
⛔ Noms de vulnérabilités ou CVE
⛔ Détails sur l'architecture ou les fournisseurs tiers (noms de contrats, tarifs)
⛔ Accusations envers un fournisseur ou employé tiers
```

---

### Étape 4 — Envoyer via le bon canal

**Canal prioritaire par situation :**

| Situation | Canal recommandé |
|---|---|
| P1 actif | Téléphone D'ABORD + CW Discussion + email si demandé |
| P2 actif | CW Discussion + email si demandé |
| P3/P4 | CW Discussion |
| Maintenance | Email + CW Discussion (J-3 et à la fin) |
| Client en attente urgente | Appel téléphonique — ne jamais laisser attendre sans réponse > 1h |

**Consignation dans CW :**
```
CW → Ticket [ID] → Time Entry
- Décrire : "Mise à jour client envoyée via [canal] — prochain contact à [heure]"
- Temps imputé : oui (communication client = temps facturable selon contrat)
```

---

### Étape 5 — Templates prêts à l'emploi

**Template P1 — Ouverture d'incident :**
```
Bonjour [Contact],

Nous avons pris en charge votre signalement concernant [sujet en termes business].

Nos techniciens sont actuellement en intervention. Nous vous tenons informé toutes les 30 minutes ou dès que nous avons du nouveau.

Référence de votre dossier : [Numéro de ticket CW]

L'équipe [Nom MSP]
```

**Template P1/P2 — Mise à jour en cours :**
```
Bonjour [Contact],

Mise à jour — [heure] :

Nos équipes poursuivent l'intervention sur [sujet]. [Une phrase sur l'avancement, sans détails techniques.]

Impact actuel : [description impact fonctionnel].

Prochaine mise à jour : [heure précise].

L'équipe [Nom MSP]
```

**Template — Résolution d'incident :**
```
Bonjour [Contact],

Nous avons le plaisir de vous informer que le problème affectant [sujet] est résolu depuis [heure].

[Une phrase sur ce qui a été fait, en termes simples.]

Votre service est pleinement opérationnel. N'hésitez pas à nous contacter si vous observez quoi que ce soit d'inhabituel.

Référence du dossier : [Numéro de ticket CW]

L'équipe [Nom MSP]
```

**Template — Maintenance planifiée (J-3) :**
```
Bonjour [Contact],

Ce message vous informe d'une maintenance planifiée sur vos services :

Date et heure : [date] de [heure début] à [heure fin estimée]
Services concernés : [liste en termes business — ex. : accès à vos fichiers partagés]
Impact attendu : [interruption de X minutes / ralentissement possible / aucun impact si en dehors des heures]

Aucune action n'est requise de votre part. Nous confirmerons la fin des travaux par retour de message.

L'équipe [Nom MSP]
```

**Template — Blocage fournisseur / délai :**
```
Bonjour [Contact],

Mise à jour sur votre dossier [sujet] :

Nous attendons actuellement une intervention de la part du fournisseur responsable du service [ex. : votre opérateur Internet] pour débloquer la situation.

Nous suivons ce dossier activement et nous vous tenons informé dès que nous avons du nouveau. Prochaine mise à jour : [heure].

L'équipe [Nom MSP]
```

---

## Livrables attendus

- Communication envoyée via le canal approuvé pour le client
- Entrée de temps dans CW documentant la communication et la prochaine heure de contact
- Discussion CW mise à jour avec le contenu envoyé
- Calendrier de prochaine communication respecté

---

## Critères de clôture (DoD)

- [ ] Mise à jour envoyée dans les délais de la cadence définie
- [ ] Contenu client-safe vérifié (aucun IP, credential, commande, log brut)
- [ ] Impact et prochaine étape clairement exprimés en langage client
- [ ] Heure de prochaine mise à jour communiquée (sauf si clôture finale)
- [ ] Communication consignée dans le ticket CW (time entry ou note)
- [ ] Canal de communication respecte les préférences client documentées dans Hudu

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| P1 actif depuis > 1h sans mise à jour client | @IT-UrgenceMaster | Immédiat |
| Client injoignable par le canal habituel | Essayer tous les canaux — puis @IT-Commandare-OPR | 30 min |
| Client demande à parler à un gestionnaire | @IT-Commandare-OPR | Immédiat |
| Communication contient une information sensible envoyée par erreur | @IT-SecurityMaster | Immédiat — incident sécurité |
| Incident > 4h sans résolution visible | @IT-UrgenceMaster + escalade P1 | Immédiat |

---

## Notes MSP

- **Règle d'or :** un client qui n'a pas de nouvelles assume le pire — une communication médiocre est pire qu'une résolution lente
- **ETA = engagement :** ne jamais donner une ETA que vous ne pouvez pas tenir — mieux vaut donner une heure de prochaine mise à jour
- **Langue :** adapter au niveau technique du contact client (technicien client vs. direction générale)
- **Fréquence sur P1 :** 30 min = maximum acceptable — viser 20 min lors des incidents critiques
- Ce runbook est complément du **OPR-CW-TicketQualityAudit** — la Discussion CW est l'artéfact de communication officiel
- Conserver tous les templates utilisés dans Hudu → [Client] → Communication History

---

*OPR-ClientCommunication-Cadence_V1 — IT MSP Intelligence Platform — 2026-05-23*
