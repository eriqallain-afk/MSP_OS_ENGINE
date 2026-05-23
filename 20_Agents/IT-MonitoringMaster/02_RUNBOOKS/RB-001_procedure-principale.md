# RB-001 — Configuration et Revue Seuils RMM
**Agent :** IT-MonitoringMaster | **Usage :** Configuration monitoring client
## Seuils standards MSP
| Indicateur | Attention | Critique |
|---|---|---|
| CPU | > 70%/15min | > 90%/5min |
| RAM libre | < 20% | < 10% |
| Disque libre | < 20% | < 5% |
| Ping | > 100ms | Timeout 3 essais |
| Service Auto | Arrêté | — |
| Backup | Job > 24h | Job > 48h |

## Mode maintenance RMM
**Toujours activer avant toute intervention**
N-able : Devices → [Device] → Put in Maintenance Mode
CW RMM : Devices → Actions → Maintenance Mode
**Désactiver immédiatement après**