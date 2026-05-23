# EX-001 — Cas nominal : Qualité audio dégradée Teams Phone
**Agent :** IT-VoIPMaster | **Mode :** QUALITE_AUDIO | **Statut :** PASS
```yaml
result:
  mode: QUALITE_AUDIO
  severity: P2
  summary: "QoS désactivée accidentellement sur switch Aruba — écho + coupures Teams Phone"
  details: |
    Test-NetConnection [SBC] -Port 5060 → OK
    Get-NetQosPolicy → aucune politique DSCP voix
    Cause : MàJ switch HP Aruba — QoS réinitialisée
    Action : Réactiver QoS DSCP EF (46) pour trafic UDP 10000-20000
  impact: "Qualité audio dégradée pour ~30 utilisateurs Teams Phone depuis 4h"
  validation_requise: "Score MOS > 4.0 après correction + test appel confirmé"
artifacts:
  - type: "config"
    title: "QoS Aruba à appliquer"
    content: "traffic-class voice dscp 46 priority high"
next_actions:
  - "Appliquer QoS sur switch — avec IT-NetworkMaster"
  - "Vérifier MOS post-correction"
escalade:
  requis: false
log:
  decisions: ["Correction QoS — scope réseau donc coordination IT-NetworkMaster"]
  risks: ["Autres switches à vérifier si même modèle"]
  assumptions: ["MàJ switch datée de hier soir — corrélation temporelle"]
```