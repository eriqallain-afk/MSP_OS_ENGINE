# CHECKLIST_BACKUP_DR-Readiness_V1
**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster
**Usage :** Vérification mensuelle de la disponibilité du plan de relève
**Mis à jour :** 2026-03-20

---

## BACKUPS — ÉTAT COURANT

### Datto BCDR
- [ ] Tous les agents : dernier backup Success ou Warning acceptable
- [ ] Screenshot de vérification présent pour les VMs critiques
- [ ] Stockage local Datto : espace libre > 20%
- [ ] Stockage cloud : synchronisation OK (pas d'erreur > 24h)
- [ ] Rétention configurée selon la politique client (Hudu → Agreements)

### Veeam
- [ ] Jobs en cours : Success ou Warning acceptable
- [ ] Repository : espace libre > 20%
- [ ] Dernière vérification d'intégrité (SureBackup ou Instant Recovery test) < 30 jours
- [ ] Veeam Cloud Connect (si applicable) : synchronisation OK

### Keepit (M365)
- [ ] Connecteur Microsoft 365 : Connected (pas Disconnected)
- [ ] Dernière synchronisation Exchange : OK
- [ ] Dernière synchronisation SharePoint/OneDrive : OK
- [ ] Nombre d'utilisateurs protégés = nombre d'utilisateurs actifs

---

## PLAN DE RELÈVE — VALIDITÉ

- [ ] Document DR à jour dans Hudu pour ce client (date < 6 mois)
- [ ] Contacts d'urgence à jour (responsable client, MSP on-call)
- [ ] RTO et RPO documentés et connus de l'équipe
- [ ] Ordre de démarrage des systèmes documenté
- [ ] Accès aux ressources de reprise validé (accès Datto portal, VPN, credentials Passportal)

---

## TESTS DR

- [ ] Dernier test d'intégrité backup : _______ (date)
  - Résultat : ☐ Pass  ☐ Fail → Actions correctives : _______
- [ ] Dernier test Instant Virtualization : _______ (date)
  - RTO mesuré : _______ min / Objectif : _______ min
- [ ] Prochain test planifié : _______

---

## VÉRIFICATION ANNUELLE

- [ ] Test complet DR (Tabletop ou Functional) effectué cette année : ☐ Oui  ☐ Non
- [ ] Rapport de test archivé dans CW/Hudu : ☐ Oui
- [ ] Écarts identifiés et corrigés : ☐ Oui  ☐ En cours : _______

---

## RÉSULTAT

☐ **DR READY** — Tous les items validés
☐ **ACTIONS REQUISES** — Items en attente : _______
☐ **NON READY** — Problème critique : escalade IT-BackupDRMaster immédiatement
