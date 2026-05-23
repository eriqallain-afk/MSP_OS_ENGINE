# Guide d'utilisation — @IT-VoIPMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-VoIPMaster ?

**IT-VoIPMaster est l'expert téléphonie IP et communications unifiées du MSP.**

Il couvre le diagnostic, la conception et l'optimisation des solutions VoIP : 3CX, Teams Phone, Cisco CUCM, RingCentral, Mitel. Il s'occupe aussi de l'infrastructure UC associée — trunks SIP, QoS, codecs, ports firewall voix.

| Domaine | Ce qu'il couvre |
|---|---|
| Diagnostic voix | Pas de tonalité, audio unidirectionnel, écho, coupures, MOS < 3.5 |
| Teams Phone | Direct Routing, SBC, licences Phone System, migration |
| 3CX | Extensions, trunks SIP, groupes d'appels, administration |
| Infrastructure UC | VLAN voix, QoS DSCP, ports firewall, jitter, latence |
| Conception | Architecture nouvelle solution VoIP, dimensionnement, plan migration |

> **Règle absolue : ne jamais couper un service téléphonie sans backup confirmé.** Tout redémarrage de PBX ou trunk SIP déclenche une alerte d'impact obligatoire.

---

## Quand l'utiliser ?

- Un utilisateur n'a pas de tonalité ou ne peut pas passer d'appels
- Les appels se coupent de manière aléatoire
- La qualité audio est dégradée (écho, coupures, voix robotique)
- Un seul côté entend l'autre (audio unidirectionnel)
- Le trunk SIP d'un site entier est down
- Teams Phone ne fonctionne pas pour un ou plusieurs utilisateurs
- Tu dois concevoir une nouvelle solution VoIP pour un client
- Tu veux un rapport de qualité mensuel pour un client VoIP

---

## Les commandes principales

### `/diag [symptôme]` — Diagnostic problème voix

La commande principale pour tout incident téléphonie.

**Usage :**
```
/diag pas de tonalité — 3CX — tous les postes du site Montréal
/diag audio unidirectionnel — on entend le client mais il ne nous entend pas
/diag coupures aléatoires sur appels sortants — trunk SIP VoIP.ms
/diag Teams Phone inaccessible — tous les utilisateurs depuis 09h00
```

**Ce que tu obtiens :**
- Classification du symptôme selon l'arbre de diagnostic
- Top 3 causes probables avec pourcentage de confiance
- Checklist de 5 tests ordonnés (du plus simple au plus complexe)
- Commandes de diagnostic prêtes à exécuter :

```powershell
# Test connectivité SIP et latence réseau
param([string]$Billet = "T[XXXXX]", [string]$SBC = "[SBC-HOST]")

# Test port SIP 5060
Test-NetConnection -ComputerName $SBC -Port 5060 | Select-Object -ExpandProperty TcpTestSucceeded

# Test latence (indicateur jitter)
$ping = Test-Connection $SBC -Count 10 -ErrorAction SilentlyContinue
$avg = ($ping | Measure-Object -Property ResponseTime -Average).Average
Write-Host ("Latence avg : {0}ms" -f [math]::Round($avg,0))
```

**Arbre de diagnostic rapide :**

| Symptôme | Vérifier en premier |
|---|---|
| Pas de tonalité / registration SIP échoue | Credentials SIP, NAT traversal, firewall UDP 5060 |
| Audio unidirectionnel | NAT/STUN config, RTP port range ouvert (10000-20000) |
| Écho ou délai excessif | Latence WAN > 150ms, jitter > 30ms, AEC désactivé |
| Coupures aléatoires | Keep-alive SIP, packet loss > 1%, QoS non configuré |
| Mauvaise qualité (MOS < 3.5) | Codec G.711 vs G.729, bande passante, QoS DSCP EF (46) |
| Teams Phone spécifique | Direct Routing config, SBC certifié, licences Phone System |

---

### `/design [contexte]` — Conception nouvelle solution VoIP

Pour concevoir une architecture VoIP complète pour un nouveau client ou site.

**Usage :**
```
/design nouvelle solution VoIP — 45 utilisateurs — 3 sites — remplacement Mitel vieillissant
/design migration Teams Phone — 20 utilisateurs — actuellement 3CX on-premise
/design nouveau site — 10 postes — succursale rejoignant l'infrastructure existante
```

**Ce que tu obtiens :**
- Architecture proposée avec choix de plateforme justifié
- Dimensionnement : trunks SIP, canaux simultanés, licences
- Prérequis réseau : VLAN voix, QoS DSCP, ports firewall, jitter buffer
- Plan de migration si existant à remplacer
- Risques identifiés avec mitigations

---

### `/qualite` — Analyse qualité appels

Pour analyser la qualité audio et produire un état des lieux MOS, jitter, packet loss.

**Usage :**
```
/qualite — trunk SIP VoIP.ms — client Metal-Pless — données du mois de mai
/qualite — Teams Phone — score MOS moyen signalé dégradé
```

**Ce que tu obtiens :**
- Score MOS actuel et comparaison seuil acceptable (MOS ≥ 3.5)
- Jitter mesuré vs seuil (< 30ms recommandé)
- Packet loss vs seuil (< 1% recommandé)
- Recommandations QoS si seuils dépassés

**Référence codecs :**

| Codec | Bande passante | Qualité MOS | Usage typique |
|---|---|---|---|
| G.711 | 87 kbps | ~4.4 | LAN, haute qualité |
| G.729 | 31 kbps | ~3.9 | WAN, bandwidth limité |
| Opus | Variable | ~4.5 | Teams Phone, WebRTC |

---

### `/close` — Clôture CW

Menu de clôture pour générer Note Interne, Discussion CW, Email client ou Notice Teams.

**Usage :**
```
/close
```
L'agent affiche le menu — il attend ta réponse avant de produire quoi que ce soit.

---

## Flux de travail

### Site entier sans téléphonie (P1)

```
1. Ticket P1 reçu — téléphonie site entier down
   ↓
2. /diag téléphonie site entier down — trunk SIP — [Client]
   ↓
3. Escalade @IT-Commandare-NOC immédiate (< 5 min)
   ↓
4. Tests dans l'ordre : trunk → SBC → firewall → réseau
   ↓
5. Correction + validation service restauré
   ↓
6. /close — Note Interne + Discussion + Email client
```

### Qualité audio dégradée (P2)

```
1. Utilisateurs signalent écho ou coupures
   ↓
2. /diag [symptôme précis]
   ↓
3. Exécuter tests de latence et jitter
   ↓
4. Si problème réseau/QoS → handoff @IT-NetworkMaster
5. Si Teams Phone → handoff @IT-CloudMaster (licences / Direct Routing)
   ↓
6. /qualite — mesurer MOS avant/après correctif
   ↓
7. /close
```

### Migration vers Teams Phone

```
1. /design migration Teams Phone — [N] utilisateurs — [plateforme actuelle]
   ↓
2. Vérifier : licences Phone System M365 (→ @IT-CloudMaster)
3. Vérifier : SBC certifié pour Direct Routing
4. Vérifier : VLAN voix + QoS DSCP EF (46) configuré
   ↓
5. Planifier fenêtre de migration avec client
   ↓
6. /close — documentation CW
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| JAMAIS couper un service téléphonie sans backup | Interruption service = impact client immédiat |
| Toujours valider QoS avant de toucher trunk SIP | Modification sans QoS peut dégrader tous les appels |
| `⚠️ Impact` obligatoire avant redémarrage PBX | Transparence + validation avant action à risque |
| `[À CONFIRMER]` si info non vérifiable | Zéro invention sur config SIP ou trunk |
| VLAN voix séparé du LAN data | Isolation = qualité audio prévisible |
| DSCP EF (46) pour RTP, CS3 (24) pour SIP | Standards QoS voix universels |

**Ports à toujours vérifier sur le firewall :**
- UDP/TCP 5060 — SIP signaling
- UDP/TCP 5061 — SIP over TLS
- UDP 10000-20000 — RTP media (typique)
- TCP 5061 — Teams Direct Routing (TLS)

---

## Questions fréquentes

**Q : Qu'est-ce que le MOS et quel est le seuil acceptable ?**
MOS (Mean Opinion Score) mesure la qualité audio perçue sur une échelle de 1 à 5. Un MOS ≥ 3.5 est acceptable pour des appels professionnels. En dessous, les utilisateurs se plaignent. G.711 vise 4.4, G.729 vise 3.9.

**Q : C'est quoi l'audio unidirectionnel (one-way audio) ?**
Une des deux parties ne peut pas entendre l'autre. Cause principale : problème de NAT/STUN — les paquets RTP ne trouvent pas le chemin retour. Vérifier la configuration STUN sur le PBX et l'ouverture des ports RTP sur le firewall.

**Q : Quelle différence entre Teams Phone et 3CX ?**
Teams Phone est une solution cloud Microsoft intégrée à M365 — nécessite licence Phone System et un SBC certifié pour Direct Routing. 3CX est un PBX on-premise ou cloud indépendant de Microsoft — plus flexible, moins lié à l'écosystème M365.

**Q : Quand escalader vers IT-NetworkMaster ?**
Dès qu'un problème de QoS, VLAN voix ou règles firewall voix est identifié. IT-VoIPMaster diagnostique le problème voix — IT-NetworkMaster configure le réseau pour le résoudre.

**Q : Quand escalader vers IT-CloudMaster ?**
Pour tout ce qui touche Teams Phone côté administration M365 : licences Phone System, configuration Direct Routing dans le tenant, politiques Teams admin.

---

*GUIDE_UTILISATION — IT-VoIPMaster v1.0 — MSP Intelligence AI — 2026-05-18*
