# INFRA-AD-UserManagement_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__AD_User_Management_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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
