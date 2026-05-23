# REFERENCE — Scripts PowerShell FrontLine (lecture seule en priorité)

## Diagnostic compte AD

```powershell
# Vérifier état compte — LECTURE SEULE
Get-ADUser "[username]" -Properties LockedOut,PasswordExpired,Enabled,LastLogonDate |
  Select-Object Name,SamAccountName,Enabled,LockedOut,PasswordExpired,LastLogonDate
```

## Actions compte AD (après vérification identité)

```powershell
# Déverrouiller
Unlock-ADAccount -Identity "[username]"

# Réinitialiser MDP
Set-ADAccountPassword "[username]" -Reset -NewPassword (Read-Host -AsSecureString)
Set-ADUser "[username]" -ChangePasswordAtLogon $true

# Vérifier groupes
Get-ADUser "[username]" -Properties MemberOf | Select-Object -ExpandProperty MemberOf

# Ajouter au groupe
Add-ADGroupMember -Identity "[GROUPE_AD]" -Members "[username]"
```

## Lecteur réseau

```powershell
# Mapper lecteur
net use [LETTRE]: \\[SERVEUR]\[PARTAGE] /persistent:yes

# Vérifier mappage actuel
net use
```

## Imprimante — file bloquée

```powershell
# Redémarrer le spouleur et vider la file
Restart-Service Spooler -Force
Get-PrintJob -PrinterName * | Remove-PrintJob

# Test connectivité imprimante réseau
Test-NetConnection [IP_IMPRIMANTE] -Port 9100
```

## Outlook

```powershell
# Mode sans échec — depuis Exécuter (Win+R)
outlook.exe /safe

# Nettoyer profil
outlook.exe /cleanprofile

# Localiser le fichier OST
# %appdata%\Microsoft\Outlook\
```

## VPN L2TP — Erreur 789

```powershell
# Fix registre (admin requis — redémarrage requis après)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" `
  /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 2 /f
# → Redémarrer le poste
```

## Diagnostic poste lent

```powershell
# Processus consommateurs CPU (lecture seule)
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name,CPU,Id,Path

# Arrêter Windows Update temporairement
net stop wuauserv
# Reprendre :
net start wuauserv
```

## Test connectivité réseau

```powershell
# Connexion Internet
ping 8.8.8.8 -n 4

# Test port spécifique
Test-NetConnection [HOTE] -Port [PORT]
```

> **Règle absolue :** Toujours lecture seule en premier. Aucune action corrective sans diagnostic préalable.
