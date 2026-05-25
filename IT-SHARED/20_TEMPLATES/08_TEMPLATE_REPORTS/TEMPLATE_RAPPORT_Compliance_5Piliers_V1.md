# TEMPLATE_RAPPORT_Compliance_5Piliers_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-ComplianceMaster | @IT-ReportMaster
**Département :** TEMPLATES | **Source :** IT MSP Intelligence Platform

---

## INSTRUCTIONS D'UTILISATION

Ce template produit **deux livrables** à partir d'un même audit :

1. **Note CW interne** — bloc texte, traçabilité, archivage
2. **Rapport client Word/PowerPoint** — avec zones pour gauges Microsoft + commentaires exécutifs

> Pour générer le rapport : coller le HANDOFF_BLOCK dans IT-ReportMaster.
> Pour le rapport Word : copier la Section B et insérer les screenshots dans les zones prévues.

---

## SECTION A — CW NOTE INTERNE

```text
CW NOTE INTERNE — Audit Conformité Sécurité 5 Piliers
Runbook utilisé : SEC-COMPLIANCE-5Piliers_Framework_V1
                  SEC-ENTRA-SecurityCompliance_V1
                  SEC-PURVIEW-ComplianceAudit_V1

CLIENT        : [À COMPLÉTER]
BILLET CW     : #[À COMPLÉTER]
PÉRIODE       : [Q1/Q2/Q3/Q4]-[ANNÉE]
AUDITEUR      : [Nom technicien]
DATE AUDIT    : [Date]
FRAMEWORK     : [Loi 25 / PCI / SOC2 / Cyber-assurance / Défaut]

═══════════════════════════════════════════════
SCORES 5 PILIERS
═══════════════════════════════════════════════

P1 Lifecycle Risk       : [XX]/100 [🟢 BON / 🟡 ACCEPTABLE / 🔴 CRITIQUE]
P2 Governance Integrity : [XX]/100 [🟢 BON / 🟡 ACCEPTABLE / 🔴 CRITIQUE]
P3 Continuity Assurance : [XX]/100 [🟢 BON / 🟡 ACCEPTABLE / 🔴 CRITIQUE]
P4 Exposure Surface     : [XX]/100 [🟢 BON / 🟡 ACCEPTABLE / 🔴 CRITIQUE]
P5 Operational Drift    : [XX]/100 [🟢 BON / 🟡 ACCEPTABLE / 🔴 CRITIQUE]

SCORE GLOBAL            : [XX]/100 [🟢 MATURE / 🟡 ACCEPTABLE / 🔴 CRITIQUE]

═══════════════════════════════════════════════
CONSTAT ENTRA ID
═══════════════════════════════════════════════

MFA enforcement         : [XX]% des utilisateurs
Legacy Auth bloqué      : [Oui / Non]
CA Policies actives     : [X] dont [X] MFA
PIM activé              : [Oui / Non / Partiel]
Utilisateurs à risque   : Élevé:[X] Moyen:[X]
Comptes inactifs >90j   : [X]
Guests inactifs >90j    : [X]
App registrations       : [X] total / [X] orphelines
Secure Score            : [XX]%

═══════════════════════════════════════════════
CONSTAT PURVIEW
═══════════════════════════════════════════════

DLP policies            : [X] total / [X] en Enforce
Workloads DLP couverts  : Exchange[✓/✗] SPO[✓/✗] OD[✓/✗] Teams[✓/✗]
Sensitivity labels      : [X] labels / [X] policies publiées
Rétention Exchange      : [Oui / Non]
Rétention SPO/OD        : [Oui / Non]
Unified Audit Log       : [Actif / DÉSACTIVÉ ⛔]
Partage externe SPO     : [Gouverné / Non gouverné]
Compliance Manager      : [XX]% — [framework]

═══════════════════════════════════════════════
TOP 5 LACUNES — PRIORITÉ
═══════════════════════════════════════════════

1. [🔴/🟡] [Lacune] — Pilier P[X] — Effort [X]h — Impact +[X] pts
2. [🔴/🟡] [Lacune] — Pilier P[X] — Effort [X]h — Impact +[X] pts
3. [🔴/🟡] [Lacune] — Pilier P[X] — Effort [X]h — Impact +[X] pts
4. [🟡/🟢] [Lacune] — Pilier P[X] — Effort [X]h — Impact +[X] pts
5. [🟡/🟢] [Lacune] — Pilier P[X] — Effort [X]h — Impact +[X] pts

QUICK WINS (impact rapide, effort faible)
- [Action] → +[X] pts P[X] — [X]h de travail
- [Action] → +[X] pts P[X] — [X]h de travail

PROCHAINE REVUE : [Date — trimestre suivant]
```

---

## SECTION B — RAPPORT CLIENT (Word/PowerPoint)

> **Instructions technicien :**
> 1. Copier cette section dans un document Word
> 2. Remplacer chaque zone [SCREENSHOT] par la capture correspondante
> 3. Compléter les zones [À COMPLÉTER]
> 4. Supprimer les instructions en italique avant envoi

---

### PAGE DE COUVERTURE

```
RAPPORT DE CONFORMITÉ SÉCURITÉ
[NOM DU CLIENT]
[PÉRIODE — ex: Q2 2026]

Préparé par : [Nom MSP]
Date : [Date]
Confidentiel — Usage interne client uniquement
```

---

### SECTION 1 — SCORE GLOBAL

**Score de maturité sécurité : [XX] / 100**

```
[SCREENSHOT — Microsoft Secure Score]
Chemin : security.microsoft.com/securescore
Capturer : le cercle de score + le pourcentage
```

*Ce score reflète votre posture de sécurité globale sur Microsoft 365 et Entra ID.
Un score de [XX]% signifie [interprétation non technique — ex: "votre environnement présente
des risques modérés qui méritent attention dans les 90 prochains jours"].*

---

### SECTION 2 — LES 5 PILIERS

#### Pilier 1 — Lifecycle Risk : [XX]/100

| Élément | État |
|---|---|
| Systèmes en fin de vie (EOL) | [✓ Aucun / ⚠️ X systèmes identifiés] |
| Protocoles obsolètes (Legacy Auth) | [✓ Bloqués / ⚠️ Actifs] |
| Versions logicielles | [✓ À jour / ⚠️ X éléments à mettre à jour] |

*[Commentaire non technique — 2 phrases max]*

---

#### Pilier 2 — Governance Integrity : [XX]/100

```
[SCREENSHOT — Entra ID → Rôles et administrateurs]
Chemin : entra.microsoft.com → Identity → Roles
Capturer : la liste des Global Admins
```

| Élément | État |
|---|---|
| Comptes administrateurs dédiés | [✓ Oui / ⚠️ Non] |
| Protection renforcée (PIM) | [✓ Actif / ⚠️ Inactif] |
| Authentification forte pour les admins | [✓ Oui / ⚠️ Partielle] |
| Révision des accès invités | [✓ En place / ⚠️ À configurer] |

*[Commentaire non technique — 2 phrases max]*

---

#### Pilier 3 — Continuity Assurance : [XX]/100

| Élément | État |
|---|---|
| Sauvegardes validées (<90 jours) | [✓ Oui / ⚠️ Non] |
| Comptes d'urgence (break-glass) | [✓ Configurés / ⚠️ Absents] |
| Politiques de rétention des données | [✓ Actives / ⚠️ Incomplètes] |
| Points de défaillance uniques documentés | [✓ Documentés / ⚠️ Non documentés] |

*[Commentaire non technique — 2 phrases max]*

---

#### Pilier 4 — Exposure Surface : [XX]/100

```
[SCREENSHOT — Compliance Manager ou DLP Overview]
Chemin : compliance.microsoft.com → Data loss prevention → Overview
Capturer : le dashboard DLP avec statut des politiques
```

| Élément | État |
|---|---|
| Authentification multi-facteurs (MFA) | [[XX]% des utilisateurs protégés] |
| Protection contre l'hameçonnage (DLP) | [✓ Active / ⚠️ Absente / ⚠️ Partielle] |
| Classification des données sensibles | [✓ En place / ⚠️ À configurer] |
| Partage externe contrôlé | [✓ Gouverné / ⚠️ Non restreint] |

*[Commentaire non technique — 2 phrases max]*

---

#### Pilier 5 — Operational Drift : [XX]/100

```
[SCREENSHOT — Compliance Manager Score]
Chemin : compliance.microsoft.com → Compliance Manager
Capturer : le score global + les frameworks évalués
```

| Élément | État |
|---|---|
| Comptes inactifs gérés | [[X] comptes à réviser] |
| Journal d'audit activé | [✓ Actif / ⚠️ DÉSACTIVÉ — Critique] |
| Score conformité Microsoft | [[XX]% — [Niveau]] |
| Alertes de sécurité traitées | [[X] alertes ouvertes] |

*[Commentaire non technique — 2 phrases max]*

---

### SECTION 3 — PRIORITÉS DE REMÉDIATION

| Priorité | Action | Délai recommandé | Effort estimé |
|---|---|---|---|
| 🔴 Critique | [Action 1] | Immédiat — 30 jours | [X]h |
| 🔴 Critique | [Action 2] | Immédiat — 30 jours | [X]h |
| 🟡 Important | [Action 3] | 60-90 jours | [X]h |
| 🟡 Important | [Action 4] | 60-90 jours | [X]h |
| 🟢 Recommandé | [Action 5] | 90-180 jours | [X]h |

---

### SECTION 4 — ÉVOLUTION DU SCORE

| Pilier | Score précédent | Score actuel | Tendance |
|---|---|---|---|
| P1 Lifecycle Risk | [XX] | [XX] | [↗ +X / ↘ -X / → stable] |
| P2 Governance Integrity | [XX] | [XX] | [↗ +X / ↘ -X / → stable] |
| P3 Continuity Assurance | [XX] | [XX] | [↗ +X / ↘ -X / → stable] |
| P4 Exposure Surface | [XX] | [XX] | [↗ +X / ↘ -X / → stable] |
| P5 Operational Drift | [XX] | [XX] | [↗ +X / ↘ -X / → stable] |
| **GLOBAL** | **[XX]** | **[XX]** | **[↗ / ↘ / →]** |

*[Premier audit : colonne "Score précédent" = N/A — Baseline établie ce trimestre]*

---

### SECTION 5 — PROCHAINES ÉTAPES

```
Prochaine revue trimestrielle : [Date]
Objectif score global Q[X+1]  : [XX]/100 (gain de [X] points)

Actions confirmées pour ce trimestre :
[ ] [Action 1] — Responsable : [MSP / Client] — Échéance : [Date]
[ ] [Action 2] — Responsable : [MSP / Client] — Échéance : [Date]
[ ] [Action 3] — Responsable : [MSP / Client] — Échéance : [Date]
```

---

## HANDOFF_BLOCK — IT-ReportMaster

```text
HANDOFF_BLOCK — Rapport Compliance 5 Piliers
CLIENT        : [À COMPLÉTER]
PÉRIODE       : [Q#-ANNÉE]
FRAMEWORK     : [À COMPLÉTER]
AUDITEUR      : [À COMPLÉTER]

SCORES :
P1 Lifecycle Risk       : [XX]/100
P2 Governance Integrity : [XX]/100
P3 Continuity Assurance : [XX]/100
P4 Exposure Surface     : [XX]/100
P5 Operational Drift    : [XX]/100
SCORE GLOBAL            : [XX]/100

CONSTATS CLÉS ENTRA ID :
- MFA : [XX]% enforced
- Legacy Auth bloqué : [Oui/Non]
- PIM : [Actif/Non]
- Risque utilisateurs : [X] élevé / [X] moyen
- Comptes inactifs : [X]

CONSTATS CLÉS PURVIEW :
- DLP enforce : [X] policies
- Labels déployés : [X]
- UAL actif : [Oui/Non]
- Compliance Manager : [XX]%

TOP 3 LACUNES :
1. [lacune] — P[X] — Effort [Xh]
2. [lacune] — P[X] — Effort [Xh]
3. [lacune] — P[X] — Effort [Xh]

FORMAT RAPPORT DEMANDÉ : [client-safe / exécutif / auditeur]
SCREENSHOTS DISPONIBLES : [Oui — joindre / Non — utiliser tableaux RAG]
```

*TEMPLATE_RAPPORT_Compliance_5Piliers_V1 — 2026-05-22*
