# BUNDLE RUNBOOK BACKUP Datto-Keepit-DR V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-BackupDRMaster, IT-CloudMaster | IT-MaintenanceMaster | IT-SysAdmin
**Description :** Datto BCDR + Keepit M365 + Plan de Relève — Opérations et DR
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__Datto_Operations_V1 -->
## RUNBOOK — Datto BCDR et RMM

# RUNBOOK — Datto : Backup (BCDR) & RMM Operations
**ID :** RUNBOOK__Datto_Operations_V1
**Version :** 1.0 | **Agents :** IT-BackupDRMaster, IT-Assistant-N3, IT-MonitoringMaster
**Domaine :** INFRA — Backup & RMM
**Mis à jour :** 2026-03-20

---

# PARTIE 1 — DATTO BCDR (SIRIS / ALTO)

## 1.1 ACCÈS CONSOLE DATTO BACKUP

| Méthode | Accès |
|---|---|
| **Partner Portal** | https://partners.datto.com |
| **Interface locale appareil** | https://[IP_DATTO] (réseau local) |
| **Datto RMM (si intégré)** | Via le portail RMM |

---

## 1.2 VÉRIFICATION JOURNALIÈRE DES BACKUPS

```
Partner Portal → Devices → [Appareil Datto] → Backups

Vérifier pour chaque agent :
✅ Success (vert) → OK
⚠️ Warning → Lire le détail — souvent tolérable (fichiers locked)
❌ Failed → Intervention requise

Points de vérification :
→ Dernier backup réussi (date/heure)
→ Backup local OK + Backup cloud OK
→ Vérification screenshot (Datto prend un screenshot de la VM bootée)
   ✅ Screenshot présent = backup bootable
   ❌ Screenshot absent ou écran noir = problème d'intégrité
```

---

## 1.3 BACKUPS EN ÉCHEC — CODES D'ERREUR COURANTS

| Erreur | Cause probable | Action |
|---|---|---|
| `VSS Error` | VSS defaillant sur la machine | Vérifier VSS sur la machine cible |
| `Snapshot failed` | Driver Datto ou conflit snapshot | Vérifier le driver Datto Agent |
| `Network timeout` | Connectivité vers l'appareil Datto | Vérifier réseau entre Datto et la machine |
| `Agent not responding` | Service Datto Agent arrêté | Redémarrer le service Datto Backup Agent |
| `Insufficient space` | Disque Datto plein | Vérifier espace local + cloud |
| `Backup queue full` | Trop de backups en attente | Forcer un backup complet |

### Redémarrer le service Datto Agent
```powershell
# Sur la machine protégée par Datto
Get-Service -Name "Backup Agent Service" | Restart-Service -Force
# OU selon la version :
Get-Service | Where-Object {$_.Name -match "Datto\|Backup Agent"} | Restart-Service
```

---

## 1.4 RESTAURATION DATTO

### Restauration de fichiers/dossiers
```
1. Partner Portal → Devices → [Appareil Datto] → Restore
2. Sélectionner l'agent (machine source)
3. Sélectionner le point de restauration (date/heure)
4. Choisir : File Restore
5. Naviguer → sélectionner les fichiers → Restore
6. Options : restaurer sur la machine d'origine OU télécharger localement
```

### Virtualization locale (Datto Instant Virtualization)
```
⚠️ Utiliser si la machine physique est HS — démarrer la VM depuis le backup

1. Partner Portal → Devices → [Appareil Datto] → Restore → Virtualize
2. Sélectionner le point de restauration
3. "Local Virtualize" → la VM démarre sur l'appliance Datto locale
4. Connexion via lien fourni dans le portail

⚠️ Performance réduite vs la machine physique
⚠️ Durée maximale recommandée : 72h (solution temporaire)
⚠️ NE PAS modifier des données critiques en mode virtualization sans plan de restauration définitive
```

### Bare Metal Restore (BMR)
```
Pour restauration sur nouveau hardware :
1. Partner Portal → Devices → [Appareil Datto] → Restore → Bare Metal Restore
2. Télécharger l'ISO de restauration Datto
3. Booter le nouveau serveur depuis l'ISO
4. Suivre l'assistant de restauration

⚠️ Durée selon la taille : compter 2-8h pour un serveur standard
⚠️ Valider les licences Windows après la restauration
```

---

## 1.5 VÉRIFICATION STOCKAGE ET RÉTENTION

```
Partner Portal → Devices → [Appareil Datto] → Storage
→ Espace local utilisé / disponible
→ Espace cloud utilisé

⚠️ Alerter si local > 80% utilisé
Action : Partner Portal → Settings → Retention Settings → ajuster la rétention
OU : contacter Datto pour extension de stockage cloud
```

---

# PARTIE 2 — DATTO RMM

## 2.1 ACCÈS DATTO RMM

| Accès | URL |
|---|---|
| **Portail Datto RMM** | https://[votre-domaine].centrastage.net |
| **Desktop Agent** | Application locale sur les postes |

---

## 2.2 HEALTH CHECK DATTO RMM

```
Dashboard → Devices
→ Devices Online / Offline
→ Alertes actives (rouge/orange)

Sites → [Client] → Devices
→ Statut par appareil : Online, Offline, Maintenance

Alerts → Active Alerts
→ Trier par priorité et type
→ Acknowledge les alertes traitées
```

---

## 2.3 SCRIPTS ET AUTOMATISATION DATTO RMM

```
Jobs → Create Job
→ Sélectionner les cibles (1 device, site, ou groupe)
→ Choisir le composant (script PS, batch, package)
→ Planifier ou exécuter maintenant

Bibliothèque de composants :
ComStore → rechercher par catégorie
→ Patch Management, Software Install, Cleanup, Monitoring
```

---

## 2.4 MODE MAINTENANCE (SUPPRESSION ALERTES PENDANT MAINTENANCE)

```
⚠️ TOUJOURS activer le mode maintenance avant une intervention planifiée

Device → [Appareil] → Maintenance → Enable Maintenance Mode
→ Durée : en minutes
→ Les alertes sont suspendues pendant la durée définie

Après l'intervention :
Device → [Appareil] → Maintenance → Disable Maintenance Mode

⛔ NE JAMAIS oublier de désactiver le mode maintenance après intervention
   Les alertes réelles seraient ignorées
```

---

## 2.5 ALERTES DATTO RMM — TYPES ET ACTIONS

| Type d'alerte | Action standard |
|---|---|
| Offline Device | Vérifier alimentation, réseau, puis escalader |
| Disk Usage > 90% | Nettoyage immédiat → escalade INFRA |
| High CPU / Memory | Investiguer processus → escalade si persistant |
| Patch Status Failed | Vérifier WSUS / Windows Update |
| Backup Failed | Vérifier Datto BCDR / Veeam |
| Security Alert (AV/EDR) | Escalade SOC immédiate |
| Service Down | Redémarrer le service → escalade si récurrent |

---

## 3. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer un point de restauration Datto manuellement
⛔ NE JAMAIS laisser le mode Virtualization actif > 72h sans plan de sortie
⛔ NE JAMAIS modifier les politiques de rétention sans approbation et impact évalué
⛔ NE PAS ignorer les erreurs de screenshot Datto — signe que le backup n'est pas bootable
⛔ NE JAMAIS oublier de désactiver le mode maintenance RMM
```

---

## 4. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Backup en échec machine critique > 24h | NOC + BackupDR | Dans l'heure |
| Appareil Datto BCDR inaccessible | NOC + BackupDR | Immédiat |
| Stockage local Datto > 90% | BackupDR + INFRA | Dans l'heure |
| Restauration en cours (machine HS) | BackupDR + INFRA | Suivi continu |


---
<!-- SOURCE: RUNBOOK__Keepit_Operations_V1 -->
## RUNBOOK — Keepit Backup M365

# RUNBOOK — Keepit : Backup Microsoft 365 & Cloud
**ID :** RUNBOOK__Keepit_Operations_V1
**Version :** 1.0 | **Agents :** IT-BackupDRMaster, IT-CloudMaster
**Domaine :** INFRA — Backup Cloud M365
**Mis à jour :** 2026-03-20

---

## 1. PRÉSENTATION KEEPIT

Keepit est une solution de **backup cloud-to-cloud** pour Microsoft 365 et autres SaaS.
Données protégées typiquement : Exchange Online, SharePoint, OneDrive, Teams, Entra ID.

**Portail :** https://app.keepit.com
**Credentials :** voir Passportal

---

## 2. VÉRIFICATION JOURNALIÈRE

```
Dashboard → Overview
→ Statut des backups par service (Exchange, SharePoint, OneDrive, Teams)
✅ Vert = backup réussi
⚠️ Orange = backup avec avertissements
❌ Rouge = backup en échec

Connectors → [Client] → [Service]
→ Dernière synchronisation
→ Nombre d'objets protégés
→ Taille totale des données sauvegardées
```

---

## 3. VÉRIFICATION CONNECTEUR MICROSOFT 365

```
Connectors → Microsoft 365 → [Tenant client]
→ Status : Connected / Disconnected / Error

Si le connecteur est déconnecté :
1. Cliquer sur le connecteur → Reconnect
2. Se connecter avec un compte admin Global Administrator du tenant M365
3. Accorder les permissions requises (OAuth)
4. Vérifier que le connecteur est vert après quelques minutes

⚠️ Si déconnexion depuis > 24h : les données ne sont plus sauvegardées
⚠️ Vérifier si le compte admin M365 utilisé par Keepit est actif et non expiré
```

---

## 4. RESTAURATION KEEPIT

### Restaurer des emails Exchange Online
```
1. Portail Keepit → Search → [Client]
2. Chercher par : utilisateur, sujet, date, expéditeur
3. Sélectionner les emails → Restore
4. Options :
   → Restore to original mailbox (restauration directe)
   → Restore to alternate mailbox
   → Export to PST
5. Suivre la progression dans : Jobs → Restore Jobs
```

### Restaurer des fichiers SharePoint / OneDrive
```
1. Portail Keepit → Sites → [Client] → SharePoint / OneDrive
2. Naviguer jusqu'au fichier/dossier
3. Cliquer sur la version à restaurer (historique disponible)
4. Restore to original location OU Download
5. Vérifier la restauration dans SharePoint/OneDrive
```

### Restaurer un compte utilisateur M365 supprimé
```
1. Portail Keepit → Users → [Client]
2. Chercher le compte supprimé (visible dans Keepit même si supprimé dans M365)
3. Sélectionner → Restore User
4. Les données sont restaurées dans un nouveau compte ou compte réactivé
⚠️ La licence M365 doit être disponible pour la restauration
```

---

## 5. AUDIT ET CONFORMITÉ

```
Portail Keepit → Reports
→ Backup Success Rate : % de backups réussis sur les 30 derniers jours
→ Storage Used : espace utilisé par client
→ Activity Log : historique des backups et restaurations

Export des rapports (pour audit client) :
Reports → Export → CSV ou PDF
```

---

## 6. GESTION DES LICENCES KEEPIT

```
Admin → [Client] → Licenses
→ Nombre d'utilisateurs licenciés vs utilisateurs protégés
→ Si utilisateurs > licences : backup incomplet

⚠️ Nouveaux utilisateurs M365 ne sont PAS automatiquement protégés
   si le nombre de licences est atteint
Action : ajouter des licences ou vérifier les utilisateurs actifs
```

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer un connecteur — les données sauvegardées seraient perdues
⛔ NE JAMAIS modifier les permissions du compte admin M365 utilisé par Keepit
   sans tester la reconnexion ensuite
⛔ NE PAS ignorer les alertes de connecteur déconnecté plus de 24h
⛔ NE PAS restaurer vers un utilisateur actif sans vérifier l'impact sur les données existantes
```

---

## 8. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Connecteur déconnecté > 24h | BackupDR + CloudMaster | Dans l'heure |
| Restauration urgente (données perdues) | BackupDR | Immédiat |
| Problème de licences (utilisateurs non protégés) | BackupDR + TECH | Dans la journée |


---
<!-- SOURCE: RUNBOOK__DR_Plan_Validation_V1 -->
## RUNBOOK — Plan de Relève (DR) Validation et Exécution

# RUNBOOK — Plan de Relève (DR) : Validation & Exécution
**ID :** RUNBOOK__DR_Plan_Validation_V1
**Version :** 1.0 | **Agents :** IT-BackupDRMaster, IT-MaintenanceMaster
**Domaine :** INFRA — Disaster Recovery
**Mis à jour :** 2026-03-20

---

## 1. OBJECTIFS DU PLAN DE RELÈVE

```
RPO (Recovery Point Objective) : Perte de données maximale acceptable
   → Exemple : RPO = 4h = on tolère de perdre 4h de données max

RTO (Recovery Time Objective) : Temps de reprise maximal acceptable
   → Exemple : RTO = 8h = les systèmes doivent être opérationnels en < 8h

Ces valeurs sont définies par CLIENT dans Hudu → Agreements → BR/BDR
```

---

## 2. NIVEAUX DE SINISTRE ET RÉPONSE

| Niveau | Définition | Déclenchement |
|---|---|---|
| **N1 — Incident** | 1 service ou serveur hors ligne | Restauration normale |
| **N2 — Panne partielle** | Salle serveur principale inaccessible | Failover partiel |
| **N3 — Catastrophe** | Site complet inaccessible | Plan de relève complet |

---

## 3. PRÉREQUIS AVANT ACTIVATION DU PLAN DE RELÈVE

```
✅ Checklist avant démarrage :
[ ] Confirmer l'étendue du sinistre (quels systèmes, quelle durée estimée)
[ ] Obtenir l'approbation du responsable client pour l'activation
[ ] Vérifier que le dernier backup est disponible (Datto/Veeam) et l'heure du snapshot
[ ] Identifier le site de reprise (cloud Datto, infra secondaire, Azure)
[ ] Notifier les parties prenantes (client + équipe interne)
[ ] Ouvrir un billet P1 dans CW avec la mention "DR ACTIVÉ"
[ ] Informer le NOC : monitoring renforcé pendant toute la durée

⚠️ NE JAMAIS activer le plan de relève sans approbation du client
⚠️ NE JAMAIS éteindre les serveurs primaires sans certitude qu'ils ne récupèrent pas
```

---

## 4. ORDRE DE REPRISE DES SYSTÈMES

```
⚠️ L'ordre de démarrage est CRITIQUE — respecter impérativement

ORDRE 1 — Réseau et accès
├── UPS / alimentation
├── Switches core
├── Firewall (WatchGuard/Fortinet/etc.)
└── VPN (pour accès remote de l'équipe IT)

ORDRE 2 — Infrastructure de base
├── Domain Controller principal (AD/DNS)
├── DC secondaire (si disponible)
└── DHCP (si séparé du DC)

ORDRE 3 — Services partagés
├── Serveur de fichiers
├── Serveur d'impression
└── NAS / Stockage partagé

ORDRE 4 — Applications métier
├── SQL Server (base de données)
├── ERP / Application principale du client
├── Serveur web / applicatif
└── RDS / Accès distant

ORDRE 5 — Services secondaires
├── Backup / Veeam / Datto
├── Monitoring
└── Autres services non critiques

VALIDATION À CHAQUE ÉTAPE avant de passer à la suivante
```

---

## 5. VALIDATION POST-REPRISE

```powershell
# Script de validation infrastructure de base
Start-Transcript -Path "C:\IT_LOGS\AUDIT\DR_Validation_$(Get-Date -Format 'yyyyMMdd_HHmm').log"

Write-Host "=== VALIDATION DR — $(Get-Date) ===" -ForegroundColor Cyan

# 1. DC et AD
Write-Host "=== DOMAIN CONTROLLER ===" -ForegroundColor Yellow
Get-Service NTDS,DNS,Netlogon,KDC | Select-Object Name, Status | Format-Table -AutoSize
net share | Select-String "SYSVOL|NETLOGON"
repadmin /replsummary

# 2. Connectivité réseau
Write-Host "=== CONNECTIVITÉ ===" -ForegroundColor Yellow
Test-NetConnection -ComputerName "8.8.8.8" -InformationLevel Quiet
Test-NetConnection -ComputerName "domaine.local" -InformationLevel Quiet

# 3. Services critiques
Write-Host "=== SERVICES CRITIQUES ===" -ForegroundColor Yellow
$Services = @("MSSQLSERVER","W3SVC","TermService","Spooler")
Get-Service $Services -ErrorAction SilentlyContinue |
    Select-Object Name, Status | Format-Table -AutoSize

# 4. Espace disques
Write-Host "=== DISQUES ===" -ForegroundColor Yellow
Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} |
    Select-Object Name,
        @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
        @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} | Format-Table -AutoSize

Write-Host "=== VALIDATION TERMINÉE ===" -ForegroundColor Green
Stop-Transcript
```

---

## 6. TESTS ANNUELS DU PLAN DE RELÈVE

```
Fréquence recommandée : 1x par an minimum, idéalement 2x

Test de type Desktop Exercise (Tabletop) :
→ Simulation sur papier/discussion — pas d'action réelle
→ Durée : 2-3h
→ Participants : IT + responsable client
→ Valider : connaissance du plan, contacts d'urgence, séquence de reprise

Test de type Functional Test (Test partiel) :
→ Démarrer 1-2 VMs depuis les backups Datto (Instant Virtualization)
→ Vérifier l'accessibilité
→ Mesurer le RTO réel vs objectif
→ Ne pas impacter la production

Test Full DR (annuel) :
→ Basculer un site complet vers le cloud Datto ou site secondaire
→ Mesurer RTO et RPO réels
→ Valider avec les utilisateurs clés
→ Documenter les écarts et mettre à jour le plan
```

---

## 7. COMMUNICATION PENDANT UN SINISTRE

```
T+0 (découverte) :
→ Ouvrir billet P1 CW : "SINISTRE — DR activé — Client [NOM]"
→ Notifier le NOC et le superviseur IT
→ Appeler le responsable client : [voir Passportal / Hudu → Contact d'urgence]

T+30 min :
→ Premier point de situation au client (même si aucune solution)
→ Estimation du RTO réaliste

T+[RTO/2] :
→ Mise à jour au client : avancement + ETA

À la reprise :
→ Communication formelle : "Services rétablis à [HH:MM]"
→ Rapport d'incident à envoyer dans les 24h
→ Post-mortem dans les 72h (billet CW)
```

---

## 8. CONTACTS D'URGENCE (TEMPLATE)

```
⚠️ À remplir dans Hudu pour chaque client

Client : [NOM]
Responsable IT client : [NOM] | [TÉLÉPHONE] | [EMAIL]
Contact d'urgence secondaire : [NOM] | [TÉLÉPHONE]
Décideur pour DR activation : [NOM] | [TÉLÉPHONE]
Fournisseur internet (ISP) : [NOM] | [TÉLÉPHONE SUPPORT] | [NUMÉRO DE COMPTE]
Fournisseur de matériel d'urgence : [NOM] | [TÉLÉPHONE]
```

---

## 9. NE PAS FAIRE

```
⛔ NE JAMAIS activer le plan de relève sans approbation client
⛔ NE JAMAIS ignorer l'ordre de démarrage des systèmes
⛔ NE JAMAIS éteindre les anciens serveurs avant d'avoir validé la reprise
⛔ NE PAS oublier de noter l'heure exacte de chaque action (pour le post-mortem)
⛔ NE JAMAIS communiquer des délais non réalistes au client sous pression
```

---

## 10. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| RTO en dépassement (objectif non atteint) | BackupDR + INFRA + superviseur | Immédiat |
| Corruption backup (restauration impossible) | BackupDR | Immédiat |
| Client insatisfait de la communication | TECH + superviseur | Immédiat |


---
<!-- SOURCE: TEMPLATE_BACKUP_DR-Test-et-Restore_V1 -->
## TEMPLATE — Rapport DR Test et Demande de Restauration

# TEMPLATE_BACKUP_DR-Test-et-Restore_V1
**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster
**Usage :** Rapport de test DR + Demande de restauration formelle
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — RAPPORT TEST DR

```
═══════════════════════════════════════════════
RAPPORT TEST DISASTER RECOVERY
Client        : [NOM CLIENT]
Date du test  : [YYYY-MM-DD]
Effectué par  : [Technicien]
Billet CW     : #[XXXXXX]
Solution backup : [Datto / Veeam / Keepit / Autre]
═══════════════════════════════════════════════

SCÉNARIO TESTÉ
Type : [Restauration fichier / VM complète / Instant Virtualization / Bare Metal]
Asset testé  : [Nom VM ou serveur]
Point de restauration utilisé : [Date/heure du snapshot]
Objectif RPO : [Xh] | Objectif RTO : [Xh]

PROCÉDURE EXÉCUTÉE
1. [Étape 1 — ex: Démarrage VM via Instant Virtualization Datto]
2. [Étape 2 — ex: Test RDP/connexion]
3. [Étape 3 — ex: Validation des services critiques]
4. [Étape 4 — ex: Arrêt de la VM de test]

RÉSULTATS
RPO réel : [Xh depuis le dernier backup sain]
RTO réel : [Xh Ymin pour atteindre un état opérationnel]

Validation :
☐ VM/système a démarré correctement
☐ Services critiques opérationnels : [Liste]
☐ Données accessibles et intègres
☐ Accès réseau/utilisateurs fonctionnel (si testé)
☐ Screenshot backup présent (Datto)

Résultat global : ✅ PASS / ❌ FAIL / ⚠️ PARTIEL

ÉCARTS ET ACTIONS CORRECTIVES
[Si FAIL ou PARTIEL : décrire l'écart et l'action pour y remédier]

PROCHAINE DATE DE TEST RECOMMANDÉE : [YYYY-MM-DD]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — DEMANDE DE RESTAURATION

```
═══════════════════════════════════════════════
DEMANDE DE RESTAURATION
Billet CW      : #[XXXXXX]
Client         : [NOM]
Date/Heure     : [YYYY-MM-DD HH:MM]
Demandé par    : [Nom utilisateur / responsable]
Technicien     : [NOM]
═══════════════════════════════════════════════

OBJET DE LA RESTAURATION
Type : ☐ Fichier(s)/Dossier(s)  ☐ VM complète  ☐ Base de données  ☐ Autre

Fichier(s) concerné(s) :
• [Chemin et nom exact du fichier ou dossier]
• [Fichier 2 si applicable]

Serveur/VM source : [NOM]
Solution backup   : [Datto / Veeam / Keepit]

POINT DE RESTAURATION DEMANDÉ
Date/heure souhaitée : [YYYY-MM-DD HH:MM]
(dernier backup disponible avant la perte/corruption)

DESTINATION
☐ Emplacement original (écrase l'existant — confirmer avec client)
☐ Emplacement alternatif : [Préciser le chemin]
☐ Téléchargement local (pour vérification)

AUTORISATION
Autorisé par : [Nom du responsable client]
Méthode      : ☐ Verbal  ☐ Email  ☐ Teams  ☐ Billet CW

VALIDATION POST-RESTAURATION
[ ] Fichier ouvert et contenu vérifié par [utilisateur]
[ ] Données intègres confirmées
[ ] Billet CW complété avec résultats
═══════════════════════════════════════════════
```


---
<!-- SOURCE: CHECKLIST_BACKUP_DR-Readiness_V1 -->
## CHECKLIST — DR Readiness

# CHECKLIST_BACKUP_DR-Readiness_V1
**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster
**Usage :** Vérification mensuelle de la disponibilité du plan de relève
**Mis à jour :** 2026-03-20

---

## BACKUPS — ÉTAT COURANT

### Datto BCDR
- [ ] Tous les agents : dernier backup Success ou Warning acceptable
- [ ] Screenshot de vérification présent pour les VMs critiques
- [ ] Stockage local Datto : espace libre > 20%
- [ ] Stockage cloud : synchronisation OK (pas d'erreur > 24h)
- [ ] Rétention configurée selon la politique client (Hudu → Agreements)

### Veeam
- [ ] Jobs en cours : Success ou Warning acceptable
- [ ] Repository : espace libre > 20%
- [ ] Dernière vérification d'intégrité (SureBackup ou Instant Recovery test) < 30 jours
- [ ] Veeam Cloud Connect (si applicable) : synchronisation OK

### Keepit (M365)
- [ ] Connecteur Microsoft 365 : Connected (pas Disconnected)
- [ ] Dernière synchronisation Exchange : OK
- [ ] Dernière synchronisation SharePoint/OneDrive : OK
- [ ] Nombre d'utilisateurs protégés = nombre d'utilisateurs actifs

---

## PLAN DE RELÈVE — VALIDITÉ

- [ ] Document DR à jour dans Hudu pour ce client (date < 6 mois)
- [ ] Contacts d'urgence à jour (responsable client, MSP on-call)
- [ ] RTO et RPO documentés et connus de l'équipe
- [ ] Ordre de démarrage des systèmes documenté
- [ ] Accès aux ressources de reprise validé (accès Datto portal, VPN, credentials Passportal)

---

## TESTS DR

- [ ] Dernier test d'intégrité backup : _______ (date)
  - Résultat : ☐ Pass  ☐ Fail → Actions correctives : _______
- [ ] Dernier test Instant Virtualization : _______ (date)
  - RTO mesuré : _______ min / Objectif : _______ min
- [ ] Prochain test planifié : _______

---

## VÉRIFICATION ANNUELLE

- [ ] Test complet DR (Tabletop ou Functional) effectué cette année : ☐ Oui  ☐ Non
- [ ] Rapport de test archivé dans CW/Hudu : ☐ Oui
- [ ] Écarts identifiés et corrigés : ☐ Oui  ☐ En cours : _______

---

## RÉSULTAT

☐ **DR READY** — Tous les items validés
☐ **ACTIONS REQUISES** — Items en attente : _______
☐ **NON READY** — Problème critique : escalade IT-BackupDRMaster immédiatement
