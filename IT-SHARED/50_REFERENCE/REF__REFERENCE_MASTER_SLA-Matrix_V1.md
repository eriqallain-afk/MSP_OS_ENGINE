# REFERENCE_MASTER_SLA-Matrix_V1
**Agent :** Tous les agents IT MSP, IT-MaintenanceMaster, IT-SysAdmin
**Usage :** Référence SLA — priorités, délais de réponse, escalades
**Mis à jour :** 2026-03-20

---

## MATRICE SLA MSP

| Priorité | Définition | Exemples | Réponse | Résolution | Escalade auto |
|---|---|---|---|---|---|
| **P1 — Critique** | Panne totale ou données à risque | DC down, ransomware, réseau site complet, breach | 15 min | 4h | 30 min → Senior + client |
| **P2 — Majeur** | Service essentiel dégradé, impact large | VPN down, Exchange inaccessible, VEEAM job critique failed, RDS down | 30 min | 8h | 2h → Senior |
| **P3 — Normal** | Impact limité, workaround possible | Imprimante, poste lent, appli secondaire lente, backup non-critique | 2h | 24h | 4h → N2 |
| **P4 — Faible** | Aucun impact immédiat | Demande de service, info, changement planifié, ajout compte | 4h | 72h | 24h → N2 |

---

## RÈGLES DE RECLASSIFICATION

**Monter la priorité si :**
- L'impact s'étend à plus d'utilisateurs que prévu
- Une donnée sensible est exposée ou à risque
- Le contournement (workaround) cesse de fonctionner
- Un deuxième système tombe pendant l'incident

**Descendre la priorité si :**
- Un contournement stable est en place
- L'impact est confirmé comme limité à 1-2 utilisateurs
- Le client confirme que l'impact business est minimal

---

## DÉLAIS DE COMMUNICATION CLIENT

| Priorité | Premier contact | Mises à jour | Communication résolution |
|---|---|---|---|
| P1 | Immédiat (call ou Teams) | Toutes les 30 min | Immédiatement à la résolution |
| P2 | 30 min | Toutes les 2h | À la résolution + email |
| P3 | 2h | 1x/jour si non résolu | Email résolution |
| P4 | 4h | À la résolution | Email résolution |

---

## DÉFINITION DES NIVEAUX DE SUPPORT

| Niveau | Qui | Scope |
|---|---|---|
| **N1** | Technicien junior / Help Desk | Réinitialisation MDP, imprimantes, poste utilisateur, questions de base |
| **N2** | Technicien support | Tickets P3/P4, dépannage avancé utilisateur, accès réseau, email |
| **N3** | Technicien senior / Spécialiste | Tickets P1/P2, serveurs, réseau, sécurité, RDS, AD |
| **NOC** | Équipe NOC | Monitoring, alertes, maintenances, incidents infrastructure |
| **SOC** | Équipe sécurité | Incidents sécurité, EDR, breach, phishing, analyse menaces |

---

## HORS HEURES

- **Heures ouvrables :** Lundi–Vendredi 8h–17h (heure locale du client)
- **P1 hors heures :** Alerte on-call → réponse 30 min
- **P2 hors heures :** Évaluation → traitement au début du quart suivant sauf aggravation
- **P3/P4 hors heures :** Traitement le prochain jour ouvrable
