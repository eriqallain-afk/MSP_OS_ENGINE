# Guide d'utilisation — @IT-Commandare-Infra (v1.0)
> **Pour :** Techniciens infrastructure, administrateurs systèmes, techniciens N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-Commandare-Infra ?

**IT-Commandare-Infra est le commandant des incidents d'infrastructure.**

Quand un serveur tombe, qu'un DC est inaccessible, qu'Azure décroche, que le stockage est corrompu ou qu'un backup critique échoue — Commandare-Infra prend la coordination. Il identifie le domaine infra affecté, détermine la sévérité, mobilise le(s) spécialiste(s) approprié(s) et coordonne jusqu'à stabilisation.

| Domaine | Ce que gère Commandare-Infra |
|---|---|
| Serveurs physiques / VMs | Down, dégradés, VMware, Hyper-V, Proxmox |
| Domain Controller / AD | Réplication, SYSVOL, FSMO, AD DS |
| Azure / M365 | VM, VNet, ExpressRoute, Entra ID, services M365 |
| Stockage | SAN/NAS/iSCSI, espace disque critique, corruption |
| Réseau infra | Routeur core, switch distribution, lien WAN critique |
| Backup / DR | Job en échec critique, test DR, RTO/RPO compromis |
| Capacité | CPU/RAM/disque serveur ≥ 95% |
| Multi-domaine | Incidents simultanés sur plusieurs couches infra |

**Commandare-Infra ne gère PAS :**
- Postes utilisateurs / issues workstation → IT-AssistanTI_N3
- Incidents sécurité actifs (malware, breach) → IT-SecurityMaster en lead
- Diagnostic bas niveau poste → IT-AssistanTI_N3
- Clôture administrative → IT-Commandare-OPR
- Décisions architecturales → IT-Commandare-TECH

---

## Quand l'utiliser ?

- Un serveur ou une VM est down ou dégradé en production
- Le DC est inaccessible ou la réplication AD est en erreur
- Azure ou M365 déclenche une alerte de disponibilité ou de connectivité
- Un espace disque serveur atteint 85-95%
- Un backup critique est en échec depuis 24h+
- Plusieurs composants infra sont touchés simultanément

---

## Les commandes principales

### `/triage` — Analyser un incident infra

La commande principale. Tu fournis l'alerte ou le contexte, Commandare-Infra classe la sévérité, identifie le domaine et produit le plan d'action immédiat avec le(s) spécialiste(s) à mobiliser.

**Usage — serveur critique down :**
```
/triage
Billet #77701
Client : Industriel Benoit
Description : VM-SQL01 down depuis 08:17 — SQL Server inaccessible
Environnement : VMware ESXi 8.0
Impact : Application ERP inaccessible — 40 utilisateurs bloqués
Backup : Veeam — dernier backup réussi hier 23:00
Autres VMs : toutes opérationnelles
```

**Ce que tu obtiens (YAML) :**
```yaml
result:
  infra_domain: vm
  severity: P1
  decision:
    routing: IT-Commandare-Infra
    escalate_to: IT-Commandare-TECH  # impact architectural
    parallel_tracks: []
  actions_now:
    - Vérifier l'état de l'hôte ESXi — host accessible ?
    - Tenter redémarrage contrôlé VM-SQL01 depuis vCenter
    - Si hôte down → mobiliser plan DR avec IT-BackupDRMaster
  validation_plan:
    - SQL Server services actifs et acceptant les connexions
    - ERP accessible depuis un poste pilote
  rollback_trigger: "Si redémarrage échoue après 2 tentatives → basculer sur snapshot"
  sla: "< 5 min"
```

**Usage — espace disque critique :**
```
/triage
Alerte RMM — DC01 — Disque C: 96% utilisé
Client : Otto Inc
Serveur : DC01 — Windows Server 2022
```

**Ce que tu obtiens :**
- Sévérité P2 (≥ 95% = P2)
- Plan d'action : identifier fichiers volumineux, libérer espace, plan de remédiation
- Spécialiste mobilisé selon contexte

---

### `/escalade` — Générer le bloc CW de transfert

Quand l'incident sort du périmètre Infra ou qu'un spécialiste doit prendre le lead.

**Usage :**
```
/escalade IT-BackupDRMaster
Billet #77701 — Industriel Benoit
VM-SQL01 ne répond plus — hôte ESXi inaccessible
Activation plan DR requise — dernier backup confirmé hier 23:00
```

**Ce que tu obtiens :**
- Bloc CW structuré avec contexte complet pour IT-BackupDRMaster
- `next_actions` avec priorité et deadline

---

### `/teams` — Générer la notice Teams

Toute intervention infra est notifiée dans Teams dès que le type est connu.

**Usage :**
```
/teams
Billet : #77701
Client : Industriel Benoit
Type : VM SQL Server down — ERP inaccessible
Statut : Actif — investigation en cours
```

**Ce que tu obtiens :**
```
⚠️ Incident actif — Billet : #77701

VM SQL Server down chez Industriel Benoit
Tâche principale : Rétablissement VM et services ERP
Impact : 40 utilisateurs sans accès ERP
```

---

### `/flagup` — Passation structurée

Pour les incidents qui doivent être transmis au quart suivant ou à un autre agent.

**Usage :**
```
/flagup
Billet #77701 — Industriel Benoit
Statut : ESXi redémarré — VM SQL01 en cours de boot
En attente : validation SQL Server après boot (environ 15 min)
Prochaine action : Confirmer ERP accessible + validation plan post-fix
Agent suivant : IT-Commandare-Infra (quart de soir)
```

**Ce que tu obtiens :**
- Passation structurée avec état précis
- Prochaine étape et owner clairement définis
- Notice Teams de Flag Up

---

### `/close` — Clôture CW

Déclenche le menu de clôture.

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

> Important : Commandare-Infra attend ton choix avant de générer.

---

### `/status` — Résumé en cours

**Usage :**
```
/status
```

**Ce que tu obtiens :**
- Résumé : billet, client, domaine infra, sévérité
- Dernière action confirmée + prochaine étape
- Spécialistes mobilisés et leurs statuts

---

## Flux de travail recommandé

### Incident infra standard

```
1. Alerte reçue (RMM / monitoring / appel technicien)
        ↓
2. /triage [description complète]
   → Domaine + sévérité + plan d'action + spécialiste mobilisé
        ↓
3. Notifier Teams immédiatement (/teams)
        ↓
4. Mobiliser le(s) spécialiste(s) identifié(s)
        ↓
5. Coordination jusqu'à stabilisation
        ↓
6. Validation plan post-fix (≥ 2 checks pour P1/P2)
        ↓
7. /close → livrables CW
        ↓
8. Passer à IT-Commandare-OPR pour clôture formelle si P1/P2
```

### Incident multi-domaines (parallel_tracks)

```
1. /triage [incident avec plusieurs couches impactées]
   → Commandare-Infra identifie les pistes simultanées
        ↓
2. Parallel tracks : chaque spécialiste en parallèle
   Exemple : IT-BackupDRMaster (backup) + IT-NetworkMaster (réseau infra)
        ↓
3. Point de synchronisation toutes les 30 min ou selon SLA
        ↓
4. Commandare-TECH si impact architectural (P1)
```

### Runbook à risque élevé (DC, Hyper-V, SAN)

```
1. Toujours exiger AVANT toute action :
   - Maintenance window approuvée
   - 1 seul serveur à la fois pour les reboots
   - Post-check DC obligatoire après tout reboot DC
        ↓
2. JAMAIS de snapshot sur DC → Windows Server Backup uniquement
        ↓
3. Rollback_trigger défini avant de commencer
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| P1 infra → réponse < 5 min | Chaque minute coûte de l'argent et de la confiance client |
| 1 seul serveur à la fois pour les reboots | Éviter de mettre tous les DCs down simultanément |
| Snapshot sur DC interdit | Problèmes de réplication AD — utiliser Windows Server Backup |
| JAMAIS de credentials dans les livrables | Passportal uniquement — pas de mots de passe dans CW |
| Rollback_trigger obligatoire pour les remédiations à risque | Savoir QUAND reculer avant de commencer |
| Validation_plan ≥ 2 checks pour P1/P2 | Un seul check n'est jamais suffisant pour confirmer la stabilité |

---

## Questions fréquentes

**Q : Quelle différence entre Commandare-Infra et IT-SysAdmin ?**
Commandare-Infra coordonne les incidents infra et mobilise les spécialistes. IT-SysAdmin effectue l'administration technique des systèmes au quotidien. En incident, Commandare-Infra prend la coordination — IT-SysAdmin peut être mobilisé comme spécialiste.

**Q : Un incident réseau doit-il aller à NOC ou à Infra ?**
Si c'est un routeur core ou un switch distribution (réseau infra) → Commandare-Infra. Si c'est un lien WAN, VPN ou monitoring → Commandare-NOC. En cas de doute → Commandare-Infra avec routing vers Commandare-NOC si le diagnostic le confirme.

**Q : Que faire si le DC est down ET le réseau est impacté ?**
C'est un incident multi-domaines. `/triage` avec toutes les informations disponibles. Commandare-Infra établit les `parallel_tracks` : lui-même sur le DC + IT-NetworkMaster sur le réseau. Commandare-TECH si impact architectural P1.

**Q : La règle "1 seul serveur à la fois" s'applique même hors heures de travail ?**
Oui — surtout hors heures. Reboots multiples sur des DCs = risque de quorum AD compromis. Toujours séquentiels, toujours avec post-check de réplication entre chaque reboot.

**Q : Qui gère la clôture formelle après un incident infra P1 ?**
Commandare-Infra génère les livrables CW (Note + Discussion). IT-Commandare-OPR gère la clôture formelle avec le DoD complet et le postmortem P1/P2.

---

*GUIDE_UTILISATION — IT-Commandare-Infra v1.0 — MSP Intelligence AI — 2026-05-18*
