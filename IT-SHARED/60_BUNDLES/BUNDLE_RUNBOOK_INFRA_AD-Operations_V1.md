# BUNDLE RUNBOOK INFRA AD-Operations V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-Assistant-N2, IT-Assistant-N3, IT-MaintenanceMaster | IT-SysAdmin
**Description :** Active Directory — Gestion utilisateurs, Domain Controllers, DC Health
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__AD_User_Management_V1 -->
## RUNBOOK — Gestion Utilisateurs et Groupes AD

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


---
<!-- SOURCE: RUNBOOK__AD_DC_Operations_V1 -->
## RUNBOOK — Opérations Domain Controller

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


---
<!-- SOURCE: TEMPLATE_SUPPORT_Escalade-et-Service-Restaure_V1 -->
## TEMPLATE — Blocs Escalade et Service Restauré

# TEMPLATE_SUPPORT_Escalade-et-Service-Restaure_V1
**Agent :** IT-Assistant-N2, IT-Assistant-N3
**Usage :** Blocs CW à coller avant transfert d'un billet + confirmation service rétabli
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — BLOC ESCALADE NOC (à coller dans CW avant transfert)

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT NOC
Billet : #[XXXXXX] | Priorité : P[1/2]
Technicien : [NOM] | [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

SYMPTÔME
[Description précise]

IMPACT IMMÉDIAT
• Utilisateurs affectés : [Nombre / Qui]
• Services impactés    : [Liste]
• Heure de début       : [HH:MM]

RISQUES À VENIR SI NON TRAITÉ
• [Risque 1]
• [Risque 2]

ASSETS AFFECTÉS
• [Asset 1]
• [Asset 2]

ACTIONS DÉJÀ TENTÉES (N2/N3)
1. [Action — résultat]
2. [Action — résultat]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — BLOC ESCALADE SOC

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT SOC
Billet : #[XXXXXX] | Priorité : P[1/2]
Technicien : [NOM] | [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

TYPE : ☐ Phishing/Compromission  ☐ Ransomware  ☐ Breach  ☐ Autre

COMPTE/ASSET AFFECTÉ
• [Utilisateur / Asset — voir Passportal pour credentials]
• Heure de détection : [HH:MM]

SYMPTÔMES OBSERVÉS
• [Symptôme 1]
• [Symptôme 2]

ACTIONS IMMÉDIATES EFFECTUÉES (N2/N3)
☐ Compte désactivé
☐ Sessions révoquées
☐ MDP réinitialisé (voir Passportal)

VÉRIFICATIONS À COMPLÉTER PAR LE SOC
☐ Règles Outlook suspectes
☐ Transferts automatiques
☐ Activité connexion 7 derniers jours
☐ Propagation — autres comptes
═══════════════════════════════════════════════
```

---

## PARTIE 3 — BLOC ESCALADE TECH (Senior/RCA)

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT TECH (Support N3+)
Billet : #[XXXXXX] | Priorité : P[1/2/3]
Technicien N2 : [NOM] | [YYYY-MM-DD HH:MM]
Durée intervention N2 : [X min]
═══════════════════════════════════════════════

PROBLÉMATIQUE
[Description complète]

CE QUI A ÉTÉ TENTÉ
1. [Action — résultat]
2. [Action — résultat]
3. [Action — résultat]

HYPOTHÈSE ACTUELLE
[Ce que le technicien pense être la cause]

CLIENT EN ATTENTE : ☐ Oui  ☐ Non
SLA À RISQUE      : ☐ Oui  ☐ Non
═══════════════════════════════════════════════
```

---

## PARTIE 4 — CONFIRMATION SERVICE RÉTABLI (CW Discussion + Teams)

### CW Discussion (client-safe)
```
RÉSOLUTION : [Type de service] rétabli
DATE : [YYYY-MM-DD] | TECHNICIEN : [Initiales]

TRAVAUX EFFECTUÉS :
• Analyse du service et vérifications de l'environnement
• [Action corrective 1 — description fonctionnelle sans détails techniques sensibles]
• [Action corrective 2]
• Contrôles de bon fonctionnement effectués

RÉSULTAT :
• [Service X] : pleinement opérationnel depuis [HH:MM]
• Monitoring confirmé — aucune alerte active

RECOMMANDATION :
• [Si applicable — ex: planifier une mise à jour de prévention]
```

### Annonce Teams
```
✅ Service rétabli — [Nom du service] | [DATE] [HH:MM]
Billet #[XXXXXX] — [Technicien]
[Description 1 ligne de la résolution]
```


---
<!-- SOURCE: CHECKLIST_MAINTENANCE_Precheck-Generic_V1 -->
## CHECKLIST — Precheck Générique Serveur

# CHECKLIST — PRECHECK (Generic Windows Server)

- [ ] Uptime / last boot
- [ ] Pending reboot (CBS/WU/PendingFileRename/CCM)
- [ ] CPU/RAM (si perf incident)
- [ ] Disques (C: + volumes data) — espace libre
- [ ] Services critiques (selon rôle)
- [ ] Sessions (RDS) si reboot prévu
- [ ] Event Logs: System/Application (Errors/Critical sur 1–2h)
- [ ] Backups : dernier job OK (si maintenance)
- [ ] Monitoring: alertes actives vs baseline



---
<!-- SOURCE: CHECKLIST_MAINTENANCE_Postcheck-Generic_V1 -->
## CHECKLIST — Postcheck Générique Serveur

# CHECKLIST — POSTCHECK (Generic Windows Server)

- [ ] Host en ligne (ping/RMM)
- [ ] Services critiques OK
- [ ] Event Logs post-action: Kernel-Power, disk/NTFS, service failures
- [ ] Pending reboot = False (ou expliqué)
- [ ] App/partage/URL test rapide
- [ ] Monitoring back to green / alertes normalisées
- [ ] Backups: pas d'échec post-reprise

