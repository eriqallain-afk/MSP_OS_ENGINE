# EX-001 — Cas nominal : VPN SSL WatchGuard down — utilisateur
**Agent :** IT-NetworkMaster | **Mode :** VPN_UTILISATEUR | **Statut :** PASS
```yaml
result:
  mode: VPN_UTILISATEUR
  severity: P3
  summary: "Utilisateur impossible de se connecter VPN SSL — absent du groupe AD VPN-Users"
  details: |
    Test-NetConnection [GW] -Port 443 → OK
    Get-ADUser jean.martin -Properties LockedOut → False
    Groupe AD VPN-Users → jean.martin ABSENT
  impact: "1 utilisateur sans accès VPN — P3"
  validation_requise: "Connexion VPN confirmée par l'utilisateur"
artifacts:
  - type: powershell
    title: "Ajout groupe AD VPN"
    content: "Add-ADGroupMember -Identity 'VPN-Users' -Members 'jean.martin'"
next_actions:
  - "Confirmer connexion VPN réussie avec l'utilisateur"
  - "Documenter dans CW"
escalade:
  requis: false
log:
  decisions: ["Ajout groupe AD — correction standard"]
  risks: ["Vérifier que le groupe VPN-Users a bien les droits dans WatchGuard"]
  assumptions: ["Compte AD actif et non verrouillé"]
```