# EXEMPLE DE RÉFÉRENCE — INTERVENTION MSP
## Diagnostic DHCP — Étendue saturée / Scope critique

**Type de document :** Référence interne / cas modèle réutilisable  
**Client du cas :** Otto Inc  
**Billet de référence :** #0001234  
**Usage :** Réutilisation lors d’alertes NOC de saturation DHCP ou scope critique  

## But du document
Transformer la résolution complète de ce cas en modèle de référence pour les techniciens MSP. Le document conserve la séquence d’analyse réellement utilisée, les scripts PowerShell employés, les critères de diagnostic, les décisions prises, ainsi que les sorties CW prêtes à coller.

## 1. Quand utiliser ce document
- Lorsqu’une alerte NOC / RMM indique qu’un scope DHCP est à 100 %, presque plein ou en état critique.
- Lorsqu’un site signale des échecs d’attribution IP pour de nouveaux appareils, postes, téléphones SIP ou équipements réseau.
- Lorsqu’il faut distinguer une panne DHCP réelle d’une saturation structurelle, d’un conflit IP ponctuel ou d’une mauvaise interprétation des réservations.
- Lorsqu’on veut produire rapidement une note interne, une discussion facturable et une recommandation de suivi uniformes.

## 2. Résumé exécutif du cas de référence
Le cas a commencé par une alerte NOC signalant une étendue DHCP à 100 % sur CLT-DC01. L’analyse a confirmé que le service DHCP était fonctionnel, mais que l’étendue était en forte tension de capacité. Une entrée BAD_ADDRESS a été observée puis corrélée à l’historique d’un poste client vu avec plusieurs adresses MAC / interfaces. Cette anomalie a été retenue comme symptôme secondaire. La cause principale retenue est une saturation structurelle du scope, utilisé par plusieurs catégories d’équipements dans un même segment d’adressage.

## 3. Runbooks, garde-fous et références utilisés
### 3.1 Utilisés ou référencés directement pendant le cas
- `GUARDRAILS__IT_AGENTS_MASTER` — posture lecture seule d’abord, une action à la fois, livrables CW, pas d’invention.
- `TEMPLATE_BUNDLE_CW_CLOSE` — préparation des sorties de clôture CW (Note interne / Discussion client).
- `RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1` (dans `BUNDLE_RUNBOOK_SUPPORT_Intervention-Live_V1` / `BUNDLE_RUNBOOKS_IT_SUPPORT`) — qualification initiale du billet et logique d’escalade.

### 3.2 Références complémentaires pertinentes
- `BUNDLE_KP_SysAdmin_V2` — section DNS / DHCP : commandes de statistiques de scope et seuil > 80 % comme point d’attention.
- Références AD / DNS / RMM du client pour la corrélation d’une IP en conflit à un poste précis.
- Cette intervention met aussi en évidence le besoin d’un runbook DHCP dédié si ce type d’alerte devient fréquent.

## 4. Pré-requis
- Accès admin au serveur DHCP ou session PowerShell distante.
- Module DHCP Server disponible.
- Accès RMM ou équivalent pour la corrélation machine cliente.
- Accès AD et DNS si une IP / un hostname doit être corrélé.
- Accès aux journaux DHCP : `C:\Windows\System32\dhcp`.
- Aucune remédiation avant confirmation de la cause principale.

## 5. Séquence d’analyse exacte
### 5.1 Étape 1 — Validation réelle du scope
```powershell
$ScopeId = '10.50.0.0'

Write-Host "=== SCOPE ==="
Get-DhcpServerv4Scope -ScopeId $ScopeId | Format-List *

Write-Host " "
Write-Host "=== STATISTICS ==="
Get-DhcpServerv4ScopeStatistics -ScopeId $ScopeId | Format-List *

Write-Host " "
Write-Host "=== EXCLUSIONS ==="
Get-DhcpServerv4ExclusionRange -ScopeId $ScopeId | Format-Table -AutoSize

Write-Host " "
Write-Host "=== RESERVATIONS COUNT ==="
(Get-DhcpServerv4Reservation -ScopeId $ScopeId | Measure-Object).Count

Write-Host " "
Write-Host "=== LEASE STATES ==="
Get-DhcpServerv4Lease -ScopeId $ScopeId |
    Group-Object AddressState |
    Select-Object Name, Count |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== NEXT EXPIRING LEASES ==="
Get-DhcpServerv4Lease -ScopeId $ScopeId |
    Sort-Object LeaseExpiryTime |
    Select-Object -First 20 IPAddress, HostName, ClientId, AddressState, LeaseExpiryTime |
    Format-Table -AutoSize
```

### 5.2 Étape 2 — Plage réelle, bail et baux Declined
```powershell
$ScopeId = '10.50.0.0'

Write-Host "=== SCOPE RANGE / LEASE DURATION ==="
Get-DhcpServerv4Scope -ScopeId $ScopeId |
    Select-Object ScopeId, Name, StartRange, EndRange, SubnetMask, LeaseDuration, State |
    Format-List

Write-Host " "
Write-Host "=== DECLINED LEASES ==="
Get-DhcpServerv4Lease -ScopeId $ScopeId |
    Where-Object { $_.AddressState -eq 'Declined' } |
    Select-Object IPAddress, HostName, ClientId, AddressState, LeaseExpiryTime |
    Format-Table -AutoSize
```

### 5.3 Étape 3 — Revue ciblée des IP en conflit
```powershell
$ScopeId = '10.50.0.0'
$IPs = @(
    '10.50.0.26',
    '10.50.0.57',
    '10.50.0.73',
    '10.50.0.124',
    '10.50.0.130',
    '10.50.0.132',
    '10.50.0.254'
)

Write-Host "=== DHCP ROUTER OPTION ==="
Get-DhcpServerv4OptionValue -ScopeId $ScopeId -OptionId 3 |
    Format-List *

Write-Host " "
Write-Host "=== RESERVATIONS MATCHING DECLINED IPs ==="
Get-DhcpServerv4Reservation -ScopeId $ScopeId |
    Where-Object { $IPs -contains $_.IPAddress.IPAddressToString } |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== CONFLICT IP CHECK ==="
$Results = foreach ($IP in $IPs) {
    $Ping = Test-Connection -ComputerName $IP -Count 1 -Quiet -ErrorAction SilentlyContinue
    $Neighbor = Get-NetNeighbor -IPAddress $IP -ErrorAction SilentlyContinue | Select-Object -First 1

    [pscustomobject]@{
        IPAddress      = $IP
        PingResponds   = $Ping
        MacAddress     = if ($Neighbor) { $Neighbor.LinkLayerAddress } else { '[none]' }
        NeighborState  = if ($Neighbor) { $Neighbor.State } else { '[none]' }
        InterfaceAlias = if ($Neighbor) { $Neighbor.InterfaceAlias } else { '[none]' }
    }
}

$Results | Format-Table -AutoSize
```

### 5.4 Étape 4 — Confirmer le nombre réel d’IP encore libres
```powershell
$ScopeId = '10.50.0.0'

Write-Host "=== FREE DHCP IPs ==="
Get-DhcpServerv4FreeIPAddress -ScopeId $ScopeId -NumAddress 15 |
    Format-Table -AutoSize
```

### 5.5 Étape 5 — Analyse d’un BAD_ADDRESS persistant
```powershell
$IP = '10.50.0.73'
$ScopeId = '10.50.0.0'

Write-Host "=== BAD ADDRESS DETAILS ==="
Get-DhcpServerv4Lease -ScopeId $ScopeId |
    Where-Object { $_.IPAddress -eq $IP } |
    Select-Object IPAddress, HostName, ClientId, AddressState, LeaseExpiryTime, Description |
    Format-List

Write-Host " "
Write-Host "=== NEIGHBOR CHECK ==="
Get-NetNeighbor -IPAddress $IP -ErrorAction SilentlyContinue |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== DNS CHECK ==="
Resolve-DnsName $IP -ErrorAction SilentlyContinue

Write-Host " "
Write-Host "=== DHCP AUDIT LOG QUICK CHECK ==="
$AuditPath = 'C:\Windows\System32\dhcp'
Get-ChildItem $AuditPath -Filter 'DhcpSrvLog-*.log' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 2 |
    ForEach-Object {
        Write-Host "----- $($_.Name) -----"
        Select-String -Path $_.FullName -Pattern '10.50.0.73' -SimpleMatch -ErrorAction SilentlyContinue
    }
```

### 5.6 Étape 6 — Corrélation AD / DNS / machine cliente
```powershell
$HostName = 'AJ-LT-I3E79FI'
$ZoneName = 'tc.lan'
$Mac = 'F0D415992A4B'
$AuditPath = 'C:\Windows\System32\dhcp'

Write-Host "=== AD COMPUTER ==="
Get-ADComputer -Identity $HostName -Properties DNSHostName, Enabled, LastLogonDate, IPv4Address, whenChanged -ErrorAction SilentlyContinue |
    Select-Object Name, DNSHostName, Enabled, LastLogonDate, IPv4Address, whenChanged |
    Format-List

Write-Host " "
Write-Host "=== DNS A RECORD ==="
Get-DnsServerResourceRecord -ZoneName $ZoneName -Name $HostName -RRType A -ErrorAction SilentlyContinue |
    Select-Object HostName, Timestamp,
        @{N='IPAddress';E={$_.RecordData.IPv4Address.IPAddressToString}} |
    Format-Table -AutoSize
```

## 6. Critères de diagnostic
- **Panne DHCP réelle** : service non répondant, impact généralisé confirmé.
- **Alerte transitoire** : le scope remonte avec une marge confortable.
- **Saturation structurelle** : très peu d’IP libres, nombreuses catégories d’équipements dans le même scope, bail déjà court, /24 presque complet.
- **Symptôme secondaire** : BAD_ADDRESS lié à un conflit historique, à une interface secondaire ou à un client multi-interface.

## 7. Conclusion du cas de référence
Le service DHCP était fonctionnel. Le problème principal était une saturation structurelle du scope /24, utilisé par trop de catégories d’équipements dans un même segment. L’entrée BAD_ADDRESS investiguée a été classée comme symptôme secondaire après corrélation avec l’historique d’un poste vu avec plusieurs interfaces / MAC.

## 8. Sorties CW prêtes à coller
### Note interne CW — exemple
```text
────────────────────────────────────────────────────────
        DHCP / SATURATION D’ÉTENDUE / ANALYSE
────────────────────────────────────────────────────────

BILLET: #[XXXXX]
CLIENT: [Nom du client]
DATE: [YYYY-MM-DD]

PRÉPARATION ET DÉCOUVERTE
---------
Prise de connaissance de la demande et consultation de la documentation du client.

Réception et analyse d’une alerte NOC liée à une saturation d’étendue DHCP.
Investigation effectuée en lecture seule uniquement.
```

### Discussion CW — exemple
```text
  ────────────────────────────────────────────────────────
          Analyse d’alerte DHCP — Capacité d’adressage
  ────────────────────────────────────────────────────────

DATE: [YYYY-MM-DD]
TECHNICIEN: [À CONFIRMER]
---------

PRÉPARATION ET DÉCOUVERTE:
---------
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.
```
