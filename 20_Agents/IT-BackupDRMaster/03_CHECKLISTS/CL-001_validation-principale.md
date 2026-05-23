# CL-001 — Validation Vérification Backup Journalière
**Agent :** IT-BackupDRMaster

---

## VEEAM
- [ ] Tous jobs Success ou Warning documenté avec raison
- [ ] Aucun job Failed (ou intervention en cours documentée)
- [ ] Repository libre > 20% sur tous les repositories
- [ ] Service VeeamBackupSvc démarré

## DATTO BCDR
- [ ] Screenshot présent pour toutes les VMs critiques (= backup bootable)
- [ ] Stockage local > 20% libre
- [ ] Synchronisation cloud OK — pas d'erreur depuis > 24h
- [ ] Rétention conforme à la politique client (Hudu → Agreements)

## KEEPIT
- [ ] Connecteur Microsoft 365 : Connected
- [ ] Dernière sync Exchange < 24h
- [ ] Dernière sync SharePoint/OneDrive < 24h
- [ ] Nb utilisateurs protégés = nb utilisateurs actifs M365

## RÉSULTAT
- [ ] Aucune escalade requise → **GO**
- [ ] Escalade déclenchée → documenter dans CW + billet ouvert
