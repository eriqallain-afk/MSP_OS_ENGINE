# CW TEMPLATE LIBRARY — IT-MaintenanceMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
_Bibliothèque de macros /template (checklists injectables)_

## Comment utiliser
- Dans le chat avec IT-MaintenanceMaster et IT-Assistant-N3 :
  - `/template <NOM>` pour injecter une checklist
  - `/result <num> <FAIT|KO|SKIP|À_SUIVRE> : <résultat>`
  - `/evidence <label> : <résumé preuve>` (+ capture)
  - `/close` pour générer CW_INTERNAL_NOTES + CW_DISCUSSION (+ email optionnel)

## Règle fixe (toujours dans NOTE INTERNE, première ligne)
- Prendre connaissance de la demande et consultation de la documentation disponible du client .
# CORE (transverse)

## /template start_standard
1. Reformuler la demande + impact (service/utilisateurs, urgence, scope).
2. Identifier le type : NOC | SOC | SUPPORT | OTHER.
3. Lister les objets concernés (serveur(s), compte(s), équipement(s), site(s), etc.).
4. Vérifier prérequis : accès/outils (RMM, DUO, M365, Firewall…), fenêtre maintenance, approbations.
5. Définir plan d’action (3–7 étapes) + critères de succès.
6. Définir le point de communication (quand informer le client : début / pendant / fin).

## /template evidence_capture
1. Pour chaque action : définir la preuve attendue (capture, statut RMM, message console, résultat test).
2. Toute preuve manquante doit être taggée **[À CONFIRMER]** + question/action associée.
3. Noter référence/indice de preuve (heure, outil, intitulé capture).
4. Client-safe : masquer IP/comptes/chemins/logs bruts (remplacer par [MASQUÉ]).

## /template noc_baseline
1. Vérifier l’état du serveur dans RMM (online + métriques).
2. Vérifier alertes monitoring (actuelles + 24h).
3. Vérifier sauvegardes récentes / snapshot (si applicable).
4. Vérifier capacité (CPU/RAM/Disk) + services critiques (selon client).
5. Préparer mitigation/rollback si échec ou perte de connectivité.
6. Validation finale : services OK + monitoring OK (sinon [À CONFIRMER]).

## /template soc_baseline
1. Triage alerte : source, horodatage, criticité.
2. Définir périmètre (assets, comptes, sites).
3. Containment si requis (isolation/quarantaine) **[À CONFIRMER]** si non validé.
4. Collecte IOC (interne seulement, jamais en client-safe).
5. Remédiation + vérifications (EDR/SIEM) + recommandations.
6. Validation finale : risque réduit + actions de suivi.

## /template support_baseline
1. Confirmer symptôme + impact.
2. Reproduire / collecter preuves.
3. Hypothèse cause + test (1–2 max).
4. Correctif + preuve.
5. Validation utilisateur / service.
6. Prévention (si applicable).

## /template closeout_validations
1. Services : OK | KO | [À CONFIRMER]
2. Monitoring : OK | KO | [À CONFIRMER]
3. Backups (si applicable) : OK | KO | [À CONFIRMER]
4. Validation utilisateur (si applicable) : OK | KO | [À CONFIRMER]
5. Prochaines étapes : aucune | suivi | action client

---

# NOC

## /template NOC.UPDATE_SERVER
1. Vérification de l'état du serveur dans RMM.
2. Connexion à DUO pour ByPassCode (si requis).
3. Vérification sauvegardes récentes / snapshot (si applicable).
4. Vérification espace disque / santé générale (services + event logs rapides).
5. Installation des mises à jour (KB/Drivers) via outil (RMM/WSUS/Intune/…).
6. Traitement des échecs (si applicable) + relance ciblée.
7. Redémarrage planifié (si requis).
8. Post-check : services critiques OK, accès OK, monitoring OK, état MAJ confirmé.

## /template NOC.REBOOT
1. Confirmer fenêtre de maintenance / impact accepté.
2. Vérifier sessions actives / tâches planifiées.
3. Redémarrer le serveur.
4. Validation post-reboot : services, connectivité, monitoring, journaux.

## /template NOC.BACKUP_FAIL
1. Vérifier l’erreur de job et la dernière exécution OK.
2. Vérifier espace repo / connectivité / credentials (sans les exposer).
3. Action corrective (selon outil) + relance.
4. Validation : job OK + monitoring/alerte normalisé.

---

# SOC

## /template SOC.EDR_ALERT
1. Collecter détails alerte (host, user, type, horodatage).
2. Triage : faux positif vs incident probable.
3. Containment (si requis) : isoler/quarantaine.
4. Remédiation : scan, nettoyage, suppression/quarantaine.
5. Validation : alerte close + recommandations.

## /template SOC.FW_RULE_CHANGE
1. Recueillir le flux à autoriser (src/dst/port/proto) + justification.
2. Créer la règle firewall (avec nommage/description).
3. Test de connectivité.
4. Documenter + plan rollback (désactivation règle).

## /template SOC.FW_UNBLOCK
1. Identifier ce qui bloque (log firewall, catégorie, IP/host masqué si client-safe).
2. Débloquer (exception temporaire ou permanente) + justification.
3. Tester.
4. Documenter + durée/expiration si temporaire.

---

# SUPPORT

## /template SUPPORT.M365_USER_ADD
1. Connexion au centre d’administration Microsoft 365.
2. Création utilisateur + paramètres de base.
3. Attribution licences.
4. MFA / Identity (si requis).
5. Exchange : boîte aux lettres / groupes / alias (si requis).
6. Validation : connexion + tests basiques.

## /template SUPPORT.EXCHANGE_TASK
1. Connexion au centre d’admin Exchange.
2. Action demandée (permissions, shared mailbox, transport rule, etc.).
3. Validation : tests (envoi/réception si applicable).
4. Documenter.

## /template SUPPORT.IDENTITY_MFA
1. Vérifier l’identité / méthode MFA.
2. Réinitialiser/ajuster MFA selon demande.
3. Validation : connexion OK.
4. Conseils utilisateur (client-safe).

---

# OTHER (générique)

## /template OTHER.GENERAL
1. Collecte : symptômes, impact, preuves.
2. Action principale.
3. Validation post-action.
4. Documentation / recommandations.
