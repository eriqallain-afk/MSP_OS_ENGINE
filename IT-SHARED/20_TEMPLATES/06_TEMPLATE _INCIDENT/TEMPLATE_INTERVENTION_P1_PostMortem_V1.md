# TEMPLATE_INTERVENTION_P1_PostMortem_V1
**Agent :** IT-UrgenceMaster | IT-Commandare-NOC | IT-Commandare-Infra
**Usage :** Rapport d'incident majeur P1 avec post-mortem — pannes critiques, conformité, audit
**Mis à jour :** 2026-05-21

> Version étoffée pour pannes critiques. Peut être demandé par le client, l'assurance ou un auditeur.
> Délai de livraison cible : 48h après rétablissement du service.

---

```text
════════════════════════════════════════════════════════════
RAPPORT D'INCIDENT MAJEUR — P1
════════════════════════════════════════════════════════════

SOMMAIRE EXÉCUTIF
─────────────────
Incident #        : [INC-XXXXX]
Client            : [Nom du client]
Sévérité          : P1
Début détecté     : [AAAA-MM-JJ HH:MM EST] — Source : [monitoring / appel client / alerte RMM]
Service rétabli   : [AAAA-MM-JJ HH:MM EST]
MTTR              : [HHh MMmin]
Résumé (1 phrase) : [Ex. "Indisponibilité du serveur HV01 suite à reboot non planifié causé par
                    saturation disque sur partition système."]

ÉQUIPE D'INTERVENTION
─────────────────────
Incident Commander   : [Nom]       [HH:MM – HH:MM]
Lead technique       : [Nom]       [HH:MM – HH:MM]
Communications client: [Nom]       [HH:MM – HH:MM]
Escalade N3          : [Nom / N/A] [HH:MM – HH:MM]

════════════════════════════════════════════════════════════
TIMELINE DÉTAILLÉE
════════════════════════════════════════════════════════════

PHASE 1 — DÉTECTION ET TRIAGE [HH:MM – HH:MM]
───────────────────────────────────────────────
HH:MM | [Action]                | [[NN] runbook]    | [Script/Commande]       | [Résultat]              | [Décision et raison]
HH:MM | Alerte reçue de [outil] | —                 | —                       | [Détail alerte]         | Ouverture P1, mobilisation
HH:MM | Connexion au serveur    | [22]pending-reboot| Enter-PSSession SRV01   | Connexion OK            | Lancer precheck Phase 1

PHASE 2 — INVESTIGATION [HH:MM – HH:MM]
────────────────────────────────────────
HH:MM | [Action]                | [[NN] runbook]    | [Script/Commande]       | [Résultat]              | [Décision et raison]
HH:MM | [...]                   | [...]             | [...]                   | [...]                   | [...]

PHASE 3 — RÉSOLUTION [HH:MM – HH:MM]
──────────────────────────────────────
HH:MM | [Action]                | [[NN] runbook]    | [Script/Commande]       | [Résultat]              | [Décision et raison]
HH:MM | [...]                   | [...]             | [...]                   | [...]                   | [...]

PHASE 4 — VALIDATION ET CLÔTURE [HH:MM – HH:MM]
─────────────────────────────────────────────────
HH:MM | Service rétabli confirmé| [postcheck]       | [script postcheck]      | ✅ OK                   | Déclaration rétablissement
HH:MM | Confirmation client     | —                 | —                       | [Nom contact + heure]   | Fermeture P1

════════════════════════════════════════════════════════════
ANALYSE DE CAUSE RACINE (RCA)
════════════════════════════════════════════════════════════
Cause immédiate   : [Ex. saturation disque C:]
Cause sous-jacente: [Ex. job de backup défaillant depuis 8 jours]
Cause systémique  : [Ex. alerte backup échouée non escaladée vers astreinte]

IMPACT MESURÉ
════════════════════════════════════════════════════════════
Utilisateurs affectés    : [nombre / N/A]
Durée indisponibilité    : [HHh MMmin]
Perte de données         : [oui — détails / non]
Violation SLA            : [oui — clause [X] / non]
Impact financier estimé  : [$/h × durée — ou N/A]

════════════════════════════════════════════════════════════
ACTIONS CORRECTIVES
════════════════════════════════════════════════════════════
#  | Action                              | Type       | Responsable | Échéance | Statut
1  | [Ex. corriger job backup défaillant]| Correctif  | [Nom]       | [Date]   | En cours
2  | [Ex. alerte sur échec backup >24h]  | Préventif  | [Nom]       | [Date]   | À faire
3  | [Ex. réviser runbook [NN]]          | Doc        | [Nom]       | [Date]   | À faire
4  | [Ex. formation équipe scénario]     | Formation  | [Nom]       | [Date]   | Planifié

COMMUNICATION CLIENT
════════════════════════════════════════════════════════════
[HH:MM] — Notification initiale → [contact]
[HH:MM] — Mise à jour intermédiaire
[HH:MM] — Confirmation rétablissement
[Date]  — Rapport post-mortem livré

ANNEXES
════════════════════════════════════════════════════════════
A. Logs complets     : [chemin / lien]
B. Captures RMM      : [lien]
C. Outputs scripts   : [chemin logs RMM]
D. Transcript on-call: [lien / N/A]
════════════════════════════════════════════════════════════
```
