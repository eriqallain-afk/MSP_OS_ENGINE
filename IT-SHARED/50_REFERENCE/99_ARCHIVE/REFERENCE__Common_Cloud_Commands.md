# REFERENCE - Commandes Cloud Courantes

## Azure CLI (az)

### Authentification
```bash
# Login interactif
az login

# Login avec Service Principal
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
az login --service-principal -u APP_ID -p PASSWORD --tenant TENANT_ID

# Sélectionner subscription
az account set --subscription "SUBSCRIPTION_NAME"

# Lister subscriptions
az account list --output table
```

### Resource Groups
```bash
# Créer RG
az group create --name rg-prod-001 --location canadacentral

# Lister RGs
az group list --output table

# Supprimer RG (avec confirmation)
az group delete --name rg-dev-001 --yes --no-wait

# Verrouiller RG
az lock create --name DeleteLock --lock-type CanNotDelete --resource-group rg-prod-001
```

### Virtual Machines
```bash
# Lister VMs
az vm list --output table

# Démarrer VM
az vm start --resource-group rg-prod-001 --name vm-app-001

# Arrêter VM (deallocate pour arrêter facturation)
az vm deallocate --resource-group rg-prod-001 --name vm-app-001

# Resize VM
az vm resize --resource-group rg-prod-001 --name vm-app-001 --size Standard_D4s_v3

# Obtenir IP publique
az vm list-ip-addresses --resource-group rg-prod-001 --name vm-app-001 --output table
```

### Storage
```bash
# Créer Storage Account
az storage account create   --name stprod001   --resource-group rg-prod-001   --location canadacentral   --sku Standard_LRS

# Obtenir connection string
az storage account show-connection-string   --name stprod001   --resource-group rg-prod-001

# Créer container blob
az storage container create   --name backups   --account-name stprod001
```

### Networking
```bash
# Créer VNet
az network vnet create   --resource-group rg-prod-001   --name vnet-prod-001   --address-prefix [IP_CLIENTE]/16   --subnet-name subnet-app   --subnet-prefix [IP_CLIENTE]/24

# Créer NSG
az network nsg create   --resource-group rg-prod-001   --name nsg-app-001

# Ajouter NSG rule
az network nsg rule create   --resource-group rg-prod-001   --nsg-name nsg-app-001   --name AllowHTTPS   --priority 100   --source-address-prefixes '*'   --destination-port-ranges 443   --access Allow   --protocol Tcp
```

## Microsoft 365 (PowerShell)

### Exchange Online
```powershell
# Connexion
Connect-ExchangeOnline

# Lister mailboxes
Get-Mailbox -ResultSize Unlimited | Select DisplayName,PrimarySmtpAddress,@{N="Size";E={(Get-MailboxStatistics $_.Identity).TotalItemSize}}

# Créer mailbox partagée
New-Mailbox -Shared -Name "Support IT" -DisplayName "Support IT" -Alias supportit

# Ajouter permissions
Add-MailboxPermission -Identity "Support IT" -User user@domain.com -AccessRights FullAccess -InheritanceType All
Add-RecipientPermission -Identity "Support IT" -Trustee user@domain.com -AccessRights SendAs

# Mail flow rules
New-TransportRule -Name "Block Executable Attachments"   -AttachmentExtensionMatchesWords @("exe","bat","cmd","com","pif","scr","vbs")   -RejectMessageReasonText "Executable attachments blocked by policy"

# Recherche message
Get-MessageTrace -SenderAddress sender@external.com -RecipientAddress user@domain.com -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)
```

### SharePoint Online
```powershell
# Connexion
Connect-SPOService -Url https://tenant-admin.sharepoint.com

# Lister sites
Get-SPOSite | Select Url,Owner,StorageUsageCurrent,StorageQuota

# Créer site
New-SPOSite -Url https://tenant.sharepoint.com/sites/IT-Team   -Owner admin@domain.com   -StorageQuota 26214400   -Template "STS#3"

# Permissions
Set-SPOUser -Site https://tenant.sharepoint.com/sites/IT-Team   -LoginName user@domain.com   -Group "IT-Team Members"
```

### Teams
```powershell
# Connexion
Connect-MicrosoftTeams

# Lister équipes
Get-Team

# Créer équipe
New-Team -DisplayName "IT Support" -Description "Équipe support IT" -Visibility Private

# Ajouter membres
Add-TeamUser -GroupId <team-id> -User user@domain.com -Role Member

# Créer channel
New-TeamChannel -GroupId <team-id> -DisplayName "Incidents" -Description "Gestion incidents"
```

### Azure AD (Graph)
```powershell
# Connexion
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All"

# Lister utilisateurs
Get-MgUser -All | Select DisplayName,UserPrincipalName,AccountEnabled

# Créer utilisateur
$PasswordProfile = @{
    Password = "<TEMP_PASSWORD>!"
    ForceChangePasswordNextSignIn = $true
}

New-MgUser -DisplayName "Jean Tremblay"   -UserPrincipalName "jean.tremblay@domain.com"   -AccountEnabled   -PasswordProfile $PasswordProfile   -MailNickname "jean.tremblay"

# Réinitialiser MFA
Reset-MgUserAuthenticationMethodPassword -UserId user@domain.com
```

## AWS CLI

### Authentification
```bash
# Configurer credentials
aws configure

# Utiliser profil spécifique
aws s3 ls --profile prod

# Lister profils
aws configure list-profiles
```

### EC2
```bash
# Lister instances
aws ec2 describe-instances --output table

# Démarrer instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Arrêter instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Créer AMI
aws ec2 create-image --instance-id i-1234567890abcdef0 --name "Backup-$(date +%Y%m%d)"
```

### S3
```bash
# Lister buckets
aws s3 ls

# Copier fichiers
aws s3 cp file.txt s3://bucket-name/

# Sync directory
aws s3 sync ./local-folder s3://bucket-name/remote-folder

# Lifecycle policy
aws s3api put-bucket-lifecycle-configuration --bucket bucket-name --lifecycle-configuration file://lifecycle.json
```

## Google Workspace (gam)

### Utilisateurs
```bash
# Créer utilisateur
gam create user jean.tremblay@domain.com firstname Jean lastname Tremblay password <TEMP_PASSWORD>! changepassword on

# Lister utilisateurs
gam print users

# Suspendre utilisateur
gam update user jean.tremblay@domain.com suspended on

# Reset password
gam update user jean.tremblay@domain.com password NewP@ss123! changepassword on
```

### Groupes
```bash
# Créer groupe
gam create group it-team@domain.com name "IT Team" description "Équipe IT"

# Ajouter membre
gam update group it-team@domain.com add member jean.tremblay@domain.com

# Lister membres
gam print group-members group it-team@domain.com
```

### Gmail
```bash
# Créer alias
gam user jean.tremblay@domain.com add alias jtremblay@domain.com

# Délégation
gam user jean.tremblay@domain.com delegate to admin@domain.com

# Signature
gam user jean.tremblay@domain.com signature file signature.html
```

## Références rapides

### Codes de sortie communs
- 0: Succès
- 1: Erreur générale
- 2: Syntaxe invalide
- 126: Commande non exécutable
- 127: Commande non trouvée
- 130: Terminé par Ctrl+C

### Variables d'environnement utiles
```bash
# Azure
export AZURE_SUBSCRIPTION_ID="xxx"
export AZURE_RESOURCE_GROUP="rg-prod-001"

# AWS
export AWS_DEFAULT_REGION="ca-central-1"
export AWS_PROFILE="production"

# Proxies
export HTTP_PROXY="http://<PROXY_HOST>:8080"
export HTTPS_PROXY="http://<PROXY_HOST>:8080"
```
