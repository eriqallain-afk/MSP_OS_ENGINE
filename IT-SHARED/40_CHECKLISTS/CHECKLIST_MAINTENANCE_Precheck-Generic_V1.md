# CHECKLIST — PRECHECK (Generic Windows Server)
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

- [ ] Uptime / last boot
- [ ] Pending reboot (CBS/WU/PendingFileRename/CCM)
- [ ] CPU/RAM (si perf incident)
- [ ] Disques (C: + volumes data) — espace libre
- [ ] Services critiques (selon rôle)
- [ ] Sessions (RDS) si reboot prévu
- [ ] Event Logs: System/Application (Errors/Critical sur 1–2h)
- [ ] Backups : dernier job OK (si maintenance)
- [ ] Monitoring: alertes actives vs baseline

## REBOOT_UPTIME_OBLIGATOIRE
PRECHECK=LastBootUpTime+Uptime via script, log au billet.
POSTCHECK=LastBootUpTime+Uptime via script apres reboot, log au billet.