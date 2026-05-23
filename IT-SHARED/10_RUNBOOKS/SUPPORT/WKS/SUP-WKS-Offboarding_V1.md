# SUP-WKS-Offboarding_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2 | @IT-TechOPS
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Encadrer le départ d'un employé — désactivation compte, sauvegarde données, libération licences, wipe sécurisé du poste.

> ⚠️ **Toute modification AD / M365 est hors scope N2.** Ce runbook guide le N2 dans la collecte d'info et les étapes poste. Les actions AD/M365/licences → IT-SysAdmin ou IT-CloudMaster.

## PRÉREQUIS

```
[ ] Autorisation du gestionnaire client reçue (par écrit dans le ticket)
[ ] Date de départ confirmée
[ ] Nom d'utilisateur AD / M365
[ ] Décision sur la redirection des emails (vers qui ?)
[ ] Décision sur les données (archiver / supprimer)
[ ] Décision sur le matériel (wipe + retour / réassigner)
```

---

## SECTION 1 — SCRIPT INVENTAIRE DONNÉES POSTE

> Exécuter avant de récupérer le poste — documenter ce qui s'y trouve.

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== INFORMATIONS POSTE ==="
$cs = Get-CimInstance Win32_ComputerSystem
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    OS          = $os.Caption
    Domaine     = $cs.Domain
    Dernier_Boot = $os.LastBootUpTime
} | Out-String -Width 300 | Write-Output

Write-Output "=== UTILISATEURS AVEC PROFIL LOCAL ==="
Get-CimInstance Win32_UserProfile | Where-Object { -not $_.Special -and $_.LocalPath -like "C:\Users\*" } |
    ForEach-Object {
        $path = $_.LocalPath
        $size = if (Test-Path $path) {
            [math]::Round((Get-ChildItem $path -Recurse -EA SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB, 0)
        } else { "N/A" }
        [pscustomobject]@{
            Chemin    = $path
            DernierUse = $_.LastUseTime
            TailleMB  = $size
        }
    } | Out-String -Width 300 | Write-Output

Write-Output "=== DONNÉES CRITIQUES (Bureau / Documents / Downloads) ==="
$userFolders = Get-ChildItem "C:\Users" -Directory -EA SilentlyContinue |
    Where-Object { $_.Name -ne "Public" -and $_.Name -ne "Default" }
foreach ($u in $userFolders) {
    foreach ($folder in @("Desktop","Documents","Downloads")) {
        $p = Join-Path $u.FullName $folder
        if (Test-Path $p) {
            $count = (Get-ChildItem $p -Recurse -EA SilentlyContinue).Count
            $size = [math]::Round((Get-ChildItem $p -Recurse -EA SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB, 0)
            Write-Output "  $($u.Name)\$folder : $count fichiers — $size MB"
        }
    }
}

Write-Output "=== ONEDRIVE SYNCHRONISÉ ? ==="
Get-Process OneDrive -EA SilentlyContinue | Select-Object Name, Id, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,0)}} |
    Out-String -Width 300 | Write-Output
$odPath = "$env:USERPROFILE\OneDrive*"
if (Test-Path $odPath) { Write-Output "OneDrive présent : $odPath" } else { Write-Output "OneDrive non détecté — données locales à sauvegarder manuellement." }

Write-Output "=== CONNEXIONS ACTIVES AU POSTE ==="
query session 2>&1 | Out-String -Width 300 | Write-Output

Write-Output "=== FIN INVENTAIRE ==="
```

---

## SECTION 2 — CHECKLIST OFFBOARDING COMPLET

```
ÉTAPES OFFBOARDING — à cocher dans l'ordre

DONNÉES (avant toute action)
[ ] Données Bureau / Documents inventoriées (Section 1)
[ ] OneDrive synchronisé — données dans le cloud ? (confirmer)
[ ] Sauvegarde finale effectuée si données locales critiques
[ ] Destination de la sauvegarde documentée dans le ticket

COMPTE AD — via IT-SysAdmin
[ ] Compte AD désactivé (NE PAS supprimer — conserver 30-90 jours selon politique)
[ ] Déplacé dans OU "Désactivés" ou équivalent
[ ] Mot de passe réinitialisé (accès révoqué)
[ ] Groupes AD conservés pour documentation

COMPTE M365 — via IT-CloudMaster ou IT-SysAdmin
[ ] Licence M365 retirée (ou boîte mise en litige si requis)
[ ] Redirection des emails configurée (si demandée)
[ ] Délégation de boîte (si demandée)
[ ] OneDrive partagé avec le gestionnaire (si requis)
[ ] MFA désactivé / appareils révoqués
[ ] Tokens révoqués (Sign out de toutes les sessions)

MATÉRIEL
[ ] Poste récupéré physiquement
[ ] Effacement sécurisé effectué (voir Section 3)
[ ] Asset retiré du RMM
[ ] Licence AV/EDR libérée dans la console
[ ] Asset documenté dans Hudu / CMDB (statut : Wipe / Réassigné / Retiré)

DOCUMENTATION
[ ] Ticket CW mis à jour avec toutes les actions
[ ] Hudu mis à jour
```

---

## SECTION 3 — EFFACEMENT SÉCURISÉ (avant retour/réassignation)

> ⚠️ **Irréversible.** Confirmer que toutes les données ont été sauvegardées.

```powershell
# Vérification pré-wipe — confirmer qu'on efface le bon poste
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Output "=== CONFIRMATION PRÉ-WIPE ==="
Write-Output "HOSTNAME : $env:COMPUTERNAME"
Write-Output "DOMAINE  : $((Get-CimInstance Win32_ComputerSystem).Domain)"
Write-Output ""
Write-Output "⚠️ Vérifier que ce poste correspond bien à l'asset à effacer AVANT de continuer."
Write-Output ""
Write-Output "OPTIONS D'EFFACEMENT :"
Write-Output "1. Windows Reset : Settings > Recovery > Reset this PC > Remove everything > Local reinstall"
Write-Output "   Commande : Start-Process 'ms-settings:recovery'"
Write-Output ""
Write-Output "2. Effacement certifié via outil approuvé (DBAN, Eraser, Blancco) selon politique client"
Write-Output ""
Write-Output "3. Si BitLocker activé : effacer la clé BitLocker dans AD/Azure AD AVANT le wipe"
Write-Output "   Bitlocker status : manage-bde -status C:"
```

---

## LIVRABLE CW

```text
CW NOTE INTERNE — Offboarding employé
Runbook utilisé : SUP-WKS-Offboarding_V1

CONTEXTE :
Employé : [À CONFIRMER]
Date de départ : [Date]
Ticket autorisé par : [Gestionnaire client]

DONNÉES :
OneDrive synchronisé : [Oui / Non]
Sauvegarde locale effectuée : [Oui / N-A] → [chemin]

COMPTE AD : Désactivé [Oui / En attente IT-SysAdmin]
COMPTE M365 : Désactivé / Licence libérée [Oui / En attente]
Redirection email vers : [À CONFIRMER / N-A]

MATÉRIEL :
Poste récupéré : [Oui / Non]
Effacement effectué : [Oui — méthode : ] / [Non — réassigné à :]
Asset Hudu/RMM mis à jour : [Oui]

→ Décision suivante : [raison]
```

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Désactivation compte AD / M365 | IT-SysAdmin / IT-CloudMaster | Selon date départ |
| Effacement certifié (conformité) | IT-TechOPS | Planifié |
| Boîte mail en litige (légal) | IT-CloudMaster + coordonnateur | Selon instruction légale |
| Données critiques non sauvegardées | IT-SysAdmin + gestionnaire client | Avant toute action |

*SUP-WKS-Offboarding_V1 — 2026-05-22*
