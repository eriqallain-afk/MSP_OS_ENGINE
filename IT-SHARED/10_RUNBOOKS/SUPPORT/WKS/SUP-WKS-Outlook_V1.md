# SUP-WKS-Outlook_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Gérer 80% des problèmes Outlook / M365 niveau 2 — profil, sync, recherche, plantage, invites MDP.

## QUESTIONS DE TRIAGE

```
[ ] Je ne reçois plus de courriels / les autres ne me reçoivent pas ?
[ ] Outlook ne démarre pas / gèle / plante ?
[ ] Invites de mot de passe répétées ?
[ ] La recherche ne fonctionne pas ?
[ ] Problème seulement sur ce poste ou aussi sur mobile / OWA ?
[ ] Depuis quand ?
[ ] Version Office : [À CONFIRMER] (Office 365 / 2021 / 2019)
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC OUTLOOK

> Exécuter sur le poste problématique via RMM.

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== VERSION OFFICE / OUTLOOK ==="
$outlookKey = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
if (Test-Path $outlookKey) {
    Get-ItemProperty $outlookKey |
        Select-Object ProductReleaseIds, VersionToReport, UpdateChannel, CDNBaseUrl |
        Out-String -Width 300 | Write-Output
} else {
    $outlookLegacy = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -EA SilentlyContinue |
        Where-Object { $_.DisplayName -like "*Microsoft Office*" -or $_.DisplayName -like "*Microsoft 365*" } |
        Select-Object DisplayName, DisplayVersion
    $outlookLegacy | Out-String -Width 300 | Write-Output
}

Write-Output "=== PROCESSUS OUTLOOK EN COURS ==="
Get-Process OUTLOOK -EA SilentlyContinue | Select-Object Name, Id, CPU, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,0)}}, Responding |
    Out-String -Width 300 | Write-Output

Write-Output "=== PROFILS OUTLOOK ==="
$profileKey = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles"
if (Test-Path $profileKey) {
    Get-ChildItem $profileKey | Select-Object Name | Out-String -Width 300 | Write-Output
} else {
    Write-Output "Clé profils non trouvée (version Office différente ou profil non créé)."
}

Write-Output "=== TAILLE FICHIERS OST / PST ==="
$searchPaths = @("$env:LOCALAPPDATA\Microsoft\Outlook", "$env:USERPROFILE\Documents")
foreach ($sp in $searchPaths) {
    if (Test-Path $sp) {
        Get-ChildItem $sp -Filter "*.ost","*.pst" -Recurse -EA SilentlyContinue |
            Select-Object Name, @{N="TailleGB";E={[math]::Round($_.Length/1GB, 2)}}, LastWriteTime |
            Out-String -Width 300 | Write-Output
    }
}

Write-Output "=== COMPTE M365 CONNECTÉ ==="
$identityKey = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity\Identities"
if (Test-Path $identityKey) {
    Get-ChildItem $identityKey | Get-ItemProperty | Select-Object FirstName, LastName, EmailAddresses |
        Out-String -Width 300 | Write-Output
} else {
    Write-Output "Clé identité non trouvée."
}

Write-Output "=== ERREURS OUTLOOK RÉCENTES (EventLog Application) ==="
Get-WinEvent -FilterHashtable @{
    LogName='Application'
    ProviderName='Microsoft Office 16 Alerts','Outlook'
    StartTime=(Get-Date).AddDays(-3)
} -MaxEvents 15 -EA SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Out-String -Width 300 | Write-Output

Write-Output "=== ÉTAT CONNEXION EXCHANGE (test OWA) ==="
Write-Output "ACTION MANUELLE : Ouvrir https://outlook.office365.com dans un onglet privé."
Write-Output "Si OWA OK → problème local Outlook/profil."
Write-Output "Si OWA aussi HS → problème compte/messagerie → escalade N3."

Write-Output "=== FIN DIAGNOSTIC ==="
```

---

## SECTION 2 — ACTIONS PAR SCÉNARIO

### A — Outlook ne démarre pas / plante

```powershell
# Mode sans échec Outlook — exécuter en ligne de commande (pas via RMM system context)
Write-Output "Lancer Outlook en mode sans échec :"
Write-Output "  outlook.exe /safe"
Write-Output ""
Write-Output "=== COMPLÉMENTS OUTLOOK ACTIFS ==="
$addInKey = "HKCU:\Software\Microsoft\Office\Outlook\Addins"
if (Test-Path $addInKey) {
    Get-ChildItem $addInKey | ForEach-Object {
        [pscustomobject]@{
            Nom         = $_.PSChildName
            LoadBehavior = (Get-ItemProperty $_.PSPath -EA SilentlyContinue).LoadBehavior
        }
    } | Out-String -Width 300 | Write-Output
}
Write-Output "LoadBehavior=3 = chargé. Si plantage en mode normal mais pas /safe → désactiver compléments tiers."
```

### B — Nouveau profil Outlook

```powershell
# Instructions pour recréer le profil Outlook
Write-Output "ÉTAPES — Nouveau profil Outlook :"
Write-Output "1. Fermer Outlook complètement (vérifier dans Gestionnaire des tâches)"
Write-Output "2. Panneau de configuration > Courrier > Afficher les profils"
Write-Output "3. Ajouter > Nommer le profil (ex: 'Nouveau')"
Write-Output "4. Ajouter le compte Exchange/M365"
Write-Output "5. Définir comme profil par défaut"
Write-Output "6. Redémarrer Outlook"
Write-Output ""
Write-Output "⚠️ L'OST sera recréé — première synchronisation peut prendre 10-30 min selon taille boîte."
```

### C — Invites MDP répétées

```powershell
#Requires -Version 5.1
# Nettoyer les credentials Office corrompus
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== CREDENTIALS OFFICE/EXCHANGE DANS LE GESTIONNAIRE ==="
cmdkey /list 2>&1 | Select-String "MicrosoftOffice|Exchange|outlook|graph|sharepoint" |
    Out-String -Width 300 | Write-Output

Write-Output ""
Write-Output "ACTION : Supprimer les entrées MicrosoftOffice* dans Gestionnaire d'identifiants Windows."
Write-Output "Chemin : Panneau de configuration > Gestionnaire d'identifiants > Informations d'identification Windows"
Write-Output "Supprimer toutes les entrées contenant 'MicrosoftOffice' ou 'Exchange'"
Write-Output "Puis relancer Outlook et se reconnecter."
```

### D — Recherche Outlook ne fonctionne pas

```powershell
#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== ÉTAT INDEX DE RECHERCHE WINDOWS ==="
$svc = Get-Service "WSearch" -EA SilentlyContinue
Write-Output "Service WSearch : $($svc.Status)"

Write-Output "=== RECONSTRUIRE L'INDEX (si Outlook inclus) ==="
Write-Output "Étapes manuelles requises (contexte utilisateur) :"
Write-Output "1. Paramètres Windows > Recherche > Indexation Windows"
Write-Output "2. Options avancées > Reconstruire"
Write-Output "3. Redémarrer le service WSearch si nécessaire"

# Redémarrer le service de recherche
try {
    Restart-Service WSearch -Force
    Write-Output "Service WSearch redémarré."
} catch {
    Write-Output "Erreur redémarrage WSearch : $_"
}
```

---

## SECTION 3 — LIVRABLE CW

```text
CW NOTE INTERNE — Problème Outlook / M365
Runbook utilisé : SUP-WKS-Outlook_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [À CONFIRMER]
Symptôme : [ne démarre pas / invites MDP / recherche / autre]

DIAGNOSTIC :
OWA testé : [OK / HS]
Version Outlook : [À COMPLÉTER]
Taille OST : [GB]
Profil : [existant / recréé]

ACTIONS :
[ ] Mode sans échec testé
[ ] Compléments désactivés
[ ] Profil recréé
[ ] Credentials supprimés du gestionnaire
[ ] Index recherche reconstruit

RÉSULTAT : [Résolu / Escalade]

→ Décision suivante : [raison]
```

---

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| OWA aussi dysfonctionnel | IT-Assistant-N3 (Exchange Online) | Selon SLA |
| Problème côté tenant M365 | IT-Assistant-N3 / IT-CloudMaster | Selon SLA |
| Activité suspecte sur le compte mail | IT-SecurityMaster | Immédiat |
| OST > 50 GB — performance chronique | IT-Assistant-N3 (archivage) | Planifié |

*SUP-WKS-Outlook_V1 — 2026-05-22*
