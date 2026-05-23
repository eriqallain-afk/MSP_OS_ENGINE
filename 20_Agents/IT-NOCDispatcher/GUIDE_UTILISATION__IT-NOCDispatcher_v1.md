# Guide d'utilisation — @IT-NOCDispatcher (v1.0)
> **Pour :** Techniciens N1/N2, agents NOC, coordonnateurs MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-NOCDispatcher ?

**IT-NOCDispatcher est le premier point de qualification de toute alerte ou ticket entrant.**

Il ne résout pas les incidents — il les qualifie, les priorise, les route vers le bon agent ou technicien, et surveille le SLA jusqu'à stabilisation.

| Ce qu'il fait | Ce qu'il ne fait pas |
|---|---|
| Qualifier la priorité P1/P2/P3/P4 | Résoudre techniquement l'incident |
| Assigner au bon agent/technicien | Prendre des décisions techniques seul |
| Générer la notice Teams initiale | Fermer le billet sans owner assigné |
| Piloter le suivi SLA | Laisser un P1 sans escalade > 10 min |
| Préparer la passation de quart | |

> **Principe clé : Qualifier avant d'escalader. Toujours produire une décision même partielle.**

---

## Quand l'utiliser ?

- Tu reçois une alerte RMM et tu dois décider de la priorité et de qui l'assigner
- Un ticket CW arrive sans assignation claire
- Un P1/P2 risque de dépasser son SLA et tu dois escalader structurellement
- La fin de quart approche et tu dois faire la passation à l'équipe suivante
- Tu veux un résumé des incidents P1/P2 actifs en ce moment

---

## Les commandes principales

### `MODE=DISPATCH` — Dispatcher un ticket ou alerte entrant

La commande principale. Utilise le mode DISPATCH pour toute alerte ou ticket entrant.

**Usage — alerte RMM :**
```
MODE=DISPATCH
Alerte RMM : Client Otto Group — CPU 97% depuis 18 min sur SRV-APP01
Type : Alerte monitoring automatique
Billet CW : À créer
```

**Usage — ticket CW entrant :**
```
MODE=DISPATCH
Ticket CW #77088 — Client : Otto Mfg
Description : VPN site-to-site down depuis 30 min — 45 utilisateurs sans accès réseau siège
Signalé par : Directeur TI via appel
```

**Ce que tu obtiens :**
```yaml
result:
  mode: DISPATCH
  ticket_id: "#77088"
  severity: P2
  domaine: réseau
  owner_assigne: "@IT-NetworkMaster"
  summary: "VPN site-to-site inaccessible — 45 utilisateurs bloqués depuis 30 min"
  actions_immediates:
    - "Ouvrir billet CW P2 si non existant"
    - "Aviser IT-NetworkMaster — délai réponse : 30 min max"
    - "Envoyer notice Teams aux clients affectés"
  sla:
    reponse_avant: "14:45"
    resolution_avant: "16:15"
  communication_client:
    requise: true
    message: "Incident réseau en cours — équipe mobilisée — mise à jour dans 30 min"
```

---

### `MODE=ESCALADE_SLA` — Gérer un dépassement de SLA

Quand un ticket risque de dépasser son SLA cible.

**Usage :**
```
MODE=ESCALADE_SLA
Ticket CW #77062 — Client : Otto Inc — P2
SLA cible : 16:00 — Il est actuellement 15:35 — 25 min restants
Raison blocage : Technicien en attente d'accès VPN client non disponible
```

**Ce que tu obtiens :**
- Analyse de la situation SLA (temps écoulé / restant)
- Raison du blocage identifiée
- Agent d'escalade recommandé
- Actions de mitigation immédiates
- Communication client requise ou non

---

### `MODE=SHIFT_HANDOVER` — Passation de quart

Produit un document de passation structuré pour l'équipe du quart suivant.

**Usage :**
```
MODE=SHIFT_HANDOVER
Quart : 08h00 → 16h00
Passation à : Équipe de soir (16h00)
```

**Ce que tu obtiens :**
- Tous les tickets P1/P2 actifs avec statut et prochaine action
- Alertes RMM non acquittées
- Maintenances planifiées dans le quart suivant
- Points d'attention (clients en surveillance renforcée, serveurs instables)

---

### `/dispatch` — Dispatch rapide (commande courte)

Alias simplifié pour le mode DISPATCH.

**Usage :**
```
/dispatch #77099 — Client : Otto Mfg — Serveur DC01 inaccessible depuis 5 min
```

---

### `/escalade_sla` — Escalade SLA rapide

**Usage :**
```
/escalade_sla #77062 — SLA à 16:00 — il est 15:45 — blocage accès VPN
```

---

### `/handover` — Passation de quart rapide

**Usage :**
```
/handover
```

---

### `/status` — Résumé des tickets actifs

Résumé rapide de tous les P1/P2 en cours.

**Usage :**
```
/status
```

---

### `/close` — Clôture CW du dispatch

Génère les livrables CW après résolution d'un ticket dispatché.

**Usage :**
```
/close
Billet #77088 — VPN Otto Mfg résolu. IT-NetworkMaster a corrigé la config BGP.
Durée totale : 1h35. SLA P2 respecté.
```

**Menu affiché (puis STOP — attendre ton choix) :**
```
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout (1+2+3+4)
```

---

## Matrice de priorité — référence rapide

| Priorité | Définition | Exemples fréquents | Délai réponse | Escalade auto |
|---|---|---|---|---|
| **P1** | Panne totale / données à risque / sécurité | DC down, ransomware, réseau site complet down | 15 min | 30 min → IT-Commandare-NOC |
| **P2** | Service essentiel dégradé | VPN down, Exchange inaccessible, backup critique KO | 30 min | 2h → Senior |
| **P3** | Impact limité, workaround possible | Imprimante en panne, poste lent, appli secondaire | 2h | 4h → N2 |
| **P4** | Aucun impact immédiat | Demande de service, changement planifié, info | 4h | 24h → N2 |

---

## Flux de travail recommandé

### Alerte RMM reçue

```
1. Alerte RMM reçue (email / dashboard / appel)
        ↓
2. MODE=DISPATCH [décrire l'alerte + client]
        ↓
3. Lire la décision : severity / owner / actions_immediates / SLA cible
        ↓
4. Créer ou mettre à jour le billet CW
   Assigner à l'owner recommandé
        ↓
5. Envoyer la notice Teams (si P1/P2 — obligatoire)
        ↓
6. Surveiller le SLA
   → Si risque dépassement : MODE=ESCALADE_SLA
```

### Fin de quart

```
1. 15 min avant la fin du quart
        ↓
2. MODE=SHIFT_HANDOVER [quart en cours → quart suivant]
        ↓
3. Partager le document de passation via Teams
        ↓
4. Briefer verbalement l'équipe suivante sur les P1/P2 actifs
```

---

## Notice Teams — format obligatoire

Toute intervention P1/P2 déclenche une notice Teams dès que le type est connu.

**Format :**
```
[ICÔNE] [Statut] — Billet : #[XXXXX]
[Situation] chez [Client]
Tâche principale : [Action en cours]
Impact : [Description de l'impact]
```

**Exemples :**
```
⚠️ Incident réseau P2 actif — Billet : #77088
VPN site-to-site inaccessible chez Otto Mfg
Tâche principale : Diagnostic et restauration VPN
Impact : 45 utilisateurs sans accès réseau siège — équipe mobilisée
```

```
✅ Incident résolu — Billet : #77088
VPN rétabli chez Otto Mfg
Tâche principale : Validation post-résolution complétée
Impact : Accès réseau siège confirmé — tous les utilisateurs opérationnels
```

| Icône | Quand l'utiliser |
|---|---|
| ⚠️ | Incident actif en cours |
| 🔄 | Validation / tests en cours |
| 🚩 | Flag Up / action requise par une équipe |
| ✅ | Intervention terminée |

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Toujours produire une décision — même partielle | Pas de ticket sans owner ni priorité |
| P1 non assigné > 10 min → escalade IT-Commandare-NOC immédiate | SLA P1 = 15 min — zéro tolérance |
| Zéro ticket P1/P2 sans owner à la fermeture de chaque échange | Responsabilité claire |
| ZÉRO IP dans Discussion CW et livrables clients | Client-safe obligatoire |
| Info non confirmée → `[À CONFIRMER]` | Séparer faits et hypothèses |
| Notice Teams obligatoire dès que le type P1/P2 est connu | Communication coordonnée |

---

## Questions fréquentes

**Q : Quelle différence entre IT-NOCDispatcher et IT-UrgenceMaster ?**
IT-NOCDispatcher qualifie et route les tickets entrants — il est le premier point de contact.
IT-UrgenceMaster est le copilote live pour les P1/P2 en cours — il guide le technicien qui est déjà en train de gérer l'urgence.
En pratique : NOCDispatcher dispatch → UrgenceMaster copilote l'intervention.

**Q : Que faire si je ne sais pas si c'est P1 ou P2 ?**
Fournis le maximum d'informations disponibles. L'agent attribue une priorité avec justification. En cas de doute, il recommande de traiter en P1 jusqu'à confirmation du périmètre réel.

**Q : Comment gérer une alerte RMM chronique (faux positifs récurrents) ?**
Dispatch normalement la première occurrence. Si c'est récurrent, escalade vers `@IT-MonitoringMaster` pour révision des seuils. Note-le dans le handover.

**Q : Est-ce que IT-NOCDispatcher fait le suivi jusqu'à la résolution ?**
Non — il assigne et surveille le SLA. La résolution technique appartient à l'agent ou technicien assigné. Si le SLA est à risque, IT-NOCDispatcher génère l'escalade via `MODE=ESCALADE_SLA`.

---

*GUIDE_UTILISATION — IT-NOCDispatcher v1.0 — MSP Intelligence AI — 2026-05-18*
