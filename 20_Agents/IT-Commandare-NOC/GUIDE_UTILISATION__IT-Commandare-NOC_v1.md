# Guide d'utilisation — @IT-Commandare-NOC (v1.0)
> **Pour :** Techniciens NOC, analystes MSP, agents de coordination
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-Commandare-NOC ?

**IT-Commandare-NOC est le commandant des opérations du Network Operations Center.**

Il ne fait pas le travail de diagnostic technique lui-même — il **triage, classe, coordonne et mobilise**. Quand une alerte réseau, VPN, backup ou monitoring arrive, Commandare-NOC l'analyse, détermine la sévérité (P1 à P4), établit le plan de réponse initial et mobilise le bon spécialiste.

| Domaine | Ce que gère Commandare-NOC |
|---|---|
| Réseau | Routeurs, switches, pare-feux, liens WAN, BGP, MPLS, VLAN |
| VPN | Tunnels site-à-site, VPN utilisateur, connectivité distante |
| Backup / DR | Jobs Veeam/Datto en échec, RPO/RTO compromis |
| Monitoring | Corrélation d'alertes, bruit NOC, faux positifs, seuils |
| VoIP / UC | Trunks SIP down, enregistrement PBX, alertes UC |
| Urgences | Premier répondant pour tout incident non classifié |

**Commandare-NOC ne gère PAS :**
- Tickets support utilisateur → IT-Commandare-TECH
- Incidents serveurs/VMs/Cloud → IT-Commandare-Infra
- Incidents sécurité actifs (breach, malware) → IT-SecurityMaster
- Clôture administrative → IT-Commandare-OPR

---

## Quand l'utiliser ?

- Une alerte RMM ou SIEM arrive et tu dois déterminer la sévérité et le plan d'action
- Un lien WAN est down et tu dois coordonner la réponse
- Plusieurs alertes arrivent simultanément pour le même client ou site (corrélation)
- Un job Veeam ou Datto échoue depuis plus de 24h
- Tu dois générer une notice Teams pour le début ou la fin d'un incident NOC
- Tu dois préparer une clôture CW formelle après stabilisation

---

## Les commandes principales

### `/triage` — Analyser un incident ou une alerte

La commande principale. Tu fournis l'alerte ou le contexte de l'incident, Commandare-NOC classe la sévérité, identifie le domaine et produit le plan de réponse.

**Usage :**
```
/triage
Alerte RMM — Billet #77401
Client : Otto Transport
Description : Lien WAN principal — perte de connectivité depuis 14:32
Équipements affectés : Routeur principale bureau principal
Utilisateurs impactés : 67 utilisateurs sans accès réseau
Lien de secours : LTE disponible mais non activé
```

**Ce que tu obtiens (YAML) :**
```yaml
result:
  noc_domain: réseau
  severity: P1
  decision:
    routing: IT-NetworkMaster
    escalate_to: IT-Commandare-Infra  # si DC affecté
  actions_now:
    - Activer le lien LTE de secours immédiatement
    - Contacter IT-NetworkMaster pour diagnostic routeur
    - Notifier le client — impact confirmé
  sla: "< 5 min"
```

---

### `/escalade` — Générer le bloc CW de transfert

Quand un incident dépasse ton périmètre ou qu'un spécialiste doit prendre le lead.

**Usage :**
```
/escalade IT-Commandare-Infra
Billet #77401 — DC01 inaccessible suite panne réseau
Contexte : lien WAN down depuis 14:32, LTE activé, mais DC01 sur réseau principal toujours offline
```

**Ce que tu obtiens :**
- Bloc CW structuré prêt à coller dans ConnectWise
- Contexte complet pour l'agent cible
- `next_actions` avec ETA et owner clairement définis

---

### `/teams` — Générer la notice Teams

Pour toute intervention, une notice Teams est obligatoire dès que le type d'incident est connu.

**Usage :**
```
/teams
Billet : #77401
Client : Otto Transport
Type : Panne réseau — WAN principal
Statut : Actif — en cours
```

**Ce que tu obtiens :**
```
⚠️ Incident actif — Billet : #77401

Panne réseau chez Otto Transport
Tâche principale : Rétablissement lien WAN principal
Impact : 67 utilisateurs sans accès réseau
```

---

### `/flagup` — Passation structurée (Flag Up)

Quand l'intervention doit être transmise au quart suivant ou à un autre agent.

**Usage :**
```
/flagup
Billet #77401 — Otto Transport
Statut : LTE actif — réseau partiel rétabli
En attente : technicien FAI confirmé pour 17h00
Prochaine action : valider remplacement équipement FAI
Agent suivant : IT-Commandare-NOC (quart de soir)
```

**Ce que tu obtiens :**
- Contexte complet pour la passation
- État précis : ce qui est fait, ce qui reste, qui attend quoi
- Notice Teams de passation générée

---

### `/close` — Clôture CW

Déclenche le menu de clôture pour générer les livrables CW formels.

**Usage :**
```
/close
```

**Ce que tu obtiens (menu — STOP en attente de ton choix) :**
```
Clôture — Billet #[XXXXX]
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout (1+2+3+4)

Que veux-tu générer ?
```

> Important : Commandare-NOC attend ton choix avant de générer quoi que ce soit.

---

### `/status` — Résumé en cours

Pour avoir un résumé rapide de l'état de l'intervention active.

**Usage :**
```
/status
```

**Ce que tu obtiens :**
- Résumé : billet, client, domaine, sévérité
- Dernière action confirmée + prochaine étape
- Agents mobilisés et leurs statuts

---

## Flux de travail recommandé

### Incident NOC standard

```
1. Alerte reçue (RMM / SIEM / appel)
        ↓
2. /triage [description complète de l'alerte]
   → Sévérité + domaine + plan d'action + spécialiste mobilisé
        ↓
3. Notifier Teams immédiatement (/teams)
        ↓
4. Mobiliser le spécialiste NOC (IT-NetworkMaster, IT-BackupDRMaster, etc.)
        ↓
5. Suivre l'évolution — /status pour mises à jour
        ↓
6. Incident stabilisé → /close [choix livrable CW]
        ↓
7. Passer à IT-Commandare-OPR pour la clôture formelle si P1/P2
```

### Corrélation multi-alertes

```
1. Plusieurs alertes arrivent pour le même client/site dans un court intervalle
        ↓
2. /triage avec TOUTES les alertes listées
   → Commandare-NOC identifie le pattern (incident multi-composants)
        ↓
3. Plan de réponse unique coordonné — parallel_tracks si plusieurs domaines
        ↓
4. Un seul technicien coordinateur pour éviter les collisions
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| P1 NOC → réponse < 5 min | Chaque minute de délai a un impact client direct |
| Jamais acquitter une alerte P1 sans investigation | Un faux positif confirmé vaut mieux qu'une panne manquée |
| Corrélation obligatoire si même client/site simultané | Plusieurs alertes simultanées = incident unique jusqu'à preuve du contraire |
| Teams obligatoire dès que le type est connu | La communication est aussi critique que l'intervention technique |
| ZÉRO IP dans les livrables CW_DISCUSSION | Visible sur facture client — toujours utiliser des descriptions génériques |
| Escalader si hors périmètre NOC | Un routage rapide est plus efficace qu'une tentative hors périmètre |

---

## Questions fréquentes

**Q : Quelle différence entre Commandare-NOC et IT-NetworkMaster ?**
Commandare-NOC triage, classe et coordonne. IT-NetworkMaster effectue le diagnostic technique et la remédiation réseau. Commandare-NOC mobilise IT-NetworkMaster — il ne remplace pas le spécialiste.

**Q : Est-ce que Commandare-NOC gère les incidents serveurs ?**
Non. Serveurs, VMs, DC, Azure → IT-Commandare-Infra. Commandare-NOC reste sur les domaines réseau, VPN, backup, monitoring, VoIP.

**Q : Que faire si je ne sais pas si c'est P1 ou P2 ?**
Lance `/triage` avec tout le contexte disponible. Commandare-NOC détermine la sévérité selon la matrice P1-P4. En cas de doute → toujours classer au niveau supérieur et ajuster après investigation.

**Q : Dois-je toujours notifier Teams ?**
Oui. La règle est absolue : toute intervention est notifiée dans Teams dès que le type d'incident est connu, avec le numéro de billet.

**Q : Qui gère la clôture formelle après un P1 ?**
Commandare-NOC génère les livrables CW (Note Interne + Discussion). Pour la clôture formelle avec DoD (Definition of Done) complet, il passe à IT-Commandare-OPR.

---

*GUIDE_UTILISATION — IT-Commandare-NOC v1.0 — MSP Intelligence AI — 2026-05-18*
