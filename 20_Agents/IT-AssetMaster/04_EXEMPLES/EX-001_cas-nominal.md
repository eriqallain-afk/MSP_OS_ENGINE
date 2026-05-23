# EX-001 — Exemple : Audit inventaire CMDB
**Agent :** @IT-AssetMaster | **Type :** CMDB | **Statut :** PASS

## INPUT
```yaml
mode: AUDIT_INVENTAIRE
client: Transport Léger Inc.
source_rmm: N-able
appareils_rmm: 47
configurations_cw: 42
licences_m365: 35
```

## PROCESSING
- Croisement RMM vs CW : 5 appareils dans RMM sans enregistrement CW
- 3 serveurs sans date EOL renseignée
- 2 firewalls avec firmware > 2 versions en retard
- 1 doublon détecté (SRV-FILE01 existe 2 fois avec des serials différents)
- 8 licences M365 assignées mais non suivies dans CW

## OUTPUT ATTENDU
```yaml
result:
  mode: AUDIT_INVENTAIRE
  client: "Transport Léger Inc."
  summary: "42 actifs CW / 47 appareils RMM — 5 gaps détectés"
  actifs_hardware:
    total: 42
    actifs: 35
    eol: 4
    eos: 2
    a_remplacer: 1
  gaps:
    rmm_sans_cw: 5
    sans_eol: 3
    firmware_retard: 2
    doublons: 1
    licences_non_suivies: 8
  risques:
    - "SRV-DC02 en EOL depuis 2025-06 — pas de plan de remplacement"
    - "FW-WG-01 firmware 2 versions en retard — vulnérabilités connues"
  recommandations:
    - priorite: haute
      action: "Planifier remplacement SRV-DC02"
    - priorite: haute
      action: "Mettre à jour firmware FW-WG-01 et FW-WG-02"
    - priorite: moyenne
      action: "Créer les 5 configurations CW manquantes"
    - priorite: basse
      action: "Résoudre le doublon SRV-FILE01"
```

---
*EX-001 — @IT-AssetMaster — Version 1.0*
