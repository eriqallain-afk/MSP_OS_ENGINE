# INFRA-SRV-HealthCheck_Template_V1
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

## 1. INFORMATIONS SYSTÈME

### Général
- **OS Version:** [Windows Server 2022 / 2019 / 2016]
- **Build:** [20348.xxx]
- **Architecture:** [x64]
- **Domain:** [DOMAIN.LOCAL]
- **Uptime:** [X jours, X heures]
- **Last Reboot:** [DATE/TIME]

### Hardware (si applicable)
- **Fabricant:** [Dell / HP / etc.]
- **Modèle:** [PowerEdge R640 / etc.]
- **CPU:** [X cores @ X GHz]
- **RAM:** [X GB]
- **RAID Controller:** [Type + Status]

---

## 2. ESPACE DISQUE

| Lettre | Label | Total | Utilisé | Libre | % Libre | Status |
|--------|-------|-------|---------|-------|---------|---------|
| C: | OS | X GB | X GB | X GB | X% | 🟢/🟡/🔴 |
| D: | Data | X GB | X GB | X GB | X% | 🟢/🟡/🔴 |
| E: | Logs | X GB | X GB | X GB | X% | 🟢/🟡/🔴 |

**Seuils:**
- 🟢 > 20% libre
- 🟡 10-20% libre
- 🔴 < 10% libre

**Actions requises:**
- [ ] Aucune
- [ ] Nettoyage requis (volume X)
- [ ] Extension disque requise (volume X)

---

## 3. PERFORMANCE

### CPU
- **Utilisation moyenne (7j):** [X]%
- **Utilisation max (7j):** [X]%
- **Processus top consommateur:** [nom processus - X%]

**Status:** 🟢 < 70% / 🟡 70-85% / 🔴 > 85%

### Mémoire
- **RAM installée:** [X GB]
- **RAM utilisée:** [X GB]
- **RAM disponible:** [X GB]
- **% Utilisation:** [X]%
- **Page File Usage:** [X MB / X MB]

**Status:** 🟢 < 80% / 🟡 80-90% / 🔴 > 90%

### Réseau
- **NICs actives:** [X]
- **Throughput moyen:** [X Mbps]
- **Packets errors:** [X]

**Status:** 🟢 OK / 🟡 Warnings / 🔴 Errors

---

## 4. SERVICES CRITIQUES

| Service | Display Name | Status | Startup | Action |
|---------|--------------|--------|---------|--------|
| W32Time | Windows Time | Running | Automatic | ✓ OK |
| Dnscache | DNS Client | Running | Automatic | ✓ OK |
| Netlogon | Netlogon | Running | Automatic | ✓ OK |
| [service] | [nom] | [status] | [type] | [action] |

**Services arrêtés (non désirés):**
- [Nom service - raison si connu]

**Actions:**
- [ ] Redémarrer services arrêtés
- [ ] Investiguer cause arrêt

---

## 5. EVENT LOGS (Dernières 24h)

### Erreurs système (System Log)
| Time | Source | Event ID | Message |
|------|--------|----------|---------|
| [TIME] | [Source] | [ID] | [Brief msg] |

**Nombre total erreurs System:** [X]

### Erreurs application (Application Log)
| Time | Source | Event ID | Message |
|------|--------|----------|---------|
| [TIME] | [Source] | [ID] | [Brief msg] |

**Nombre total erreurs Application:** [X]

### Erreurs critiques
- [ ] Aucune erreur critique
- [ ] Erreurs critiques détectées (voir détails ci-dessus)

---

## 6. MISES À JOUR WINDOWS

### Status
- **Dernière vérification:** [DATE/TIME]
- **Dernière installation:** [DATE]
- **Patches en attente:** [X]
- **Reboot requis:** [Oui/Non]

### Patches récents (30 derniers jours)
| KB | Titre | Date installation |
|----|-------|-------------------|
| KB5034441 | Security Update | 2024-01-15 |
| [KB] | [Titre] | [Date] |

**Actions:**
- [ ] Pas d'action requise
- [ ] Installer patches en attente
- [ ] Planifier reboot pour appliquer patches

---

## 7. BACKUP STATUS

### Configuration
- **Solution:** [VEEAM / Windows Backup / Azure Backup / Autre]
- **Type:** [Full + Incremental / Differential]
- **Rétention:** [X jours]
- **Destination:** [Path/URL]

### Derniers backups
| Date | Type | Taille | Durée | Status |
|------|------|--------|-------|--------|
| [DATE] | Full | X GB | Xh Xm | ✓ Success |
| [DATE] | Incr | X GB | Xm | ✓ Success |

**Backups ratés (7 derniers jours):**
- [ ] Aucun
- [ ] [DATE - Raison]

**Actions:**
- [ ] Pas d'action
- [ ] Investiguer backup raté
- [ ] Test restore requis

---

## 8. SÉCURITÉ

### Antivirus/Endpoint Protection
- **Solution:** [Windows Defender / Symantec / Autre]
- **Version:** [X.X.X]
- **Dernière mise à jour définitions:** [DATE/TIME]
- **Dernière analyse complète:** [DATE]
- **Menaces détectées (30j):** [X]

**Actions:**
- [ ] Rien à signaler
- [ ] Forcer mise à jour définitions
- [ ] Investiguer menaces

### Firewall
- **Status:** [Activé/Désactivé]
- **Profil actif:** [Domain / Private / Public]
- **Règles inbound:** [X]
- **Règles outbound:** [X]

### Comptes locaux
| Compte | Status | Dernier login | Action |
|--------|--------|---------------|--------|
| Administrator | Enabled/Disabled | [DATE] | [Action] |
| [compte] | [status] | [date] | [action] |

**Comptes inutilisés à désactiver:**
- [Liste comptes]

---

## 9. RÔLES & FONCTIONNALITÉS

### Rôles installés
- [ ] Active Directory Domain Services
- [ ] DNS Server
- [ ] DHCP Server
- [ ] File Services
- [ ] IIS
- [ ] Hyper-V
- [ ] SQL Server
- [ ] [Autre]

### Applications tierces
| Application | Version | Status |
|-------------|---------|--------|
| [App] | [X.X] | Running/Stopped |

---

## 10. RÉSEAU & CONNECTIVITÉ

### Configuration IP
| NIC | IP Address | Subnet | Gateway | DNS |
|-----|------------|--------|---------|-----|
| Ethernet0 | [IP_CLIENTE] | 255.255.255.0 | [IP_CLIENTE] | [IP_CLIENTE], [IP_CLIENTE] |

### Tests connectivité
- [ ] Ping gateway: OK / FAILED
- [ ] Ping DNS: OK / FAILED
- [ ] Ping DC: OK / FAILED
- [ ] Internet: OK / FAILED
- [ ] Résolution DNS: OK / FAILED

**Commandes exécutées:**
```cmd
ping [IP_CLIENTE] -n 4
ping 8.8.8.8 -n 4
nslookup google.com
```

---

## 11. SPÉCIFIQUE AU RÔLE

### [Si File Server]
- **Shares actifs:** [X]
- **Connexions actives:** [X utilisateurs]
- **Quotas:** [Status]

### [Si SQL Server]
- **Instance:** [MSSQLSERVER / nom]
- **Databases:** [X]
- **Status:** [Online/Offline]
- **Dernier backup:** [DATE]
- **Jobs failed:** [X]

### [Si IIS]
- **Sites web:** [X]
- **App Pools:** [X]
- **Sites down:** [X]

### [Si Hyper-V]
- **VMs totales:** [X]
- **VMs running:** [X]
- **VM checkpoints:** [X]
- **Storage usage:** [X GB / X GB]

---

## 12. OBSERVATIONS & RECOMMANDATIONS

### Problèmes identifiés
1. **[Titre problème 1]**
   - Sévérité: 🔴 Critique / 🟡 Important / 🟢 Mineur
   - Impact: [Description]
   - Recommandation: [Action]

2. **[Titre problème 2]**
   - Sévérité: 🔴/🟡/🟢
   - Impact: [Description]
   - Recommandation: [Action]

### Optimisations suggérées
- [Suggestion 1]
- [Suggestion 2]

### Actions à planifier
- [ ] [Action 1 - échéance]
- [ ] [Action 2 - échéance]

---

## 13. CONCLUSION

### Status global
🟢 **Healthy** / 🟡 **Attention required** / 🔴 **Critical issues**

### Prochaine revue
**Date:** [DATE]

### Approbation
- **Technicien:** [NOM] - [DATE]
- **Superviseur:** [NOM] - [DATE]

---

## ANNEXE: Commandes utilisées

```powershell
# Informations système
Get-ComputerInfo | Select OSName, OSVersion, CsName, WindowsVersion, OsUptime

# Espace disque
Get-PSDrive -PSProvider FileSystem | Select Name, @{N="Total(GB)";E={[math]::Round($_.Used + $_.Free)/1GB,2}}, @{N="Used(GB)";E={[math]::Round($_.Used/1GB,2)}}, @{N="Free(GB)";E={[math]::Round($_.Free/1GB,2)}}, @{N="Free%";E={[math]::Round(($_.Free/($_.Used+$_.Free))*100,2)}}

# Services
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select Name, DisplayName, Status

# Event logs errors (dernières 24h)
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddHours(-24) | Select TimeGenerated, Source, EventID, Message

# Patches récents
Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-30)} | Sort InstalledOn -Descending | Select HotFixID, Description, InstalledOn

# Performance counters
Get-Counter '\Processor(_Total)\% Processor Time', '\Memory\Available MBytes' | Select -ExpandProperty CounterSamples

# Réseau
Get-NetAdapter | Select Name, Status, LinkSpeed
Test-NetConnection -ComputerName 8.8.8.8 -InformationLevel Detailed
```
