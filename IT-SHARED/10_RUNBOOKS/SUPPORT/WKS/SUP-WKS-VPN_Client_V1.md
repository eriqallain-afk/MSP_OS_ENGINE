# SUP-WKS-VPN_Client_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Diagnostiquer et résoudre les problèmes VPN côté client — connexion impossible, déconnexions fréquentes, ressources inaccessibles après connexion.

> Pour la configuration avancée des firewalls VPN (Fortinet, WatchGuard, SonicWall, Meraki) → runbook [55] SUP-NET-VPN_Troubleshooting_V2.

## QUESTIONS DE TRIAGE

```
[ ] Quel client VPN ? (GlobalProtect / Cisco AnyConnect / WatchGuard / FortiClient / Windows VPN natif)
[ ] VPN ne se connecte pas du tout ? Ou se déconnecte après connexion ?
[ ] Message d'erreur précis ?
[ ] Après connexion VPN — accès aux ressources internes OK ou non ?
[ ] Problème sur ce poste uniquement ou plusieurs collègues ?
[ ] Réseau Internet fonctionne sans VPN (speedtest) ?
[ ] Depuis quand ?
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC VPN CLIENT

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== ADAPTATEURS RÉSEAU ET VPN ==="
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress |
    Out-String -Width 300 | Write-Output

Write-Output "=== IP DES ADAPTATEURS ==="
Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.PrefixOrigin -ne "WellKnown" } |
    Select-Object InterfaceAlias, IPAddress, PrefixLength, PrefixOrigin |
    Out-String -Width 300 | Write-Output

Write-Output "=== ROUTES RÉSEAU (après connexion VPN) ==="
Get-NetRoute -AddressFamily IPv4 | Where-Object { $_.RouteMetric -lt 9999 } |
    Select-Object DestinationPrefix, NextHop, RouteMetric, InterfaceAlias |
    Sort-Object RouteMetric | Out-String -Width 300 | Write-Output

Write-Output "=== DNS ACTIF ==="
Get-DnsClientServerAddress | Where-Object { $_.ServerAddresses -ne "" } |
    Select-Object InterfaceAlias, ServerAddresses | Out-String -Width 300 | Write-Output

Write-Output "=== CLIENTS VPN INSTALLÉS ==="
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                  "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -EA SilentlyContinue |
    Where-Object { $_.DisplayName -match "GlobalProtect|AnyConnect|FortiClient|WatchGuard|OpenVPN|Pulse" } |
    Select-Object DisplayName, DisplayVersion, InstallDate |
    Out-String -Width 300 | Write-Output

Write-Output "=== PROCESSUS VPN EN COURS ==="
$vpnProcesses = @("pangp","vpnagent","ipsecdrv","WGSSLVPN","fortitray","FortiSSLVPNdaemon","openvpn","mstsc")
Get-Process | Where-Object { $_.Name -in $vpnProcesses -or $_.Name -like "*vpn*" -or $_.Name -like "*palo*" } |
    Select-Object Name, Id, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,0)}}, Responding |
    Out-String -Width 300 | Write-Output

Write-Output "=== TEST CONNECTIVITÉ INTERNET ==="
@("8.8.8.8","1.1.1.1") | ForEach-Object {
    $ping = Test-Connection $_ -Count 2 -EA SilentlyContinue
    Write-Output "  $_ : $(if ($ping) { "OK ($([math]::Round(($ping | Measure-Object ResponseTime -Average).Average,0)) ms)" } else { 'ÉCHEC ⛔' })"
}

Write-Output "=== ERREURS VPN RÉCENTES (EventLog) ==="
Get-WinEvent -FilterHashtable @{LogName='Application','System'; StartTime=(Get-Date).AddDays(-3)} -MaxEvents 500 -EA SilentlyContinue |
    Where-Object { $_.Message -match "VPN|GlobalProtect|AnyConnect|FortiClient|WatchGuard|IKE|IPSec" } |
    Select-Object -First 20 TimeCreated, ProviderName, LevelDisplayName, Message |
    Out-String -Width 300 | Write-Output

Write-Output "=== FIN DIAGNOSTIC ==="
```

---

## SECTION 2 — RÉSOLUTION PAR SCÉNARIO

### A — VPN ne se connecte pas (erreur d'authentification)
- Vérifier que le compte AD / M365 est actif et non verrouillé → runbook [52b] wks-login
- Vérifier si MFA requis et fonctionnel
- Tester les credentials sur un autre poste ou via le portail VPN web si disponible
- Réinstaller le certificat client si VPN basé sur certificat

### B — VPN se connecte mais pas d'accès aux ressources

```powershell
#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Exécuter APRÈS connexion VPN
Write-Output "=== TEST ACCÈS RESSOURCES INTERNES ==="

$resources = @{
    "DNS Interne"   = @{Target="[NOM-DC-OU-SERVEUR]"; Port=53; Type="DNS"}
    "Partage Réseau" = @{Target="[NOM-SERVEUR]"; Port=445; Type="SMB"}
    "RDP Serveur"   = @{Target="[NOM-SERVEUR]"; Port=3389; Type="RDP"}
}

foreach ($name in $resources.Keys) {
    $r = $resources[$name]
    $test = Test-NetConnection $r.Target -Port $r.Port -InformationLevel Quiet -EA SilentlyContinue
    Write-Output "  $name ($($r.Target):$($r.Port)) : $(if ($test) {'ACCESSIBLE ✓'} else {'INACCESSIBLE ⛔'})"
}

Write-Output ""
Write-Output "=== RÉSOLUTION DNS VPN ==="
Resolve-DnsName "[NOM-DOMAINE-INTERNE]" -EA SilentlyContinue | Out-String -Width 300 | Write-Output
```

→ Si DNS ne résout pas le domaine interne : problème de split DNS ou serveur DNS poussé par le VPN incorrectement → escalade.

### C — Déconnexions fréquentes
- Vérifier veille réseau / économiseur d'énergie sur l'adaptateur WiFi
- `Get-NetAdapterPowerManagement` → désactiver "Allow computer to turn off device to save power"
- Vérifier qualité signal WiFi si télétravail → recommander câble Ethernet

```powershell
# Désactiver la gestion énergie sur les adaptateurs réseau
Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
    try {
        $pm = Get-NetAdapterPowerManagement -Name $_.Name -EA Stop
        Set-NetAdapterPowerManagement -Name $_.Name -WakeOnMagicPacket Disabled -WakeOnPattern Disabled -EA SilentlyContinue
        Write-Output "Gestion énergie modifiée : $($_.Name)"
    } catch {
        Write-Output "Non applicable : $($_.Name)"
    }
}
```

---

## LIVRABLE CW

```text
CW NOTE INTERNE — Problème VPN
Runbook utilisé : SUP-WKS-VPN_Client_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [À CONFIRMER]
Client VPN : [GlobalProtect / AnyConnect / FortiClient / Autre]
Symptôme : [ne se connecte pas / déconnexions / ressources inaccessibles]

DIAGNOSTIC :
Internet sans VPN : [OK / HS]
VPN se connecte : [Oui / Non / Erreur: ...]
Ressources accessibles après VPN : [Oui / Non]

ACTIONS :
[ ] Credentials vérifiés
[ ] Client VPN réinstallé
[ ] Gestion énergie adaptateur modifiée
[ ] Autre : [À COMPLÉTER]

RÉSULTAT : [Résolu / Escalade]

→ Décision suivante : [raison]
```

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Problème sur plusieurs utilisateurs simultanément | IT-NetworkMaster / runbook [55] | Urgent |
| Configuration firewall/VPN côté serveur | IT-NetworkMaster | Selon SLA |
| Certificat client expiré / PKI | IT-Assistant-N3 | Selon SLA |

*SUP-WKS-VPN_Client_V1 — 2026-05-22*
