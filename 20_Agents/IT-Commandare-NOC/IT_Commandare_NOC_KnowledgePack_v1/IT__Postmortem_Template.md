# IT — Post-Mortem Template NOC (avec CAPA)

> Usage : déclencher pour tout incident S0 et tout S1 > 60 min ou récidive.
> Owner : NOC (timeline) + TECH (RCA) + OPR (comms/CAPA) + CTO (validation).

---

## 1) Executive Summary

| Champ | Valeur |
|-------|--------|
| **Incident ID** | INC-YYYY-XXXX |
| **Sévérité** | S0 / S1 / S2 |
| **Client(s) impacté(s)** | |
| **Service(s) affecté(s)** | |
| **Début incident** | AAAA-MM-JJ HH:MM |
| **Fin incident** | AAAA-MM-JJ HH:MM |
| **Durée totale** | X h Y min |
| **MTTD** | X min |
| **MTTA** | X min |
| **MTTR** | X h |
| **Cause racine (résumé)** | |
| **Résolution appliquée** | |
| **Impact estimé** | X utilisateurs / X services / X$ |
| **Leçon principale** | |

---

## 2) Timeline (NOC — faits vérifiés uniquement)

| Heure | Acteur | Action / Observation |
|-------|--------|---------------------|
| T+00:00 | Monitoring | Alerte déclenchée : |
| T+00:05 | NOC | ACK + évaluation initiale |
| T+00:XX | NOC | Escalade vers TECH — motif : |
| T+00:XX | TECH | Prise en charge — diagnostic : |
| T+00:XX | OPR | Communication client envoyée |
| T+00:XX | TECH | Mitigation appliquée : |
| T+00:XX | NOC | Service restauré — validation : |
| T+00:XX | OPR | Communication résolution client |

> Règle : consigner uniquement les FAITS vérifiés. Séparer faits / hypothèses / actions.

---

## 3) Root Cause Analysis — TECH

**Symptômes observés :**
-

**Investigation :**
1.
2.
3.

**Cause racine identifiée :**

**Facteurs contributifs :**
-
-

**Pourquoi maintenant ? (trigger immédiat) :**

**Pourquoi pas détecté avant ? (gap monitoring/process) :**

---

## 4) Changements effectués — INFRA

| Élément modifié | Avant | Après | RFC# |
|----------------|-------|-------|------|
| | | | |

- **Validation post-change :**

---

## 5) Sécurité — SECURITY (si applicable)

- **Indicateurs de compromission (IOC) :** ☐ Oui ☐ Non
- **Données exposées :** ☐ Oui ☐ Non — Détail :
- **Containment appliqué :**
- **Logs/Evidence conservés :**
- **Obligation de notification (légale/contractuelle) :** ☐ Oui ☐ Non

---

## 6) CAPA — Corrective & Preventive Actions

| # | Action | Type | Owner | Échéance | Effort | KPI attendu |
|---|--------|------|-------|----------|--------|-------------|
| 1 | | C/P | | | S/M/L | |
| 2 | | C/P | | | S/M/L | |
| 3 | | C/P | | | S/M/L | |

> **C** = Corrective (fix immédiat), **P** = Préventive (éviter récurrence), **S/M/L** = Small/Medium/Large

---

## 7) Suivi CAPA

| Date revue | Statut | Commentaire |
|-----------|--------|-------------|
| | En cours / Complété / Bloqué | |

**Date validation CTO :**
**Archivage Dossier IA (OPS-DossierIA) :**

---

## 8) Communication client envoyée

- **Email initial (T+XX) :** ☐ Oui ☐ Non
- **Updates intermédiaires :** X envoyé(s)
- **Email résolution :** ☐ Oui ☐ Non
- **Appel client post-incident :** ☐ Requis ☐ Non requis ☐ Effectué

---

> Voir aussi : IT__Severity_Matrix.md | IT__Escalation_Playbook.md | IT__KPI_Definitions.md
