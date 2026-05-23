# BUNDLE_KP_BackupDRMaster_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** IT-BackupDRMaster
**Usage :** Uploader en Knowledge dans le GPT IT-BackupDRMaster
**Contenu :** Runbooks Veeam + Datto + Keepit + DR Plan + Checklists
**Mis à jour :** 2026-03-20

---

## VEEAM — VÉRIFICATION JOURNALIÈRE

```
VBR Console → Home → Last 24 Hours
✅ Success → OK | ⚠️ Warning → lire détail | ❌ Failed → intervention immédiate

ERREURS ET ACTIONS
"Unable to connect"    → Service VeeamGuestHelper sur la VM → Get-Service | Where {$_.Name -match "VeeamGuest"}
"Snapshot not found"   → vSphere → supprimer snapshots orphelins
"Insufficient space"   → Repository → purge restore points anciens
"Access denied"        → Droits compte service → vérifier dans CMDB Passportal
"VSS snapshot failed"  → vssadmin list writers → redémarrer le writer en échec
"Network error"        → Test-NetConnection -ComputerName [VM] -Port 445

VÉRIFIER ESPACE REPOSITORY
Get-VBRBackupRepository | Select-Object Name,
    @{N='Free_GB';E={[math]::Round($_.Info.CachedFreeSpace/1GB,1)}},
    @{N='Free%';E={[math]::Round($_.Info.CachedFreeSpace/$_.Info.CachedTotalSpace*100,0)}}
⚠️ Seuil alerte : < 20% | Seuil critique : < 10%
```

---

## VEEAM — RESTAURATION

### Restauration fichiers
```
VBR → Backups → VM → Restore guest files → Windows
→ Point de restauration → Naviguer → Copy to (emplacement alternatif OBLIGATOIRE)
⛔ NE PAS Restore to original location sans confirmation explicite client
⛔ Garder la session ouverte jusqu'à validation par l'utilisateur
```

### Restauration VM complète
```
⚠️ CRITIQUE — Approbation superviseur + client requise PAR ÉCRIT

VBR → Backups → VM → Restore entire VM
→ Restore to new location (pour test avant mise en production)
→ Décocher "Connected to network" pendant la validation
→ Valider : RDP accessible + services OK + données intègres
→ Puis : Restore to original location OU Failback si satisfait
⛔ NE PAS supprimer l'ancienne VM avant validation complète de la restaurée
```

### Test d'intégrité (mensuel)
```
VBR → Backups → VM → Instant Recovery
→ VM démarre depuis le backup → tester RDP → Stop publishing
⚠️ Max 30 min en mode Instant Recovery — les écritures ne sont pas persistantes
```

---

## DATTO BCDR — VÉRIFICATION JOURNALIÈRE

```
Partner Portal → Devices → [Appareil] → Backups
✅ Success | ⚠️ Warning | ❌ Failed

POINTS CRITIQUES À VÉRIFIER
→ Screenshot présent pour VMs critiques (= backup bootable)
→ Stockage local > 20% libre
→ Synchronisation cloud : pas d'erreur > 24h
→ Rétention conforme à la politique client (voir Hudu → Agreements)

AGENT EN ÉCHEC — REDÉMARRER LE SERVICE
Get-Service | Where-Object {$_.Name -match "Datto|Backup Agent"} | Restart-Service

INSTANT VIRTUALIZATION (machine HS en urgence)
Partner Portal → Devices → [Appareil] → Restore → Virtualize
→ Choisir point de restauration → Local Virtualize
⚠️ Solution temporaire max 72h — planifier la restauration définitive immédiatement
⚠️ Informer le client sur les limitations de performance
```

---

## KEEPIT — VÉRIFICATION MENSUELLE

```
app.keepit.com → Connectors → [Client] → Microsoft 365
→ Status : Connected ✅ | Disconnected ❌ → Reconnecter immédiatement

SI DÉCONNECTÉ
→ Cliquer Reconnect → se connecter avec compte Global Admin M365 du tenant
→ Autoriser les permissions OAuth → vérifier reconnexion (5 min)
⚠️ Déconnexion > 24h = données non sauvegardées depuis ce délai

RESTAURATION EXCHANGE (emails perdus)
Portail Keepit → Search → [Client] → Chercher par utilisateur/sujet/date
→ Sélectionner → Restore to original mailbox
OU Export to PST pour récupération manuelle
```

---

## PLAN DE RELÈVE — DÉCLENCHEMENT

```
AVANT D'ACTIVER
[ ] Confirmer l'étendue du sinistre (quels systèmes, durée estimée)
[ ] Approbation du responsable client obtenue PAR ÉCRIT
[ ] Dernier backup disponible et validé (Datto/Veeam) → noter la date/heure du snapshot
[ ] Ouvrir billet P1 dans CW : "DR ACTIVÉ — Client [NOM]"
[ ] NOC informé : monitoring renforcé

ORDRE DE DÉMARRAGE OBLIGATOIRE
1. Réseau + Firewall + VPN
2. Domain Controller(s)
3. DNS + DHCP
4. Serveur de fichiers
5. SQL / Applications
6. RDS / Accès distant
7. Monitoring + Backup
⛔ NE JAMAIS déroger à cet ordre

RTO / RPO
→ Objectifs dans Hudu → [Client] → Agreements → Plan de relève
```

---

## CHECKLIST DR READINESS (vérification mensuelle)

```
DATTO
[ ] Tous les agents : dernière session Success ou Warning acceptable
[ ] Screenshot présent pour VMs critiques
[ ] Stockage local > 20% libre
[ ] Sync cloud OK (pas d'erreur > 24h)

VEEAM
[ ] Jobs production : Success ou Warning
[ ] Repository > 20% libre
[ ] Test intégrité < 30 jours

KEEPIT
[ ] Connecteur Connected
[ ] Dernière sync Exchange + SharePoint OK
[ ] Nb utilisateurs protégés = nb utilisateurs actifs M365

PLAN DR
[ ] Document à jour dans Hudu (< 6 mois)
[ ] Contacts d'urgence à jour
[ ] Test complet DR < 12 mois

RÉSULTAT : ✅ DR READY | ⚠️ Actions requises | ❌ Escalade immédiate
```

---

## ESCALADES

| Situation | Département | Délai |
|---|---|---|
| VM critique en échec 2 jours consécutifs | IT-Commandare-NOC | Dans l'heure |
| Repository < 10% libre | IT-Commandare-Infra | Dans l'heure |
| Restauration VM complète requise | Superviseur + client | Immédiat |
| Keepit déconnecté > 24h | IT-CloudMaster | Dans l'heure |
| RTO dépassé (restauration trop longue) | Superviseur | Immédiat |
