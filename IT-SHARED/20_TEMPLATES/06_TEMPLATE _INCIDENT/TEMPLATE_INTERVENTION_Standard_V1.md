# TEMPLATE_INTERVENTION_Standard_V1
**Agent :** IT-MaintenanceMaster | IT-SysAdmin | IT-TechOPS | IT-Assistant-N3
**Usage :** Compte rendu d'intervention standard — incidents, demandes, maintenance planifiée
**Mis à jour :** 2026-05-21

> Coller en CW_NOTE_INTERNE à la clôture du ticket. Compléter chaque champ — ne pas laisser de [placeholder] vide.

---

```text
════════════════════════════════════════════════════════════
COMPTE RENDU D'INTERVENTION
════════════════════════════════════════════════════════════

IDENTIFICATION
──────────────
Ticket #          : [#XXXXXX]
Client / Site     : [Nom du client — Site]
Système(s)        : [Serveur, application, service impacté]
Criticité         : [P1 / P2 / P3 / P4]
Agent responsable : [Nom]
Agents en support : [Noms — ou N/A]
Début             : [AAAA-MM-JJ HH:MM EST]
Fin               : [AAAA-MM-JJ HH:MM EST]
Durée totale      : [HHh MMmin]

CONTEXTE INITIAL
────────────────
Symptôme rapporté :
[Description telle que reçue du client ou détectée par monitoring]

Impact business :
[Utilisateurs/services affectés — perte de production — N/A si aucun]

Hypothèse de départ :
[Ce qu'on suspectait au démarrage de l'intervention]

════════════════════════════════════════════════════════════
CHRONOLOGIE DES ACTIONS
════════════════════════════════════════════════════════════

[HH:MM] — ÉTAPE 1 : [Titre court de l'action]
  Runbook utilisé   : [[NN] keyword → FILENAME_V2.md]
  Raison            : [Pourquoi ce runbook par rapport aux symptômes détectés]
  Script/Commande   :
    [coller le bloc PS ou commande exécutée]
  Résultat          :
    [Sortie pertinente, code retour, message — coller le retour brut]
  Interprétation    : [Ce que ce résultat nous dit]
  Décision suivante : [Pourquoi on passe à l'étape 2 — ce qui a été éliminé ou confirmé]

[HH:MM] — ÉTAPE 2 : [Titre]
  Runbook utilisé   : [[NN] keyword → FILENAME_V2.md]
  Raison            : [En lien avec la décision de l'étape 1]
  Script/Commande   :
    [...]
  Résultat          :
    [...]
  Interprétation    : [...]
  Décision suivante : [...]

[HH:MM] — ÉTAPE N : [Titre]
  [... répéter pour chaque action significative ...]

════════════════════════════════════════════════════════════
CAUSE RACINE
════════════════════════════════════════════════════════════
[Description technique de la cause réelle — pas le symptôme visible]

RÉSOLUTION APPLIQUÉE
════════════════════════════════════════════════════════════
[Action finale qui a corrigé le problème — runbook ou script utilisé]

VALIDATION POST-CORRECTIF
════════════════════════════════════════════════════════════
[ ] Service rétabli — vérifié via : [méthode/script]
[ ] Confirmation client : [Nom du contact + heure]
[ ] Monitoring revenu au vert : [outil + horodatage]
[ ] Tests fonctionnels effectués : [liste]
[ ] LastBoot / Uptime documenté (si reboot) : [valeur]

════════════════════════════════════════════════════════════
SUIVIS REQUIS
════════════════════════════════════════════════════════════
Action                          | Responsable | Échéance | Ticket
[Ex. mise à jour du runbook]    | [Nom]       | [Date]   | [#XXXX]
[Ex. patch en fenêtre prochaine]| [Nom]       | [Date]   | [#XXXX]

LEÇONS APPRISES
════════════════════════════════════════════════════════════
Ce qui a bien fonctionné    : [...]
Ce qui a ralenti            : [...]
Amélioration suggérée       : [runbook / monitoring / doc]

RÉFÉRENCES
════════════════════════════════════════════════════════════
Logs        : [chemin ou N/A]
Tickets liés: [#XXXX — ou N/A]
KB/Article  : [lien — ou N/A]
════════════════════════════════════════════════════════════
```
