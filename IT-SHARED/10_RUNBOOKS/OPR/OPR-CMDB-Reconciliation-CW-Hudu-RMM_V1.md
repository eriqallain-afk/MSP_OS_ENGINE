# OPR-CMDB-Reconciliation-CW-Hudu-RMM_V1

Status: DRAFT
Domain: OPR - CMDB and Asset Governance
Use: Reconcile assets between ConnectWise, Hudu, RMM, backup and monitoring.

## Objective
Ensure assets are consistent, owned, monitored, documented and not missing key operational fields.

## Triggers
- CMDB mismatch or missing asset.
- Hudu documentation missing or outdated.
- RMM device not matching CW configuration.
- Backup or monitoring gap detected.

## Procedure
1. Identify asset and source systems.
2. Compare name, client, site, role, status, OS, EOL, backup and monitoring.
3. Record deltas in CW internal note.
4. Create update tasks for owners of each source.
5. Confirm client-safe fields only for external artifacts.

## DoD
- [ ] Asset identified in all relevant systems.
- [ ] Deltas documented.
- [ ] Owner and ETA assigned for corrections.
- [ ] No secrets, IPs or credentials in client liverables.
