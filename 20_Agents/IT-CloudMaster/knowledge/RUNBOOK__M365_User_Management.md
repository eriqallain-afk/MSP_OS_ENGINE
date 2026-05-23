# RUNBOOK - M365 User Management

## Création nouvel utilisateur M365

### Pré-requis
- [ ] Licence disponible
- [ ] Nom/Email validé par RH
- [ ] Département et manager connus
- [ ] Groupes de sécurité identifiés

### Procédure (Azure AD)

```powershell
# Connexion
Connect-AzureAD
Connect-MsolService

# Créer l'utilisateur
$UserPrincipalName = "prenom.nom@domain.com"
$DisplayName = "Prénom Nom"
$Password = (ConvertTo-SecureString -String "<TEMP_PASSWORD>!" -AsPlainText -Force)

New-AzureADUser `
    -DisplayName $DisplayName `
    -UserPrincipalName $UserPrincipalName `
    -AccountEnabled $true `
    -PasswordProfile @{Password = $Password; ForceChangePasswordNextLogin = $true} `
    -Department "IT" `
    -JobTitle "Titre" `
    -MailNickname "prenom.nom"

# Assigner licence E3
Set-MsolUserLicense -UserPrincipalName $UserPrincipalName `
    -AddLicenses "tenant:ENTERPRISEPACK"

# Ajouter aux groupes
Add-AzureADGroupMember -ObjectId "group-id" -RefObjectId "user-id"
```

### Validation post-création
- [ ] Connexion au portail Office 365
- [ ] Email fonctionnel
- [ ] Accès Teams/SharePoint
- [ ] Licence activée

### Troubleshooting

**Problème:** Licence non disponible
- Vérifier inventaire: `Get-MsolAccountSku`
- Commander licences supplémentaires

**Problème:** Email non livré
- Vérifier MX records
- Valider Mail flow rules
- Tester avec `Test-Mailflow`

## Gestion groupes de distribution

### Créer groupe distribution

```powershell
New-DistributionGroup `
    -Name "Equipe-IT" `
    -DisplayName "Équipe IT" `
    -PrimarySmtpAddress "equipe-it@domain.com" `
    -MemberJoinRestriction "Closed" `
    -MemberDepartRestriction "Closed"

# Ajouter membres
Add-DistributionGroupMember `
    -Identity "Equipe-IT" `
    -Member "user@domain.com"
```

### Convertir en groupe M365

```powershell
Upgrade-DistributionGroup -DlIdentities "Equipe-IT"
```

## Onboarding client nouveau locataire

1. **Configuration initiale**
   - Activer MFA pour admins
   - Configurer Conditional Access policies
   - Établir naming standards
   
2. **Sécurité de base**
   - Bloquer legacy authentication
   - Activer ATP Safe Links
   - Configurer DLP policies

3. **Email flow**
   - Configurer SPF/DKIM/DMARC
   - Mail flow rules anti-spam
   - Transport rules

## Références rapides

### Portails d'administration
- Azure AD: https://portal.azure.com
- M365 Admin: https://admin.microsoft.com
- Exchange Admin: https://admin.exchange.microsoft.com
- Security & Compliance: https://protection.office.com

### Commandes PowerShell essentielles

```powershell
# Connexion modules
Connect-AzureAD
Connect-MsolService  
Connect-ExchangeOnline

# Lister utilisateurs
Get-AzureADUser -All $true | Select UserPrincipalName,DisplayName

# Lister licences
Get-MsolAccountSku

# Reset MFA
Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName "user@domain.com"

# Mailbox stats
Get-MailboxStatistics -Identity "user@domain.com"
```
