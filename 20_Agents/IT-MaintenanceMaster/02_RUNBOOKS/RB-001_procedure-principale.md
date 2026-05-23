# RB-001 — Intervention Complète : De /start à /close
**Agent :** IT-MaintenanceMaster | **Usage :** Guide de référence pour chaque intervention

---

## Flux type d'une intervention

```
1. /start  →  triage + plan + scripts precheck
2. Exécuter les scripts → coller les résultats
3. /check  →  analyser résultats → prochaine action
4. Itérer (step 2-3) jusqu'à résolution
5. /close  →  sélectionner les livrables
6. /kb     →  si P1/P2 ou nouveau type (automatique)
7. /db     →  si P1/P2 ou > 30 min (automatique)
```

---

## Flux maintenance planifiée

```
1. /start_maint  →  pack complet : ordre, snapshots, precheck, notice Teams
2. Activer mode maintenance RMM  →  proposer notice Teams début
3. Exécuter patching serveur par serveur
4. Après chaque serveur : /check résultats
5. Fin fenêtre : désactiver mode maintenance RMM
6. Notice Teams fin de maintenance
7. /close  →  Note Interne + Discussion
```

---

## Flux estimation/devis

```
1. /estimé  →  produire estimation structurée
2. Ajuster selon retours du tech
3. Exporter en format client-safe
```

---

## Référence commandes par domaine

| Domaine | Commande |
|---|---|
| AD / DC | `/runbook dc` ou `/runbook ad` |
| SQL Server | `/runbook sql` |
| Veeam Backup | `/runbook veeam` |
| RDS | `/runbook rds` |
| M365 / Exchange | `/runbook m365` |
| Réseau / Firewall | `/runbook reseau` |
| Post-panne électrique | `/runbook panne` |
| Imprimantes | `/runbook print` |
| Linux / XCP-ng | `/runbook linux` |

---

## Standards obligatoires

**Snapshots :** `@TBILLET_PHASE_SERVEUR_SNAP_YYYYMMDD_HHMM`
**Scripts :** `CATEGORIE_ACTION_CIBLE_v1.ps1`
**Logs :** `C:\IT_LOGS\CATEGORIE\CATEGORIE_SERVEUR_TICKET_DATE.log`
