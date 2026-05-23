# BUNDLE_KP_Commandare-Infra_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** @IT-Commandare-Infra
**Usage :** Uploader en Knowledge dans le GPT IT-Commandare-Infra
**Contenu :** Triage infra, matrice sévérité, diagnostic serveurs/VM/DC/stockage/cloud, validation post-fix, rollback
**Mis à jour :** 2026-03-28

---

## 1. MATRICE SÉVÉRITÉ INFRA

| Sévérité | Critères | SLA réponse | Actions immédiates |
|---|---|---|---|
| **P1** | DC down, réseau core down, Azure tenant inaccessible, stockage corrompu, VM prod critique down | < 5 min | Isolation + mobilisation spécialiste immédiate |
| **P2** | Réplication AD dégradée, backup en échec > 24h, VM dégradée, disk ≥ 95%, WAN redondant down | < 15 min | Diagnostic + remédiation planifiée |
| **P3** | Snapshot échoué, service secondaire arrêté, disk ≥ 85%, lenteur VM isolée | < 1h | Investigation standard |
| **P4** | Alerte informationnelle, capacity planning, maintenance préventive | < 4h | Planifier |

---

## 2. ROUTING SPÉCIALISTES PAR DOMAINE

| Domaine | Agent principal | Agent secondaire | Contexte |
|---|---|---|---|
| Serveur physique / VM | @IT-Commandare-Infra | @IT-Commandare-TECH | Hyper-V, VMware, Proxmox, Vates XCP-ng |
| Cloud / Azure / M365 | @IT-CloudMaster | @IT-Commandare-Infra | Azure VM, VNet, Entra ID, Exchange Online |
| Domain Controller / AD | @IT-Commandare-Infra | @IT-NetworkMaster | Réplication, SYSVOL, FSMO, DNS AD |
| Réseau infra | @IT-NetworkMaster | @IT-Commandare-Infra | Routeur core, switch distribution, WAN |
| Stockage | @IT-Commandare-Infra | @IT-BackupDRMaster | SAN, NAS, iSCSI, disk critique |
| Backup / DR | @IT-BackupDRMaster | @IT-Commandare-Infra | Veeam, Datto, KeepIT, RPO/RTO |
| Multi-domaine | parallel_tracks | @IT-Commandare-TECH si P1 | Plusieurs couches impactées simultanément |

---

## 3. PROTOCOLE DIAGNOSTIC PAR TYPE

### Serveur Windows — inaccessible ou dégradé
```
1. PING + Test-NetConnection (port RDP 3389, WinRM 5985)
2. Vérifier dans l'hyperviseur : VM allumée ? CPU/RAM alloués ?
3. Console hyperviseur : écran bleu ? Prompt login ? Boot loop ?
4. Si accessible :
   - Event Viewer : System + Application (Critical/Error dernières 2h)
   - Services critiques : Get-Service | Where Status -ne Running
   - Disk : Get-PSDrive -PSProvider FileSystem
   - Uptime : (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
5. Si inaccessible : redémarrage contrôlé via hyperviseur (1 serveur à la fois, validation après)
```

### Domain Controller — réplication / SYSVOL / FSMO
```
1. repadmin /replsummary → état de réplication global
2. repadmin /showrepl → détail par partenaire
3. dcdiag /v → validation complète DC
4. nltest /dsgetdc:DOMAIN → DC trouvé par les clients ?
5. SYSVOL : net share → SYSVOL et NETLOGON partagés ?
6. FSMO : netdom query fsmo → rôles correctement distribués ?

⚠️ JAMAIS redémarrer un DC sans avoir vérifié :
   - Que ce n'est PAS le seul DC du domaine
   - Que les rôles FSMO sont transférés si nécessaire
   - Que la réplication est fonctionnelle avec au moins 1 autre DC
```

### Hyperviseur — Hyper-V / VMware / Proxmox / XCP-ng
```
Hyper-V :
  Get-VM | Select Name,State,Uptime,Status
  Get-VMHost | Select LogicalProcessorCount,MemoryCapacity
  Get-Volume | Where DriveLetter | Select DriveLetter,SizeRemaining

VMware vSphere :
  Vérifier vCenter → VM status, alarms, host connectivity
  esxcli system maintenanceMode get (si host en maintenance)
  esxcli storage filesystem list (datastores)

Proxmox / XCP-ng :
  SSH → pvesh get /cluster/status (Proxmox)
  SSH → xe vm-list power-state=running (XCP-ng)

⚠️ Ne JAMAIS forcer l'arrêt d'une VM sans snapshot préalable
```

### Stockage — SAN / NAS / iSCSI / disk critique
```
1. Espace disque : % libre sur chaque volume
2. I/O : latence disque anormale ? (> 20ms = investigation)
3. SMART status : disques physiques en alerte ?
4. iSCSI : connexion initiator → target active ?
5. RAID : dégradé ? Rebuild en cours ?
6. Si NAS (Synology/QNAP) : DSM/QTS → Storage Manager → état des pools
```

### Azure / M365 — incident cloud
```
1. https://status.azure.com → incident en cours sur la région ?
2. https://status.office365.com → service M365 impacté ?
3. Azure Portal → Service Health → incidents actifs
4. Si incident Microsoft : documenter, communiquer au client, attendre résolution
5. Si PAS d'incident Microsoft :
   - Azure VM : vérifier état provisioning, NSG, disk
   - Entra ID : vérifier sign-in logs, conditional access
   - Exchange Online : message trace, règles transport
   → Mobiliser @IT-CloudMaster
```

---

## 4. VALIDATION POST-FIX (obligatoire P1/P2)

### Checklist minimale
```
[ ] Service rétabli et accessible (test fonctionnel, pas juste ping)
[ ] Monitoring confirme le retour à la normale (pas d'alertes résiduelles)
[ ] Client confirme que le service fonctionne de son côté
[ ] Aucune erreur Critical/Error dans l'Event Viewer post-fix
[ ] Si DC : réplication fonctionnelle (repadmin /replsummary = 0 failures)
[ ] Si VM : snapshot pré-intervention supprimé (ne pas laisser traîner)
[ ] Si réseau : connectivité validée depuis un poste utilisateur
```

### Rollback — déclencheurs
```
REVENIR EN ARRIÈRE SI :
- Le service n'est pas rétabli dans les 30 min post-action
- De nouvelles erreurs apparaissent qui n'existaient pas avant l'intervention
- L'impact s'est élargi à d'autres services
- Le client signale un nouveau problème causé par le fix

MÉTHODE :
1. Restaurer depuis le snapshot pré-intervention
2. Notifier le client immédiatement
3. Escalader vers @IT-Commandare-TECH pour RCA
4. Ouvrir un ticket incident séparé pour le rollback
```

---

## 5. ANTI-PATTERNS INFRA

```
❌ Redémarrer un DC sans vérifier les rôles FSMO et la réplication
❌ Forcer l'arrêt d'une VM sans snapshot préalable
❌ Modifier une config réseau en prod sans backup de la config actuelle
❌ Traiter un incident Azure sans vérifier status.azure.com d'abord
❌ Laisser un snapshot d'intervention plus de 72h (performance dégradée)
❌ Redémarrer plusieurs serveurs en parallèle (1 à la fois, validation après chaque)
❌ Ignorer une alerte "disk 85%" — c'est un P3 qui devient P1 en quelques jours
❌ Appliquer un fix sans plan de rollback documenté
```

---

## 6. ESCALADES

| Situation | Vers | Quand |
|---|---|---|
| RCA profond requis | @IT-Commandare-TECH | Post-stabilisation P1/P2 |
| Incident sécurité | @IT-SecurityMaster | Dès suspicion (immédiat) |
| Clôture / comms client | @IT-Commandare-OPR | Après résolution |
| Urgence live P1 multi-sites | @IT-UrgenceMaster | Dès qualification |
| Alertes réseau/VPN/backup | @IT-Commandare-NOC | Si domaine NOC |
| Workstation / user | @IT-Assistant-N3 | Hors périmètre infra |

---

*BUNDLE_KP_Commandare-Infra_V1 — Version 1.0 — 2026-03-28*
