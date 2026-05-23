# NAMING_STANDARDS_v1.md
# Source de vérité — Conventions de nommage IT
# Version : 1.0 | Date : 2026-03-02 | Statut : ACTIF

---

## Règle fondamentale
> Un nom doit être lisible sans contexte. En regardant le nom seul, on doit savoir :
> quoi, où, quand, et dans quel billet.

---

## Format de date universel

```
YYYYMMDD_HHMM
```

| ✅ Correct | ❌ Incorrect |
|-----------|------------|
| `20260302_2145` | `02-03-26_21h45` |
| `20260302_2145` | `2026-03-02 21:45` |
| `20260302_2145` | `Mars2026` |

Utilisé partout : snapshots, logs, transcripts, noms de fichiers.

---

## Catégories standardisées

Utilisées dans tous les noms (scripts, logs, tâches, KB).

| Code | Domaine | Exemples d'usage |
|------|---------|-----------------|
| `MAINT` | Maintenance, patching, fenêtres | Scripts de patch, plans de maintenance |
| `DIAG` | Diagnostic, troubleshooting | Scripts de collecte, investigation |
| `AUDIT` | Audit, conformité, inventaire | Audits licences, assets, sécurité |
| `SECU` | Sécurité, SOC | IR, hardening, audit local admin |
| `BACKUP` | Backup, DR, validation | Vérification jobs, tests DR |
| `REPORT` | Rapports, exports | Rapports mensuels, QBR |
| `DEPLOY` | Déploiement, migration | Déploiement agents, migrations |
| `CONFIG` | Configuration, GPO, politiques | Application de GPO, config RMM |

---

## Snapshots VMware / Hyper-V

### Format
```
@[BILLET]_[PHASE]_[SERVEUR]_SNAP_[YYYYMMDD_HHMM]
```

### Règles
- `@` devant le billet : identifiant visuel immédiat dans la liste de snapshots
- BILLET : numéro ConnectWise sans espaces → `T12345`
- PHASE : choisir dans la liste ci-dessous, respecter la casse (PascalCase)
- SERVEUR : nom exact du serveur tel qu'il apparaît dans vCenter/Hyper-V

### Phases valides

| Phase | Quand l'utiliser |
|-------|-----------------|
| `Preboot` | Avant tout redémarrage |
| `Postpatch` | Après application des patches, avant reboot |
| `PreReboot` | Juste avant un reboot planifié |
| `PostReboot` | Validation post-reboot |
| `PreMigration` | Avant une migration de VM ou de données |
| `PostMigration` | Après migration complète |
| `PreUpgrade` | Avant upgrade d'OS ou d'application critique |
| `PreChange` | Avant tout changement majeur non couvert ci-dessus |

### Exemples

```
@T12345_Preboot_SRV-DC01_SNAP_20260302_2145
@T12345_Postpatch_SRV-SQL02_SNAP_20260302_2230
@T12345_PreMigration_SRV-FILE01_SNAP_20260303_0800
@T67890_PreUpgrade_SRV-EXCH01_SNAP_20260315_0100
@T67890_PostMigration_SRV-APP01_SNAP_20260315_0345
```

### ⚠️ Anti-patterns à éviter
```
# Mauvais — pas de billet
SRV-DC01_snap_avant_patch

# Mauvais — date illisible
@T12345_Preboot_SRV-DC01_03022026

# Mauvais — phase vague
@T12345_Avant_SRV-DC01_SNAP_20260302_2145
```

---

## Scripts PowerShell — nommage fichier

### Format
```
[CATEGORIE]_[ACTION]_[CIBLE]_v[VERSION].ps1
```

### Règles
- CATEGORIE : code standardisé (voir tableau ci-dessus)
- ACTION : verbe ou nom d'action en PascalCase → `Patching` `HealthCheck` `Cleanup` `Validation`
- CIBLE : serveur, groupe, ou scope → `AllServers` `DC` `SQL` `Exchange` `ADUsers`
- VERSION : `v1` `v2` etc. — incrémenter à chaque modification majeure

### Exemples
```
MAINT_Patching_AllServers_v1.ps1
MAINT_HealthCheck_DC_v2.ps1
AUDIT_DiskSpace_AllServers_v1.ps1
AUDIT_LocalAdmin_v1.ps1
DIAG_Validation_SQL_v1.ps1
DIAG_PendingReboot_AllServers_v1.ps1
SECU_AuditLocalAdmin_v1.ps1
BACKUP_VerifyJobs_Veeam_v1.ps1
CONFIG_SetNTP_AllServers_v1.ps1
```

---

## Fichiers de logs / transcripts

### Format
```
[CATEGORIE]_[SERVEUR]_[BILLET]_[YYYYMMDD_HHMM].log
```

### Arborescence
```
C:\IT_LOGS\
├── MAINT\
│   └── MAINT_SRV-DC01_T12345_20260302_2145.log
├── DIAG\
│   └── DIAG_SRV-SQL02_T12346_20260303_0910.log
├── AUDIT\
│   └── AUDIT_SRV-FILE01_T12347_20260304_1400.log
├── SECU\
│   └── SECU_SRV-DC01_T12348_20260305_0800.log
└── BACKUP\
    └── BACKUP_SRV-VEEAM01_T12349_20260306_0200.log
```

### Règles
- Dossier CATEGORIE créé automatiquement si absent (script standard le gère)
- SERVEUR : `$env:COMPUTERNAME` si script local, sinon nom cible
- BILLET : numéro CW sans @ dans les noms de fichiers

---

## Tâches planifiées (Scheduled Tasks)

### Format
```
IT_[CATEGORIE]_[ACTION]_[FRÉQUENCE]
```

### Exemples
```
IT_MAINT_Patching_Nightly
IT_MAINT_Patching_Weekly
IT_BACKUP_Verify_Daily
IT_AUDIT_DiskSpace_Weekly
IT_AUDIT_LocalAdmin_Monthly
IT_CONFIG_SetNTP_Daily
```

---

## Noms dans CW / KB / Documentation

### Format (lisible, tirets)
```
[CATEGORIE]-[ACTION]-[CIBLE]-v[VERSION]
```

### Exemples
```
MAINT-HealthCheck-DC-v2
MAINT-Patching-AllServers-v1
DIAG-PendingReboot-AllServers-v1
AUDIT-DiskSpace-Servers-v1
SECU-AuditLocalAdmin-v1
```

---

## Évolution de ce document

Ce fichier est la **source de vérité**. Toute nouvelle convention doit être ajoutée ici avant d'être utilisée.

| Version | Date | Changement |
|---------|------|-----------|
| 1.0 | 2026-03-02 | Création initiale : snapshots, scripts, logs, tasks, KB |
