# INFRA-M365-Exchange_Online_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__M365_Exchange_Online_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3, IT-CloudMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — Microsoft 365
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS ADMINISTRATION EXCHANGE

| Portail | URL |
|---|---|
| **Exchange Admin Center (EAC)** | https://admin.exchange.microsoft.com |
| **M365 Admin Center** | https://admin.microsoft.com |
| **Azure Portal (Entra ID)** | https://portal.azure.com |
| **PowerShell Exchange Online** | `Connect-ExchangeOnline -UserPrincipalName <ADMIN_UPN>.com` |

---

## 2. CONNEXION POWERSHELL EXCHANGE ONLINE

```powershell
# Installer le module si nécessaire (une seule fois)
Install-Module -Name ExchangeOnlineManagement -Force

# Connexion
Connect-ExchangeOnline -UserPrincipalName "<ADMIN_UPN>.com"

# Déconnexion après utilisation
Disconnect-ExchangeOnline -Confirm:$false
```

---

## 3. GESTION DES BOÎTES AUX LETTRES

### Créer une boîte aux lettres
```powershell
# ⚠️ Nécessite une licence Exchange Online assignée à l'utilisateur
# Assigner la licence dans M365 Admin → Users → Active Users → Licenses

# Créer un utilisateur avec boîte aux lettres
New-Mailbox -Name "Prénom Nom" -UserPrincipalName "prenom.nom@domaine.com" `
    -Password (Read-Host -AsSecureString) `
    -DisplayName "Prénom Nom" -FirstName "Prénom" -LastName "Nom"
```

### Boîte aux lettres partagée
```powershell
# Créer une boîte partagée (ne requiert pas de licence)
New-Mailbox -Shared -Name "info" -DisplayName "Info Général" `
    -Alias "info" -PrimarySmtpAddress "info@domaine.com"

# Donner accès à des utilisateurs
Add-MailboxPermission -Identity "info@domaine.com" -User "prenom.nom@domaine.com" `
    -AccessRights FullAccess -InheritanceType All -AutoMapping:$true

# Donner droit d'envoi
Add-RecipientPermission "info@domaine.com" -Trustee "prenom.nom@domaine.com" `
    -AccessRights SendAs -Confirm:$false
```

### Vérifier les permissions d'une boîte
```powershell
# Qui a accès à cette boîte ?
Get-MailboxPermission "info@domaine.com" | Where-Object {$_.User -notmatch "NT AUTHORITY"} |
    Select-Object Identity, User, AccessRights | Format-Table -AutoSize

# Droit SendAs
Get-RecipientPermission "info@domaine.com" | Where-Object {$_.Trustee -notmatch "NT AUTHORITY"}
```

---

## 4. DÉPANNAGE EMAIL — ENVOI/RÉCEPTION

### Tracer un message (Message Trace)
```
Exchange Admin Center → Mail flow → Message trace
→ Entrer : expéditeur, destinataire, plage de dates (max 10 jours)
→ Résultats : Delivered / Failed / Filtered / Pending

Via PowerShell :
Get-MessageTrace -SenderAddress "expediteur@domaine.com" `
    -RecipientAddress "destinataire@domaine.com" `
    -StartDate (Get-Date).AddDays(-2) -EndDate (Get-Date) |
    Select-Object Received, SenderAddress, RecipientAddress, Status | Format-Table
```

### Messages bloqués / en quarantaine
```
Security Admin Center (protection.office.com) → Review → Quarantine
→ Chercher les messages retenus
→ Libérer ou supprimer
```

---

## 5. VÉRIFICATION RÈGLES OUTLOOK SUSPECTES

```
⚠️ Action prioritaire en cas de compromission de compte
```

```powershell
# Voir toutes les règles Outlook d'un utilisateur
Get-InboxRule -Mailbox "utilisateur@domaine.com" |
    Select-Object Name, Enabled, Description, ForwardTo, ForwardAsAttachmentTo,
    RedirectTo, DeleteMessage, MoveToFolder | Format-List

# Supprimer une règle suspecte
Remove-InboxRule -Mailbox "utilisateur@domaine.com" -Identity "Nom de la règle"

# Voir les transferts automatiques (ForwardingSmtpAddress)
Get-Mailbox "utilisateur@domaine.com" | Select-Object DisplayName, ForwardingSmtpAddress, DeliverToMailboxAndForward

# Supprimer un transfert automatique suspect
Set-Mailbox "utilisateur@domaine.com" -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false
```

---

## 6. VÉRIFICATION ACTIVITÉ DE CONNEXION SUSPECTE

```powershell
# Voir les connexions récentes (30 jours)
Get-MailboxStatistics "utilisateur@domaine.com" |
    Select-Object LastLogonTime, LastUserActionTime | Format-List

# Audit log — connexions et actions sur la boîte
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) `
    -UserIds "utilisateur@domaine.com" -Operations "MailboxLogin,Send,Create" |
    Select-Object CreationDate, UserIds, Operations, AuditData | Format-Table
```

---

## 7. LISTES DE DISTRIBUTION ET GROUPES M365

```powershell
# Lister les membres d'un groupe
Get-DistributionGroupMember "NomGroupe@domaine.com" |
    Select-Object Name, PrimarySmtpAddress | Format-Table

# Ajouter un membre
Add-DistributionGroupMember -Identity "NomGroupe@domaine.com" -Member "utilisateur@domaine.com"

# Retirer un membre
Remove-DistributionGroupMember -Identity "NomGroupe@domaine.com" -Member "utilisateur@domaine.com" -Confirm:$false
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer une boîte aux lettres sans avoir vérifié les données importantes
⛔ NE JAMAIS désactiver le compte avant d'avoir transféré/archivé les données
   si requis par le client
⛔ NE JAMAIS envoyer des credentials de boîte partagée par email
⛔ NE PAS créer des règles de transfert vers des domaines externes sans approbation
⛔ NE JAMAIS modifier les connecteurs mail sans avoir testé en environnement de test
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Tous les utilisateurs ne reçoivent pas d'emails | NOC + TECH | Immédiat |
| Compte compromis avec règles de transfert suspectes | SOC | Immédiat |
| Queue mail bloquée (spam sortant) | SOC + TECH | Dans l'heure |
| Problème de licence Exchange (boîtes désactivées) | TECH | Dans l'heure |
