# RUNBOOK — Post-Shutdown Électrique (reprise infra) — NOC/MSP

## Objectif
Assurer une reprise **stable** après retour du courant : réseau → stockage → virtualisation → services critiques → monitoring → rapport.

## Ordre de validation (priorité)
1) **Énergie/UPS/PDU** (événements power, batterie)
2) **Réseau** (FW/ISP/VPN/DNS/DHCP/NTP)
3) **Stockage** (SAN/NAS/RAID/SMART)
4) **Virtualisation** (vCenter/hosts/datastores)
5) **Services** (AD/DNS → SQL/IIS/File/RDS → apps)
6) **Backups** (dernier job + pas d'échec post-reprise)
7) **Monitoring** (alertes, ack, retour au vert)

## 1) UPS / Power events
- Vérifier logs UPS (power fail/restore, batteries faibles).
- Si UPS faible : noter le risque + recommander remplacement.

## 2) Réseau baseline (read-only)
```powershell
"=== DNS / Gateway quick checks ==="
ipconfig /all
nslookup google.com
route print | findstr /I "0.0.0.0"

"=== Time sync ==="
w32tm /query /status
w32tm /query /source
```

## 3) Stockage
- Sur SAN/NAS : état contrôleurs, disques, volumes, iSCSI, alertes.
- Vérifier que les datastores sont montés **avant** vCenter/ESXi dépendants.

## 4) Virtualisation (VMware vSphere)
- **Ordre recommandé** : SAN/NAS → ESXi hosts → vCenter.
- Si vCenter est parti avant le SAN :
  - redémarrer vCenter **après** confirmation datastores.
  - au besoin redémarrer les hosts ESXi (1 à la fois) si incohérences.
- Valider : cluster, hosts connected, datastores OK, VMs up.

## 5) Services critiques Windows (par rôle)
- DC: voir `RUNBOOK__DC_PrePost_Validation.md`
- SQL: voir `RUNBOOK__SQL_PrePost_Validation.md`
- Print: voir `RUNBOOK__PrintServer_PrePost_Validation.md`

## 6) Monitoring
- Lister les alertes apparues depuis le retour du courant.
- Distinguer :
  - alertes transitoires (boot) vs. anomalies persistantes
- Normaliser/ack une fois validé.

## 7) Rapport (CW)
- CW_NOTE_INTERNE : timeline + validations + anomalies + suivis.
- CW_DISCUSSION (STAR) : résultat + actions clés.

