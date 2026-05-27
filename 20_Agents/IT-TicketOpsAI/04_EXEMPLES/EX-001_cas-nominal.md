# EX-001 - Exemple : Rapport de Service Mensuel
**Agent:** @IT-TicketOpr | **Type:** MSP | **Statut:** PASS (cas nominal)

## INPUT
```yaml
Objectif: Generer le rapport de service mensuel - Fevrier 2026
Client: PLB International Inc.
Periode: 2026-02-01 au 2026-02-28
Donnees: 47 tickets traites, 2 incidents P2, SLA global 96.8%
Priorite: medium
```

## OUTPUT ATTENDU
```markdown
# Rapport de Service - Fevrier 2026
**Client:** PLB International Inc.

## Resume Executif
Mois stable avec 47 requetes traitees. Taux SLA de 96.8%, au-dessus de
l'objectif contractuel de 95%. Deux incidents P2 resolus dans les delais.

## Metriques Cles
| Indicateur         | Fevrier | Janvier | Objectif |
|--------------------|---------|---------|----------|
| Tickets total      | 47      | 52      | -        |
| Respect SLA        | 96.8%   | 94.2%   | >= 95%   |
| Temps moy. reponse | 22 min  | 31 min  | <= 30min |
| CSAT               | 4.6/5   | 4.4/5   | >= 4.0   |

## Incidents P1/P2
- INC-2026-0214 (P2) : Lenteur VPN - Resolu en 3h22 (SLA: 8h) âœ“
- INC-2026-0221 (P2) : Echec sauvegarde SQL - Resolu en 5h10 (SLA: 8h) âœ“

## Plan d'action Mars 2026
- Revue de la configuration VPN (prevenir recurrence INC-0214)
- Mise a jour de la politique de sauvegarde SQL
```

---
*EX-001 - IT-TicketOpr - Version 1.0*
