# BUNDLE_KP_UrgenceMaster_V2
**Agent :** @IT-UrgenceMaster
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** Protocole panne HQ, panne réseau/WAN, hyperviseur HS, RAID dégradé, multi-sites, téléphonie, notifications 3 couches, RCA 5 Pourquoi, templates CW, escalades.

---

## SECTION 1 — COMPORTEMENT FONDAMENTAL (hérité V1)

```
RÈGLES D'OR — URGENCE MSP :

1. ÉVALUER avant d'agir — 2 minutes de diagnostic sauvent 2 heures
2. NOTIFIER en parallèle des actions — ne jamais travailler en silence
3. DOCUMENTER en temps réel — chaque action dans CW avec HH:MM
4. UN SEUL chef d'orchestre à la fois — éviter les conflits d'actions
5. SNAPSHOTS avant toute intervention si le système fonctionne encore
6. COMMUNICATION client toutes les 30 min minimum en P1
7. ESCALADE si pas de résolution dans le délai cible — pas de héros solitaires
```

---

## SECTION 2 — FORMAT NOTICES TEAMS STANDARD NOC (hérité V1)

### Notice alerte P1
```
🔴 ALERTE P1 — [TITRE INCIDENT]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client  : [NOM CLIENT]
Billet  : #[XXXXXX]
Statut  : 🔴 En cours d'investigation
Début   : [YYYY-MM-DD HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Impact : [Description impact — sans détails techniques]
Tech   : @[NOM TECH] — sur le dossier

Prochain statut : [HH:MM] (dans 30 min max)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Notice mise à jour P1
```
⚠️ MISE À JOUR P1 — [TITRE INCIDENT] — [HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client  : [NOM CLIENT] | Billet : #[XXXXXX]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Situation : [Mise à jour client-safe]
Actions   : [Ce qui est en cours]
ETA       : [Estimation résolution ou prochain point]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Chef d'équipe] | [HH:MM]
```

### Notice résolution P1
```
✅ RÉSOLU — [TITRE INCIDENT]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client      : [NOM CLIENT]
Billet      : #[XXXXXX]
Résolu      : [YYYY-MM-DD HH:MM]
Durée totale: [HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Cause       : [Résumé client-safe]
Résolution  : [Action principale — sans détails techniques]
Suivi       : [Post-mortem prévu / Actions préventives planifiées]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Chef d'équipe] | [HH:MM]
```

---

## SECTION 3 — PROTOCOLE PANNE HQ (hérité V1 + enrichi)

### Phase 1 : Évaluation initiale (0-5 min)
```
ÉVALUATION RAPIDE — PANNE HQ :
[ ] Confirmer la portée (1 user / department / site complet)
[ ] Vérifier depuis RMM : serveurs up ? réseau up ? Internet up ?
[ ] Ping DC principal : Test-NetConnection [NOM_DC] -Port 389
[ ] Ping passerelle Internet : Test-NetConnection 8.8.8.8
[ ] Vérifier Service Health M365 : admin.microsoft.com → Service Health
[ ] Contacter le client pour impact réel (combien d'usagers, quels services)

CLASSIFICATION RAPIDE :
- Internet seul → Problème WAN/ISP → Section 4
- Réseau interne → Problème switch/routeur/VLAN → IT-NetworkMaster
- Serveurs inaccessibles → Section 3 Phase 2
- M365 indisponible → Vérifier Service Health Microsoft d'abord
```

### Phase 2 : Diagnostic serveurs (5-20 min)
```powershell
# Depuis le serveur de gestion ou RMM — ping multi-hôtes
$servers = @("[NOM_DC1]","[NOM_DC2]","[NOM_SERVEUR_FICHIERS]","[NOM_SERVEUR_APP]")
foreach ($s in $servers) {
    $result = Test-Connection $s -Count 2 -Quiet
    $status = if ($result) { "✅ UP" } else { "❌ DOWN" }
    Write-Host "$status — $s"
}

# Services DC
Get-Service -ComputerName [NOM_DC1] NTDS,DNS,Kdc,Netlogon -ErrorAction SilentlyContinue | 
    Select-Object Name, Status, @{N='Host';E={'[NOM_DC1]'}}

# Vérifier Hyper-V hôte
Get-VM -ComputerName [NOM_HYPERVISEUR] | Select-Object Name, State, CPUUsage, MemoryAssigned
```

### Phase 3 : Résolution et validation
```
CHECKLIST GO/NO-GO PAR SERVEUR :
✅ GO si :
- Services critiques démarrés
- Event Log : pas d'erreur critique récente
- Ping/TCP check OK
- Application accessible (test fonctionnel)
- Backup récent confirmé

❌ NO-GO si :
- SMART failure ou erreur disque physique → Escalade INFRA immédiate
- Corruption base de données → IT-SysAdmin + backup
- Hardware failure → escalade matérielle + activation DR
- Ransomware détecté → IT-SecurityMaster + isolation

CRITÈRES NO-GO — ACTIONS IMMÉDIATES :
- DC non démarrable → Vérifier Hyper-V snapshot + Datto BCDR
- RAID dégradé → NE PAS redémarrer le serveur sans analyse → Section 6
- Processus de chiffrement actif → Isolation réseau immédiate + IT-SecurityMaster
```

---

## SECTION 4 — PANNE RÉSEAU / WAN

### Diagnostic réseau/WAN complet
```powershell
# ===== DIAGNOSTIC RÉSEAU WAN =====
Write-Host "=== DIAGNOSTIC RÉSEAU ===" -ForegroundColor Cyan

# 1. Connectivité locale
Write-Host "`n[1] Passerelle par défaut :"
$gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0").NextHop | Select-Object -First 1
Test-NetConnection $gw | Select-Object ComputerName, PingSucceeded, PingReplyDetails

# 2. DNS
Write-Host "`n[2] Résolution DNS :"
Resolve-DnsName "google.com" -ErrorAction SilentlyContinue | Select-Object Name, IPAddress

# 3. Internet
Write-Host "`n[3] Internet (8.8.8.8) :"
Test-NetConnection "8.8.8.8" | Select-Object ComputerName, PingSucceeded

# 4. M365
Write-Host "`n[4] M365 (outlook.office365.com) :"
Test-NetConnection "outlook.office365.com" -Port 443 | Select-Object ComputerName, TcpTestSucceeded

# 5. Traceroute vers Internet
Write-Host "`n[5] Traceroute :"
tracert -d -h 15 8.8.8.8

# 6. Interfaces réseau
Write-Host "`n[6] Interfaces actives :"
Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object Name, InterfaceDescription, LinkSpeed, MacAddress
```

### Procédure panne WAN (Internet down)
```
PANNE WAN — ÉTAPES :
1. Vérifier si le problème est ISP (ping passerelle ISP) ou routeur interne
   → Ping vers IP passerelle ISP (généralement fourni par ISP)
   → Si passerelle répond mais Internet non → problème ISP
   → Si passerelle ne répond pas → problème routeur/firewall

2. Vérifier le routeur/firewall :
   → Interface web admin du firewall accessible ?
   → Logs firewall : erreurs WAN ?
   → Interface WAN up/down ?
   → Connexion PPPoE/DHCP : renégocier si applicable

3. Si problème ISP confirmé :
   → Appeler l'ISP avec le numéro de compte client (Passportal)
   → Demander le numéro de dossier ISP
   → ETA de résolution
   → Documenter dans CW

4. Mesures de contournement possibles :
   → Failover 4G/5G si équipé (Meraki, WatchGuard)
   → Hotspot temporaire pour usagers critiques
   → Activer failover ISP secondaire si contracté
```

---

## SECTION 5 — HYPERVISEUR HS (HYPER-V / VMWARE)

### Évaluation hyperviseur défaillant
```
DÉCISION GO/NO-GO HYPERVISEUR :

GO — Tenter redémarrage hyperviseur si :
✅ Les VMs sont sur stockage externe (SAN/NAS) — données sécurisées
✅ Les VMs ont un backup récent (< 24h)
✅ Aucun signe de défaillance matérielle (disque, RAM)
✅ Le redémarrage est approuvé par le client

NO-GO — NE PAS redémarrer si :
❌ Erreur disque détectée (SMART, Event ID 7/11)
❌ Panique / BSOD répété à l'arrêt → vérifier hardware d'abord
❌ Storage RAID dégradé → voir Section 6
❌ Suspicion ransomware → isolation + IT-SecurityMaster

PROCÉDURE REDÉMARRAGE HYPER-V CONTRÔLÉ :
1. Sauvegarder l'état (si hyperviseur répond encore)
   → Checkpoint-VM sur toutes les VMs critiques
2. Arrêt ordonné des VMs (du moins critique au plus critique)
   → Stop-VM -Name "[VM_APP]" -Force
   → Stop-VM -Name "[VM_DC]" -Force (DC en dernier)
3. Redémarrer l'hôte
4. Redémarrer les VMs dans l'ordre (DC en premier)
5. Valider chaque VM avant de démarrer la suivante
```

### Migration VMs d'urgence
```powershell
# Live Migration si cluster disponible
Move-VM -Name "[NOM_VM]" -DestinationHost "[HOST_DESTINATION]" -Verbose

# Migration stockage seulement (hôte différent, même storage)
Move-VMStorage -VMName "[NOM_VM]" -DestinationStoragePath "[CHEMIN_DEST]"

# Export VM vers stockage externe (si hôte répond encore)
Export-VM -Name "[NOM_VM]" -Path "[CHEMIN_EXPORT]" -AsJob
# Surveiller : Get-Job | Select-Object Name, State, ChildJobs

# Import sur hôte de remplacement
Import-VM -Path "[CHEMIN_EXPORT]\[NOM_VM]\Virtual Machines\[GUID].vmcx" -Copy -GenerateNewId -VhdDestinationPath "[CHEMIN_VHD]"

# Si Hyper-V inaccessible → activer Datto Instant Virtualization
# portal.datto.com → Device → Advanced Restore → Virtualize
```

---

## SECTION 6 — RAID DÉGRADÉ / DISQUE HS

### Évaluation RAID dégradé
```
⚠️ RÈGLE CRITIQUE : Un RAID dégradé est une urgence SILENCIEUSE
Le serveur peut sembler normal mais TOUT autre échec = perte de données totale

ÉTAPES IMMÉDIATES — RAID DÉGRADÉ :

1. ÉVALUER le niveau de dégradation
   → RAID 1 (1 disque) : 1 disque manquant → 0 redondance restante → CRITIQUE
   → RAID 5 (1 disque) : 1 disque manquant → 0 redondance restante → CRITIQUE
   → RAID 6 (2 disques) : 1 disque manquant → redondance 1 → URGENCE
   → RAID 10 : vérifier quelle paire est affectée

2. NE PAS FAIRE sans backup vérifié :
   ❌ Ne pas hot-swap en précipitation sans confirmer le modèle exact
   ❌ Ne pas initialiser un nouveau disque si rebuild automatique déjà en cours
   ❌ Ne pas redémarrer le serveur si rebuild en cours (interruption = perte)

3. BACKUP D'ABORD si encore possible :
   → Déclencher un backup Veeam immédiat de toutes les VMs
   → Vérifier que le backup complète avant toute intervention matérielle

4. IDENTIFIER le disque défaillant
   → Via contrôleur RAID (iDRAC, ILO, console RAID)
   → Event Log Windows : Source "disk" ou "storport" ou "RAID"
   → Get-WmiObject Win32_DiskDrive | Select-Object Model, Status, Index
```

```powershell
# Événements disque critiques
Get-WinEvent -LogName System -FilterHashtable @{LogName='System'; ProviderName='disk','storahci','stornvme','storport'} -MaxEvents 50 |
    Where-Object { $_.Level -le 2 } |
    Select-Object TimeCreated, Id, Message | Format-Table -Wrap

# SMART via WMI
Get-WmiObject -Class Win32_DiskDrive | Select-Object Model, Index, Size, Status, InterfaceType
# Status "Pred Fail" → remplacement IMMÉDIAT
```

### Communication client — RAID dégradé
```
Template Notice Teams — RAID dégradé :

⚠️ ALERTE MATÉRIELLE — [CLIENT]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client  : [NOM CLIENT]
Billet  : #[XXXXXX]
Urgence : ⚠️ Composant matériel défaillant
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Un composant de stockage sur [SERVEUR] requiert une attention immédiate.
Le serveur fonctionne actuellement, mais la redondance est réduite.

Action requise : Remplacement matériel planifié d'urgence
Backup : ✅ En cours / ✅ Vérifié
Risque actuel : [Faible/Modéré] — service en ligne

Nous vous contacterons sous 1h avec un plan d'action.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Chef d'équipe] | [Date HH:MM]
```

---

## SECTION 7 — MULTI-SITES DOWN

### Coordination multi-sites
```
PROTOCOLE MULTI-SITES DOWN :

ÉVALUATION (0-5 min) :
[ ] Combien de sites sont affectés ?
[ ] Est-ce un point commun ? (même ISP, même MPLS, même firewall central)
[ ] Les sites ont-ils un lien en commun ? (MPLS, SD-WAN, VPN hub)
[ ] M365/Cloud fonctionne-t-il ? (détermine si c'est réseau ou serveurs)

PRIORISATION DES SITES :
→ Site principal (HQ) : priorité absolue
→ Sites avec production critique : P1
→ Sites bureaux administratifs : P2
→ Sites remote/petits bureaux : P3

GESTION DE L'ÉQUIPE :
→ Assigner un technicien PAR SITE si possible
→ Canal Teams dédié pour coordination multi-sites
→ Chef d'orchestre unique pour décisions

COMMUNICATION :
→ Notice Teams une seule fois pour TOUS les sites
→ Mise à jour toutes les 30 min
→ Contact client principal informé immédiatement
→ NE PAS noyer le client de messages individuels par site
```

---

## SECTION 8 — PANNE TÉLÉPHONIE (SIP / TEAMS PHONE)

### Diagnostic téléphonie SIP
```powershell
# Test connectivité SIP trunk
Test-NetConnection [IP_SBC_OU_TRUNK] -Port 5060
Test-NetConnection [IP_SBC_OU_TRUNK] -Port 5061  # TLS SIP
Test-NetConnection [IP_SBC_OU_TRUNK] -Port 443   # Teams Direct Routing

# Qualité réseau pour voix (latence, jitter)
ping -n 50 [IP_SBC_OU_TRUNK]
# ⚠️ Latence > 150ms ou jitter > 30ms → problème réseau pour voix

# Vérifier QoS policies (DSCP pour voix)
Get-NetQosPolicy | Where-Object { $_.AppPathNameMatchCondition -like "*Teams*" -or $_.DSCPAction -gt 0 }
```

### Procédure panne Teams Phone
```
PANNE TEAMS PHONE — ÉTAPES :
1. Vérifier Service Health Teams : admin.teams.microsoft.com → Service Health
   → Si Microsoft indique un incident → documenter et attendre

2. Vérifier les licences Teams Phone des utilisateurs affectés
   → admin.microsoft.com → Users → Licenses → Teams Phone Standard

3. Vérifier les numéros de téléphone assignés
   → Teams Admin Center → Voice → Phone numbers → filtrer par utilisateur

4. Direct Routing (SBC) si configuré :
   → Teams Admin Center → Voice → Direct Routing → vérifier health SBC
   → Vérifier connexion TLS entre SBC et Microsoft (port 443)

5. Mesures de contournement :
   → Rerouter les appels vers Teams Chat/vidéo
   → Activer renvoi vers cellulaire si disponible
   → Informer les utilisateurs de l'alternative de contact

6. Escalade :
   → Fournisseur SIP trunk si direct routing
   → Microsoft Support si service Teams Phone global
```

---

## SECTION 9 — TEMPLATES CW URGENCE (hérité V1)

### Note Interne CW — Incident P1
```
Prise en connaissance de la demande et consultation de la documentation du client.

## INCIDENT P1 — [TYPE] — [NOM CLIENT]
Billet : #[XXXXXX] | Priorité : P1 | Début : [YYYY-MM-DD HH:MM]
Impact : [Description technique — nombre d'usagers/services]

## CHRONOLOGIE
- [HH:MM] Alerte reçue via [RMM / Client / Monitoring]
- [HH:MM] Première évaluation : [Observation]
- [HH:MM] Actions de confinement/stabilisation
- [HH:MM] [Action suivante]
- [HH:MM] Service rétabli / Escalade vers [ÉQUIPE]

## DIAGNOSTIC
Symptôme : [Description technique]
Cause probable : [Hypothèse]
Systèmes affectés : [Liste]

## ACTIONS EFFECTUÉES
- [Action 1 — résultat]
- [Action 2 — résultat]
- [Action 3 — résultat]

## ÉTAT ACTUEL
[Résolu / En cours / Escaladé → Détails]

## SUIVI
- Post-mortem prévu : [Date/heure]
- Actions préventives : [Liste]
```

### Discussion CW — Urgence (client-safe)
```
Prise en connaissance de la demande et consultation de la documentation du client.

### SITUATION
Interruption de service détectée affectant [description fonctionnelle — sans détails techniques].

### ACTIONS IMMÉDIATES
- Prise en charge immédiate dès détection de l'alerte
- Évaluation de la situation et mise en place de mesures de stabilisation
- Coordination avec l'équipe technique spécialisée
- [Action corrective principale en langage client]
- Validation complète du rétablissement du service

### RÉSULTAT
Service [NOM] : ✅ Pleinement rétabli depuis [HH:MM]
Durée d'interruption : [HH:MM]

Des mesures préventives ont été initiées pour éviter la récurrence.
```

---

## SECTION 10 — ESCALADES RAPIDES (hérité V1 + enrichi)

| Situation | Destination | Délai | Action requise |
|---|---|---|---|
| P1 automatique (DC down, réseau site, ransomware) | IT-Commandare-NOC | Immédiat | Notice Teams + billet P1 |
| Hyperviseur HS — VMs down | IT-SysAdmin + Chef d'équipe | Immédiat | GO/NO-GO redémarrage |
| RAID dégradé / disque défaillant | IT-BackupDRMaster + INFRA | Dans l'heure | Backup immédiat + évaluation |
| Ransomware / chiffrement actif | IT-SecurityMaster + SOC | Immédiat | Isolation réseau |
| Multi-sites down (3+ sites) | Chef d'équipe + Management | Immédiat | War room activation |
| DR activé | IT-BackupDRMaster + Client | Dans 30 min | Communication client |
| ISP down > 1h sans ETA | Chef d'équipe + Client | Dans 30 min | Plan contournement |
| Incendie / sinistre physique | Management + Client + Assurances | Immédiat | DR + sécurité physique |
| P2 → P1 dégradation | Chef d'équipe | Dans 30 min | Réévaluation et communication |

---

## SECTION 11 — RCA POST-URGENCE (5 POURQUOI)

### Template RCA — 5 Pourquoi
```
ANALYSE CAUSE RACINE (RCA) — 5 POURQUOI
════════════════════════════════════════
Incident : [Titre]
Date     : [YYYY-MM-DD]
Billet   : #[XXXXXX]
Rédigé   : [NOM] | Approuvé : [À CONFIRMER]

DESCRIPTION DU PROBLÈME
[1-2 phrases factuelles décrivant ce qui s'est passé]

ANALYSE 5 POURQUOI
Problème    : [Énoncé du problème]
Pourquoi 1  : [Première cause]
Pourquoi 2  : [Cause de la cause 1]
Pourquoi 3  : [Cause de la cause 2]
Pourquoi 4  : [Cause de la cause 3]
Pourquoi 5  : [Cause racine fondamentale]

CAUSE RACINE IDENTIFIÉE
[Énoncé de la cause racine]

ACTIONS CORRECTIVES
| # | Action | Responsable | Échéance | Statut |
|---|---|---|---|---|
| 1 | [Action corrective] | [NOM] | [Date] | [ ] |
| 2 | [Action préventive] | [NOM] | [Date] | [ ] |
| 3 | [Amélioration process] | [NOM] | [Date] | [ ] |

MESURES DE VÉRIFICATION
→ Comment vérifier que les actions ont l'effet souhaité ?
→ [KPI ou métrique à surveiller]
════════════════════════════════════════
```

---

## SECTION 12 — NOTIFICATIONS 3 COUCHES

### Notification NOC → Chef d'équipe → Client
```
COUCHE 1 — NOC INTERNE (immédiat, via Teams canal NOC)
Contenu : Alerte technique complète (serveurs, services, actions)
Format : Notice Teams Alerte P1 (Section 2)
Délai : Dès détection

COUCHE 2 — CHEF D'ÉQUIPE (dans 5 min, si P1)
Template :
"🔴 P1 [CLIENT] — [RÉSUMÉ COURT]
Tech : @[NOM] — sur le dossier depuis [HH:MM]
Impact : [Description]
Actions : [En cours]
Besoin de support ? [Oui/Non]"

COUCHE 3 — CLIENT (dans 15 min, si impact visible)
→ Email (template Section 10) + Notice Teams client (si canal commun)
Contenu : Impact fonctionnel uniquement — pas de détails techniques
Fréquence : Toutes les 30 min jusqu'à résolution
```

---

## SECTION 13 — CHECKLIST POST-URGENCE (hérité V1)

```
CHECKLIST POST-URGENCE P1 :
[ ] Tous les services confirmés opérationnels
[ ] Event Logs vérifiés — pas d'erreurs critiques résiduelles
[ ] Monitoring vert sur tous les systèmes affectés
[ ] Snapshot(s) créés avant intervention → supprimés ou conservés ?
[ ] Mode maintenance RMM désactivé
[ ] CW Note Interne complète avec chronologie
[ ] CW Discussion client-safe rédigée
[ ] Email client post-résolution envoyé (si P1/P2)
[ ] Chef d'équipe informé de la résolution
[ ] RCA planifié si incident > 2h ou récurrent
[ ] Documentation Hudu mise à jour si découverte pertinente
[ ] KB à créer pour la prochaine fois ?
```

---

## SECTION 14 — DIAGNOSTICS RAPIDES (hérité V1 + enrichi)

### Réseau down
```powershell
# Réseau interne
Test-NetConnection [NOM_DC1] -Port 389      # AD/LDAP
Test-NetConnection [NOM_SERVEUR_FICHIERS] -Port 445  # SMB
ipconfig /all                                # Adresse IP assignée ?
arp -a                                       # Cache ARP (passerelle accessible ?)
route print                                  # Table de routage
netstat -rn | findstr "0.0.0.0"            # Routes par défaut
```

### Serveur critique
```powershell
# Santé rapide serveur
Get-Service NTDS,DNS,Kdc,Netlogon -ErrorAction SilentlyContinue | Select-Object Name, Status
Get-EventLog System -EntryType Error -Newest 20 | Select-Object TimeGenerated, Source, Message
Get-PSDrive FileSystem | Select-Object Name, Used, Free
$mem = Get-CimInstance Win32_OperatingSystem
"RAM libre: $([math]::Round($mem.FreePhysicalMemory/1MB,1)) GB"
```

### DC down
```powershell
# Diagnostics DC
dcdiag /test:replications /test:services /test:fsmo
repadmin /showrepl
repadmin /replsummary
netdom query fsmo
w32tm /query /status   # Synchronisation NTP
Get-Service NTDS,DNS,Kdc,Netlogon | Select-Object Name, Status
```

---

*BUNDLE_KP_UrgenceMaster_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
