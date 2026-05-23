# IT-NetworkMaster — Knowledge Pack v1

> Pack complet réseau MSP : diagnostic, commandes, référence équipements.

---

## 1. ARBRE DE DIAGNOSTIC RÉSEAU

```
PROBLÈME RÉSEAU SIGNALÉ
        │
        ▼
[Un seul user?] ──Oui──► Vérifier poste / câble / switch port / VLAN user
        │No
        ▼
[Un seul site?] ──Oui──► Vérifier switch core / firewall / lien WAN site
        │No
        ▼
[Plusieurs sites?] ──Oui──► Vérifier firewall périmètre / ISP / BGP / MPLS
        │
        ▼
[Internet HS?] ──Oui──► Ping gateway → Ping DNS → Traceroute → ISP ticket
        │No
        ▼
[Réseau interne OK, service HS?] ──► Vérifier serveur applicatif, DNS, firewall règles
```

---

## 2. COMMANDES DE DIAGNOSTIC — Windows / CMD

```powershell
# Connectivité de base
ping 8.8.8.8                          # Test Internet
ping dc01.client.local                 # Test DNS + résolution interne
tracert 8.8.8.8                       # Traceroute Internet
pathping 8.8.8.8                      # Latence + perte par saut

# DNS
nslookup dc01.client.local            # Résolution DNS
nslookup -type=MX client.com 8.8.8.8  # Enregistrements MX
ipconfig /displaydns                  # Cache DNS local
ipconfig /flushdns                    # Vider cache DNS

# IP et interfaces
ipconfig /all                         # Config IP complète
netsh interface show interface        # État interfaces
Get-NetIPAddress                      # PowerShell - adresses IP
Get-NetRoute                          # PowerShell - table de routage

# Connexions actives
netstat -an                           # Toutes connexions
netstat -b                            # Connexions + processus
Get-NetTCPConnection | Sort State     # PowerShell

# Wi-Fi
netsh wlan show all                   # Réseaux WiFi + info
netsh wlan show interfaces            # Interface WiFi
```

---

## 3. COMMANDES CISCO / FortiGate

### Cisco IOS
```
show ip interface brief               # État interfaces + IP
show running-config                   # Config complète
show version                          # Version IOS + hardware
show interfaces GigabitEthernet0/0    # Détail interface
show ip route                         # Table de routage
show ip arp                           # Table ARP
show mac address-table                # Table MAC (switch)
show spanning-tree                    # STP status
show vlan brief                       # VLANs configurés
show cdp neighbors                    # Voisins CDP
debug ip ospf events                  # Debug OSPF (attention production!)
no debug all                          # Stopper tous les debugs
```

### FortiGate CLI
```bash
get system status                     # Version + serial
get system interface                  # Interfaces + IP
get router info routing-table all     # Table de routage
get system arp                        # Table ARP
diagnose sniffer packet any 'host 1.2.3.4' 4   # Capture paquets
diagnose debug flow                   # Debug flow
diagnose firewall iprope show         # Sessions firewall actives
show full-configuration               # Config complète
execute ping 8.8.8.8                  # Ping depuis FortiGate
execute traceroute 8.8.8.8            # Traceroute depuis FortiGate
```

---

## 4. CHECKLIST — Configuration Nouveau Client

```
SETUP RÉSEAU MSP — Nouveau client
─────────────────────────────────────
DOCUMENTATION
[ ] Schéma réseau créé (physique + logique)
[ ] Inventaire équipements dans CMDB
[ ] Plan d'adressage IP documenté
[ ] Tableau VLANs documenté

FIREWALL / SÉCURITÉ
[ ] Firmware à jour
[ ] Accès admin par interface dédiée (MGMT VLAN)
[ ] Règle RDP Internet → BLOQUÉE
[ ] VPN configuré avec MFA
[ ] Log forwarding activé (SIEM / Syslog)
[ ] Profils IPS/AV activés sur règles Internet

RÉSEAU
[ ] Segmentation VLAN en place (Servers / Users / WiFi / IoT / MGMT)
[ ] QoS configuré si VoIP
[ ] Monitoring ajouté (N-Able / PRTG)
[ ] SNMP configuré
[ ] Alertes uptime/latence configurées

DOCUMENTATION FINALE
[ ] Accès admin documentés dans gestionnaire de mots de passe
[ ] Runbook réseau client créé
[ ] Contacts ISP documentés
[ ] Numéros de circuits WAN documentés
```

---

## 5. RÉFÉRENCE VLAN — Standard MSP

| VLAN ID | Nom | Usage | Exemples |
|---------|-----|-------|---------|
| 1 | Default | ⚠️ Ne pas utiliser (sécurité) | — |
| 10 | MGMT | Administration réseau (switches, firewall, AP) | 192.168.10.0/24 |
| 20 | SERVERS | Serveurs production | 192.168.20.0/24 |
| 30 | USERS | Postes de travail | 192.168.30.0/28 |
| 40 | WIFI-CORP | WiFi employés | 192.168.40.0/24 |
| 50 | WIFI-GUEST | WiFi invités (isolé) | 10.50.0.0/24 |
| 60 | VOIP | Téléphones IP | 192.168.60.0/24 |
| 70 | IOT | Appareils IoT / imprimantes | 192.168.70.0/24 |
| 99 | QUARANTINE | Machines isolées / non conformes | 10.99.99.0/24 |

---

## 6. TROUBLESHOOTING — Problèmes Fréquents

### WiFi intermittent
```
1. Vérifier canal WiFi (éviter 1/6/11 surchargés en 2.4 GHz)
2. Vérifier puissance signal (RSSI > -70 dBm recommandé)
3. Vérifier firmware AP
4. Vérifier DHCP lease (épuisement pool ?)
5. Tester en filaire pour isoler WiFi vs réseau
```

### VPN ne se connecte pas
```
1. Vérifier que le service VPN est accessible (ping gateway)
2. Vérifier certificat VPN (expiré ?)
3. Vérifier MFA (token valide ?)
4. Vérifier règle firewall (port 443/UDP 500/4500 ouvert ?)
5. Vérifier logs VPN firewall (FortiGate/Cisco ASA)
6. Test depuis réseau mobile (exclure blocage ISP client)
```

### DNS ne résout pas
```
1. nslookup test.client.local [IP_DC]  # Test direct vers DC
2. Vérifier service DNS sur DC (services.msc)
3. Vérifier Event Log DNS (ID 4015 = erreur zone)
4. ipconfig /registerdns sur DC
5. Vérifier zones DNS (forwarders configurés ?)
6. dcdiag /test:dns /v  # Diagnostic DNS intégral AD
```

---

## 7. GLOSSAIRE RÉSEAU

| Terme | Définition |
|-------|-----------|
| **VLAN** | Virtual LAN — segmentation logique du réseau |
| **QoS** | Quality of Service — priorisation du trafic (VoIP, critique) |
| **BGP** | Border Gateway Protocol — routage inter-AS (WAN/Internet) |
| **OSPF** | Open Shortest Path First — routage IGP interne |
| **STP** | Spanning Tree Protocol — prévention boucles réseau |
| **LACP** | Link Aggregation Control Protocol — agrégation de liens |
| **NAT** | Network Address Translation — translation d'adresses IP |
| **DHCP** | Dynamic Host Configuration Protocol — attribution IP automatique |
| **SNMP** | Simple Network Management Protocol — supervision réseau |
| **MTU** | Maximum Transmission Unit — taille maximale paquet (1500 bytes standard) |
| **Latency** | Délai de transmission (ms) — cible VoIP : < 150ms |
| **Jitter** | Variation de latence — cible VoIP : < 30ms |
| **Packet Loss** | Perte de paquets — cible : < 1% |

---

> Voir aussi : RUNBOOK__IT_NETWORK_DIAGNOSTIC_V1.md | IT__Severity_Matrix.md
