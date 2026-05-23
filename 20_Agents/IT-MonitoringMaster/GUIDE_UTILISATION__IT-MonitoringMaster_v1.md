# Guide d'utilisation — @IT-MonitoringMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP — Équipe NOC
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-MonitoringMaster ?

**IT-MonitoringMaster est l'expert supervision du NOC MSP.**

Il analyse les alertes RMM, configure les seuils KPI, produit des rapports de santé infrastructure, et distingue les vraies alertes des faux positifs. Il travaille avec N-able, Datto RMM, PRTG et Zabbix.

| Besoin | Ce que fait IT-MonitoringMaster |
|---|---|
| Alerte RMM reçue | Classification P1-P4, diagnostic probable, actions immédiates |
| Seuils à configurer | Recommandations KPI par type d'actif (serveur, réseau, backup) |
| Faux positif récurrent | Analyse + recommandation d'ajustement du seuil documenté |
| Rapport de santé mensuel | Uptime, top alertes, tendances CPU/disk/réseau, gaps coverage |
| Corrélation d'alertes | Distinguer alerte isolée d'une tendance systémique |

> IT-MonitoringMaster ne clôture pas les incidents — il analyse et route. Les interventions de remédiation passent par IT-MaintenanceMaster ou l'agent spécialisé selon le domaine.

---

## Quand l'utiliser ?

- Tu reçois une alerte depuis N-able, Datto RMM, PRTG ou Zabbix et tu dois savoir si c'est réel
- Une alerte revient plusieurs fois en peu de temps (faux positif possible ou tendance)
- Tu dois configurer ou ajuster les seuils de monitoring d'un nouveau client
- Tu veux générer le rapport de santé mensuel de l'infrastructure
- Tu dois identifier les assets sans monitoring actif (gap coverage)
- Une alerte P1 vient d'arriver — tu as besoin de l'escalader correctement en moins de 5 min

---

## Les commandes principales

### `/alerte` — Analyser une alerte RMM

La commande principale. Coller l'alerte telle quelle — l'agent la classifie et propose les actions immédiates.

**Usage :**
```
/alerte
Source : N-able
Type : CPU High
Serveur : SRV-APP01
Client : Otto Inc
Valeur : 97% CPU (avg 15 min)
Heure : 2026-05-18 02h34
Seuil configuré : Warning 80% / Critical 95%
```

**Ce que tu obtiens :**
- `classification` : type d'alerte (CPU / disk / réseau / service / sécurité)
- `sévérité` : P1 / P2 / P3 / P4
- `diagnostic_probable` : top 2 causes probables
- `actions_immédiates` : commandes lecture seule à exécuter pour valider
- `escalade_vers` : agent cible ou équipe si P1/P2
- `seuils_contexte` : seuil déclenché vs seuil recommandé MSP

**Exemple de script de vérification généré :**
```powershell
param([string]$Billet = "T[XXXXX]", [string]$Serveur = $env:COMPUTERNAME)
#Requires -Version 5.1

# CPU (15 min avg)
$cpu = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
Write-Host ("CPU avg : {0}%" -f $cpu) -ForegroundColor $(if ($cpu -gt 95) {"Red"} elseif ($cpu -gt 80) {"Yellow"} else {"Green"})

# RAM
$os = Get-CimInstance Win32_OperatingSystem
$ramPct = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 0)
Write-Host ("RAM utilisee : {0}%" -f $ramPct) -ForegroundColor $(if ($ramPct -gt 95) {"Red"} elseif ($ramPct -gt 85) {"Yellow"} else {"Green"})

# Disques
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $pct = [math]::Round($_.FreeSpace / $_.Size * 100, 0)
    Write-Host ("Disque {0}: {1}% libre" -f $_.DeviceID, $pct) -ForegroundColor $(if ($pct -lt 10) {"Red"} elseif ($pct -lt 20) {"Yellow"} else {"Green"})
}

# Services critiques
"ADWS","DNS","Netlogon","NTDS","W32Time","WinRM","MSSQLSERVER","VeeamBackupSvc" | ForEach-Object {
    $s = Get-Service $_ -EA SilentlyContinue
    if ($s) { Write-Host (" Svc {0,-22} {1}" -f $_, $s.Status) -ForegroundColor $(if ($s.Status -ne "Running") {"Red"} else {"Green"}) }
}
```

---

### `/seuils [type]` — Recommandations KPI

Pour configurer ou valider les seuils de monitoring d'un actif.

**Usage :**
```
/seuils serveur windows
```

```
/seuils backup veeam
```

```
/seuils réseau lan
```

**Ce que tu obtiens — seuils MSP recommandés :**

| Métrique | Warning | Critical | Fréquence polling |
|---|---|---|---|
| CPU serveur (avg 15 min) | 80% | 95% | 5 min |
| RAM serveur | 85% | 95% | 5 min |
| Disque libre | 20% | 10% | 15 min |
| Disk growth rate | >5 GB/j | >15 GB/j | 1h |
| Services critiques (AD, SQL, IIS) | Dégradé | Arrêté | 2 min |
| Latence réseau LAN | >20 ms | >100 ms | 5 min |
| Latence WAN | >50 ms | >200 ms | 5 min |
| Backup last success | >24h | >48h | 1h |
| Certificats SSL expiry | 30 jours | 7 jours | 24h |
| Patch compliance | <90% | <75% | 24h |

---

### `/rapport` — Rapport de santé infrastructure

Pour le cycle mensuel ou à la demande d'un client.

**Usage :**
```
/rapport
Client : Otto Mfg
Période : Mai 2026
Données disponibles : [coller les données RMM ou indiquer les actifs]
```

**Ce que tu obtiens :**
- Uptime par service et asset (%)
- Top alertes du mois par fréquence
- Tendances : CPU, disk, réseau
- Assets sans monitoring actif (gap coverage)
- Recommandations d'optimisation des seuils
- Format prêt à partager avec @IT-ReportMaster

---

### `/config [actif]` — Configuration monitoring

Pour un nouveau client ou un actif non encore configuré.

**Usage :**
```
/config serveur windows server 2022 — rôle domain controller
```

```
/config switch réseau — Cisco Catalyst 2960
```

**Ce que tu obtiens :**
- Seuils recommandés par type d'actif
- Fréquence de polling optimale
- Liste des alertes critiques à configurer en priorité
- Alertes informatives vs critiques
- Maintenance windows à prévoir (patching, backup)

---

### `/close` — Clôture CW

Menu de clôture après analyse d'une alerte. Attend ton choix avant de générer.

**Usage :**
```
/close
```

**Ce que tu obtiens :**
```
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout
```

**Exemple CW Note Interne (choix 1) :**
```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #55123 — Otto Inc — Alerte monitoring CPU critique SRV-APP01
02h34 — Alerte N-able reçue : CPU 97% avg 15 min — seuil critique 95%
02h36 — Diagnostic : processus IIS en boucle — service W3SVC
02h40 — Action : redémarrage pool applicatif [POOL-NOM]
02h45 — Validation : CPU redescendu à 18% — services OK
Statut : ✅ Résolu
```

---

## Flux de travail recommandé

### Alerte reçue depuis le RMM

```
1. Alerte reçue (N-able / Datto RMM / PRTG)
        ↓
2. /alerte [coller l'alerte complète]
   → Classification P1-P4 + diagnostic probable + actions immédiates
        ↓
3. Exécuter les commandes de diagnostic proposées (lecture seule)
        ↓
4. P1/P2 confirmé ?
   OUI → Escalade immédiate vers @IT-Commandare-NOC (< 5 min)
   NON → Appliquer le correctif proposé ou ajuster le seuil
        ↓
5. /close → Note Interne + Discussion
```

### Faux positif récurrent

```
1. /alerte [alerte récurrente]
   → L'agent identifie le faux positif et recommande l'ajustement
        ↓
2. Valider l'ajustement de seuil dans le RMM
        ↓
3. Documenter dans /close → Note Interne
   (ne pas supprimer l'alerte — ajuster le seuil)
```

### Rapport de santé mensuel

```
1. Rassembler les données du mois (export RMM ou liste actifs)
        ↓
2. /rapport [données période]
        ↓
3. Transmettre le rapport à @IT-ReportMaster pour inclusion dans le rapport client
        ↓
4. Signaler les gaps coverage à combler au prochain cycle
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| JAMAIS acquitter une alerte P1 sans investigation | Une alerte P1 non investiguée = incident masqué |
| Alerte isolée ≠ tendance récurrente | Distinguer avant d'agir — une seule alerte peut être un pic ponctuel |
| Lecture seule d'abord | Collecter et confirmer avant de modifier des seuils ou des configs |
| Faux positif → ajuster le seuil, pas supprimer l'alerte | Supprimer une alerte = supprimer la visibilité |
| Escalade P1 vers @IT-Commandare-NOC en < 5 min | Pas de tentative de résolution solo sur un P1 |
| ZÉRO credentials dans les livrables | Passportal uniquement — jamais dans une Note CW ou un email |
| [À CONFIRMER] si info non vérifiable | Zéro invention — mieux vaut signaler un doute que donner une info fausse |

---

## Questions fréquentes

**Q : Comment distinguer une vraie alerte d'un faux positif ?**
IT-MonitoringMaster analyse le contexte : fréquence de l'alerte, heure, corrélation avec d'autres alertes du même actif. Une alerte CPU à 98% sur 2 min sans historique similaire = faux positif probable. La même alerte sur 30 min avec disk à 95% = P1 réel. L'agent te donne son diagnostic avec niveau de confiance.

**Q : Quelle différence avec @IT-MaintenanceMaster pour les alertes ?**
IT-MonitoringMaster analyse et classe. IT-MaintenanceMaster exécute la remédiation. Flux typique : MonitoringMaster classe l'alerte → route vers MaintenanceMaster ou l'agent spécialisé → MaintenanceMaster intervient et ferme le billet.

**Q : Que faire si le seuil recommandé ne correspond pas au comportement normal du client ?**
Documenter le contexte client dans `/config` — IT-MonitoringMaster adapte les recommandations. Un serveur SQL qui tourne à 85% CPU en permanence ne doit pas avoir le même seuil qu'un serveur de fichiers.

**Q : Comment traiter une alerte backup (Veeam/Datto) reçue dans N-able ?**
Utiliser `/alerte` pour la classification initiale. Si l'alerte est confirmée P2 ou P3, IT-MonitoringMaster te route vers @IT-BackupDRMaster qui gère le triage backup.

**Q : Peut-on modifier les seuils RMM directement depuis l'agent ?**
Non — IT-MonitoringMaster recommande les ajustements. La modification dans N-able ou Datto RMM reste manuelle. L'agent produit le YAML de configuration à appliquer.

---

*GUIDE_UTILISATION — IT-MonitoringMaster v1.0 — MSP Intelligence AI — 2026-05-18*
