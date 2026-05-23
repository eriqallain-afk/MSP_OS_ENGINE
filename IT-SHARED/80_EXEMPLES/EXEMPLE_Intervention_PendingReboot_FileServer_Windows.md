# EXEMPLE — Intervention Pending Reboot sur serveur de fichiers Windows

## Usage
Ce document sert de référence interne pour les cas similaires :
- alerte **Windows Update pending reboot**
- serveur de fichiers Windows
- risque d'impact sur les partages SMB
- besoin de décision rapide **GO / NO-GO**
- clôture CW standard après exécution

---

## Scénario type

**Type d'alerte**
- Pending reboot déclenché par Windows Update
- Uptime élevé
- Serveur de fichiers en production
- Fenêtre de redémarrage approuvée par le client

**Risque principal**
- Coupure des partages alors que des fichiers sont encore ouverts
- Risque de perte de travail non enregistré
- Impact utilisateur immédiat si reboot lancé trop tôt

---

## Triage initial

### Objectif
Déterminer si le serveur peut être redémarré sans interrompre des usagers actifs sur les partages.

### Ce qu'il faut éviter
- Se fier uniquement à `query user`
- Conclure trop vite au GO parce qu'il n'y a pas de session interactive
- Redémarrer sans vérifier les fichiers SMB ouverts

### Règle pratique
Sur un **file server**, la décision de reboot doit être basée d'abord sur :
1. les **sessions SMB**
2. les **fichiers SMB ouverts**

---

## Precheck ciblé — file server

### Vérification sessions et fichiers ouverts

```powershell
Write-Host "=== SMB SESSIONS ==="
$SmbSessions = Get-SmbSession -ErrorAction SilentlyContinue

if ($SmbSessions) {
    $SmbSessions |
        Sort-Object ClientUserName, ClientComputerName |
        Select-Object ClientComputerName, ClientUserName, NumOpens, ConnectedTime |
        Format-Table -AutoSize
}
else {
    Write-Host "Aucune session SMB active."
}

Write-Host " "
Write-Host "=== SMB OPEN FILES ==="
$SmbOpenFiles = Get-SmbOpenFile -ErrorAction SilentlyContinue

if ($SmbOpenFiles) {
    $SmbOpenFiles |
        Sort-Object ClientUserName, ClientComputerName, Path |
        Select-Object ClientComputerName, ClientUserName, Path, Permissions, SessionId |
        Format-Table -AutoSize
}
else {
    Write-Host "Aucun fichier SMB ouvert."
}
```

### Interprétation
- **Aucun fichier SMB ouvert** = **GO technique** pour reboot
- **Au moins un fichier SMB ouvert** = **NO-GO**

### Indicateur fort
La présence d'un fichier temporaire de type `~$NomDuFichier.xlsx` indique généralement qu'un document Excel est encore ouvert.

---

## Déroulé type de l'intervention

### Étape 1 — Premier contrôle
Le contrôle SMB montre encore des fichiers ouverts sur les partages.

**Décision**
- **NO-GO**
- ne pas redémarrer
- demander la fermeture des fichiers
- replanifier ou attendre la fenêtre effective

### Étape 2 — Recheck avant exécution
Refaire **uniquement** le contrôle suivant :

```powershell
Get-SmbOpenFile |
    Select-Object ClientComputerName, ClientUserName, Path |
    Format-Table -AutoSize
```

**Décision**
- si le résultat contient encore des lignes : **NO-GO**
- si le résultat est vide : **GO reboot**

### Étape 3 — Reboot contrôlé

```powershell
Restart-Computer -Force
```

⚠️ Impact attendu :
- indisponibilité temporaire des partages pendant le redémarrage

---

## Postcheck standard après retour en ligne

```powershell
Write-Host "=== HOST / UPTIME ==="
Get-CimInstance Win32_OperatingSystem |
    Select-Object CSName, Caption, LastBootUpTime

Write-Host " "
Write-Host "=== PENDING REBOOT FLAGS ==="
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'

[pscustomobject]@{
    CBS_RebootPending           = $CBS
    WU_RebootRequired           = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending      = $CCM
    PendingReboot               = ($CBS -or $WU -or $PFR -or $CCM)
} | Format-List

Write-Host " "
Write-Host "=== SERVICES CRITIQUES FICHIER ==="
Get-Service -Name LanmanServer, LanmanWorkstation -ErrorAction SilentlyContinue |
    Select-Object Name, DisplayName, Status, StartType |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== SMB SHARES ==="
Get-SmbShare -Special $false -ErrorAction SilentlyContinue |
    Select-Object Name, Path, Description |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== SMB OPEN FILES ==="
$OpenFiles = Get-SmbOpenFile -ErrorAction SilentlyContinue
if ($OpenFiles) {
    $OpenFiles |
        Select-Object ClientComputerName, ClientUserName, Path |
        Format-Table -AutoSize
}
else {
    Write-Host "Aucun fichier SMB ouvert."
}

Write-Host " "
Write-Host "=== SERVICES AUTO NON DEMARRES ==="
Get-Service |
    Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' } |
    Select-Object Name, DisplayName, Status |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== SYSTEM ERRORS DEPUIS LE BOOT ==="
$BootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$BootTime} -ErrorAction SilentlyContinue |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First 20 TimeCreated, Id, ProviderName, Message |
    Format-Table -Wrap
```

---

## Critères de succès

L'intervention peut être considérée réussie si :

- le serveur revient en ligne
- le `LastBootUpTime` est récent
- tous les flags de pending reboot sont à `False`
- `LanmanServer` et `LanmanWorkstation` sont en état `Running`
- les partages SMB sont présents
- aucun fichier SMB n'est encore ouvert au moment du contrôle final
- les erreurs vues depuis le boot ne montrent pas d'impact fonctionnel immédiat

---

## Exemple de décision finale

### Cas observé
- premier contrôle : fichiers SMB encore ouverts
- décision : **NO-GO**
- second contrôle après fermeture : plus de fichiers ouverts
- reboot exécuté
- postcheck validé
- pending reboot cleared

### Conclusion type
**Intervention réussie — reboot effectué après validation d'absence de fichiers ouverts sur les partages.**

---

## Leçon importante à retenir

### Mauvais réflexe
```powershell
query user
```

### Pourquoi
Sur un **serveur de fichiers**, cette commande peut ne rien montrer d'utile pour la décision de reboot.

### Bon réflexe
```powershell
Get-SmbSession
Get-SmbOpenFile
```

---

## Modèle court — Note interne

```text
Prise de connaissance de la demande et consultation de la documentation du client.

Alerte Pending Reboot active sur un serveur de fichiers.
Validation lecture seule effectuée avant redémarrage.
Résultat initial : présence de fichiers SMB ouverts, donc NO-GO.
Nouvelle validation effectuée après fermeture des fichiers.
Redémarrage exécuté une fois le contrôle SMB revenu vide.
Postcheck complété : serveur en ligne, partages présents, services de partage opérationnels, aucun fichier SMB ouvert et indicateurs Pending Reboot à False.
Conclusion : intervention complétée avec succès.
```

---

## Modèle court — Discussion CW

```text
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

Validation préalable effectuée avant le redémarrage planifié afin d’éviter toute interruption pendant l’utilisation des partages.
Le redémarrage a d’abord été reporté lorsqu’une utilisation active des fichiers a été constatée.
Une nouvelle validation a ensuite confirmé que les fichiers étaient fermés.
Le redémarrage planifié a été exécuté pour finaliser les mises à jour en attente.
Une vérification complète a été réalisée après le retour en ligne.
L'intervention est complétée avec succès.
```

---

## Runbooks / références utilisés ou alignés

### Confirmés comme utilisés / alignés directement
1. **BUNDLE_KP_SysAdmin_V2 — Section 4 — Fichiers / Partages / DFS**
   - base pour `Get-SmbSession`, `Get-SmbOpenFile`, `Get-SmbShare`

2. **BUNDLE_KP_SysAdmin_V2 — Section 8 — Patching et maintenance**
   - rappel de séquencement par rôle
   - validation des accès et de l'état avant reboot
   - pending reboot check

3. **BUNDLE_KP_SysAdmin_V2 — Section 10 — Health Check serveur**
   - base pour le contrôle uptime / pending reboot / services auto stoppés

4. **BUNDLE_KP_SysAdmin_V2 — Section 12 — Templates CW**
   - structure de base pour la note interne et la discussion client-safe

### Référence complémentaire utile
- **TEMPLATE_BUNDLE_CW_CLOSE**
  - pour la formulation normalisée des livrables de clôture

---

## Version réutilisable — résumé ultra court

1. Valider la fenêtre approuvée
2. Vérifier `Get-SmbOpenFile`
3. Si résultat non vide = **NO-GO**
4. Faire fermer les fichiers
5. Revalider `Get-SmbOpenFile`
6. Si résultat vide = **GO reboot**
7. Redémarrer
8. Postcheck : uptime, flags pending reboot, services SMB, partages, fichiers ouverts, erreurs depuis le boot
9. Clôturer CW

---

## Nom recommandé pour classement KB
`EXEMPLE_Intervention_PendingReboot_FileServer_Windows.md`
