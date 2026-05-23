# NOC-OPS-FrontDoor_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

## 1. CANAUX D'ENTREE

- Appel direct client -> @IT-FrontLine
- Email critique -> @IT-Commandare-NOCDispatcher
- Alerte RMM P1 -> @IT-Commandare-NOC
- Teams message urgent -> @IT-UrgenceMaster

---

## 2. QUALIFICATION INITIALE (< 3 minutes)

1. **Qui est impacte ?** (un utilisateur / un service / le site complet)
2. **Depuis quand ?** (minutes / heures / ce matin)
3. **Quoi exactement ?** (service down / lenteur / erreur)
4. **Impact business ?** (perte revenu / securite / operationnel degrade)

---

## 3. ARBRE DE DECISION

- Panne totale site -> P1 -> @IT-UrgenceMaster (RUNBOOK IT_URGENCE_PANNE_HQ)
- Securite / ransomware -> P1 -> @IT-SecurityMaster
- Service critique down -> P1/P2 -> @IT-Commandare-NOC
- Multi-utilisateurs impactes -> P2 -> @IT-Commandare-NOC
- Incident isole -> P3 -> @IT-Commandare-NOCDispatcher

---

## 4. ACTIONS IMMEDIATES P1

- [ ] Ouvrir billet CW IMMEDIATEMENT
- [ ] Notifier le technicien senior de garde
- [ ] Envoyer notice Teams (INCIDENT EN COURS)
- [ ] Lancer RUNBOOK IT_URGENCE_P1P2 ou IT_URGENCE_PANNE_HQ
- [ ] Escalader au client si impact visible (< 5 min pour P1)
