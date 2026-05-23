# RUNBOOK__SERVER_ROLE_DISCOVERY
Version: v1  
Owner: IT-SHARED  
Risk: low  
Objectif: **identifier rapidement le(s) rôle(s) d’un serveur** et produire un `role_profile` pasteable dans le ticket/chat.

---

## Quand l’utiliser
- Ticket/alerte RMM où le **rôle du serveur n’est pas confirmé** (ex. hostname ambigu).
- Avant de livrer un runbook “à risque” (ex. patching DC, SQL, hypervisor).

---

## Entrées requises
- `server_name`
- `access_method` (RMM / WinRM / console / RDP / SSH / etc.)

---

## Sortie attendue (à coller au RouterIA)
L’utilisateur doit renvoyer un bloc **YAML** (ou JSON) au format:

```yaml
role_profile:
  server_name: "<name>"
  os_caption: "<Windows Server 2019/2022...>"
  os_version: "<10.0.x>"
  domain_joined: true|false
  detected_roles: ["domain_controller", "dns"]   # liste
  role_confidence: 0.0-1.0
  key_signals:
    - "<signal 1>"
    - "<signal 2>"
  notes: "<anything relevant>"
```

---

## Procédure (Windows) — collecte standard
> Exécuter en PowerShell **admin** (si possible).  
> Ne change rien sur le serveur: **lecture seule**.

### 1) Infos OS + domaine
- `systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"Domain"`
- PowerShell: `Get-CimInstance Win32_OperatingSystem | Select Caption, Version, BuildNumber`

### 2) Signaux de rôles (services & features)
> Tu peux exécuter tout ou partie selon droits/outils.

**A. Services (rapide)**
- DC (AD DS): `Get-Service NTDS -ErrorAction SilentlyContinue`
- DNS: `Get-Service DNS -ErrorAction SilentlyContinue`
- DHCP: `Get-Service DHCPServer -ErrorAction SilentlyContinue`
- SQL: `Get-Service *MSSQL* -ErrorAction SilentlyContinue`
- IIS (W3SVC): `Get-Service W3SVC -ErrorAction SilentlyContinue`
- Hyper-V: `Get-Service vmms -ErrorAction SilentlyContinue`
- RDS: `Get-Service TermService -ErrorAction SilentlyContinue`

**B. Windows Features (si disponible)**
- `Get-WindowsFeature | Where-Object Installed | Select Name`

Signaux typiques:
- `AD-Domain-Services` ⇒ domain_controller (très fort)
- `DNS` ⇒ dns
- `DHCP` ⇒ dhcp
- `Web-Server` ⇒ iis
- `FS-FileServer` ⇒ file_server
- `Hyper-V` ⇒ hyperv
- `RDS-RD-Server` ⇒ rds

### 3) Générer un role_profile (script prêt à copier)
> Si `Get-WindowsFeature` n’existe pas (ex: OS client), ignore la partie features.

```powershell
$svr = $env:COMPUTERNAME
$os  = Get-CimInstance Win32_OperatingSystem
$domain = (Get-CimInstance Win32_ComputerSystem).Domain
$domainJoined = $domain -and $domain -ne $svr

function HasService($name) {
  try { (Get-Service $name -ErrorAction Stop) -ne $null } catch { $false }
}

$roles = @()
$signals = @()

if (HasService "NTDS") { $roles += "domain_controller"; $signals += "Service NTDS present" }
if (HasService "DNS")  { $roles += "dns"; $signals += "Service DNS present" }
if (HasService "DHCPServer") { $roles += "dhcp"; $signals += "Service DHCPServer present" }

try {
  $sql = Get-Service "*MSSQL*" -ErrorAction Stop
  if ($sql) { $roles += "sql_server"; $signals += "MSSQL service(s) present" }
} catch {}

if (HasService "W3SVC") { $roles += "iis"; $signals += "Service W3SVC present" }
if (HasService "vmms")  { $roles += "hyperv"; $signals += "Service vmms present" }
if (HasService "TermService") { $roles += "rds"; $signals += "Service TermService present" }

# Bonus: features si dispo
try {
  $feat = Get-WindowsFeature | Where-Object Installed | Select -Expand Name
  if ($feat -contains "AD-Domain-Services") { if ($roles -notcontains "domain_controller") { $roles += "domain_controller"; $signals += "Feature AD-Domain-Services installed" } }
  if ($feat -contains "Web-Server") { if ($roles -notcontains "iis") { $roles += "iis"; $signals += "Feature Web-Server installed" } }
  if ($feat -contains "FS-FileServer") { if ($roles -notcontains "file_server") { $roles += "file_server"; $signals += "Feature FS-FileServer installed" } }
} catch {}

# Score simple
$confidence = if ($roles.Count -gt 0) { [Math]::Min(1.0, 0.55 + 0.1*$roles.Count) } else { 0.25 }

$profile = [ordered]@{
  role_profile = [ordered]@{
    server_name     = $svr
    os_caption      = $os.Caption
    os_version      = $os.Version
    domain_joined   = [bool]$domainJoined
    detected_roles  = $roles
    role_confidence = [Math]::Round($confidence, 2)
    key_signals     = $signals
    notes           = ""
  }
}

$profile | ConvertTo-Json -Depth 6
```

---

## Validation rapide (sanity)
- Si `domain_controller` détecté: prévoir ensuite des runbooks avec **prechecks réplication**.
- Si `hyperv` détecté: vérifier s’il héberge des VMs critiques avant reboot.
- Si aucun rôle détecté: renvoyer aussi une liste “top 10 services” (optionnel).

---

## Handoff vers RouterIA
L’utilisateur colle le JSON dans le chat. RouterIA doit:
1) parser `detected_roles`
2) choisir `roles_to_intents[role]`
3) livrer le runbook correspondant (ex. DC patching)
