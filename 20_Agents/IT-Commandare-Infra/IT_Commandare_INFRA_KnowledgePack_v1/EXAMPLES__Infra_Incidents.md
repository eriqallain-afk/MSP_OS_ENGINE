# Exemples d'incidents — IT-Commandare-Infra

## Exemple 1 — DC down (P1)

**Input :**
```yaml
intent: dc_incident
request: "Alerte N-able : SRV-DC01 inaccessible depuis 8 min. Ping KO. RDP KO."
context:
  affected: [SRV-DC01]
  client: ACME
  source: N-able monitoring
```

**Output attendu :**
```yaml
result:
  summary: "Domain Controller SRV-DC01 inaccessible — service AD potentiellement impacté."
  severity: P1
  infra_domain: dc
  affected_assets: [SRV-DC01]
  decision:
    owner: IT-Commandare-Infra
    priority: P1
    routing: IT-Commandare-Infra
    escalate_to: IT-Commandare-TECH
    parallel_tracks:
      - actor: IT-NetworkMaster
        task: "Confirmer connectivité réseau vers SRV-DC01 (VLAN, switch port)"
  actions_now:
    - "IT-Commandare-Infra : tenter console iDRAC/iLO ou accès vCenter"
    - "Vérifier si SRV-DC02 (secondaire) répond et assume les rôles FSMO"
    - "IT-NetworkMaster : vérifier port switch, VLAN, logs interface"
  actions_next:
    - "Si hardware failure : initiate DR procedure pour DC"
    - "Vérifier réplication AD depuis DC secondaire"
    - "Notifier client via IT-TicketScribe"
  validation_plan:
    - "dcdiag /test:replications sur DC secondaire"
    - "nltest /dsgetdc:[domain] depuis workstation"
    - "Authentification AD testée avec compte utilisateur"
  risks:
    - "Si DC01 seul DC : AD complètement down, login impossible"
    - "DNS AD possiblement affecté (DHCP/DNS hébergé sur DC01)"
  rollback_trigger: null
```

---

## Exemple 2 — Azure VM down + Espace disque critique (P1 multi)

**Input :**
```yaml
intent: cloud_incident
request: "Azure alert: VM-APP-PROD01 deallocated. En même temps, SRV-FILE01 à 97% disk."
context:
  client: BETA
  affected: [VM-APP-PROD01, SRV-FILE01]
```

**Output attendu :**
```yaml
result:
  summary: "Double incident P1/P2 : VM Azure prod deallocated + serveur fichiers en saturation disque."
  severity: P1
  infra_domain: multi
  decision:
    routing: "IT-CloudMaster (Azure) + IT-Commandare-Infra (disk)"
    parallel_tracks:
      - actor: IT-CloudMaster
        task: "Investiguer VM-APP-PROD01 : raison deallocation (budget? maintenance? erreur?)"
      - actor: IT-Commandare-Infra
        task: "Libérer espace SRV-FILE01 : identifier top consommateurs, actions immédiates"
    escalate_to: IT-Commandare-TECH
  actions_now:
    - "IT-CloudMaster : Azure Portal → VM-APP-PROD01 → Activity Log → raison stop"
    - "IT-Commandare-Infra : PowerShell Get-ChildItem sur SRV-FILE01 drives"
  validation_plan:
    - "VM-APP-PROD01 : ping + test applicatif post-restart"
    - "SRV-FILE01 : disk < 80% confirmé + logs events vérifiés"
```

---

## Exemple 3 — Backup en échec depuis 48h (P2)

**Input :**
```yaml
intent: backup_critical
request: "Datto alerte : ACME-SRV-SQL01 aucun backup réussi depuis 48h. Dernier succès D-2."
```

**Output attendu :**
```yaml
result:
  summary: "Backup SQL01 en échec 48h — RPO compromis."
  severity: P2
  infra_domain: backup
  decision:
    routing: IT-BackupDRMaster
    escalate_to: null
  actions_now:
    - "IT-BackupDRMaster : consulter logs Datto sur ACME-SRV-SQL01"
    - "Vérifier espace agent Datto + connectivité vers cloud Datto"
  actions_next:
    - "Forcer backup manuel si logs OK"
    - "Vérifier SQL VSS writer : vssadmin list writers"
  validation_plan:
    - "Backup manuel forcé → succès confirmé dans Datto portal"
    - "Alerte Datto résolue + monitoring normalisé"
  rollback_trigger: null
```
