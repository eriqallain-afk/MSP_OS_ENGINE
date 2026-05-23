# IT — Communication Templates (TECH)

> Version TECH : communications pendant/après le diagnostic et la remédiation.
> TECH rédige les CW_NOTE_INTERNE et les blocs ESCALADE. OPR/CommsMSP gère le client.

---

## A) CW_NOTE_INTERNE — Diagnostic initial TECH

```
DIAGNOSTIC TECH — INC-YYYY-XXXX
─────────────────────────────────────
SYMPTÔMES OBSERVÉS :
- [Symptôme 1]
- [Symptôme 2]

PREUVES / LOGS :
- [Log / Event ID / Metric]
- [Timestamp + valeur]

HYPOTHÈSE PRINCIPALE :
[Description hypothèse + justification]

TESTS EFFECTUÉS :
1. [Test 1] → Résultat :
2. [Test 2] → Résultat :

HYPOTHÈSE CONFIRMÉE / INFIRMÉE :
[Conclusion]

NEXT STEPS :
- [ ] [Action 1]
- [ ] [Action 2]

RISQUE SI NON TRAITÉ :
[Impact potentiel]

ESCALADE REQUISE : Oui / Non → Vers : [INFRA / Security / CTO]
```

---

## B) CW_NOTE_INTERNE — RCA (Root Cause Analysis)

```
RCA — INC-YYYY-XXXX
─────────────────────────────────────
CAUSE RACINE CONFIRMÉE :
[Description précise — 1-2 phrases]

TRIGGER IMMÉDIAT :
[Ce qui a déclenché l'incident aujourd'hui]

FACTEURS CONTRIBUTIFS :
1. [Facteur 1]
2. [Facteur 2]

TIMELINE DE LA CAUSE :
[Chronologie de comment la cause s'est développée]

FIX APPLIQUÉ :
1. [Action 1] — Heure :
2. [Action 2] — Heure :

VALIDATION POST-FIX :
- [ ] Service restauré
- [ ] Monitoring vert
- [ ] Client confirmé (si applicable)

RÉCIDIVE POSSIBLE : Oui / Non
SI OUI — CAPA recommandée :
[Description action préventive]
```

---

## C) Bloc ESCALADE TECH → NOC

```
ESCALADE TECH → NOC
─────────────────────────────────────
STATUT ACTUEL : [Résolu / Stable / En cours]
ACTIONS TECH : [Résumé actions]
SURVEILLANCE REQUISE : [Oui — quoi surveiller / Non]
CRITÈRES D'ALERTE : [Si X → rappeler TECH]
RISQUE RÉSIDUEL : [Description ou "Aucun"]
```

---

## D) Bloc ESCALADE TECH → CTO (si arbitrage requis)

```
ESCALADE TECH → CTO — DÉCISION REQUISE
─────────────────────────────────────
CONTEXTE :
[Résumé situation en 3 lignes max]

OPTIONS ÉVALUÉES :
Option A : [Description] — Avantages : / Risques :
Option B : [Description] — Avantages : / Risques :

RECOMMANDATION TECH :
[Option recommandée + justification]

DÉCISION REQUISE AVANT :
[Deadline] — Raison : [Impact si délai]

IMPACT SI DÉCISION DIFFÉRÉE :
[Description impact]
```

---

## E) Communication TECH → Client (direct, cas rare)

> Note : Les communications client passent normalement par OPR/CommsMSP.
> TECH communique directement uniquement en cas d'urgence live ou de contexte technique complexe.

```
Bonjour [Contact technique client],

Suite à notre diagnostic, voici les informations techniques :

CAUSE IDENTIFIÉE : [Description technique claire]
ACTION APPLIQUÉE : [Ce qui a été fait]
ÉTAT ACTUEL : [Service restauré / En cours / Stable]

VOTRE ACTION REQUISE (si applicable) :
→ [Action client]

Nous restons disponibles pour toute question technique.
[Nom] — TECH MSP
```

---

> Voir aussi : IT__Postmortem_Template.md | IT__Escalation_Playbook.md | IT__RCA standards
