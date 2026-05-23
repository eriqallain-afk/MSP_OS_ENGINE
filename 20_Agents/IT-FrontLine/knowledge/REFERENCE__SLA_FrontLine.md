# REFERENCE — SLA & Priorités IT-AssistanTI_FrontLine

## Matrice SLA

| Priorité | Critères | Délai réponse | Délai résolution | Escalade auto |
|---|---|---|---|---|
| **P1** | Service critique down, sécurité active, plusieurs départements | Immédiat | Escalade immédiate | Dès détection |
| **P2** | Groupe d'utilisateurs impactés (> 5), service dégradé | < 15 min | 8h | 2h si non résolu |
| **P3** | Utilisateur unique bloqué, problème fonctionnel | < 1h | 24h | 4h si bloqué |
| **P4** | Demande informationnelle, amélioration, changement planifié | < 4h | 72h | 24h |

## Règles FrontLine

| Situation | Action |
|---|---|
| P1 détecté | Escalade immédiate — aucune tentative de résolution |
| Scope FrontLine + < 45 min estimé | Résoudre directement |
| Scope FrontLine + > 45 min estimé | /triage + transférer |
| Hors scope FrontLine | /triage + transférer immédiatement |
| MDP sans vérification identité | Bloquer — refuser poliment |
| Processus inconnu / sécurité suspecte | @IT-SecurityMaster — ne pas toucher |

## Escalades par domaine

| Domaine | Agent | Délai max |
|---|---|---|
| MFA, Exchange, Teams, Entra | @IT-CloudMaster | Immédiat |
| Infrastructure serveur | @IT-AssistanTI_N3 | Immédiat |
| VPN complexe, firewall | @IT-NetworkMaster | Immédiat |
| Sécurité, virus, suspect | @IT-SecurityMaster | Immédiat |
| Téléphonie | @IT-VoIPMaster | Immédiat |
| P1 réseau / site | @IT-Commandare-NOC | < 5 min |
| P1 serveur / infra | @IT-Commandare-Infra | < 5 min |
| P2 multi-users | @IT-NOCDispatcher | < 10 min |
| Clôture formelle complexe | @IT-TicketScribe | Post-résolution |
