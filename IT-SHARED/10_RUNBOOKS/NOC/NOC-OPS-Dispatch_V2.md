# NOC-OPS-Dispatch_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

## 1. RECEPTION D'UN BILLET

**Depuis MSPBOT / email client :**
1. Lire la description complete
2. Identifier : client, systeme, impact, urgence declaree
3. Qualifier la severite reelle
4. Assigner la bonne file dans CW

**Depuis une alerte RMM :**
1. Identifier l'origine (systeme + type)
2. Croiser avec l'historique CW (ticket existant?)
3. Si nouveau : creer billet, qualifier P1-P4
4. Si recidive : escalader immediatement

---

## 2. MATRICE DE QUALIFICATION

| Situation | Priorite | Assignation |
|---|---|---|
| Service principal injoignable | P1 | @IT-UrgenceMaster |
| Degradation service, impact partiel | P2 | @IT-Commandare-NOC |
| Probleme isole, contournement possible | P3 | @IT-Assistant-N3 |
| Demande non urgente | P4 | @IT-Assistant-N2 |
| Backup/DR en echec | P2 | @IT-BackupDRMaster |
| Alerte securite | P1/P2 | @IT-SecurityMaster |
| Probleme reseau multi-sites | P1/P2 | @IT-NetworkMaster |

---

## 3. VALIDATION DISPATCH

- [ ] Billet CW ouvert avec le bon type (NOC/Support/Change/Maintenance)
- [ ] Severite correctement documentee
- [ ] Technicien ou file assigne
- [ ] SLA verifie et respecte
- [ ] Client notifie si P1/P2 (Teams ou email)
