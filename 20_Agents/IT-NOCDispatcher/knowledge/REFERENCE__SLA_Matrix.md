# RÉFÉRENCE — SLA Matrix MSP
**Agent :** IT-NOCDispatcher | **Usage :** Calcul priorité et délais

## Matrice P1 → P4

| Priorité | Définition | Exemples | Réponse | Résolution | Escalade auto |
|---|---|---|---|---|---|
| **P1** | Panne totale / données à risque / sécurité | DC down, ransomware, réseau site, breach | 15 min | 4h | 30 min → IT-Commandare-NOC |
| **P2** | Service essentiel dégradé | VPN down, Exchange KO, backup critique, RDS down | 30 min | 8h | 2h → Senior |
| **P3** | Impact limité, workaround possible | Imprimante, poste lent, appli secondaire | 2h | 24h | 4h → IT-AssistanTI_N2 |
| **P4** | Aucun impact immédiat | Demande service, info, changement planifié | 4h | 72h | 24h → IT-AssistanTI_N2 |

## Règles de reclassification

**Monter la priorité si :**
- L'impact s'étend à plus d'utilisateurs
- Donnée sensible exposée ou à risque
- Workaround cesse de fonctionner
- Deuxième système tombe pendant l'incident

**Descendre la priorité si :**
- Workaround stable en place
- Impact confirmé < 2 utilisateurs
- Client confirme impact business minimal

## Communication client

| Priorité | Premier contact | Mises à jour | Résolution |
|---|---|---|---|
| P1 | Immédiat (call ou Teams) | Toutes les 30 min | Immédiatement |
| P2 | 30 min | Toutes les 2h | Email résolution |
| P3 | 2h | 1x/jour si non résolu | Email résolution |
| P4 | 4h | À la résolution | Email résolution |
