# MEM-IT-REFERENCE-ONEPAGER — v1.0
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
meta:
  doc_id: MEM-IT-REFERENCE-ONEPAGER
  version: v1.0
  status: normative
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, CMD-INFRA, CMD-TECH, SEC-X]

## A) Ownership & routing (résumé)
- Monitoring/alerts → CMD-NOC (esc: INFRA/TECH/SEC-X)
- Réseau/core infra → CMD-INFRA (esc: NOC + ISP/Vendor + SEC-X si suspicion)
- Endpoint/M365/apps → CMD-TECH (esc: NOC si majeur + SEC-X si compromission)
- SLA/coordination/change → CMD-OPR (esc: Management + validation client si besoin)
- Sécurité (phishing/EDR/IAM/anomalie/exfil) → SEC-X (IR lead)

## B) Severity & update cadence
- S0: 15 min
- S1: 30 min
- S2: 2 h
- S3: 1×/jour ouvré
- S4: selon ticket

## C) Formats obligatoires
- Incident: INC-ID + sev + impact + owner + timeline + next update time
- Change: RFC-Light (objectif/scope/risque/test/rollback/fenêtre/owner/validation)
- S0/S1: Postmortem PM-INC_ID + CAPA (owner/date/success criteria)

## D) Comms minimum
- Interne: [INCIDENT][Sx] INC-ID impact owner next update
- Client: incident détecté + impact + prochaine update + résolution

## E) CMDB / KB
- CMDB CI: ci_id, client_code, type, owner, criticality, dependencies, SoT, last_updated
- Post-change: MAJ CMDB/KB ≤ 48h
- S0/S1 ou récurrence: KB obligatoire

## F) Definition of Done (DoD)
- RUN: owner+sev+updates+log+close summary
- CHANGE: validation+test+rollback+comms+CMDB/KB update
- PM: RCA+CAPA+dates+preuves+KB/CMDB

## G) Gouvernance
- Propriétaire doc: CMD-OPR | Co-owners: CMD-NOC, CMD-INFRA, CMD-TECH, SEC-X
- Versioning: v1 → v1.1 → v2 (voir MEM-IT-Versioning-Policy)
