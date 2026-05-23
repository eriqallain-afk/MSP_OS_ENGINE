# NOC-OPS-CommandCenter_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

## 1. DEBUT DE QUART

- [ ] Consulter tous les billets OPEN dans CW — trier par priorite P1->P4
- [ ] Verifier N-able : alertes actives non acquittees
- [ ] Verifier Auvik : alertes reseau actives
- [ ] Verifier Veeam / Datto : jobs en echec des dernieres 24h
- [ ] Lire le dernier rapport de handover

---

## 2. GESTION DES INCIDENTS

### Escalade selon severite
| Severite | Action | Delai |
|---|---|---|
| P1 | Escalader a @IT-UrgenceMaster | < 5 min |
| P2 | Notifier supervisor + assigner technicien | < 15 min |
| P3 | Assigner selon disponibilite | < 2h |
| P4 | File normale | < 4h |

---

## 3. COORDINATION MULTI-INCIDENTS

- Ne jamais gerer plus de 2 P1 simultanement sans escalade
- Un incident P1 = un technicien dedie + un coordinateur NOC
- Updates Teams toutes les 30 min sur les P1/P2 actifs

---

## 4. HANDOVER DE QUART

Document obligatoire a produire :
- Incidents actifs (numero, client, statut, prochaine action)
- Alertes en suspens
- Points d'attention pour le quart suivant
- Technicien sortant + entrant (nom + heure)
