# SUP-WKS-Imprimante_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-FrontLine | @IT-Assistant-N2 | @IT-TechOnsite
**Département :** SUP-WKS | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF
Résoudre les problèmes d'impression côté poste client — imprimante locale USB, réseau partagée ou IP directe.
> Pour les problèmes de serveur d'impression → runbook [27] print (MAINT-SRV-PrintServer_PrePost_V1).

## QUESTIONS DE TRIAGE

```
[ ] Problème sur un seul utilisateur ou plusieurs collègues ?
[ ] Imprimante USB locale, réseau partagée (via serveur) ou IP directe ?
[ ] Message d'erreur précis ? (hors ligne, file bloquée, erreur, accès refusé)
[ ] L'imprimante s'affiche dans la liste des périphériques ?
[ ] Impression depuis d'autres applications fonctionne ?
[ ] Depuis quand ?
```

---

## SECTION 1 — SCRIPT DIAGNOSTIC IMPRESSION POSTE

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== SERVICE SPOOLER ==="
Get-Service Spooler | Select-Object Name, Status, StartType | Out-String -Width 300 | Write-Output

Write-Output "=== IMPRIMANTES INSTALLÉES ==="
Get-Printer | Select-Object Name, DriverName, PortName, Shared, Default, PrinterStatus |
    Out-String -Width 300 | Write-Output

Write-Output "=== PORTS D'IMPRESSION ==="
Get-PrinterPort | Select-Object Name, Description, PrinterHostAddress, PortNumber |
    Out-String -Width 300 | Write-Output

Write-Output "=== FILE D'ATTENTE (JOBS EN COURS) ==="
Get-PrintJob -PrinterName * -EA SilentlyContinue | Select-Object PrinterName, JobStatus, DocumentName, UserName, TotalPages, Size |
    Out-String -Width 300 | Write-Output

Write-Output "=== PILOTES IMPRIMANTES INSTALLÉS ==="
Get-PrinterDriver | Select-Object Name, MajorVersion, PrinterEnvironment | Out-String -Width 300 | Write-Output

Write-Output "=== ERREURS SPOOLER RÉCENTES ==="
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-PrintService','Spooler'; StartTime=(Get-Date).AddDays(-3)} -MaxEvents 20 -EA SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Out-String -Width 300 | Write-Output

Write-Output "=== TEST CONNECTIVITÉ IMPRIMANTE (si IP connue) ==="
$printers = Get-PrinterPort | Where-Object { $_.PrinterHostAddress -match '^\d+\.\d+\.\d+\.\d+$' }
foreach ($p in $printers) {
    $ping = Test-Connection $p.PrinterHostAddress -Count 2 -EA SilentlyContinue
    Write-Output "  $($p.Name) [$($p.PrinterHostAddress)] : $(if ($ping) { "PING OK ($([math]::Round(($ping | Measure-Object ResponseTime -Average).Average,0)) ms)" } else { 'PING ÉCHEC ⛔' })"
}
Write-Output "=== FIN DIAGNOSTIC ==="
```

---

## SECTION 2 — SCRIPT RÉPARATION SPOOLER + VIDER FILE

> ⚠️ Valider avec l'utilisateur : tous les jobs en cours seront perdus.

```powershell
#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== ARRÊT SPOOLER ==="
Stop-Service Spooler -Force
Start-Sleep -Seconds 2

Write-Output "=== SUPPRESSION JOBS EN ATTENTE ==="
$spoolPath = "$env:WINDIR\System32\spool\PRINTERS"
$files = Get-ChildItem $spoolPath -EA SilentlyContinue
if ($files) {
    $files | Remove-Item -Force -EA SilentlyContinue
    Write-Output "Fichiers supprimés : $($files.Count)"
} else {
    Write-Output "File d'attente déjà vide."
}

Write-Output "=== REDÉMARRAGE SPOOLER ==="
Start-Service Spooler
Start-Sleep -Seconds 2
$svc = Get-Service Spooler
Write-Output "Spooler : $($svc.Status)"

Write-Output "=== VÉRIFICATION POST-NETTOYAGE ==="
Get-Printer | Select-Object Name, PrinterStatus, Default | Out-String -Width 300 | Write-Output
Write-Output "=== RÉPARATION TERMINÉE ==="
```

---

## SECTION 3 — ACTIONS PAR SCÉNARIO

### Cas A — Un seul utilisateur ne peut pas imprimer

1. Vérifier imprimante par défaut correcte (Section 1 — colonne Default)
2. Vider la file + redémarrer Spooler (Section 2)
3. Vérifier que le job apparaît dans la file après impression → statut ?
4. Si "hors ligne" → décocher "Utiliser l'imprimante hors connexion" (clic droit sur l'imprimante)
5. Si pilote corrompu → supprimer et réinstaller depuis source approuvée (GPO / portail / script)

### Cas B — Personne ne peut imprimer (imprimante réseau)

```powershell
# Ping rapide imprimante réseau (remplacer [IP_IMPRIMANTE])
param([string]$PrinterIP = "[IP_IMPRIMANTE]")
Test-NetConnection $PrinterIP -Port 9100 | Select-Object ComputerName, TcpTestSucceeded, PingSucceeded |
    Out-String -Width 300 | Write-Output
```

- Si ping échoue → imprimante hors ligne ou réseau → vérifier alimentation, câble, IP
- Si imprimante partagée via serveur → vérifier le serveur d'impression → runbook [27]
- Vérifier la file du serveur d'impression depuis le serveur

### Cas C — Réinstallation imprimante réseau

```powershell
# Supprimer et réajouter une imprimante IP
param(
    [Parameter(Mandatory)][string]$PrinterName,
    [Parameter(Mandatory)][string]$PrinterIP,
    [Parameter(Mandatory)][string]$DriverName
)
Remove-Printer -Name $PrinterName -EA SilentlyContinue
Remove-PrinterPort -Name "IP_$PrinterIP" -EA SilentlyContinue
Add-PrinterPort -Name "IP_$PrinterIP" -PrinterHostAddress $PrinterIP
Add-Printer -Name $PrinterName -DriverName $DriverName -PortName "IP_$PrinterIP"
Set-Printer -Name $PrinterName -Shared $false
Write-Output "Imprimante réinstallée : $PrinterName sur $PrinterIP"
```

---

## SECTION 4 — LIMITES N2

⛔ **NE PAS faire en N2 :**
- Modifier la configuration réseau de l'imprimante (IP, VLAN)
- Changer les pilotes sur un serveur d'impression partagé
- Modifier les permissions d'impression (ACL)
- Problèmes mécaniques / matériel → fournisseur ou contact interne client

---

## LIVRABLE CW

```text
CW NOTE INTERNE — Imprimante qui n'imprime pas
Runbook utilisé : SUP-WKS-Imprimante_V1

CONTEXTE :
Utilisateur : [À CONFIRMER]
Poste : [À CONFIRMER]
Imprimante : [nom] — [USB / réseau IP / partagée]
Symptôme : [file bloquée / hors ligne / pilote / autre]

DIAGNOSTIC :
Spooler : [Running / Stopped]
Jobs bloqués : [nombre]
Ping imprimante : [OK / ÉCHEC / N-A USB]

ACTIONS :
[ ] Spooler redémarré + file vidée
[ ] Imprimante réinstallée
[ ] Pilote mis à jour

RÉSULTAT : [Résolu / Escalade]

→ Décision suivante : [raison]
```

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Spooler crashe en boucle | IT-SysAdmin (serveur print) / IT-TechOnsite | Selon SLA |
| Imprimante réseau non joignable (ping échoue) | IT-NetworkMaster | Selon SLA |
| Plusieurs utilisateurs impactés | Runbook [27] MAINT-SRV-PrintServer_PrePost_V1 | Priorité |

*SUP-WKS-Imprimante_V1 — 2026-05-22*
