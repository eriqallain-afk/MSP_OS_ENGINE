# OPR-SLA-BreachPrevention_V1

Status: DRAFT
Domain: OPR - OPS MSP
Use: Prevent SLA miss by detecting risk, escalating early and documenting actions.
Consumers: Any IT agent. This runbook maps an SLA risk intent to an OPR governance workflow.

## 1. Objective
Keep tickets from breaching SLA through proactive review, clear ownership, client updates and escalation.

## 2. Triggers
- SLA at risk or overdue.
- No update in the expected cadence.
- Blocked by vendor, client, or admin decision.
- Priority or impact changed.

## 3. Procedure
1. Confirm ticket priority, SLA timer, actual impact and owner.
2. Confirm the next technical action and the next update time.
3. Escalate to the active owner if blocked or without progress.
4. Add a CW internal note and client-safe update if applicable.
5. Set next review time and follow up until risk is cleared.

## 4. DoD
- [ ] SLA risk validated.
- [ ] Owner and next action confirmed.
- [ ] CWand client updates completed.
- [ ] Escalation added if blocked.
- [ ] No IP, secrets, or credentials in client artifacts.
