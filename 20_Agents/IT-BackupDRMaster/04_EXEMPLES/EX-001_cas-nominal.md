# EX-001 — Cas nominal : Triage job Veeam en échec VSS
**Agent :** IT-BackupDRMaster | **Mode :** VEEAM_TRIAGE | **Statut :** PASS

---

## INPUT
```yaml
mode: VEEAM_TRIAGE
client: "Acme Corp"
billet: "T1601500"
systeme: "SRV-SQL01"
erreur: "Failed to create VSS snapshot. VSS snapshot failed."
```

## OUTPUT
```yaml
result:
  mode: VEEAM_TRIAGE
  severity: P2
  summary: "Job Veeam en échec — VSS writer SQL défaillant sur SRV-SQL01"
  details: |
    Cause identifiée : service SQL Server VSS Writer arrêté sur SRV-SQL01.
    Ce writer est requis pour créer un snapshot application-consistent des bases SQL.
    Vérification :
      vssadmin list writers  →  SQL Server Writer : Failed [LastError: 0x800423f4]
    Actions :
      1. net stop SQLWriter
      2. net start SQLWriter
      3. Relancer le job Veeam manuellement
      4. Vérifier le résultat — attendu : Success
  impact: "Backup SQL non application-consistent depuis hier soir"
  validation_requise: "Confirmer que le job relancé est Success avant fermeture"

artifacts:
  - type: powershell
    title: "Vérification et redémarrage VSS Writer SQL"
    content: |
      # ⚠️ Impact : redémarrage du service SQLWriter — interruption < 30s
      vssadmin list writers | Select-String -Pattern "SQL Server Writer" -Context 0,3
      # Si Failed :
      net stop SQLWriter; net start SQLWriter
      # Relancer le job Veeam (remplacer par le nom exact du job)
      Start-VBRJob -Job (Get-VBRJob -Name "BACKUP-SRV-SQL01")

next_actions:
  - "Surveiller le job relancé — doit terminer en Success"
  - "Ajouter surveillance service SQLWriter dans RMM (alerte si arrêté)"
  - "Créer article KB si premier incident de ce type"

escalade:
  requis: false

log:
  decisions:
    - "Relancer le writer sans escalade — correction standard N3"
  risks:
    - "Si job échoue à nouveau → escalade IT-Commandare-Infra"
  assumptions:
    - "Bases SQL non corrompues — backup avant-hier était Success"
```
