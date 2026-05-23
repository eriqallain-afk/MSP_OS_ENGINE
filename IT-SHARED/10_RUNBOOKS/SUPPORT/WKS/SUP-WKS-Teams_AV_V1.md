# SUP-WKS-Teams_AV_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Résoudre les problèmes Teams et audio/vidéo — ne peut pas rejoindre réunion, pas de son, caméra absente, Teams qui plante.

## QUESTIONS DE TRIAGE

```
[ ] Teams ne démarre pas du tout ?
[ ] Peut ouvrir Teams mais pas rejoindre de réunion ?
[ ] Pas de son (micro / haut-parleurs) ?
[ ] Caméra non détectée ?
[ ] Teams très lent / bande passante ?
[ ] Problème sur ce seul poste ou plusieurs collègues ?
[ ] Dernière fois que ça fonctionnait ?
[ ] Version Teams : Classic ou New Teams ?
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC TEAMS ET AUDIO

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== VERSION TEAMS ==="
$teamsPath = @(
    "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe",
    "$env:LOCALAPPDATA\Microsoft\TeamsMeetingAddin\*\*\Microsoft.Teams.AddinLoader.dll"
)
$teamsInstall = $teamsPath | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($teamsInstall) {
    $ver = (Get-Item $teamsInstall -EA SilentlyContinue).VersionInfo
    Write-Output "Teams Classic : $($ver.FileVersion) — $teamsInstall"
} else {
    Write-Output "Teams Classic non détecté — vérifier New Teams (MSIX)"
}

# New Teams (MSIX)
$newTeams = Get-AppxPackage -Name "MSTeams" -EA SilentlyContinue
if ($newTeams) {
    Write-Output "New Teams : $($newTeams.Version) — $($newTeams.PackageFamilyName)"
}

Write-Output ""
Write-Output "=== PROCESSUS TEAMS EN COURS ==="
Get-Process Teams -EA SilentlyContinue | Select-Object Name, Id, CPU, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,0)}}, Responding |
    Out-String -Width 300 | Write-Output

Write-Output "=== PÉRIPHÉRIQUES AUDIO ==="
try {
    $audio = Get-CimInstance -Namespace root\wmi -ClassName MSAudio_HardwareDeviceInfo -EA SilentlyContinue
    if ($audio) {
        $audio | Select-Object InstanceName, Active | Out-String -Width 300 | Write-Output
    } else {
        Write-Output "Périphériques audio via WMI non disponibles — vérification alternative :"
        Get-PnpDevice -Class "Media" -EA SilentlyContinue | Select-Object Status, FriendlyName, InstanceId |
            Out-String -Width 300 | Write-Output
    }
} catch {
    Write-Output "Erreur lecture audio : $_"
}

Write-Output "=== CAMÉRAS ==="
Get-PnpDevice -Class "Camera","Image" -EA SilentlyContinue | Select-Object Status, FriendlyName, InstanceId |
    Out-String -Width 300 | Write-Output

Write-Output "=== PILOTES AUDIO/VIDÉO (récents / problèmes) ==="
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddDays(-7)} -MaxEvents 200 -EA SilentlyContinue |
    Where-Object { $_.LevelDisplayName -eq 'Erreur' -and ($_.ProviderName -like "*audio*" -or $_.ProviderName -like "*KSCAMERA*" -or $_.ProviderName -like "*HDAudio*") } |
    Select-Object TimeCreated, ProviderName, Message |
    Out-String -Width 300 | Write-Output

Write-Output "=== TEST CONNECTIVITÉ TEAMS (endpoints M365) ==="
$endpoints = @("teams.microsoft.com","login.microsoftonline.com","statics.teams.cdn.office.net")
foreach ($ep in $endpoints) {
    $test = Test-NetConnection $ep -Port 443 -InformationLevel Quiet -EA SilentlyContinue
    Write-Output "  $ep`:443 — $(if ($test) { 'OK' } else { 'ÉCHEC ⛔' })"
}

Write-Output "=== FIN DIAGNOSTIC ==="
```

---

## SECTION 2 — SCRIPT NETTOYAGE CACHE TEAMS

> ⚠️ Teams doit être complètement fermé. Valider avec l'utilisateur — il sera déconnecté.

```powershell
#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== FERMETURE TEAMS ==="
Get-Process Teams -EA SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

Write-Output "=== NETTOYAGE CACHE TEAMS CLASSIC ==="
$cacheTeams = "$env:APPDATA\Microsoft\Teams"
$cacheDirs = @("Cache","Code Cache","blob_storage","databases","GPUCache","IndexedDB","Local Storage","tmp")
$freed = 0
foreach ($dir in $cacheDirs) {
    $p = Join-Path $cacheTeams $dir
    if (Test-Path $p) {
        $size = (Get-ChildItem $p -Recurse -EA SilentlyContinue | Measure-Object Length -Sum).Sum
        Remove-Item $p -Recurse -Force -EA SilentlyContinue
        $freed += $size
        Write-Output "Supprimé : $p ($([math]::Round($size/1MB,0)) MB)"
    }
}
Write-Output "Total libéré : $([math]::Round($freed/1MB,0)) MB"
Write-Output "Relancer Teams manuellement."
```

---

## SECTION 3 — ACTIONS PAR SCÉNARIO

| Symptôme | Action N2 |
|---|---|
| Teams ne démarre pas | Vider le cache (Section 2) → réparer/réinstaller si persiste |
| Pas de son en réunion | Vérifier périphérique par défaut dans Teams (Paramètres > Appareils) et dans Windows (Sons) |
| Micro ne fonctionne pas | Vérifier permissions micro : Paramètres Windows > Confidentialité > Microphone → Teams = Autorisé |
| Caméra non détectée | Vérifier permissions caméra Windows + pilote PnP → Device Manager |
| Teams très lent | Vérifier bande passante (speedtest), fermer onglets SharePoint lourds, réduire qualité vidéo |
| Erreur "Impossible de rejoindre" | Vérifier date/heure poste (décalage NTP = auth fail), vérifier proxies |
| Réunions Teams impossible depuis Outlook | Vérifier complément Teams dans Outlook (Section 1 add-ins) |

---

## SECTION 4 — LIVRABLE CW

```text
CW NOTE INTERNE — Problème Teams / Audio-Vidéo
Runbook utilisé : SUP-WKS-Teams_AV_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [À CONFIRMER]
Version Teams : [Classic / New]
Symptôme : [ne démarre pas / pas de son / caméra / lent]

DIAGNOSTIC :
Périphérique audio détecté : [Oui / Non]
Caméra détectée : [Oui / Non]
Connectivité teams.microsoft.com : [OK / ÉCHEC]

ACTIONS :
[ ] Cache Teams vidé
[ ] Permissions micro/caméra vérifiées
[ ] Périphérique audio par défaut reconfiguré
[ ] Réinstallation Teams

RÉSULTAT : [Résolu / Escalade]

→ Décision suivante : [raison]
```

---

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Problème sur plusieurs postes simultanément | IT-Assistant-N3 (Exchange/Teams Online) | Selon SLA |
| Endpoints Teams bloqués (firewall/proxy) | IT-NetworkMaster | Selon SLA |
| Status.office365.com indique incident actif | Informer le client et attendre | N/A |

*SUP-WKS-Teams_AV_V1 — 2026-05-22*
