# BUNDLE — BUNDLE_INFRA_SERVER
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Bundle ID :** BUNDLE_INFRA_SERVER
**Source ZIP :** INFRA_Server.zip
**Généré :** 2026-04-04T20:19:33Z

## Contenu (runbooks)
1. **RUNBOOK__AD_User_Management_V1** — RUNBOOK — Active Directory : Gestion Utilisateurs & Groupes (Maj: 2026-03-20 | Agents: IT-Assistant-N2, IT-Assistant-N3)
2. **RUNBOOK__AD_DC_Operations_V1** — RUNBOOK — Active Directory : Opérations Domain Controller (Maj: 2026-03-20 | Agents: IT-Assistant-N3, IT-MaintenanceMaster)
3. **RUNBOOK__DC_PrePost_Validation** — RUNBOOK — Domain Controller (AD DS/DNS) — Precheck/Postcheck (Maj: N/A | Agents: N/A)
4. **RUNBOOK__RDS_Operations_V1** — RUNBOOK — Remote Desktop Services (RDS) : Session Broker & RemoteApp (Maj: 2026-03-20 | Agents: IT-Assistant-N3, IT-MaintenanceMaster)
5. **RUNBOOK__SQL_PrePost_Validation** — RUNBOOK — SQL Server — Precheck/Postcheck (Maj: N/A | Agents: N/A)
6. **TEMPLATE__Server_Health_Check** — TEMPLATE - Server Health Check (Maj: N/A | Agents: N/A)

---

<!-- RUNBOOK_START: RUNBOOK__AD_User_Management_V1 (INFRA__RUNBOOK__AD_User_Management_V1.md) -->
# RUNBOOK — Active Directory : Gestion Utilisateurs & Groupes
**ID :** RUNBOOK__AD_User_Management_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3
**Domaine :** INFRA — Active Directory
**Mis à jour :** 2026-03-20

---

## 1. CRÉATION D'UN COMPTE UTILISATEUR AD

### Pré-requis obligatoires
```
⛔ NE JAMAIS créer un compte sans avoir reçu :
   - Demande écrite du responsable RH ou superviseur direct
   - Nom complet, titre, département, date de début
   - Groupes AD à assigner (selon le rôle)
   - Licence M365 à assigner si applicable
```

### Procédure PowerShell
```powershell
# Variables — adapter selon le client
$FirstName  = "Prénom"
$LastName   = "Nom"
$Username   = "$($FirstName.ToLower()).$($LastName.ToLower())"
$UPN        = "$Username@domaine.com"
$OU         = "OU=Utilisateurs,OU=Client,DC=domaine,DC=local"
$Department = "Département"
$Title      = "Titre du poste"
$Manager    = "username.manager"  # SAMAccountName du gestionnaire

# Créer le compte
New-ADUser `
  -Name "$FirstName $LastName" `
  -GivenName $FirstName `
  -Surname $LastName `
  -SamAccountName $Username `
  -UserPrincipalName $UPN `
  -Path $OU `
  -Department $Department `
  -Title $Title `
  -Manager $Manager `
  -AccountPassword (Read-Host -AsSecureString "Mot de passe initial") `
  -ChangePasswordAtLogon $true `
  -Enabled $true

# Vérification
Get-ADUser $Username | Select-Object Name, SamAccountName, UserPrincipalName, Enabled
```

### Ajouter aux groupes AD
```powershell
# ⛔ NE PAS ajouter directement sur les dossiers/ressources
# Toujours passer par les groupes AD

$Groups = @("GRP_Departement_Acces","GRP_VPN_Users","GRP_Imprimante_Bureau")
foreach ($g in $Groups) {
    Add-ADGroupMember -Identity $g -Members $Username
    Write-Host "Ajouté à : $g"
}
# Vérifier les membres
Get-ADGroupMember "GRP_Departement_Acces" | Select-Object Name, SamAccountName
```

---

## 2. DÉSACTIVATION D'UN COMPTE (DÉPART EMPLOYÉ)

```
⛔ NE JAMAIS supprimer un compte immédiatement — désactiver d'abord
   Attendre 30 jours minimum avant suppression définitive
   Vérifier si le compte possède des boîtes aux lettres partagées ou des ressources
```

```powershell
$Username = "prenom.nom"

# 1. Désactiver le compte
Disable-ADAccount -Identity $Username

# 2. Révoquer les sessions actives (si M365 connecté)
# À faire dans Azure AD / Entra ID en parallèle

# 3. Déplacer vers OU Désactivés
$OU_Desactives = "OU=Comptes_Desactives,DC=domaine,DC=local"
Move-ADObject -Identity (Get-ADUser $Username).DistinguishedName -TargetPath $OU_Desactives

# 4. Retirer de tous les groupes SAUF Domain Users
$GroupsToRemove = Get-ADPrincipalGroupMembership $Username |
    Where-Object { $_.Name -ne "Domain Users" }
foreach ($g in $GroupsToRemove) {
    Remove-ADGroupMember -Identity $g.Name -Members $Username -Confirm:$false
    Write-Host "Retiré de : $($g.Name)"
}

# 5. Ajouter note dans la description
Set-ADUser $Username -Description "DÉSACTIVÉ le $(Get-Date -Format 'yyyy-MM-dd') - Billet #XXXXXX"

# 6. Validation
Get-ADUser $Username -Properties Description | Select-Object Name, Enabled, Description
```

---

## 3. RÉINITIALISATION MOT DE PASSE

```powershell
# ⚠️ Vérifier l'identité de l'utilisateur AVANT toute réinitialisation
$Username = "prenom.nom"

# Réinitialiser et forcer changement à la prochaine connexion
Set-ADAccountPassword -Identity $Username -Reset `
    -NewPassword (Read-Host -AsSecureString "Nouveau mot de passe")
Set-ADUser -Identity $Username -ChangePasswordAtLogon $true
Unlock-ADAccount -Identity $Username

# Vérifier que le compte n'est plus verrouillé
Get-ADUser $Username -Properties LockedOut, PasswordExpired, BadLogonCount |
    Select-Object Name, Enabled, LockedOut, PasswordExpired, BadLogonCount
```

---

## 4. GESTION DES GROUPES AD

### Créer un nouveau groupe
```powershell
# ⛔ Toujours documenter l'objectif du groupe dans la Description
New-ADGroup `
    -Name "GRP_NomGroupe_Usage" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=Groupes,DC=domaine,DC=local" `
    -Description "Usage : accès [ressource]. Créé le $(Get-Date -Format 'yyyy-MM-dd') - Billet #XXXXXX"
```

### Auditer les membres d'un groupe
```powershell
$GroupName = "GRP_NomGroupe"
Get-ADGroupMember $GroupName -Recursive |
    Get-ADUser -Properties Department, Title, Enabled |
    Select-Object Name, SamAccountName, Department, Title, Enabled |
    Sort-Object Name | Format-Table -AutoSize
```

### Trouver tous les groupes d'un utilisateur
```powershell
$Username = "prenom.nom"
(Get-ADUser $Username -Properties MemberOf).MemberOf |
    ForEach-Object { (Get-ADGroup $_).Name } |
    Sort-Object
```

---

## 5. AUDIT COMPTES INACTIFS

```powershell
# Comptes non utilisés depuis 90 jours
$Date = (Get-Date).AddDays(-90)
Search-ADAccount -AccountInactive -TimeSpan (New-TimeSpan -Days 90) -UsersOnly |
    Where-Object { $_.Enabled -eq $true } |
    Get-ADUser -Properties LastLogonDate, Department |
    Select-Object Name, SamAccountName, LastLogonDate, Department |
    Sort-Object LastLogonDate | Format-Table -AutoSize
```

---

## 6. NE PAS FAIRE — RÈGLES ABSOLUES

```
⛔ NE JAMAIS modifier les permissions directement sur les dossiers
   → Toujours utiliser les groupes AD

⛔ NE JAMAIS supprimer un compte sans désactivation préalable de 30 jours

⛔ NE JAMAIS créer un compte sans demande écrite approuvée

⛔ NE JAMAIS partager des credentials de compte de service

⛔ NE JAMAIS mettre un utilisateur dans le groupe "Domain Admins" pour un accès temporaire
   → Créer un accès délégué ou un groupe dédié

⛔ NE JAMAIS renommer Domain Admins, Domain Users, ou autres groupes built-in
```

---

## 7. ESCALADE

| Situation | Département |
|---|---|
| Compromission de compte admin | SOC — Immédiat |
| Problème de réplication AD | NOC |
| GPO affectant tous les utilisateurs | INFRA |
| Restructuration OU importante | TECH (approbation requise) |
<!-- RUNBOOK_END: RUNBOOK__AD_User_Management_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__AD_DC_Operations_V1 (INFRA__RUNBOOK__AD_DC_Operations_V1.md) -->
# RUNBOOK — Active Directory : Opérations Domain Controller
**ID :** RUNBOOK__AD_DC_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-MaintenanceMaster
**Domaine :** INFRA — Active Directory Infrastructure
**Mis à jour :** 2026-03-20

---

## 1. HEALTH CHECK DC — PROCÉDURE COMPLÈTE

```powershell
$OutDir = "C:\IT_LOGS\AUDIT\DC_$(Get-Date -Format 'yyyyMMdd_HHmm')"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
Start-Transcript -Path "$OutDir\DC_HealthCheck.log"

# 1. Services critiques
Write-Host "=== SERVICES ===" -ForegroundColor Cyan
Get-Service NTDS,DNS,Netlogon,KDC,W32Time |
    Select-Object Name, Status, StartType | Format-Table -AutoSize

# 2. Partages SYSVOL et NETLOGON
Write-Host "=== SYSVOL / NETLOGON ===" -ForegroundColor Cyan
net share | Select-String -Pattern "SYSVOL|NETLOGON"

# 3. Réplication AD
Write-Host "=== RÉPLICATION ===" -ForegroundColor Cyan
repadmin /replsummary
repadmin /showrepl

# 4. Rôles FSMO
Write-Host "=== RÔLES FSMO ===" -ForegroundColor Cyan
netdom query fsmo

# 5. DCdiag rapide
Write-Host "=== DCDIAG ===" -ForegroundColor Cyan
dcdiag /q

# 6. Événements critiques (24h)
Write-Host "=== ÉVÉNEMENTS CRITIQUES ===" -ForegroundColor Cyan
$start = (Get-Date).AddHours(-24)
Get-WinEvent -FilterHashtable @{LogName='Directory Service'; StartTime=$start} |
    Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
    Select-Object -First 20 TimeCreated, Id, Message | Format-Table -Wrap

Stop-Transcript
```

---

## 2. VÉRIFICATION RÉPLICATION AD

```powershell
# Résumé réplication (vue globale)
repadmin /replsummary

# Forcer synchronisation depuis tous les partenaires
repadmin /syncall /AdeP

# Vérifier les objets en attente (lingering objects)
repadmin /removelingeringobjects [DC_cible] [DC_source] [Partition] /Advisory_Mode

# Diagnostique erreurs réplication
repadmin /showrepl * /errorsonly

# Si erreur de réplication — vérifier la topologie
repadmin /showconn
```

### Erreurs courantes réplication

| Code erreur | Cause | Action |
|---|---|---|
| 1256 | DC inaccessible réseau | Vérifier connectivité + DNS |
| 1722 | RPC server unavailable | Vérifier service RPC + firewall |
| 8453 | Accès refusé réplication | Vérifier permissions DSACLS |
| 8606 | Lingering objects | repadmin /removelingeringobjects |
| -2146893022 | Problème Kerberos/heure | Synchroniser W32Time |

---

## 3. SYNCHRONISATION HEURE (W32Time)

```powershell
# Vérifier l'état de la synchronisation
w32tm /query /status
w32tm /query /peers

# Forcer synchronisation
net stop w32time
net start w32time
w32tm /resync /force

# Sur le PDC emulator — configurer source NTP externe
w32tm /config /manualpeerlist:"time.windows.com,0x8 pool.ntp.org,0x8" /syncfromflags:manual /reliable:YES /update
```

---

## 4. VÉRIFICATION DNS SUR DC

```powershell
# Zones DNS hébergées sur ce DC
Get-DnsServerZone | Select-Object ZoneName, ZoneType, IsAutoCreated | Format-Table

# Enregistrements SRV critiques AD
Resolve-DnsName -Name "_ldap._tcp.dc._msdcs.domaine.com" -Type SRV
Resolve-DnsName -Name "_kerberos._tcp.dc._msdcs.domaine.com" -Type SRV

# Ré-enregistrer les enregistrements DNS du DC
ipconfig /registerdns
nltest /dsregdns

# Test résolution interne
Resolve-DnsName "NOM_DC" -Type A
Resolve-DnsName "domaine.com" -Type SOA
```

---

## 5. PRE/POST REBOOT DC

### PRECHECK avant reboot DC
```powershell
# ⚠️ NE JAMAIS reboôter le seul DC de l'environnement sans plan de contingence
# ⚠️ S'assurer qu'un DC secondaire est opérationnel AVANT le reboot

# Vérifier rôles FSMO sur CE DC
netdom query fsmo

# Vérifier réplication OK
repadmin /replsummary

# Vérifier sessions actives
query session /server:$(hostname)

# Vérifier pas de job batch en cours
Get-ScheduledTask | Where-Object {$_.State -eq 'Running'}
```

### POSTCHECK après reboot DC
```powershell
# Attendre 2-3 minutes après le démarrage avant de valider

# Services démarrés
Get-Service NTDS,DNS,Netlogon,KDC,W32Time |
    Select-Object Name, Status | Format-Table

# SYSVOL partagé
net share | Select-String "SYSVOL|NETLOGON"

# Réplication reprise
repadmin /replsummary

# Authentification fonctionnelle
nltest /sc_verify:domaine.com
```

---

## 6. GESTION RÔLES FSMO

```powershell
# Voir les 5 rôles FSMO
netdom query fsmo

# Transfert FSMO vers un autre DC (normal, planifié)
# Sur le DC qui reçoit les rôles :
Move-ADDirectoryServerOperationMasterRole -Identity "NOM_DC_CIBLE" `
    -OperationMasterRole SchemaMaster, DomainNamingMaster, RIDMaster, PDCEmulator, InfrastructureMaster

# ⚠️ Saisie de rôle FSMO (urgence — DC source inaccessible)
# ntdsutil → roles → connections → connect to server [DC_cible] → quit
# → seize [role] → quit → quit
# ⛔ NE SAISIR les rôles QUE si le DC source est définitivement HS
```

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS reboôter tous les DCs en même temps
⛔ NE JAMAIS modifier le schéma AD sans approbation et backup
⛔ NE JAMAIS baisser le niveau fonctionnel du domaine/forêt
⛔ NE JAMAIS saisir les rôles FSMO si le DC source est récupérable
⛔ NE JAMAIS désactiver le compte krbtgt directement
⛔ NE JAMAIS supprimer un DC avec ntdsutil sans nettoyage des métadonnées
```

---

## 8. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Réplication bloquée depuis > 1h | NOC | 30 min |
| DC unique tombé, auth impossible | NOC + INFRA | Immédiat |
| Compromission compte domain admin | SOC | Immédiat |
| Modification schéma AD requise | TECH (approbation) | Planifié |
<!-- RUNBOOK_END: RUNBOOK__AD_DC_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__DC_PrePost_Validation (RUNBOOK__DC_PrePost_Validation.md) -->
# RUNBOOK — Domain Controller (AD DS/DNS) — Precheck/Postcheck

## Services critiques
```powershell
Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Format-Table Name,Status,StartType
net share | findstr /I "SYSVOL NETLOGON"
```

## Réplication AD
```powershell
repadmin /replsummary
repadmin /syncall /AdeP
```

## Santé AD (rapide)
```powershell
# dcdiag peut être long; utiliser /q pour erreurs seulement
$OutDir = "$env:TEMP\\DC_CHECK"; New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
dcdiag /q | Out-File (Join-Path $OutDir "dcdiag_q_$TS.txt")
"dcdiag_q saved to $OutDir"
```

## DNS (erreurs récentes)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Rejouer services + replsummary.
- Vérifier que SYSVOL/NETLOGON partagés.
- Confirmer qu'aucun nouvel event critique (Directory Service/System).
<!-- RUNBOOK_END: RUNBOOK__DC_PrePost_Validation -->

---

<!-- RUNBOOK_START: RUNBOOK__RDS_Operations_V1 (INFRA__RUNBOOK__RDS_Operations_V1.md) -->
# RUNBOOK — Remote Desktop Services (RDS) : Session Broker & RemoteApp
**ID :** RUNBOOK__RDS_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-MaintenanceMaster
**Domaine :** INFRA — Remote Desktop Services
**Mis à jour :** 2026-03-20

---

## 1. ARCHITECTURE RDS TYPIQUE MSP

```
Client → RD Gateway → RD Broker → RD Session Host(s)
                    ↓
              RD Web Access
              RD Licensing
```

**Composants clés :**
- **RD Connection Broker** — distribue les sessions, gère la reconnexion
- **RD Session Host** — héberge les sessions et applications
- **RD Gateway** — accès sécurisé depuis Internet (HTTPS 443)
- **RD Web Access** — portail web RemoteApp
- **RD Licensing** — gestion des CAL RDS

---

## 2. VÉRIFICATION SANTÉ RDS — HEALTH CHECK

```powershell
Start-Transcript -Path "C:\IT_LOGS\DIAG\RDS_HealthCheck_$(Get-Date -Format 'yyyyMMdd_HHmm').log"

# Services RDS critiques
Write-Host "=== SERVICES RDS ===" -ForegroundColor Cyan
$RDSServices = @(
    'TermService',      # Remote Desktop Services
    'SessionEnv',       # Remote Desktop Configuration
    'UmRdpService',     # Remote Desktop Device Redirector
    'RpcSs',            # RPC (requis)
    'TSGateway'         # RD Gateway (si installé)
)
Get-Service $RDSServices -ErrorAction SilentlyContinue |
    Select-Object Name, DisplayName, Status, StartType | Format-Table -AutoSize

# Sessions actives
Write-Host "=== SESSIONS ACTIVES ===" -ForegroundColor Cyan
query session

# Utilisateurs connectés
Write-Host "=== UTILISATEURS ===" -ForegroundColor Cyan
query user

# Ressources serveur
Write-Host "=== RESSOURCES ===" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    CPU_Usage = "$((Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average)%"
    RAM_Free_GB = [math]::Round($os.FreePhysicalMemory/1MB, 1)
    RAM_Total_GB = [math]::Round($os.TotalVisibleMemorySize/1MB, 1)
    Disk_C_Free_GB = [math]::Round((Get-PSDrive C).Free/1GB, 1)
} | Format-List

Stop-Transcript
```

---

## 3. DÉPANNAGE — UTILISATEUR NE PEUT PAS SE CONNECTER

### Arbre de décision
```
L'utilisateur ne peut pas se connecter en RDS
│
├─ Message "The remote computer could not be found"
│   → Vérifier DNS + connectivité réseau + RD Gateway
│
├─ Message "Access denied"
│   → Vérifier groupe "Remote Desktop Users" ou "RDP_Acces" dans AD
│   → Vérifier GPO qui bloquent l'accès RDP
│
├─ Message "The connection was denied because the user account is not authorized"
│   → Vérifier propriétés utilisateur AD → onglet Remote control
│   → Vérifier "Allow log on through Remote Desktop Services" GPO
│
├─ Message "Your session has been disconnected"
│   → Vérifier limites de session dans GPO (timeout, déconnexion)
│   → Vérifier le profil itinérant si applicable
│
└─ Connexion réussie mais application ne démarre pas
    → Vérifier les RemoteApp publiées dans RD RemoteApp Manager
    → Vérifier les droits sur l'application
```

### Vérifier et ajouter l'accès RDP
```powershell
# ⛔ NE PAS activer l'accès RDP à un utilisateur individuellement
# Utiliser le groupe AD approprié

# Vérifier les membres du groupe Remote Desktop Users
Get-ADGroupMember "Remote Desktop Users" | Select-Object Name, SamAccountName

# Ajouter l'utilisateur au groupe approprié
Add-ADGroupMember -Identity "Remote Desktop Users" -Members "prenom.nom"
# OU selon la convention du client :
Add-ADGroupMember -Identity "GRP_RDP_Utilisateurs" -Members "prenom.nom"
```

### Vérifier les limites de session GPO
```powershell
# Vérifier les paramètres GPO RDS appliqués
gpresult /h "C:\IT_LOGS\DIAG\GPResult_RDS.html" /f
# Ouvrir le fichier HTML pour analyser les politiques appliquées

# Chemins GPO pertinents :
# Computer > Admin Templates > Windows Components > Remote Desktop Services
# > RD Session Host > Session Time Limits
# > RD Session Host > Connections
```

---

## 4. DÉPANNAGE — SESSIONS FANTÔMES (GHOST SESSIONS)

```powershell
# Lister toutes les sessions incluant déconnectées
query session

# Identifier les sessions avec statut "Disc" (déconnectées)
# Réinitialiser une session fantôme (remplacer ID par le numéro de session)
Reset-Session 3 /server:NOM_SERVEUR_RDS

# Forcer déconnexion d'une session (si reset ne suffit pas)
logoff 3 /server:NOM_SERVEUR_RDS

# ⛔ NE PAS tuer les sessions sans avoir averti l'utilisateur
# ⛔ NE PAS déconnecter la session Console (ID 0)
```

---

## 5. GESTION REMOTEAPP

### Vérifier les applications publiées
```powershell
# Sur le serveur RD Session Host ou via Server Manager
Import-Module RemoteDesktop

# Lister les RemoteApp publiées
Get-RDRemoteApp -CollectionName "NomCollection" |
    Select-Object DisplayName, FilePath, Alias | Format-Table -AutoSize
```

### Publier une nouvelle RemoteApp
```powershell
# ⚠️ Vérifier que l'application est installée sur TOUS les Session Hosts de la collection
New-RDRemoteApp `
    -CollectionName "NomCollection" `
    -DisplayName "Nom Application" `
    -FilePath "C:\Program Files\App\app.exe" `
    -Alias "NomApp"

# Assigner les groupes AD qui peuvent accéder à cette RemoteApp
Set-RDRemoteApp `
    -CollectionName "NomCollection" `
    -Alias "NomApp" `
    -UserGroups @("DOMAINE\GRP_App_Users")
```

---

## 6. RD GATEWAY — VÉRIFICATION

```powershell
# Services RD Gateway
Get-Service TSGateway | Select-Object Name, Status, StartType

# Vérifier le certificat SSL RD Gateway (expiration)
$cert = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -match "gateway.domaine.com" }
[pscustomobject]@{
    Subject = $cert.Subject
    Expiration = $cert.NotAfter
    JoursRestants = ($cert.NotAfter - (Get-Date)).Days
}
```

---

## 7. REBOOT SESSION HOST — PROCÉDURE

```powershell
# ⚠️ AVANT de reboôter un Session Host :
# 1. Vider le serveur des utilisateurs actifs

# Mode drain — nouvelles connexions redirigées vers d'autres hôtes
Set-RDSessionHost -SessionHost "NOM_HOST.domaine.com" `
    -NewConnectionAllowed No -ConnectionBroker "NOM_BROKER.domaine.com"

# Vérifier qu'il n'y a plus de sessions actives
query session /server:NOM_HOST

# Attendre / déconnecter les sessions restantes
# Puis procéder au reboot
Restart-Computer -ComputerName "NOM_HOST" -Force

# Après reboot — réactiver les connexions
Set-RDSessionHost -SessionHost "NOM_HOST.domaine.com" `
    -NewConnectionAllowed Yes -ConnectionBroker "NOM_BROKER.domaine.com"
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS reboôter tous les Session Hosts en même temps
⛔ NE JAMAIS donner les droits administrateur local sur un RDS à un utilisateur standard
⛔ NE JAMAIS installer des logiciels sur un Session Host sans mode installation
   → toujours utiliser : change user /install avant l'installation
   → puis : change user /execute après
⛔ NE JAMAIS mapper un lecteur réseau en dur dans un profil RDS
   → utiliser les GPO de redirection de dossiers
⛔ NE JAMAIS désactiver le monitoring sur un Session Host pendant une maintenance
   sans avoir informé le NOC
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Broker RD inaccessible (tous les utilisateurs impactés) | NOC | Immédiat |
| Certificat RD Gateway expiré | INFRA | Dans l'heure |
| > 50 utilisateurs déconnectés simultanément | NOC | Immédiat |
| Problème de licence RDS (CAL épuisées) | TECH | Dans l'heure |
<!-- RUNBOOK_END: RUNBOOK__RDS_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__SQL_PrePost_Validation (RUNBOOK__SQL_PrePost_Validation.md) -->
# RUNBOOK — SQL Server — Precheck/Postcheck

## Services
```powershell
Get-Service | Where-Object {$_.Name -match '^MSSQL' -or $_.Name -match '^SQL'} | Sort-Object Name | Format-Table Name,Status,StartType
```

## Connectivité (local)
> Option A : `Invoke-Sqlcmd` si module dispo.

```powershell
if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
  Invoke-Sqlcmd -Query "SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version" | Format-Table -Auto
} else {
  "Invoke-Sqlcmd indisponible — fallback .NET"
  $cn = New-Object System.Data.SqlClient.SqlConnection
  $cn.ConnectionString = "Server=localhost;Database=master;Integrated Security=True;Connection Timeout=5"
  $cn.Open();
  $cmd = $cn.CreateCommand();
  $cmd.CommandText = "SELECT @@SERVERNAME AS ServerName";
  $r = $cmd.ExecuteScalar();
  $cn.Close();
  "ServerName=$r"
}
```

## Journaux Windows (SQL-related)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} |
  Where-Object { $_.LevelDisplayName -in 'Error','Critical' -and ($_.ProviderName -match 'MSSQL|SQLSERVERAGENT|SQL' -or $_.Message -match 'SQL') } |
  Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Services MSSQL/Agent running.
- Test SELECT OK.
- Vérifier EventLog 1h post.

## Note opérationnelle
- Certains environnements (CU/patch) peuvent nécessiter **2 reboots**. Documenter la raison (pending reboot flags).
<!-- RUNBOOK_END: RUNBOOK__SQL_PrePost_Validation -->

---

<!-- RUNBOOK_START: TEMPLATE__Server_Health_Check (TEMPLATE__Server_Health_Check.md) -->
# TEMPLATE - Server Health Check

**Date:** [DATE]  
**Serveur:** [HOSTNAME]  
**Technicien:** [NOM]  
**Type:** [Physical / VM - Hyper-V / VM - ESXi / Azure VM]

---

## 1. INFORMATIONS SYSTÈME

### Général
- **OS Version:** [Windows Server 2022 / 2019 / 2016]
- **Build:** [20348.xxx]
- **Architecture:** [x64]
- **Domain:** [DOMAIN.LOCAL]
- **Uptime:** [X jours, X heures]
- **Last Reboot:** [DATE/TIME]

### Hardware (si applicable)
- **Fabricant:** [Dell / HP / etc.]
- **Modèle:** [PowerEdge R640 / etc.]
- **CPU:** [X cores @ X GHz]
- **RAM:** [X GB]
- **RAID Controller:** [Type + Status]

---

## 2. ESPACE DISQUE

| Lettre | Label | Total | Utilisé | Libre | % Libre | Status |
|--------|-------|-------|---------|-------|---------|---------|
| C: | OS | X GB | X GB | X GB | X% | 🟢/🟡/🔴 |
| D: | Data | X GB | X GB | X GB | X% | 🟢/🟡/🔴 |
| E: | Logs | X GB | X GB | X GB | X% | 🟢/🟡/🔴 |

**Seuils:**
- 🟢 > 20% libre
- 🟡 10-20% libre
- 🔴 < 10% libre

**Actions requises:**
- [ ] Aucune
- [ ] Nettoyage requis (volume X)
- [ ] Extension disque requise (volume X)

---

## 3. PERFORMANCE

### CPU
- **Utilisation moyenne (7j):** [X]%
- **Utilisation max (7j):** [X]%
- **Processus top consommateur:** [nom processus - X%]

**Status:** 🟢 < 70% / 🟡 70-85% / 🔴 > 85%

### Mémoire
- **RAM installée:** [X GB]
- **RAM utilisée:** [X GB]
- **RAM disponible:** [X GB]
- **% Utilisation:** [X]%
- **Page File Usage:** [X MB / X MB]

**Status:** 🟢 < 80% / 🟡 80-90% / 🔴 > 90%

### Réseau
- **NICs actives:** [X]
- **Throughput moyen:** [X Mbps]
- **Packets errors:** [X]

**Status:** 🟢 OK / 🟡 Warnings / 🔴 Errors

---

## 4. SERVICES CRITIQUES

| Service | Display Name | Status | Startup | Action |
|---------|--------------|--------|---------|--------|
| W32Time | Windows Time | Running | Automatic | ✓ OK |
| Dnscache | DNS Client | Running | Automatic | ✓ OK |
| Netlogon | Netlogon | Running | Automatic | ✓ OK |
| [service] | [nom] | [status] | [type] | [action] |

**Services arrêtés (non désirés):**
- [Nom service - raison si connu]

**Actions:**
- [ ] Redémarrer services arrêtés
- [ ] Investiguer cause arrêt

---

## 5. EVENT LOGS (Dernières 24h)

### Erreurs système (System Log)
| Time | Source | Event ID | Message |
|------|--------|----------|---------|
| [TIME] | [Source] | [ID] | [Brief msg] |

**Nombre total erreurs System:** [X]

### Erreurs application (Application Log)
| Time | Source | Event ID | Message |
|------|--------|----------|---------|
| [TIME] | [Source] | [ID] | [Brief msg] |

**Nombre total erreurs Application:** [X]

### Erreurs critiques
- [ ] Aucune erreur critique
- [ ] Erreurs critiques détectées (voir détails ci-dessus)

---

## 6. MISES À JOUR WINDOWS

### Status
- **Dernière vérification:** [DATE/TIME]
- **Dernière installation:** [DATE]
- **Patches en attente:** [X]
- **Reboot requis:** [Oui/Non]

### Patches récents (30 derniers jours)
| KB | Titre | Date installation |
|----|-------|-------------------|
| KB5034441 | Security Update | 2024-01-15 |
| [KB] | [Titre] | [Date] |

**Actions:**
- [ ] Pas d'action requise
- [ ] Installer patches en attente
- [ ] Planifier reboot pour appliquer patches

---

## 7. BACKUP STATUS

### Configuration
- **Solution:** [VEEAM / Windows Backup / Azure Backup / Autre]
- **Type:** [Full + Incremental / Differential]
- **Rétention:** [X jours]
- **Destination:** [Path/URL]

### Derniers backups
| Date | Type | Taille | Durée | Status |
|------|------|--------|-------|--------|
| [DATE] | Full | X GB | Xh Xm | ✓ Success |
| [DATE] | Incr | X GB | Xm | ✓ Success |

**Backups ratés (7 derniers jours):**
- [ ] Aucun
- [ ] [DATE - Raison]

**Actions:**
- [ ] Pas d'action
- [ ] Investiguer backup raté
- [ ] Test restore requis

---

## 8. SÉCURITÉ

### Antivirus/Endpoint Protection
- **Solution:** [Windows Defender / Symantec / Autre]
- **Version:** [X.X.X]
- **Dernière mise à jour définitions:** [DATE/TIME]
- **Dernière analyse complète:** [DATE]
- **Menaces détectées (30j):** [X]

**Actions:**
- [ ] Rien à signaler
- [ ] Forcer mise à jour définitions
- [ ] Investiguer menaces

### Firewall
- **Status:** [Activé/Désactivé]
- **Profil actif:** [Domain / Private / Public]
- **Règles inbound:** [X]
- **Règles outbound:** [X]

### Comptes locaux
| Compte | Status | Dernier login | Action |
|--------|--------|---------------|--------|
| Administrator | Enabled/Disabled | [DATE] | [Action] |
| [compte] | [status] | [date] | [action] |

**Comptes inutilisés à désactiver:**
- [Liste comptes]

---

## 9. RÔLES & FONCTIONNALITÉS

### Rôles installés
- [ ] Active Directory Domain Services
- [ ] DNS Server
- [ ] DHCP Server
- [ ] File Services
- [ ] IIS
- [ ] Hyper-V
- [ ] SQL Server
- [ ] [Autre]

### Applications tierces
| Application | Version | Status |
|-------------|---------|--------|
| [App] | [X.X] | Running/Stopped |

---

## 10. RÉSEAU & CONNECTIVITÉ

### Configuration IP
| NIC | IP Address | Subnet | Gateway | DNS |
|-----|------------|--------|---------|-----|
| Ethernet0 | [IP_CLIENTE] | 255.255.255.0 | [IP_CLIENTE] | [IP_CLIENTE], [IP_CLIENTE] |

### Tests connectivité
- [ ] Ping gateway: OK / FAILED
- [ ] Ping DNS: OK / FAILED
- [ ] Ping DC: OK / FAILED
- [ ] Internet: OK / FAILED
- [ ] Résolution DNS: OK / FAILED

**Commandes exécutées:**
```cmd
ping [IP_CLIENTE] -n 4
ping 8.8.8.8 -n 4
nslookup google.com
```

---

## 11. SPÉCIFIQUE AU RÔLE

### [Si File Server]
- **Shares actifs:** [X]
- **Connexions actives:** [X utilisateurs]
- **Quotas:** [Status]

### [Si SQL Server]
- **Instance:** [MSSQLSERVER / nom]
- **Databases:** [X]
- **Status:** [Online/Offline]
- **Dernier backup:** [DATE]
- **Jobs failed:** [X]

### [Si IIS]
- **Sites web:** [X]
- **App Pools:** [X]
- **Sites down:** [X]

### [Si Hyper-V]
- **VMs totales:** [X]
- **VMs running:** [X]
- **VM checkpoints:** [X]
- **Storage usage:** [X GB / X GB]

---

## 12. OBSERVATIONS & RECOMMANDATIONS

### Problèmes identifiés
1. **[Titre problème 1]**
   - Sévérité: 🔴 Critique / 🟡 Important / 🟢 Mineur
   - Impact: [Description]
   - Recommandation: [Action]

2. **[Titre problème 2]**
   - Sévérité: 🔴/🟡/🟢
   - Impact: [Description]
   - Recommandation: [Action]

### Optimisations suggérées
- [Suggestion 1]
- [Suggestion 2]

### Actions à planifier
- [ ] [Action 1 - échéance]
- [ ] [Action 2 - échéance]

---

## 13. CONCLUSION

### Status global
🟢 **Healthy** / 🟡 **Attention required** / 🔴 **Critical issues**

### Prochaine revue
**Date:** [DATE]

### Approbation
- **Technicien:** [NOM] - [DATE]
- **Superviseur:** [NOM] - [DATE]

---

## ANNEXE: Commandes utilisées

```powershell
# Informations système
Get-ComputerInfo | Select OSName, OSVersion, CsName, WindowsVersion, OsUptime

# Espace disque
Get-PSDrive -PSProvider FileSystem | Select Name, @{N="Total(GB)";E={[math]::Round($_.Used + $_.Free)/1GB,2}}, @{N="Used(GB)";E={[math]::Round($_.Used/1GB,2)}}, @{N="Free(GB)";E={[math]::Round($_.Free/1GB,2)}}, @{N="Free%";E={[math]::Round(($_.Free/($_.Used+$_.Free))*100,2)}}

# Services
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select Name, DisplayName, Status

# Event logs errors (dernières 24h)
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddHours(-24) | Select TimeGenerated, Source, EventID, Message

# Patches récents
Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-30)} | Sort InstalledOn -Descending | Select HotFixID, Description, InstalledOn

# Performance counters
Get-Counter '\Processor(_Total)\% Processor Time', '\Memory\Available MBytes' | Select -ExpandProperty CounterSamples

# Réseau
Get-NetAdapter | Select Name, Status, LinkSpeed
Test-NetConnection -ComputerName 8.8.8.8 -InformationLevel Detailed
```
<!-- RUNBOOK_END: TEMPLATE__Server_Health_Check -->

---
