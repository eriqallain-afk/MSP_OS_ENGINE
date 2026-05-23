# Règles de Routing — IT-Commandare-Infra

## Routing par domaine détecté

```yaml
routing_rules:

  server:
    primary: IT-Commandare-Infra
    secondary: IT-Commandare-TECH
    keywords: [serveur, server, windows server, linux, physique, bare metal, BSOD, reboot]

  vm:
    primary: IT-Commandare-Infra
    secondary: IT-Commandare-TECH
    keywords: [vmware, hyper-v, proxmox, vm, virtual machine, esxi, vCenter, snapshot, HA, cluster]

  storage:
    primary: IT-Commandare-Infra
    secondary: IT-BackupDRMaster
    keywords: [SAN, NAS, iSCSI, disque, disk, espace, storage, RAID, LUN, datastore]

  dc:
    primary: IT-Commandare-Infra
    secondary: IT-NetworkMaster
    keywords: [domain controller, DC, Active Directory, AD, SYSVOL, NETLOGON, réplication, FSMO, DNS AD]

  cloud_azure:
    primary: IT-CloudMaster
    secondary: IT-Commandare-Infra
    keywords: [Azure, VM Azure, Azure AD, Entra, subscription, tenant, resource group, VNet, ExpressRoute]

  cloud_m365:
    primary: IT-CloudMaster
    secondary: null
    keywords: [Microsoft 365, M365, Exchange Online, Teams, SharePoint, OneDrive, Outlook, licences]

  network_infra:
    primary: IT-NetworkMaster
    secondary: IT-Commandare-Infra
    keywords: [routeur core, switch distribution, WAN, lien principal, MPLS, BGP, pare-feu principal]

  backup_dr:
    primary: IT-BackupDRMaster
    secondary: IT-Commandare-Infra
    keywords: [backup, sauvegarde, Veeam, Datto, DR, disaster recovery, RPO, RTO, restauration]

  multi_domain:
    primary: IT-Commandare-TECH      # si P1
    tracks:
      - IT-Commandare-Infra
      - IT-CloudMaster
      - IT-NetworkMaster
    note: "Lancer les tracks en parallèle — IT-Commandare-TECH coordonne si P1"
```

## Règles d'escalade

| Condition | Escalade vers |
|-----------|--------------|
| P1 + impact architectural (migration, DR activé) | IT-Commandare-TECH |
| Incident implique vecteur sécurité | IT-SecurityMaster (prend le lead sécurité) |
| Incident non résolu en 2h (P2) | IT-Commandare-TECH |
| Décision de rollback majeur requis | IT-Commandare-TECH + IT-DirecteurGeneral |
| Client VIP affecté | IT-TicketScribe + IT-DirecteurGeneral notifié |

## Passage à IT-Commandare-OPR

Déclencher IT-Commandare-OPR quand :
- Service stabilisé (P1/P2 contenu)
- Remédiation définitive planifiée ou appliquée
- Ticket CW à fermer ou à mettre à jour formellement
- DoD (Definition of Done) à vérifier
