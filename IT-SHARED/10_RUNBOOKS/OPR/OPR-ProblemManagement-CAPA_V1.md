# OPR-ProblemManagement-CAPA_V1

Status: DRAFT
Domain: OPR - Problem Management
Use: Transform recurring incidents into a problem record with RCA, CAPA, owner and follow-up.
Consumers: Any IT agent when recurrence or technical debt is detected.

## 1. Objective
Reduce repeat incidents by capturing patterns, identifying cause, defining corrective actions and making follow-up visible.

## 2. Triggers
- Same alert or symptom returns.
- 3 or more incidents on the same system or service.
- Manual fix required multiple times.
- Known technical debt or unresolved root cause.

## 3. Procedure
1. Group related tickets, alerts and timelines.
2. Define problem statement in client-safe language.
3. Document known cause, probable cause, or unknown with hypothesis.
4. Define CAPA: corrective action, preventive action, owner and ETA.
5. Link`ack to tickets, KB, CMDB or change record if needed.

## 4. Artifacts
- Problem record or CW parent ticket.
- RCA note or hypothesis.
- CAPA action list with owner and ETA.
- KB or monitoring update if recurrent.

## 5. DoD
- [ ] Recurrence pattern documented.
- [ ] RCA or hypothesis captured.
- [ ] CAPA owner and ETA defined.
- [ ] Stakeholders notified if impact or SLA risk exists.
- [ ] No secrets, IP, credentials or confidential details in client artifacts.
