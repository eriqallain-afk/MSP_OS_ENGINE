# RUNBOOK — Processus Projet & SOW MSP
**Version :** 1.0 | **Date :** 2026-05-19 | **Statut :** STAGING — activation avec MODULE_PROJETS
**Agent :** IT-ProjetSOW | **Playbook :** IT_PROJET_SOW

---

## Déclencheurs

Ce runbook s'applique quand un agent terrain détecte :
- Besoin d'infrastructure nouvelle (serveurs, réseau, cloud)
- Migration ou upgrade majeur
- Projet de sécurité (EDR, SOC, compliance)
- Onboarding client → lacunes identifiées par IT-OnOffBoarder (/gap)
- Demande explicite de SOW ou devis par le client

---

## Phase 1 — Détection et escalade

**Agent source :** Tout agent autorisé (FrontLine, N2, N3, SysAdmin, OnOffBoarder, etc.)
**Commande :** `/escalade-ventes`

1. Remplir le schéma ventes/SCHEMA_OPPORTUNITY.yaml
2. Nommer le fichier : `OPP-{YYYYMMDD}-{NNN}.yaml`
3. Déposer dans : `ventes/opportunities/`
4. Notifier IT-ProjetSOW : « Nouvelle opportunité OPP-{id} — [client] — [catégorie] »

**Signal fort → escalade immédiate :**
- Client mentionne budget alloué
- IT-OnOffBoarder a complété un /gap avec des lacunes Haute/Critique
- Demande de RFP ou devis formelle

---

## Phase 2 — Analyse (IT-ProjetSOW)

```
/lire OPP-{id}        → Résumé + validation schéma
/analyser OPP-{id}    → Besoins, portée, exclusions, risques, approche
```

**Livrables phase 2 :**
- Portée définie (inclus / exclus / hypothèses)
- Risques si non adressé
- Approche recommandée (phases, jalons)
- Questions ouvertes pour le client

---

## Phase 3 — Estimation

```
/estimer OPP-{id}
```

**Format estimation :**
```
Approche     : Forfait | Régie | Hybride
Effort       : X à Y jours-technicien
Délai        : X à Y semaines
Ressources   : [Profils requis]

COÛTS (fourchette)
Analyse/Design    : $X – $Y
Implémentation    : $X – $Y
Tests/Validation  : $X – $Y
Formation         : $X – $Y
TOTAL             : $X – $Y

HYPOTHÈSES : [Liste]
⚠️ VALIDATION EA REQUISE avant soumission
```

---

## Phase 4 — Rédaction SOW

```
/sow OPP-{id}
```

**Structure SOW (7 sections) :**
1. Résumé exécutif
2. Portée des travaux (inclus / exclus)
3. Livrables
4. Méthodologie et jalons
5. Responsabilités MSP / Client
6. Estimation et modalités de paiement
7. Conditions et validité de l'offre

**Règles absolues :**
- Zéro IP, credentials, CVE dans le SOW client
- Langage non-technique — bénéfices business
- Tous les prix = fourchettes avec hypothèses

---

## Phase 5 — Validation EA

**OBLIGATOIRE avant soumission.**

EA valide :
- [ ] Prix dans la fourchette acceptable
- [ ] Portée réaliste pour les ressources disponibles
- [ ] Risques identifiés et documentés
- [ ] Format SOW conforme aux standards MSP

---

## Phase 6 — Soumission client

```
/soumettre OPP-{id}
```

Produit :
- Email client (template TEMPLATE_EMAIL_SOW_V1.md)
- Document SOW attaché
- Copie dans ventes/estimations/

---

## Phase 7 — Suivi et clôture

Si accepté → déplacer vers `ventes/approved/`
Si refusé → statut REFUSÉ + raison dans opportunité YAML
Si suivi → IT-ReportMaster génère rapport pipeline mensuel

---

## Escalades

| Situation | Action |
|---|---|
| Infrastructure complexe | IT-SysAdmin pour validation technique |
| Projet cloud/M365 | IT-CloudMaster |
| Projet sécurité | IT-SecurityMaster |
| Projet réseau | IT-NetworkMaster |
| Rapport exécutif | IT-ReportMaster |
| Validation prix | EA (obligatoire) |

---

*RUNBOOK PROJET-SOW v1.0 — IT-SHARED/10_RUNBOOKS/PROJET/ — MSP Intelligence AI — 2026-05-19*
