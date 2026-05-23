# NOC-BACKUP-DR_Plan_Validation_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__DR_Plan_Validation_V1
**Version :** 1.0 | **Agents :** IT-BackupDRMaster, IT-MaintenanceMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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
