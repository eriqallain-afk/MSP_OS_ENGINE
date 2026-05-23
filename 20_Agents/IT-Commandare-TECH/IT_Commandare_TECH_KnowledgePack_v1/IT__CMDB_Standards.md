# IT — CMDB Standards (TECH)

> Version TECH : focus sur la documentation technique des assets pendant/après diagnostic.
> La mise à jour CMDB est une responsabilité partagée : TECH documente, OPR valide.

---

## Champs obligatoires — Tout asset

| Champ | Obligatoire | Exemple |
|-------|-------------|---------|
| Asset ID | ✅ | SRV-PROD-001 |
| Hostname / Nom | ✅ | DC01.client.local |
| Type | ✅ | Server / VM / Switch / SaaS / Licence |
| Client | ✅ | Industries XYZ |
| Environnement | ✅ | prod / staging / dev |
| Criticité | ✅ | critique / important / standard |
| OS + version | ✅ | Windows Server 2022 Standard 21H2 |
| IP + VLAN | ✅ | 192.168.10.5 / VLAN 10 |
| Dépendances | ✅ | Active Directory, SQL Server, Backup Veeam |
| Responsable TECH | ✅ | Martin L. |
| Dernière MAJ | ✅ | 2026-03-07 |

---

## Champs spécifiques par type d'asset

### Serveur / VM
- Hyperviseur : Hyper-V / VMware / Azure VM
- RAM / vCPU / Disque
- Rôles Windows : DC / DNS / DHCP / File Server / Print / SQL / Web
- Cluster : Oui/Non — Membres :
- Snapshot politique : Fréquence + rétention

### Réseau (Switch / Firewall / AP)
- Fabricant + Modèle + Firmware
- Ports / VLANs configurés
- Gestion OOB (console / IPMI)
- Dernier firmware appliqué + date

### SaaS / Cloud
- Tenant ID / Subscription ID
- Région cloud
- Admin accounts (nombre)
- MFA activé : Oui/Non
- Date renouvellement licence

---

## Règles TECH — Mise à jour CMDB pendant intervention

```
AVANT toute intervention :
  1. Vérifier l'entrée CMDB existante
  2. Si asset absent → créer entrée minimale (Asset ID + Hostname + Type + Client)

APRÈS toute modification :
  1. Mettre à jour les champs modifiés
  2. Ajouter note : "Modifié le AAAA-MM-JJ — INC/RFC# — Description modification"
  3. Documenter les nouvelles dépendances découvertes

SI CMDB manque d'informations critiques :
  → Créer ticket de complétion → Owner : OPR
  → Tag : "CMDB-incomplete"
```

---

## Criticité — Définition TECH

| Niveau | Définition | Exemples |
|--------|-----------|---------|
| **Critique** | Panne = arrêt total / majorité utilisateurs impactés | DC primaire, Firewall périmètre, Exchange, ERP |
| **Important** | Panne = dégradation significative / contournement difficile | DC secondaire, Backup, File Server, VPN |
| **Standard** | Panne = impact limité / contournement simple | Imprimantes, postes, SaaS secondaires |

---

## Qualité CMDB (Definition of Done)

- [ ] 100% champs obligatoires remplis
- [ ] Dépendances documentées (services liés)
- [ ] Criticité assignée et validée
- [ ] Source de vérité identifiée (CMDB / ticket / audit physique)
- [ ] Lien vers dernier incident/RFC associé

---

> Voir aussi : IT__Postmortem_Template.md — Section 4 (changements effectués → MAJ CMDB)
