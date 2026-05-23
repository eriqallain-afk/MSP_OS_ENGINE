# RUNBOOK — DC patching & prechecks (Windows Updates) — RUNBOOK__DC_PATCHING_PRECHECK

## Objectif
Appliquer des mises à jour Windows manquantes sur un **Domain Controller (DC)** (ex: `DCsrv01`) de façon contrôlée, avec **pré-contrôles** (santé AD/replication), **fenêtre de maintenance**, **redémarrage**, puis **post-checks**.

## Portée
- Domain Controllers Windows (AD DS).
- Scénario typique: RMM/monitoring détecte “updates missing” et “reboot required”.

## Risque / garde-fous
- **Risque élevé**: un reboot DC au mauvais moment peut impacter l’authentification, la réplication, DNS, GPO.
- Appliquer le processus **Change Management** (Change ID), fenêtre de maintenance, et idéalement ne pas patcher tous les DCs en même temps.

## Inputs requis (à confirmer avant action)
- Nom du serveur: `server_name` (ex: DCsrv01)
- Fenêtre de maintenance: `maintenance_window` (début/fin + timezone)
- Change ID / Ticket ID: `change_id` (ou Service Ticket)
- Contexte infra: nombre de DC, site, rôle FSMO (si applicable), WSUS vs Windows Update
- Accès: compte admin, méthode RMM/console, capacité de rollback (snapshot/backup)

---

## 1) Prechecks (AVANT installation)
### 1.1 Communication / préparation
1. Confirmer que **au moins un autre DC** est opérationnel (si environnement multi-DC).
2. Programmer la fenêtre de maintenance + prévenir les parties prenantes.
3. Suspendre/mettre en “maintenance mode” les alertes RMM/monitoring (si applicable).
4. Vérifier l’espace disque (au moins quelques Go libres sur C:).

### 1.2 Santé AD/DNS/Replication (commandes usuelles)
> Exécuter depuis une session admin sur le DC (ou depuis un poste admin en remote), en adaptant selon votre standard.

- Vérifier la santé globale:
  - `dcdiag /v`
- Vérifier la réplication:
  - `repadmin /replsummary`
  - `repadmin /showrepl`
- Vérifier services critiques (AD DS, DNS, DFSR si SYSVOL):
  - Vérifier que les services attendus sont “Running”
- Vérifier logs système récents (System / Directory Service / DNS Server):
  - Rechercher erreurs critiques récentes (2–24h)

### 1.3 Sauvegarde / rollback
1. Confirmer qu’un **backup système/VM** récent est disponible (et testé si possible).
2. Si VM et autorisé par policy: snapshot **juste avant** patching (attention aux règles AD/snapshots — respecter votre standard interne).
3. Confirmer procédure de restauration (qui, comment, RTO/RPO).

---

## 2) Installation des mises à jour (Patching)
### 2.1 Méthode
- Si WSUS/outil central (SCCM/Intune/RMM): utiliser la méthode standard.
- Sinon: Windows Update (UI / commande selon standard).
- Documenter les KBs installées si disponibles.

### 2.2 Séquence recommandée
1. Lancer la détection/installation des updates manquantes.
2. Surveiller:
   - progression installation
   - CPU/RAM/disk
   - erreurs d’installation (codes)
3. Une fois l’installation terminée, préparer le redémarrage.

---

## 3) Redémarrage contrôlé
1. Vérifier une dernière fois:
   - aucune opération critique en cours (backup, migration, etc.)
   - réplication stable (si vous avez le temps, refaire `repadmin /replsummary`)
2. Redémarrer le DC.
3. Attendre le retour complet:
   - login possible
   - services AD DS/DNS up
   - temps de stabilisation (ex: 5–15 min) selon environnement

---

## 4) Post-checks (APRÈS reboot)
### 4.1 Santé AD / réplication
- `dcdiag` (au moins les checks essentiels)
- `repadmin /replsummary` et `repadmin /showrepl`
- Vérifier SYSVOL/DFSR (si applicable), DNS, Event Logs.

### 4.2 Validation applicative minimale
- Test authentification (login / accès ressource)
- Vérifier que le monitoring RMM repasse au vert après sortie maintenance.

### 4.3 Clôture
1. Noter dans le ticket:
   - heure début/fin
   - KBs installées (si disponibles)
   - reboot effectué (oui/non)
   - résultats prechecks/post-checks
2. Sortir du maintenance mode (monitoring).
3. Si anomalies: lancer le playbook RCA / incident.

---

## 5) Rollback (si échec)
- Si update échoue: collecter codes d’erreur + logs + retenter selon standard.
- Si le DC ne revient pas:
  - basculer temporairement les dépendances (si possible)
  - engager procédure de restauration/rollback approuvée (backup/VM restore)
  - escalader (N2/N3) + ouvrir incident majeur si impact.

---

## Checklist “runbook card” (version courte)
- [ ] Confirmer ticket/change + fenêtre maintenance
- [ ] Mettre monitoring en maintenance
- [ ] Prechecks: `dcdiag` + `repadmin` + logs + disk
- [ ] Confirmer backup/rollback
- [ ] Installer updates (WSUS/RMM/standard)
- [ ] Reboot contrôlé
- [ ] Post-checks: `dcdiag` + `repadmin` + services + logs
- [ ] Sortie maintenance + mise à jour ticket
