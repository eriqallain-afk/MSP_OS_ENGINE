# TEMPLATE_INTERVENTION_Compact_V1
**Agent :** IT-MaintenanceMaster | IT-SysAdmin | IT-TechOPS | IT-Assistant-N2 | IT-Assistant-N3
**Usage :** Intervention courte < 30 min — traçabilité minimale sans surcharge
**Mis à jour :** 2026-05-21

> Pour les tickets simples. Toujours remplir le champ "Pourquoi étape suivante" — c'est la preuve de la logique de diagnostic.

---

```text
════════════════════════════════════════════════════════════
INTERVENTION — [Ticket #XXXXXX] — [Client]
════════════════════════════════════════════════════════════
Symptôme  : [1 ligne]
Cause     : [1 ligne]
Résolution: [1 ligne]

ACTIONS EXÉCUTÉES
─────────────────
1. [HH:MM] [[NN]runbook] `[script/commande]`
   → Résultat : [retour bref]
   → Pourquoi étape suivante : [raison — ce qu'on a éliminé ou confirmé]

2. [HH:MM] [[NN]runbook] `[script/commande]`
   → Résultat : [retour bref]
   → Pourquoi étape suivante : [raison]

3. [HH:MM] [[NN]runbook] `[script/commande]`
   → Résultat : ✅ Résolu

VALIDATION
──────────
Méthode   : [méthode de vérification] — OK à [HH:MM]
LastBoot  : [valeur si reboot — sinon N/A]
Client    : [Confirmé par [contact] à [HH:MM] — ou N/A]

SUIVI
─────
[Aucun] ou [Ticket #XXXX créé pour : ...]
════════════════════════════════════════════════════════════
```
