# NOC-BACKUP-Validation_Statut_Sauvegardes_V1

Status: Active
Owner: IT-BackupDRMaster / IT-Commandare-NOC
Scope: NOC / Backup / DR
Format: ASCII-safe

## Objective
Validate the daily backup status for monitored backup platforms and qualify each alert as OK, KO, No Result, False Positive, or Escalation Required.

## Triggers
- NOC ticket to validate backup status.
- Backup Monitor alert.
- Backup Radar report.
- Handover indicating unknown backup status.

## Scope
Included:
- Veeam
- Datto
- Keepit
- SaaS Backup
- Backup Radar

Excluded:
- Data restore without approval.
- Deletion of backups or restore points.
- Retention change without approved.

## Read-only first
1. Read the ticket and identify the backup product.
2. Identify [CLIENT], [JOB_BACKUP] and the workload.
3. Confirm the last known backup result.
4. Confirm if the alert is new, recurring or obsolete.
5. Do not change configuration before the diagnostic is documented.

## Diagnostic
1. Confirm the platform source.
2. Confirm the last successful backup.
3. Confirm the last failed backup.
4. Confirm if the job is enabled, planned, or obsolete.
5. Compare the source backup status with the monitoring status.
6. Classify the result: OK, Warning, Failed, No Result, Unknown, or False Positive.

## Permitted actions
- Rerun a non-destructive job if the platform and window allow it.
- Correct a false positive in the monitoring tool if the source status is OK.
- Document an obsolete job and request validation before removal from monitoring.
- Escalate if the last successful backup is too old or unknown.

## Validation
- Last successful backup is documented.
- Current alert is explained or escalated.
- Monitoring status is OK or follow-up is documented.
- CW internal note is complete.

## Escalation
Escalate to BackupDR / Senior if:
- no recent successful backup;
- potential data loss;
- multiple jobs or clients are impacted;
- restore test fails;
- SaaS credential or token error cannot be resolved by NOC.

## CW internal note
Preparation et decouverte. Consultation de la documentation.

- Product: [PRODUCT]
- Job: [JOB_BACKUP]
- Status: [OK / KO / No Result / False Positive]
- Cause: [A SUPPLIER OU LONGUEMenT ATTENDRE]
- Action: [ACTION]
- Validation: [RESULT]

## CW discussion client-safe
Preparation et decouverte. Consultation de la documentation.

- Situation: validation du statut des sauvegardes supervisees.
- Tache: confirmer si les sauvegardes recentes sont conformes.
- Action: analyse des resultats disponibles et verification de la surveillance.
- Resultat: [sauvegarde confirmee / suivi en cours / escalade requise].

Duree: [X]h[XX]2

## Safety
- No IP, credential, token, secret, hash, or raw log in client-facing outputs.
- Use only masked placeholders for sensitive data.
- Read-only first always.
