# MEM-IT-Conventions — v1.0
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
meta:
  doc_id: MEM-IT-Conventions
  version: v1.0
  status: normative
  timezone: America/Montreal
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, CMD-INFRA, CMD-TECH, SEC-X]

## 1) Objectif
Standardiser le nommage, les IDs, les rôles (owners), les escalades et les artefacts pour RUN/CHANGE/SEC dans un contexte MSP.

## 2) Préfixes & IDs
- Blocs mémoire: `MEM-IT-<Bloc>`
- Incidents: `INC-YYYYMMDD-<ClientCode>-<ShortSlug>`
- Changements: `RFC-YYYYMMDD-<ClientCode>-<ShortSlug>`
- Postmortems: `PM-<INC_ID>`

## 3) Rôles (Commandare)
- CMD-NOC: supervision, triage, coordination incident
- CMD-INFRA: réseau, serveurs, cloud, capacity
- CMD-TECH: endpoints, M365/apps/outils, support L2/L3
- CMD-OPR: process, change, SLA, reporting, gouvernance
- SEC-X: transverse sécurité (IAM, vuln, IR, compliance)

## 4) Niveaux d’escalade (standard)
`L1 → L2 → L3 → Vendor/Provider → Management → Client`

## 5) Formats attendus (minimum)
- Incident update: horodatage, état, impact, actions depuis dernière update, next steps, ETA/risques, prochaine update
- RFC-Light: objectif, scope, risque, test, rollback, fenêtre, owner, validation
- Postmortem: timeline, RCA, CAPA (owner/date/success criteria)

## 6) Definition of Done (DoD) — checklists rapides
### RUN (incident)
- [ ] Owner assigné + back-up nommé
- [ ] Sévérité (S0–S4) définie + timestamps (détection/début)
- [ ] Canal incident interne + log actions
- [ ] Comms client selon matrice (si applicable)
- [ ] Clôture: résumé + next steps
- [ ] S0/S1: postmortem planifiée et produite

### CHANGE (RFC)
- [ ] CI impactés listés
- [ ] Test + rollback écrits
- [ ] Fenêtre confirmée + validations obtenues
- [ ] Comms prêtes (interne/client)
- [ ] Post-change: MAJ CMDB/KB sous 48h

### POSTMORTEM (S0/S1)
- [ ] Timeline complète
- [ ] RCA (cause racine) + facteurs contributifs
- [ ] CAPA avec owners + dates + critères de succès
- [ ] KB/CMDB/monitoring mis à jour
