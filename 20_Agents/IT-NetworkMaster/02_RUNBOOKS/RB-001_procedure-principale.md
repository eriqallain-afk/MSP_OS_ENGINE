# RB-001 — Diagnostic Réseau et Firewall
**Agent :** IT-NetworkMaster | **Usage :** Incident réseau entrant

## Diagnostic couches (lecture seule d'abord)
```powershell
ipconfig /all
ping -n 4 8.8.8.8
tracert -d [GATEWAY]
nslookup google.com [DNS_INTERNE]
Test-NetConnection -ComputerName [FIREWALL] -Port 443
```

## WatchGuard — Triage VPN SSL
- Dashboard → VPN → Statistics → état tunnels
- Port 443 accessible ? `Test-NetConnection [GW] -Port 443`
- Utilisateur dans bon groupe AD → Authentication → Users and Groups

## Fortinet
```bash
get system status && get vpn ipsec tunnel summary
diagnose vpn tunnel up [NOM]
# Debug IKE (max 30s) : diagnose debug application ike -1 && diagnose debug enable
```

## Meraki — Device offline
Vérifier alimentation + HTTPS sortant vers *.meraki.com + UDP 7351

## MikroTik
```bash
/system resource print && /ip ipsec active-peers print
/log print where topics~"error"
/system backup save name=backup_$(date +%Y%m%d) # Avant toute MàJ
```