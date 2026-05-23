# BUNDLE_KP_CloudMaster_V1
**Agent :** @IT-CloudMaster | **Mis à jour :** 2026-03-29 | IT-MaintenanceMaster | IT-SysAdmin

## COMMANDES M365 ESSENTIELLES

### Exchange Online — Triage
```powershell
# Tracer un message
Get-MessageTrace -SenderAddress "user@domain.com" -StartDate (Get-Date).AddHours(-24) -EndDate (Get-Date)
# Règles Outlook suspectes
Get-InboxRule -Mailbox "user@domain.com" | Where {$_.ForwardTo -or $_.DeleteMessage} | FL Name,ForwardTo,DeleteMessage
# Transfert automatique
Get-Mailbox "user@domain.com" | Select ForwardingSmtpAddress,DeliverToMailboxAndForward
# Supprimer transfert
Set-Mailbox "user@domain.com" -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false
```

### Entra ID — Compte compromis
```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All"
$uid = (Get-MgUser -Filter "UserPrincipalName eq 'user@domain.com'").Id
Update-MgUser -UserId $uid -AccountEnabled $false
Revoke-MgUserSignInSession -UserId $uid
# Consentements OAuth suspects
Get-MgUserOauth2PermissionGrant -UserId $uid | Select ClientId,Scope
```

### Intune — Appareil non conforme
```
Endpoint Manager → Devices → [device] → Compliance → détail non-conformité
Actions : Sync → Restart → Retire (si perdu/volé)
Wipe sélectif : supprime données corporate, conserve données perso
```

### KeepIT M365 — Backup cloud
```
Vérifier : Dashboard → Job status → dernière sauvegarde réussie
Restaurer : Browse → sélectionner mailbox/OneDrive/SharePoint → Restore
Rétention : vérifier politique (30j/90j/1an/illimité)
```

## PORTAILS DE RÉFÉRENCE
| Service | URL |
|---|---|
| Azure Portal | portal.azure.com |
| M365 Admin | admin.microsoft.com |
| Exchange Admin | admin.exchange.microsoft.com |
| Entra ID | entra.microsoft.com |
| Intune | intune.microsoft.com |
| Security | security.microsoft.com |
| Compliance | compliance.microsoft.com |
| Azure Status | status.azure.com |
| M365 Status | status.office365.com |

## ESCALADES
| Situation | Vers |
|---|---|
| VM Azure / VNet / ExpressRoute | @IT-Commandare-Infra |
| Incident sécurité M365 (breach, phishing) | @IT-SecurityMaster |
| Backup M365 en échec (KeepIT) | @IT-BackupDRMaster |

---
*BUNDLE_KP_CloudMaster_V1 — Version 1.0*
