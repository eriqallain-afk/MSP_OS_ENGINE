# EX-001 — Fiche edocs SERVEUR — SRV-SQL01
```yaml
type: "SERVEUR"
nom: "SRV-SQL01 (Maestro)"
role: "Serveur SQL principal application Maestro"
os: "Windows Server 2022 Standard"
liaisons_montantes:
  - "APPLICATION — Maestro"
  - "BACKUP — VEEAM On-premise"
liaisons_descendantes:
  - "SERVEUR — SRV-RDS01"
compte_admin: "Voir Passportal — SRV-SQL01 Admin"
derniere_maj: "2026-03-22 | eallain | #T1601200"
```