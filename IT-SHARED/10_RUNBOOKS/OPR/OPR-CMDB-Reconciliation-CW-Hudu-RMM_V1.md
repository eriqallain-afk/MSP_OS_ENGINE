# OPR-CMDB-Reconciliation-CW-Hudu-RMM_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-AssetMaster | @IT-OPS-DossierIA | @IT-Commandare-OPR
**Scope :** Réconciliation CMDB entre ConnectWise Manage, Hudu et N-able RMM

---

## Objectif

Garantir que chaque actif client est cohérent, complet et documenté dans les trois systèmes source (ConnectWise Manage, Hudu, N-able RMM). Détecter les actifs orphelins, les écarts de données et les licences non documentées avant qu'ils ne causent un incident ou un angle mort opérationnel.

---

## Déclencheurs

- Écart détecté entre le nombre d'actifs dans CW et dans le RMM pour un client
- Actif visible dans le RMM mais absent de la CMDB CW ou de Hudu
- Actif documenté dans Hudu mais disparu du RMM (machine décommissionnée sans mise à jour)
- Audit mensuel CMDB planifié (déclenchement automatique le 1er lundi du mois)
- Onboarding ou offboarding client — vérification complète obligatoire
- Signalement technicien : actif introuvable lors d'une intervention

---

## Prérequis

- Accès à ConnectWise Manage (Configurations → [Client])
- Accès à Hudu (Assets → [Client])
- Accès à la console N-able RMM (All Devices → filtre client)
- Accès à la console Backup (Veeam / Datto / autre selon client — voir Hudu)
- Accès à la console Monitoring NOC (N-able, LogicMonitor ou équivalent)
- Nom du client et liste des sites (ex. siège, filiales, remote)
- Ticket CW ouvert pour traçabilité (type : Maintenance / CMDB Audit)

---

## Procédure

### Étape 1 — Extraction des inventaires source

**1.1 — Exporter l'inventaire CW Manage (Configurations)**
```
CW Manage → Companies → [Client] → Configurations
Filtres : Status = Active, Type = tous
Exporter en CSV : nom, type, numéro de série, site, statut, date de création
```

**1.2 — Exporter l'inventaire Hudu**
```
Hudu → Assets → [Client]
Vérifier les catégories : Servers, Workstations, Network Devices, Printers, Software Licenses
Exporter ou copier la liste : nom, catégorie, IP, site, dernière modification
```

**1.3 — Exporter l'inventaire RMM N-able**
```
N-able → All Devices → Filtrer par Client
Colonnes à noter : Device Name, OS, Last Seen, IP, Site, Monitoring Status
Exporter CSV
```

**1.4 — Vérifier le backup et le monitoring**
```
Console Backup → [Client] → vérifier chaque machine active (dernier job, statut)
Console NOC → [Client] → vérifier que chaque serveur a une sonde active
```

---

### Étape 2 — Comparaison et détection des écarts

Créer un tableau de comparaison (Excel ou note CW) avec les colonnes suivantes :

| Nom actif | CW Manage | Hudu | RMM N-able | Backup | Monitoring | Delta |
|---|---|---|---|---|---|---|

**Catégories d'écarts à rechercher :**

| Type d'écart | Description | Priorité |
|---|---|---|
| Actif orphelin RMM | Présent dans RMM, absent de CW et/ou Hudu | Haute |
| Actif fantôme CW | Présent dans CW, absent du RMM depuis > 30 jours | Haute |
| Hudu non documenté | Actif actif sans article Hudu | Moyenne |
| Backup manquant | Machine active sans job backup configuré | Critique |
| Monitoring absent | Serveur actif sans sonde NOC | Critique |
| Licence orpheline | Licence dans CW sans actif associé | Moyenne |
| OS EOL | OS en fin de vie encore actif — voir OPR-EOL-EOS-RiskRegister | Haute |
| Données manquantes | Numéro de série, site, type, IP non renseignés | Basse |

---

### Étape 3 — Documentation des écarts dans CW

```
CW Manage → Ticket [ID] → Note Interne

Phrase d'ouverture OBLIGATOIRE :
"Prise de connaissance de la demande et consultation de la documentation du client."

Corps de la note :
CMDB AUDIT — [CLIENT] — [DATE]
========================================
Systèmes comparés : CW Manage / Hudu / N-able RMM
Nombre d'actifs CW   : [X]
Nombre d'actifs RMM  : [X]
Nombre d'actifs Hudu : [X]

ÉCARTS DÉTECTÉS :
1. [Nom actif] — absent de Hudu — action : créer article
2. [Nom actif] — absent du RMM depuis 45 jours — action : confirmer décommission
3. [Nom actif] — backup non configuré — action : ticket maintenance urgent
4. [Nom licence] — orpheline dans CW — action : associer ou archiver

ACTIONS ASSIGNÉES :
- [Technicien / Agent] : [action] — ETA : [date]
```

---

### Étape 4 — Correction et mise à jour

**Pour chaque écart, selon la catégorie :**

**Actif orphelin RMM → créer la Configuration dans CW :**
```
CW → Companies → [Client] → Configurations → + Add
Champs obligatoires : Name, Type, Serial Number, Status, Site, Manufacturer, Model
```

**Actif fantôme CW → vérifier avant archivage :**
```
1. Confirmer avec le client ou le technicien responsable que la machine est décommissionnée
2. Si confirmé : Status = Inactive dans CW + archiver l'article Hudu (ne pas supprimer)
3. Note CW : raison, date de décommission, demandeur
```

**Hudu non documenté → créer l'article :**
```
Hudu → [Client] → Assets → + New Asset
Template recommandé : Server / Workstation / Network Device selon type
Renseigner : IP, OS, rôle, site, credentials (vault Hudu), date d'installation
```

**Backup manquant → escalader immédiatement :**
```
→ Créer ticket Maintenance séparé — priorité P2
→ Assigner à @IT-BackupDRMaster
→ Ne pas fermer le ticket CMDB avant résolution
```

**Monitoring absent → créer la sonde :**
```
N-able → [Client] → Add Device → configurer les checks standard
Ou escalader à @IT-MonitoringMaster si template personnalisé requis
```

---

### Étape 5 — Validation finale et clôture

```
□ Tableau de comparaison complet (CW / Hudu / RMM / Backup / Monitoring)
□ Tous les écarts documentés dans la Note Interne CW
□ Actions assignées avec propriétaire et ETA
□ Actifs critiques (backup, monitoring) traités en priorité
□ CW Configurations mis à jour (actifs corrects, inactifs archivés)
□ Hudu à jour pour tous les actifs actifs
□ Ticket CW fermé uniquement quand tous les écarts ont un owner et une ETA
```

---

## Commandes / Scripts

### Vérifier les machines RMM via PowerShell (N-able API — si activé)
```powershell
# Prérequis : module N-able API configuré ou export CSV manuel
# Comparaison des noms de machines entre deux exports CSV

param(
    [Parameter(Mandatory)][string]$CWExportPath,   # chemin vers le CSV CW
    [Parameter(Mandatory)][string]$RMMExportPath   # chemin vers le CSV RMM
)

$cw  = Import-Csv $CWExportPath  | Select-Object -ExpandProperty Name
$rmm = Import-Csv $RMMExportPath | Select-Object -ExpandProperty "Device Name"

$onlyInCW  = $cw  | Where-Object { $_ -notin $rmm }
$onlyInRMM = $rmm | Where-Object { $_ -notin $cw  }

Write-Host ""
Write-Host "=== Actifs UNIQUEMENT dans CW (potentiellement décommissionnés) ==="
$onlyInCW | ForEach-Object { Write-Host "  - $_" }

Write-Host ""
Write-Host "=== Actifs UNIQUEMENT dans RMM (absents de CW) ==="
$onlyInRMM | ForEach-Object { Write-Host "  - $_" }

Write-Host ""
Write-Host "Total CW  : $($cw.Count)  |  Total RMM : $($rmm.Count)"
Write-Host "Orphelins CW : $($onlyInCW.Count)  |  Orphelins RMM : $($onlyInRMM.Count)"
```

### Vérifier les actifs sans numéro de série dans CW (requête manuelle)
```
CW → Reports → Configurations → Filtrer : Serial Number = vide, Status = Active
Exporter → ajouter les numéros de série manquants depuis Hudu ou physiquement
```

---

## Livrables attendus

| Livrable | Destination | Audience |
|---|---|---|
| Tableau de comparaison CW/Hudu/RMM | Note Interne CW | Techniciens internes |
| Liste des écarts avec priorités et owners | Note Interne CW | Techniciens + QAMaster |
| Tickets de correction créés (backup, monitoring) | CW Manage | Techniciens |
| Hudu mis à jour | Hudu [Client] | Tous les agents |
| CW Configurations mis à jour | CW Manage | Facturation + Opérations |

---

## Critères de clôture (DoD)

- [ ] Les trois inventaires (CW, Hudu, RMM) ont été comparés
- [ ] Tous les écarts sont documentés dans la Note Interne CW
- [ ] Chaque écart a un propriétaire et une ETA de correction
- [ ] Les écarts critiques (backup, monitoring) ont un ticket séparé ouvert
- [ ] Aucun actif actif n'est sans monitoring ni sans backup (ou exception documentée)
- [ ] Aucune information confidentielle (IP, credentials, logs) dans les communications client
- [ ] Hudu à jour pour tous les actifs actifs du périmètre audité

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| Machine active sans backup depuis > 48h | @IT-BackupDRMaster | Immédiat — P2 |
| Serveur critique sans monitoring | @IT-MonitoringMaster | Immédiat — P2 |
| OS EOL détecté avec risque sécurité | @IT-SecurityMaster + @IT-AssetMaster | 24h |
| Écart non résolu depuis > 5 jours | @IT-Commandare-OPR | Escalade |
| > 20% des actifs en écart | @IT-Commandare-OPR + EA | Revue de compte requise |

---

## Notes MSP

- **Fréquence recommandée :** mensuel pour tous les clients actifs, trimestriel pour les clients light
- **Priorité de correction :** Backup manquant > Monitoring absent > Hudu incomplet > Données CW manquantes
- **Ne jamais supprimer un actif dans CW ou Hudu** — toujours archiver/inactiver avec date et raison
- **Licences orphelines :** signaler au gestionnaire de compte — peut impacter la facturation
- **Temps estimé :** 30–90 min selon la taille du client (< 20 actifs : 30 min / 20–100 actifs : 60–90 min)
- Ce runbook est déclenché automatiquement dans le cadre du **OPR-Monthly-Client-OpsPack** pour chaque client

---

*OPR-CMDB-Reconciliation-CW-Hudu-RMM_V1 — IT MSP Intelligence Platform — 2026-05-23*
