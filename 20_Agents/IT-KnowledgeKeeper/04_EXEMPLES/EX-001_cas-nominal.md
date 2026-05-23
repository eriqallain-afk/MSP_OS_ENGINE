# EX-001 — KB : Veeam job en échec VSS SQL
```yaml
titre: "Veeam — Job backup échoue avec erreur VSS sur serveur SQL"
symptome: "Job Veeam en échec — VSS snapshot failed for VM SRV-SQL01"
cause: "Service SQL Server VSS Writer arrêté sur le serveur cible"
resolution:
  - "1. vssadmin list writers | findstr SQL"
  - "2. net stop SQLWriter && net start SQLWriter"
  - "3. Relancer le job Veeam manuellement"
prevention: "Ajouter surveillance service SQLWriter dans RMM"
tags: ["veeam","backup","vss","sql","job-failed"]
ticket_source: "#T1600998"
```