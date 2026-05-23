# RB-001 — Diagnostic Exchange Online et Entra ID
**Agent :** IT-CloudMaster | **Usage :** Incident M365 entrant

## Exchange — Tracer un message
```powershell
Connect-ExchangeOnline -UserPrincipalName <ADMIN_UPN>.com
Get-MessageTrace -SenderAddress "exp@dom.com" -RecipientAddress "dest@dom.com" `
    -StartDate (Get-Date).AddDays(-2) -EndDate (Get-Date) | Select-Object Received,Status
# Règles Outlook suspectes — escalade SOC si transfert externe
Get-InboxRule -Mailbox "user@domaine.com" |
    Select-Object Name,Enabled,ForwardTo,DeleteMessage | Format-List
```

## Entra ID — Connexions suspectes
```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All"
Get-MgAuditLogSignIn -Filter "userPrincipalName eq 'user@dom.com'" -Top 20 |
    Select-Object CreatedDateTime,IpAddress,Location | Format-Table
# Désactiver + révoquer (compte compromis)
Update-MgUser -UserId $userId -AccountEnabled $false
Revoke-MgUserSignInSession -UserId $userId
```

## Réinitialiser OneDrive
```powershell
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset
```