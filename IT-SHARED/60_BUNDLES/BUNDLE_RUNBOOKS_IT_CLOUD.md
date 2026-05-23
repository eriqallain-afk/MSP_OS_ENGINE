# BUNDLE_RUNBOOKS_IT_CLOUD
**Bundle Runbooks — IT MSP Intelligence Platform**
**Catégorie :** Cloud — M365, Azure, Entra ID, Utilisateurs, Architecture cloud
**Agents consommateurs :** @IT-CloudMaster | @IT-Commandare-Infra | @IT-AssetMaster
**Version :** 1.0 | **Date :** 2026-04-04
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Repo GitHub :** `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_CLOUD.md`

> Ce bundle regroupe tous les runbooks de la catégorie **Cloud — M365, Azure, Entra ID, Utilisateurs, Architecture cloud**.
> Uploader en Knowledge dans les GPT agents indiqués.
> Les runbooks sont à jour — source canonique dans GitHub.

---

## RB-CLOUD-001 — Architecture Cloud / Azure — Standards et déploiement

# RUNBOOK — IT_CLOUD_ARCHITECTURE_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Architecture cloud (requirements -> design -> sécurité -> runbook)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-CTOMaster`
- Steps (ordre canon) :
  - **cto** → `IT-CTOMaster`
  - **cloud** → `IT-CloudMaster`
  - **security** → `IT-SecurityMaster`
  - **kb** → `IT-KnowledgeKeeper`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---

## RB-CLOUD-002 — M365 — Gestion des utilisateurs

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


---

## RB-CLOUD-003 — M365 — Onboarding nouvel utilisateur

# RUNBOOK: Microsoft 365 User Onboarding

## Métadonnées
- **ID:** RUNBOOK-M365-USER-001
- **Version:** 1.0
- **Dernière mise à jour:** Février 2026
- **Durée estimée:** 20-30 minutes
- **Niveau:** Intermédiaire

## Objectif
Provisionner un utilisateur Microsoft 365 avec tous les services et permissions selon les meilleures pratiques de sécurité.

## Prérequis
- [ ] Accès Global Admin ou User Admin à M365
- [ ] Licences M365 disponibles
- [ ] Formulaire d'onboarding complété
- [ ] Approbation du manager

## Variables requises
```yaml
user_first_name: "Jean"
user_last_name: "Tremblay"
user_upn: "jtremblay@company.com"
job_title: "Analyste IT"
department: "Technologies"
manager_upn: "mlavoie@company.com"
office_location: "Montreal, QC"
license_sku: "SPE_E3"  # Microsoft 365 E3
groups: ["All-Staff", "IT-Department", "VPN-Users"]
```

## Centres d'administration utilisés
- 🔹 Microsoft 365 Admin Center (admin.microsoft.com)
- 🔹 Azure AD Admin Center (aad.portal.azure.com)
- 🔹 Exchange Admin Center (admin.exchange.microsoft.com)
- 🔹 SharePoint Admin Center (tenant-admin.sharepoint.com)
- 🔹 Teams Admin Center (admin.teams.microsoft.com)
- 🔹 Security & Compliance Center (compliance.microsoft.com)

## Étapes d'exécution

### 1. Création du compte utilisateur
**Durée:** 5 minutes  
**Centre:** Microsoft 365 Admin Center

**Actions PowerShell:**
```powershell
# Se connecter à Microsoft 365
Connect-MsolService

# Créer l'utilisateur
$password = Read-Host -AsSecureString "Entrer mot de passe temporaire"
New-MsolUser -UserPrincipalName $user_upn `
    -FirstName $user_first_name `
    -LastName $user_last_name `
    -DisplayName "$user_first_name $user_last_name" `
    -Title $job_title `
    -Department $department `
    -Office $office_location `
    -Password $password `
    -ForceChangePassword $true `
    -UsageLocation "CA"

# Assigner licence
Set-MsolUserLicense -UserPrincipalName $user_upn -AddLicenses "company:$license_sku"

# Définir le manager
Set-AzureADUserManager -ObjectId $user_upn -RefObjectId (Get-AzureADUser -ObjectId $manager_upn).ObjectId
```

**Via portail:**
1. Aller à admin.microsoft.com
2. Users → Active users → Add a user
3. Remplir informations de base
4. Sélectionner licence Microsoft 365 E3
5. Définir profile info (job title, department, manager)
6. Créer avec mot de passe temporaire

**Validation:**
- [ ] Compte créé avec succès
- [ ] Licence assignée
- [ ] Manager défini
- [ ] Mot de passe temporaire généré

### 2. Configuration Exchange Online
**Durée:** 5 minutes  
**Centre:** Exchange Admin Center

**Actions PowerShell:**
```powershell
# Se connecter à Exchange Online
Connect-ExchangeOnline

# Créer boîte aux lettres (auto-créée avec licence)
# Vérifier statut
Get-Mailbox -Identity $user_upn | Select-Object DisplayName, PrimarySmtpAddress

# Configurer quota de boîte
Set-Mailbox -Identity $user_upn `
    -IssueWarningQuota 45GB `
    -ProhibitSendQuota 48GB `
    -ProhibitSendReceiveQuota 50GB

# Activer archive en ligne
Enable-Mailbox -Identity $user_upn -Archive

# Configurer signature automatique (via template)
# Note: Nécessite solution tierce ou GPO

# Ajouter à listes de distribution
Add-DistributionGroupMember -Identity "All-Staff@company.com" -Member $user_upn
Add-DistributionGroupMember -Identity "IT-Department@company.com" -Member $user_upn

# Configurer délégation si nécessaire
# Add-MailboxPermission -Identity "shared@company.com" -User $user_upn -AccessRights FullAccess
```

**Via portail:**
1. Aller à admin.exchange.microsoft.com
2. Recipients → Mailboxes → Vérifier création boîte
3. Ouvrir boîte → Storage → Configurer quotas
4. Archive → Enable archive
5. Groups → Ajouter aux DL appropriées

**Validation:**
- [ ] Boîte aux lettres active
- [ ] Archive activée
- [ ] Quotas configurés
- [ ] Ajouté aux DL requises

### 3. Configuration Azure AD & Sécurité
**Durée:** 5 minutes  
**Centre:** Azure AD Admin Center

**Actions PowerShell:**
```powershell
# Se connecter à Azure AD
Connect-AzureAD

# Ajouter aux groupes de sécurité
foreach ($group in $groups) {
    $groupObj = Get-AzureADGroup -Filter "DisplayName eq '$group'"
    Add-AzureADGroupMember -ObjectId $groupObj.ObjectId -RefObjectId (Get-AzureADUser -ObjectId $user_upn).ObjectId
}

# Activer MFA (si non activé par Conditional Access)
$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enabled"
$sta = @($st)
Set-MsolUser -UserPrincipalName $user_upn -StrongAuthenticationRequirements $sta

# Configurer méthodes d'authentification
# Via portail: Security → MFA → User settings
```

**Via portail:**
1. Aller à aad.portal.azure.com
2. Users → Sélectionner utilisateur
3. Groups → Add memberships → Ajouter All-Staff, IT-Department, VPN-Users
4. Authentication methods → Configure MFA
5. Devices → Vérifier Conditional Access policies appliquées

**Validation:**
- [ ] Ajouté à tous les groupes requis
- [ ] MFA activé
- [ ] Conditional Access appliqué
- [ ] Méthodes d'auth configurées

### 4. Configuration Teams & SharePoint
**Durée:** 5 minutes  
**Centre:** Teams Admin Center / SharePoint Admin Center

**Actions PowerShell:**
```powershell
# Se connecter à Teams
Connect-MicrosoftTeams

# Ajouter aux équipes
Add-TeamUser -GroupId "team-id-it-department" -User $user_upn -Role Member

# Configurer politique d'appel
Grant-CsTeamsCallingPolicy -Identity $user_upn -PolicyName "CanadaCallingPolicy"

# Configurer accès SharePoint
# Via SharePoint Admin Center ou site-specific
Connect-PnPOnline -Url "https://company.sharepoint.com/sites/IT-Department"
Add-PnPSiteCollectionAppCatalog
```

**Via portail:**
1. **Teams Admin Center** (admin.teams.microsoft.com):
   - Users → Sélectionner utilisateur
   - Policies → Assigner calling, messaging, meeting policies
   - Groups → Ajouter aux teams appropriées

2. **SharePoint Admin Center** (tenant-admin.sharepoint.com):
   - Active sites → Sélectionner site IT
   - Permissions → Add member
   - Ajouter utilisateur avec permissions appropriées

**Validation:**
- [ ] Ajouté aux Teams requises
- [ ] Policies Teams assignées
- [ ] Accès SharePoint configuré
- [ ] OneDrive provisionné

### 5. Configuration sécurité & compliance
**Durée:** 5 minutes  
**Centre:** Security & Compliance Center

**Actions:**
1. **Data Loss Prevention:**
   - Aller à compliance.microsoft.com
   - Policies → DLP → Vérifier que user est couvert
   
2. **Retention Policies:**
   - Information governance → Retention
   - Vérifier application des politiques de rétention

3. **Sensitivity Labels:**
   - Information protection → Labels
   - Publier labels au user si nécessaire

4. **Audit Logging:**
   - Vérifier que actions sont auditées
   ```powershell
   Search-UnifiedAuditLog -UserIds $user_upn -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)
   ```

**Validation:**
- [ ] DLP appliqué
- [ ] Retention policies actives
- [ ] Sensitivity labels disponibles
- [ ] Audit logging fonctionnel

### 6. Configuration complémentaire
**Durée:** 5 minutes

**Actions:**
```powershell
# Configurer langue et timezone
Set-MailboxRegionalConfiguration -Identity $user_upn `
    -Language "fr-CA" `
    -DateFormat "dd/MM/yyyy" `
    -TimeFormat "HH:mm" `
    -TimeZone "Eastern Standard Time"

# Configurer signature email via template
# [Nécessite solution tierce ou script custom]

# Configurer mobile device policy
Set-CASMailbox -Identity $user_upn -ActiveSyncEnabled $true

# Documenter dans CMDB
# [Via script ou manuel]
```

**Validation:**
- [ ] Langue et timezone configurées
- [ ] ActiveSync activé
- [ ] Mobile device policy appliquée

## Post-exécution

### Documentation
- [ ] Mettre à jour CMDB avec informations utilisateur
- [ ] Documenter groups et permissions
- [ ] Créer entrée dans système de tickets
- [ ] Notifier équipe IT

### Communication utilisateur

**Email de bienvenue à envoyer:**
```
Objet: Bienvenue chez [Entreprise] - Vos accès Microsoft 365

Bonjour Jean,

Bienvenue dans l'équipe! Voici vos informations de connexion:

📧 Email: jtremblay@company.com
🔐 Mot de passe temporaire: [fourni séparément]
🌐 Portail: https://portal.office.com

IMPORTANT: À votre première connexion, vous devrez:
1. Changer votre mot de passe
2. Configurer l'authentification multifacteur (MFA)
3. Installer Microsoft Authenticator sur votre téléphone

Applications disponibles:
✓ Outlook (email)
✓ Teams (messagerie, appels, réunions)
✓ SharePoint (documents partagés)
✓ OneDrive (stockage personnel - 1TB)
✓ Office Apps (Word, Excel, PowerPoint)

Ressources:
- Guide de démarrage: [lien intranet]
- Support IT: helpdesk@company.com
- Votre manager: Marie Lavoie (mlavoie@company.com)

Si vous avez des questions, n'hésitez pas à contacter le service IT.

Cordialement,
Équipe IT
```

### Handover au manager
- [ ] Notifier manager que compte est actif
- [ ] Confirmer permissions et groupes
- [ ] Planifier onboarding technique si nécessaire

## Tests de validation

### Checklist finale
```powershell
# Script de validation complet
$user = Get-MsolUser -UserPrincipalName $user_upn

Write-Host "=== VALIDATION COMPTE M365 ===" -ForegroundColor Green
Write-Host "Nom: $($user.DisplayName)"
Write-Host "UPN: $($user.UserPrincipalName)"
Write-Host "Licence: $(if($user.isLicensed){'✓ Assignée'}else{'✗ Manquante'})"
Write-Host "MFA: $(if($user.StrongAuthenticationRequirements){'✓ Activé'}else{'✗ Désactivé'})"

$mailbox = Get-Mailbox -Identity $user_upn
Write-Host "Boîte email: $(if($mailbox){'✓ Créée'}else{'✗ Manquante'})"
Write-Host "Archive: $(if($mailbox.ArchiveStatus -eq 'Active'){'✓ Activée'}else{'✗ Désactivée'})"

$groups = Get-AzureADUserMembership -ObjectId $user_upn
Write-Host "Groupes: $($groups.Count) groupes" -ForegroundColor Cyan
$groups | ForEach-Object { Write-Host "  - $($_.DisplayName)" }
```

**Résultat attendu:**
- ✓ Licence assignée
- ✓ MFA activé
- ✓ Boîte email créée
- ✓ Archive activée
- ✓ Minimum 3 groupes (All-Staff, IT-Department, VPN-Users)

## Rollback

En cas d'erreur ou annulation:

```powershell
# Désactiver le compte (soft delete)
Set-MsolUser -UserPrincipalName $user_upn -BlockCredential $true

# OU supprimer complètement (30 jours retention)
Remove-MsolUser -UserPrincipalName $user_upn -Force

# Récupérer licence
Set-MsolUserLicense -UserPrincipalName $user_upn -RemoveLicenses "company:$license_sku"

# Retirer des groupes
foreach ($group in $groups) {
    $groupObj = Get-AzureADGroup -Filter "DisplayName eq '$group'"
    Remove-AzureADGroupMember -ObjectId $groupObj.ObjectId -MemberId (Get-AzureADUser -ObjectId $user_upn).ObjectId
}
```

## Métriques de succès
- Temps d'onboarding < 30 minutes
- Aucune erreur durant provisionnement
- Utilisateur peut se connecter et utiliser services
- MFA configuré et fonctionnel
- Tous les groupes assignés

## Références
- [M365 User Management Best Practices](https://docs.microsoft.com/microsoft-365/admin/add-users/)
- [Azure AD Security Best Practices](https://docs.microsoft.com/azure/active-directory/fundamentals/identity-secure-score)
- Standards internes: `SHARED/IT-MSP/10_RUN/MEM-IT-Routing-Rules.md`

## Historique des modifications
| Date | Version | Auteur | Changements |
|------|---------|--------|-------------|
| 2026-02-10 | 1.0 | IT-CloudMaster | Création initiale |


---

## RB-CLOUD-004 — Asset Lifecycle — Cycle de vie des actifs IT

# RUNBOOK — IT_ASSET_LIFECYCLE_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Gestion du cycle de vie des assets (inventaire -> standard -> plan renouvellement)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-AssetMaster`
- Steps (ordre canon) :
  - **asset** → `IT-AssetMaster`
  - **softw** → `IT-SoftwMaster`
  - **report** → `IT-ReportMaster`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---
