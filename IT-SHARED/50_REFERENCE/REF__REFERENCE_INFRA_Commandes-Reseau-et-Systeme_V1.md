# REFERENCE_INFRA_Commandes-Reseau-et-Systeme_V1
**Agent :** IT-NetworkMaster, IT-Assistant-N3, IT-MaintenanceMaster | IT-SysAdmin
**Usage :** Référence rapide des commandes de diagnostic réseau et système
**Mis à jour :** 2026-03-20

---

## WINDOWS — RÉSEAU

```powershell
# Configuration IP complète
ipconfig /all

# Vider le cache DNS
ipconfig /flushdns

# Renouveler bail DHCP
ipconfig /release && ipconfig /renew

# Test connectivité
ping -n 4 [cible]
Test-NetConnection -ComputerName [cible] -Port [port]
tracert -d [cible]

# Routes
route print
Get-NetRoute | Where-Object {$_.DestinationPrefix -eq '0.0.0.0/0'}

# DNS
nslookup [nom] [serveur-dns]
Resolve-DnsName [nom] -Type A

# Connexions actives
netstat -ano | findstr ESTABLISHED
Get-NetTCPConnection | Where-Object {$_.State -eq 'Established'}

# Interfaces réseau
Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
Get-NetIPAddress -AddressFamily IPv4
```

---

## CISCO IOS / IOS-XE

```
show version
show interfaces status
show ip interface brief
show ip route
show log | tail 50
show running-config
show vlan brief
show spanning-tree summary
show mac address-table
show cdp neighbors
show arp
show ip bgp summary
```

---

## FORTINET FORTIGATE (CLI)

```bash
get system status
get system performance status
get system interface
diagnose ip address list
get vpn ipsec tunnel summary
diagnose vpn ike gateway list
get firewall policy
diagnose sniffer packet [iface] "host [IP]" 4 10
get log memory raw
```

---

## WATCHGUARD (CLI SSH — port 4118)

```bash
show vpn
show log | tail 50
ifconfig
conntrack -L | head 20
```

---

## LINUX — RÉSEAU

```bash
ip addr show
ip route show
ss -tunapl
netstat -tunapl
ping -c 4 [cible]
traceroute [cible]
dig [nom] @[serveur-dns]
nslookup [nom]
iptables -L -n -v
```

---

## MIKROTIK (CLI)

```bash
/system resource print
/interface print
/ip address print
/ip route print
/ip ipsec active-peers print
/log print where topics~"error"
/ip firewall filter print stats
```

---

## WINDOWS — SYSTÈME

```powershell
# Info système
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, LastBootUpTime

# Processus top CPU/RAM
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WS

# Services arrêtés (Auto)
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'}

# Disques
Get-PSDrive -PSProvider FileSystem | Select-Object Name,
    @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
    @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}}

# Logs événements
Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=(Get-Date).AddHours(-24)} |
    Select-Object -First 20 TimeCreated, Id, Message

# Pending reboot
Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
```
