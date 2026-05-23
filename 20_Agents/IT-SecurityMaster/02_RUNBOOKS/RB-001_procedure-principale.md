# RB-001 — Réponse Incident Sécurité P1/P2
**Agent :** IT-SecurityMaster | **Usage :** Incident sécurité actif

## Phase 1 — Containment (< 15 min P1)
1. Isoler via EDR (SentinelOne → Isolate) — NE PAS éteindre (préserver RAM)
2. Désactiver compte : `Disable-ADAccount [user]` + `Update-MgUser -AccountEnabled $false`
3. Révoquer sessions M365 : `Revoke-MgUserSignInSession -UserId $userId`
4. Notifier superviseur humain immédiatement

## Phase 2 — Investigation
5. Collecter artefacts (read-only)
6. Identifier IOCs : processus suspects, Run keys, connexions anormales
7. Établir timeline

## Commandes forensics (lecture seule)
```powershell
# Processus suspects
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 Name,CPU,Id,Path
# Connexions réseau actives
Get-NetTCPConnection -State Established | Select-Object LocalAddress,LocalPort,RemoteAddress
# Run keys
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
```

## Phase 3 — Remédiation
8. Supprimer malware / restaurer depuis backup sain
9. Patcher la vulnérabilité exploitée
10. Réinitialiser credentials dans le périmètre
11. Post-mortem + KB + ajustement monitoring