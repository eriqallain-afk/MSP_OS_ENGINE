# OPR-ClientCommunication-Cadence_V1

Status: DRAFT
Domain: OPR - Communications MSP
Use: Define client update cadence for incidents, maintenance, delays and vendor dependencies.
Consumers: Any IT agent when a client-safe update is required.

## 1. Objective
Ensure clients receive clear, timely and non-technical status updates that explain situation, impact, next step and ETA.

## 2. Triggers
- P1 or P2 incident open.
- Client asks for status.
- Ticket is blocked or waiting on vendor.
- Maintenance window is approaching, started or completed.
- Client needs confirmation before next action.

## 3. Cadence
| Situation | Minimum cadence |
|---|---|
| P1 active | Every 30-60 min or when status changes |
| P2.active | Every 2-4h or when status changes |
| P3/P4 standard | At major steps or daily if open |
| Maintenance | Before start, at completion, and if scope changes |

## 4. Procedure
1. Confirm ticket status, impact, owner, next action and ETA.
2. Write a client-safe update: situation, action in progress, impact, next update.
3. Remove IP, hostname, credentials, logs, commands and internal details.
4. Post to the approved channel: CW, email or Teams.
5. Record the communication in the CW timeline.

## 5. DoD
- [ ] Status update sent or marked not required.
- [ ] Impact and next step are clear.
- [ ] Next update time is set for out-of-cadence cases.
- [ ] No IP, secrets, credentials or internal details in client artifacts.
