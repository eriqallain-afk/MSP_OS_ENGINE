# CL-001 - Checklist Pre/Post Patching
**Agent:** @IT-ScriptMaster | **Type:** IT Infrastructure

## PRE-EXECUTION
### Preparation environnement
- [ ] Fenetre de maintenance approuvee par ecrit
- [ ] Backup/snapshot < 24h confirme pour chaque serveur PROD
- [ ] Services critiques identifies et surveilles
- [ ] Contacts d'urgence disponibles pendant la fenetre
- [ ] Plan de rollback documente

### Verification systeme
- [ ] Espace disque suffisant (>= 15% libre sur C:)
- [ ] Pas d'incidents actifs sur les serveurs cibles
- [ ] Acces administrateur valide (RDP / WinRM)
- [ ] Antivirus en mode exclusion pour la fenetre

## EXECUTION
- [ ] Serveurs DEV/QA traites avant PROD
- [ ] Chaque redemarrage confirme avec client (PROD)
- [ ] Statut journalise par serveur en temps reel
- [ ] Alertes monitoring suspendues pendant maintenance

## POST-EXECUTION
### Validation technique
- [ ] Services critiques operationnels (liste a definir par client)
- [ ] Pas d'erreurs dans l'Event Viewer (niveau Critical/Error)
- [ ] Connectivite reseau confirmee
- [ ] Applications metier accessibles

### Rapport et cloture
- [ ] Rapport de patching complete (succes/echecs/reportes)
- [ ] Rapport envoye au client dans les 2h post-maintenance
- [ ] Tickets ouverts pour les serveurs en echec
- [ ] CMDB mise a jour
- [ ] Prochaine fenetre planifiee si elements en suspens

---
*CL-001 - IT-ScriptMaster - Version 1.0*
