# TEMPLATE_BACKUP_Restore_Trimestriel_V1
**Agent :** IT-BackupDRMaster | IT-MaintenanceMaster
**Usage :** Rapport de test de restauration trimestriel — conformité + archivage
**Mis à jour :** 2026-05-21

---

## CW NOTE INTERNE — RAPPORT TEST RESTAURATION TRIMESTRIEL

> Copier ce contenu dans le billet ConnectWise → Note interne.
> Remplir toutes les sections avant de clore le billet.

---

## 1. EN-TÊTE DU RAPPORT

| Champ | Valeur |
|---|---|
| **Client** | _____________________________ |
| **Trimestre / Année** | Q___ / 202___ |
| **Date du test** | AAAA-MM-JJ |
| **Heure début** | HH:MM |
| **Heure fin** | HH:MM |
| **Technicien** | _____________________________ |
| **Billet ConnectWise** | #_____________ |
| **Solution de backup** | ☐ Veeam  ☐ Datto  ☐ Keepit  ☐ Autre : __________ |
| **Version / Build outil backup** | _____________________________ |

---

## 2. SCÉNARIO TESTÉ

| Champ | Valeur |
|---|---|
| **Type de scénario** | ☐ Q1 — Fichiers/dossiers  ☐ Q2 — VM complète  ☐ Q3 — SQL  ☐ Q4 — BMR/P2V |
| **Asset source** | Nom du serveur / VM / service : _____________________________ |
| **Point de restauration utilisé** | Date/heure : AAAA-MM-JJ HH:MM |
| **Chemin / base / VM cible restaurée** | _____________________________ |
| **Environnement de test** | _____________________________ (confirmer : isolé, pas de prod) |
| **RPO cible documenté** | ___ heures (source : SLA / DR Plan) |
| **RTO cible documenté** | ___ heures (source : SLA / DR Plan) |

---

## 3. RÉSULTATS MESURÉS

| Métrique | Valeur mesurée | Objectif | Écart | Statut |
|---|---|---|---|---|
| **RTO réel** | ___ h ___ min | ___ heures | +/- ___ min | ☐ OK  ☐ NOK |
| **RPO réel** | ___ h ___ min | ___ heures | +/- ___ min | ☐ OK  ☐ NOK |
| **Volume restauré** | ___ GB | — | — | ☐ Complet  ☐ Partiel |
| **Données restaurées** | ☐ OK — Intègres et accessibles | ☐ NOK — Problème détecté | | |

---

## 4. TABLEAU DE VALIDATION

| Critère | Résultat | Commentaire |
|---|---|---|
| ☐ **Intégrité des données** — fichiers lisibles, hash check (si applicable) | ☐ OK  ☐ NOK  ☐ N/A | |
| ☐ **Connectivité réseau** — ping / Test-Connection vers la cible restaurée | ☐ OK  ☐ NOK  ☐ N/A | |
| ☐ **Services critiques** — Windows / Linux services actifs et démarrés | ☐ OK  ☐ NOK  ☐ N/A | |
| ☐ **Données applicatives** — accès à l'application / base de données validé | ☐ OK  ☐ NOK  ☐ N/A | |
| ☐ **Dépendances** — DNS résolu, AD joignable, SQL accessible si requis | ☐ OK  ☐ NOK  ☐ N/A | |
| ☐ **ACL / permissions** — droits d'accès préservés (Q1 : fichiers) | ☐ OK  ☐ NOK  ☐ N/A | |
| ☐ **Intégrité SQL** (Q3) — DBCC CHECKDB sans erreur | ☐ OK  ☐ NOK  ☐ N/A | |
| ☐ **Rôles Windows** — rôles/fonctionnalités actifs post-restauration | ☐ OK  ☐ NOK  ☐ N/A | |
| ☐ **Nettoyage effectué** — environnement de test supprimé après validation | ☐ OK  ☐ NOK | |

---

## 5. ÉCARTS DÉTECTÉS ET CORRECTIFS APPORTÉS

> Documenter tout écart, même mineur. Si aucun écart, indiquer explicitement "Aucun écart détecté."

### 5.1 Écarts détectés

| # | Description de l'écart | Sévérité | Impact |
|---|---|---|---|
| 1 | | ☐ Critique  ☐ Majeur  ☐ Mineur | |
| 2 | | ☐ Critique  ☐ Majeur  ☐ Mineur | |
| 3 | | ☐ Critique  ☐ Majeur  ☐ Mineur | |

### 5.2 Correctifs apportés pendant le test

| # | Correctif | Appliqué par | Résultat |
|---|---|---|---|
| 1 | | | |
| 2 | | | |

### 5.3 Actions correctives planifiées (post-test)

| Action | Responsable | Échéance | Billet CW |
|---|---|---|---|
| | | AAAA-MM-JJ | # |
| | | AAAA-MM-JJ | # |

---

## 6. VERDICT FINAL

```
┌─────────────────────────────────────────────────────────────────┐
│                        VERDICT DU TEST                          │
│                                                                 │
│   ☐  SUCCÈS          — Tous les critères atteints               │
│                                                                 │
│   ☐  SUCCÈS PARTIEL  — Restauration fonctionnelle,              │
│                         écarts mineurs documentés               │
│                                                                 │
│   ☐  ÉCHEC           — Restauration impossible ou données       │
│                         corrompues ou RTO/RPO > 120% objectif   │
└─────────────────────────────────────────────────────────────────┘
```

**Justification du verdict :**

_______________________________________________________________________________

_______________________________________________________________________________

---

## 7. ACTIONS SI ÉCHEC

> Compléter uniquement si verdict = ÉCHEC ou SUCCÈS PARTIEL nécessitant re-test.

- [ ] Escalade effectuée vers @IT-BackupDRMaster le : AAAA-MM-JJ HH:MM
- [ ] Escalade effectuée vers @IT-Commandare-NOC le : AAAA-MM-JJ HH:MM
- [ ] Client notifié le : AAAA-MM-JJ HH:MM
- [ ] Incident QA loggué dans `00_QA/incidents/IT-BackupDRMaster/` : ☐ Oui  ☐ Non
- [ ] Billet correctif CW ouvert : # _____________
- [ ] Re-test planifié le : AAAA-MM-JJ

---

## 8. SIGNATURE ET ARCHIVAGE

| Champ | Valeur |
|---|---|
| **Technicien** | _____________________________ |
| **Date de clôture** | AAAA-MM-JJ |
| **Heure de clôture** | HH:MM |
| **Rapport archivé dans Hudu** | ☐ Oui — Chemin : Client → Rapports → Backup & DR |
| **Note CW mise à jour** | ☐ Oui — Billet # _____________ |
| **Captures d'écran jointes** | ☐ Oui  ☐ Non — Raison : ________ |
| **Dashboard QA mis à jour** | ☐ Oui (via @IT-QAMaster)  ☐ Non |

---

*TEMPLATE_BACKUP_Restore_Trimestriel_V1 — IT MSP Intelligence Platform — 2026-05-21*
