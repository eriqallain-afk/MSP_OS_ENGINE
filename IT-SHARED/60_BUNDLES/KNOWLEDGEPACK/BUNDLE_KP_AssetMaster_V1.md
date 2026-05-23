# BUNDLE_KP_AssetMaster_V1
**Agent :** @IT-AssetMaster | **Mis à jour :** 2026-03-29 | IT-MaintenanceMaster | IT-SysAdmin

## CATÉGORIES ACTIFS CMDB

| Catégorie | Types | Champs clés CW |
|---|---|---|
| Serveurs | Physique, VM, Cloud | OS, RAM, CPU, rôles, IP |
| Réseau | Switch, Routeur, Firewall, AP | Firmware, VLAN, ports |
| Postes | Desktop, Laptop, Thin Client | OS, RAM, disque, user |
| Périphériques | Imprimante, Scanner, UPS | IP, modèle, contrat |
| Logiciels | OS, Apps, Sécurité | Version, licences, expiry |
| Cloud | Azure VM, M365, SaaS | Tenant, abo, coût/mois |

## CONVENTION NOMMAGE ACTIFS
```
[CLIENT]-[TYPE]-[SITE]-[SEQ]
Exemples :
  ACME-SRV-MTL-001    (serveur)
  ACME-FW-MTL-001     (firewall)
  ACME-SW-MTL-001     (switch)
  ACME-AP-MTL-001     (access point)
  ACME-PC-MTL-042     (poste)
```

## CHAMPS CW CONFIGURATIONS OBLIGATOIRES
```
- Name (hostname exact conforme à la convention)
- Type (Server / Workstation / Network / Printer / Cloud)
- Status (Active / EOL / EOS / Retired / Maintenance)
- Manufacturer + Model
- Serial Number
- Client + Site
- OS + Version (si applicable)
- Install Date
- EOL Date (obligatoire pour serveurs et firewall)
- Assigned Contact / Owner
```

## CYCLE DE VIE
```
Procurement → Déploiement → Opération → Maintenance → Décommission

Alertes automatiques :
- EOL dans 12 mois → planifier remplacement
- Licence dans 60 jours → planifier renouvellement
- Garantie expirée → évaluer risque
- Firmware > 2 versions en retard → planifier MàJ
```

## AUDIT TRIMESTRIEL
```
1. Croiser CW Configurations vs RMM
2. Identifier gaps (dans RMM mais pas CW)
3. Identifier fantômes (dans CW mais offline > 60j)
4. Vérifier dates EOL renseignées
5. Rapport : total par catégorie, % couverture, risques
```

---
*BUNDLE_KP_AssetMaster_V1 — Version 1.0*
