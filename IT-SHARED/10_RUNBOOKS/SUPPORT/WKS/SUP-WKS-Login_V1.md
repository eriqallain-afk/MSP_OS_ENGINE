# SUP-WKS-Login_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2 | @IT-TechOPS
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Résoudre ou clarifier rapidement un problème de connexion Windows / Azure AD / M365.

## QUESTIONS DE TRIAGE

```
[ ] Problème à l'ouverture de session Windows ?
[ ] Problème dans Outlook / M365 / Teams seulement ?
[ ] Problème sur VPN uniquement ?
[ ] Message d'erreur exact ? (faire dicter ou envoyer capture)
[ ] Compte hybride AD + Azure AD ?
[ ] Nouveau téléphone ou nouvel appareil récemment ?
[ ] Changement de mot de passe récent ?
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC COMPTE AD
> Exécuter depuis un poste avec RSAT ou depuis un DC via RMM.

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
# Prérequis : module ActiveDirectory (RSAT ou DC)
param([Parameter(Mandatory)][string]$Username)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== ÉTAT DU COMPTE AD : $Username ==="
try {
    $props = @('Name','SamAccountName','Enabled','LockedOut','BadLogonCount',
               'BadPasswordTime','PasswordExpired','PasswordLastSet','PasswordNeverExpires',
               'LastLogonDate','LastLogon','AccountExpirationDate','DistinguishedName')
    $user = Get-ADUser $Username -Properties $props -EA Stop

    [pscustomobject]@{
        Nom               = $user.Name
        SamAccountName    = $user.SamAccountName
        Actif             = $user.Enabled
        Verrouillé        = $user.LockedOut
        MauvaisTentatives = $user.BadLogonCount
        DerniereMauvaisePW = if ($user.BadPasswordTime -gt 0) { [datetime]::FromFileTime($user.BadPasswordTime) } else { "N/A" }
        MDP_Expiré        = $user.PasswordExpired
        MDP_ChangéLe      = $user.PasswordLastSet
        MDP_NExpirePas    = $user.PasswordNeverExpires
        DernièreConnexion = $user.LastLogonDate
        Expiration        = if ($user.AccountExpirationDate) { $user.AccountExpirationDate } else { "Aucune" }
        OU                = ($user.DistinguishedName -replace '^CN=[^,]+,', '')
    } | Out-String -Width 300 | Write-Output
} catch {
    Write-Output "ERREUR : Impossible de lire le compte '$Username'. Module AD chargé ? $_"
}

Write-Output "=== GROUPES DU COMPTE ==="
try {
    Get-ADPrincipalGroupMembership $Username | Select-Object Name, GroupScope, GroupCategory |
        Sort-Object Name | Out-String -Width 300 | Write-Output
} catch {
    Write-Output "Impossible de lire les groupes : $_"
}
```

---

## SECTION 2 — SCRIPT DIAGNOSTIC CONNECTIVITÉ DOMAINE
> Exécuter sur le poste problématique via RMM.

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== INFO DOMAINE POSTE ==="
[pscustomobject]@{
    Hostname      = $env:COMPUTERNAME
    Domaine       = (Get-CimInstance Win32_ComputerSystem).Domain
    JointAuDomaine = (Get-CimInstance Win32_ComputerSystem).PartOfDomain
    AzureADJoint  = if ((dsregcmd /status 2>$null) -match "AzureAdJoined\s*:\s*YES") { "Oui" } else { "Non" }
    HybridJoint   = if ((dsregcmd /status 2>$null) -match "DomainJoined\s*:\s*YES") { "Oui" } else { "Non" }
} | Out-String -Width 300 | Write-Output

Write-Output "=== TEST CONNECTIVITÉ DC ==="
try {
    $domain = (Get-CimInstance Win32_ComputerSystem).Domain
    if ($domain -and $domain -ne "WORKGROUP") {
        $dc = (Resolve-DnsName "_ldap._tcp.$domain" -Type SRV -EA Stop | Select-Object -First 1).NameTarget
        $ping = Test-Connection $dc -Count 2 -EA SilentlyContinue
        [pscustomobject]@{
            DC_Name   = $dc
            Ping_OK   = if ($ping) { "OUI ($([math]::Round(($ping | Measure-Object ResponseTime -Average).Average,0)) ms)" } else { "ÉCHEC ⛔" }
        } | Out-String -Width 300 | Write-Output

        Write-Output "Test netlogon (nltest) :"
        nltest /sc_verify:$domain 2>&1 | Out-String -Width 300 | Write-Output
    } else {
        Write-Output "Poste en WORKGROUP ou domaine non détecté."
    }
} catch {
    Write-Output "Erreur résolution DC : $_"
}

Write-Output "=== DSREGCMD STATUS ==="
dsregcmd /status 2>&1 | Select-String "AzureAdJoined|DomainJoined|WorkplaceJoined|SSO|TenantId|Device" |
    Out-String -Width 300 | Write-Output

Write-Output "=== DERNIÈRES ERREURS CONNEXION (EventLog) ==="
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 10 -EA SilentlyContinue |
    Select-Object TimeCreated, @{N="Compte";E={$_.Properties[5].Value}}, @{N="Raison";E={$_.Properties[9].Value}} |
    Out-String -Width 300 | Write-Output
```

---

## SECTION 3 — ACTIONS PAR SCÉNARIO

### A — Compte verrouillé AD

```powershell
param([Parameter(Mandatory)][string]$Username)
Unlock-ADAccount -Identity $Username
$user = Get-ADUser $Username -Properties LockedOut, BadLogonCount
Write-Output "Compte déverrouillé : $($user.Name) | LockedOut: $($user.LockedOut) | BadLogons: $($user.BadLogonCount)"
Write-Output "⚠️ Demander à l'utilisateur : appareils mobiles, tablettes, sessions ouvertes ailleurs avec l'ancien MDP ?"
```

### B — Réinitialisation mot de passe AD

```powershell
param(
    [Parameter(Mandatory)][string]$Username,
    [Parameter(Mandatory)][System.Security.SecureString]$NewPassword
)
Set-ADAccountPassword -Identity $Username -NewPassword $NewPassword -Reset
Set-ADUser -Identity $Username -ChangePasswordAtLogon $true
Unlock-ADAccount -Identity $Username
Write-Output "MDP réinitialisé et compte déverrouillé : $Username"
Write-Output "⚠️ Compte hybride : attendre ~30 min sync AzureAD. NE PAS reset M365 en plus — conflit garanti."
```

### C — Problème M365 / Office (token expiré)

```powershell
# À exécuter sur le poste de l'utilisateur
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== COMPTES OFFICE/AZURE CONNECTÉS ==="
$credPaths = @(
    "HKCU:\Software\Microsoft\Office\16.0\Common\Identity",
    "HKCU:\Software\Microsoft\Office\15.0\Common\Identity"
)
foreach ($p in $credPaths) {
    if (Test-Path $p) {
        Get-ItemProperty $p -EA SilentlyContinue | Out-String -Width 300 | Write-Output
    }
}

Write-Output "=== GESTIONNAIRE DE CREDENTIALS ==="
cmdkey /list 2>&1 | Select-String "MicrosoftOffice|MicrosoftTeams|graph|sharepoint|outlook" |
    Out-String -Width 300 | Write-Output

Write-Output "ACTION : Si entrées corrompues → supprimer les entrées MicrosoftOffice* dans Gestionnaire d'identifiants Windows."
Write-Output "Puis déconnecter/reconnecter le compte dans Paramètres > Comptes > Votre compte."
```

---

## SECTION 4 — SCÉNARIOS MFA / AZURE AD

| Situation | Action N2 | Escalade ? |
|---|---|---|
| MFA — téléphone perdu/changé | Réinitialiser MFA via portail M365 Admin (si accès) | Non si accès admin |
| MFA — impossible de s'authentifier | Désactiver temporairement le MFA ou fournir code de récupération | Selon droits |
| Conditional Access bloqué | Politique CA empêche la connexion (device non conforme, IP inconnue) | Escalade N3 — ne pas modifier CA |
| "Votre organisation a besoin de…" | Enrollment Intune requis | Escalade N3 / IT-CloudMaster |
| AzureAD join cassé | `dsregcmd /leave` puis rejoin (attention — données locales) | Valider avec N3 avant |

---

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Connexions suspectes / compte potentiellement compromis | IT-SecurityMaster | Immédiat |
| Conditional Access / politique non modifiable N2 | IT-Assistant-N3 | Selon SLA |
| Poste ne peut plus joindre le domaine | IT-SysAdmin | Selon urgence |
| MFA non réinitialisable via portail | IT-Assistant-N3 | Selon SLA |

*SUP-WKS-Login_V1 — 2026-05-22*
