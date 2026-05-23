# RB-001 - Cycle de Patching Mensuel
**Agent:** @IT-ScriptMaster | **Type:** IT Infrastructure

## Objectif
Appliquer les mises a jour de securite et correctifs systeme sur les serveurs assignes dans la fenetre de maintenance approuvee.

## Declencheur
- Date de maintenance planifiee (generalement 2e mardi du mois - Patch Tuesday)
- Alerte de vulnerabilite critique (CVSS >= 9.0 = hors cycle)

## Prerequis
- [ ] Fenetre de maintenance confirmee avec le client
- [ ] Snapshots/sauvegardes recentes verifiees
- [ ] Liste des serveurs cibles exportee
- [ ] Contacts d'urgence identifies

## Etapes
### Phase 1 - Pre-maintenance (J-2)
1. Exporter la liste des serveurs depuis la CMDB
2. Verifier l'etat des sauvegardes (< 24h)
3. Envoyer la notification de maintenance aux parties prenantes
4. Preparer le rapport de patching vierge

### Phase 2 - Execution (Fenetre maintenance)
1. Confirmer le debut de fenetre avec le client
2. Pour chaque serveur (ordre : DEV > QA > PROD) :
   a. Verifier connectivite RDP/WinRM
   b. Capturer l'etat actuel (uptime, services critiques)
   c. Lancer les mises a jour (Windows Update / WSUS)
   d. Surveiller la progression
   e. Redemarrer si requis (confirmation client si PROD)
   f. Verifier redemarrage et services post-patch
   g. Documenter le statut dans le rapport

### Phase 3 - Post-maintenance
1. Consolider le rapport final (succes / echecs / en attente)
2. Envoyer le rapport au client
3. Planifier le suivi pour les elements en echec
4. Mettre a jour la CMDB

## Verification
- [ ] Tous les serveurs cibles traites ou statut documente
- [ ] Services critiques operationnels
- [ ] Rapport envoye et accuse de reception obtenu

## Rollback
- Restaurer depuis le snapshot pre-maintenance
- Notifier le client immediatement
- Ouvrir un ticket d'incident

---
*RB-001 - IT-ScriptMaster - Version 1.0*
