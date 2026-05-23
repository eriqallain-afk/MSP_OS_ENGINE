# IT-MonitoringMaster — Knowledge Pack v1

> Pack complet supervision MSP : KPIs, seuils d'alerte, runbooks réponse, N-Able.

---

## 1. SEUILS D'ALERTE — Standard MSP

### Serveurs Windows

| Métrique | Avertissement | Critique | Action |
|---------|--------------|---------|--------|
| CPU usage | > 80% pendant 15 min | > 95% pendant 5 min | Identifier process, escalade TECH |
| RAM usage | > 85% | > 95% | Analyser mémoire, redémarrer service si leak |
| Disque C: libre | < 15% | < 5% | Nettoyage / extension / alerte OPR |
| Disque Data libre | < 20% | < 10% | Nettoyage / expansion / RFC INFRA |
| Uptime service critique | N/A | Service arrêté | Tentative redémarrage auto → alerter NOC |
| Ping latence | > 100ms | > 500ms ou perte | Vérifier réseau + charge serveur |
| Événements erreur (Event Log) | > 10/heure | > 50/heure | Analyser Event ID |
| Reboot non planifié | N/A | Toute occurrence | Vérifier Event 1074/6008/41 |

### Réseau

| Métrique | Avertissement | Critique | Action |
|---------|--------------|---------|--------|
| Utilisation bande passante | > 70% | > 90% | Analyser trafic, QoS, ISP upgrade ? |
| Latence WAN | > 100ms | > 300ms | Tester lien ISP, failover ? |
| Perte paquets | > 1% | > 5% | Test câble, switch port, ISP |
| Interface down | N/A | Interface critique down | Vérifier câble, switch, LACP |
| Uptime firewall | N/A | Firewall down | URGENCE — isolation réseau |

### Backup

| Métrique | Avertissement | Critique | Action |
|---------|--------------|---------|--------|
| Backup en échec | 1 échec | 2 échecs consécutifs | Vérifier espace, logs Veeam/Datto |
| Durée backup anormale | > 150% durée normale | > 300% | Vérifier charge réseau + stockage |
| Backup manqué | Aucune exécution | > 24h sans backup | Vérifier planification + service |
| Espace stockage backup | < 20% libre | < 10% libre | Nettoyage / extension |

---

## 2. CHECKLIST — Configuration Monitoring Nouveau Client

```
ONBOARDING MONITORING — Nouveau client
─────────────────────────────────────
RMM (N-Able)
[ ] Agents RMM installés sur tous les serveurs
[ ] Agents RMM installés sur postes (si inclus au contrat)
[ ] Groupes organisés par client / site / criticité
[ ] Politiques de monitoring appliquées (serveurs / postes)
[ ] Alertes email configurées (NOC + technicien responsable)

SERVEURS CRITIQUES
[ ] Seuils CPU / RAM / Disque configurés
[ ] Services critiques monitorés (AD, DNS, DHCP, Exchange, SQL, Backup)
[ ] Monitoring Event Log (IDs critiques : 1074, 6008, 41, 4625, 7034)
[ ] SNMP configuré (si équipements réseau)
[ ] Ping monitoring (serveurs + équipements réseau)

BACKUP
[ ] Monitoring jobs Veeam / Datto configuré
[ ] Alertes échec backup → NOC immédiat
[ ] Rapport hebdomadaire backup activé

DOCUMENTATION
[ ] Inventaire assets dans CMDB (N-Able → CW sync)
[ ] Contacts alertes validés avec client
[ ] Fenêtres de maintenance définies (pas d'alertes hors heures OK)
[ ] Tableau de bord client créé
```

---

## 3. RUNBOOK — Réponse Alerte Type

### CPU > 95% (serveur critique)

```
ALERTE CPU CRITIQUE
─────────────────────────────────────
1. Se connecter en RDP / remote au serveur
2. Ouvrir Task Manager → onglet Processes → trier par CPU
3. Identifier le processus consommateur

SI processus connu (SQL, Exchange, IIS) :
  → Vérifier logs applicatifs pour cause (requête longue, traffic spike)
  → Redémarrer service si gelé
  → Documenter dans CW

SI processus inconnu ou suspect :
  → NE PAS tuer sans analyse
  → Copier nom + PID
  → Escalade vers SecurityMaster (possible malware)
  → Notifier CTO si serveur critique

PowerShell : Get-Process | Sort CPU -Desc | Select -First 10
```

### Disque < 5% libre

```
ALERTE ESPACE DISQUE CRITIQUE
─────────────────────────────────────
1. Identifier le volume en cause
2. PowerShell : Get-ChildItem C:\ -Recurse | Sort Length -Desc | Select -First 20

Vérifications rapides :
  → C:\Windows\Temp (vider si > 5 GB)
  → C:\Users\*\AppData\Local\Temp (vider)
  → Logs IIS / SQL (archiver ou purger)
  → Fichiers dump .dmp (supprimer après analyse)
  → Corbeille (vider)

Si insuffisant :
  → Identifier dossier principal volumineux → analyser
  → RFC pour extension disque / migration data
  → Informer OPR + client si serveur de fichiers
```

---

## 4. RÉFÉRENCE — Event IDs Windows Critiques

| Event ID | Source | Signification | Priorité |
|---------|--------|--------------|---------|
| **41** | Kernel-Power | Reboot inattendu (panne d'alimentation / BSOD) | S1 |
| **6008** | EventLog | Arrêt système inattendu | S1 |
| **1074** | User32 | Reboot initié par application / utilisateur | S2 info |
| **7034** | Service Control | Service s'est arrêté de façon inattendue | S1/S2 |
| **4625** | Security | Échec de connexion (brute force possible) | S2 |
| **4624** | Security | Connexion réussie (surveiller hors heures) | Info |
| **4740** | Security | Compte verrouillé | S2 |
| **1102** | Security | Journal des événements effacé (suspicion!) | S1 |
| **4015** | DNS-Server | Erreur zone DNS critique | S1 |
| **2042** | NTDS Replication | Réplication AD arrêtée (tombstone) | S0 |
| **9** / **11** / **15** | Disk | Erreurs disque physique | S1 |

---

## 5. KPIs MONITORING MSP

| KPI | Définition | Cible | Fréquence rapport |
|-----|-----------|-------|------------------|
| **Alert-to-Incident Ratio** | % alertes qui deviennent incidents réels | > 70% (< 30% faux positifs) | Mensuel |
| **MTTD** | Temps moyen détection incident | < 5 min (S0/S1) | Par incident |
| **Uptime clients** | Disponibilité services critiques monitorés | ≥ 99.5% | Mensuel |
| **Alertes actives / client** | Nb alertes ouvertes par client | < 5 alertes actives | Hebdo |
| **Coverage** | % assets clients monitorés | 100% actifs | Trimestriel |
| **Faux positifs supprimés** | Nb règles d'alerte optimisées | ↑ progressivement | Mensuel |

---

## 6. TABLEAU DE BORD — Shift NOC

```
DASHBOARD MONITORING — Début de quart
─────────────────────────────────────
☐ Alertes actives non ACK : ___
☐ Clients avec alertes ouvertes > 4h : ___
☐ Backups en échec (dernières 24h) : ___
☐ Services DOWN (critiques) : ___
☐ Servers avec espace disque < 10% : ___
☐ Incidents S0/S1 actifs : ___

ACTION SI > 0 alerte critique :
→ Créer ticket CW
→ Notifier technicien responsable client
→ Escalade NOC si S0/S1
```

---

> Voir aussi : IT__Severity_Matrix.md | RUNBOOK__IT_NOC_COMMAND_CENTER.md
