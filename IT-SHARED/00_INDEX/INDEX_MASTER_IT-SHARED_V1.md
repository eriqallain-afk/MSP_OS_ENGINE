# INDEX_MASTER_IT-SHARED_V1

Canonical index for IT-SHERED artifacts.

## Entries
- `00_INDEX/INTENT_RUNBOOK_MATRIX_V1.md` - Intent to runbook matrix.
- `00_DOCS/ARCHITECTURE_DECISION_LOG.md` - ADRs plateforme — 9 décisions documentées (Out-String, 2-phases, scripts inline, Output Policy, WKS, etc.). Accessible aux agents via [pl5] arch-decisions. v1.0 — 2026-05-22.
- `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md` - Contextual /runbook menu.
- `IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__SERVER_ROLE_DISCOVERY.md` - Server role discovery.
- `IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__DC_PATCHING_PRECHECK.md` - DC patching prechecks.
- `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-GPO_Management_V1.md` - AD GPO Management.
- `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-FolderSecurity_V1.md` - AD Folder Security.
- `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-NewVM_Deployment_V1.md` - New VM Deployment.
- `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-HyperV_Operations_V2.md` - Hyper-V Operations (health check, snapshots, live migration, precheck reboot). v2.1 — 2026-05-21.
- `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-PendingReboot_V2.md` - Pending Reboot Windows — détection flags, precheck rôles, reboot contrôlé, postcheck. v2.2 — 2026-05-21.
- `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Validation_Statut_Sauvegardes_V1.md` - NOC Backup Status Validation.
- `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Restore_Test_Trimestriel_V1.md` - Test de restauration trimestriel — RTO/RPO, 4 scénarios rotation (fichiers, VM, SQL, BMR), conformité ISO 27001/SOC 2/PCI-DSS/Loi 25. v1.0 — 2026-05-21.
- `IT-SHARED/20_TEMPLATES/07_TEMPLATE_BACKUP/TEMPLATE_BACKUP_Restore_Trimestriel_V1.md` - Template rapport test restauration trimestriel — CW NOTE INTERNE, RTO/RPO, verdict SUCCÈS/ÉCHEC, archivage Hudu.
- `IT-SHARED/20_TEMPLATES/06_TEMPLATE _INCIDENT/TEMPLATE_INTERVENTION_Standard_V1.md` - Compte rendu intervention standard — chronologie avec raison étapes, cause racine, validation, suivis. v1.0 — 2026-05-21.
- `IT-SHARED/20_TEMPLATES/06_TEMPLATE _INCIDENT/TEMPLATE_INTERVENTION_P1_PostMortem_V1.md` - Rapport incident majeur P1 — post-mortem complet, RCA, timeline, impact, actions correctives, communication client. v1.0 — 2026-05-21.
- `IT-SHARED/20_TEMPLATES/06_TEMPLATE _INCIDENT/TEMPLATE_INTERVENTION_Compact_V1.md` - Intervention courte <30 min — traçabilité minimale avec raison de l'étape suivante obligatoire. v1.0 — 2026-05-21.
- `IT-SHARED/10_RUNBOOKS/00_POLICIES/PROMPT_FRAMEWORK_MSP_Intelligence_V1.md` - Framework de prompting MSP Intelligence — 4 couches (rôle, mode opératoire, output policy, gabarits), formats Diagnostic/Script/CW/Escalade, packs AD/Exchange/Veeam/RDS/Hyper-V, exemples bons/mauvais/refus. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Poste_Lent_V1.md` - Poste lent — diagnostic CPU/RAM/disque/processus, nettoyage, arbre de décision N2. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Login_V1.md` - Connexion impossible — compte verrouillé, MDP expiré, M365/MFA, jonction domaine. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Outlook_V1.md` - Outlook/M365 — profil, invites MDP, recherche, plantage, OWA. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Teams_AV_V1.md` - Teams / audio-vidéo — son, caméra, cache, connectivité. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Imprimante_V1.md` - Imprimante client — spooler, file bloquée, réinstallation driver. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Partage_Reseau_V1.md` - Lecteur réseau / partage SMB — disparu, accès refusé, lenteur. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-VPN_Client_V1.md` - VPN client — connexion impossible, déconnexions, ressources inaccessibles. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Alerte_AV_V1.md` - Alerte antivirus / comportement suspect — triage N2, escalade sécurité. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Profil_Corrompu_V1.md` - Profil utilisateur corrompu — .bak, profil temporaire, réparation registre. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Onboarding_Poste_V1.md` - Onboarding nouveau poste — validation post-déploiement, checklist remise utilisateur. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Offboarding_V1.md` - Offboarding employé — inventaire données, désactivation compte, wipe sécurisé. v1.0 — 2026-05-22.
- `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-COMPLIANCE-5Piliers_Framework_V1.md` - Framework scoring maturité sécurité 5 piliers (P1 Lifecycle Risk, P2 Governance Integrity, P3 Continuity Assurance, P4 Exposure Surface, P5 Operational Drift) — score pondéré dynamique, critères par pilier, calculateur PowerShell, niveaux Mature/Bon/Acceptable/Critique, runbooks associés, HANDOFF_BLOCK IT-ReportMaster. v1.0 — 2026-05-23.
- `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-ENTRA-SecurityCompliance_V1.md` - Audit sécurité Entra ID — Connect-MgGraph, MFA enforcement, Conditional Access, rôles privilégiés, PIM, Identity Protection risky users, comptes inactifs, guests, app registrations orphelines, break-glass, Secure Score. Scoring P2/P4/P5. v1.0 — 2026-05-23.
- `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-PURVIEW-ComplianceAudit_V1.md` - Audit conformité Purview — Connect-IPPSSession, DLP policies/workloads/alertes, sensitivity labels, rétention Exchange/SPO/OD/Teams, partage externe, Unified Audit Log, Compliance Manager. Scoring P3/P4/P5. v1.0 — 2026-05-23.
- `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS/TEMPLATE_RAPPORT_Compliance_5Piliers_V1.md` - Template rapport compliance 5 piliers — CW note interne (scores, constats Entra+Purview, top 5 lacunes) + rapport client Word/PowerPoint (gauges Microsoft, commentaires non techniques, priorités remédiation, évolution score, prochaines étapes) + HANDOFF_BLOCK IT-ReportMaster. v1.0 — 2026-05-23.
