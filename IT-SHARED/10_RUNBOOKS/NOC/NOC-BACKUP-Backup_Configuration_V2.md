# NOC-BACKUP-Backup_Configuration_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

## 1. VEEAM — VALIDATION CONFIGURATION

```powershell
Connect-VBRServer -Server localhost
Get-VBRJob | Select-Object Name, JobType, IsScheduleEnabled, Result | Format-Table
Get-VBRBackupRepository | Select-Object Name,
  @{N='Free_GB';E={[math]::Round($_.Info.CachedFreeSpace/1GB,1)}},
  @{N='Free_PCT';E={[math]::Round($_.Info.CachedFreeSpace/$_.Info.CachedTotalSpace*100,0)}}
```

**Checklist Veeam :**
- [ ] Repository configure (local / cloud / partner)
- [ ] Retention definie (minimum 7 jours, recommande 30 jours)
- [ ] Fenetres de sauvegarde configurees (heures creuses)
- [ ] Notifications email activees
- [ ] GFS configure pour retention longue (weekly/monthly/yearly)
- [ ] Test restauration planifie (SureBackup ou manuel trimestriel)

---

## 2. DATTO — VALIDATION CONFIGURATION

**Checklist Datto :**
- [ ] Agent Datto installe et actif sur tous les serveurs proteges
- [ ] Backup initial (seeding) complete — valide dans le portail partenaire
- [ ] Screenshot verification active (preuve de restaurabilite)
- [ ] Retention locale configuree (min 7 jours)
- [ ] Retention cloud configuree selon contrat client
- [ ] Alertes email configurees dans le portail
- [ ] Test restauration fichier effectue et documente

---

## 3. KEEPIT — VALIDATION M365 BACKUP

**Checklist Keepit :**
- [ ] Connecteur M365 autorise (compte admin global requis)
- [ ] Services selectionnes : Exchange / SharePoint / OneDrive / Teams
- [ ] Retention configuree (1 an minimum standard MSP)
- [ ] Alertes activees (echecs de sauvegarde)
- [ ] Test restauration email effectue
- [ ] Documentation Hudu mise a jour

---

## 4. DOCUMENTATION POST-CONFIGURATION

Mettre a jour Hudu avec :
- Nom de la solution backup et version
- Fenetre de sauvegarde et retention configuree
- Contacts pour les alertes
- Date du dernier test de restauration reussi
- RTO / RPO definis avec le client
