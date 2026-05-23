# SUP-WKS-Alerte_AV_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Évaluer une alerte antivirus ou un comportement suspect sur un poste — décider si c'est un faux positif ou une menace réelle, et escalader immédiatement si nécessaire.

> ⚠️ **Ce runbook N2 couvre uniquement le TRIAGE initial.** Toute menace confirmée → escalade immédiate IT-SecurityMaster. NE PAS tenter de remédier une infection sans escalade.

## QUESTIONS DE TRIAGE

```
[ ] Alerte provenant du RMM, de l'AV, ou signalée par l'utilisateur ?
[ ] Message exact de l'alerte (nom de la menace, chemin du fichier) ?
[ ] L'utilisateur a-t-il cliqué sur un lien ou ouvert une pièce jointe récemment ?
[ ] Des fichiers ont-ils disparu ou changé ?
[ ] Le poste est-il lent ou avec un comportement inhabituel ?
[ ] D'autres postes sont-ils affectés ?
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC AV ET PROCESSUS

> Exécuter sur le poste concerné via RMM IMMÉDIATEMENT — isolation possible si menace confirmée.

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== ÉTAT WINDOWS DEFENDER ==="
try {
    $mpStatus = Get-MpComputerStatus -EA Stop
    [pscustomobject]@{
        AVActivé              = $mpStatus.AntivirusEnabled
        AVSigVersion          = $mpStatus.AntivirusSignatureVersion
        AVSigDate             = $mpStatus.AntivirusSignatureLastUpdated
        SpywareEnabled        = $mpStatus.AntispywareEnabled
        RealTimeEnabled       = $mpStatus.RealTimeProtectionEnabled
        FirewallEnabled       = $mpStatus.FirewallEnabled
        DernierScanComplet    = $mpStatus.FullScanEndTime
        DernierScanRapide     = $mpStatus.QuickScanEndTime
        TampProtection        = $mpStatus.IsTamperProtected
    } | Out-String -Width 300 | Write-Output
} catch {
    Write-Output "Windows Defender non disponible ou remplacé par un AV tiers : $_"
}

Write-Output "=== MENACES DÉTECTÉES WINDOWS DEFENDER ==="
try {
    Get-MpThreatDetection | Select-Object ThreatID, ThreatName, SeverityID, ActionSuccess, DetectionTime, Resources |
        Out-String -Width 300 | Write-Output
} catch {
    Write-Output "Get-MpThreatDetection non disponible."
}

Write-Output "=== HISTORIQUE MENACES ==="
try {
    Get-MpThreat | Select-Object ThreatID, ThreatName, SeverityID, ActionSuccess, InitialDetectionTime |
        Out-String -Width 300 | Write-Output
} catch {
    Write-Output "Get-MpThreat non disponible."
}

Write-Output "=== PROCESSUS SUSPECTS (pas de chemin signé, nom inhabituel) ==="
Get-Process | Where-Object { $_.Path -and $_.Path -notlike "$env:WINDIR\*" -and $_.Path -notlike "$env:ProgramFiles\*" -and $_.Path -notlike "$(${env:ProgramFiles(x86)})\*" } |
    Select-Object Name, Id, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,0)}}, Path |
    Out-String -Width 300 | Write-Output

Write-Output "=== CONNEXIONS RÉSEAU ACTIVES (processus + port) ==="
try {
    $connections = Get-NetTCPConnection -State Established -EA SilentlyContinue
    $connections | ForEach-Object {
        $proc = Get-Process -Id $_.OwningProcess -EA SilentlyContinue
        [pscustomobject]@{
            Process     = if ($proc) { $proc.Name } else { "PID $($_.OwningProcess)" }
            LocalPort   = $_.LocalPort
            RemoteAddr  = $_.RemoteAddress
            RemotePort  = $_.RemotePort
        }
    } | Sort-Object Process | Out-String -Width 300 | Write-Output
} catch {
    Write-Output "Erreur lecture connexions TCP : $_"
}

Write-Output "=== TÂCHES PLANIFIÉES RÉCENTES (potentiellement malveillantes) ==="
Get-ScheduledTask | Where-Object { $_.Date -gt (Get-Date).AddDays(-7) -or $_.TaskPath -notlike "\Microsoft\*" } |
    Select-Object TaskName, TaskPath, State, @{N="Date";E={$_.Date}} |
    Out-String -Width 300 | Write-Output

Write-Output "=== ÉVÉNEMENTS DEFENDER RÉCENTS ==="
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Windows Defender/Operational'; StartTime=(Get-Date).AddDays(-3)} -MaxEvents 30 -EA SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Out-String -Width 300 | Write-Output

Write-Output "=== FIN DIAGNOSTIC ==="
```

---

## SECTION 2 — ARBRE DE DÉCISION

```
Alerte AV reçue
├─ Nom de menace connu (ex: Trojan:Win32/..., EICAR-Test)
│   ├─ Action AV = "Supprimé / Mis en quarantaine" ET aucun comportement suspect
│   │   → Peut être faux positif ou menace isolée
│   │   → Vérifier le fichier source (téléchargement, email)
│   │   → Confirmer avec utilisateur → noter dans CW → surveiller 24h
│   │
│   └─ Action AV = "Échec" OU menace active OU processus suspect en cours
│       → ⛔ ISOLER LE POSTE (désactiver réseau si possible)
│       → ESCALADE IMMÉDIATE → IT-SecurityMaster
│
├─ Comportement suspect signalé (fichiers chiffrés, CPU 100% inconnu, redirections navigateur)
│   → ⛔ ISOLER LE POSTE
│   → ESCALADE IMMÉDIATE → IT-SecurityMaster
│   → NE PAS éteindre le poste (préserver les preuves en RAM)
│
└─ Alerte RMM sans symptôme (scan de routine)
    → Vérifier Section 1 → si AV en quarantaine OK → log CW → surveiller
```

---

## SECTION 3 — ISOLATION D'URGENCE (si menace confirmée)

> ⛔ N'exécuter qu'en accord avec IT-SecurityMaster ou le coordonnateur.

```powershell
# Isolation réseau d'urgence — couper toutes les connexions réseau
# ⚠️ Le poste sera inaccessible via RMM après cette commande
Write-Output "⚠️ ISOLATION RÉSEAU EN COURS — confirmer avant d'exécuter"
Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Disable-NetAdapter -Confirm:$false
Write-Output "Adaptateurs désactivés. Poste isolé du réseau."
Write-Output "Pour rétablir : Enable-NetAdapter -Name '*' -Confirm:`$false"
```

---

## LIVRABLE CW

```text
CW NOTE INTERNE — Alerte AV / Comportement suspect
Runbook utilisé : SUP-WKS-Alerte_AV_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [À CONFIRMER]
Alerte : [nom menace / source alerte]
Action AV : [Supprimé / Quarantaine / Échec / Inconnue]

DIAGNOSTIC :
Processus suspects : [Aucun / liste]
Connexions sortantes inhabituelles : [Non / Oui — détails]
Defender à jour : [Oui / Non]

DÉCISION :
[ ] Faux positif confirmé → surveillance 24h
[ ] Menace isolée et supprimée → surveillance
[ ] ⛔ ESCALADE IT-SecurityMaster — menace active ou comportement suspect

→ Décision suivante : [raison]
```

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Menace non supprimée par AV | IT-SecurityMaster | **Immédiat** |
| Fichiers chiffrés / comportement ransomware | IT-SecurityMaster + IT-UrgenceMaster | **Immédiat P0** |
| Connexions sortantes inhabituelles | IT-SecurityMaster | **Immédiat** |
| Plusieurs postes alertés | IT-SecurityMaster + IT-Commandare-NOC | **Immédiat P1** |

*SUP-WKS-Alerte_AV_V1 — 2026-05-22*
