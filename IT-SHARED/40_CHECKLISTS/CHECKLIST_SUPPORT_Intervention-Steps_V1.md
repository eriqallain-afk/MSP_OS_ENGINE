# CHECKLIST_SUPPORT_Intervention-Steps_V1
**Agent :** IT-Assistant-N2, IT-Assistant-N3, IT-MaintenanceMaster | IT-SysAdmin
**Usage :** Déroulement standard d'une intervention MSP de bout en bout
**Mis à jour :** 2026-03-20

---

## PHASE 1 — KICKOFF (5 min)

- [ ] Lire le billet CW complet (ne pas sauter cette étape)
- [ ] Identifier : client, type, priorité P[1/2/3/4], assets concernés
- [ ] Consulter la documentation client dans Hudu (fiche objet IT si applicable)
- [ ] Vérifier les notes précédentes sur le billet
- [ ] Confirmer la fenêtre de maintenance et les approbations si applicable

## PHASE 2 — PRECHECK (lecture seule)

- [ ] Ping / RMM : asset accessible ?
- [ ] Resources : CPU, RAM, espace disque
- [ ] Services critiques démarrés
- [ ] Pending reboot
- [ ] Event Logs : erreurs récentes (2-48h selon le contexte)
- [ ] Backups : dernier job OK ?
- [ ] Snapshot créé si action risquée

## PHASE 3 — INTERVENTION

- [ ] **Une action à la fois** — documenter chaque action dans le journal CW au fil de l'eau
- [ ] Valider le résultat de chaque action avant de passer à la suivante
- [ ] Tagger **[À CONFIRMER]** toute action sans preuve immédiate
- [ ] Si la situation se dégrade → réévaluer la priorité → escalader si P2→P1
- [ ] Ne pas improviser hors scope sans documenter et obtenir validation

## PHASE 4 — POSTCHECK (validation)

- [ ] Services critiques : OK
- [ ] Connectivité / accès utilisateurs : OK
- [ ] Application ou service cible : fonctionnel et testé
- [ ] Event Logs post-action : aucune nouvelle erreur critique
- [ ] Monitoring : retour au vert (aucune alerte active anormale)
- [ ] Backups : pas d'impact sur les jobs planifiés
- [ ] Snapshot supprimé (si créé en PRECHECK et intervention validée)

## PHASE 5 — CLOSEOUT

- [ ] CW Note Interne : timeline + actions + preuves + validations
- [ ] CW Discussion : client-safe, facturable, sans IP ni détail sensible
- [ ] Email client (si requis) : résultat fonctionnel + prochaine étape
- [ ] Teams : annonce fin de maintenance (si applicable)
- [ ] Mode maintenance RMM désactivé
- [ ] KB créé ou mis à jour (si incident récurrent ou nouvelle procédure)
- [ ] Billet CW fermé avec statut correct
