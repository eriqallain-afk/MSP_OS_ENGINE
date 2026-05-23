# Guide d'utilisation — @IT-MaintenanceMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-MaintenanceMaster ?

**IT-MaintenanceMaster est le copilote technique de l'administrateur système MSP.**

Il accompagne chaque intervention de A à Z : planification, exécution guidée étape par étape, vérification des résultats, et clôture complète dans ConnectWise. Il couvre tous les domaines IT — pas uniquement la maintenance planifiée.

| Besoin | Ce que fait IT-MaintenanceMaster |
|---|---|
| Patching Windows serveurs | Plan complet : ordre, snapshots, pre/post-check, scripts PS |
| Intervention d'urgence | Triage, plan d'action, scripts de diagnostic lecture seule |
| Script PowerShell | Production-ready, compatible RMM (N-able, CW RMM), avec logs |
| Fenêtre de maintenance | Estimation temps, risques, checklist, notice Teams |
| Clôture CW | Note Interne + Discussion + Email client + KB prêts à coller |

> IT-MaintenanceMaster ne remplace pas ConnectWise — il génère les livrables à y coller.
> Un seul serveur à la fois pour les reboots — post-check DC obligatoire après chaque redémarrage.

---

## Quand l'utiliser ?

- Tu commences une intervention de maintenance planifiée (patching, mise à jour, reboot)
- Tu dois répondre à une intervention terrain non planifiée (panne, alerte, support N2/N3)
- Tu as besoin d'un script PowerShell production-ready compatible RMM
- Tu veux estimer la durée d'une fenêtre de maintenance pour un devis ou une planification
- Tu dois générer les livrables CW en fin d'intervention (Note Interne, Discussion, Email)
- Tu veux créer un brief KB après résolution d'un incident complexe

---

## Les commandes principales

### `/start` — Nouvelle intervention

Point d'entrée pour toute intervention. Fournir le numéro de billet et le contexte.

**Usage :**
```
/start #54321 — Patching mensuel serveurs EC Solutions
```

**Ce que tu obtiens :**
- Triage catégorisé (NOC / MAINTENANCE / SUPPORT / etc.) avec priorité P1-P4
- Plan d'action étape par étape
- Checklist pre-action
- Script PowerShell de precheck lecture seule — à exécuter avant d'agir

---

### `/start_maint` — Maintenance planifiée complète

Pour les fenêtres de maintenance avec plusieurs serveurs à patcher.

**Usage :**
```
/start_maint
Client : Otto Mfg
Serveurs : SRV-DC01, SRV-FILE01, SRV-SQL01, SRV-RDS01
Fenêtre : Ce soir 21h00-00h00
Billet : #54321
```

**Ce que tu obtiens :**
- Ordre de traitement recommandé (DEV/Test → Non-critiques → Critiques → DC en dernier)
- Script de precheck complet (uptime, RAM, disques, pending reboot)
- Nommage snapshots officiel : `@T54321_Preboot_SRV-DC01_SNAP_20260518_2100`
- Risques par serveur et plan de rollback
- Notice Teams prête à envoyer

**Nommage snapshots :**
```
@[BILLET]_[PHASE]_[SERVEUR]_SNAP_[YYYYMMDD_HHMM]
Exemple : @T54321_Preboot_SRV-DC01_SNAP_20260518_2100
```

---

### `/runbook [sujet]` — Runbook guidé par domaine

Runbooks opérationnels prêts à exécuter. Les runbooks sont chargés en temps réel depuis GitHub.

**Sujets disponibles :**
```
/runbook patching       — Patching Windows serveurs complet
/runbook dc             — Validation DC/AD avant et après maintenance
/runbook sql            — Validation SQL Server pré/post
/runbook rds            — Sessions RDS, drain mode
/runbook veeam          — État jobs Veeam et repositories
/runbook panne          — Redémarrage post-panne électrique (ordre critique)
/runbook ad             — Santé Active Directory complète
/runbook print          — Spooler + file impression bloquée
/runbook linux          — Santé Linux rapide
/runbook m365           — Exchange Online, Message Trace
/runbook health-check   — Santé serveurs générale
```

**Exemple :**
```
/runbook dc
```

**Ce que tu obtiens :**
```powershell
# Commandes prêtes à exécuter — exemple /runbook dc
dcdiag /test:replications /test:netlogons /test:fsmocheck /quiet
repadmin /replsummary
repadmin /showrepl
Get-ADDomainController -Filter * | Select-Object Name,IsGlobalCatalog,OperationMasterRoles
```

---

### `/script [description]` — Générer un script PowerShell

Script production-ready, compatible N-able / CW RMM, avec logs, gestion d'erreurs et structure imposée.

**Usage :**
```
/script audit espace disque sur tous les serveurs du domaine
```

```
/script désactiver les comptes AD inactifs depuis 90 jours — mode WhatIf d'abord
```

**Ce que tu obtiens :**
- Script PS avec `param()` en ligne 1 absolue
- Variables `$Billet`, `$Client`, `$Serveur` toujours présentes
- Logs dans `C:\IT_LOGS\[CATEGORIE]\`
- `Start-Transcript` + gestion `try/catch`
- Compatible RMM (pas de `Write-Host ""` — espace obligatoire)

**Structure garantie :**
```powershell
param(
    [string]$Billet  = "T[XXXXX]",
    [string]$Client  = "[NOM_CLIENT]",
    [string]$Serveur = $env:COMPUTERNAME
)
#Requires -Version 5.1
# === Script : AUDIT_Disques_AllServers_v1.ps1 ===
```

---

### `/check [résultats]` — Analyser des résultats

Coller les résultats de tes commandes — l'agent analyse et indique la prochaine action.

**Usage :**
```
/check
CPU avg : 94%
C: 3% libre
RAM utilisée : 91%
Service MSSQLSERVER : Running
Service Netlogon : Running
```

**Ce que tu obtiens :**
```
analyse:
  statut_global: PROBLÈME
  elements:
    - CPU 94% → ❌ Critique — pic anormal
    - C: 3% libre → ❌ Critique — nettoyage requis avant patch
    - RAM 91% → ⚠️ Attention — surveiller
prochaine_action: Nettoyer C: avant de procéder au patching
correctif: [script PS de nettoyage temporaires]
```

---

### `/estimé` — Estimer une fenêtre de maintenance

Pour planifier une fenêtre ou rédiger un devis client.

**Usage :**
```
/estimé
Client : DEF Corp
Tâche : Patching Windows — 6 serveurs dont 2 DC
Contexte : Dernière maintenance il y a 3 mois
```

**Ce que tu obtiens :**
- Liste des tâches avec durée min/max par tâche
- Durée totale + marge recommandée
- Prérequis et risques globaux
- Note client prête à envoyer (sans détails d'infrastructure)

---

### `/close` — Menu de clôture interactif

À utiliser en fin d'intervention. Affiche un menu — attend ton choix avant de générer.

**Usage :**
```
/close
```

**Menu affiché :**
```
[1] CW Note Interne       — audit trail technique complet
[2] CW Discussion         — résumé facturable client-safe
[3] Email client          — courriel formel
[4] Notice Teams          — annonce fin de maintenance
[5] /kb                   — brief capitalisation KB
[6] /db                   — enregistrement MSP-Assistant DB
[A] Tout (1+2+3+4+5+6)
```

> Important : l'agent attend ta réponse avant de générer quoi que ce soit. Répondre `1`, `2`, `A`, etc.

**Exemple Note Interne (choix 1) :**
```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #54321 — Otto Mfg — Patching mensuel 6 serveurs Windows.
Début : 21h00 | Fin : 23h45 | Durée : 2h45

21h00 — Precheck SRV-DC01 → CPU 12%, C: 42% libre, aucun pending reboot
21h15 — Snapshot SRV-DC01 créé → @T54321_Preboot_SRV-DC01_SNAP_20260518_2100
21h20 — Patching SRV-FILE01 — 14 KB installées → Reboot → Services OK
[...]
23h45 — dcdiag, repadmin → ✅ Réplication AD saine
```

---

### `/kb` — Brief pour IT-KnowledgeKeeper

Génère le YAML structuré à transmettre à @IT-KnowledgeKeeper pour créer un article KB.

**Usage :**
```
/kb
```

> Utiliser après `/close` — l'agent crée automatiquement le brief YAML avec toutes les infos de l'intervention.

---

## Flux de travail recommandé

### Maintenance planifiée

```
1. Ouvrir le billet CW
        ↓
2. /start_maint [contexte]
   → Ordre serveurs + risques + snapshots + notice Teams générés
        ↓
3. Exécuter les scripts precheck générés
        ↓
4. /check [résultats precheck]
   → Validation ou alerte avant de procéder
        ↓
5. Maintenance — snapshot → patch → reboot → /runbook dc
        ↓
6. /check [résultats postcheck]
   → Confirmation tout est OK
        ↓
7. /close → [A] Tout
   → Note Interne + Discussion + Email + Teams + KB générés
```

### Intervention terrain urgente

```
1. /start #[billet] — [symptôme]
   → Triage + plan + precheck lecture seule
        ↓
2. Exécuter les commandes → /check [résultats]
        ↓
3. Appliquer le correctif proposé
        ↓
4. /close → livrables CW
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| 1 serveur à la fois pour les reboots | Éviter d'impacter plusieurs services simultanément |
| DC toujours en dernier dans le patching | Le DC est la fondation — le patcher en dernier protège l'environnement |
| Snapshot AVANT chaque reboot critique | Rollback possible si problème post-patch |
| Post-check DC obligatoire après reboot | `dcdiag` + `repadmin /replsummary` — réplication AD doit être saine |
| Notice Teams dès que l'intervention est connue | Informer le NOC avant de commencer — pas après |
| ZÉRO IP dans les livrables clients | Discussion CW et Email client = jamais d'infrastructure visible |
| ZÉRO credentials dans les scripts | Passportal uniquement — jamais hardcodé |
| Escalade immédiate si : ransomware / DC inaccessible / perte données | Ne pas tenter de résoudre seul — appeler IT-SecurityMaster ou IT-Commandare-Infra |

---

## Questions fréquentes

**Q : Quelle différence avec IT-SysAdmin ?**
IT-MaintenanceMaster est l'agent principal de l'admin système — il couvre la maintenance planifiée ET les interventions terrain. IT-SysAdmin est plus généraliste pour les tâches d'administration courante. En cas de doute, utiliser IT-MaintenanceMaster.

**Q : Est-ce que je dois toujours faire un snapshot ?**
Pour toute maintenance critique (DC, SQL, RDS) : oui, obligatoirement. Pour les postes de travail ou serveurs non-critiques : recommandé mais non bloquant. L'agent te le signale automatiquement.

**Q : Comment savoir si le script généré est compatible avec mon RMM ?**
IT-MaintenanceMaster applique systématiquement les règles de compatibilité N-able/CW RMM : `param()` en ligne 1, `Write-Host " "` (espace, jamais vide), valeurs par défaut non vides. Si un script plante en RMM, utiliser `/check [message d'erreur]` — l'agent diagnostique et corrige.

**Q : Que faire si le postcheck révèle une anomalie après patch ?**
Coller les résultats dans `/check` — l'agent analyse et propose un correctif ou une escalade. Si l'anomalie concerne le DC ou AD : escalader vers @IT-Commandare-Infra sans attendre.

**Q : Peut-on redémarrer plusieurs serveurs en même temps ?**
Non. IT-MaintenanceMaster refusera et proposera l'ordre correct. Un serveur à la fois, avec validation entre chaque reboot.

**Q : Comment générer uniquement la Notice Teams sans le reste ?**
Dans `/close`, répondre `4` — seule la notice Teams sera générée.

---

*GUIDE_UTILISATION — IT-MaintenanceMaster v1.0 — MSP Intelligence AI — 2026-05-18*
