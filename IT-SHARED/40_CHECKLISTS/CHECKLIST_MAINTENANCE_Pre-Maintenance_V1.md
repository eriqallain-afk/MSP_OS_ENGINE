# CHECKLIST_MAINTENANCE_Pre-Maintenance_V1
**Agent :** IT-MaintenanceMaster, IT-Assistant-N3 | IT-SysAdmin
**Usage :** Avant toute maintenance planifiée (patching, redémarrage, déploiement)
**Mis à jour :** 2026-03-20

---

## PRÉ-MAINTENANCE — À compléter AVANT de commencer

### Contexte et autorisation
- [ ] Billet CW ouvert : #_______
- [ ] Fenêtre de maintenance confirmée : _______ à _______ (heure locale)
- [ ] Approbation reboots obtenue : ☐ Oui  ☐ Non requis
- [ ] Client informé (email/Teams J-48h) : ☐ Fait  ☐ Non requis
- [ ] Équipe IT briefée : ☐ Fait  ☐ Solo

### Backup et snapshots
- [ ] Backup récent confirmé (< 24h) pour chaque serveur critique
- [ ] Snapshot créé sur VMs critiques (avec nom conforme : @[Ticket]_Preboot_[VM]_SNAP_[Date])
- [ ] Point de restauration Datto validé (screenshot présent)
- [ ] Dernière restauration testée (mensuel) : ☐ OK  ☐ Non vérifié

### Vérifications système (par serveur)
- [ ] Espace disque > 10% libre sur C: et volumes data
- [ ] Services critiques démarrés et stables
- [ ] Pending reboot = False (ou reboot planifié dans cette fenêtre)
- [ ] Event Log : aucune erreur critique récente non résolue
- [ ] Sessions RDS actives vérifiées (si reboot prévu : utilisateurs avertis)

### Monitoring et accès
- [ ] Mode maintenance activé dans RMM (Datto RMM / N-able / CW RMM)
- [ ] Accès admin validé (RDP / RMM / Console)
- [ ] VPN connecté si intervention à distance
- [ ] Numéro de contact client d'urgence noté : _______

### Ordre d'intervention (pour plusieurs serveurs)
```
Ordre recommandé (critiques en dernier) :
1. Serveurs non-critiques / secondaires
2. Serveurs applicatifs (ERP, web, app)
3. Serveurs SQL / bases de données
4. Serveurs de fichiers
5. RDS / accès distant
6. Domain Controllers (en dernier — un seul à la fois)
```

### GO / NO-GO
- [ ] Toutes les cases ci-dessus validées → **GO**
- [ ] Au moins un item bloquant non résolu → **NO-GO — documenter dans CW et reprogrammer**
