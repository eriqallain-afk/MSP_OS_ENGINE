# TEMPLATE_INCIDENT_Log-et-Critique_V1
**Agent :** IT-Assistant-N3, IT-MaintenanceMaster, IT-Commandare-NOC | IT-SysAdmin
**Usage :** Journal d'incident temps réel (P1/P2) + fiche incident critique
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — JOURNAL D'INCIDENT (TIMELINE)

```
═══════════════════════════════════════════════
JOURNAL D'INCIDENT — TEMPS RÉEL
Billet CW   : #[XXXXXX]
Client      : [NOM]
Type        : [NOC / SOC / SUPPORT]
Priorité    : P[1/2]
Technicien  : [NOM]
Débuté à    : [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

SYMPTÔME INITIAL
[Description précise — ce que l'utilisateur/monitoring a signalé]

ASSETS AFFECTÉS
→ [Serveur/équipement 1]
→ [Serveur/équipement 2]

IMPACT
Utilisateurs affectés : [Nombre / qui]
Services indisponibles : [Liste]

─────────────────────────────────────────────
TIMELINE

[HH:MM] — [FAIT] — [Description action + résultat]
[HH:MM] — [FAIT] — [Description action + résultat]
[HH:MM] — [SUGGESTION] — [Description action à valider]
[HH:MM] — [À CONFIRMER] — [Information manquante]
[HH:MM] — [ESCALADE] — Département [NOC/SOC/INFRA/TECH] notifié

─────────────────────────────────────────────
VALIDATIONS FINALES

Services critiques    : ✅ OK / ❌ KO / [À CONFIRMER]
Monitoring           : ✅ OK / ❌ KO / [À CONFIRMER]
Backups (si applicable) : ✅ OK / ❌ KO / [À CONFIRMER]
Validation utilisateur  : ✅ OK / ❌ KO / [À CONFIRMER]

STATUT FINAL : [RÉSOLU / PARTIEL / ESCALADÉ]
Résolu à    : [HH:MM]
Durée totale : [X heures Y min]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — FICHE INCIDENT CRITIQUE (P1)

```
═══════════════════════════════════════════════
INCIDENT CRITIQUE — P1
Billet CW      : #[XXXXXX]
Client         : [NOM]
Date/Heure     : [YYYY-MM-DD HH:MM]
Technicien N2/N3 : [NOM]
Département notifié : [NOC / SOC / INFRA / TECH]
═══════════════════════════════════════════════

DESCRIPTION
[Ce qui s'est passé — 2-3 phrases claires]

INDICATEURS DE CRITICITÉ
☐ Ransomware / chiffrement actif
☐ Breach / compromission compte admin
☐ DC / AD inaccessible
☐ Réseau site entier down
☐ Perte de données en cours
☐ > 20 utilisateurs impactés
☐ Autre : [préciser]

ACTIONS IMMÉDIATES EFFECTUÉES
1. [Action — résultat]
2. [Action — résultat]

ÉTAT ACTUEL
[Description de la situation au moment du transfert]

RISQUES SI NON TRAITÉ IMMÉDIATEMENT
→ [Risque 1]
→ [Risque 2]
═══════════════════════════════════════════════
```
