# BUNDLE_KP_BackupDRMaster_V2
**Agent :** @IT-BackupDRMaster
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** Veeam, Datto BCDR, KeepIT, Azure Backup, Acronis, script vérification multi-agents, rapport backup mensuel, test DR complet, communication client DR, post-mortem failure, escalades.

---

## SECTION 1 — VEEAM BACKUP (hérité V1 + enrichi)

### Vérification journalière Veeam
```
CHECKLIST MATINALE VEEAM :
[ ] VBR Console → Home → Last 24 Hours
[ ] 0 job en "Failed" → action immédiate si échec
[ ] Jobs "Warning" → lire le détail, documenter
[ ] Vérifier dernier job de chaque VM critique
[ ] Vérifier espace repository (< 20% libre → alerte)
[ ] Vérifier jobs de copy/tape si configurés
```

### Erreurs courantes Veeam et résolutions
```
"Unable to connect to guest agent"
→ Vérifier service VeeamGuestHelper sur la VM cible
→ Vérifier connectivité port 445 et 6160 entre backup et VM cible
→ Test-NetConnection [IP_VM] -Port 6160

"Snapshot not found / snapshot error"
→ vSphere/Hyper-V Manager → vérifier snapshots orphelins sur la VM
→ Supprimer les snapshots orphelins depuis l'hyperviseur
→ Relancer le job manuellement après nettoyage

"Insufficient space on repository"
→ Vérifier espace disque du repository : Get-PSDrive ou explorer distant
→ Purger les restore points selon politique de rétention
→ VBR → Backup Infrastructure → Repositories → Edit → Storage → Scale-out

"Access denied"
→ Vérifier compte service Veeam dans les droits locaux de la VM
→ VBR → Manage Credentials → tester le compte

"VSS snapshot failed"
→ Sur la VM cible : vssadmin list writers
→ Redémarrer les services VSS en erreur
→ vssadmin delete shadows /all /quiet si snapshots VSS corrompus

"Network error / transport timeout"
→ Test-NetConnection [IP_VM] -Port 445
→ Vérifier MTU réseau (ping -f -l 1400 [IP_VM])
→ Vérifier règles firewall entre proxy Veeam et VM
```

### Restauration fichiers et VMs
```
RESTAURATION FICHIER (Veeam) :
1. VBR → Backups → [NOM_VM] → clic droit → Restore guest files → Windows
2. Sélectionner point de restauration (vérifier la date avec le client)
3. Naviguer dans le système de fichiers → sélectionner fichier(s)
4. Copy to → emplacement alternatif (JAMAIS directement en production sans confirmation)
5. Documenter : fichier restauré, point de restauration utilisé, emplacement livraison

RESTAURATION VM COMPLÈTE :
⚠️ APPROBATION SUPERVISEUR REQUISE AVANT TOUTE RESTAURATION VM COMPLÈTE
1. VBR → Backups → [NOM_VM] → Restore entire VM
2. Sélectionner "Restore to new location" (pour test ou si original inaccessible)
3. Sélectionner l'hôte, le datastore/volume de destination
4. Vérifier la configuration réseau (renommer VM si en parallèle de l'original)
5. Tester la VM restaurée AVANT de couper l'original

TEST D'INTÉGRITÉ (SureBackup) :
VBR → Jobs → SureBackup → New ou Run existing
→ Vérifier que les VMs bootent et que les services critiques démarrent
→ Générer rapport → archiver dans billet CW mensuel
```

```powershell
# PowerShell Veeam — jobs des dernières 24h
Add-PSSnapin VeeamPSSnapIn -ErrorAction SilentlyContinue
Get-VBRJob | ForEach-Object {
    $lastSession = Get-VBRBackupSession -Job $_ | Sort-Object EndTime -Descending | Select-Object -First 1
    [PSCustomObject]@{
        Job = $_.Name
        Status = $lastSession.Result
        StartTime = $lastSession.CreationTime
        EndTime = $lastSession.EndTime
        Duration = $lastSession.EndTime - $lastSession.CreationTime
    }
} | Format-Table -AutoSize

# Repository utilisé
Get-VBRBackupRepository | Select-Object Name, @{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB,1)}}, @{N='TotalGB';E={[math]::Round($_.Capacity/1GB,1)}}
```

---

## SECTION 2 — DATTO BCDR (hérité V1 + enrichi)

### Vérification journalière Datto
```
NAVIGATION : portal.datto.com → Devices → [NOM_CLIENT]

POINTS À VÉRIFIER :
[ ] Local backup status → dernières 24h → tous verts
[ ] Offsite sync → dernier succès < 24h
[ ] Screenshot verification → dernière VM bootée avec succès
[ ] Espace disque appliance Datto (< 20% libre → alerte)
[ ] Agent status sur chaque serveur protégé → tous "Active"

CODES STATUT DATTO :
✅ Backup success → normal
⚠️ Backup warning → vérifier les détails (VSS souvent)
❌ Backup failed → intervention requise
🔄 Backup running → en cours (normal si dans fenêtre de backup)
```

### Instant Virtualization Datto
```
ACTIVATION INSTANT VIRTUALIZATION :
1. portal.datto.com → Device → [NOM_APPLIANCE]
2. Advanced Restore → Virtualize
3. Sélectionner le serveur et le point de restauration
4. "Virtualize" → la VM démarre localement sur l'appliance Datto

⚠️ AVANT D'ACTIVER :
- Confirmer avec le client l'impact réseau (DHCP, IP)
- Vérifier que les dépendances (AD, DNS) sont disponibles
- Documenter l'heure de démarrage dans CW

DURÉE SUPPORTÉE : Typically 72h max sur appliance locale
→ Si DR prolongé → envisager migration vers environnement de production

DÉSACTIVER LA VM VIRTUALISÉE :
→ Même menu → Stop Virtualization
→ S'assurer que le serveur physique est de retour AVANT d'arrêter la VM Datto
```

---

## SECTION 3 — KEEPIT M365 BACKUP (hérité V1 + enrichi)

### Vérification mensuelle KeepIT
```
NAVIGATION : app.keepit.com

CHECKLIST MENSUELLE :
[ ] Exchange Online → tous mailboxes → 0 erreur
[ ] SharePoint Online → tous sites → 0 erreur
[ ] OneDrive → tous utilisateurs actifs → 0 erreur
[ ] Teams → conversations + fichiers → 0 erreur
[ ] Token d'accès → valide (pas d'alerte d'expiration)
[ ] Rapport téléchargé et archivé dans billet CW mensuel

ALERTES CRITIQUES KEEPIT :
- "Authentication failed" → token M365 expiré → renouveler dans Settings
- "Quota exceeded" → espace KeepIT insuffisant → contacter KeepIT ou purger
- "User not found" → compte M365 supprimé → vérifier si suppression intentionnelle
```

### Restauration KeepIT
```
RESTAURATION EMAIL :
1. app.keepit.com → Restore → Exchange Online
2. Sélectionner le mailbox → Point de restauration
3. Naviguer → sélectionner email(s) ou dossier(s)
4. Restore to original ou Restore to alternate mailbox
⚠️ Confirmer avec client : "Restaurer écrasera les emails actuels si même dossier"

RESTAURATION SHAREPOINT/ONEDRIVE :
1. app.keepit.com → Restore → SharePoint Online ou OneDrive
2. Sélectionner site ou utilisateur → Point de restauration
3. Sélectionner fichiers ou dossiers
4. Restore to original (⚠️ écrase version actuelle) ou Download

RESTAURATION TEAMS :
1. app.keepit.com → Restore → Teams
2. Sélectionner l'équipe → Point de restauration
3. Messages ou fichiers → Export (format JSON/CSV pour messages)
```

---

## SECTION 4 — AZURE BACKUP

### Configuration et vérification Azure Backup
```powershell
# Connexion Azure
Connect-AzAccount

# Lister vaults Recovery Services
Get-AzRecoveryServicesVault | Select-Object Name, ResourceGroupName, Location

# Vérifier jobs de backup (24 dernières heures)
$vault = Get-AzRecoveryServicesVault -Name "[NOM_VAULT]" -ResourceGroupName "[NOM_RG]"
Set-AzRecoveryServicesVaultContext -Vault $vault
Get-AzRecoveryServicesBackupJob -Status Failed -From (Get-Date).AddHours(-24) | Select-Object JobId, WorkloadName, Status, StartTime, EndTime

# Tous les jobs du jour
Get-AzRecoveryServicesBackupJob -From (Get-Date).Date | Select-Object JobId, WorkloadName, Status, StartTime | Format-Table
```

### Restauration Azure Backup
```powershell
# Restauration VM Azure depuis Recovery Services Vault
# 1. Trouver le vault et la VM
$vault = Get-AzRecoveryServicesVault -Name "[NOM_VAULT]" -ResourceGroupName "[NOM_RG]"
Set-AzRecoveryServicesVaultContext -Vault $vault

# 2. Trouver les points de restauration
$namedContainer = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName "[NOM_VM]"
$backupItem = Get-AzRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
$rp = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupItem | Sort-Object RecoveryPointTime -Descending | Select-Object -First 5

# 3. Restaurer vers nouvelle VM (recommandé pour test)
$restoreJob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $rp[0] `
    -StorageAccountName "[STORAGE_ACCOUNT]" `
    -StorageAccountResourceGroupName "[NOM_RG]"

Write-Host "Job restauration : $($restoreJob.JobId)"
```

### Politiques de backup Azure
```
NIVEAUX DE RÉTENTION RECOMMANDÉS MSP :
- Daily backups : 30 jours
- Weekly backups : 12 semaines
- Monthly backups : 12 mois
- Yearly backups : 3 ans (si requis par conformité)

SEUILS D'ALERTE AZURE BACKUP :
- Job échoué 1 fois → warning dans CW
- Job échoué 2 fois consécutives → alerte client + investigation
- RPO dépassé → escalade immédiate
```

---

## SECTION 5 — ACRONIS

### Opérations courantes Acronis
```
NAVIGATION : cloud.acronis.com (Acronis Cyber Cloud)
ou console locale si on-premise

VÉRIFICATION JOURNALIÈRE :
[ ] Dashboard → Activity → Failed activities (dernières 24h)
[ ] Vérifier backup schedule pour chaque plan actif
[ ] Vérifier quota stockage (< 20% libre → alerte)

CRÉER UN PLAN DE BACKUP :
Plans → Create plan → sélectionner machines
→ What to back up : Entire machine / Disks & volumes / Files
→ Where to store : Cloud / Local / NAS
→ Schedule : Daily (minimum) + Weekly full
→ Retention : 30 jours minimum

RESTAURATION ACRONIS :
1. Sélectionner la machine → Recovery
2. Choisir point de restauration
3. Entire machine (⚠️ approbation requise) ou Files/Folders
4. Pour test → restore vers nouvelle VM ou emplacement alternatif

ERREURS COURANTES :
"Backup agent offline" → vérifier service Acronis Agent sur la machine
"Quota exceeded" → purger backups anciens ou augmenter quota
"VSS error" → même résolution que Veeam (vssadmin list writers)
```

---

## SECTION 6 — SCRIPT VÉRIFICATION AUTOMATIQUE MULTI-AGENTS

```powershell
# ===== VÉRIFICATION BACKUP MULTI-SOLUTIONS =====
# À exécuter chaque matin depuis le serveur de gestion

param(
    [string]$ClientName = "[NOM_CLIENT]",
    [string]$ReportPath = "C:\Reports\BackupCheck_$(Get-Date -Format 'yyyy-MM-dd').txt"
)

$Report = @()
$Report += "RAPPORT BACKUP QUOTIDIEN — $ClientName — $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$Report += "=" * 60

# VEEAM CHECK
try {
    Add-PSSnapin VeeamPSSnapIn -ErrorAction SilentlyContinue
    $VeeamJobs = Get-VBRJob | ForEach-Object {
        $s = Get-VBRBackupSession -Job $_ | Sort-Object EndTime -Descending | Select-Object -First 1
        [PSCustomObject]@{ Job=$_.Name; Status=$s.Result; Time=$s.EndTime }
    }
    $Report += "`nVEEAM BACKUP :"
    foreach ($j in $VeeamJobs) {
        $icon = if ($j.Status -eq "Success") { "✅" } elseif ($j.Status -eq "Warning") { "⚠️" } else { "❌" }
        $Report += "  $icon $($j.Job) — $($j.Status) — $($j.Time)"
    }
    $FailedVeeam = $VeeamJobs | Where-Object { $_.Status -eq "Failed" }
    if ($FailedVeeam) { $Report += "  🚨 INTERVENTION REQUISE : $($FailedVeeam.Count) job(s) en échec" }
} catch { $Report += "`nVEEAM : Module non disponible sur ce serveur" }

# AZURE BACKUP CHECK
try {
    $vault = Get-AzRecoveryServicesVault -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($vault) {
        Set-AzRecoveryServicesVaultContext -Vault $vault
        $AzJobs = Get-AzRecoveryServicesBackupJob -From (Get-Date).AddHours(-24) -Status Failed
        $Report += "`nAZURE BACKUP :"
        if ($AzJobs) {
            $Report += "  ❌ $($AzJobs.Count) job(s) Azure en échec"
        } else {
            $Report += "  ✅ Aucun échec dans les dernières 24h"
        }
    }
} catch { $Report += "`nAZURE BACKUP : Non configuré ou non connecté" }

# RÉSUMÉ
$Report += "`n" + "=" * 60
$Report += "Rapport généré par : $env:USERNAME | $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# Sauvegarder et afficher
$Report | Out-File $ReportPath -Encoding UTF8
$Report | ForEach-Object { Write-Host $_ }
Write-Host "`nRapport sauvegardé : $ReportPath" -ForegroundColor Green
```

---

## SECTION 7 — RAPPORT BACKUP MENSUEL (template CW)

```
RAPPORT BACKUP MENSUEL — [CLIENT] — [MOIS ANNÉE]
Billet CW : #[XXXXXX]

Prise en connaissance de la demande et consultation de la documentation du client.

## RÉSUMÉ MENSUEL
Période : [YYYY-MM-01] au [YYYY-MM-31]
Solutions actives : [Veeam / Datto / KeepIT / Azure Backup / Acronis]

## STATISTIQUES VEEAM
Jobs exécutés : [X]
Succès : [X] ([Y]%)
Avertissements : [X]
Échecs : [X]
Temps moyen : [HH:MM]
Restaurations effectuées : [X] (si applicable)

## STATISTIQUES M365 (KeepIT)
Mailboxes protégés : [X]
Succès : [X] ([Y]%)
Erreurs : [X]
Restaurations effectuées : [X] (si applicable)

## INCIDENTS DU MOIS
[Date] — [Description] — [Résolution]
[Aucun incident / liste des incidents]

## STOCKAGE
Repository Veeam : [X]GB utilisé / [Y]GB total ([Z]% utilisé)
KeepIT M365 : [X]GB utilisé
Azure Backup : [X]GB utilisé

## RESTAURATIONS EFFECTUÉES CE MOIS
[Liste des restaurations — Date, Type, Résultat]
ou "Aucune restauration ce mois"

## RECOMMANDATIONS
[ ] [Recommandation 1 — ex: augmenter rétention, ajouter VM au backup]
[ ] [Recommandation 2]

## TEST DR
Dernier test SureBackup/DR : [Date] — [Résultat]
Prochain test planifié : [Date]

Technicien : [NOM] | Durée review : [HH:MM]
```

---

## SECTION 8 — PROCÉDURE TEST DR COMPLET

### Étapes test DR mensuel
```
PRÉPARATION TEST DR (J-3) :
[ ] Notifier le client — "Test DR planifié le [Date] — aucun impact en production"
[ ] Confirmer la fenêtre de maintenance
[ ] Identifier les VMs et services à tester (top 3 priorité)
[ ] Vérifier que les backups sont à jour (< 24h)
[ ] Préparer environnement de test isolé (VLAN de test ou lab)

EXÉCUTION TEST DR :
[ ] Documenter l'heure de début
[ ] Veeam SureBackup / Datto Instant Virtualization → démarrer VM de test
[ ] Mesurer le temps de démarrage (RTO)
[ ] Valider les services critiques sur la VM restaurée :
    - Contrôleur de domaine : dcdiag /test:services
    - Serveur applicatif : tester l'application
    - Serveur de fichiers : accès aux partages
[ ] Tester la connectivité réseau (ping, accès applicatif)
[ ] Mesurer le RPO (heure du dernier backup vs heure du test)
[ ] Documenter les résultats — success/failure par service

CLÔTURE TEST DR :
[ ] Arrêter les VMs de test
[ ] Nettoyer l'environnement de test
[ ] Documenter RTO et RPO réels vs objectifs
[ ] Rapport dans CW billet mensuel
[ ] Escalade si RTO/RPO ne respectent pas les objectifs
```

### Résultats à documenter
```
TEMPLATE RÉSULTATS TEST DR :
Date du test : [YYYY-MM-DD]
Technicien : [NOM]

| Serveur | Backup utilisé | Démarrage | Services OK | RTO réel | RPO réel |
|---|---|---|---|---|---|
| [NOM_VM_1] | [Date backup] | [HH:MM] | ✅/❌ | [min] | [h] |
| [NOM_VM_2] | [Date backup] | [HH:MM] | ✅/❌ | [min] | [h] |

Objectifs SLA client :
RTO cible : [X]h | RTO réel : [X]h → ✅/❌
RPO cible : [X]h | RPO réel : [X]h → ✅/❌

Problèmes identifiés :
- [Problème 1 — plan de correction]
- [Problème 2 — plan de correction]
```

---

## SECTION 9 — PLAN DE RELÈVE / ACTIVATION DR (hérité V1 + enrichi)

### Déclenchement DR
```
CRITÈRES DE DÉCLENCHEMENT DR :
- Serveur physique inaccessible > [SEUIL_CLIENT]h (selon SLA)
- Sinistre physique (incendie, inondation, vol)
- Ransomware avec serveurs chiffrés non récupérables
- Hyperviseur défaillant sans redémarrage possible

PROCESSUS DE DÉCISION GO/NO-GO :
1. IT-UrgenceMaster évalue la situation
2. Chef d'équipe approuve l'activation DR
3. Client informé et donne son accord
4. Activation DR documentée dans CW avec timestamp
```

### Ordre de démarrage serveurs critiques
```
ORDRE DE DÉMARRAGE LORS D'UN DR (générique — adapter selon Hudu client) :
1. Contrôleur de domaine principal (DC1) — attendre 5 min
2. Contrôleur de domaine secondaire (DC2) si applicable
3. Serveur DNS (si séparé)
4. Serveur DHCP (si séparé)
5. Serveur de fichiers (après AD disponible)
6. Serveurs applicatifs dans l'ordre de dépendance
7. Serveurs de backup/surveillance

VÉRIFICATION ENTRE CHAQUE DÉMARRAGE :
- ping [NOM_SERVEUR] → doit répondre
- Test-NetConnection [NOM_SERVEUR] -Port [PORT_CRITIQUE]
- Get-Service -ComputerName [NOM_SERVEUR] | Where-Object { $_.Status -eq "Stopped" -and $_.StartType -eq "Automatic" }
```

---

## SECTION 10 — COMMUNICATION CLIENT LORS ACTIVATION DR

### Email activation DR
```
Objet : [URGENT] Activation plan de continuité — [SERVICE/SITE] — Réf. #[XXXXXX]

Bonjour [NOM CONTACT CLIENT],

Nous vous informons qu'en raison de [description générale de l'incident — sans détails techniques], nous avons activé votre plan de continuité des opérations.

ÉTAT ACTUEL
Systèmes affectés : [description fonctionnelle]
Environnement de continuité : Actif depuis [HH:MM]
Services disponibles : [liste]
Services temporairement indisponibles : [liste si applicable]

PROCHAIN POINT DE CONTACT
Notre équipe vous contactera à [HH:MM] avec une mise à jour.

CONTACT D'URGENCE
[Nom du technicien responsable] — [Téléphone direct]

Nous travaillons activement à rétablir l'environnement principal.

Cordialement,
[Nom] — Support technique
```

### Notice Teams — Activation DR
```
🔴 PLAN DE CONTINUITÉ ACTIVÉ — [CLIENT]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client  : [NOM CLIENT]
Billet  : #[XXXXXX]
Statut  : 🔴 DR ACTIF depuis [HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Situation : [Description fonctionnelle]
Environnement de continuité : ✅ Opérationnel
Services actifs : [Liste]
Impact résiduel : [Description]

Prochain point : [HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Chef d'équipe] @[Tech] | [Date HH:MM]
```

---

## SECTION 11 — POST-MORTEM BACKUP FAILURE

```
POST-MORTEM BACKUP FAILURE — [CLIENT]
════════════════════════════════════════
Date : [YYYY-MM-DD] | Billet : #[XXXXXX]

RÉSUMÉ
[2-3 lignes : quel backup a échoué, depuis quand, impact]

CHRONOLOGIE
- [Date HH:MM] Premier échec détecté
- [Date HH:MM] Alerte générée (automatique / manuelle)
- [Date HH:MM] Prise en charge par [NOM]
- [Date HH:MM] Investigation / actions
- [Date HH:MM] Backup repris avec succès

CAUSE RACINE
[Cause technique identifiée]

FACTEURS CONTRIBUTEURS
- [Facteur 1]
- [Facteur 2]

DONNÉES À RISQUE PENDANT LA PANNE
RPO dégradé : [durée sans backup valide]
Données potentiellement non sauvegardées : [description]

ACTIONS CORRECTIVES
[ ] [Action 1 — responsable — échéance]
[ ] [Action 2 — responsable — échéance]

ACTIONS PRÉVENTIVES
[ ] [Prévention 1]
[ ] [Prévention 2]
════════════════════════════════════════
```

---

## SECTION 12 — SEUILS D'ALERTE BACKUP

| Situation | Avertissement | Critique | Action |
|---|---|---|---|
| Job Veeam en échec | 1 jour | 2 jours consécutifs | Escalade + correction urgente |
| Repository espace libre | < 20% | < 10% | Purge / extension |
| Datto offsite sync | > 24h | > 48h | Vérifier connectivité WAN |
| KeepIT erreurs mailboxes | > 2% | > 5% | Renouveler token |
| Azure Backup échec | 1 jour | 2 jours | Investigation vault |
| Test DR non effectué | > 30 jours | > 60 jours | Planifier test immédiatement |
| RPO réel vs cible | > 110% cible | > 150% cible | Escalade chef d'équipe |

---

## SECTION 13 — CHECKLIST DR READINESS MENSUELLE (hérité V1)

```
CHECKLIST DR READINESS MENSUELLE :
[ ] Veeam : tous jobs en succès ou warning géré
[ ] Veeam : SureBackup exécuté et succès
[ ] Veeam : espace repository > 20% libre
[ ] Datto : screenshot verification OK pour toutes VMs
[ ] Datto : offsite sync < 24h
[ ] KeepIT : rapport mensuel généré et archivé
[ ] Azure Backup : jobs OK + politique de rétention vérifiée
[ ] Documentation Hudu à jour : DR plan, RTO/RPO, contacts
[ ] Test DR réel ou simulé effectué dans le mois
[ ] Rapport mensuel envoyé au client
[ ] Actions correctives du mois précédent — statut
```

---

## SECTION 14 — ESCALADES

| Situation | Destination | Délai |
|---|---|---|
| Backup critique échoué > 2 jours | Chef d'équipe + Client | Dans l'heure |
| Ransomware — activation DR requise | IT-UrgenceMaster + IT-SecurityMaster | Immédiat |
| Repository plein — backup impossible | IT-SysAdmin + Chef d'équipe | Dans l'heure |
| Test DR échoué (RTO/RPO non respectés) | Chef d'équipe + Client | Dans la journée |
| Perte de données confirmée | Management + Juridique + Client | Immédiat |
| Datto appliance défaillante | Datto Support + Chef d'équipe | Dans l'heure |
| Azure Vault corrompu | Microsoft Support + Chef d'équipe | Dans l'heure |
| KeepIT token expiré > 48h | IT-CloudMaster | Dans les 4h |

---

*BUNDLE_KP_BackupDRMaster_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
