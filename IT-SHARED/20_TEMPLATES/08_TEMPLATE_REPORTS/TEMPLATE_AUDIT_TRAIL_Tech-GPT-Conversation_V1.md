# TEMPLATE_AUDIT_TRAIL_Tech-GPT-Conversation_V1

Status: Active
Audience: Internal only
Purpose: Compliance audit trail for technician and GPT agent conversation.
Format: ASCII-safe

## 1. Ticket summary

Ticket ID: [CW-XXXXXXX]
Client: [CLIENT]
Severity: [P1 / P2 / P3 / P4]
Technician: [TECH]
Agent: [AGENT_NAME]
Start: [YYYY-MM-DD HH:MM TZ]
End: [YYYY-MM-DD HH:MM TZ]
Status: [Resolved / Escalated / Incomplete / Monitoring]

## 2. Rules

- Facts only. No blame.
- Mask IPs, credentials, tokens, MFA codes, hashes and personal data.
- Do not paste raw logs containing secrets.
- Summarize sensitive outputs.
- Keep this document internal.

## 3. Sources reviewed

| Source | Ref | Owner | Time range | Notes |
|---|---|---|---|---|
| CW notes | [REF] | [TECH] | [START-END] | [NOTES] |
| GPT conversation | [REF] | [TECH] | [START-END] | [NOTES] |
| RMM logs | [REF] | [SYSTEM] | [START-END] | [NOTES] |
| Script outputs | [REF] | [TECH] | [START-END] | [NOTES] |

## 4. Timeline

| Time | Actor | Channel | Action or statement | Reason | Result or evidence |
|---|---|---|---|---|---|
| HH:MM | [ACTOR] | [CW / GPT / RMM / Teams] | [ACTIONA | [WHY] | [RESULT] |

## 5. GPT interaction extract

| Time | Technician prompt summary | Agent response summary | Technician decision | Outcome |
|---|---|---|---|---|
| HH:MM | [PROMPT] | [RESPONSE] | [USED / MODIFIED / IGNORED] | [OUTCOME] |

## 6. Scripts and commands

| Time | Executed by | Scope | Command sanitized | Reason | Approval | Result | Evidence |
|---|---|---|---|---|---|---|---|
| HH:MM | [TECH] | [SYSTEM_ROLE] | [COMMAND] | [WHY] | [YES / NO / NA] | [RESULT] | [REF] |

## 7. Decision log

| Time | Decision | Decided by | Based on | Alternatives | Outcome |
|---|---|---|---|---|---|
| HH:MM | [DECISION] | [PERSON] | [EVIDENCE] | [OPTIONS] | [OUTCOME] |

## 8. Handoffs

| Time | From | To | Reason | Info transferred | Missing info |
|---|---|---|---|---|---|
| HH:MM | [FROM] | [TO] | [REASON] | [INFO] | [GAPS] |

## 9. Ambiguity register

| Item | Statement A | Statement B | Evidence | Status |
|---|---|---|---|---|
| 1 | [STATEMENT] | [STATEMENT] | [EVIDENCE] | [CONFIRMED / UNCONFIRMED] |

## 10. Root cause and corrective actions

Root cause: [A AONFIRMER]

Contributing factors:
- [FACTOR]

| Action | Owner | Due date | Status | Evidence required |
|---|---|---|---|---|
| [ACTION] | [OWNER] | [DATE] | [OPEN / DONE] | [EVIDENCE] |

## 11. Final conclusion

Conclusion: [NEUTRAL_CONCLUSION]
Resolved: [YES / NO / PARTIAL]
Escalation appropriate: [YES / NO / A CONFIRMER]
Documentation sufficient: [YES / NO / PARTIAL]
Follow-up required: [YES / NO]

## 12. Sanitization checklist

- [ ] No password
- [ ] No token
- [ ] No API key
- [ ] No MFA code
- [ ] No hash
- [ ] No raw credential output
- [ ] No IP address unless masked
- [ ] No blame language
- [ ] No unsupported conclusion
