# EX-001 — Exemple : Triage alerte réseau avec corrélation
**Agent :** @IT-Commandare-NOC | **Type :** NOC | **Statut :** PASS (cas nominal avec corrélation)

## INPUT
```yaml
source: N-able RMM
alertes:
  - type: Device Offline
    asset: SW-CORE-01 (switch core site principal)
    client: Clinique Santé Plus Inc.
    depuis: 08:42
  - type: Device Offline
    asset: SRV-DC01
    client: Clinique Santé Plus Inc.
    depuis: 08:43
  - type: Device Offline
    asset: SRV-FILE01
    client: Clinique Santé Plus Inc.
    depuis: 08:43
  - type: VPN Tunnel Down
    asset: FW-WG-01 (WatchGuard)
    client: Clinique Santé Plus Inc.
    depuis: 08:44
```

## PROCESSING (résumé)
1. **Classification** : 4 alertes, même client, même site, < 2 min d'écart
2. **Corrélation détectée** : switch core down → serveurs et VPN tombent en cascade
   - Ce n'est PAS 4 incidents — c'est 1 panne réseau site
   - Cause probable : switch core (premier à tomber)
3. **Sévérité** : P1 (réseau core site down — toute l'infrastructure impactée)
4. **Mobilisation** : @IT-NetworkMaster (diagnostic switch core)
5. **Notice Teams** publiée à 08:47

## OUTPUT ATTENDU
```yaml
result:
  summary: "Panne réseau site — switch core SW-CORE-01 offline, cascade sur DC01, FILE01, VPN"
  severity: P1
  noc_domain: réseau
  affected_assets:
    - SW-CORE-01 (switch core — cause probable)
    - SRV-DC01 (impact cascade)
    - SRV-FILE01 (impact cascade)
    - FW-WG-01 tunnel VPN (impact cascade)
  correlation:
    - alert_id: 1
      relation: cause_racine
      note: "Switch core first to go down — serveurs et VPN sont des conséquences"
    - alert_id: 2,3,4
      relation: impact_cascade
      note: "Tombés 1-2 min après le switch core"
  decision:
    owner: IT-Commandare-NOC
    priority: P1
    routing: IT-NetworkMaster
    escalate_to: superviseur
  actions_now:
    - "Vérifier alimentation et connectivité physique SW-CORE-01"
    - "Contacter le site pour vérification visuelle (LED, alimentation)"
    - "Notice Teams P1 publiée"
  actions_next:
    - "Si switch OK physiquement : connexion console pour diagnostic"
    - "Si switch HS : activer le plan de contournement (switch spare si disponible)"
    - "MAJ client dans 15 min"
  risks:
    - "Aucun accès distant possible tant que le switch core est down"
    - "Impact business : toute l'infrastructure du site est offline"

artifacts:
  - type: notice_teams
    name: "Notice P1 — Clinique Santé Plus"
    content: |
      🔴 [P1] | Client : Clinique Santé Plus Inc. | Panne réseau site
      Billet : #T1720042
      Statut : EN INVESTIGATION
      Impact : Switch core offline — serveurs, VPN et services impactés
      Équipe : NOC + IT-NetworkMaster
      Prochaine MAJ : 09:00

next_actions:
  - action: "Diagnostic physique switch SW-CORE-01"
    owner: IT-NetworkMaster
    eta: "09:00"
  - action: "MAJ client"
    owner: IT-Commandare-NOC
    eta: "09:00"

log:
  trace_id: "NOC-20260328-0847-CSP"
  events:
    - ts: "08:47"
      level: INFO
      code: TRIAGE_COMPLETE
      message: "4 alertes corrélées → 1 incident P1 réseau site"
    - ts: "08:47"
      level: ACTION
      code: TEAMS_NOTICE
      message: "Notice P1 publiée dans canal NOC"
    - ts: "08:48"
      level: ACTION
      code: ROUTING
      message: "IT-NetworkMaster mobilisé pour diagnostic switch core"
  checks:
    - code: CORRELATION
      ok: true
      details: "4 alertes même client/site/fenêtre → cause racine identifiée"
    - code: SLA_RESPONSE
      ok: true
      details: "P1 traité en 5 min (SLA = 5 min)"
  assumptions:
    - "Switch core est la cause racine (premier à tomber)"
    - "Pas de panne électrique site (à confirmer avec contact sur place)"
```

## LEÇONS
- La corrélation a évité d'ouvrir 4 billets séparés — 1 seul billet parent avec cause racine
- Le switch core tombé en premier est le meilleur indicateur de cause racine
- Toujours vérifier l'alimentation physique avant de diagnostiquer la config

---
*EX-001 — @IT-Commandare-NOC — Version 1.0*
