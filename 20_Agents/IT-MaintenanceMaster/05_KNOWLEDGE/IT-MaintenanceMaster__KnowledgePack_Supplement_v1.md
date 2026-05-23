# IT-MaintenanceMaster — Knowledge Pack v1 (Supplément)

> Supplément au pack existant — ajout runbooks maintenance et checklists opérationnelles.
> Charger EN COMPLÉMENT des dossiers : 01_TEMPLATES_CW/ et 04_POWERSHELL_LIBRARY/

---

## 1. RUNBOOK — Patching Windows (RMM CW OneByOne)

```
PATCHING WINDOWS — Procédure MSP (un serveur à la fois)
─────────────────────────────────────
PRÉ-REQUIS
[ ] Fenêtre maintenance confirmée avec client (OPR)
[ ] Communication client envoyée (CommsMSP)
[ ] Backup validé (BackupDRMaster) — BLOQUANT
[ ] RFC Light approuvé si serveur critique
[ ] NOC alerté : monitoring renforcé durant fenêtre

POUR CHAQUE SERVEUR (ordre : non-critiques d'abord)
─────────────────────────────────────
PRÉ-CHECK (avant patch)
[ ] Uptime serveur (pas de reboot récent non planifié)
[ ] Espace disque C: > 15% libre
[ ] Services critiques : état Normal (connectés)
[ ] Snapshot VM créé (Veeam / Hyper-V / VMware)
[ ] Note CW ouverte (TEMPLATE__CW_NOTE_INTERNE)

PATCH
[ ] Lancer Windows Update / WSUS / RMM patch job
[ ] Surveiller: pas d'erreur installation
[ ] Si reboot requis : valider fenêtre OK → reboot

POST-CHECK (après reboot)
[ ] Ping répondant
[ ] RDP fonctionnel
[ ] Services critiques redémarrés :
    - Active Directory (si DC) : Get-Service NTDS, DNS, NETLOGON
    - SQL Server (si SQL) : Get-Service MSSQLSERVER
    - Exchange (si mail) : Get-Service MSExchangeTransport, MSExchangeIS
    - IIS (si web) : Get-Service W3SVC
[ ] Event Log : aucune erreur critique post-reboot (Event 7034/41/6008)
[ ] Vérifier que le reboot was planned : Event ID 1074
[ ] Test fonctionnel (login user / accès applicatif)

CLÔTURE
[ ] Supprimer snapshot VM (si créé)
[ ] CW Note complétée : patches appliqués + état final
[ ] CMDB mise à jour : date dernier patch
[ ] CW Discussion STAR préparée (OPR clôture)
```

---

## 2. RUNBOOK — Health Check Serveur

```
HEALTH CHECK SERVEUR — Procédure mensuelle
─────────────────────────────────────
CONNEXION
[ ] Remote Desktop ou console directe
[ ] Note CW ouverte : TEMPLATE__Server_Health_Check

PERFORMANCES
[ ] CPU usage moyen (7 derniers jours) : ___% — Normal si < 70%
[ ] RAM usage : ___% — Normal si < 80%
[ ] Disques :
    - C: ___ GB libre / ___ GB total
    - D: ___ GB libre / ___ GB total (si applicable)
[ ] Processus top consommateurs CPU/RAM notés

ÉVÉNEMENTS SYSTÈME (Event Viewer)
[ ] System Log : Erreurs (rouge) derniers 30 jours : ___
    → Event ID 7034 (service arrêt inattendu) : Oui / Non
    → Event ID 41 (reboot inattendu) : Oui / Non
[ ] Application Log : Erreurs critiques : ___
[ ] Security Log : Event 4625 (auth failures) > 10 : Oui / Non

SERVICES CRITIQUES
[ ] Tous les services configurés en "Automatique" : démarrés ✅ / Arrêtés ❌
    Service : _____________ | État : ___________
    Service : _____________ | État : ___________

STOCKAGE & DONNÉES
[ ] Espace disque dans les seuils (> 15% libre) : Oui / Non
[ ] Fragmentation (si HDD) : dernière defrag < 30 jours
[ ] Corbeille vidée sur tous les volumes
[ ] Dossiers Temp nettoyés (C:\Windows\Temp + AppData\Local\Temp)

SÉCURITÉ
[ ] Windows Defender : à jour + aucune menace active
[ ] Dernier patch Windows : date _____ — retard < 30 jours : Oui / Non
[ ] Compte admin local : verrouillé / MDP robuste : Oui / Non

RÉSEAU
[ ] Ping gateway : ___ ms
[ ] Ping DNS : ___ ms
[ ] Interface(s) réseau : aucune erreur / collision

RAPPORT FINAL
Note CW : résumé health check + points d'action
Statut global : ✅ Sain / ⚠️ Attention (actions préventives) / ❌ Critique (action requise)
```

---

## 3. CHECKLIST — Validation DC/DNS Pre-Post Patch

```
DC / DNS — VALIDATION PRÉ-PATCH
─────────────────────────────────────
[ ] Réplication AD OK : repadmin /showrepl (aucune erreur)
[ ] Réplication AD OK : repadmin /replsummary
[ ] DNS résolution interne OK : nslookup dc01.client.local
[ ] DNS résolution externe OK : nslookup google.com
[ ] SYSVOL partagé et accessible : \\dc01\sysvol
[ ] NETLOGON partagé : \\dc01\netlogon
[ ] dcdiag /test:replications → 0 erreurs
[ ] FSMO roles documentés : netdom query fsmo
[ ] Snapshot VM créé

DC / DNS — VALIDATION POST-PATCH
─────────────────────────────────────
[ ] Services redémarrés : NTDS, DNS, NETLOGON, KDC, W32TM
[ ] Réplication AD OK (mêmes tests que pré)
[ ] Authentification test : connexion avec compte user standard
[ ] SYSVOL + NETLOGON accessibles
[ ] Event Log System : aucune erreur critique
[ ] GPO appliquées : gpresult /r
```

---

## 4. CHECKLIST — Validation SQL Pre-Post Patch

```
SQL SERVER — VALIDATION PRÉ-PATCH
─────────────────────────────────────
[ ] Toutes les bases en état Online : SELECT name, state_desc FROM sys.databases
[ ] Aucun job SQL en cours : SSMS → SQL Server Agent → Jobs
[ ] Backup base effectué (complet) avant patch
[ ] Journaliser connexions actives : SELECT * FROM sys.dm_exec_sessions WHERE status = 'running'
[ ] Déconnecter applications si possible
[ ] Snapshot VM créé

SQL SERVER — VALIDATION POST-PATCH
─────────────────────────────────────
[ ] Service SQL redémarré : Get-Service MSSQLSERVER
[ ] Bases Online : SELECT name, state_desc FROM sys.databases — 0 en SUSPECT/RECOVERY
[ ] Connexions applicatives rétablies
[ ] Test requête de base sur DB principale
[ ] Event Log Application : aucune erreur SQL critique
[ ] Intégrité DB : DBCC CHECKDB('[NomBase]') — aucune erreur
```

---

## 5. COMMANDES POWERSHELL — Maintenance

```powershell
# NETTOYAGE DISQUE
# Vider Temp Windows
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Nettoyer WinSxS (Windows Update cleanup)
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Identifier top 10 dossiers volumineux
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue | 
  Sort-Object Length -Descending | Select -First 10 FullName, @{N='SizeGB';E={[math]::Round($_.Length/1GB,2)}}

# SERVICES
# Vérifier services arrêtés (démarrage auto)
Get-Service | Where {$_.Status -eq 'Stopped' -and $_.StartType -eq 'Automatic'}

# Démarrer service arrêté
Start-Service -Name "ServiceName"

# WINDOWS UPDATE
# Voir historique updates installées (30 derniers jours)
Get-HotFix | Where InstalledOn -gt (Get-Date).AddDays(-30) | Sort InstalledOn -Desc

# Vérifier updates en attente (nécessite PSWindowsUpdate)
Get-WindowsUpdate -MicrosoftUpdate

# Installer updates
Install-WindowsUpdate -AcceptAll -AutoReboot

# EVENT LOG
# Erreurs derniers 24h
Get-EventLog -LogName System -EntryType Error -Newest 50 -After (Get-Date).AddDays(-1)

# Événements reboot
Get-EventLog -LogName System | Where {$_.EventID -in @(41,1074,6008)} | Select -First 10
```

---

> Voir aussi : RUNBOOK__Windows_Patching_CW_RMM_OneByOne.md | RUNBOOK__DC_PrePost_Validation.md
