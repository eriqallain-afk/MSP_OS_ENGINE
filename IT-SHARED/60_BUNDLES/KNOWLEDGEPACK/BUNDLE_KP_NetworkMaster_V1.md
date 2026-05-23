# BUNDLE_KP_NetworkMaster_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** IT-NetworkMaster
**Usage :** Uploader en Knowledge dans le GPT IT-NetworkMaster
**Contenu :** Runbooks Firewall (WatchGuard/Fortinet/SonicWall/Meraki/Unifi/Mikrotik) + VPN + Diagnostic réseau
**Mis à jour :** 2026-03-20

---

## DIAGNOSTIC RÉSEAU RAPIDE

```powershell
# Baseline réseau complet (Windows)
@("8.8.8.8","1.1.1.1","domaine.local") | ForEach-Object {
    $r = Test-NetConnection $_ -InformationLevel Quiet -WarningAction SilentlyContinue
    [pscustomobject]@{Cible=$_; Atteint=$r}
} | Format-Table

ipconfig /all                        # Config IP complète
tracert -d [GATEWAY]                 # Chemin vers la passerelle
nslookup google.com [DNS_INTERNE]    # Résolution DNS
Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object Name,LinkSpeed

# Linux
ip addr show && ip route show
ss -tunapl | grep ESTABLISHED | head -20
ping -c 4 8.8.8.8 && traceroute 8.8.8.8
```

---

## WATCHGUARD — OPÉRATIONS CLÉS

```
ACCÈS : https://[IP_FIREBOX]:8080 | SSH port 4118 | WatchGuard Cloud ui.watchguard.com
CREDENTIALS : voir Passportal ⛔ jamais dans CW

HEALTH CHECK
Dashboard → Device Status → CPU/RAM/Connexions/Débit/Interfaces
VPN → Statistics → Tunnels actifs
System → Certificates → dates d'expiration (alerter si < 30 jours)

VPN SSL TROUBLESHOOTING
1. VPN → Mobile VPN → SSL → Enabled ?
2. Utilisateur dans le bon groupe AD (voir Authentication → Users and Groups)
3. Port 443 accessible depuis l'extérieur : Test-NetConnection [GATEWAY] -Port 443
4. Logs : Traffic Monitor → filtrer "SSL-VPN"

TUNNEL BOVPN (site-à-site) DOWN
VPN → Statistics → Reset sur le tunnel concerné
Vérifier : même clé partagée (Passportal) + subnets identiques des deux côtés
Logs : filtrer "IKE" dans Traffic Monitor

RENOUVELLEMENT CERTIFICAT WEB UI
System → Certificates → Regenerate (auto-signé) ou Import (tiers)
⛔ Clé privée → Passportal, jamais dans CW

MISE À JOUR FIRMWARE
⚠️ Backup config AVANT : System → Backup Image
System → Software Management → Upload → planifier reboot hors heures
```

---

## FORTINET FORTIGATE — OPÉRATIONS CLÉS

```
ACCÈS : https://[IP] | SSH admin@[IP]
CREDENTIALS : voir Passportal

HEALTH CHECK CLI
get system status
get system performance status
get vpn ipsec tunnel summary
diagnose vpn ike gateway list

VPN SSL TROUBLESHOOTING
get vpn ssl monitor
diagnose debug application sslvpn -1 → diagnose debug enable
→ Attendre 30s → diagnose debug disable

TUNNEL IPSEC DOWN
diagnose vpn tunnel up [NOM_TUNNEL]
diagnose vpn tunnel list name [NOM_TUNNEL]
Vérifier Phase1 + Phase2 (IKE version, DH Group, Encryption)

PACKET SNIFFER (lecture seule - usage limité < 5 min)
diagnose sniffer packet [INTERFACE] "host [IP]" 4 10

LICENCES (alerter si < 30 jours)
get system fortiguard-service status
⛔ NE PAS désactiver le mode IPS/UTM sans approbation SOC
```

---

## SONICWALL — OPÉRATIONS CLÉS

```
ACCÈS : https://[IP] | MySonicWall : mysonicwall.com
CREDENTIALS : voir Passportal

HEALTH CHECK : Dashboard → Security Dashboard → CPU/RAM/Sessions/Licences
VPN SSL : Network → SSL VPN → User Status (sessions actives)
TUNNEL IPSEC : VPN → Settings → Disable → Enable pour reset

ERREUR "Error 789 L2TP" → Clé partagée incorrecte (voir Passportal)
ERREUR "Error 800" → Port bloqué → tester depuis autre réseau

BACKUP AVANT MISE À JOUR : System → Settings → Export Settings (.exp)
```

---

## MERAKI — OPÉRATIONS CLÉS

```
ACCÈS : dashboard.meraki.com (100% cloud)
⛔ NE PAS tenter de reconfigurer sans billet CW approuvé

DEVICE OFFLINE
→ Vérifier alimentation + câble + Internet
→ Meraki requiert HTTPS sortant vers *.meraki.com + UDP 7351
→ L'appareil fonctionne en local même offline (dernière config)

AUTO VPN (site-à-site)
Security → VPN → Site-to-site VPN → statut tunnels
→ Si deux côtés Online → le tunnel se rétablit automatiquement
→ Vérifier subnets qui ne se chevauchent pas

LICENCES ⚠️ Alerter si expiration < 60 jours
Organization → Configure → License Info → Co-termination date
```

---

## UNIFI — OPÉRATIONS CLÉS

```
ACCÈS : https://[IP_CONTROLEUR]:8443 | unifi.ui.com
CREDENTIALS : voir Passportal

AP OFFLINE
ssh ubnt@[IP_AP]  →  set-inform http://[IP_CONTROLEUR]:8080/inform
cat /var/log/messages | tail -50

WIFI PERFORMANCE
Wireless → Monitor → RF Scan → channels encombrés
→ Changer le canal manuellement si interférences (< -70 dBm = signal faible)

MISE À JOUR AP
Devices → Sélectionner → Actions → Upgrade
⚠️ Perte WiFi ~2 min par AP → programmer hors heures
```

---

## MIKROTIK — OPÉRATIONS CLÉS

```
ACCÈS : Winbox (MAC/IP) | WebFig http://[IP] | SSH admin@[IP]

HEALTH CHECK
/system resource print
/interface print
/ip address print
/log print where topics~"error"

VPN
/ip ipsec active-peers print                    # Tunnels IPSec
/interface l2tp-server sessions print           # Clients L2TP
→ Pour relancer un tunnel : /ip ipsec active-peers kill numbers=[ID]

BACKUP AVANT MISE À JOUR
/system backup save name=backup_$(date +%Y%m%d)
/system package update check-for-updates
/system package update install  ← provoque un reboot
⛔ Migrer les VMs/alertes AVANT la mise à jour
```

---

## RÈGLES NON NÉGOCIABLES

```
⛔ NE JAMAIS modifier les règles firewall sans billet CW approuvé
⛔ NE JAMAIS créer de règle "Any → Any Accept" même temporairement
⛔ NE JAMAIS mettre à jour un firmware sans backup de la configuration
⛔ NE JAMAIS stocker les credentials dans CW → Passportal
⛔ NE PAS exécuter le packet sniffer > 5 min en production
```

---

## ESCALADES

| Situation | Département | Délai |
|---|---|---|
| Firewall/site inaccessible | IT-Commandare-NOC | Immédiat |
| Tunnels VPN tous down | IT-Commandare-NOC | 15 min |
| Intrusion détectée (IDS/IPS) | SOC | Immédiat |
| Certificat SSL VPN < 7 jours | IT-Commandare-Infra | Dans la journée |
