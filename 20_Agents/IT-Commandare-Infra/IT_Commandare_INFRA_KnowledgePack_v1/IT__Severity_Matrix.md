# Matrice Sévérité — IT-Commandare-Infra

## P1 — Critique (réponse < 5 min)

| Domaine | Exemples | Mobilisation immédiate |
|---------|---------|----------------------|
| server | Serveur de production down, BSOD non récupéré | IT-Commandare-Infra + IT-Commandare-TECH |
| dc | Domain Controller principal down, AD inaccessible | IT-Commandare-Infra |
| cloud | Azure tenant inaccessible, Exchange Online down (tous users) | IT-CloudMaster |
| network | Réseau core site complet down, lien WAN principal coupé | IT-NetworkMaster |
| storage | SAN/NAS corrompu, données inaccessibles, corruption détectée | IT-Commandare-Infra + IT-BackupDRMaster |
| vm | Cluster VMware/Hyper-V en failover, HA triggered | IT-Commandare-Infra |
| backup | Backup DR invalide + incident actif simultané | IT-BackupDRMaster |
| multi | ≥ 2 domaines P1 simultanés | IT-Commandare-TECH + tous spécialistes concernés |

## P2 — Élevé (réponse < 15 min)

| Domaine | Exemples | Action |
|---------|---------|--------|
| dc | Réplication AD échouée, SYSVOL désynchronisé | IT-Commandare-Infra |
| cloud | Azure AD Conditional Access bloquant utilisateurs | IT-CloudMaster |
| cloud | M365 service dégradé (Teams/SharePoint lent) | IT-CloudMaster |
| server | Serveur secondaire down, service non critique arrêté | IT-Commandare-Infra |
| storage | Espace disque ≥ 95% sur serveur critique | IT-Commandare-Infra |
| backup | Job backup en échec depuis > 24h | IT-BackupDRMaster |
| network | Lien WAN redondant down (primaire OK) | IT-NetworkMaster |
| vm | VM dégradée (snapshot bloqué, VMware tools down) | IT-Commandare-Infra |

## P3 — Moyen (réponse < 1h)

| Domaine | Exemples |
|---------|---------|
| server | Service non critique arrêté, performance dégradée |
| storage | Espace disque ≥ 85%, snapshot échoué |
| cloud | Latence M365 pour sous-groupe d'utilisateurs |
| vm | Snapshot échoué, alerte VMware Tools outdated |
| backup | Job backup en retard < 24h |

## P4 — Informatif (réponse < 4h)

- Capacity planning infra (seuils approchants dans 30+ jours)
- Maintenance préventive planifiée
- Mise à jour firmware/drivers non urgente
- Alerte monitoring informationnelle

---

## Matrice de décision : INFRA vs TECH vs NOC

| Situation | Agent lead |
|-----------|-----------|
| Serveur/VM/stockage/DC/Azure down ou dégradé | **IT-Commandare-Infra** |
| Alerte indéterminée, domaine inconnu | **IT-Commandare-NOC** → reroute |
| RCA général, bug applicatif, remédiation complexe | **IT-Commandare-TECH** |
| Incident sécurité (malware, breach) | **IT-SecurityMaster** (INFRA en support) |
| Workstation / user | **IT-AssistanTI_N3** |
