# SUP-N2-Support_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Assistant-N2 | @IT-FrontLine | @IT-MaintenanceMaster | @IT-SysAdmin
**Département :** SUP | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__N2_Support_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-FrontLine
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** SUPPORT N2 — Couverture complète
**Mis à jour :** 2026-04-11

---

## MENU — Commandes rapides

| Commande | Section |
|---|---|
| `/runbook mdp` | Section 1 — Réinitialisation mot de passe |
| `/runbook compte` | Section 2 — Création et gestion de compte |
| `/runbook imprimante` | Section 3 — Dépannage imprimante réseau |
| `/runbook wifi` | Section 4 — Connectivité Wi-Fi / réseau poste |
| `/runbook vpn` | Section 5 — VPN client utilisateur |
| `/runbook logiciel` | Section 6 — Installation logiciels standards |
| `/runbook application` | Section 7 — Assistance applications métier |

---

## SECTION 1 — Réinitialisation de mot de passe

**Durée estimée :** 5 min | **Priorité :** P3/P4

### Arbre de décision
```
Utilisateur ne peut pas se connecter
├─ Compte verrouillé → 1A Déverrouiller AD
├─ MDP expiré ou oublié → 1B Reset AD ou M365
├─ MFA bloqué / téléphone perdu → 1C Reset MFA
└─ Compte hybride AD + M365 → Reset AD uniquement (sync ~30 min)
   ⛔ NE PAS reset les deux — conflit de sync garanti
```

### 1A — Déverrouiller un compte AD
```powershell
param([Parameter(Mandatory)][string]$Username)
Unlock-ADAccount -Identity $Username
Write-Host " "
Write-Host "Compte déverrouillé : $Username"
Get-ADUser $Username -Properties LockedOut, BadLogonCount | Select-Object Name, LockedOut, BadLogonCount
```

### 1B — Reset MDP Active Directory
```powershell
param(
    [Parameter(Mandatory)][string]$Username,
    [Parameter(Mandatory)][System.Security.SecureString]$NewPassword
)
Set-ADAccountPassword -Identity $Username -NewPassword $NewPassword -Reset
Set-ADUser -Identity $Username -ChangePasswordAtLogon $true
Unlock-ADAccount -Identity $Username
Write-Host " "
Write-Host "MDP réinitialisé : $Username"
Get-ADUser $Username -Properties LockedOut, PasswordExpired, PasswordLastSet | Select-Object Name, LockedOut, PasswordExpired, PasswordLastSet
```

**Reset MDP M365 (Admin Center) :**
```
1. https://admin.microsoft.com → Users → Active Users → [Utilisateur]
2. Account → Reset password → générer ou saisir MDP
3. Cocher "Require this user to change their password when they first sign in"
4. Copier le MDP dans la Note Interne CW — jamais dans la Discussion
5. Communiquer par téléphone uniquement
```

### 1C — Reset MFA M365
```
1. admin.microsoft.com → Users → Active Users → [Utilisateur] → Account
2. Multifactor authentication → Manage → [Utilisateur] → Disable temporairement
3. L'utilisateur reconfigure MFA avec son nouveau téléphone
4. Réactiver MFA — délai max 30 min
```

### Guardrails MDP
```
⛔ JAMAIS communiquer un MDP par email ou Discussion CW
⛔ JAMAIS reset AD ET M365 simultanément sur un compte hybride
✅ Note Interne CW = seul endroit pour noter temporairement un MDP
✅ Vérifier l'identité de l'utilisateur avant tout reset
```

### Escalade
| Situation | Vers |
|---|---|
| Compte verrouillé répétitivement (> 3x/jour) | @IT-SecurityMaster |
| Sync Entra Connect cassée après reset | @IT-Assistant-N3 |

---

## SECTION 2 — Création et gestion de compte utilisateur

**Durée estimée :** 15 min | **Priorité :** P3

### Prérequis OBLIGATOIRE
```
⛔ NE JAMAIS créer un compte sans demande écrite approuvée :
   - Nom complet, titre, département, date de début
   - Groupes AD à assigner
   - Licence M365 requise
```

### Arbre de décision
```
Demande reçue
├─ Nouveau compte (onboarding) → 2A Création AD + M365
├─ Départ (offboarding) → 2B Désactivation et archivage
├─ Modification (titre, groupes, manager) → 2C Modification AD
└─ Réactivation compte désactivé → 2D Réactivation
```

### 2A — Création compte AD
```powershell
param(
    [Parameter(Mandatory)][string]$FirstName,
    [Parameter(Mandatory)][string]$LastName,
    [Parameter(Mandatory)][string]$Domain,
    [Parameter(Mandatory)][string]$OU,
    [AllowEmptyString()][string]$Department = "",
    [AllowEmptyString()][string]$Title = ""
)
$Username = "$($FirstName.ToLower()).$($LastName.ToLower())"
New-ADUser `
    -Name "$FirstName $LastName" `
    -SamAccountName $Username `
    -UserPrincipalName "$Username@$Domain" `
    -Path $OU `
    -Department $Department -Title $Title `
    -AccountPassword (Read-Host -AsSecureString "MDP initial") `
    -ChangePasswordAtLogon $true -Enabled $true
Write-Host " "
Write-Host "Compte créé : $Username"
Get-ADUser $Username | Select-Object Name, SamAccountName, Enabled
```

**Création M365 :** admin.microsoft.com → Users → Add a user → assigner licence → configurer MFA.

### 2B — Désactivation (offboarding)
```powershell
param(
    [Parameter(Mandatory)][string]$Username,
    [AllowEmptyString()][string]$DisabledOU = "OU=Disabled,DC=domaine,DC=local"
)
Disable-ADAccount -Identity $Username
$User = Get-ADUser $Username
Move-ADObject -Identity $User.DistinguishedName -TargetPath $DisabledOU
$Groups = Get-ADUser $Username -Properties MemberOf | Select-Object -ExpandProperty MemberOf
foreach ($g in $Groups) { Remove-ADGroupMember -Identity $g -Members $Username -Confirm:$false }
Write-Host " "
Write-Host "Compte désactivé et déplacé : $Username"
```

**Côté M365 :** Révoquer sessions → retirer licence → configurer réponse auto si demandé.

### 2C — Modifier un compte existant
```powershell
param(
    [Parameter(Mandatory)][string]$Username,
    [AllowEmptyString()][string]$NewTitle = "",
    [AllowEmptyString()][string]$NewDepartment = ""
)
$Params = @{}
if ($NewTitle)      { $Params["Title"]      = $NewTitle }
if ($NewDepartment) { $Params["Department"] = $NewDepartment }
Set-ADUser -Identity $Username @Params
Write-Host " "
Get-ADUser $Username -Properties Title, Department | Select-Object Name, Title, Department
```

### Guardrails comptes
```
⛔ JAMAIS supprimer un compte — toujours désactiver et déplacer dans OU Disabled
⛔ JAMAIS créer sans autorisation écrite
✅ Conserver les comptes désactivés 90 jours minimum
```

---

## SECTION 3 — Dépannage imprimante réseau

**Durée estimée :** 10-20 min | **Priorité :** P3

### Questions à poser en premier
```
1. Problème sur un seul poste ou tous les postes ?
2. Imprimante partagée (serveur print) ou IP directe ?
3. Message d'erreur exact ?
4. L'imprimante est-elle allumée ? Voyants normaux ?
```

### Arbre de décision
```
├─ Un seul poste — file bloquée → 3A Vider la file
├─ Un seul poste — driver corrompu → 3B Réinstaller l'imprimante
├─ Tous les postes — imprimante hors réseau → 3C Réseau imprimante
├─ Tous les postes — serveur print → 3D Spooler serveur
└─ Problème consommables / bourrage → 3E Matériel
```

### 3A — Vider la file d'attente bloquée
```powershell
param()
Stop-Service -Name Spooler -Force
Write-Host " "
Write-Host "Spooler arrêté"
Remove-Item "C:\Windows\System32\spool\PRINTERS\*" -Force -ErrorAction SilentlyContinue
Start-Service -Name Spooler
Write-Host " "
Write-Host "Spooler redémarré"
Get-Service Spooler
```

### 3B — Réinstaller l'imprimante (driver)
```powershell
param(
    [Parameter(Mandatory)][string]$PrinterName,
    [Parameter(Mandatory)][string]$PrinterIP,
    [Parameter(Mandatory)][string]$DriverName
)
Remove-Printer -Name $PrinterName -ErrorAction SilentlyContinue
Remove-PrinterPort -Name "IP_$PrinterIP" -ErrorAction SilentlyContinue
Add-PrinterPort -Name "IP_$PrinterIP" -PrinterHostAddress $PrinterIP
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$PrinterIP"
Write-Host " "
Write-Host "Imprimante recréée : $PrinterName → $PrinterIP"
```

### 3C — Imprimante hors réseau
```
1. ping [IP_IMPRIMANTE] — si pas de réponse : physique/réseau
2. Interface web : http://[IP_IMPRIMANTE] — vérifier état
3. Imprimer page config réseau depuis le panneau de l'imprimante
4. Si IP changée (DHCP) → configurer IP statique via interface web
5. Mettre à jour l'IP dans Hudu
```

### 3D — Spooler serveur d'impression
```powershell
param([Parameter(Mandatory)][string]$PrintServer)
$Svc = Get-Service -ComputerName $PrintServer -Name Spooler
Write-Host " "
Write-Host "Spooler sur $PrintServer : $($Svc.Status)"
if ($Svc.Status -ne "Running") {
    Restart-Service -InputObject $Svc
    Write-Host "Spooler redémarré sur $PrintServer"
}
```

### Escalade imprimantes
| Situation | Vers |
|---|---|
| Configuration réseau avancée (VLAN, QoS) | @IT-NetworkMaster |
| Imprimante défectueuse | Contrat fournisseur → numéro dans Hudu |
| Déploiement GPO imprimantes | @IT-Assistant-N3 |

---

## SECTION 4 — Connectivité Wi-Fi / réseau poste

**Durée estimée :** 10 min | **Priorité :** P3

### Diagnostic rapide
```
ipconfig /all       → IP obtenue (169.x.x.x = DHCP échoué)
ping 8.8.8.8        → connectivité Internet
ping [GATEWAY]      → passerelle locale
nslookup google.com → résolution DNS
```

### Arbre de décision
```
├─ IP 169.x.x.x → 4A Renouveler DHCP
├─ IP valide mais pas d'Internet → 4B DNS / TCP-IP
├─ Wi-Fi connecté mais lent → 4C Signal / profil
└─ Plusieurs postes impactés → 4D Escalade réseau
```

### 4A — Renouveler DHCP
```powershell
param()
ipconfig /release
Write-Host " "
Write-Host "IP libérée — renouvellement en cours..."
ipconfig /renew
Write-Host " "
ipconfig | Select-String "IPv4"
```

### 4B — DNS / pile TCP-IP
```powershell
param()
ipconfig /flushdns
Write-Host " "
Write-Host "Cache DNS vidé"
netsh int ip reset
netsh winsock reset
Write-Host " "
Write-Host "TCP/IP et Winsock réinitialisés — REDÉMARRAGE REQUIS"
```

### 4C — Wi-Fi : oublier et reconnecter
```
1. Taskbar → Wi-Fi → [Réseau] → Forget
2. Reconnecter — saisir le MDP Wi-Fi
3. Si lenteur persiste avec câble aussi → escalade réseau
4. Signal < -70 dBm = trop faible → repositionner le poste ou AP
```

### 4D — Plusieurs postes impactés
```
⚠️ Périmètre N2 LIMITÉ — collecter ces infos et escalader
Combien de postes ? Même switch / AP / bureau ?
Depuis quand ? Changement récent ?
→ Escalader à @IT-NetworkMaster si > 3 postes ou site entier
```

---

## SECTION 5 — VPN client utilisateur

**Durée estimée :** 10-15 min | **Priorité :** P3

### Vérification obligatoire AVANT tout dépannage
```
1. L'utilisateur a-t-il Internet ? → ouvrir google.com
   ⛔ Le VPN ne fonctionnera JAMAIS sans Internet
2. Quelle solution VPN ? → Hudu → [Client] → Firewall/VPN
3. Le compte AD de l'utilisateur est-il actif ? → Section 1A
```

### Arbre de décision
```
├─ Pas d'Internet → Section 4 d'abord
├─ Client VPN ne s'ouvre pas → 5A Réinstaller
├─ Erreur d'authentification → 5B Credentials / MFA
├─ Timeout / serveur inaccessible → 5C Diagnostic réseau VPN
└─ VPN connecté mais aucune ressource → 5D Escalade réseau
```

### 5A — Réinstaller le client VPN
```
WatchGuard SSL : désinstaller → télécharger depuis portail WatchGuard (voir Hudu) → reconfigurer
FortiClient   : désinstaller → https://www.fortinet.com/support/product-downloads
SonicWall     : désinstaller → Microsoft Store ou SonicWall support
```

### 5B — Problème d'authentification
```
1. MDP récemment changé → utiliser le nouveau (⛔ ne pas demander le MDP)
2. Compte AD verrouillé → Section 1A
3. MFA requis → Section 1C
4. Utilisateur absent du groupe AD VPN :
```
```powershell
param(
    [Parameter(Mandatory)][string]$Username,
    [Parameter(Mandatory)][string]$VPNGroup
)
$Member = Get-ADGroupMember -Identity $VPNGroup | Where-Object { $_.SamAccountName -eq $Username }
Write-Host " "
if ($Member) { Write-Host "OK — $Username est dans $VPNGroup" }
else         { Write-Host "ABSENT — ajouter avec : Add-ADGroupMember -Identity '$VPNGroup' -Members '$Username'" }
```

### 5C — Timeout / serveur inaccessible
```
1. Tester depuis un autre réseau (hotspot 5G mobile)
   → Si OK avec 5G : le réseau local bloque les ports VPN
2. Tester le port VPN :
```
```powershell
param(
    [Parameter(Mandatory)][string]$FirewallIP,
    [AllowEmptyString()][string]$Port = "443"
)
Test-NetConnection -ComputerName $FirewallIP -Port $Port
```

### Guardrails VPN
```
⛔ JAMAIS demander le MDP VPN — demander à l'utilisateur de le ressaisir
⛔ JAMAIS chercher des credentials VPN ailleurs que Passportal
✅ Toujours vérifier Internet AVANT de diagnostiquer le VPN
```

### Escalade VPN
| Situation | Vers |
|---|---|
| VPN hors ligne pour plusieurs utilisateurs | @IT-NetworkMaster — peut être P1 |
| VPN connecté mais ressources inaccessibles | @IT-NetworkMaster |
| Problème MFA / Entra | @IT-CloudMaster |

---

## SECTION 6 — Installation et configuration de logiciels standards

**Durée estimée :** 15-30 min | **Priorité :** P4

### Logiciels MSP standards

| Logiciel | Méthode recommandée | Source |
|---|---|---|
| Google Chrome | RMM script | chromeenterprise.google |
| Mozilla Firefox | RMM script | mozilla.org |
| Adobe Acrobat Reader | RMM script | get.adobe.com/reader |
| 7-Zip | RMM script | 7-zip.org |
| Zoom | MSI | zoom.us/download |
| Microsoft 365 Apps | M365 Admin / ODT | portal.office.com |
| WatchGuard VPN | Manuel | Portail WatchGuard client (Hudu) |
| FortiClient VPN | Manuel | fortinet.com/support/product-downloads |

### Déploiement via RMM (N-able / CW RMM)
```
1. Console RMM → Devices → [Poste] → Run Script / Deploy Software
2. Sélectionner le logiciel → exécuter
3. Surveiller le statut (2-5 min)
4. Confirmer avec l'utilisateur
```

### Vérifier si Office est déjà installé
```powershell
param([Parameter(Mandatory)][string]$ComputerName)
$Office = Get-WmiObject -Class Win32_Product -ComputerName $ComputerName |
    Where-Object { $_.Name -like "*Microsoft 365*" -or $_.Name -like "*Microsoft Office*" }
Write-Host " "
if ($Office) { Write-Host "Installé : $($Office.Name) v$($Office.Version)" }
else         { Write-Host "Office non trouvé sur $ComputerName — installation requise" }
```

### Guardrails logiciels
```
⛔ JAMAIS installer depuis une source non officielle
⛔ JAMAIS installer un logiciel non approuvé sans validation gestionnaire client
✅ Documenter la version installée dans la Note Interne CW
✅ Tester avec l'utilisateur avant de fermer le ticket
```

---

## SECTION 7 — Assistance applications métier (support de base)

**Durée estimée :** Variable | **Priorité :** P3

### Questions à poser en premier
```
1. Quelle application ? Quelle version ?
2. Message d'erreur exact ? (demander une capture d'écran)
3. Depuis quand ? Fonctionnait-il hier ?
4. Un seul utilisateur ou plusieurs ?
5. Changement récent (Update, migration) ?
6. Application documentée dans Hudu → [Client] → Applications ?
```

### Arbre de décision
```
├─ Application ne s'ouvre pas → 7A Diagnostic lancement
├─ Erreur de connexion / base de données → 7B Connectivité applicative
├─ Application lente → 7C Ressources système
├─ Erreur de licence → 7D Licences
└─ Fonctionnalité spécifique KO → 7E Support fonctionnel de base
```

### 7A — Application ne s'ouvre pas
```powershell
param()
Get-EventLog -LogName Application -EntryType Error -Newest 20 |
    Select-Object TimeGenerated, Source, Message | Format-List
```
```
Ensuite dans l'ordre :
1. Réparer : Settings → Apps → [App] → Modify → Repair
2. Exécuter en tant qu'administrateur (si ça fonctionne en admin → problème de droits)
3. Vérifier dépendances : .NET, Visual C++ Redistributable, SQL local
4. Désinstaller et réinstaller si Repair échoue
```

### 7B — Erreur de connexion serveur / base de données
```powershell
param(
    [Parameter(Mandatory)][string]$AppServer,
    [AllowEmptyString()][string]$AppPort = "443"
)
Write-Host " "
Test-Connection -ComputerName $AppServer -Count 2
Write-Host " "
Test-NetConnection -ComputerName $AppServer -Port $AppPort
```
```
Si service SQL arrêté sur le serveur → démarrer le service
⚠️ Si SQL crash en boucle → escalader immédiatement à @IT-Assistant-N3
```

### 7C — Ressources système
```powershell
param()
Write-Host " "
Write-Host "=== CPU ==="
Get-WmiObject Win32_Processor | Select-Object Name, @{N="CPU%";E={$_.LoadPercentage}}
Write-Host " "
Write-Host "=== RAM ==="
$OS = Get-WmiObject Win32_OperatingSystem
$Used = [math]::Round(($OS.TotalVisibleMemorySize - $OS.FreePhysicalMemory)/1MB, 1)
$Total = [math]::Round($OS.TotalVisibleMemorySize/1MB, 1)
Write-Host "RAM : $Used GB / $Total GB utilisée"
Write-Host " "
Write-Host "=== Disque C: ==="
Get-PSDrive C | Select-Object @{N="Utilisé(GB)";E={[math]::Round($_.Used/1GB,1)}}, @{N="Libre(GB)";E={[math]::Round($_.Free/1GB,1)}}
```

### Guardrails applications métier
```
⛔ JAMAIS modifier la config d'une app métier sans documentation dans Hudu
⛔ JAMAIS renouveler une licence sans autorisation gestionnaire client
✅ Toujours noter le message d'erreur exact dans la Note Interne CW
✅ Créer un article KB si la résolution est reproductible → /runbook ticket-to-kb
```

### Escalade applications
| Situation | Vers |
|---|---|
| Application métier critique (ERP, CRM, comptabilité) | @IT-Assistant-N3 |
| Erreur SQL ou base de données | @IT-Assistant-N3 |
| Plusieurs utilisateurs impactés | @IT-Assistant-N3 — potentiellement P2 |
| Renouvellement de licence | @IT-AssetMaster |
| App SaaS hors ligne | Vérifier status page éditeur — si outage : P2 |

---

## VÉRIFICATIONS POST-ACTION (toutes sections)

```
□ Problème résolu et testé avec l'utilisateur
□ Note Interne CW mise à jour (cause + résolution)
□ MDP jamais dans Discussion CW
□ Hudu mis à jour si information infrastructure changée
□ Article KB créé si résolution reproductible
□ Ticket fermé uniquement après confirmation utilisateur
```

---

*RUNBOOK__N2_Support_V1 — IT MSP Intelligence Platform — 2026-04-11*
