# Guide d'utilisation — @IT-NetworkMaster (v1.0)
> **Pour :** Techniciens N2/N3 MSP — Réseau & Sécurité périmétrique
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-NetworkMaster ?

**IT-NetworkMaster est l'expert réseau du MSP — firewall, VPN, VLAN, WiFi, LAN/WAN.**

Il couvre tous les équipements réseau présents dans les environnements clients MSP : WatchGuard, Fortinet, SonicWall, Meraki, UniFi, MikroTik. Il diagnostique les pannes, guide les configurations et produit les livrables CW.

| Besoin | Ce que fait IT-NetworkMaster |
|---|---|
| VPN utilisateur en panne | Diagnostic SSL/IPSec/L2TP — cause probable + correctif |
| Firewall à configurer | Règles, NAT, QoS — avec avertissement impact avant toute modification |
| Site entier offline | Diagnostic LAN/WAN en couches — du câble au routage |
| VLAN à créer ou modifier | Configuration segmentation réseau guidée |
| Firmware équipement réseau | Backup config obligatoire avant toute mise à jour |

> Zéro modification firewall sans billet CW approuvé.
> Zéro règle "Any → Any Accept" — même temporairement.
> Backup de la configuration obligatoire avant toute mise à jour firmware.

---

## Quand l'utiliser ?

- Un utilisateur ne peut pas se connecter au VPN (SSL, IPSec, L2TP)
- Un tunnel site-à-site est down
- Un site client est partiellement ou totalement offline
- Tu dois configurer ou modifier une règle firewall
- Tu dois créer ou modifier un VLAN
- Un AP WiFi est offline ou les performances WiFi sont dégradées
- Tu dois mettre à jour le firmware d'un équipement réseau (WatchGuard, Fortinet, MikroTik, etc.)
- Tu veux diagnostiquer un problème de latence ou de débit LAN/WAN

---

## Les commandes principales

### `/diag [symptôme]` — Diagnostic réseau

Point d'entrée pour tout incident réseau. L'agent applique le diagnostic en couches OSI.

**Usage :**
```
/diag VPN SSL utilisateur — connexion échoue depuis ce matin
Client : Otto Mfg
Équipement : WatchGuard M370
Symptôme : Erreur "Unable to connect" côté client
```

```
/diag Site entier offline — Client : DEF Corp — Firewall Fortinet
```

**Ce que tu obtiens :**
- Mode détecté : DIAGNOSTIC_RESEAU / WATCHGUARD / FORTINET / etc.
- Sévérité P1-P4
- Commandes de diagnostic lecture seule à exécuter en premier

**Commandes baseline Windows (générées automatiquement) :**
```powershell
# Diagnostic réseau de base — lecture seule
ipconfig /all
ping -n 4 8.8.8.8
tracert -d [GATEWAY]
nslookup [domaine] [DNS_INTERNE]
Test-NetConnection -ComputerName [SERVEUR] -Port 443
Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
Get-NetRoute | Where-Object {$_.DestinationPrefix -eq '0.0.0.0/0'}
netstat -ano | findstr ESTABLISHED
```

**Commandes Linux / SSH :**
```bash
ip addr show && ip route show
ping -c 4 8.8.8.8 && traceroute [cible]
ss -tunapl | head -20
```

---

### `/firewall [marque]` — Diagnostic et configuration firewall

Pour intervenir sur un équipement firewall spécifique.

**Usage :**
```
/firewall watchguard
Tunnel BOVPN down vers site secondaire
Client : Otto Mfg
```

```
/firewall fortinet
VPN SSL — utilisateurs ne peuvent plus se connecter depuis 30 min
```

**WatchGuard — commandes clés :**
```
Dashboard → VPN → Statistics → état tunnels
Test-NetConnection [GATEWAY_WG] -Port 443
# BOVPN : vérifier même clé partagée des deux côtés (Passportal)
# SSL VPN : vérifier utilisateur dans le bon groupe AD → Authentication → Users and Groups
# Certificat SSL : System → Certificates → date expiration
```

**Fortinet — commandes SSH :**
```bash
get system status
get system performance status
get vpn ipsec tunnel summary
get vpn ssl monitor
diagnose vpn tunnel up [NOM_TUNNEL]
# Sniffer (< 5 min maximum en production)
diagnose sniffer packet [IFACE] "host [IP_CIBLE]" 4 10
# Vérifier licences FortiGuard (alerter si < 30 jours)
get system fortiguard-service status
```

**SonicWall — navigation console :**
```
VPN SSL → Network → SSL VPN → User Status (sessions actives)
Tunnel IPSec down → VPN → Settings → Disable → Enable
Backup avant MàJ → System → Settings → Export Settings (.exp)
```

**Meraki — vérifications cloud :**
```
Device offline → vérifier alimentation + réseau + HTTPS sortant vers *.meraki.com + UDP 7351
Auto VPN down → si les 2 côtés sont Online → se rétablit automatiquement
Licences → Organization → License Info (alerter si < 60 jours)
```

> Avant tout mise à jour firmware : backup de la configuration obligatoire.
> Packet sniffer : jamais plus de 5 minutes en production.

---

### `/vpn [symptôme]` — Diagnostic VPN utilisateur

Pour un utilisateur qui ne peut pas se connecter au VPN.

**Usage :**
```
/vpn
Utilisateur : Jean Dupont
Erreur : Cannot connect — Network error
Type VPN : WatchGuard Mobile VPN with SSL
Poste : Windows 11
```

**Flux de diagnostic (généré automatiquement) :**

**Étape 1 — Internet de base :**
```powershell
Test-NetConnection 8.8.8.8
```

**Étape 2 — Compte AD verrouillé :**
```powershell
Get-ADUser [identifiant] -Properties LockedOut, PasswordExpired | Select-Object Name,LockedOut,PasswordExpired
```

**Étape 3 — Port VPN accessible :**
```powershell
# WatchGuard SSL → port 443
Test-NetConnection [GATEWAY_WG] -Port 443

# Meraki L2TP → UDP 500 + 4500
Test-NetConnection [GATEWAY_MERAKI] -Port 500
```

**Correctif Meraki L2TP — erreur 789 (registre) :**
```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent" `
    -Name "AssumeUDPEncapsulationContextOnSendRule" -Value 2 -Type DWord
# Redémarrage du poste requis après cette modification
```

---

### `/vlan [contexte]` — Configuration VLAN

Pour créer ou modifier une segmentation réseau.

**Usage :**
```
/vlan
Créer VLAN 30 — Invités WiFi — Client : DEF Corp
Équipement : UniFi USG + Switch US-24
Subnet souhaité : 192.168.30.0/24
```

**Ce que tu obtiens :**
- Configuration step-by-step pour l'équipement concerné
- Règles firewall inter-VLAN recommandées (isolation invités)
- Avertissement `⚠️ Impact :` avant chaque modification en production
- Commandes de validation post-configuration

**UniFi — AP offline (SSH) :**
```bash
ssh ubnt@[IP_AP]
set-inform http://[IP_CONTROLEUR]:8080/inform
cat /var/log/messages | tail -50
```

---

### `/qos [contexte]` — Optimisation QoS

Pour les problèmes de qualité VoIP, vidéoconférence ou priorisation des flux.

**Usage :**
```
/qos
Client : GHI Corp — problème qualité appels Teams
Firewall : WatchGuard M270
Connexion WAN : Fibre 100 Mbps symétrique
```

**Ce que tu obtiens :**
- Règles QoS recommandées pour prioriser la voix/vidéo
- DSCP marking recommandé (EF pour voix, AF41 pour vidéo)
- Si problème persistant → escalade @IT-VoIPMaster

---

### `/close` — Clôture CW

Menu de clôture après intervention réseau. Attend ton choix avant de générer.

**Usage :**
```
/close
```

**Ce que tu obtiens :**
```
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout
```

**Exemple CW Note Interne (choix 1) :**
```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #56789 — Otto Mfg — VPN SSL WatchGuard — Tunnel BOVPN down vers site B
Début : 14h00 | Fin : 14h45 | Durée : 45 min

14h00 — Vérification port 443 accessible depuis Internet → OK
14h10 — Audit logs Traffic Monitor WatchGuard → IKE Phase 1 timeout
14h20 — Identifié clé partagée modifiée côté site B (Passportal → version précédente)
14h30 — Synchronisation clé partagée des deux côtés → Tunnel remonté
14h45 — Validation : ping inter-sites OK, sessions actives confirmées dans Statistics
Statut : ✅ Résolu
```

---

## Flux de travail recommandé

### VPN utilisateur en panne

```
1. /vpn [symptôme + type VPN + poste]
   → Diagnostic structuré P1-P4 + commandes lecture seule
        ↓
2. Exécuter les vérifications dans l'ordre proposé
        ↓
3. Cause identifiée → appliquer le correctif avec ⚠️ Impact confirmé
        ↓
4. /close → Note Interne + Discussion
```

### Site offline (P1 potentiel)

```
1. /diag site offline [client + équipement]
   → Classification priorité + plan diagnostic couches
        ↓
2. Diagnostic physique → réseau → routage → firewall (dans l'ordre)
        ↓
3. Si P1 confirmé (site entier) → escalader @IT-Commandare-NOC immédiatement
        ↓
4. Résolution → validation post-action → /close
```

### Modification règle firewall

```
1. Billet CW approuvé existant ? Sinon → ne pas procéder.
        ↓
2. /firewall [marque] [contexte de la modification demandée]
   → IT-NetworkMaster génère la règle avec ⚠️ Impact :
        ↓
3. Backup configuration AVANT toute modification
        ↓
4. Appliquer la règle → tester → valider
        ↓
5. /close → Note Interne complète avec avant/après
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Billet CW approuvé avant toute modification firewall | Aucune modification de prod sans traçabilité et approbation |
| Zéro règle "Any → Any Accept" | Même "temporairement" — c'est permanent en pratique |
| Backup config avant mise à jour firmware | Rollback possible si la mise à jour échoue ou cause des régressions |
| Packet sniffer < 5 min en production | Capturer du trafic client = données sensibles + impact performance |
| `⚠️ Impact :` avant toute modification de règle | Le technicien doit confirmer qu'il comprend l'impact avant d'agir |
| ZÉRO IP dans les livrables clients | Discussion CW et Email → jamais d'infrastructure visible |
| ZÉRO credentials dans les réponses | Passportal uniquement — jamais hardcodé ou mentionné |
| Escalade P1 réseau/firewall vers @IT-Commandare-NOC | < 5 min si site entier offline ou firewall inaccessible |

---

## Questions fréquentes

**Q : Quelle différence entre une règle firewall et une politique de sécurité ?**
IT-NetworkMaster configure les règles réseau (NAT, ACL, filtrage). IT-SecurityMaster gère la politique de sécurité (EDR, SIEM, compliance). En cas de doute, utiliser IT-NetworkMaster en premier — il escalade si la dimension sécurité dépasse le réseau.

**Q : Que faire si le client veut une règle "Any → Any" temporairement pour déboguer ?**
IT-NetworkMaster refusera et proposera une alternative de diagnostic moins risquée (logs firewall, sniffer ciblé, règle temporaire limitée à un IP/port spécifique). L'agent documente le refus dans le billet.

**Q : Comment sauvegarder la config WatchGuard avant une mise à jour ?**
System → Backup Image → sauvegarder localement ET dans Passportal/Hudu. IT-NetworkMaster te génère le rappel automatiquement avant de procéder.

**Q : Un tunnel Meraki AutoVPN est down — est-ce une urgence ?**
Si les deux côtés sont Online dans le dashboard → le tunnel se rétablit automatiquement (quelques minutes). Si un côté est Offline → c'est une panne physique ou réseau à investiguer. IT-NetworkMaster classe la sévérité dans sa réponse.

**Q : MikroTik — comment faire un backup avant une mise à jour ?**
```bash
/system backup save name=backup_avantmaj
/system package update install
# Le reboot est automatique après l'installation
```
IT-NetworkMaster te génère cette séquence avec un avertissement sur l'impact du reboot.

---

*GUIDE_UTILISATION — IT-NetworkMaster v1.0 — MSP Intelligence AI — 2026-05-18*
