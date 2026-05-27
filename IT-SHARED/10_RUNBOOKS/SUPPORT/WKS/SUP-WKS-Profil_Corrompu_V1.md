# SUP-WKS-Profil_Corrompu_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2 | @IT-TechOnsite
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Diagnostiquer et réparer un profil utilisateur Windows corrompu — paramètres qui disparaissent, profil temporaire au logon, bureau vide, erreur "profil de service utilisateur".

## QUESTIONS DE TRIAGE

```
[ ] Message à la connexion : "Le service profil utilisateur..." ?
[ ] L'utilisateur arrive sur un profil temporaire ou le bureau est vide ?
[ ] Les paramètres/favoris/fichiers bureau disparaissent après déconnexion ?
[ ] Problème depuis quand ? Suite à une mise à jour ? Un crash ?
[ ] Le problème est sur un seul poste ou tous les postes de l'utilisateur ?
[ ] L'utilisateur a-t-il des données importantes sur le Bureau / Documents locaux ?
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC PROFIL

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== PROFILS UTILISATEURS EXISTANTS ==="
$profiles = Get-CimInstance Win32_UserProfile | Where-Object { -not $_.Special }
$profiles | ForEach-Object {
    try {
        $sid = $_.SID
        $path = $_.LocalPath
        $lastUse = $_.LastUseTime
        $loaded = $_.Loaded
        $size = if (Test-Path $path) { [math]::Round((Get-ChildItem $path -Recurse -EA SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB, 0) } else { "N/A" }

        [pscustomobject]@{
            Chemin    = $path
            SID       = $sid
            Chargé    = $loaded
            DernierUse = $lastUse
            TailleMB  = $size
            NTUSER    = if (Test-Path "$path\NTUSER.DAT") { "Présent" } else { "MANQUANT ⛔" }
        }
    } catch {}
} | Out-String -Width 300 | Write-Output

Write-Output "=== ENTRÉES REGISTRE ProfileList ==="
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | ForEach-Object {
    $props = Get-ItemProperty $_.PSPath -EA SilentlyContinue
    [pscustomobject]@{
        SID         = $_.PSChildName
        ProfilePath = $props.ProfileImagePath
        State       = $props.State
        RefCount    = $props.RefCount
        Backup      = $props.ProfileImagePath -match "\.bak$"
    }
} | Out-String -Width 300 | Write-Output

Write-Output "=== DOUBLONS .BAK (signe de corruption) ==="
$bakProfiles = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" |
    Where-Object { $_.PSChildName -match "\.bak$" }
if ($bakProfiles) {
    Write-Output "⛔ PROFILS .BAK DÉTECTÉS — signe de corruption :"
    $bakProfiles | ForEach-Object {
        Write-Output "  SID .bak : $($_.PSChildName)"
        $props = Get-ItemProperty $_.PSPath
        Write-Output "  Chemin : $($props.ProfileImagePath)"
    }
} else {
    Write-Output "Aucun doublon .bak détecté."
}

Write-Output "=== ERREURS PROFIL RÉCENTES ==="
Get-WinEvent -FilterHashtable @{LogName='Application'; ProviderName='Microsoft-Windows-User Profiles Service','Microsoft-Windows-User Profiles General'; StartTime=(Get-Date).AddDays(-7)} -MaxEvents 20 -EA SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Out-String -Width 300 | Write-Output

Write-Output "=== FIN DIAGNOSTIC ==="
```

---

## SECTION 2 — RÉPARATION PROFIL .BAK

> ⚠️ Sauvegarder les données utilisateur AVANT toute intervention (Section 3).

```powershell
#Requires -Version 5.1
# Réparation profil corrompu via clés .bak dans le registre
# À exécuter avec l'utilisateur DÉCONNECTÉ du poste
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param([Parameter(Mandatory)][string]$UserSID)
# Ex: $UserSID = "S-1-5-21-XXXX-XXXX-XXXX-1001"

$profileListPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$sidPath    = "$profileListPath\$UserSID"
$sidBakPath = "$profileListPath\$UserSID.bak"

if (Test-Path $sidBakPath) {
    Write-Output "Doublon .bak trouvé — procédure de réparation :"

    if (Test-Path $sidPath) {
        Write-Output "Suppression de la clé corrompue sans .bak..."
        Remove-Item $sidPath -Force
        Write-Output "Clé supprimée : $sidPath"
    }

    Write-Output "Renommage $UserSID.bak → $UserSID..."
    Rename-Item $sidBakPath $UserSID
    Write-Output "Clé renommée. Vérification :"
    Get-ItemProperty "$profileListPath\$UserSID" | Select-Object ProfileImagePath, State, RefCount |
        Out-String -Width 300 | Write-Output

    Write-Output "✅ Réparation terminée. Demander à l'utilisateur de se reconnecter."
} elseif (Test-Path $sidPath) {
    Write-Output "Pas de .bak détecté. Vérification State de la clé existante :"
    $props = Get-ItemProperty $sidPath
    Write-Output "State : $($props.State) (0 = OK, 1024 = temporaire)"
    if ($props.State -ne 0) {
        Set-ItemProperty $sidPath -Name State -Value 0
        Write-Output "State corrigé à 0."
    }
} else {
    Write-Output "SID '$UserSID' non trouvé dans ProfileList."
}
```

---

## SECTION 3 — SAUVEGARDE DONNÉES PROFIL AVANT INTERVENTION

```powershell
#Requires -Version 5.1
# Sauvegarder les données critiques du profil avant suppression/recréation
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

param(
    [Parameter(Mandatory)][string]$UserProfilePath,   # Ex: C:\Users\jsmith
    [Parameter(Mandatory)][string]$BackupDestination  # Ex: \\SRV-FILES\Backups\Profils
)

$BackupPath = Join-Path $BackupDestination "$(Split-Path $UserProfilePath -Leaf)_backup_$(Get-Date -Format 'yyyyMMdd_HHmm')"
New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

$folders = @("Desktop","Documents","Downloads","Pictures","Favorites","AppData\Roaming\Microsoft\Signatures")
foreach ($folder in $folders) {
    $src = Join-Path $UserProfilePath $folder
    if (Test-Path $src) {
        $dst = Join-Path $BackupPath $folder
        Copy-Item $src $dst -Recurse -Force -EA SilentlyContinue
        Write-Output "Sauvegardé : $folder → $dst"
    }
}

$size = [math]::Round((Get-ChildItem $BackupPath -Recurse -EA SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB, 0)
Write-Output "Sauvegarde terminée : $BackupPath ($size MB)"
```

---

## SECTION 4 — SCÉNARIO : PROFIL TEMPORAIRE À CHAQUE CONNEXION

**Causes fréquentes :**
- Fichier `NTUSER.DAT` verrouillé ou corrompu
- Clé `.bak` en doublon dans ProfileList (Section 2)
- Disque plein : pas assez d'espace pour charger le profil

**Étapes :**
1. Diagnostiquer (Section 1) → identifier le SID et si .bak présent
2. S'assurer que l'espace disque est suffisant (>500 MB minimum sur C:)
3. Réparer la clé .bak (Section 2) si applicable
4. Sauvegarder les données (Section 3)
5. Si réparation impossible → créer un nouveau profil local ou forcer la resynchronisation du profil itinérant

---

## LIVRABLE CW

```text
CW NOTE INTERNE — Profil utilisateur corrompu
Runbook utilisé : SUP-WKS-Profil_Corrompu_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [À CONFIRMER]
Symptôme : [profil temporaire / paramètres disparus / erreur profil]

DIAGNOSTIC :
Doublon .bak détecté : [Oui / Non]
NTUSER.DAT présent : [Oui / Non]
Espace disque C: : [% libre]

ACTIONS :
[ ] Données sauvegardées vers [chemin]
[ ] Clé .bak réparée dans ProfileList
[ ] Nouveau profil créé

RÉSULTAT : [Résolu / Escalade]

→ Décision suivante : [raison]
```

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Profil itinérant (Roaming Profile) corrompu | IT-SysAdmin | Selon SLA |
| NTUSER.DAT corrompu et données critiques à récupérer | IT-Assistant-N3 | Selon urgence |
| Plusieurs utilisateurs affectés sur même poste | IT-SysAdmin (profil partagé ou GPO) | Priorité |

*SUP-WKS-Profil_Corrompu_V1 — 2026-05-22*
