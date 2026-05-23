# SUP-WKS-Partage_Reseau_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Résoudre les problèmes d'accès aux lecteurs réseau mappés et partages SMB — lecteur P: disparu, accès refusé, lenteur d'accès.

## QUESTIONS DE TRIAGE

```
[ ] Lecteur(s) réseau disparu(s) ou non montés ?
[ ] Accès refusé sur un dossier / partage ?
[ ] Lenteur d'accès (navigation lente dans les dossiers) ?
[ ] Problème sur ce seul poste ou plusieurs collègues ?
[ ] Sur VPN ou sur le réseau local ?
[ ] Lettre du lecteur concerné ?
[ ] Changement de mot de passe récent ? (cause fréquente)
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC LECTEURS RÉSEAU

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== LECTEURS RÉSEAU ACTUELS ==="
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -like "\\*" -or $_.DisplayRoot -like "\\*" } |
    Select-Object Name, Root, DisplayRoot, @{N="Libre_GB";E={[math]::Round($_.Free/1GB,1)}} |
    Out-String -Width 300 | Write-Output

Write-Output "=== NET USE (sessions SMB actives) ==="
net use 2>&1 | Out-String -Width 300 | Write-Output

Write-Output "=== LECTEURS MAPPÉS (registre — contexte utilisateur requis) ==="
$networkKey = "HKCU:\Network"
if (Test-Path $networkKey) {
    Get-ChildItem $networkKey | ForEach-Object {
        [pscustomobject]@{
            Lettre      = $_.PSChildName
            RemotePath  = (Get-ItemProperty $_.PSPath).RemotePath
            UserName    = (Get-ItemProperty $_.PSPath).UserName
        }
    } | Out-String -Width 300 | Write-Output
} else {
    Write-Output "Clé HKCU:\Network non accessible (contexte SYSTEM — exécuter en contexte utilisateur)."
}

Write-Output "=== TEST CONNECTIVITÉ SERVEUR DE FICHIERS ==="
$drives = net use 2>&1 | Where-Object { $_ -match "\\\\" }
$servers = $drives | ForEach-Object { if ($_ -match '(\\\\[^\\]+)') { $matches[1] } } | Sort-Object -Unique
foreach ($srv in $servers) {
    $srvName = $srv.TrimStart('\')
    $ping = Test-Connection $srvName -Count 2 -EA SilentlyContinue
    $smb = Test-NetConnection $srvName -Port 445 -InformationLevel Quiet -EA SilentlyContinue
    Write-Output "  $srvName — Ping: $(if ($ping) {'OK'} else {'ÉCHEC ⛔'}) | SMB 445: $(if ($smb) {'OK'} else {'ÉCHEC ⛔'})"
}

Write-Output "=== ÉVÉNEMENTS RÉSEAU RÉCENTS ==="
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-24)} -MaxEvents 200 -EA SilentlyContinue |
    Where-Object { $_.LevelDisplayName -eq 'Erreur' -and $_.ProviderName -like "*MRxSmb*" -or $_.ProviderName -like "*srv*" } |
    Select-Object TimeCreated, Id, ProviderName, Message |
    Out-String -Width 300 | Write-Output

Write-Output "=== FIN DIAGNOSTIC ==="
```

---

## SECTION 2 — SCRIPT RECONNEXION LECTEURS

```powershell
#Requires -Version 5.1
# Reconnecter tous les lecteurs réseau déconnectés
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== RECONNEXION LECTEURS RÉSEAU ==="
$networkKey = "HKCU:\Network"
if (Test-Path $networkKey) {
    Get-ChildItem $networkKey | ForEach-Object {
        $letter = $_.PSChildName
        $path   = (Get-ItemProperty $_.PSPath).RemotePath
        $user   = (Get-ItemProperty $_.PSPath).UserName

        net use "${letter}:" /delete /yes 2>&1 | Out-Null
        net use "${letter}:" "$path" /persistent:yes 2>&1 | Out-String -Width 300 | Write-Output
        Write-Output "Reconnecté : ${letter}: → $path"
    }
} else {
    Write-Output "⚠️ Exécuter ce script en contexte utilisateur (pas SYSTEM) pour accéder à HKCU:\Network"
}
```

---

## SECTION 3 — ACTIONS PAR SCÉNARIO

### A — Lecteurs disparus après redémarrage
- Vérifier si les lecteurs sont définis par GPO (reconnexion automatique) ou script de logon
- Si GPO : `gpresult /r` pour confirmer que la politique s'applique correctement
- Si pas de GPO : recréer le mappage permanent via Section 2

### B — Accès refusé

```powershell
# Vérifier qui a accès au partage (depuis un poste admin)
param([Parameter(Mandatory)][string]$SharePath)
# Ex: $SharePath = "\\SRV-FILES\Partage"
try {
    $acl = Get-Acl $SharePath -EA Stop
    $acl.Access | Select-Object IdentityReference, FileSystemRights, AccessControlType |
        Out-String -Width 300 | Write-Output
} catch {
    Write-Output "Accès refusé ou chemin inaccessible : $_"
    Write-Output "→ Escalade N3 pour vérification permissions NTFS/SMB côté serveur."
}
```

⛔ Modification des permissions NTFS → **hors scope N2** → escalade IT-SysAdmin ou IT-Assistant-N3.

### C — Lenteur d'accès SMB

```powershell
#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== PARAMÈTRES SMB CLIENT ==="
Get-SmbClientConfiguration | Select-Object EnableLargeMtu, DirectoryCacheEntriesMax, FileInfoCacheEntriesMax, SessionTimeout |
    Out-String -Width 300 | Write-Output

Write-Output "=== STATISTIQUES SMB ==="
Get-SmbClientNetworkInterface | Out-String -Width 300 | Write-Output

Write-Output "=== OFFLOADING RÉSEAU ==="
Get-NetAdapterAdvancedProperty | Where-Object { $_.DisplayName -like "*RSS*" -or $_.DisplayName -like "*Offload*" } |
    Select-Object Name, DisplayName, DisplayValue | Out-String -Width 300 | Write-Output
```

---

## LIVRABLE CW

```text
CW NOTE INTERNE — Lecteur réseau inaccessible
Runbook utilisé : SUP-WKS-Partage_Reseau_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [À CONFIRMER]
Lecteur(s) : [ex: P: → \\SRV-FILES\Partage]
Symptôme : [disparu / accès refusé / lent]

DIAGNOSTIC :
Serveur joignable (ping/SMB 445) : [OK / ÉCHEC]
Session net use : [OK / Déconnectée]

ACTIONS :
[ ] Lecteurs reconnectés
[ ] Connectivité serveur confirmée
[ ] Permissions vérifiées

RÉSULTAT : [Résolu / Escalade]

→ Décision suivante : [raison]
```

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Serveur de fichiers non joignable (SMB 445) | IT-SysAdmin / IT-NetworkMaster | Urgent |
| Accès refusé (permissions NTFS/SMB) | IT-SysAdmin (runbook [06c] ad-folder) | Selon SLA |
| Même problème plusieurs utilisateurs | IT-SysAdmin | Priorité |

*SUP-WKS-Partage_Reseau_V1 — 2026-05-22*
