# TEMPLATE LIBRARY — IT-AssistanceTI_N2 et N3 - IT-MaintenanceMaster et autre assistant (MASTER)
**Version :** 1.0 | **Date :** 2026-03-15 | **Agent :** IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Source :** Fusion de 39 fichiers → 20 stubs exclus → 15 templates uniques

---

## TABLE DES MATIÈRES

| # | Catégorie | Template | Usage |
|---|-----------|----------|-------|
| 1.1 | ConnectWise | CW Discussion STAR (règles) | Règle + format rapide |
| 1.2 | ConnectWise | CW Discussion STAR (complet) | Format détaillé + exemples |
| 1.3 | ConnectWise | CW Note Interne (complet) | Note technique détaillée |
| 1.4 | ConnectWise | CW Note Interne (timeline) | Format horodaté |
| 1.5 | ConnectWise | CW Template Library (macros) | /template injectables |
| 2.1 | Communication | Email Client Maintenance | Email post-intervention |
| 2.2 | Communication | Teams Notice | Annonce début/fin |
| 3.1 | Rapports | Rapport Mensuel IT | Mensuel client |
| 3.2 | Rapports | QBR (Quarterly Business Review) | Trimestriel direction |
| 3.3 | Rapports | Postmortem d'Incident | Post-incident P1/P2 |
| 3.4 | Rapports | Cloud Health Report | Multi-cloud M365/Azure/AWS |
| 3.5 | Rapports | Azure Health Report | Azure spécifique |
| 3.6 | Rapports | Rapport Backup | VEEAM/Datto état backups |
| 3.7 | Rapports | Rapport DR Test | Test Disaster Recovery |
| 4.1 | Technique | Architecture Cloud | Document architecture |

---

---
# SECTION 1 — CONNECTWISE
---

## 1.1 — CW DISCUSSION STAR (Règles)

# CW_DISCUSSION_STAR — Template

Règle : commencer par l’une des phrases imposées :
- Prendre connaissance de la demande et connexion à la documentation de l'entreprise.
- Préparation et découverte. Consultation de la documentation.

Ensuite, STAR (facturable, sans IP, sans détails sensibles) :

S (Situation) : [Contexte court — fenêtre hors heures / serveurs / impact attendu]
T (Task)      : [Objectif — appliquer CU + sécurité, valider services]
A (Action)    : [Actions clés — pré-check, patch via ConnectWise RMM, reboots contrôlés, post-check/tests]
R (Result)    : [Résultat — services OK / conformité / exceptions + suivi]

Exemple :
Préparation et découverte. Consultation de la documentation.
S : Fenêtre hors heures pour maintenance Windows sur serveurs applicatifs.
T : Appliquer CU/sécurité et confirmer l’état des services critiques.
A : Pré-check santé, déploiement des correctifs approuvés via ConnectWise RMM, redémarrages contrôlés, validations post-patch.
R : Serveurs opérationnels après redémarrage; suivi planifié pour correctifs non critiques si applicable.


---

## 1.2 — CW DISCUSSION STAR (Format complet + exemples)

# TEMPLATE: CW_DISCUSSION (Note ConnectWise - Facturable)

## Objectif
Générer un résumé en bullet points qui apparaîtra sur la facture client. Doit être:
- ✅ Format STAR
- ✅ Clair et concis
- ✅ Sans informations sensibles (mots de passe, IPs internes, détails sécurité)
- ✅ Orienté valeur/résultats

## Format

```
INTERVENTION: [Type d'intervention]
DATE: [Date]
TECHNICIEN: [Nom ou initiales]

TRAVAUX EFFECTUÉS:
• [Action 1 - résultat client-visible]
• [Action 2 - résultat client-visible]
• [Action 3 - résultat client-visible]
• [Action 4 - résultat client-visible]

RÉSULTAT:
• [Impact positif pour le client]
• [Confirmation de bon fonctionnement]

[Optionnel] RECOMMANDATION:
• [Suggestion pour le client]
```

## Exemples par type d'intervention

### Exemple 1: Patching de serveurs

```
INTERVENTION: Maintenance serveurs (mises à jour sécurité)
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Vérification pré-déploiement
• Vérification de l'état des dernières sauvegardes, prise de Snapshot
• Vérification de l'état général des serveurs, services en cours et fichiers journaux
• Installation des mises à jour de sécurité Microsoft sur 5 serveurs
• Redémarrages planifiés et supervisés hors heures d'affaires
• Vérification du bon démarrage de tous les services critiques
• Tests de connectivité et accessibilité des applications

RÉSULTAT:
• Tous les serveurs à jour avec les derniers correctifs de sécurité
• Aucun impact sur les opérations de l'entreprise
• Services opérationnels confirmés

RECOMMANDATION:
• Prochaine fenêtre de maintenance recommandée: Mars 2026
```

### Exemple 2: Troubleshooting backup

```
INTERVENTION: Résolution problème de sauvegarde
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Prise de connaissance de la demande et connexion à la documentation
• Connexion au serveur de sauvegarde
• Diagnostic de l'échec de sauvegarde du serveur SRV-FILE01
• Résolution du problème d'espace disque sur le dépôt de backup
• Lancement manuel de la sauvegarde et vérification de la réussite
• Mise en place d'alertes pour prévenir futures occurrences

RÉSULTAT:
• Sauvegarde fonctionnelle et complétée avec succès
• Espace libéré sur le dépôt (ancien backups archivés)
• Alertes configurées pour prévenir le problème

RECOMMANDATION:
• Envisager augmentation capacité stockage backup d'ici 3 mois
```

### Exemple 3: Maintenance réseau

```
INTERVENTION: Mise à jour équipements réseau
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Prise de connaissance de la demande et connexion à la documentation
• Mise à jour firmware du pare-feu Watchguard
• Application des correctifs de sécurité recommandés
• Vérification de la configuration post-mise à jour
• Tests de connectivité Internet et VPN

RÉSULTAT:
• Pare-feu mis à jour avec dernières protections de sécurité
• Connectivité confirmée (Internet, VPN, accès distant)
• Aucune interruption de service observée
```

### Exemple 4: Audit/Vérification

```
INTERVENTION: Audit de l'infrastructure serveurs
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Vérification de l'état de santé de 8 serveurs
• Contrôle de l'espace disque disponible
• Analyse des journaux d'événements (30 derniers jours)
• Vérification du statut des services critiques

RÉSULTAT:
• Infrastructure en bon état général
• Quelques alertes mineures identifiées et résolues
• Aucun problème critique détecté

RECOMMANDATION:
• Prévoir nettoyage fichiers temporaires sur SRV-APP01 (espace 85%)
```

### Exemple 5: Intervention d'urgence

```
INTERVENTION: Intervention urgente - Serveur inaccessible
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Diagnostic du serveur SRV-APP01 non accessible
• Redémarrage du serveur via console hyperviseur
• Vérification et correction de l'erreur de démarrage du service
• Restauration complète de l'accessibilité

RÉSULTAT:
• Serveur restauré et fonctionnel
• Services applicatifs redémarrés avec succès
• Utilisateurs peuvent accéder à nouveau aux applications

RECOMMANDATION:
• Surveillance renforcée du serveur sur 48h
• Analyse approfondie planifiée pour identifier cause racine
```

## Règles importantes

### ✅ À FAIRE
- Utiliser langage simple et compréhensible
- Mentionner résultats concrets
- Indiquer impacts positifs pour le client
- Être factuel et précis
- Inclure recommandations si pertinent

### ❌ À ÉVITER
- Jargon technique excessif
- Détails d'implémentation (ports, IPs, commandes)
- Informations sensibles (credentials, vulnérabilités)
- Blâmer ou critiquer
- Promesses non vérifiées

## Variables à personnaliser

```yaml
type_intervention: "[Maintenance/Troubleshooting/Audit/Urgence/...]"
date: "[YYYY-MM-DD]"
technicien: "[Initiales ou nom]"
travaux: "[Liste bullet points 3-6 items]"
resultat: "[Impact client 1-3 points]"
recommandation: "[Optionnel - 1-2 points]"
```

## Longueur recommandée
- **Minimum:** 4-5 bullet points
- **Idéal:** 6-8 bullet points
- **Maximum:** 10 bullet points

**Note:** Le client VOIT cette note sur sa facture. Elle doit démontrer la valeur du travail effectué tout en restant professionnelle et appropriée.

---

*Template version 1.0 - IT-MaintenanceMaster*


---

## 1.3 — CW NOTE INTERNE (Format complet)

# TEMPLATE: CW_NOTE_INTERNE (Note technique - Base de connaissance)

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


---

## 1.4 — CW NOTE INTERNE (Format timeline horodaté)

# TEMPLATE — CW_NOTE_INTERNE (TIMELINE)

> Préfixe imposé (choisir 1 et garder le même dans CW_DISCUSSION) :
- Prendre connaissance de la demande et connexion à la documentation de l'entreprise.
- Préparation et découverte. Consultation de la documentation.

## Contexte
- Ticket: [#]
- Client: [Nom]
- Fenêtre: [Début–Fin] (TZ)
- Scope: [Serveurs/Services]
- Contraintes: [Prod/VIP/No-touch/1 serveur critique à la fois]

## Pré-check (FAIT/CONFIRMÉ)
- Uptime / pending reboot: [...]
- Disques: [...]
- Services critiques (selon rôle): [...]
- Event logs récents: [...]
- Backups (si applicable): [...]

## Timeline (horodatée si possible)
- [HH:MM] /obs ...
- [HH:MM] /test ...
- [HH:MM] /cmd ...
- [HH:MM] /out ...
- [HH:MM] /decision ...

## Actions réalisées
- [Action 1] — résultat
- [Action 2] — résultat

## Validations post-actions
- Services: [...]
- App / accès: [...]
- Monitoring/alertes: [...]

## Anomalies / risques / écarts
- [...]

## Suivis / recommandations
- [...]


---

## 1.5 — CW TEMPLATE LIBRARY (Macros /template injectables)

# CW TEMPLATE LIBRARY — IT-MaintenanceMaster
_Bibliothèque de macros /template (checklists injectables)_

## Comment utiliser
- Dans le chat avec IT-MaintenanceMaster :
  - `/template <NOM>` pour injecter une checklist
  - `/result <num> <FAIT|KO|SKIP|À_SUIVRE> : <résultat>`
  - `/evidence <label> : <résumé preuve>` (+ capture)
  - `/close` pour générer CW_INTERNAL_NOTES + CW_DISCUSSION (+ email optionnel)

## Règle fixe (toujours dans NOTE INTERNE, première ligne)
- Prendre connaissance de la demande et connexion à la documentation de l'entreprise.
# CORE (transverse)

## /template start_standard
1. Reformuler la demande + impact (service/utilisateurs, urgence, scope).
2. Identifier le type : NOC | SOC | SUPPORT | OTHER.
3. Lister les objets concernés (serveur(s), compte(s), équipement(s), site(s), etc.).
4. Vérifier prérequis : accès/outils (RMM, DUO, M365, Firewall…), fenêtre maintenance, approbations.
5. Définir plan d’action (3–7 étapes) + critères de succès.
6. Définir le point de communication (quand informer le client : début / pendant / fin).

## /template evidence_capture
1. Pour chaque action : définir la preuve attendue (capture, statut RMM, message console, résultat test).
2. Toute preuve manquante doit être taggée **[À CONFIRMER]** + question/action associée.
3. Noter référence/indice de preuve (heure, outil, intitulé capture).
4. Client-safe : masquer IP/comptes/chemins/logs bruts (remplacer par [MASQUÉ]).

## /template noc_baseline
1. Vérifier l’état du serveur dans RMM (online + métriques).
2. Vérifier alertes monitoring (actuelles + 24h).
3. Vérifier sauvegardes récentes / snapshot (si applicable).
4. Vérifier capacité (CPU/RAM/Disk) + services critiques (selon client).
5. Préparer mitigation/rollback si échec ou perte de connectivité.
6. Validation finale : services OK + monitoring OK (sinon [À CONFIRMER]).

## /template soc_baseline
1. Triage alerte : source, horodatage, criticité.
2. Définir périmètre (assets, comptes, sites).
3. Containment si requis (isolation/quarantaine) **[À CONFIRMER]** si non validé.
4. Collecte IOC (interne seulement, jamais en client-safe).
5. Remédiation + vérifications (EDR/SIEM) + recommandations.
6. Validation finale : risque réduit + actions de suivi.

## /template support_baseline
1. Confirmer symptôme + impact.
2. Reproduire / collecter preuves.
3. Hypothèse cause + test (1–2 max).
4. Correctif + preuve.
5. Validation utilisateur / service.
6. Prévention (si applicable).

## /template closeout_validations
1. Services : OK | KO | [À CONFIRMER]
2. Monitoring : OK | KO | [À CONFIRMER]
3. Backups (si applicable) : OK | KO | [À CONFIRMER]
4. Validation utilisateur (si applicable) : OK | KO | [À CONFIRMER]
5. Prochaines étapes : aucune | suivi | action client

---

# NOC

## /template NOC.UPDATE_SERVER
1. Vérification de l'état du serveur dans RMM.
2. Connexion à DUO pour ByPassCode (si requis).
3. Vérification sauvegardes récentes / snapshot (si applicable).
4. Vérification espace disque / santé générale (services + event logs rapides).
5. Installation des mises à jour (KB/Drivers) via outil (RMM/WSUS/Intune/…).
6. Traitement des échecs (si applicable) + relance ciblée.
7. Redémarrage planifié (si requis).
8. Post-check : services critiques OK, accès OK, monitoring OK, état MAJ confirmé.

## /template NOC.REBOOT
1. Confirmer fenêtre de maintenance / impact accepté.
2. Vérifier sessions actives / tâches planifiées.
3. Redémarrer le serveur.
4. Validation post-reboot : services, connectivité, monitoring, journaux.

## /template NOC.BACKUP_FAIL
1. Vérifier l’erreur de job et la dernière exécution OK.
2. Vérifier espace repo / connectivité / credentials (sans les exposer).
3. Action corrective (selon outil) + relance.
4. Validation : job OK + monitoring/alerte normalisé.

---

# SOC

## /template SOC.EDR_ALERT
1. Collecter détails alerte (host, user, type, horodatage).
2. Triage : faux positif vs incident probable.
3. Containment (si requis) : isoler/quarantaine.
4. Remédiation : scan, nettoyage, suppression/quarantaine.
5. Validation : alerte close + recommandations.

## /template SOC.FW_RULE_CHANGE
1. Recueillir le flux à autoriser (src/dst/port/proto) + justification.
2. Créer la règle firewall (avec nommage/description).
3. Test de connectivité.
4. Documenter + plan rollback (désactivation règle).

## /template SOC.FW_UNBLOCK
1. Identifier ce qui bloque (log firewall, catégorie, IP/host masqué si client-safe).
2. Débloquer (exception temporaire ou permanente) + justification.
3. Tester.
4. Documenter + durée/expiration si temporaire.

---

# SUPPORT

## /template SUPPORT.M365_USER_ADD
1. Connexion au centre d’administration Microsoft 365.
2. Création utilisateur + paramètres de base.
3. Attribution licences.
4. MFA / Identity (si requis).
5. Exchange : boîte aux lettres / groupes / alias (si requis).
6. Validation : connexion + tests basiques.

## /template SUPPORT.EXCHANGE_TASK
1. Connexion au centre d’admin Exchange.
2. Action demandée (permissions, shared mailbox, transport rule, etc.).
3. Validation : tests (envoi/réception si applicable).
4. Documenter.

## /template SUPPORT.IDENTITY_MFA
1. Vérifier l’identité / méthode MFA.
2. Réinitialiser/ajuster MFA selon demande.
3. Validation : connexion OK.
4. Conseils utilisateur (client-safe).

---

# OTHER (générique)

## /template OTHER.GENERAL
1. Collecte : symptômes, impact, preuves.
2. Action principale.
3. Validation post-action.
4. Documentation / recommandations.


---
# SECTION 2 — COMMUNICATION
---

## 2.1 — EMAIL CLIENT (Maintenance / Intervention)

# TEMPLATE — EMAIL CLIENT (MAINTENANCE / INTERVENTION)

Objet: [Ticket #] — [Résumé court]

Bonjour,

Nous avons effectué les travaux planifiés sur votre infrastructure, incluant :
- [Action principale]
- [Validation principale]

Résultat :
- [État final / services OK]

Suivi recommandé (si applicable) :
- [Suivi 1]

Merci,

[Signature MSP]


---

## 2.2 — TEAMS NOTICE (Début / Fin — copiable)

# TEMPLATE — TEAMS NOTICE (COPIABLE)

## ⚠️ Début
(Caractère 12) [Client] — Début maintenance/intervention (#Ticket [#])
(Caractère 10) Fenêtre: [HH:MM–HH:MM]
(Caractère 10) Scope: [Serveurs/Services]
(
@NOC
## ✅ Fin
(Caractère 12) [Client] — Fin maintenance/intervention (#Ticket [#])
(Caractère 10) Résultat: [OK / Dégradé / Incident]
(Caractère 10) Suivi: [Aucun / Détails]


---
# SECTION 3 — RAPPORTS
---

## 3.1 — RAPPORT MENSUEL IT MSP

# TEMPLATE — Rapport Mensuel IT MSP
**ID :** TEMPLATE__RAPPORT_MENSUEL_V1  
**Agent producteur :** IT-ReportMaster  
**Fréquence :** Mensuelle | **Délai :** ≤ 5 jours ouvrables après fin de mois

---

# RAPPORT MENSUEL IT — [MOIS ANNÉE]

**Client :** [NOM CLIENT]  
**Préparé par :** [MSP NAME] — @IT-ReportMaster  
**Date de production :** [DATE]

---

## RÉSUMÉ DU MOIS

🟢 **Points positifs :** [2-3 points courts]  
🟡 **Points d'attention :** [1-2 si applicable]  
🔴 **Incidents notables :** [Si P1/P2 ont eu lieu]

---

## TICKETS DU MOIS

| Métrique | Ce mois | Mois précédent | Variation |
|---------|---------|---------------|-----------|
| Total ouverts | | | |
| Total fermés | | | |
| En cours (fin mois) | | | |
| FCR % | | | |

### Répartition par catégorie

| Catégorie | Nombre | % |
|----------|--------|---|
| Réseau | | |
| Serveurs/Infra | | |
| Cloud/M365 | | |
| Sécurité | | |
| Workstation/User | | |
| Maintenance | | |
| Autre | | |

---

## SLA & PERFORMANCE

| Niveau | Cible | Résultat | Statut |
|--------|-------|---------|--------|
| P1 | 98% | | 🟢/🟡/🔴 |
| P2 | 95% | | 🟢/🟡/🔴 |
| P3/P4 | 90% | | 🟢/🟡/🔴 |

**MTTR moyen :**
- P1 : [Xh]
- P2 : [Xh]
- P3 : [Xh]

---

## MAINTENANCE RÉALISÉE

| Date | Activité | Systèmes | Résultat |
|------|---------|---------|---------|
| | | | ✅ Succès |

---

## SÉCURITÉ

| Indicateur | Ce mois | Statut |
|-----------|---------|--------|
| Incidents sécurité | | |
| Patches critiques déployés | | |
| Compliance patch (%) | | 🟢/🟡/🔴 |
| Coverage EDR (%) | | 🟢/🟡/🔴 |

---

## INFRASTRUCTURE — ÉTAT DE SANTÉ

| Service | Uptime % | Incidents | Commentaire |
|---------|---------|---------|------------|
| Infrastructure principale | | | |
| Email | | | |
| Backup | | | |

---

## ACTIONS DU MOIS PROCHAIN

| Action | Type | Priorité | Date planifiée |
|--------|------|---------|--------------|
| | Maintenance/Projet/Suivi | | |

---

*Rapport généré par @IT-ReportMaster | Confidentiel*


---

## 3.2 — RAPPORT QBR (Quarterly Business Review)

# TEMPLATE — Rapport QBR (Quarterly Business Review) MSP
**ID :** TEMPLATE__QBR_REPORT_V1  
**Agent producteur :** IT-ReportMaster  
**Fréquence :** Trimestrielle | **Audience :** Direction client + MSP

---

# RAPPORT TRIMESTRIEL IT — Q[N] [ANNÉE]

**Client :** [NOM CLIENT]  
**Préparé par :** [MSP NAME]  
**Date :** [DATE]  
**Période couverte :** [DATE DÉBUT] — [DATE FIN]

---

## RÉSUMÉ EXÉCUTIF

> *2-3 phrases résumant le trimestre : performance globale, événements majeurs, tendances.*

[RÉSUMÉ EXÉCUTIF — À COMPLÉTER]

**Points clés du trimestre :**
- 🟢 [Succès/réalisation majeure]
- 🟢 [Deuxième point positif]
- 🟡 [Point d'attention]
- 🔴 [Défi/incident majeur si applicable]

---

## 1. PERFORMANCE DE SERVICE

### 1.1 Vue d'ensemble des tickets

| Métrique | Q[N] | Q[N-1] | Variation |
|---------|------|--------|-----------|
| Total tickets ouverts | | | |
| Total tickets fermés | | | |
| Tickets en cours (fin période) | | | |
| First Call Resolution % | | | |
| Ticket Reopen Rate % | | | |

### 1.2 Distribution par priorité

| Priorité | Nombre | % du total | SLA respecté % |
|---------|--------|-----------|----------------|
| P1 — Critique | | | |
| P2 — Élevé | | | |
| P3 — Moyen | | | |
| P4 — Faible | | | |

### 1.3 SLA Performance

| Niveau | Cible | Réalisé Q[N] | Statut |
|--------|-------|-------------|--------|
| P1 — Résolution 4h | 98% | | 🟢/🟡/🔴 |
| P2 — Résolution 8h | 95% | | 🟢/🟡/🔴 |
| P3 — Résolution 24h | 90% | | 🟢/🟡/🔴 |

### 1.4 Temps de résolution moyen (MTTR)

| Catégorie | MTTR Q[N] | MTTR Q[N-1] | Variation |
|-----------|-----------|-----------|-----------|
| P1 | | | |
| P2 | | | |
| Workstation/User | | | |
| Réseau | | | |
| Cloud/M365 | | | |

---

## 2. DISPONIBILITÉ INFRASTRUCTURE

### 2.1 Uptime par service critique

| Service | Uptime Q[N] | Cible | Incidents |
|---------|------------|-------|---------|
| Domain Controller | | 99.9% | |
| Exchange / M365 Email | | 99.9% | |
| Réseau principal | | 99.9% | |
| Serveurs applicatifs | | 99.5% | |
| VPN | | 99.5% | |

### 2.2 Incidents majeurs du trimestre

| Date | Incident | Durée | Impact | Résolu |
|------|---------|-------|--------|--------|
| | | | | |
| | | | | |

---

## 3. SÉCURITÉ

| Indicateur | Q[N] | Q[N-1] | Statut |
|-----------|------|--------|--------|
| Incidents sécurité | | | |
| Couverture EDR (%) | | | 🟢/🟡/🔴 |
| Couverture MFA (%) | | | 🟢/🟡/🔴 |
| CVEs critiques résolues | | | |
| Compliance patch (%) | | | 🟢/🟡/🔴 |

---

## 4. MAINTENANCE ET PROJETS

### 4.1 Maintenance réalisée

| Date | Activité | Systèmes | Résultat |
|------|---------|---------|---------|
| | Windows Patching | | ✅ |
| | | | |

### 4.2 Projets du trimestre

| Projet | Statut | % Complété | Commentaire |
|--------|--------|-----------|-------------|
| | ✅ Complété / 🔄 En cours / 📋 Planifié | | |

---

## 5. RECOMMANDATIONS Q[N+1]

### 5.1 Priorités recommandées

| # | Recommandation | Urgence | Effort | ROI estimé |
|---|--------------|---------|--------|-----------|
| 1 | | 🔴 Élevée | | |
| 2 | | 🟡 Moyenne | | |
| 3 | | 🟢 Faible | | |

### 5.2 Investissements proposés

| Projet | Description | Budget estimé | Justification |
|--------|-------------|-------------|--------------|
| | | | |

---

## 6. PLAN Q[N+1]

### Maintenances planifiées :
- [Date] — [Activité]
- [Date] — [Activité]

### Projets planifiés :
- [Projet 1] : [Description] — [Dates]
- [Projet 2] : [Description] — [Dates]

---

## ANNEXES

### A. Top 10 catégories de tickets (Q[N])
[Tableau ou graphique]

### B. Assets en fin de vie (12 prochains mois)
[Liste]

### C. Licences à renouveler (90 prochains jours)
[Liste]

---

*Document préparé par @IT-ReportMaster — [MSP NAME]*  
*Confidentiel — À l'usage exclusif de [CLIENT NAME] et [MSP NAME]*


---

## 3.3 — POSTMORTEM D'INCIDENT (P1/P2)

# TEMPLATE — Postmortem d'Incident IT
**ID :** TEMPLATE__POSTMORTEM_V2  
**Agent producteur :** IT-ReportMaster  
**Déclencheur :** Tout incident P1 ou P2 récurrent | **Délai :** ≤ 5 jours ouvrables post-résolution

---

# RAPPORT POSTMORTEM — [TITRE INCIDENT]

**Ticket CW :** [#TICKET]  
**Date/Heure incident :** [YYYY-MM-DD HH:MM]  
**Date/Heure résolution :** [YYYY-MM-DD HH:MM]  
**Durée totale :** [Xh Ymin]  
**Rédigé par :** [Technicien / Agent]  
**Révisé par :** [IT-Commandare-TECH / Senior]  
**Date du postmortem :** [YYYY-MM-DD]

---

## RÉSUMÉ EXÉCUTIF

> *2-3 phrases maximum. Non-technique. Répondre : Quoi s'est passé ? Quel impact ? Comment résolu ?*

[RÉSUMÉ EXÉCUTIF]

---

## IMPACT

| Dimension | Détail |
|-----------|--------|
| Services affectés | [Liste] |
| Utilisateurs touchés | [Nombre / Tous] |
| Durée d'interruption | [Xh Ymin] |
| Clients impactés | [Noms ou Tous] |
| SLA manqué | [Oui/Non — détail] |
| Perte estimée | [Si applicable] |

---

## TIMELINE DES ÉVÉNEMENTS

| Heure | Événement | Qui |
|-------|----------|-----|
| HH:MM | Déclenchement initial | [Monitoring/User/NOC] |
| HH:MM | Détection confirmée | |
| HH:MM | Premier technicien assigné | |
| HH:MM | [Action/découverte] | |
| HH:MM | Escalade vers [Agent/Senior] | |
| HH:MM | Cause racine identifiée | |
| HH:MM | Remédiation appliquée | |
| HH:MM | Service restauré | |
| HH:MM | Validation complète | |
| HH:MM | Ticket fermé | |

**MTTD (Détection) :** [Xh Ymin depuis début incident]  
**MTTR (Résolution) :** [Xh Ymin depuis ouverture ticket]

---

## ANALYSE CAUSE RACINE (5 Whys)

**Problème observé :** [Description symptôme final]

| Niveau | Pourquoi ? | Réponse |
|--------|-----------|---------|
| Why 1 | Pourquoi le service était-il down ? | |
| Why 2 | Pourquoi [réponse 1] ? | |
| Why 3 | Pourquoi [réponse 2] ? | |
| Why 4 | Pourquoi [réponse 3] ? | |
| Why 5 | Pourquoi [réponse 4] ? | |

**Cause racine identifiée :** [Description précise]

**Catégorie :** 
- [ ] Erreur humaine
- [ ] Défaillance matérielle
- [ ] Défaillance logicielle/bug
- [ ] Manque de monitoring
- [ ] Procédure absente ou inadéquate
- [ ] Changement non contrôlé
- [ ] Cause externe (FAI, fournisseur)

---

## CE QUI A BIEN FONCTIONNÉ

- [Point positif 1 — ex: détection rapide par monitoring]
- [Point positif 2]
- [Point positif 3]

---

## CE QUI PEUT ÊTRE AMÉLIORÉ

- [Amélioration 1 — ex: délai de détection trop long]
- [Amélioration 2]
- [Amélioration 3]

---

## PLAN D'ACTION

### Actions correctives (déjà prises)

| Action | Responsable | Complété le |
|--------|------------|------------|
| [Action déjà réalisée] | | [DATE] |

### Actions préventives (à planifier)

| # | Action | Responsable | Échéance | Statut |
|---|--------|------------|---------|--------|
| 1 | | | | 📋 À faire |
| 2 | | | | 📋 À faire |
| 3 | | | | 📋 À faire |

---

## COMMUNICATION EFFECTUÉE

| Destinataire | Canal | Message | Heure |
|-------------|-------|---------|-------|
| [Client] | Email/Teams | [Résumé] | |
| [Direction interne] | [Canal] | [Résumé] | |

---

## NOTES ADDITIONNELLES

[Tout autre élément pertinent, références tickets liés, KB créés]

---

**Règle non-blame :** Ce document vise l'amélioration des processus, pas l'identification de responsables.  
*Postmortem généré par @IT-ReportMaster — Confidentiel interne*


---

## 3.4 — CLOUD HEALTH REPORT (Multi-cloud : M365 / Azure / AWS / GCP)

# TEMPLATE: Cloud Health Report

## Informations du rapport

| Champ | Valeur |
|-------|--------|
| **Client** | [Nom du client] |
| **Période couverte** | [Date début] - [Date fin] |
| **Plateformes analysées** | ☐ Azure  ☐ M365  ☐ Google Workspace  ☐ AWS |
| **Date du rapport** | [Date génération] |
| **Préparé par** | IT-CloudMaster |
| **Version** | 1.0 |

---

## 📊 Résumé exécutif

### Vue d'ensemble
[Paragraphe de 3-4 phrases résumant l'état général de l'environnement cloud, les principales découvertes, et les actions recommandées.]

### Indicateurs clés

| Métrique | Valeur | Tendance | Objectif | Statut |
|----------|--------|----------|----------|--------|
| **Score de santé global** | [X]% | [↗/→/↘] | >90% | [🟢/🟡/🔴] |
| **Disponibilité (uptime)** | [X]% | [↗/→/↘] | >99.9% | [🟢/🟡/🔴] |
| **Conformité sécurité** | [X]% | [↗/→/↘] | 100% | [🟢/🟡/🔴] |
| **Utilisation licences** | [X]% | [↗/→/↘] | 85-95% | [🟢/🟡/🔴] |
| **Coût mensuel** | [X]$ | [↗/→/↘] | [Budget] | [🟢/🟡/🔴] |

**Légende:** 🟢 Bon | 🟡 Attention | 🔴 Critique

---

## 1️⃣ Azure

### 1.1 Vue d'ensemble infrastructure

#### Ressources déployées
| Type de ressource | Quantité | Coût mensuel | Variation |
|-------------------|----------|--------------|-----------|
| Virtual Machines | [X] | [X]$ | [±X]% |
| Storage Accounts | [X] | [X]$ | [±X]% |
| SQL Databases | [X] | [X]$ | [±X]% |
| App Services | [X] | [X]$ | [±X]% |
| Virtual Networks | [X] | [X]$ | [±X]% |
| **Total** | **[X]** | **[X]$** | **[±X]%** |

#### Performance et disponibilité
```
🟢 Uptime global: 99.98%
🟢 Temps réponse moyen: 45ms
🟡 Incidents: 2 (Sev 3)
🟢 Changements planifiés: 5 (100% réussis)
```

### 1.2 Sécurité et conformité

#### Azure Security Center - Secure Score
**Score actuel:** [X]/100 (Variation: [±X] points)

**Recommandations critiques:**
1. ⚠️ [Nombre] VMs sans patch récents
2. ⚠️ [Nombre] Storage accounts sans encryption at rest
3. ⚠️ [Nombre] NSG avec règles trop permissives

**Actions correctives:**
- [ ] Activer Update Management sur toutes VMs
- [ ] Forcer HTTPS sur tous Storage Accounts
- [ ] Revoir règles NSG et appliquer principe du moindre privilège

#### Conformité
| Standard | Statut | Score | Écarts |
|----------|--------|-------|--------|
| CIS Azure Benchmark | [🟢/🟡/🔴] | [X]% | [X] |
| ISO 27001 | [🟢/🟡/🔴] | [X]% | [X] |
| SOC 2 | [🟢/🟡/🔴] | [X]% | [X] |

### 1.3 Optimisation des coûts

#### Top 5 ressources par coût
1. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]
2. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]
3. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]
4. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]
5. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]

#### Opportunités d'économies
| Opportunité | Économie estimée | Effort | Priorité |
|-------------|------------------|--------|----------|
| Réserver VMs (1 an) | [X]$/mois ([X]%) | Faible | Haute |
| Resize under-utilized VMs | [X]$/mois ([X]%) | Moyen | Moyenne |
| Supprimer snapshots orphelins | [X]$/mois ([X]%) | Faible | Haute |
| Migrer vers Managed Disks | [X]$/mois ([X]%) | Élevé | Faible |

**Économies totales potentielles:** [X]$/mois ([X]% du budget actuel)

---

## 2️⃣ Microsoft 365

### 2.1 Licences et utilisation

#### Distribution des licences
| Type licence | Assignées | Utilisées | Disponibles | Taux d'utilisation |
|--------------|-----------|-----------|-------------|-------------------|
| M365 E3 | [X] | [X] | [X] | [X]% |
| M365 E5 | [X] | [X] | [X] | [X]% |
| M365 Business | [X] | [X] | [X] | [X]% |
| **Total** | **[X]** | **[X]** | **[X]** | **[X]%** |

**💡 Recommandation:** [Analyser si besoin d'acheter plus / réduire / redistribuer licences]

#### Services activés
```
✓ Exchange Online: [X] utilisateurs actifs
✓ SharePoint Online: [X] sites, [X] TB stockés
✓ OneDrive: [X] utilisateurs, [X] TB stockés
✓ Microsoft Teams: [X] équipes actives, [X] réunions/mois
✓ Yammer: [X] utilisateurs actifs
```

### 2.2 Sécurité Microsoft 365

#### Microsoft Secure Score
**Score actuel:** [X]/100 (Variation: [±X] points)

**Top 5 recommandations:**
1. 🔴 [Impact: +X points] - [Description recommandation]
2. 🟡 [Impact: +X points] - [Description recommandation]
3. 🟡 [Impact: +X points] - [Description recommandation]
4. 🟢 [Impact: +X points] - [Description recommandation]
5. 🟢 [Impact: +X points] - [Description recommandation]

#### Authentification et accès
| Métrique | Valeur | Cible |
|----------|--------|-------|
| Utilisateurs avec MFA | [X]% | 100% |
| Conditional Access policies | [X] actives | [X] recommandées |
| Comptes admin protégés | [X]% | 100% |
| Sign-ins risqués bloqués | [X] ce mois | Minimiser |

### 2.3 Conformité et gouvernance

#### Data Loss Prevention (DLP)
```
Politiques actives: [X]
Incidents détectés: [X]
Faux positifs: [X]
Actions automatiques: [X]
```

**Incidents notables:**
- [Date] - [Type] - [Description] - [Action prise]

#### Retention et eDiscovery
```
Politiques de rétention: [X] actives
Holds légaux: [X]
Recherches eDiscovery: [X] ce mois
Volume sous hold: [X] GB
```

### 2.4 Collaboration et productivité

#### Microsoft Teams
| Métrique | Ce mois | Mois précédent | Variation |
|----------|---------|----------------|-----------|
| Équipes actives | [X] | [X] | [±X]% |
| Canaux créés | [X] | [X] | [±X]% |
| Messages envoyés | [X]K | [X]K | [±X]% |
| Réunions tenues | [X] | [X] | [±X]% |
| Participants uniques | [X] | [X] | [±X]% |

**Tendance:** [↗ Adoption croissante / → Stable / ↘ En baisse]

#### SharePoint et OneDrive
```
Sites SharePoint: [X] (+[X] ce mois)
Stockage total: [X] TB / [X] TB ([X]% utilisé)
Fichiers partagés externes: [X] (tendance: [↗/→/↘])
OneDrive actifs: [X] utilisateurs ([X]% de la base)
```

---

## 3️⃣ Google Workspace

### 3.1 Licences et services

#### Distribution des licences
| Plan | Utilisateurs | Coût mensuel | Utilisation |
|------|--------------|--------------|-------------|
| Business Starter | [X] | [X]$ | [X]% |
| Business Standard | [X] | [X]$ | [X]% |
| Business Plus | [X] | [X]$ | [X]% |
| Enterprise | [X] | [X]$ | [X]% |
| **Total** | **[X]** | **[X]$** | **[X]%** |

### 3.2 Sécurité et administration

#### Rapports de sécurité
```
🟢 Validation en 2 étapes: [X]% des utilisateurs
🟡 Applications tierces autorisées: [X]
🟢 Alertes de sécurité: [X] ce mois
🟢 Comptes suspendus: [X]
```

#### Stockage Drive
```
Quota total: [X] TB
Utilisé: [X] TB ([X]%)
Top 5 utilisateurs:
  1. [user@domain] - [X] GB
  2. [user@domain] - [X] GB
  3. [user@domain] - [X] GB
  4. [user@domain] - [X] GB
  5. [user@domain] - [X] GB
```

---

## 4️⃣ AWS

### 4.1 Infrastructure et services

#### Services principaux
| Service | Ressources | Coût mensuel | Utilisation |
|---------|------------|--------------|-------------|
| EC2 | [X] instances | [X]$ | [X]% CPU avg |
| S3 | [X] buckets, [X] TB | [X]$ | [X] TB/mo transfer |
| RDS | [X] instances | [X]$ | [X]% connections |
| Lambda | [X] functions | [X]$ | [X]M invocations |
| **Total** | - | **[X]$** | - |

### 4.2 Sécurité AWS

#### AWS Security Hub
**Score de sécurité:** [X]/100

**Findings critiques:**
- 🔴 [Nombre] High severity findings
- 🟡 [Nombre] Medium severity findings
- 🟢 [Nombre] Low severity findings

**Top issues:**
1. [Description issue] - [Impact] - [Remediation]
2. [Description issue] - [Impact] - [Remediation]
3. [Description issue] - [Impact] - [Remediation]

#### IAM Best Practices
```
✓ Root account MFA: [Activé/Désactivé]
✓ IAM users avec MFA: [X]%
✓ Access keys rotated (<90 jours): [X]%
⚠ Policies trop permissives: [X]
✓ Service roles utilisés: [X]
```

---

## 📈 Tendances et analyses

### Évolution des coûts (6 derniers mois)
```
Mois 1: [X]$
Mois 2: [X]$ ([±X]%)
Mois 3: [X]$ ([±X]%)
Mois 4: [X]$ ([±X]%)
Mois 5: [X]$ ([±X]%)
Mois 6: [X]$ ([±X]%)

Tendance: [↗ Hausse / → Stable / ↘ Baisse]
Projection mois prochain: [X]$
```

### Incidents et disponibilité
```
Incidents totaux: [X]
  - Sev 1 (Critique): [X]
  - Sev 2 (Majeur): [X]
  - Sev 3 (Mineur): [X]

MTTR moyen: [X] heures
Uptime global: [X]%

Causes principales:
  1. [Cause] - [X] incidents
  2. [Cause] - [X] incidents
  3. [Cause] - [X] incidents
```

---

## 🎯 Recommandations prioritaires

### Haute priorité (< 30 jours)
1. **[Titre recommandation]**
   - **Impact:** [Description impact business/sécurité/coût]
   - **Effort:** [Faible/Moyen/Élevé] - [X heures]
   - **Économies/Gains:** [X]$/mois ou [Description bénéfice]
   - **Actions:** 
     - [ ] [Action 1]
     - [ ] [Action 2]
     - [ ] [Action 3]

2. **[Titre recommandation]**
   - **Impact:** [Description]
   - **Effort:** [Niveau]
   - **Économies/Gains:** [Montant]
   - **Actions:** [Liste]

### Moyenne priorité (30-90 jours)
1. **[Titre]** - [Description brève] - Impact: [X]
2. **[Titre]** - [Description brève] - Impact: [X]
3. **[Titre]** - [Description brève] - Impact: [X]

### Basse priorité (> 90 jours)
1. **[Titre]** - [Description brève]
2. **[Titre]** - [Description brève]

---

## 📋 Plan d'action

| # | Action | Responsable | Échéance | Statut | Notes |
|---|--------|-------------|----------|--------|-------|
| 1 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |
| 2 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |
| 3 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |
| 4 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |
| 5 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |

---

## 📎 Annexes

### A. Méthodologie
[Description de la méthodologie utilisée pour collecter les données, analyser l'environnement, et générer les recommandations]

### B. Outils utilisés
- Azure Monitor & Log Analytics
- Microsoft 365 Admin Center & Secure Score
- Google Workspace Admin Reports
- AWS CloudWatch & Security Hub
- Scripts PowerShell / Azure CLI / AWS CLI personnalisés

### C. Glossaire
| Terme | Définition |
|-------|------------|
| MTTR | Mean Time To Resolution - Temps moyen de résolution |
| Secure Score | Score de sécurité Microsoft (0-100) |
| DLP | Data Loss Prevention - Prévention de perte de données |
| NSG | Network Security Group - Groupe de sécurité réseau |
| IAM | Identity and Access Management |

### D. Contacts
| Rôle | Nom | Email | Téléphone |
|------|-----|-------|-----------|
| Cloud Architect | [Nom] | [Email] | [Tél] |
| Security Lead | [Nom] | [Email] | [Tél] |
| Support IT | [Équipe] | [Email] | [Tél] |

---

## 📝 Notes de fin de rapport

**Prochain rapport:** [Date]  
**Fréquence:** [Mensuel/Trimestriel]  
**Feedback:** [Email pour commentaires]

---

*Rapport généré par IT-CloudMaster le [Date]*  
*Version du template: 1.0*  
*Confidentiel - Usage interne uniquement*


---

## 3.5 — AZURE HEALTH REPORT

# TEMPLATE - Azure Health Report

**Date:** [DATE]  
**Période:** [PÉRIODE]  
**Analyste:** [NOM]  
**Tenant:** [NOM TENANT]

---

## 1. RÉSUMÉ EXÉCUTIF

### Santé globale
🟢 **Statut:** Healthy / 🟡 Warning / 🔴 Critical

### Points clés
- [Point important 1]
- [Point important 2]
- [Point important 3]

### Actions recommandées (Top 3)
1. [Action prioritaire 1]
2. [Action prioritaire 2]
3. [Action prioritaire 3]

---

## 2. COMPUTE (Virtual Machines)

### Vue d'ensemble
| Métrique | Valeur | Statut |
|----------|--------|--------|
| VMs totales | [X] | 🟢 |
| VMs en exécution | [X] | 🟢 |
| Utilisation CPU moyenne | [X]% | 🟢/🟡/🔴 |
| Utilisation RAM moyenne | [X]% | 🟢/🟡/🟢 |

### VMs nécessitant attention

#### CPU Over-utilized (>80% avg)
| VM Name | Resource Group | CPU Avg | Recommandation |
|---------|----------------|---------|----------------|
| [vm-name] | [rg-name] | [X]% | Resize to [SKU] |

#### Memory Over-utilized (>85% avg)
| VM Name | Resource Group | RAM Avg | Recommandation |
|---------|----------------|---------|----------------|
| [vm-name] | [rg-name] | [X]% | Resize to [SKU] |

#### Under-utilized (<20% CPU & <30% RAM)
| VM Name | Resource Group | CPU Avg | RAM Avg | Économie potentielle |
|---------|----------------|---------|---------|---------------------|
| [vm-name] | [rg-name] | [X]% | [X]% | [$X/mois] |

### Backup Status
| VM Name | Last Backup | Status | Action |
|---------|-------------|--------|--------|
| [vm-name] | [DATE] | ✓/✗ | [Action si requis] |

### Alertes actives
- [Alerte 1 - Description]
- [Alerte 2 - Description]

---

## 3. STORAGE

### Storage Accounts
| Account | Type | Used | Capacity | % Used | Status |
|---------|------|------|----------|--------|--------|
| [st-name] | [Premium/Standard] | [X GB] | [X GB] | [X]% | 🟢 |

### Blob Storage Tiers
| Hot | Cool | Archive | Recommandation |
|-----|------|---------|----------------|
| [X GB] | [X GB] | [X GB] | Move [X GB] to Cool tier → $[X]/mois savings |

### Disques non attachés
| Disk Name | Size | Type | Coût mensuel | Action |
|-----------|------|------|--------------|--------|
| [disk-name] | [X GB] | Premium SSD | $[X] | Delete/Archive |

**Économies potentielles:** $[X]/mois en supprimant disques orphelins

---

## 4. NETWORKING

### VNets et Peerings
| VNet | Address Space | Subnets | Peerings | Status |
|------|---------------|---------|----------|--------|
| [vnet-name] | [[IP_CLIENTE]/16] | [X] | [X] | 🟢 |

### NSG Rules Review
| NSG | Problème | Sévérité | Recommandation |
|-----|----------|----------|----------------|
| [nsg-name] | Any-Any rule found | 🔴 High | Restreindre source/destination |
| [nsg-name] | Port [X] ouvert à 0.0.0.0/0 | 🟡 Medium | Limiter par IP |

### Load Balancers Health
| LB Name | Backend Pools | Health Probes | Status |
|---------|---------------|---------------|--------|
| [lb-name] | [X] | [X/X healthy] | 🟢 |

### Public IPs non utilisées
| IP Name | Associated To | Action |
|---------|---------------|--------|
| [ip-name] | None | Delete → $[X]/mois savings |

---

## 5. SÉCURITÉ

### Azure Security Center Score
**Score actuel:** [X]/100

### Recommandations critiques
| Recommandation | Ressources affectées | Impact |
|----------------|---------------------|--------|
| [Recommandation 1] | [X] | High |
| [Recommandation 2] | [X] | Medium |

### Compliance Status
| Standard | Conformité | Actions requises |
|----------|------------|------------------|
| CIS Azure Benchmark | [X]% | [X] contrôles à corriger |
| ISO 27001 | [X]% | [X] contrôles à corriger |

### Vulnerabilities détectées
| Sévérité | Count | Exemple |
|----------|-------|---------|
| Critical | [X] | [CVE-XXXX sur vm-prod-01] |
| High | [X] | |
| Medium | [X] | |

### MFA Status (Azure AD)
| Total Users | MFA Enabled | % | Status |
|-------------|-------------|---|--------|
| [X] | [X] | [X]% | 🟢 (>95%) / 🟡 (80-95%) / 🔴 (<80%) |

---

## 6. COÛTS & OPTIMISATION

### Dépenses mensuelles
| Catégorie | Mois précédent | Mois actuel | Tendance |
|-----------|----------------|-------------|----------|
| Compute | $[X] | $[X] | ↗ ↘ → |
| Storage | $[X] | $[X] | ↗ ↘ → |
| Networking | $[X] | $[X] | ↗ ↘ → |
| **TOTAL** | **$[X]** | **$[X]** | **↗ ↘ →** |

### Top 5 ressources coûteuses
| Ressource | Type | Coût mensuel | Optimisation possible |
|-----------|------|--------------|---------------------|
| [resource-1] | VM | $[X] | Downsize → $[X] savings |
| [resource-2] | Storage | $[X] | Tier adjustment → $[X] savings |

### Économies identifiées

#### Immediate (Quick wins)
- Supprimer [X] disques non attachés → $[X]/mois
- Supprimer [X] IPs non utilisées → $[X]/mois
- **Total quick wins:** $[X]/mois

#### Short-term (1-3 mois)
- Resize [X] VMs over/under-utilized → $[X]/mois
- Acheter Reserved Instances pour [X] VMs → $[X]/mois (économie 30-40%)
- Migrer [X GB] vers Cool/Archive tier → $[X]/mois
- **Total short-term:** $[X]/mois

**Économies totales potentielles:** $[X]/mois ($[X]/an)

### Reserved Instances Opportunities
| VM SKU | Qty Running | RI Coverage | Économie potentielle (1yr) |
|--------|-------------|-------------|--------------------------|
| Standard_D2s_v3 | [X] | [X]% | $[X] |
| Standard_D4s_v3 | [X] | [X]% | $[X] |

---

## 7. DISPONIBILITÉ & PERFORMANCE

### SLA Status
| Service | Target SLA | Actual | Status |
|---------|-----------|--------|--------|
| VMs (Availability Set) | 99.95% | [X]% | 🟢/🟡/🔴 |
| Storage | 99.9% | [X]% | 🟢 |

### Incidents récents
| Date | Service | Impact | Durée | RCA |
|------|---------|--------|-------|-----|
| [DATE] | [Service] | [High/Med/Low] | [Xh] | [Lien/Résumé] |

### Maintenance planifiée
| Date | Service | Impact attendu | Action requise |
|------|---------|----------------|----------------|
| [DATE] | [Service] | [Description] | [Action] |

---

## 8. BACKUP & DISASTER RECOVERY

### Backup Compliance
| Total Protected Items | Last 24h Success | Failures | Status |
|---------------------|------------------|----------|--------|
| [X] VMs | [X] | [X] | 🟢/🟡/🔴 |
| [X] Databases | [X] | [X] | 🟢/🟡/🔴 |

### Backup Failures (si applicable)
| Item | Last Attempt | Error | Action |
|------|--------------|-------|--------|
| [vm-name] | [DATE] | [Error msg] | [Action] |

### DR Readiness
| Component | Status | Last Test | Next Test |
|-----------|--------|-----------|-----------|
| Failover plan | ✓ Documented | [DATE] | [DATE] |
| Test failover | ⚠ Overdue | [DATE] | **ASAP** |

---

## 9. RECOMMENDATIONS

### Priorité HAUTE (Immediate action)
1. **[Titre recommandation 1]**
   - Impact: [Security/Cost/Performance]
   - Effort: [Low/Medium/High]
   - Bénéfice: [Description]
   - Action: [Steps précis]

2. **[Titre recommandation 2]**
   - Impact: [Security/Cost/Performance]
   - Effort: [Low/Medium/High]
   - Bénéfice: [Description]
   - Action: [Steps précis]

### Priorité MOYENNE (1-3 mois)
1. [Recommandation]
2. [Recommandation]

### Priorité BASSE (Nice to have)
1. [Recommandation]
2. [Recommandation]

---

## 10. ACTIONS & FOLLOW-UP

### Actions assignées
| # | Action | Propriétaire | Échéance | Status |
|---|--------|-------------|----------|--------|
| 1 | [Action] | [Nom] | [DATE] | 🔄 En cours |
| 2 | [Action] | [Nom] | [DATE] | ⏳ Planifié |

### Prochaine revue
**Date:** [DATE]  
**Focus:** [Thèmes à approfondir]

---

## ANNEXES

### A. Méthodologie
- Période analysée: [DATE DÉBUT] → [DATE FIN]
- Outils utilisés: Azure Portal, Azure Monitor, Azure Advisor, Cost Management
- Metrics collectées: CPU, Memory, Disk, Network (avg 30 jours)

### B. Contacts
- **Azure Admin:** [Nom] - [Email]
- **Security Lead:** [Nom] - [Email]
- **FinOps:** [Nom] - [Email]

### C. Références
- Azure Advisor recommendations: [Lien]
- Cost Management dashboard: [Lien]
- Security Center: [Lien]

---

**Rapport généré le:** [DATE/TIME]  
**Prochain rapport:** [DATE]


---

## 3.6 — RAPPORT BACKUP (VEEAM / Datto)

# Rapport de Sauvegarde

**Agent:** @IT-BackupDRMaster
**Type de document:** backup_report
**Style:** Factuel, avec métriques, alertes colorées

---

## Sections


### 1. État backups

[Contenu de la section État backups]


### 2. Succès/Échecs

[Contenu de la section Succès/Échecs]


### 3. Stockage utilisé

[Contenu de la section Stockage utilisé]


### 4. Tests de restauration

[Contenu de la section Tests de restauration]


### 5. Actions

[Contenu de la section Actions]


---

## Instructions de Remplissage

Ce template doit être rempli avec:
- **Précision technique:** Détails factuels et vérifiables
- **Clarté:** Langage adapté à l'audience
- **Structure:** Respect de l'ordre des sections
- **Complétude:** Toutes les sections doivent être remplies

## Audience Cible

[Définir l'audience: technique, business, client, etc.]

## Format de Sortie

- Format: Markdown
- Style: Factuel, avec métriques, alertes colorées
- Longueur: Adapter selon le contexte (concis mais complet)

---

*Template généré automatiquement pour IT-BackupDRMaster*


---

## 3.7 — RAPPORT TEST DR (Disaster Recovery)

# Rapport Test DR

**Agent:** @IT-BackupDRMaster
**Type de document:** dr_test
**Style:** Structuré, mesurable, actionnable

---

## Sections


### 1. Scénario

[Contenu de la section Scénario]


### 2. Procédures testées

[Contenu de la section Procédures testées]


### 3. RTO/RPO mesurés

[Contenu de la section RTO/RPO mesurés]


### 4. Gaps

[Contenu de la section Gaps]


### 5. Améliorations

[Contenu de la section Améliorations]


---

## Instructions de Remplissage

Ce template doit être rempli avec:
- **Précision technique:** Détails factuels et vérifiables
- **Clarté:** Langage adapté à l'audience
- **Structure:** Respect de l'ordre des sections
- **Complétude:** Toutes les sections doivent être remplies

## Audience Cible

[Définir l'audience: technique, business, client, etc.]

## Format de Sortie

- Format: Markdown
- Style: Structuré, mesurable, actionnable
- Longueur: Adapter selon le contexte (concis mais complet)

---

*Template généré automatiquement pour IT-BackupDRMaster*


---
# SECTION 4 — TECHNIQUE
---

## 4.1 — ARCHITECTURE CLOUD

# Architecture Cloud

**Agent:** @IT-CloudMaster
**Type de document:** cloud_architecture
**Style:** Cloud-native, best practices AWS/Azure/GCP

---

## Sections


### 1. Services utilisés

[Contenu de la section Services utilisés]


### 2. Networking

[Contenu de la section Networking]


### 3. Security

[Contenu de la section Security]


### 4. Coûts

[Contenu de la section Coûts]


### 5. Scalability

[Contenu de la section Scalability]


### 6. DR

[Contenu de la section DR]


---

## Instructions de Remplissage

Ce template doit être rempli avec:
- **Précision technique:** Détails factuels et vérifiables
- **Clarté:** Langage adapté à l'audience
- **Structure:** Respect de l'ordre des sections
- **Complétude:** Toutes les sections doivent être remplies

## Audience Cible

[Définir l'audience: technique, business, client, etc.]

## Format de Sortie

- Format: Markdown
- Style: Cloud-native, best practices AWS/Azure/GCP
- Longueur: Adapter selon le contexte (concis mais complet)

---

*Template généré automatiquement pour IT-CloudMaster*


---

## NOTES DE CONSOLIDATION

| Stat | Valeur |
|------|--------|
| Fichiers source analysés | 39 |
| Stubs génériques exclus | 20 (contenu identique non opérationnel) |
| Doublons exacts exclus | — (inclus dans les stubs) |
| Templates uniques retenus | 15 |
| Fichiers réels traités | 4 groupes de doublons détectés et fusionnés |

**Règle de fusion appliquée :** quand plusieurs fichiers couvraient le même sujet,
le plus complet a été retenu (ex: CW Note Interne 543L > CW Internal Note 92L stub).
