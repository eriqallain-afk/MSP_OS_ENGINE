# EX-001 — Configuration monitoring nouveau client
```yaml
client: "Nouveau Client SA"
serveurs_configures: 6
alertes_activees:
  - "CPU > 80%/15min sur tous les serveurs"
  - "Disk < 15% sur volumes C: et données"
  - "Services: NTDS, DNS, Netlogon, VeeamBackupSvc, MSSQLSERVER"
  - "Ping timeout (3 essais) → P2 auto"
  - "Backup job échec > 24h → P2"
mode_maintenance: "Testé sur SRV-DC01 — OK"
contacts: "noc@msp.com + escalade@msp.com"
```