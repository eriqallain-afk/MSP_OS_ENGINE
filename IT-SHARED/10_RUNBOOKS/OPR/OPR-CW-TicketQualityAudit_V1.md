# OPR-CW-TicketQualityAudit_V1

Status: DRAFT
Domain: OPR - OPS MSP

Use: Audit CW ticket quality before closure.
Consumers: Any IT agent. This runbook maps a closure intent to a quality gate, not to a single agent.


## 1. Objective
Ensure a CW ticket is not closed until the operational DoD is met: context, cause, actions, validation, client-safe update, and next actions.

## 2. Triggers
- /close or closure request.
- CW note or discussion is missing.
- Time is logged but value is not clear.
- P1/P2 resolved and post-incident artifacts are needed.

## 3. Inputs
- Ticket ID: [A CONFIRM]
- Client: [A CONFIRM]
- Impact: [A CONFIRM]
- Severity: [A CONFIRM]
- Status: [A CONFIRM]

## 4. Procedure
1. Read title, description, alert, time entries and internal notes.
2. Confirm cause: known, probable, or unknown with hypothesis.
3. Confirm actions taken, results and validation tests.
4. Confirm customer-safe CW discussion is added.
5. Confirm next actions, owner and ETA if not complete.

## 5. Artifacts
Required:
- CW internal note.
- CW discussion.
- Technical log or attachment if script was used.
- Post-mortem task if P1/P2.

## 6. DoD
- [ ] Cause documented or marked unknown with hypothesis.
- [ ] Actions and results documented.
- [ ] Validation completed.
- [ ] Client-safe discussion added.
- [ ] No secrets, tokens, IPs, or credentials in client artifacts.
- [ ] KB or CMDB update captured if needed.

## 7. Escalation
| Situation | Target | Delay |
|---|---|---|
| Missing technical resolution | Technical owner | Immediate |
| P1/P2 without post-mortem | IT-ReportMaster | < 48h |
| Recurring issue | IT-KnowledgeKeeper + OPR | Next business day |
