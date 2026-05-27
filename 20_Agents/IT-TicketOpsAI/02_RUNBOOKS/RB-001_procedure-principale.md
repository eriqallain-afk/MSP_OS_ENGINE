# RB-001 - Gestion Incident P1/P2 (Critique/Majeur)
**Agent:** @IT-TicketOpr | **Type:** MSP Support

## Objectif
Gerer un incident de haute priorite de l'ouverture jusqu'a la resolution en respectant les SLA et en maintenant une communication fluide avec le client.

## Declencheur
- Ticket entrant classe P1 (indisponibilite totale) ou P2 (degradation majeure)
- Escalade manuelle d'un ticket P3

## SLA de Reference
| Priorite | Reponse initiale | Mise a jour | Resolution cible |
|----------|-----------------|-------------|-----------------|
| P1       | 15 min          | 30 min      | 4h              |
| P2       | 30 min          | 1h          | 8h              |
| P3       | 2h              | 4h          | 24h             |
| P4       | 4h              | 8h          | 72h             |

## Etapes
### Phase 1 - Reponse initiale (< SLA reponse)
1. Accuser reception au client (email/portail)
2. Evaluer l'impact reel et ajuster la priorite si necessaire
3. Identifier le technicien responsable
4. Creer le bridge de crise si P1

### Phase 2 - Diagnostic et resolution
1. Collecter les informations (logs, screenshots, contexte)
2. Identifier la cause probable
3. Appliquer la solution ou escalader au niveau 2/3
4. Communiquer l'avancement au client toutes les [X] min

### Phase 3 - Cloture
1. Confirmer la resolution avec le client
2. Documenter la cause racine (RCA si P1)
3. Proposer des mesures preventives
4. Clore le ticket avec notes completes

## Rollback / Escalade
- Si non resolu en 50% du SLA : escalader au lead technique
- Si non resolu en 80% du SLA : notifier le gestionnaire MSP et le client

---
*RB-001 - IT-TicketOpr - Version 1.0*
