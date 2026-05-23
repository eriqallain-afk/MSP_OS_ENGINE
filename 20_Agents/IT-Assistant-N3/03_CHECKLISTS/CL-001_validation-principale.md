# CL-001 — Checklist Intervention N3 (Triage → Clôture)
**Agent :** IT-AssistanTI_N3

---

## KICKOFF
- [ ] Billet CW lu en entier (ne pas sauter)
- [ ] Client, type, priorité P1/P2/P3/P4 identifiés
- [ ] Documentation Hudu consultée (fiche objet IT si applicable)
- [ ] Fenêtre de maintenance et approbations confirmées (si applicable)

## PRECHECK (lecture seule)
- [ ] Connectivité : ping / RMM / RDP OK
- [ ] Ressources : CPU, RAM, espace disque
- [ ] Services critiques démarrés
- [ ] Pending Reboot = False (ou prévu)
- [ ] Event Logs : aucune erreur critique récente non expliquée
- [ ] Backup : dernier job OK (si maintenance planifiée)
- [ ] Snapshot créé si action risquée

## INTERVENTION
- [ ] Une action à la fois — documenter au fil de l'eau dans CW
- [ ] Résultat validé avant de passer à l'étape suivante
- [ ] `[À CONFIRMER]` sur toute info non vérifiée
- [ ] `[WARNING IMPACT]` avant toute action destructrice + confirmation
- [ ] Si P2→P1 détecté : bloc escalade déclenché immédiatement

## POSTCHECK
- [ ] Services critiques OK
- [ ] Application / service cible fonctionnel (testé)
- [ ] Event Logs post-action : aucune nouvelle erreur critique
- [ ] Monitoring retourné au vert
- [ ] Snapshot supprimé (si créé et intervention validée)

## CLÔTURE (`/close`)
- [ ] CW Note Interne : "Prise de connaissance..." + timeline + preuves
- [ ] CW Discussion : client-safe, format STAR, facturable
- [ ] Email si P1/P2 ou requis
- [ ] Teams si maintenance planifiée
- [ ] Mode maintenance RMM désactivé
- [ ] `/kb` si P1/P2 ou nouveau type de problème
- [ ] `/db` si P1/P2 ou > 30 min
