# RB-001 — Vérification Journalière et Triage Backup
**Agent :** IT-BackupDRMaster | **Fréquence :** Quotidienne (matin) + sur incident

---

## VEEAM — Vérification journalière

```powershell
# Connexion VBR
Connect-VBRServer -Server localhost

# Statut dernières sessions (24h)
$jobs = Get-VBRJob
foreach ($job in $jobs) {
    $s = $job.FindLastSession()
    if ($s) {
        [pscustomobject]@{
            Job    = $job.Name
            Result = $s.Result
            End    = $s.EndTime.ToString('yyyy-MM-dd HH:mm')
        }
    }
} | Format-Table -AutoSize

# Espace repositories
Get-VBRBackupRepository | Select-Object Name,
    @{N='Free_GB';E={[math]::Round($_.Info.CachedFreeSpace/1GB,1)}},
    @{N='Free_PCT';E={[math]::Round($_.Info.CachedFreeSpace/$_.Info.CachedTotalSpace*100,0)}} |
    Format-Table -AutoSize
```

**Erreurs fréquentes et actions :**

| Erreur | Cause probable | Action |
|---|---|---|
| Unable to connect | VeeamGuestHelper arrêté sur la VM | `Get-Service VeeamGuestHelper \| Start-Service` sur la VM |
| Snapshot not found | Snapshot orphelin dans vSphere/Hyper-V | Supprimer les snapshots orphelins |
| Insufficient space | Repository plein | Purger les restore points anciens |
| Access denied | Compte service VEEAM | Vérifier credentials → Passportal |
| VSS snapshot failed | VSS writer KO sur la VM | `vssadmin list writers` → redémarrer le writer |
| Network error | Connectivité port 445/6160 | `Test-NetConnection [VM] -Port 445` |

---

## DATTO BCDR — Vérification journalière

1. Partner Portal → Devices → [Appareil] → Backups
2. ✅ Screenshot présent pour chaque VM critique → backup bootable
3. Stockage local > 20% libre
4. Synchronisation cloud OK (pas d'erreur > 24h)

**Agent Datto arrêté sur machine protégée :**
```powershell
Get-Service | Where-Object {$_.Name -match "Datto|Backup Agent"} |
    Select-Object Name, Status | Format-Table
# Si arrêté :
Get-Service | Where-Object {$_.Name -match "Datto"} | Start-Service
```

---

## KEEPIT — Vérification mensuelle

1. app.keepit.com → Connectors → [Client] → Microsoft 365
2. Status = **Connected** ✅ | **Disconnected** ❌ → Reconnecter immédiatement
3. Dernière sync Exchange < 24h ✅
4. Dernière sync SharePoint/OneDrive < 24h ✅
5. Nb utilisateurs protégés = nb utilisateurs actifs M365

**Reconnexion Keepit :**
- Cliquer Reconnect → compte Global Admin M365 du tenant
- Autoriser permissions OAuth → vérifier reconnexion (5 min)
- ⚠️ Déconnexion > 24h = données M365 non sauvegardées → alerter client

---

## SEUILS D'ALERTE

| Indicateur | Attention | Critique | Action |
|---|---|---|---|
| Repository libre | < 20% | < 10% | Purge / escalade IT-Commandare-Infra |
| Job en échec | 1 jour | 2 jours consécutifs | Triage / escalade |
| Screenshot Datto | Absent 1 VM | Absent VM critique | Escalade IT-Commandare-Infra |
| Keepit sync | > 12h | > 24h | Reconnecter / escalade IT-CloudMaster |
