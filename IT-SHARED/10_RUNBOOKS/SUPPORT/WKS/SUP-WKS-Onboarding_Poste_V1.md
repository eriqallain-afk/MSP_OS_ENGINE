# SUP-WKS-Onboarding_Poste_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2 | @IT-TechOnsite
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Valider qu'un nouveau poste est prêt avant remise à l'utilisateur — jonction domaine, applications, accès, imprimantes, email.

> Pour le déploiement et la configuration complète → runbook TechOPS `/start deploiement`.

## PRÉREQUIS

```
[ ] Image OS appliquée et activée
[ ] Poste joint au domaine AD ou Azure AD (selon politique client)
[ ] Nom du poste conforme aux standards client (ex: WKS-NOM-001)
[ ] Compte utilisateur AD/Entra créé et actif
[ ] Liste des applications à installer fournie
[ ] Lecteurs réseau à mapper fournis
[ ] Imprimantes à configurer identifiées
```

---

## SECTION 1 — SCRIPT VALIDATION POST-DÉPLOIEMENT

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== HÔTE / OS / ACTIVATION ==="
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    OS          = $os.Caption
    Version     = $os.Version
    Architecture = $os.OSArchitecture
    Domaine     = $cs.Domain
    JointDomaine = $cs.PartOfDomain
    RAM_GB      = [math]::Round($cs.TotalPhysicalMemory/1GB, 1)
    LastBoot    = $os.LastBootUpTime
} | Out-String -Width 300 | Write-Output

Write-Output "=== ACTIVATION WINDOWS ==="
try {
    $lic = Get-CimInstance SoftwareLicensingProduct -Filter "ApplicationId='55c92734-d682-4d71-983e-d6ec3f16059f' AND LicenseStatus=1" -EA Stop
    if ($lic) { Write-Output "Windows activé ✓ | $($lic.Name)" } else { Write-Output "⛔ Windows NON ACTIVÉ" }
} catch {
    Write-Output "Vérification activation : $((cscript.exe /nologo "$env:WINDIR\System32\slmgr.vbs" /xpr 2>&1) -join '')"
}

Write-Output "=== JONCTION DOMAINE / AZURE AD ==="
dsregcmd /status 2>&1 | Select-String "AzureAdJoined|DomainJoined|WorkplaceJoined|TenantId" |
    Out-String -Width 300 | Write-Output

Write-Output "=== APPLICATIONS INSTALLÉES ==="
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                  "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -EA SilentlyContinue |
    Where-Object { $_.DisplayName -and -not $_.SystemComponent } |
    Select-Object DisplayName, DisplayVersion, InstallDate |
    Sort-Object DisplayName |
    Out-String -Width 300 | Write-Output

Write-Output "=== ANTIVIRUS / EDR ==="
Get-CimInstance -Namespace root\SecurityCenter2 -ClassName AntiVirusProduct -EA SilentlyContinue |
    Select-Object DisplayName, productState | Out-String -Width 300 | Write-Output

Write-Output "=== AGENT RMM ==="
$rmmAgents = @("N-able Agent","CW Automate Agent","Acronis","SolarWinds","Kaseya","ConnectWise Automate")
$installed = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                               "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -EA SilentlyContinue |
    Where-Object { $rmmAgents | ForEach-Object { $_.DisplayName -like "*$_*" } | Where-Object { $_ } }
if ($installed) {
    $installed | Select-Object DisplayName, DisplayVersion | Out-String -Width 300 | Write-Output
} else {
    Write-Output "⚠️ Aucun agent RMM reconnu détecté — vérifier manuellement."
}

Write-Output "=== OFFICE / M365 ==="
$officeKey = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
if (Test-Path $officeKey) {
    Get-ItemProperty $officeKey | Select-Object ProductReleaseIds, VersionToReport, UpdateChannel |
        Out-String -Width 300 | Write-Output
} else {
    Write-Output "Office Click-to-Run non détecté — vérifier installation."
}

Write-Output "=== DISQUES ==="
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    [pscustomobject]@{
        Lecteur = $_.DeviceID
        TotalGB = [math]::Round($_.Size/1GB,1)
        LibreGB = [math]::Round($_.FreeSpace/1GB,1)
        "Libre%" = [math]::Round(($_.FreeSpace/$_.Size)*100,0)
    }
} | Out-String -Width 300 | Write-Output

Write-Output "=== MISES À JOUR WINDOWS EN ATTENTE ==="
try {
    $wu = New-Object -ComObject Microsoft.Update.Session
    $result = $wu.CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    Write-Output "MàJ en attente : $($result.Updates.Count)"
    $result.Updates | Select-Object -First 10 | ForEach-Object { Write-Output "  - $($_.Title)" }
} catch {
    Write-Output "Vérification WU non disponible."
}

Write-Output "=== FIN VALIDATION ==="
```

---

## SECTION 2 — CHECKLIST VALIDATION UTILISATEUR

```
VALIDATION AVEC L'UTILISATEUR (en présence ou via session à distance)

Accès et identité
[ ] Connexion Windows avec le compte de l'utilisateur — OK
[ ] Mot de passe doit être changé au premier logon — OK
[ ] MFA configuré (si applicable)

Applications
[ ] Outlook configuré et reçoit les emails
[ ] Teams connecté et fonctionnel
[ ] Applications métier installées et accessibles
[ ] Navigateur configuré (favoris, page d'accueil)

Réseau et accès
[ ] Lecteurs réseau mappés et accessibles
[ ] Imprimante(s) installée(s) et test d'impression OK
[ ] VPN configuré et testé (si télétravail)
[ ] OneDrive/SharePoint synchronisé

Sécurité
[ ] AV/EDR actif et à jour
[ ] Agent RMM visible dans le RMM
[ ] BitLocker activé (si politique client)
[ ] Chiffrement confirmé : manage-bde -status C:
```

---

## LIVRABLE CW

```text
CW NOTE INTERNE — Onboarding nouveau poste
Runbook utilisé : SUP-WKS-Onboarding_Poste_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [Hostname]
Date remise : [Date]

VALIDATION :
OS activé : [Oui / Non]
Joint au domaine : [AD / Azure AD / Non]
Office / M365 : [Version]
AV/EDR : [Nom + actif]
Agent RMM : [Visible / Non]

APPLICATIONS INSTALLÉES : [liste]
LECTEURS MAPPÉS : [liste]
IMPRIMANTES : [liste]
VPN : [Configuré / N-A]

VALIDATION UTILISATEUR : [Oui — utilisateur confirme bon fonctionnement]
```

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Jonction domaine impossible | IT-SysAdmin | Avant remise |
| Licences manquantes (Office, AV) | IT-AssetMaster | Avant remise |
| Azure AD / Intune enrollment bloqué | IT-CloudMaster | Avant remise |

*SUP-WKS-Onboarding_Poste_V1 — 2026-05-22*
