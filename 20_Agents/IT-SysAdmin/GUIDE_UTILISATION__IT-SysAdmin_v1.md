# Guide d'utilisation — @IT-SysAdmin (v1.0)
> **Pour :** Administrateurs système MSP — senior
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-SysAdmin ?

**IT-SysAdmin est le copilote technique de l'administrateur système senior.**

Il accompagne chaque intervention de A à Z — planification, exécution guidée, vérification des résultats, clôture CW complète. Il couvre tous les domaines IT sans exception : patching, virtualisation, AD, M365, Azure, Linux, Veeam, EDR, firewalls.

Sa posture est celle d'un sysadmin de 25 ans d'expérience : il résout directement sans step-by-step excessif, génère des scripts production-ready, et fournit des analyses précises sans théorie inutile.

**Domaines couverts :**

| Domaine | Technologies |
|---|---|
| Serveurs Windows | Active Directory, DNS/DHCP, GPO, FSMO, File/Print Server |
| Virtualisation | Hyper-V, VMware vSphere, XCP-ng — VMs, snapshots, migration |
| Microsoft 365 | Exchange Online, Teams, SharePoint, OneDrive, Intune |
| Azure | Azure AD / Entra ID, ressources cloud |
| Backup | Veeam, Datto, Keepit — jobs, restauration, intégrité |
| Sécurité | SentinelOne, EDR, CVE, hardening, incidents |
| Réseau | Firewalls (WatchGuard, Fortinet), VPN, VLAN |
| Linux | Ubuntu, RHEL, Debian — services, diagnostic, logs |
| RDS | RemoteApp, sessions, licences, performance |
| Patching | Windows Update, WSUS, maintenance planifiée |

**Ce qu'il fait :**
- Triage et plan d'action structuré pour toute intervention
- Pack maintenance planifiée complet : ordre, risques, checklist, scripts pre/post
- Runbooks guidés par domaine accessibles par commande
- Scripts PowerShell production-ready avec tous les standards RMM
- Analyse de résultats de scripts collés directement (/check)
- Estimation temps et tâches pour devis ou fenêtres de maintenance
- Clôture CW complète selon TEMPLATE_BUNDLE_CW_CLOSE.md

**Ce qu'il ne fait PAS :**
- Il ne gère pas les escalades vers NOC/SOC en tant qu'agent — appeler directement les départements
- Il ne remplace pas IT-SecurityMaster pour les incidents sécurité actifs

---

## Quand l'utiliser ?

- Tu planifies une fenêtre de maintenance multi-serveurs
- Tu dois patcher un environnement Windows Server (1 ou plusieurs serveurs)
- Tu administres Active Directory : GPO, comptes, audits, scripts
- Tu travailles sur Hyper-V, VMware ou Veeam
- Tu as besoin d'un script PowerShell production-ready avec standards complets
- Tu veux analyser les résultats d'un diagnostic collé depuis le terminal (/check)
- Tu dois produire une estimation de temps pour un devis ou une planification
- Tu clôtures une intervention complexe avec livrables CW complets

**Distinction avec les agents voisins :**

| Agent | Posture | Utiliser quand |
|---|---|---|
| IT-FrontLine | Premier contact N1/N2 | Appels entrants, triage, résolutions rapides |
| IT-Assistant-N2 | Coach guidé N2 | Problème utilisateur — step-by-step au téléphone |
| IT-Assistant-N3 | Expert guidé N3 | Incidents serveur complexes — guidage pédagogique |
| **IT-SysAdmin** | Senior autonome | Administration régulière, maintenance planifiée, infra complète |
| IT-MaintenanceMaster | Guidage détaillé maint. | Même périmètre — confirmation à chaque étape (posture différente) |

---

## Les commandes principales

### `/start` — Nouvelle intervention sysadmin

Produit le triage complet, plan d'action, risques, checklist pre-action et scripts precheck.

**Usage :**
```
/start #12345
Client : Dupont Construction
Intervention : DC01 présente des erreurs de réplication — aucun impact utilisateur pour l'instant
```

**Ce que tu obtiens (format YAML) :**
```yaml
triage:
  categorie: "NOC"
  priorite: "P2"
  systemes_affectes: ["SRV-DC01"]
  impact_utilisateurs: "Aucun pour l'instant — risque si DC secondaire tombe"

plan_action:
  - "Exécuter DIAG_Precheck_DC_v1.ps1 (lecture seule)"
  - "Analyser repadmin /replsummary — identifier le partenaire en erreur"
  - "Vérifier DNS et connectivité inter-DCs"
  - "Corriger la réplication (méthode selon le type d'erreur)"

risques:
  - "Si DC secondaire tombe pendant la panne → perte auth complète (P1)"

checklist_pre_action:
  - "[ ] Snapshot VM créé sur DC01"
  - "[ ] NOC alerté (monitoring renforcé)"
  - "[ ] Autre DC disponible et confirmé fonctionnel"

scripts_precheck: |
  # Scripts lecture seule fournis
```

---

### `/start_maint` — Maintenance planifiée complète

Pour organiser une fenêtre de maintenance. Produit l'ordre des serveurs, les risques, la checklist complète, les scripts pre/post, les noms de snapshots et les annonces Teams.

**Usage :**
```
/start_maint
Client : Otto Inc
Serveurs : SRV-DC01, SRV-SQL01, SRV-FILE01, SRV-PRINT01
Fenêtre : vendredi 22h-02h
Type : Patching Windows mensuel
```

**Ce que tu obtiens :**
- Ordre de traitement : Non-critiques → SRV-FILE01 → SRV-PRINT01 → SRV-SQL01 → SRV-DC01 (DC en dernier)
- Scripts precheck par serveur (espace disque, pending reboot, services critiques, Event Log)
- Nommage snapshots : `@T12345_Preboot_SRV-DC01_SNAP_20260522_2200`
- Checklist bloquants : backup valide, espace C > 15%, snapshot créé
- Annonces Teams début/fin pré-rédigées

**Règle critique :** 1 serveur à la fois — jamais de liste automatique de reboots.

---

### `/runbook [sujet]` — Runbooks par domaine

Charge le runbook du domaine demandé avec scripts PowerShell séparés.

**Runbooks disponibles :**

```
/runbook dc       → Validation DC/AD — santé, réplication, FSMO
/runbook sql      → SQL Server — bases, services, espace log
/runbook veeam    → Veeam — jobs, repositories, erreurs courantes
/runbook rds      → Remote Desktop — sessions, drain mode, performance
/runbook m365     → Microsoft 365 — Exchange, utilisateurs, traces mail
/runbook reseau   → Diagnostic réseau — baseline, firewall, VPN
/runbook panne    → Post-panne électrique — ordre de démarrage infra
/runbook print    → Print Server — spooler, queue, drivers
/runbook linux    → Linux — diagnostic rapide, services, logs
/runbook ad       → AD complet — FSMO, admins, comptes expirés, verrouillés
```

**Exemple — /runbook dc :**
```
/runbook dc
```

Produit :
```powershell
# Santé DC — lecture seule
dcdiag /test:replications /test:netlogons /test:fsmocheck /quiet
repadmin /replsummary
repadmin /showrepl
Get-ADDomainController -Filter * | Select-Object Name,IsGlobalCatalog,OperationMasterRoles
```

---

### `/script [description]` — Script PowerShell production-ready

Génère un script complet avec tous les standards obligatoires.

**Usage :**
```
/script audit espace disque sur tous les serveurs du domaine
```

**Ce que tu obtiens :**
```powershell
param(
    [string]$Billet  = "T[XXXXX]",
    [string]$Client  = "[NOM_CLIENT]",
    [string]$Serveur = $env:COMPUTERNAME
)

#Requires -Version 5.1
# ============================================================
# Script  : AUDIT_EspaceDisk_AllServers_v1.ps1
# Billet  : $Billet
# Auteur  : [TECHNICIEN]
# Date    : 2026-05-18
# Version : 1.0
# Desc    : Audit espace disque sur tous les serveurs du domaine
# ⚠️ Impact : lecture seule — aucune modification
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
$LogDir  = "C:\IT_LOGS\AUDIT"
$Date    = Get-Date -Format "yyyyMMdd_HHmm"
$LogFile = "$LogDir\AUDIT_${Serveur}_${Billet}_${Date}.log"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
Start-Transcript -Path $LogFile -Append
Write-Host "=== Début : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan

try {
    Get-ADComputer -Filter {OperatingSystem -like "*Server*"} |
        ForEach-Object {
            Get-PSDrive -PSProvider FileSystem -CimSession $_.Name -ErrorAction SilentlyContinue |
                Where-Object {$_.Used -gt 0} |
                Select-Object @{N='Serveur';E={$_.PSComputerName}},
                              Name,
                              @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
                              @{N='Free_PCT';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}}
        } | Format-Table -AutoSize
    Write-Host "[OK] Audit terminé" -ForegroundColor Green
}
catch {
    Write-Host "[ERREUR] : $_" -ForegroundColor Red
}

Write-Host "=== Fin : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan
Stop-Transcript
```

**Conventions de nommage scripts :**
```
MAINT_Patching_AllServers_v1.ps1
DIAG_Validation_DC_v1.ps1
AUDIT_HealthCheck_SQL_v2.ps1
SECU_CheckAdmins_AD_v1.ps1
```

---

### `/check [résultats]` — Analyser les résultats d'un script

Colle les résultats d'une commande ou d'un script — l'agent analyse et propose la prochaine action.

**Usage :**
```
/check
[Coller les résultats du terminal ici]
```

**Ce que tu obtiens :**
```yaml
analyse:
  statut_global: "ATTENTION"
  elements:
    - element: "Espace disque C:"
      valeur: "4 GB libres (3%)"
      statut: "❌ Critique — action requise"
    - element: "Services automatiques arrêtés"
      valeur: "0"
      statut: "✅ Normal"
    - element: "Pending reboot"
      valeur: "true"
      statut: "⚠️ Reboot requis avant patching"

prochaine_action: "Nettoyage dossiers temporaires + purge logs avant patching"

correctif: |
  # Nettoyage C: — valider d'abord avec -WhatIf
  Get-ChildItem "$env:SystemRoot\Temp" -Recurse -ErrorAction SilentlyContinue |
      Remove-Item -Recurse -Force -WhatIf
```

---

### `/estime` — Estimation temps et tâches

Pour les devis ou la planification d'une fenêtre de maintenance.

**Usage :**
```
/estime
Patching mensuel — 6 serveurs Windows Server 2019/2022
Dont 2 DCs, 1 SQL, 2 File Servers, 1 Print Server
```

**Ce que tu obtiens :**
```yaml
estimation:
  taches:
    - no: 1
      description: "Vérification sauvegardes + création snapshots"
      duree_min: 20
      duree_max: 40
      prerequis: "Accès Veeam / console virtualisation"
      risques: "Backup KO = report obligatoire"
    - no: 2
      description: "Patching 4 serveurs non-critiques"
      duree_min: 90
      duree_max: 150
      prerequis: "Snapshots créés, RMM accessible"
      risques: "Reboot prolongé si KB cumulatifs"
    - no: 3
      description: "Patching 2 DCs (1 à la fois avec post-check AD)"
      duree_min: 60
      duree_max: 120
      prerequis: "Serveurs non-critiques OK"
      risques: "Réplication AD à valider entre chaque DC"

  resume:
    fenetre_recommandee: "4h (inclure 30 min de marge)"
    prerequis_globaux:
      - "Backups vérifiés < 24h"
      - "Approbation client par écrit"
      - "Contacts d'urgence disponibles"
```

---

### `/close` — Menu de clôture interactif

Sur `/close`, menu interactif — l'agent attend ton choix avant de générer quoi que ce soit.

**Usage :**
```
/close
```

```
📋 Clôture — Billet #12345
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout (1+2+3+4)

Que veux-tu générer ?
```

L'agent sélectionne automatiquement le bon template selon la situation :

| Situation | Template utilisé |
|---|---|
| Maintenance / audit standard | CW_DISCUSSION |
| Incident P1/P2 complexe | CW_DISCUSSION_STAR |
| Note interne technique | CW_NOTE_INTERNE |
| Patching multi-serveurs | CW_NOTE_INTERNE_STAR |
| Email client requis | EMAIL_CLIENT |
| Notice Teams | AVIS_TEAMS |

---

## Flux de travail recommandé

### Maintenance planifiée

```
1. /start_maint [description fenêtre]
   → Ordre serveurs + checklist + scripts pre/post
       ↓
2. Créer snapshots — nommage standard @[BILLET]_Preboot_[SERVEUR]_SNAP_[YYYYMMDD_HHMM]
       ↓
3. Notice Teams début (générée par /start_maint)
       ↓
4. Pour chaque serveur dans l'ordre :
   a. Script precheck → /check [résultats]
   b. Patch via CW RMM
   c. Reboot si requis (validation explicite)
   d. Script postcheck → /check [résultats]
   e. Supprimer snapshot si postcheck OK
       ↓
5. /close → [A] Tous les livrables CW
6. /kb si incident ou comportement nouveau identifié
7. /db pour enregistrement dans MSP-Assistant DB
```

### Intervention ad hoc

```
1. /start [#billet + description]
       ↓
2. Scripts precheck (lecture seule) → /check [résultats]
       ↓
3. /runbook [domaine] si applicable
4. /script [description] si script requis
       ↓
5. Exécution avec confirmation avant toute action destructrice
       ↓
6. /close → livrables CW
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| 1 serveur à la fois pour les reboots | Jamais de liste automatique |
| Lecture seule AVANT toute remédiation | Collecter et confirmer avant d'agir |
| `param()` ligne 1 absolue dans tout script | Sinon RMM ne passe pas les paramètres |
| `Write-Host " "` — jamais `Write-Host ""` | Chaînes vides causent des erreurs N-able / CW RMM |
| Backup valide avant toute maintenance | Bloquant absolu |
| Snapshot créé avant action sur serveur critique | Rollback possible si patch échoue |
| ZÉRO IP dans CW Discussion | Visible sur la facture client |
| ZÉRO MDP dans les scripts ou les livrables | Passportal uniquement |
| Escalade immédiate si ransomware / breach | IT-SecurityMaster — ne pas toucher au poste |
| /close → menu — attendre le choix | Jamais de génération automatique |

---

## Questions fréquentes

**Q : Quelle différence entre IT-SysAdmin et IT-MaintenanceMaster ?**
Même périmètre technique — comportement différent. IT-SysAdmin a une posture senior autonome : il résout directement, moins step-by-step, adapté à l'admin régulière. IT-MaintenanceMaster a une posture de guidage avec confirmation à chaque étape — adapté aux techniciens qui veulent être accompagnés sur des maintenances planifiées.

**Q : Quelle différence entre IT-SysAdmin et IT-Assistant-N3 ?**
IT-Assistant-N3 guide étape par étape en mode pédagogique, adapté pour des incidents imprévus avec escalade et guidage structuré. IT-SysAdmin a une posture autonome, adapté pour les admins système expérimentés qui veulent un copilote, pas un tutoriel.

**Q : Peut-il générer des scripts pour N-able ou CW RMM ?**
Oui — avec les standards anti-erreur RMM intégrés : `Write-Host " "`, `[AllowEmptyString()]`, `param()` ligne 1. Ces règles sont appliquées automatiquement sur tout script généré.

**Q : Comment utiliser /check ?**
Après avoir exécuté un script ou une commande, coller le résultat brut du terminal après `/check`. L'agent analyse chaque ligne, identifie les ✅ OK / ⚠️ attention / ❌ problème, et propose le correctif si nécessaire.

**Q : /estime est-il utilisable pour un devis client ?**
Oui. Le bloc `note_client` dans le YAML de /estime est formulé en langage client-safe, sans détails d'infrastructure — il peut être copié directement dans un courriel ou une proposition de service.

**Q : Que faire si le patch échoue sur un serveur critique ?**
Ne pas passer au serveur suivant. Utiliser le snapshot créé en precheck pour rollback si nécessaire. Documenter l'erreur exacte dans CW, puis ouvrir un suivi avant de retenter.

---

*GUIDE_UTILISATION — IT-SysAdmin v1.0 — MSP Intelligence AI — 2026-05-18*
