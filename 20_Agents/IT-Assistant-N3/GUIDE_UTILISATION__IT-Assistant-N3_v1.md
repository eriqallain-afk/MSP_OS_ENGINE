# Guide d'utilisation — @IT-Assistant-N3 (v1.0)
> **Pour :** Techniciens N2/N3 MSP — incidents complexes et architecture
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-Assistant-N3 ?

**IT-Assistant-N3 est l'expert technique de la plateforme — il couvre de N1 à N3.**

Il guide le technicien en temps réel sur des incidents complexes que N2 ne peut pas résoudre : Active Directory, Domain Controllers, RDS, Exchange, VMware/Hyper-V, SQL Server, scripts PowerShell production-ready. Il inclut des runbooks intégrés par domaine, une génération de scripts avec standards obligatoires, et une clôture CW complète.

**Domaines couverts :**

| Domaine | Technologies |
|---|---|
| Infrastructure | Windows Server, Active Directory, DNS/DHCP, FSMO |
| Virtualisation | VMware vSphere, Hyper-V, XCP-ng |
| Services cloud | M365 — Exchange Online, Teams, SharePoint, Intune |
| Accès distant | RDS / RemoteApp, sessions, profils, licences |
| Backup | Veeam, Datto — jobs, restauration VM, intégrité |
| Réseau | WatchGuard, Fortinet, Cisco, Ubiquiti, VPN |
| Sécurité | EDR, isolation réseau, collecte artefacts, RCA |
| Linux | Ubuntu, RHEL, Debian — diagnostic, services, logs |

**Ce qu'il fait :**
- Triage P1–P4 avec arbre de décision adapté aux incidents infrastructure
- Runbooks intégrés accessibles par commande (dc, sql, veeam, rds, panne, sécurité...)
- Scripts PowerShell production-ready avec header, transcript, try/catch, -WhatIf
- Gestion d'escalade P1 avec bloc CW départements NOC/SOC/INFRA/TECH
- Post-check AD obligatoire après tout reboot serveur
- Capitalisation KB + enregistrement DB après clôture

---

## Quand l'utiliser ?

- IT-Assistant-N2 est bloqué et escalade vers N3
- Un serveur est impliqué dans l'incident (DC, SQL, RDS, Hyper-V)
- Tu dois générer un script PowerShell de production (avec header, transcript, standards RMM)
- Une maintenance planifiée multi-serveurs doit être organisée
- Tu dois valider AD/DC avant ou après un reboot
- Un incident sécurité nécessite une réponse structurée (isolation, collecte artefacts)
- Tu as besoin d'un runbook complet par domaine (patching, veeam, panne, réseau...)

**Distinction avec les agents voisins :**

| Agent | Niveau | Utiliser quand |
|---|---|---|
| IT-FrontLine | N1/N2 | Premier contact — appels, triage, résolutions rapides |
| IT-Assistant-N2 | N2 | MDP, accès, Outlook, VPN utilisateur, poste lent |
| **IT-Assistant-N3** | N3 | Serveurs, DC/AD, RDS, Hyper-V, SQL, scripts production |
| IT-SysAdmin | Senior | Admin système généraliste — patching, virtualisation, infrastructure |

> **Règle clé N3 :** 1 seul DC à la fois pour les reboots. Post-check AD obligatoire après chaque reboot serveur.

---

## Les commandes principales

### `/start` — Nouvelle intervention N3

Produit le triage complet avec plan d'action, checklist pre-action et scripts de collecte d'état.

**Usage :**
```
/start #77010
Client : Otto Inc
Problème : DC01 ne répond plus — les utilisateurs ne peuvent pas s'authentifier
```

**Ce que tu obtiens :**
```
TRIAGE & CATEGORISATION
Catégorie : INFRA CRITIQUE
Priorité  : P1
Systèmes affectés : DC01 — Active Directory
Impact utilisateurs : Tous les utilisateurs du domaine

⚠️ [ESCALADE REQUISE — P1]
Ce billet doit être transféré maintenant.
Tape /escalade pour générer le bloc CW à coller avant de transférer.

[Ou si tu choisis de continuer en P1 :]
⚠️ [DÉCISION DOCUMENTÉE — P1 NON ESCALADÉ]
Je continue à t'assister — réévaluation dans 15 min.

PLAN D'INTERVENTION :
1. Ping DC01 — réponse ?
2. Test-NetConnection DC01 -Port 389 (LDAP)
3. Si KO → console physique ou iLO/iDRAC

CHECKLIST PRE-ACTION :
[ ] Snapshot VM créé avant toute action
[ ] NOC alerté
[ ] Autre DC disponible pour auth temporaire ?

SCRIPTS INITIAUX (lecture seule) :
[Scripts PowerShell de diagnostic fournis]
```

---

### `/start_maint` — Pack maintenance planifiée

Pour organiser une fenêtre de maintenance multi-serveurs. Produit l'ordre de traitement, les risques, la checklist complète et les scripts pre/post.

**Usage :**
```
/start_maint
Client : Dupont Construction
Serveurs : SRV-DC01, SRV-SQL01, SRV-FILE01, SRV-RDS01
Fenêtre : samedi 22h-02h
```

**Ce que tu obtiens :**
- Ordre recommandé : SQL → App/Web → Print → File → DC (DC toujours en dernier)
- Checklist bloquants : backup valide, espace disque > 15%, snapshot créé
- Scripts PowerShell pre-check et post-check pour chaque serveur
- Nommage snapshots : `@T12345_Preboot_SRV-DC01_SNAP_20260522_2200`
- Annonces Teams début et fin pré-rédigées

---

### `/runbook [sujet]` — Runbooks intégrés par domaine

Affiche le runbook complet pour le domaine demandé. L'agent charge aussi les fichiers depuis GitHub en temps réel.

**Runbooks disponibles :**

```
/runbook patching    → Patching Windows — ordre serveurs, precheck, postcheck
/runbook ad          → Active Directory — validation DC pre/post
/runbook healthcheck → Health Check serveur mensuel
/runbook veeam       → Veeam — vérification jobs, erreurs courantes, restauration
/runbook rds         → Remote Desktop Services — connexions, sessions, performance
/runbook m365        → Microsoft 365 — onboarding, dépannage Exchange, Teams
/runbook reseau      → Diagnostic réseau — couche physique à application
/runbook panne       → Post-panne électrique — ordre de reprise infra
/runbook securite    → Réponse incident sécurité — isolation, artefacts, escalade
/runbook print       → Print Server — spooler, queue, drivers
/runbook linux       → Linux — diagnostic, services, logs, disque plein
```

**Exemple :**
```
/runbook ad
```

Produit :
```
PRE-PATCH AD
[ ] repadmin /showrepl     → 0 erreur
[ ] repadmin /replsummary  → 0 erreur
[ ] dcdiag /test:replications → 0 erreur
[ ] nslookup [domaine]     → OK
[ ] SYSVOL + NETLOGON accessibles
[ ] FSMO roles documentés : netdom query fsmo
[ ] Snapshot VM créé

POST-PATCH AD
[ ] Services : NTDS, DNS, NETLOGON, KDC, W32TM démarrés
[ ] repadmin /showrepl → 0 erreur
[ ] Auth test : login compte utilisateur standard
[ ] SYSVOL + NETLOGON accessibles
[ ] Event Log System : 0 erreur critique
[ ] GPO appliquées : gpresult /r
```

---

### `/script [description]` — Script PowerShell production-ready

Génère un script complet avec tous les standards obligatoires : `param()` ligne 1, header, transcript, try/catch, `-WhatIf` pour les scripts destructifs.

**Usage :**
```
/script analyse réplication AD sur tous les DCs du domaine
```

**Ce que tu obtiens :**
```powershell
param(
    [string]$Billet  = "T[XXXXX]",
    [string]$Serveur = $env:COMPUTERNAME
)

#Requires -Version 5.1
# ============================================================
# Script  : DIAG_Replication_AD_v1.ps1
# Billet  : $Billet
# Auteur  : [TECHNICIEN]
# Date    : 2026-05-18
# Version : 1.0
# Desc    : Analyse réplication AD sur tous les DCs
# ⚠️ Impact : lecture seule — aucune modification
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$LogDir  = "C:\IT_LOGS\DIAG"
$Date    = Get-Date -Format "yyyyMMdd_HHmm"
$LogFile = "$LogDir\DIAG_${Serveur}_${Billet}_${Date}.log"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
Start-Transcript -Path $LogFile -Append
Write-Host "=== Début : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan

try {
    repadmin /replsummary
    repadmin /showrepl
    dcdiag /test:replications /quiet
    Write-Host "[OK] Analyse terminée" -ForegroundColor Green
}
catch {
    Write-Host "[ERREUR] : $_" -ForegroundColor Red
}

Write-Host "=== Fin : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan
Stop-Transcript
```

**Règle anti-erreur RMM :**
- `Write-Host " "` (espace) — jamais `Write-Host ""`
- `[AllowEmptyString()]` sur les paramètres `[string]` avec valeur par défaut
- `param()` toujours ligne 1 absolue

---

### `/escalade` — Bloc CW de transfert département

Sur `/escalade` ou déclenchement automatique P1, génère le bloc prêt à coller dans CW.

**Usage :**
```
/escalade
```

**Règle de routage automatique :**
| Situation | Département |
|---|---|
| Ransomware, chiffrement actif | SOC |
| Breach, accès non autorisé, exfiltration | SOC |
| Phishing, compromission compte | SOC |
| DC down, AD compromis, réplication brisée | NOC |
| Réseau principal hors service | NOC |
| Backup critique en échec, DR | NOC |
| Serveur critique (SQL, RDS, Exchange) | INFRA |
| Infrastructure dégradée | INFRA |
| Escalade technique senior, RCA | TECH |

---

### `/close` — Clôture complète 4 livrables

Sur `/close`, menu interactif — l'agent attend ton choix.

**Usage :**
```
/close
```

Génère dans l'ordre : CW Discussion (format STAR), Note Interne détaillée, Email client, Annonce Teams.

Après `/close`, l'agent propose automatiquement :
```
Livrables CW générés.
- Tape /kb pour capitaliser cet incident dans IT-KnowledgeKeeper
- Tape /db pour enregistrer l'intervention dans MSP-Assistant DB
```

---

### `/kb` — Brief capitalisation KB

Génère un brief YAML complet pour IT-KnowledgeKeeper. Critère : tout incident P1/P2 et tout nouveau type de problème → KB obligatoire.

**Usage :**
```
/kb
```

Produit le YAML complet : `ticket_id`, `cause_racine_identifiee` (la VRAIE cause, pas le symptôme), `commandes_cles`, `points_attention`, `runbook_recommande`.

---

## Flux de travail recommandé

### Incident N3 entrant

```
1. Billet reçu (escalade de N2 ou MSPBOT direct)
       ↓
2. /start [#billet + description]
   → Triage + priorité + plan + checklist + scripts precheck
       ↓
3. P1 → /escalade IMMÉDIAT (bloc CW département)
   P2/P3 → intervention guidée
       ↓
4. Collecte d'état (scripts lecture seule d'abord)
       ↓
5. Runbook si applicable : /runbook [sujet]
   Script si nécessaire : /script [description]
       ↓
6. Reboot serveur → post-check AD obligatoire (/runbook ad)
   1 seul DC à la fois — confirmation avant chaque reboot
       ↓
7. /close → livrables CW complets
8. /kb si P1/P2 ou nouveau type d'incident
9. /db si intervention > 30 min
```

### Post-check AD obligatoire après reboot

```
Après tout reboot DC ou serveur impactant AD :
1. Attendre 5 min après le redémarrage
2. /runbook ad → checklist post-patch AD
3. repadmin /showrepl → 0 erreur
4. Login utilisateur standard → confirmer auth OK
5. Valider SYSVOL et NETLOGON accessibles
→ Passer au serveur suivant seulement si tout est vert
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| 1 seul DC à la fois — jamais 2 DCs simultanément | Perte d'authentification totale si les 2 tombent |
| Post-check AD obligatoire après tout reboot serveur | Réplication peut être silencieusement brisée |
| Snapshot VM créé avant toute action sur serveur critique | Rollback possible si le patch échoue |
| Lecture seule en premier — jamais de remédiation avant diagnostic | Évite d'aggraver l'incident |
| Backup valide vérifié avant toute maintenance | Bloquant — pas de maintenance sans backup confirmé |
| `param()` ligne 1 absolue dans tout script | Sinon le RMM ne passe pas les paramètres correctement |
| `-WhatIf` sur tous les scripts destructifs | Valider l'effet avant d'exécuter |
| ZÉRO IP dans les livrables clients | Jamais dans CW Discussion ni Email |
| Machine non éteinte en cas de ransomware | Artefacts forensics préservés pour le SOC |
| P1 non escaladé → réévaluation automatique à 15 min | L'agent repropose l'escalade — ne pas ignorer |

---

## Questions fréquentes

**Q : Quelle différence entre IT-Assistant-N3 et IT-SysAdmin ?**
IT-Assistant-N3 guide étape par étape avec runbooks et scripts — posture pédagogique, adapté pour les incidents imprévus avec le client. IT-SysAdmin a une posture senior autonome : il planifie et exécute directement, mieux adapté aux maintenances planifiées et à l'administration régulière.

**Q : Pourquoi le post-check AD est-il obligatoire même pour un reboot planifié ?**
La réplication AD peut être brisée silencieusement après un reboot. Sans vérification, le problème peut ne se manifester que des heures plus tard, en production, et être difficile à attribuer.

**Q : Peut-il redémarrer 2 DCs en même temps ?**
Non — refus systématique. Si tu insistes, l'agent documente la décision et réévalue dans 15 min. 1 DC à la fois, post-check avant le suivant.

**Q : Comment générer un script sans déclencher des erreurs dans N-able ?**
L'agent respecte automatiquement les standards RMM : `Write-Host " "` (espace, pas vide), `[AllowEmptyString()]` sur les paramètres string, `param()` ligne 1 absolue, valeur par défaut non vide. Ne jamais modifier ces règles.

**Q : /kb est-il obligatoire après chaque intervention N3 ?**
Obligatoire pour tout P1/P2 et tout nouveau type de problème. Optionnel pour les P3/P4 simples. L'agent le propose automatiquement après `/close`.

---

*GUIDE_UTILISATION — IT-Assistant-N3 v1.0 — MSP Intelligence AI — 2026-05-18*
