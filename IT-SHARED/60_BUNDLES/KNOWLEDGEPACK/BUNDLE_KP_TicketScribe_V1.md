# BUNDLE_KP_TicketScribe_V1
**Agent :** @IT-TicketScribe | **Mis à jour :** 2026-03-29 | IT-MaintenanceMaster | IT-SysAdmin

## PHRASES D'OUVERTURE CW (obligatoire)
Choisir UNE — identique dans CW_DISCUSSION ET CW_NOTE_INTERNE :
- `Prendre connaissance de la demande et connexion à la documentation de l'entreprise.`
- `Préparation et découverte. Consultation de la documentation.`

## CW_NOTE_INTERNE (technique, interne)
```
[Phrase d'ouverture]

## Timeline
- HH:MM — [Action]
- HH:MM — [Résultat]

## Commandes exécutées
[Commandes et outputs]

## Résolution
[Description technique]

## Suivi
[Si applicable]
```

## CW_DISCUSSION STAR (client-facing, facturation)
```
[Phrase d'ouverture]

• Situation : [problème en termes fonctionnels]
• Tâche : [objectif]
• Action : [ce qui a été fait — sans jargon]
• Résultat : [état actuel]

Durée : [X]h[XX]min
```
**Règles :** min 4 bullets, zéro IP, zéro jargon, lisible par un comptable.

## EMAIL CLIENT
```
Objet : [RÉSOLU/EN COURS] [Description] — #TXXXXXXX

Bonjour [Nom],
[Corps — fonctionnel, sans jargon technique]
Cordialement, [Nom] — Support technique
```

## NOTICE TEAMS
```
EN COURS : 🔴 [P1/P2] | Client : [NOM] | [Type]
RÉSOLU :   ✅ [P1/P2] RÉSOLU | Client : [NOM] | Durée : [X]h[XX]
```

## RÈGLES ABSOLUES
- Zéro IP dans tout livrable client/externe
- Zéro credentials
- Zéro jargon non expliqué dans CW_DISCUSSION
- Phrase d'ouverture obligatoire
- CW_DISCUSSION ≥ 4 bullet points

---
*BUNDLE_KP_TicketScribe_V1 — Version 1.0*
