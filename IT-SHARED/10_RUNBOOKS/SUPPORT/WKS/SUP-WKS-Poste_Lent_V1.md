# SUP-WKS-Poste_Lent_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2 | @IT-TechOnsite
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Identifier rapidement si la lenteur vient du matériel, des ressources système, d'un logiciel précis ou du réseau.

## QUESTIONS DE TRIAGE

```
[ ] Depuis quand c'est lent ? (aujourd'hui / depuis une semaine / toujours)
[ ] Lent partout ou seulement dans une app (Outlook, Teams, appli métier) ?
[ ] Lent en ligne seulement (SharePoint, navigateur) ?
[ ] D'autres collègues ont-ils le même problème ?
[ ] Poste local ou télétravail (VPN, Wi-Fi maison) ?
[ ] Dernier redémarrage ? (demander à l'utilisateur)
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC RESSOURCES

> Exécuter sur le poste cible via RMM. Copier-coller directement.

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== HÔTE / OS / UPTIME ==="
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    OS          = $os.Caption
    Version     = $os.Version
    LastReboot  = $os.LastBootUpTime
    Uptime_Hrs  = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 1)
} | Out-String -Width 300 | Write-Output

Write-Output "=== CPU ==="
$cpus = Get-CimInstance Win32_Processor
[pscustomobject]@{
    Modele      = ($cpus | Select-Object -First 1).Name.Trim()
    Cores       = ($cpus | Measure-Object NumberOfCores -Sum).Sum
    LogicalProc = ($cpus | Measure-Object NumberOfLogicalProcessors -Sum).Sum
    "Load%"     = [math]::Round(($cpus | Measure-Object LoadPercentage -Average).Average, 0)
} | Out-String -Width 300 | Write-Output

Write-Output "=== MÉMOIRE RAM ==="
[pscustomobject]@{
    TotalGB  = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    LibreGB  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    UtilisGB = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)
    "Util%"  = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 0)
} | Out-String -Width 300 | Write-Output

Write-Output "=== DISQUES ==="
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    [pscustomobject]@{
        Lecteur  = $_.DeviceID
        TotalGB  = [math]::Round($_.Size / 1GB, 1)
        LibreGB  = [math]::Round($_.FreeSpace / 1GB, 1)
        "Libre%" = [math]::Round(($_.FreeSpace / $_.Size) * 100, 0)
        ALERTE   = if (($_.FreeSpace / $_.Size) -lt 0.10) { "⛔ CRITIQUE <10%" } elseif (($_.FreeSpace / $_.Size) -lt 0.20) { "⚠️ FAIBLE <20%" } else { "OK" }
    }
} | Out-String -Width 300 | Write-Output

Write-Output "=== TOP 10 PROCESSUS — CPU ==="
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 |
    Select-Object Name, Id, @{N="CPU_s";E={[math]::Round($_.CPU, 1)}}, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,0)}} |
    Out-String -Width 300 | Write-Output

Write-Output "=== TOP 10 PROCESSUS — RAM ==="
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 |
    Select-Object Name, Id, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,0)}}, @{N="CPU_s";E={[math]::Round($_.CPU,1)}} |
    Out-String -Width 300 | Write-Output

Write-Output "=== PROGRAMMES AU DÉMARRAGE ==="
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, User |
    Out-String -Width 300 | Write-Output

Write-Output "=== LOGICIELS INSTALLÉS RÉCEMMENT (30 jours) ==="
$cutoff = (Get-Date).AddDays(-30)
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                  "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -EA SilentlyContinue |
    Where-Object { $_.InstallDate -and [datetime]::ParseExact($_.InstallDate, "yyyyMMdd", $null) -gt $cutoff } |
    Select-Object DisplayName, DisplayVersion, InstallDate, Publisher |
    Sort-Object InstallDate -Descending |
    Out-String -Width 300 | Write-Output

Write-Output "=== MISES À JOUR WINDOWS EN ATTENTE ==="
try {
    $wu = New-Object -ComObject Microsoft.Update.Session
    $searcher = $wu.CreateUpdateSearcher()
    $result = $searcher.Search("IsInstalled=0 and IsHidden=0")
    Write-Output "Mises à jour en attente : $($result.Updates.Count)"
    $result.Updates | ForEach-Object { Write-Output "  - $($_.Title)" }
} catch {
    Write-Output "Vérification WU non disponible via COM : $_"
}

Write-Output "=== SANTÉ DISQUE (SMART) ==="
try {
    Get-PhysicalDisk | Select-Object MediaType, Size, HealthStatus, OperationalStatus |
        Out-String -Width 300 | Write-Output
} catch {
    Write-Output "Get-PhysicalDisk non disponible : $_"
}

Write-Output "=== FIN DIAGNOSTIC ==="
```

---

## SECTION 2 — SCRIPT NETTOYAGE (après confirmation)

> ⚠️ Valider avec l'utilisateur que le poste peut être perturbé 2-3 minutes.

```powershell
#Requires -Version 5.1
# Nettoyage fichiers temporaires — à exécuter après confirmation
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== NETTOYAGE FICHIERS TEMPORAIRES ==="

$before = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace

# Temp utilisateur et système
$paths = @("$env:TEMP", "$env:WINDIR\Temp", "$env:WINDIR\SoftwareDistribution\Download")
foreach ($p in $paths) {
    if (Test-Path $p) {
        try {
            Get-ChildItem $p -Recurse -Force -EA SilentlyContinue |
                Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-3) } |
                Remove-Item -Force -EA SilentlyContinue
            Write-Output "Nettoyé : $p"
        } catch {
            Write-Output "Erreur sur $p : $_"
        }
    }
}

# Vider corbeille
try { Clear-RecycleBin -Force -EA SilentlyContinue; Write-Output "Corbeille vidée." } catch {}

# Flush DNS
ipconfig /flushdns | Out-Null
Write-Output "Cache DNS vidé."

$after = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
$freed = [math]::Round(($after - $before) / 1MB, 0)
Write-Output "Espace libéré : $freed MB"
Write-Output "=== NETTOYAGE TERMINÉ ==="
```

---

## SECTION 3 — ARBRE DE DÉCISION

```
Poste lent
├─ CPU > 85% continu
│   ├─ Processus connu (Teams, Chrome, AV scan) → fermer/optimiser → rester N2
│   ├─ Processus inconnu / 100% soutenu → vérifier si malware → escalade IT-SecurityMaster si suspect
│   └─ Mise à jour Windows en cours → attendre, planifier redémarrage
│
├─ RAM > 85%
│   ├─ Trop de programmes → désactiver auto-start non essentiels
│   ├─ 4 Go ou moins sur Win10/11 → recommander upgrade RAM (ticket TechOPS)
│   └─ Processus unique consomme tout → vérifier fuite mémoire → escalade N3
│
├─ Disque C: < 10% libre
│   ├─ Fichiers temp / corbeille → Nettoyage Section 2
│   ├─ Anciens fichiers ou OneDrive tout local → audit avec utilisateur
│   └─ Disque SMART dégradé → escalade TechOPS (remplacement disque)
│
├─ Disque à 100% d'activité (I/O)
│   ├─ AV / backup en cours → vérifier planification → déplacer hors heures
│   └─ SMART fail → escalade TechOPS urgent
│
├─ Rien de flagrant → lenteur réseau/app
│   ├─ Télétravail : test speedtest → vérifier Wi-Fi vs filaire
│   └─ Même problème plusieurs collègues → escalade N3 (infra réseau/serveur)
│
└─ Redémarrage récent jamais fait (> 3 jours)
    └─ Proposer / planifier redémarrage propre → réévaluer après
```

---

## SECTION 4 — LIVRABLE CW

```text
CW NOTE INTERNE — Poste lent
Runbook utilisé : SUP-WKS-Poste_Lent_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [À CONFIRMER]
Symptôme : Poste lent depuis [À CONFIRMER]

DIAGNOSTIC :
CPU Load : [%]  |  RAM : [X GB / Y GB]  |  Disque C: [% libre]
Processus suspect : [nom ou Aucun]
SMART : [OK / Dégradé]

ACTIONS :
[ ] Redémarrage effectué
[ ] Nettoyage fichiers temp — [X MB libérés]
[ ] Désactivation auto-start : [liste]
[ ] Autre : [À COMPLÉTER]

RÉSULTAT : [Amélioré / Pas résolu → escalade]

→ Décision suivante : [raison]
```

---

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Processus inconnu à 100% CPU / comportement suspect | IT-SecurityMaster | Immédiat |
| SMART fail / disque défectueux | IT-TechOnsite (hardware) | Urgent |
| Même lenteur sur plusieurs postes | IT-N3 (infra réseau/serveur) | Selon SLA |
| RAM insuffisante — upgrade requis | IT-TechOnsite via ticket | Planifié |

*SUP-WKS-Poste_Lent_V1 — 2026-05-22*
