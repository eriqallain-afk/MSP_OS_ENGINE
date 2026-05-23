# RUNBOOK — GESTION UTILISATEURS M365
**Agents :** @IT-CloudMaster, IT-MaintenanceMaster, IT-SysAdmin
**Scope :** Creation, modification, licences, MFA, desactivation

---

## 1. CREATION COMPTE

```powershell
Connect-MgGraph -Scopes 'User.ReadWrite.All','Directory.ReadWrite.All'
$userParams = @{
  DisplayName       = 'Prenom Nom'
  UserPrincipalName = 'prenom.nom@domaine.com'
  MailNickname      = 'prenom.nom'
  AccountEnabled    = $true
  PasswordProfile   = @{ Password = (Read-Host -AsSecureString); ForceChangePasswordNextSignIn = $true }
}
New-MgUser @userParams
```

**Checklist creation :**
- [ ] UPN conforme au standard client (prenom.nom@domaine.com)
- [ ] Licence assignee (minimum Business Basic)
- [ ] MFA configure (Authenticator app) des le premier login
- [ ] Groupes ajoutes (AD, M365, Distribution)
- [ ] Signature email configuree
- [ ] Fiche Hudu creee ou mise a jour

---

## 2. ATTRIBUTION LICENCES

```powershell
# Voir licences disponibles
Get-MgSubscribedSku | Select-Object SkuPartNumber,
  @{N='Dispo';E={$_.PrepaidUnits.Enabled - $_.ConsumedUnits}}

# Assigner licence
Set-MgUserLicense -UserId 'prenom.nom@domaine.com' `
  -AddLicenses @{SkuId = 'GUID_LICENCE'} -RemoveLicenses @()
```

---

## 3. DESACTIVATION (depart employe)

```powershell
Update-MgUser -UserId 'prenom.nom@domaine.com' -AccountEnabled $false
Revoke-MgUserSignInSession -UserId 'prenom.nom@domaine.com'
```

**Checklist desactivation :**
- [ ] Compte AD desactive (si hybride)
- [ ] Sessions M365 revoquees
- [ ] Boite mail -> partagee ou redirection configuree
- [ ] OneDrive -> acces delegue au manager (30 jours minimum)
- [ ] Licence recuperee apres 30 jours
- [ ] Hudu mis a jour
