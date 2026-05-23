# TEMPLATE: CW_NOTE_INTERNE (Note technique - Base de connaissance)
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Objectif
Générer une note technique détaillée UNIQUEMENT visible par les techniciens. Sert de:
- ✅ Documentation technique complète
- ✅ Base de connaissance pour interventions futures
- ✅ Référence pour troubleshooting similaires
- ✅ Traçabilité des actions techniques

## Format

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE - [TYPE]
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date/Heure: [YYYY-MM-DD HH:MM - HH:MM]
Technicien: [Nom complet]
Client: [Nom client]
Ticket CW: [CW-123456]
Serveurs/Équipements: [Liste]
Type intervention: [Maintenance/Troubleshooting/Urgence/Audit]

CONTEXTE INITIAL
----------------
[Description situation initiale]
[Pourquoi cette intervention était nécessaire]
[Symptômes observés / Demande initiale]

ENVIRONNEMENT TECHNIQUE
-----------------------
Serveurs concernés:
  • [Serveur 1]: [OS, rôle, version, IP]
  • [Serveur 2]: [OS, rôle, version, IP]
  • [...]

Hyperviseur:
  • Plateforme: [VMware ESXi 7.0 / Hyper-V Server 2022 / ...]
  • Version: [X.X.X]
  • Host: [Nom]

Réseau:
  • Pare-feu: [Watchguard M370 / Fortinet FG-100F / ...]
  • Firmware: [Version]
  • Switches: [Modèles]

Backup:
  • Solution: [VEEAM Backup & Replication 12 / Datto SIRIS / ...]
  • Version: [X.X]
  • Repo: [Localisation]

DIAGNOSTIC / ANALYSE
--------------------
[Étapes de diagnostic effectuées]

Erreurs observées:
  • Event Log: [ID événement, source, description]
  • Messages système: [Détails]
  • Codes erreur: [Si applicable]

Causes identifiées:
  • [Cause 1]
  • [Cause 2]

ACTIONS TECHNIQUES DÉTAILLÉES
------------------------------
[Chronologie des actions avec commandes exactes]

1. [Action 1]
   Commande exécutée:
   ```powershell
   [Commande PowerShell exacte]
   ```
   Résultat: [Output ou résultat]
   
2. [Action 2]
   Commande exécutée:
   ```powershell
   [Commande PowerShell exacte]
   ```
   Résultat: [Output ou résultat]

3. [...]

CONFIGURATIONS MODIFIÉES
-------------------------
[Tout changement de configuration]

Avant:
  • [Paramètre]: [Valeur avant]

Après:
  • [Paramètre]: [Valeur après]

Raison: [Justification du changement]

TESTS DE VALIDATION
--------------------
[Tests effectués pour confirmer résolution]

✓ Test 1: [Description] - SUCCÈS
✓ Test 2: [Description] - SUCCÈS
✓ Test 3: [Description] - SUCCÈS

RÉSULTAT FINAL
--------------
État: [RÉSOLU / PARTIELLEMENT RÉSOLU / EN COURS]

Services vérifiés:
  ✓ [Service 1]: Opérationnel
  ✓ [Service 2]: Opérationnel
  ✓ [Service 3]: Opérationnel

NOTES IMPORTANTES
-----------------
• [Information importante 1]
• [Information importante 2]
• [Particularités de cet environnement]

RECOMMANDATIONS TECHNIQUES
--------------------------
Court terme (< 1 mois):
  • [Recommandation 1]
  • [Recommandation 2]

Moyen terme (1-3 mois):
  • [Recommandation 1]

Long terme (> 3 mois):
  • [Recommandation 1]

SUIVI REQUIS
------------
□ Surveillance dans 24h: [Quoi surveiller]
□ Surveillance dans 1 semaine: [Quoi surveiller]
□ Tâche planifiée: [Description, échéance]

RÉFÉRENCES / LIENS UTILES
--------------------------
• KB Article: [Lien interne si applicable]
• Documentation vendor: [Lien]
• Ticket lié: [CW-XXXXX]

TEMPS INTERVENTION
------------------
Temps total: [X heures Y minutes]
  - Diagnostic: [X min]
  - Résolution: [X min]
  - Tests: [X min]
  - Documentation: [X min]

═══════════════════════════════════════════════════════════════
```

## Exemples par type d'intervention

### Exemple 1: Patching Windows Server

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE - PATCHING WINDOWS SERVER
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date/Heure: 2026-02-10 20:00 - 23:15
Technicien: Eric Archambault
Client: Otto Inc Inc.
Ticket CW: CW-789456
Serveurs/Équipements: SRV-DC01, SRV-APP01, SRV-SQL01, SRV-FILE01, SRV-WEB01
Type intervention: Maintenance préventive (patching mensuel)

CONTEXTE INITIAL
----------------
Fenêtre de maintenance mensuelle approuvée pour application des mises à jour
de sécurité Microsoft (Patch Tuesday - Février 2026).
Objectif: Mettre à jour 5 serveurs Windows Server 2022 avec les KB de février.
Tous les utilisateurs notifiés, backup pré-maintenance complété.

ENVIRONNEMENT TECHNIQUE
-----------------------
Serveurs concernés:
  • SRV-DC01: Windows Server 2022 DC, [IP_CLIENTE], vCPU:4 RAM:16GB
  • SRV-APP01: Windows Server 2022 Std, [IP_CLIENTE], vCPU:4 RAM:32GB
  • SRV-SQL01: Windows Server 2022 + SQL 2022, [IP_CLIENTE], vCPU:8 RAM:64GB
  • SRV-FILE01: Windows Server 2022 Std, [IP_CLIENTE], vCPU:2 RAM:16GB
  • SRV-WEB01: Windows Server 2022 + IIS, [IP_CLIENTE], vCPU:4 RAM:16GB

Hyperviseur:
  • Plateforme: VMware ESXi 8.0 U2
  • Version: 8.0.2 (build 22380479)
  • Host: esx-lab.otto-inc.local

DIAGNOSTIC / ANALYSE
--------------------
État pré-maintenance vérifié:

```powershell
# Vérification espace disque
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | 
    Select-Object DeviceID, @{N="FreeGB";E={[math]::Round($_.FreeSpace/1GB,2)}}
```

Tous serveurs: > 20GB disponible sur C: ✓

Mises à jour disponibles identifiées:
```powershell
Get-WindowsUpdate -ComputerName SRV-DC01,SRV-APP01,SRV-SQL01,SRV-FILE01,SRV-WEB01
```

Total: 15 KB de sécurité + 3 KB optionnels

ACTIONS TECHNIQUES DÉTAILLÉES
------------------------------

1. Installation updates sur SRV-FILE01 (non-critique en premier)
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-FILE01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 20:45, services UP à 20:52 ✓

2. Installation updates sur SRV-WEB01
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-WEB01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 21:10, IIS démarré automatiquement ✓

3. Installation updates sur SRV-APP01
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-APP01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 21:35, tous services applicatifs redémarrés ✓

4. Installation updates sur SRV-SQL01
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-SQL01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 22:05
   
   Vérification SQL Server post-reboot:
   ```powershell
   Get-Service -ComputerName SRV-SQL01 -Name MSSQLSERVER,SQLSERVERAGENT
   ```
   État: Running ✓
   
   Test connexion DB:
   ```powershell
   Test-DbaConnection -SqlInstance SRV-SQL01 -Database master
   ```
   Résultat: Success ✓

5. Installation updates sur SRV-DC01 (DC en dernier)
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-DC01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 22:40
   
   Vérification réplication AD:
   ```powershell
   repadmin /replsummary
   repadmin /showrepl
   ```
   État: Réplication OK, aucun échec ✓

CONFIGURATIONS MODIFIÉES
-------------------------
Aucune configuration modifiée. Installation patches uniquement.

TESTS DE VALIDATION
--------------------
✓ Test 1: Ping de tous serveurs - SUCCÈS
✓ Test 2: Accès RDP à tous serveurs - SUCCÈS
✓ Test 3: Services critiques (AD, SQL, IIS, partages fichiers) - SUCCÈS
✓ Test 4: Accès applications métier depuis poste test - SUCCÈS
✓ Test 5: Vérification Event Logs (pas d'erreurs critiques) - SUCCÈS

Commande validation finale:
```powershell
$servers = @("SRV-DC01","SRV-APP01","SRV-SQL01","SRV-FILE01","SRV-WEB01")
$servers | ForEach-Object {
    Test-Connection $_ -Count 2 -Quiet
    Get-Service -ComputerName $_ | Where-Object {$_.Status -ne 'Running' -and $_.StartType -eq 'Automatic'}
}
```
Résultat: Tous serveurs accessibles, aucun service automatique arrêté ✓

RÉSULTAT FINAL
--------------
État: RÉSOLU AVEC SUCCÈS

Services vérifiés:
  ✓ Active Directory: Opérationnel (SRV-DC01)
  ✓ SQL Server: Opérationnel (SRV-SQL01)
  ✓ IIS Web Server: Opérationnel (SRV-WEB01)
  ✓ Partages fichiers: Accessibles (SRV-FILE01)
  ✓ Applications métier: Fonctionnelles (SRV-APP01)

Tous serveurs: Niveau patch février 2026 appliqué ✓

NOTES IMPORTANTES
-----------------
• SRV-SQL01: Reboot a pris 8 minutes (normal pour SQL Server avec DBs importantes)
• SRV-DC01: Réplication AD vérifiée - aucun problème
• Aucune erreur critique dans Event Logs post-patching
• Snapshots VMware conservés 72h par précaution

RECOMMANDATIONS TECHNIQUES
--------------------------
Court terme (< 1 mois):
  • Supprimer snapshots VMware après validation (dans 3 jours)
  • Surveiller performance SRV-SQL01 (monitoring habituel)

Moyen terme (1-3 mois):
  • Prochaine fenêtre patching: Mars 2026 (2e mardi du mois)

SUIVI REQUIS
------------
□ Surveillance dans 24h: Event Logs tous serveurs
□ Surveillance dans 1 semaine: Performance applications
□ Tâche planifiée: Suppression snapshots (2026-02-13)

TEMPS INTERVENTION
------------------
Temps total: 3 heures 15 minutes
  - Préparation: 15 min
  - Patching: 2h 40 min
  - Tests validation: 15 min
  - Documentation: 5 min

═══════════════════════════════════════════════════════════════
```

### Exemple 2: Troubleshooting VEEAM

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE - TROUBLESHOOTING BACKUP VEEAM
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date/Heure: 2026-02-10 09:30 - 11:15
Technicien: Eric Archambault
Client: Otto Inc Inc.
Ticket CW: CW-789457
Serveurs/Équipements: SRV-FILE01, VEEAM-SRV
Type intervention: Troubleshooting urgent (backup failed)

CONTEXTE INITIAL
----------------
Alerte VEEAM reçue: Job "Daily Backup - File Servers" a échoué cette nuit.
Erreur: "Insufficient disk space on backup repository"
Impact: Backup SRV-FILE01 non complété depuis 24h

ENVIRONNEMENT TECHNIQUE
-----------------------
Serveurs concernés:
  • SRV-FILE01: Windows Server 2022, [IP_CLIENTE], 2TB données
  • VEEAM-SRV: Windows Server 2022, [IP_CLIENTE]

Backup:
  • Solution: VEEAM Backup & Replication 12.1.2
  • Job: "Daily Backup - File Servers"
  • Repository: "Backup-Repo-01" (NAS Synology)
  • Rétention: 14 jours

DIAGNOSTIC / ANALYSE
--------------------
Vérification status job VEEAM:
```powershell
Get-VBRJob -Name "Daily Backup - File Servers" | Get-VBRJobSession | Select -Last 5
```

Résultat: Derniers 2 runs = Failed

Vérification espace repository:
```powershell
Get-VBRBackupRepository -Name "Backup-Repo-01" | Select Name, FreeSpace, Capacity
```

Résultat:
  • Capacity: 10TB
  • FreeSpace: 45GB (0.45% libre) ⚠️
  • Threshold: 50GB minimum recommandé

Erreurs observées:
  • Event Log VEEAM: ID 190, "Insufficient disk space"
  • Job log: "Cannot write to backup file, disk full"

Causes identifiées:
  • Repository presque plein (99.55% utilisé)
  • Anciens backups pas supprimés automatiquement
  • GFS policy pas appliquée correctement

ACTIONS TECHNIQUES DÉTAILLÉES
------------------------------

1. Vérification retention policy
   ```powershell
   Get-VBRJob -Name "Daily Backup - File Servers" | Select RetentionPolicy
   ```
   Résultat: 14 restore points (correct)

2. Identification backup points à supprimer
   ```powershell
   Get-VBRBackup | Where-Object {$_.JobName -eq "Daily Backup - File Servers"} | 
       Get-VBRRestorePoint | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-14)}
   ```
   Résultat: 8 restore points > 14 jours trouvés

3. Suppression manuelle anciens restore points
   ```powershell
   $oldPoints = Get-VBRBackup | Where-Object {$_.JobName -eq "Daily Backup - File Servers"} | 
       Get-VBRRestorePoint | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-14)}
   
   $oldPoints | ForEach-Object { Remove-VBRRestorePoint -RestorePoint $_ -Confirm:$false }
   ```
   Résultat: 8 restore points supprimés, 1.2TB libéré ✓

4. Vérification espace post-cleanup
   ```powershell
   Get-VBRBackupRepository -Name "Backup-Repo-01" | Select FreeSpace
   ```
   Résultat: FreeSpace = 1.25TB (12.5% libre) ✓

5. Relance job backup manuellement
   ```powershell
   Start-VBRJob -Job (Get-VBRJob -Name "Daily Backup - File Servers")
   ```
   Résultat: Job démarré

6. Surveillance job en cours
   ```powershell
   Get-VBRJob -Name "Daily Backup - File Servers" | Get-VBRJobSession -Last | 
       Select State, Progress, @{N="Duration";E={(Get-Date) - $_.CreationTime}}
   ```
   Monitoring: Job complété après 45 minutes ✓

CONFIGURATIONS MODIFIÉES
-------------------------
Correction automation retention:

Avant:
  • Compact full backup file: Disabled

Après:
  • Compact full backup file: Enabled
  • Run immediately: Yes

Raison: Assurer suppression automatique anciens points

TESTS DE VALIDATION
--------------------
✓ Test 1: Job backup complété sans erreur - SUCCÈS
✓ Test 2: Espace repository > 10% - SUCCÈS (12.5%)
✓ Test 3: Restore point créé - SUCCÈS
✓ Test 4: Test restore 1 fichier - SUCCÈS

RÉSULTAT FINAL
--------------
État: RÉSOLU

Services vérifiés:
  ✓ VEEAM Backup Service: Running
  ✓ Repository accessible: OK
  ✓ Job planifié prochaine exécution: 2026-02-11 00:00

NOTES IMPORTANTES
-----------------
• Problème causé par échec automatic cleanup
• Compact full backup désactivé (?)
• Repository à surveiller mensuellement
• Envisager augmentation capacité dans 6 mois

RECOMMANDATIONS TECHNIQUES
--------------------------
Court terme (< 1 mois):
  • Surveiller espace repository hebdomadairement
  • Vérifier que compact runs correctement

Moyen terme (1-3 mois):
  • Review retention policy (peut-être réduire à 10 jours?)

Long terme (> 3 mois):
  • Planifier expansion repository (actuel 10TB → 15TB)
  • Considérer archivage vieux backups sur stockage froid

SUIVI REQUIS
------------
□ Surveillance dans 24h: Vérifier job ce soir
□ Surveillance dans 1 semaine: Espace repository
□ Tâche planifiée: Review capacity (2026-08-01)

RÉFÉRENCES / LIENS UTILES
--------------------------
• KB VEEAM: https://www.veeam.com/kb2197
• Ticket lié: CW-789450 (Installation VEEAM initiale)

TEMPS INTERVENTION
------------------
Temps total: 1 heure 45 minutes
  - Diagnostic: 20 min
  - Résolution: 60 min (cleanup + backup run)
  - Tests: 15 min
  - Documentation: 10 min

═══════════════════════════════════════════════════════════════
```

## Règles importantes

### ✅ À INCLURE
- Commandes PowerShell EXACTES utilisées
- Outputs/résultats des commandes
- Codes erreur Event Log avec ID et source
- IPs, credentials (si nécessaire pour reproduction)
- Tous détails techniques pertinents
- Screenshots d'erreurs si applicable

### ❌ À ÉVITER
- Langage vague ou générique
- Omettre commandes critiques
- Oublier détails environnement
- Ne pas documenter tests validation

## Utilisation comme base de connaissance

Cette note doit permettre à un autre technicien de:
1. Comprendre exactement ce qui a été fait
2. Reproduire l'intervention si nécessaire
3. Troubleshooter problèmes similaires
4. Apprendre de l'expérience

---

*Template version 1.0 - IT-MaintenanceMaster*
