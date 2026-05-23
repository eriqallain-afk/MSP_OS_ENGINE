# KB — Veeam : Échecs récurrents "Failed to retrieve object hierarchy" — Probe RMM VMware
**Référence :** KB-VEEAM-001
**Domaine :** Backup / Veeam / VMware ESXi / RMM Monitoring
**Créé de :** Ticket CW #0001234 — Otto Inc
**Date :** 2026-03-24
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Auteur :** @IT-BackupDRMaster + @IT-MonitoringMaster

---

## Symptôme

Jobs Veeam en échec depuis plusieurs semaines sur environnement VMware ESXi.
Erreur : `Failed to retrieve object hierarchy` — impossible de créer les tâches de traitement des VMs.
Les services Veeam sont démarrés, les jobs et dépôts sont actifs — le problème est externe à Veeam.

## Cause racine confirmée

La probe RMM effectuait des checks VMware API et SSH trop fréquents pendant la fenêtre de backup.
Ces checks généraient des timeouts sur les services de gestion ESXi (`hostd` / `vpxa` / SoapAdapter),
empêchant Veeam d'inventorier l'arborescence VMware.

Signal additionnel : trafic non-SSH sur le port SSH (`invalid protocol identifier`)
→ module RMM mal configuré (type de check incorrect : HTTP/TCP envoyé sur port 22).

## Indices diagnostics

Dans les logs ESXi pendant la fenêtre backup :
- Timeouts SoapAdapter / connexions HTTP API instables
- Avertissements authentification API — sessions courtes/instables
- Connexions provenant de la probe RMM identifiables

Dans Veeam :
- Jobs actifs, services up — le problème survient à la phase d'inventaire VMware
- Corrélation temporelle : échecs surviennent exactement pendant le polling RMM

## Procédure de diagnostic (PRECHECK)

```powershell
param(
    [string[]]$JobNames  = @("MP_ESXI - Local_Daily"),
    [int]$DaysHistory    = 21,
    [string]$OutputRoot  = "$env:TEMP\VeeamDiag"
)
# Exécuter sur le serveur Veeam — collecte jobs, sessions, repos, services, logs Windows
# Renvoyer le dossier de sortie compressé pour analyse
```

Éléments à collecter :
- Schedule et historique des jobs Veeam (21 jours)
- État des dépôts et capacité
- Services Veeam + version
- Logs ESXi hostd/vpxa (si accessible) — fenêtre corrélée aux backups

## Correctif

**Côté équipe RMM / Monitoring :**
1. Identifier le module qui génère du trafic non-SSH sur le port SSH → corriger le type de check
2. Vérifier le module VMware/vSphere API : méthode auth, endpoint, fréquence de polling
3. Appliquer rate limit ou jitter sur les checks VMware **pendant la fenêtre de backup**
4. Confirmer : plus d'erreurs `invalid protocol identifier` + diminution timeouts hostd

**Côté Backup / Veeam (après correctif RMM) :**
1. Relancer manuellement le job `MP_ESXI - Local_Daily`
2. Vérifier que la phase d'inventaire VMware se déroule sans timeout
3. Surveiller 24h — si persistant : planifier fenêtre pour restart hostd/vpxa

## Escalade si persistant après correctif RMM

- Restart services de gestion ESXi (hostd/vpxa) — fenêtre maintenance requise, pas d'arrêt VMs
- Vérifier latence I/O stockage (perf ESXi) → @IT-Commandare-Infra

## Agents impliqués

| Agent | Rôle |
|---|---|
| @IT-BackupDRMaster | Diagnostic Veeam, PRECHECK, validation post-correctif |
| @IT-MonitoringMaster | Analyse probe RMM, correction checks VMware/SSH |
| @IT-Commandare-Infra | Si restart ESXi agents requis |

## Note opérationnelle

Ce type de problème ne se voit PAS dans Veeam seul.
Il faut toujours corréler les logs ESXi avec la fenêtre de backup avant de conclure.
Le PRECHECK script doit être exécuté en premier — avant toute remédiation.

---
*KB-VEEAM-001 — v1.0 — 2026-03-24*
