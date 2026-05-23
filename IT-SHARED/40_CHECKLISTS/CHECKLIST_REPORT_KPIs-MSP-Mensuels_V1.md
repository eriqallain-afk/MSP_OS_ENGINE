# CHECKLIST_REPORT_KPIs-MSP-Mensuels_V1
**Agent :** IT-ReportMaster
**Usage :** Collecte et validation des KPIs mensuels pour le rapport client
**Mis à jour :** 2026-03-20

---

## DONNÉES À COLLECTER (source : CW Manage + RMM)

### Tickets
- [ ] Nombre total de tickets ouverts dans le mois : _______
- [ ] Tickets P1 : _______ | P2 : _______ | P3 : _______ | P4 : _______
- [ ] MTTR (temps moyen résolution) P1 : _______ h | P2 : _______ h
- [ ] Taux de réouverture (reopen rate) : _______ %
- [ ] Tickets fermés dans le SLA : _______ %

### Disponibilité et performance
- [ ] Disponibilité infrastructure (uptime) — via RMM : _______ %
- [ ] Alertes critiques reçues : _______ | Traitées dans le SLA : _______ %
- [ ] Incidents P1/P2 ce mois : _______ | Avec postmortem : _______

### Sécurité
- [ ] Alertes EDR traitées : _______ | Incidents confirmés : _______
- [ ] Patchs critiques appliqués dans les 30 jours : _______ %
- [ ] Secure Score M365 ce mois : _______ (tendance ↑ ↓ =)

### Backup
- [ ] Taux de succès backup Datto/Veeam/Keepit : _______ %
- [ ] Tests DR effectués ce mois : ☐ Oui  ☐ Non | Résultat : _______
- [ ] Incidents backup P2+ : _______

---

## VALIDATION AVANT ENVOI DU RAPPORT

- [ ] Toutes les données collectées et vérifiées
- [ ] Incidents P1/P2 avec postmortem joints si applicable
- [ ] Recommandations du mois rédigées (3 max, actionnables)
- [ ] Rapport relu pour ne pas inclure : IPs internes, noms de serveurs sensibles, CVE détaillés
- [ ] Rapport envoyé au contact client dans les 5 jours ouvrables après fin de mois

---

## SEUILS D'ALERTE (à signaler dans le rapport)

| KPI | Seuil normal | Seuil alerte |
|---|---|---|
| Disponibilité infra | > 99.5% | < 99% |
| Tickets dans le SLA | > 95% | < 90% |
| Taux succès backup | > 98% | < 95% |
| Patchs critiques | 100% dans 30j | < 90% |
| Secure Score | > 60% | < 40% |
