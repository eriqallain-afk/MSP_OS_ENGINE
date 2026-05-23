# IT — KPI Definitions (NOC)

> Version NOC : focus sur les métriques d'incident, d'alerte et de disponibilité.

---

## KPIs Incident (NOC primaires)

| KPI | Définition | Calcul | Cible MSP |
|-----|-----------|--------|-----------|
| **MTTD** | Mean Time To Detect — délai entre début incident et première alerte | T(alerte) - T(début_incident) | < 5 min (S0/S1) |
| **MTTA** | Mean Time To Acknowledge — délai entre alerte et prise en charge NOC | T(ACK) - T(alerte) | < 5 min (S0), < 15 min (S1) |
| **MTTR** | Mean Time To Resolve — délai total détection → résolution complète | T(résolution) - T(détection) | < 4h (S1), < 24h (S2) |
| **MTTF** | Mean Time To Failure — temps moyen entre deux incidents sur même composant | Σ(uptime) / nb_incidents | Référence baseline |

---

## KPIs Disponibilité

| KPI | Définition | Calcul | Cible |
|-----|-----------|--------|-------|
| **Uptime %** | Disponibilité service sur période | (temps_total - temps_panne) / temps_total × 100 | ≥ 99.5% |
| **SLA Compliance** | % tickets/incidents respectant les SLA définis | nb_dans_sla / nb_total × 100 | ≥ 95% |
| **Alert Noise Ratio** | % alertes qui sont de vrais incidents (vs faux positifs) | vrais_incidents / total_alertes × 100 | ≥ 70% |
| **Escalation Rate** | % incidents nécessitant escalade vers TECH ou CTO | incidents_escaladés / total_incidents × 100 | < 20% |

---

## KPIs Qualité NOC

| KPI | Définition | Cible |
|-----|-----------|-------|
| **First Call Resolution (FCR)** | % incidents résolus sans escalade | ≥ 75% |
| **Update Cadence Compliance** | % incidents avec updates dans les délais définis | ≥ 95% |
| **Documentation Rate** | % incidents avec notes CW complètes à la clôture | 100% |
| **Repeat Incident Rate** | % incidents identiques sur même client/service (30j) | < 10% |

---

## Seuils d'alerte NOC

```
CRITIQUE  → MTTD > 10 min sur S0
CRITIQUE  → MTTA > 5 min sur S0
ATTENTION → SLA Compliance < 90%
ATTENTION → Alert Noise Ratio < 50% (trop de bruit → ajuster MonitoringMaster)
INFO      → Repeat Incident Rate > 15% (même service) → escalade TECH pour RCA
```

---

## Tableaux de bord recommandés (shift)

**Début de quart (NOC)**
- [ ] Incidents actifs S0/S1 en cours
- [ ] SLA à risque (< 2h avant breach)
- [ ] Alertes ouvertes non ACK

**Fin de quart (NOC)**
- [ ] Résumé : nb alertes / incidents / escalades
- [ ] MTTR moyen du quart
- [ ] Handover : incidents chauds à transmettre

---

> Voir aussi : IT__Severity_Matrix.md pour les définitions S0-S4 et cadences.
