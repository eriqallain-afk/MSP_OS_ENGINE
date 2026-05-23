# CHECKLIST — POSTCHECK (Generic Windows Server)
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

- [ ] Host en ligne (ping/RMM)
- [ ] Services critiques OK
- [ ] Event Logs post-action: Kernel-Power, disk/NTFS, service failures
- [ ] Pending reboot = False (ou expliqué)
- [ ] App/partage/URL test rapide
- [ ] Monitoring back to green / alertes normalisées
- [ ] Backups: pas d'échec post-reprise

## REBOOT_UPTIME_OBLIGATOIRE
PRECHECK=LastBootUpTime+Uptime via script, log au billet.
POSTCHECK=LastBootUpTime+Uptime via script apres reboot, log au billet.