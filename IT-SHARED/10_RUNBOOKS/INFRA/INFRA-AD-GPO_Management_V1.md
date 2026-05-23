# INFRA-AD-GPO_Management_V1
**Version :** 1.0 | **Date :** 2026-05-16 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-Assistant-N2 | @IT-Assistant-N3 | @IT-Commandare-Infra | @IT-MaintenanceMaster
**Département :** INFRA | **Domaine :** AD (Active Directory — Group Policy)
**Durée estimée :** 15–60 min selon opération

---

## OBJECTIF

Procédures complètes pour auditer, comprendre, créer et dépanner les Group Policy Objects (GPO) dans un environnement Active Directory géré par un MSP.
Couvre : audit initial, nommage, héritage, liaison, bonnes pratiques MSP et diagnostic.

> **Règle absolue :** Ne jamais modifier la `Default Domain Policy` ni la `Default Domain Controllers Policy` sans validation N3 + client.

---

## PRÉ-REQUIS

| Élément | Requis |
|---|---|
| Accès | Administrateur du domaine (ou délégation GPO) |
| Outils | PowerShell 5.1+ avec module `GroupPolicy`, RSAT-GroupPolicy, GPMC |
| Snapshot / Backup | Backup AD recommandé avant toute création/modification GPO |
| Fenêtre de maintenance | Confirmée pour tout changement en production |
| CW Ticket | Ouvert et en cours avant toute intervention |

```powershell
# Vérifier que le module GroupPolicy est disponible
Get-Module -ListAvailable -Name GroupPolicy
# Si absent, installer RSAT (sur un poste Windows 10/11)
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
```

---

## SECTION 1 — AUDIT GPO AVANT TOUTE INTERVENTION

> Toujours commencer par cet audit. Ne jamais créer ou modifier une GPO sans avoir fait l'inventaire.

### 1A — Lister toutes les GPO du domaine

```powershell
# Import du module
Import-Module GroupPolicy

# Lister toutes les GPO avec nom, état, dates
Get-GPO -All | Select-Object `
    DisplayName,
    GpoStatus,
    CreationTime,
    ModificationTime,
    Id `
| Sort-Object DisplayName `
| Format-Table -AutoSize

# Export CSV pour documentation
Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime, Id |
    Export-Csv -Path "C:\Temp\GPO_Audit_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation -Encoding UTF8
```

**Statuts possibles (`GpoStatus`) :**

| Valeur | Signification |
|---|---|
| `AllSettingsEnabled` | GPO active (Computer + User) |
| `ComputerSettingsDisabled` | Seuls les paramètres utilisateur s'appliquent |
| `UserSettingsDisabled` | Seuls les paramètres ordinateur s'appliquent |
| `AllSettingsDisabled` | GPO désactivée — n'applique rien |

### 1B — Lister les liaisons GPO (scope : domaine / OU / site)

```powershell
# Lister toutes les GPO avec leurs liaisons (OU, site, domaine)
$Domain = (Get-ADDomain).DistinguishedName
Get-GPO -All | ForEach-Object {
    $gpo = $_
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    $xml = [xml]$report
    $links = $xml.GPO.LinksTo
    if ($links) {
        foreach ($link in $links.Link) {
            [PSCustomObject]@{
                GPO_Name    = $gpo.DisplayName
                Linked_To   = $link.SOMPath
                LinkEnabled = $link.Enabled
                Enforced    = $link.NoOverride
                GPO_Status  = $gpo.GpoStatus
                Modified    = $gpo.ModificationTime
            }
        }
    } else {
        [PSCustomObject]@{
            GPO_Name    = $gpo.DisplayName
            Linked_To   = "NON LIEE"
            LinkEnabled = $false
            Enforced    = $false
            GPO_Status  = $gpo.GpoStatus
            Modified    = $gpo.ModificationTime
        }
    }
} | Sort-Object Linked_To | Format-Table -AutoSize

# Identifier les GPO non liées (orphelines)
Write-Host "`n=== GPO ORPHELINES (non liées) ===" -ForegroundColor Yellow
Get-GPO -All | ForEach-Object {
    $gpo = $_
    $report = [xml](Get-GPOReport -Guid $gpo.Id -ReportType Xml)
    if (-not $report.GPO.LinksTo) {
        Write-Host "  ORPHELINE: $($gpo.DisplayName)" -ForegroundColor Yellow
    }
}
```

---

## SECTION 2 — COMPRENDRE LES NOMS DE GPO

### 2A — Convention de nommage recommandée (MSP)

Format standard : `[SCOPE]-[FONCTION]-[VERSION]`

| Composant | Description | Exemples |
|---|---|---|
| `SCOPE` | Étendue cible | `CORP`, `SERVERS`, `LAPTOPS`, `USERS`, `SITE-MTL` |
| `FONCTION` | Ce que fait la GPO | `SEC-Firewall`, `SW-Chrome`, `MAP-Drives`, `AUDIT-Policy` |
| `VERSION` | Numéro de version | `v1`, `v2` |

**Exemples de noms bien formés :**

```
CORP-SEC-PasswordPolicy-v1          → Politique de mot de passe, tout le domaine
SERVERS-SEC-Hardening-v2            → Hardening sécurité, OU Serveurs
LAPTOPS-SW-ChromeDeployment-v1      → Déploiement Chrome, OU Laptops
USERS-MAP-NetworkDrives-v1          → Mappage lecteurs réseau, OU Utilisateurs
SITE-MTL-NET-ProxySettings-v1       → Proxy spécifique au site Montréal
```

### 2B — Décoder les noms non standardisés

Pour une GPO au nom ambigu (ex: `GPO_TEST_FINALE_2023`, `Politique Marie`, `New Group Policy Object`), utiliser les commandes de la Section 3 pour inspecter le contenu réel.

```powershell
# Recherche par mot-clé dans les noms de GPO
$keyword = "proxy"  # Adapter
Get-GPO -All | Where-Object { $_.DisplayName -like "*$keyword*" } |
    Select-Object DisplayName, GpoStatus, ModificationTime | Format-Table -AutoSize

# Lister toutes les GPO sans convention de nommage (ne contenant pas de tiret)
Get-GPO -All | Where-Object { $_.DisplayName -notmatch '-' } |
    Select-Object DisplayName, GpoStatus, CreationTime | Format-Table -AutoSize
```

### 2C — Documenter une GPO au nom ambigu

1. Inspecter son contenu (Section 3A)
2. Vérifier où elle est liée (Section 1B)
3. Vérifier qui l'a créée et quand (Section 1A — ModificationTime + CreationTime)
4. Ajouter un commentaire dans les propriétés de la GPO :

```powershell
# Ajouter/mettre à jour la description d'une GPO
Set-GPO -Name "GPO_TEST_FINALE_2023" -Description "Contient: Proxy IE forcé à 10.0.0.1:8080 — Créée par Jean D. mars 2023 — A standardiser"
```

---

## SECTION 3 — IDENTIFIER LES PARAMÈTRES DANS UNE GPO EXISTANTE

### 3A — Lister tous les settings d'une GPO par nom

```powershell
# Rapport HTML complet d'une GPO (ouvre dans le navigateur)
$GPOName = "CORP-SEC-PasswordPolicy-v1"  # Adapter
Get-GPOReport -Name $GPOName -ReportType Html -Path "C:\Temp\GPO_Report_$GPOName.html"
Start-Process "C:\Temp\GPO_Report_$GPOName.html"

# Rapport XML pour traitement PowerShell
$xml = [xml](Get-GPOReport -Name $GPOName -ReportType Xml)

# Afficher les paramètres Computer Configuration
$xml.GPO.Computer.ExtensionData | ForEach-Object {
    Write-Host "Extension: $($_.Name)" -ForegroundColor Cyan
    $_.Extension | ForEach-Object { $_ }
}

# Afficher les paramètres User Configuration
$xml.GPO.User.ExtensionData | ForEach-Object {
    Write-Host "Extension: $($_.Name)" -ForegroundColor Cyan
}
```

### 3B — Chercher un paramètre spécifique dans TOUTES les GPO

```powershell
# Recherche d'un paramètre par mot-clé dans toutes les GPO (scan XML)
$SearchTerm = "proxy"  # Adapter — insensible à la casse
$Results = @()

Get-GPO -All | ForEach-Object {
    $gpo = $_
    try {
        $reportXml = Get-GPOReport -Guid $gpo.Id -ReportType Xml -ErrorAction Stop
        if ($reportXml -match $SearchTerm) {
            $Results += [PSCustomObject]@{
                GPO_Name = $gpo.DisplayName
                GPO_ID   = $gpo.Id
                Status   = $gpo.GpoStatus
            }
        }
    } catch {
        Write-Warning "Impossible de lire la GPO: $($gpo.DisplayName)"
    }
}

Write-Host "`n=== GPO contenant '$SearchTerm' ===" -ForegroundColor Green
$Results | Format-Table -AutoSize
```

### 3C — Identifier les GPO redondantes ou en conflit

```powershell
# Lister toutes les GPO liées à la même OU — détecter les doublons potentiels
$TargetOU = "OU=Utilisateurs,DC=contoso,DC=local"  # Adapter

$linked = Get-GPInheritance -Target $TargetOU
Write-Host "GPO appliquées à $TargetOU (ordre de traitement) :" -ForegroundColor Cyan
$linked.GpoLinks | Select-Object DisplayName, Order, Enabled, Enforced | Format-Table -AutoSize

# Rapport consolidé de toutes les GPO liées à une OU avec leurs settings
$linked.GpoLinks | ForEach-Object {
    $name = $_.DisplayName
    Write-Host "`n--- GPO: $name ---" -ForegroundColor Yellow
    $xml = [xml](Get-GPOReport -Name $name -ReportType Xml)
    $hasComputer = $xml.GPO.Computer.ExtensionData -ne $null
    $hasUser = $xml.GPO.User.ExtensionData -ne $null
    Write-Host "  Computer Settings: $(if ($hasComputer) {'OUI'} else {'vide'})"
    Write-Host "  User Settings:     $(if ($hasUser) {'OUI'} else {'vide'})"
}
```

---

## SECTION 4 — HÉRITAGE ET APPLICATION DES GPO

### 4A — Ordre d'application (LSDOU)

Les GPO s'appliquent dans cet ordre — le dernier l'emporte (sauf `Enforced`) :

```
1. LOCAL        → Stratégie locale de la machine (gpedit.msc)
2. SITE         → GPO liées au site AD (ex: Site-MTL)
3. DOMAINE      → GPO liées à la racine du domaine
4. OU PARENTE   → GPO liées à l'OU parent (ex: OU=France)
5. OU ENFANT    → GPO liées à l'OU cible (ex: OU=Paris)
```

**Règle :** En cas de conflit entre deux paramètres identiques, c'est la GPO la plus proche de l'objet (OU enfant) qui gagne, **sauf** si une GPO parente est marquée `Enforced`.

### 4B — Block Inheritance et Enforced

| Mécanisme | Effet | Commande |
|---|---|---|
| `Block Inheritance` | L'OU ignore les GPO héritées des niveaux supérieurs | `Set-GPInheritance -Target $OU -IsBlocked Yes` |
| `Enforced` (No Override) | La GPO s'impose même si l'OU a Block Inheritance | `Set-GPLink -Name $GPO -Target $OU -Enforced Yes` |

```powershell
# Vérifier le Block Inheritance sur une OU
$OU = "OU=Serveurs,DC=contoso,DC=local"
$inheritance = Get-GPInheritance -Target $OU
Write-Host "Block Inheritance: $($inheritance.GpoInheritanceBlocked)"
Write-Host "GPO héritées:" -ForegroundColor Cyan
$inheritance.InheritedGpoLinks | Select-Object DisplayName, Order, Enforced | Format-Table

# Vérifier quelles GPO sont Enforced (No Override)
Get-GPO -All | ForEach-Object {
    $gpo = $_
    $xml = [xml](Get-GPOReport -Guid $gpo.Id -ReportType Xml)
    $xml.GPO.LinksTo.Link | Where-Object { $_.NoOverride -eq $true } | ForEach-Object {
        Write-Host "ENFORCED: $($gpo.DisplayName) → $($_.SOMPath)" -ForegroundColor Red
    }
}
```

### 4C — Diagnostiquer pourquoi un paramètre ne s'applique pas

```powershell
# Sur la machine/session utilisateur cible — générer un rapport RSoP HTML
gpresult /h "C:\Temp\GPResult_$(hostname)_$(Get-Date -Format 'yyyyMMdd_HHmm').html" /f
Start-Process "C:\Temp\GPResult_$(hostname)_$(Get-Date -Format 'yyyyMMdd_HHmm').html"

# Résumé rapide en console (Computer + User)
gpresult /r

# Résumé pour un utilisateur spécifique sur un ordinateur distant
gpresult /s NOMSERVEUR /user DOMAINE\jdupont /r

# Voir uniquement les GPO appliquées (filtrées)
gpresult /r /scope computer   # Paramètres ordinateur
gpresult /r /scope user       # Paramètres utilisateur
```

**Points de blocage courants à vérifier avec gpresult :**

| Symptôme dans gpresult | Cause probable |
|---|---|
| GPO listée dans "Denied" | Security Filtering — l'objet n'a pas les droits `Read` + `Apply` |
| GPO absente de la liste | Pas liée à la bonne OU, ou link désactivé |
| GPO listée mais paramètre absent | Paramètre écrasé par une GPO de priorité plus haute |
| "WMI filter" — False | Le filtre WMI ne correspond pas à la machine |

---

## SECTION 5 — AVANT DE CRÉER UNE NOUVELLE GPO

### 5A — Checklist obligatoire

```
[ ] 1. Le paramètre n'existe pas déjà dans une GPO existante
        → Utiliser la recherche Section 3B avant de créer
[ ] 2. La Default Domain Policy n'est PAS l'endroit approprié
        → Toujours créer une GPO dédiée
[ ] 3. L'OU cible est correctement identifiée et documentée
        → Confirmer la portée avec le client si doute
[ ] 4. Les conflits potentiels avec les GPO existantes ont été analysés
        → Vérifier Section 3C sur l'OU cible
[ ] 5. La GPO a un nom conforme à la convention [SCOPE]-[FONCTION]-[VERSION]
[ ] 6. La GPO est créée en staging (OU de test) avant la prod
[ ] 7. Le ticket CW est mis à jour avec la justification
[ ] 8. Un backup GPO est effectué avant toute modification
```

### 5B — Backup GPO avant toute intervention

```powershell
# Backup de TOUTES les GPO du domaine
$BackupPath = "C:\Temp\GPO_Backup_$(Get-Date -Format 'yyyyMMdd_HHmm')"
New-Item -Path $BackupPath -ItemType Directory -Force
Backup-GPO -All -Path $BackupPath
Write-Host "Backup complet dans: $BackupPath" -ForegroundColor Green

# Backup d'une seule GPO
Backup-GPO -Name "CORP-SEC-PasswordPolicy-v1" -Path $BackupPath

# Lister les backups disponibles
Get-GPOBackup -Path $BackupPath | Select-Object DisplayName, BackupId, Timestamp | Format-Table
```

---

## SECTION 6 — LIER UNE GPO À UNE OU

### 6A — Liaison PowerShell

```powershell
# Variables — adapter
$GPOName  = "LAPTOPS-SW-ChromeDeployment-v1"
$TargetOU = "OU=Laptops,OU=Postes,DC=contoso,DC=local"

# Lier la GPO à l'OU (activée, non enforced par défaut)
New-GPLink -Name $GPOName -Target $TargetOU -LinkEnabled Yes

# Lier avec Enforced (utiliser avec parcimonie)
New-GPLink -Name $GPOName -Target $TargetOU -LinkEnabled Yes -Enforced Yes

# Définir l'ordre de priorité (1 = plus haute priorité)
Set-GPLink -Name $GPOName -Target $TargetOU -Order 1

# Désactiver temporairement une liaison (sans supprimer)
Set-GPLink -Name $GPOName -Target $TargetOU -LinkEnabled No
```

### 6B — Vérification post-liaison

```powershell
# Vérifier que la GPO est bien liée et dans le bon ordre
$TargetOU = "OU=Laptops,OU=Postes,DC=contoso,DC=local"
$inheritance = Get-GPInheritance -Target $TargetOU
Write-Host "GPO liées à $TargetOU :" -ForegroundColor Cyan
$inheritance.GpoLinks | Select-Object DisplayName, Order, Enabled, Enforced | Format-Table -AutoSize

# Forcer la mise à jour de la stratégie sur une machine (voir Section 8)
Invoke-GPUpdate -Computer "NOM-PC-TEST" -Force -RandomDelayInMinutes 0

# Vérifier l'application après gpupdate
gpresult /s NOM-PC-TEST /r
```

---

## SECTION 7 — BONNES PRATIQUES MSP

### 7A — Règles fondamentales

| Règle | Justification |
|---|---|
| Ne jamais modifier `Default Domain Policy` | Risque d'impact global non maîtrisé |
| Ne jamais modifier `Default Domain Controllers Policy` | Réservé aux paramètres DC critiques — sécurité audit |
| 1 GPO = 1 fonction | Facilite le diagnostic, désactivation ciblée |
| Tester en OU staging avant prod | Limite l'impact en cas d'erreur |
| Toujours documenter (description + ticket) | Traçabilité MSP obligatoire |
| Versionner les GPO (`v1`, `v2`) | Facilite le rollback et l'historique |
| Éviter les GPO liées au niveau domaine sauf si nécessaire | Porte d'application trop large |

### 7B — Organisation recommandée des GPO par domaine fonctionnel

```
SÉCURITÉ
  CORP-SEC-PasswordPolicy-v1          → Politique de mot de passe domaine
  CORP-SEC-AccountLockout-v1          → Verrouillage de compte
  SERVERS-SEC-Hardening-v2            → Durcissement serveurs
  LAPTOPS-SEC-BitLocker-v1            → Chiffrement BitLocker
  LAPTOPS-SEC-Firewall-v1             → Firewall Windows

DÉPLOIEMENT LOGICIEL
  LAPTOPS-SW-Office365-v1             → Installation M365 Apps
  LAPTOPS-SW-Chrome-v1                → Déploiement Chrome
  SERVERS-SW-Agents-v1                → Agents RMM / AV

MAPPAGE LECTEURS RÉSEAU
  USERS-MAP-Drives-Commun-v1          → Lecteur Z: partagé
  USERS-MAP-Drives-Departement-v1     → Lecteurs par département (avec Item-Level Targeting)

PARAMÈTRES UTILISATEUR
  USERS-CFG-Wallpaper-v1              → Fond d'écran corporatif
  USERS-CFG-IE-Proxy-v1               → Paramètres proxy navigateur
  USERS-CFG-StartMenu-v1              → Configuration menu démarrer

PARAMÈTRES ORDINATEUR
  CORP-CFG-WindowsUpdate-v1           → Configuration Windows Update (WSUS)
  CORP-CFG-TimeSync-v1                → Synchronisation NTP
  CORP-CFG-RemoteDesktop-v1           → Paramètres RDP
```

### 7C — OU de staging pour les tests

```powershell
# Créer une OU de test si elle n'existe pas
New-ADOrganizationalUnit -Name "STAGING_GPO_TEST" -Path "DC=contoso,DC=local" `
    -Description "OU de test GPO — Aucun objet de production"

# Lier la nouvelle GPO au staging en premier
$GPOName  = "LAPTOPS-SEC-BitLocker-v1"
$StagingOU = "OU=STAGING_GPO_TEST,DC=contoso,DC=local"
New-GPLink -Name $GPOName -Target $StagingOU -LinkEnabled Yes

# Après validation en staging — lier à la prod
$ProdOU = "OU=Laptops,OU=Postes,DC=contoso,DC=local"
New-GPLink -Name $GPOName -Target $ProdOU -LinkEnabled Yes
```

---

## SECTION 8 — DIAGNOSTIC ET DÉPANNAGE

### 8A — Forcer la mise à jour des stratégies

```powershell
# Sur la machine locale
gpupdate /force

# Sur une machine distante via PowerShell
Invoke-GPUpdate -Computer "NOM-PC" -Force -RandomDelayInMinutes 0
# Inclure les paramètres utilisateur
Invoke-GPUpdate -Computer "NOM-PC" -Force -RandomDelayInMinutes 0 -Target "All"

# Sur plusieurs machines en parallèle
$Machines = @("PC001","PC002","PC003")
$Machines | ForEach-Object -Parallel {
    Invoke-GPUpdate -Computer $_ -Force -RandomDelayInMinutes 0 -ErrorAction SilentlyContinue
    Write-Host "gpupdate lancé sur $_"
} -ThrottleLimit 5
```

### 8B — Rapport RSoP détaillé (gpresult)

```powershell
# Rapport HTML complet — le plus complet pour le diagnostic
gpresult /h "C:\Temp\GPResult.html" /f
Start-Process "C:\Temp\GPResult.html"

# Console — résumé rapide
gpresult /r

# Pour un utilisateur spécifique sur machine distante
gpresult /s NOM-MACHINE /user DOMAINE\jdupont /h "C:\Temp\GPResult_jdupont.html" /f

# Voir les GPO refusées (Denied GPOs) — très utile pour le diagnostic
gpresult /r 2>&1 | Select-String -Pattern "Denied|Raison|Reason|DENIED"
```

### 8C — Event Viewer — Événements Group Policy critiques

Chemin : `Applications and Services Logs > Microsoft > Windows > Group Policy > Operational`

| Event ID | Sévérité | Signification | Action |
|---|---|---|---|
| `4016` | Info | Début du traitement des GPO | Normal |
| `5016` | Info | Fin du traitement des GPO — succès | Normal |
| `1085` | Erreur | Échec application d'une extension GPO (ex: Software Installation) | Voir Section 8D |
| `1125` | Erreur | Impossible de joindre le DC pour récupérer les GPO | Vérifier connectivité réseau/DNS |
| `1129` | Erreur | Traitement GPO échoué — erreur réseau | Vérifier réplication AD et connectivité |
| `7016` | Avertissement | Délai dépassé pour une extension GPO | Extensions lentes — vérifier charge |

```powershell
# Lire les événements Group Policy en erreur sur une machine
Get-WinEvent -ComputerName "NOM-MACHINE" -LogName "Microsoft-Windows-GroupPolicy/Operational" |
    Where-Object { $_.LevelDisplayName -in ('Error','Warning') } |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Sort-Object TimeCreated -Descending |
    Format-List

# Filtrer sur les Event ID critiques
Get-WinEvent -ComputerName "NOM-MACHINE" -FilterHashtable @{
    LogName = 'Microsoft-Windows-GroupPolicy/Operational'
    Id      = @(1085, 1125, 1129, 7016)
    StartTime = (Get-Date).AddHours(-24)
} | Select-Object TimeCreated, Id, Message | Format-List
```

### 8D — GPO qui ne s'applique pas — Arbre de diagnostic

```
1. gpresult /r → La GPO est-elle dans la liste "Applied GPOs" ?
   │
   ├─ NON → La GPO est-elle dans "Denied GPOs" ?
   │         ├─ OUI → Vérifier Security Filtering (Section 8E)
   │         └─ NON → GPO pas liée à la bonne OU ? Link désactivé ?
   │
   └─ OUI → Le paramètre est-il bien visible dans le rapport HTML ?
             ├─ NON → Écrasé par une GPO de priorité plus haute → Section 3C
             └─ OUI → Délai d'application ? → gpupdate /force + redémarrage
```

### 8E — Security Filtering et WMI Filters

```powershell
# Vérifier le Security Filtering d'une GPO
# Par défaut, "Authenticated Users" doit avoir Read + Apply Group Policy
$GPOName = "LAPTOPS-SEC-BitLocker-v1"
Get-GPPermission -Name $GPOName -All | Select-Object Trustee, Permission | Format-Table

# Ajouter un groupe au Security Filtering (remplace Authenticated Users si nécessaire)
# 1. Ajouter le groupe avec Read + Apply
Set-GPPermission -Name $GPOName -TargetName "GRP_Laptops_GPO" -TargetType Group -PermissionLevel GpoApply

# 2. Retirer Authenticated Users si on veut restreindre à ce groupe seulement
Set-GPPermission -Name $GPOName -TargetName "Authenticated Users" -TargetType Group -PermissionLevel GpoRead
# ATTENTION : laisser au moins Read à Authenticated Users pour que les DCs puissent traiter la GPO

# Vérifier les WMI Filters associés à une GPO
$gpo = Get-GPO -Name $GPOName
if ($gpo.WmiFilter) {
    Write-Host "WMI Filter actif: $($gpo.WmiFilter.Name)" -ForegroundColor Yellow
    Write-Host "Query: $($gpo.WmiFilter.Query)"
} else {
    Write-Host "Aucun WMI Filter sur cette GPO" -ForegroundColor Green
}
```

### 8F — Vérifier la réplication SYSVOL (GPO non appliquée sur certains DCs)

```powershell
# Vérifier l'état DFSR (réplication SYSVOL)
$DCs = Get-ADDomainController -Filter * | Select-Object -ExpandProperty HostName
foreach ($DC in $DCs) {
    Write-Host "`n=== SYSVOL sur $DC ===" -ForegroundColor Cyan
    Invoke-Command -ComputerName $DC -ScriptBlock {
        dfsrdiag ReplicationState /member:$env:COMPUTERNAME
    } -ErrorAction SilentlyContinue
}

# Vérifier que la GPO existe dans SYSVOL sur chaque DC
$GPOGUID = (Get-GPO -Name "LAPTOPS-SEC-BitLocker-v1").Id.ToString()
$Domain   = (Get-ADDomain).DNSRoot
foreach ($DC in $DCs) {
    $path = "\\$DC\SYSVOL\$Domain\Policies\{$GPOGUID}"
    if (Test-Path $path) {
        Write-Host "OK: $DC — $path" -ForegroundColor Green
    } else {
        Write-Host "MANQUANT: $DC — $path" -ForegroundColor Red
    }
}
```

---

## SECTION 9 — ROLLBACK GPO

```powershell
# Restaurer une GPO depuis un backup
$BackupPath = "C:\Temp\GPO_Backup_20260516_0900"
$GPOName    = "LAPTOPS-SEC-BitLocker-v1"

# Lister les backups disponibles pour retrouver le bon BackupId
Get-GPOBackup -Path $BackupPath | Where-Object { $_.DisplayName -eq $GPOName } |
    Select-Object DisplayName, BackupId, Timestamp | Format-Table

# Restaurer (remplace la GPO actuelle par la version backupée)
$BackupId = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"  # Copier le BackupId depuis la liste
Restore-GPO -BackupId $BackupId -Path $BackupPath

Write-Host "GPO restaurée. Vérifier avec: Get-GPOReport -Name '$GPOName' -ReportType Html -Path C:\Temp\post_restore.html"
```

---

## RÉFÉRENCES RAPIDES

| Commande | Usage |
|---|---|
| `Get-GPO -All` | Lister toutes les GPO |
| `Get-GPOReport -Name $n -ReportType Html` | Rapport HTML d'une GPO |
| `Get-GPInheritance -Target $OU` | Héritage GPO d'une OU |
| `New-GPLink -Name $n -Target $OU` | Lier une GPO à une OU |
| `Set-GPLink -Name $n -Target $OU -Enforced Yes` | Enforcer une liaison |
| `Backup-GPO -All -Path $path` | Backup toutes les GPO |
| `Restore-GPO -BackupId $id -Path $path` | Restaurer une GPO |
| `gpresult /h rapport.html /f` | Rapport RSoP HTML complet |
| `gpupdate /force` | Forcer l'application des GPO |
| `Invoke-GPUpdate -Computer $pc -Force` | gpupdate sur machine distante |

---

*INFRA-AD-GPO_Management_V1 — MSP Intelligence AI — 2026-05-16*
