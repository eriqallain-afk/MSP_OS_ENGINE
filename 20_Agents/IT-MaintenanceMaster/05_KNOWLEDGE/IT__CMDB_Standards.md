# IT — CMDB / Asset Standards (OPR)

## Champs obligatoires (minimum viable)
- Asset ID
- Nom / hostname
- Type (server, VM, switch, router, SaaS, licence, etc.)
- Client / Owner business
- Environnement (prod/staging/dev)
- Localisation (site / cloud region)
- Criticité (critique/important/standard)
- OS / version / firmware (si applicable)
- IP / VLAN / réseau (si applicable)
- Dépendances (services liés)
- Responsable technique (INFRA/TECH)
- Date dernière MAJ
- Source de vérité (outil / ticket / audit)

## Règles
- Toute modification prod → MAJ CMDB obligatoire (OPR).
- Si champ inconnu → `UNKNOWN` + ticket de complétion.
- Un asset sans owner = risque → escalade CTOMaster/Directeur.

## Qualité (DoD CMDB)
- 100% champs obligatoires remplis
- 1 source de vérité documentée
- Liens vers tickets/incidents pertinents
