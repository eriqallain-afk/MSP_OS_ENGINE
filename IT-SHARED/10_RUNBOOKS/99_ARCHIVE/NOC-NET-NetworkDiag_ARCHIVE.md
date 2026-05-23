# RUNBOOK — DIAGNOSTIC RESEAU IT
**Agents :** @IT-NetworkMaster
**Scope :** Connectivite, DNS, DHCP, VPN, firewall

---

## 1. DIAGNOSTIC INITIAL

```powershell
# Connectivite de base
Test-NetConnection -ComputerName 8.8.8.8 -Port 53
Test-NetConnection -ComputerName google.com -Port 443
Resolve-DnsName google.com

# Interfaces reseau actives
Get-NetAdapter | Where-Object Status -eq Up | Select-Object Name, LinkSpeed, MacAddress
Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer
```

---

## 2. DNS

```powershell
Resolve-DnsName DC01.domaine.local              # DNS interne AD
Resolve-DnsName domaine.com -Server 8.8.8.8    # DNS externe
dcdiag /test:DNS /v                             # Diagnostic complet DNS AD
ipconfig /flushdns                              # Vider le cache DNS client
```

**Issues frequentes :**
- DNS client pointe vers mauvais serveur -> corriger via DHCP ou GPO
- Conditional Forwarders manquants -> ajouter dans DNS Manager

---

## 3. DHCP

```powershell
Get-DhcpServerv4Scope | Select-Object ScopeId, Name, State
Get-DhcpServerv4ScopeStatistics | Select-Object ScopeId, PercentageInUse, Free
```

**Seuil critique :** Si utilisation > 80% -> etendre ou nettoyer les baux expires.

---

## 4. FIREWALL

- [ ] Ports entrants : uniquement ceux documentes dans Hudu
- [ ] Ports sortants : 80/443/53/25 non bloques
- [ ] VPN : tunnels actifs verifies
- [ ] Logs : aucune regle deny massive inattendue

Voir `BUNDLE_INFRA_FIREWALL.md` pour procedures specifiques WatchGuard/Fortinet/SonicWall.
