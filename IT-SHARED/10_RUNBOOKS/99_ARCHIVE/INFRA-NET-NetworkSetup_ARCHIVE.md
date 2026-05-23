# RUNBOOK — CONFIGURATION RESEAU INITIAL
**Agents :** @IT-NetworkMaster
**Scope :** Deploiement ou reconfiguration infrastructure reseau MSP

---

## 1. PLAN D'ADRESSAGE STANDARD MSP

| VLAN | Reseau | Usage |
|---|---|---|
| VLAN 1 | 10.x.1.0/24 | Management (switches/AP) |
| VLAN 10 | 10.x.10.0/24 | Serveurs |
| VLAN 20 | 10.x.20.0/24 | Postes de travail |
| VLAN 30 | 10.x.30.0/24 | VoIP |
| VLAN 40 | 10.x.40.0/24 | Wi-Fi invites (isole) |
| VLAN 50 | 10.x.50.0/24 | IoT / Cameras |

---

## 2. FIREWALL — REGLES MINIMUM

- Any -> WAN : HTTPS(443), HTTP(80), DNS(53)
- LAN -> WAN : Outbound any (journalise)
- DENYALL inbound (sauf regles explicites documentees)
- VPN Mobile : SSL VPN port 443

Voir `BUNDLE_INFRA_FIREWALL.md` pour configuration detaillee par modele.

---

## 3. DHCP — CONFIGURATION

- [ ] Scope cree pour chaque VLAN
- [ ] Exclusions pour IPs statiques (serveurs, imprimantes, AP)
- [ ] DNS servers configures (DC interne + forwarder externe)
- [ ] Lease time : 8h postes, 24h serveurs, 1h invites
- [ ] Reservations documentees dans Hudu

---

## 4. DNS — VALIDATION

```powershell
Resolve-DnsName DC01.domaine.local
Test-NetConnection 8.8.8.8 -Port 443
dcdiag /test:DNS /v
```

---

## 5. VALIDATION POST-DEPLOIEMENT

- [ ] Tous les VLANs joignables depuis le firewall
- [ ] DHCP distribue correctement dans chaque VLAN
- [ ] DNS interne et externe fonctionnels
- [ ] Monitoring ajoute dans N-able / Auvik
- [ ] Documentation Hudu completee (plan reseau, VLANs, IPs statiques)
