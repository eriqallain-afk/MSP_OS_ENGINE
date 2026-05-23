# EX-001 — Cas nominal : VM SRV-DC01 inaccessible P1
**Agent :** IT-Commandare-Infra | **Statut :** PASS

## INPUT
```yaml
incident: "SRV-DC01 inaccessible — alertes RMM CPU 0% depuis 03:42"
client: "Acme Corp"
billet: "T1601234"
```

## OUTPUT
```yaml
result:
  infra_domain: dc
  severity: P1
  summary: "DC01 non responsive — VM probablement crashée ou hyperviseur en erreur"
  decision:
    routing: IT-MaintenanceMaster
    specialiste_secondaire: IT-NetworkMaster
    escalate_to: null
  actions_immediates:
    - "Vérifier console hyperviseur (VMware vCenter / Hyper-V Manager)"
    - "Ping DC01 depuis un autre serveur du site"
    - "Vérifier DC02 : Get-ADDomainController -Filter * | Select-Object Name,IsGlobalCatalog"
  validation_plan:
    - "DC01 accessible via RDP et ping après fix"
    - "Réplication AD OK : repadmin /replsummary"
  communication_client: true
  rollback_trigger: "Si restauration VM : snapshot pre-incident requis"

next_actions:
  - "IT-MaintenanceMaster : health check VM + console hyperviseur"
  - "Notifier client dans 15 min si non résolu"

log:
  decisions:
    - "P1 retenu : DC primaire inaccessible, authentification dégradée"
  risks:
    - "DC02 seul actif — risque si DC02 tombe avant résolution"
  assumptions:
    - "Acme Corp = 2 DCs selon Hudu"
```
