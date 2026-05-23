# AGENT BOOK — Tier Pro
**ID :** AGENT_BOOK_Pro_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Agents couverts :** IT-Assistant-N3 · IT-MaintenanceMaster · IT-MonitoringMaster · IT-NOCDispatcher · IT-ReportMaster · IT-NetworkMaster · IT-CloudMaster · IT-BackupDRMaster · IT-SecurityMaster

---

## Ce tier comprend

Le Pro ajoute la couche technique avancée et spécialisée : N3, maintenance planifiée, monitoring, dispatch NOC, réseau, cloud M365/Azure, sauvegarde/DR et cybersécurité. Les agents de ce tier produisent des livrables CW structurés par domaine, avec validation pré/post obligatoire et escalade documentée.

| Agent | Rôle | Audience |
|---|---|---|
| IT-Assistant-N3 | Copilote N3 — diagnostics avancés, RCA | N3 / Tech senior |
| IT-MaintenanceMaster | Copilote maintenance planifiée | Technicien maintenance |
| IT-MonitoringMaster | Analyse alertes RMM, seuils, rapports | NOC / Monitoring |
| IT-NOCDispatcher | Dispatch et routage tickets/alertes NOC | NOC / Shift lead |
| IT-ReportMaster | Rapports postmortem, mensuel, QBR, sécurité | Coordonnateur / Direction |
| IT-NetworkMaster | Diagnostics réseau, firewall, VPN, VLAN | Réseau / Infrastructure |
| IT-CloudMaster | M365, Entra ID, Intune, Azure | Cloud / M365 admin |
| IT-BackupDRMaster | Veeam, Datto, Keepit, DR, restauration | NOC / Infrastructure |
| IT-SecurityMaster | EDR/SIEM, IR, audit sécurité, rapports | SOC / Sécurité |

---

## IT-Assistant-N3

> **Rôle :** Technicien senior IA pour incidents N3 complexes. Diagnostics avancés, RCA, coordination escalade vers Commandare.

**Audience :** Technicien N3, tech senior en intervention infrastructure complexe.

**Déclencheur typique :** Billet escaladé depuis N2, incident multi-systèmes, panne récurrente, besoin de RCA.

### Capacités principales
- AD/DC : opérations avancées, réplication, FSMO, DSRM, intégrité NTDS
- Virtualisation : Hyper-V, VMware, XCP-ng — VM operations, RAID, stockage
- SQL Server, RDS/RemoteApp, Exchange Online, Intune, Entra ID
- Génération de scripts PowerShell production (param() ligne 1 absolu)
- RCA structuré (5 Pourquoi) et postmortem N3
- Validation AD pré/post obligatoire sur toute intervention DC
- Chargement automatique de runbooks selon le contexte

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/start [#billet]` | Triage N3 + plan d'intervention | Début de billet N3 |
| `/script [desc]` | Script PowerShell production-ready | Besoin d'automatisation |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Note interne technique (avec faits, hypothèses, risques)
- Discussion CW (client-safe)
- RCA document si P1/P2
- Script PowerShell dans bloc séparé

### Règles critiques
- **1 serveur à la fois** — post-check DC obligatoire
- **Snapshot DC interdit** → Windows Server Backup uniquement
- Reboot DC : `shutdown /r /t 0 /c "Billet #XXXXX — [raison]" /d p:4:1`
- Escalade P1/P2 vers IT-Commandare-Infra immédiatement

### 🔧 Pistes d'amélioration
- Ajouter `/rca [billet]` : RCA guidé 5 Pourquoi avec output CW prêt
- Ajouter `/precheck [serveur]` et `/postcheck [serveur]` explicites comme commandes séparées
- Ajouter matrice de sévérité pour escalade : critères clairs P1 vs P2 vs N3 autonome

---

## IT-MaintenanceMaster

> **Rôle :** Copilote pour toutes les maintenances planifiées. Plan d'abord, confirmation aux étapes à risque, documentation complète pré/post.

**Audience :** Technicien effectuant patching, reboots contrôlés, vérifications de santé serveur.

**Déclencheur typique :** Fenêtre de maintenance, patching mensuel, reboot planifié, vérification post-panne.

### Capacités principales
- Patching Windows : stratégie complète vs RMM, WSUS
- Reboot contrôlé avec documentation Event ID 1074 (shutdown /r)
- Health checks serveur avec script MasterScript
- Precheck / postcheck structurés (CPU, RAM, disque, services arrêtés, logs événements)
- Validation DC pré/post obligatoire
- Notices Teams maintenance générées mot pour mot
- Audit trimestriel serveurs
- Procédures post-panne électrique

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/start [#billet]` | Triage + plan + precheck | Début de maintenance |
| `/start_maint` | Pack maintenance : ordre serveurs + snapshots | Maintenance planifiée multi-serveurs |
| `/script [desc]` | Script PowerShell production-ready | Automatisation maintenance |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Plan de maintenance (ordre serveurs, snapshots, checkpoints)
- Precheck/postcheck structurés
- Script de health check
- Notice Teams (⚠️ Maintenance en cours)
- Note interne + Discussion clôture

### Règles critiques
- **Reboot obligatoire documenté :** `shutdown /r /t 0 /c "Billet #XXXXX — [raison]" /d p:4:1`
- `Restart-Computer -Force` seul **interdit sur DC**
- Notice Teams générée **avant** le début de la maintenance
- Snapshot DC interdit → Windows Server Backup

### 🔧 Pistes d'amélioration
- Ajouter `/precheck [serveur]` et `/postcheck [serveur]` comme commandes explicites
- Ajouter `/notice [maintenance|urgence]` : génère la notice Teams avec les 3 variantes (début/fin/annulation)
- Lier automatiquement à T4 CW_NOTE_DIAGNOSTIC pour les outputs MasterScript

---

## IT-MonitoringMaster

> **Rôle :** Expert monitoring. Analyse les alertes RMM, recommande les seuils, produit des rapports de santé infrastructure.

**Audience :** Équipe NOC, technicien en charge du monitoring RMM (N-able, ConnectWise RMM, Auvik).

**Déclencheur typique :** Alerte RMM reçue à analyser, faux positif récurrent, rapport de santé demandé.

### Capacités principales
- Triage et classification d'alertes RMM (isolée vs tendance récurrente)
- Recommandation de seuils KPI (CPU, RAM, disque, latence, services)
- Distinction faux positif → ajustement seuil documenté
- Rapports de santé infrastructure
- Recommandations de configuration monitoring par type d'actif
- Analyse de tendances (uptime, événements répétés)

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/alerte [détails]` | Analyse alerte : classification + actions | Alerte RMM reçue |
| `/seuils [type]` | Recommandations seuils KPI | Calibration monitoring |
| `/rapport` | Rapport de santé infrastructure | Revue périodique |
| `/config [actif]` | Recommandations config monitoring | Nouvel actif à monitorer |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Rapport d'analyse d'alerte (classification, actions recommandées)
- Recommandations seuils (tableau par métrique)
- Rapport de santé infrastructure
- Note interne CW

### 🔧 Pistes d'amélioration
- Ajouter `/tendance [client]` : analyse des alertes répétées sur 30/90 jours → recommandation seuil
- Ajouter `/faux-positif [alerte]` : documenter et créer une règle d'exclusion à soumettre à l'équipe RMM
- Définir une escalade automatique si alerte P1 non acquittée > 5 min → IT-NOCDispatcher

---

## IT-NOCDispatcher

> **Rôle :** Dispatcher NOC. Qualifie les alertes et tickets, route vers le bon agent/technicien, gère les passations de quart.

**Audience :** NOC, chef de quart, coordinateur de shift.

**Déclencheur typique :** Ticket non assigné, alerte sans propriétaire, passation de quart, SLA à risque.

### Capacités principales
- Qualification et priorisation des tickets/alertes
- Routing avec assignation d'un propriétaire
- Escalade P1 non assigné > 10 min → IT-Commandare-NOC
- Zéro ticket P1/P2 orphelin (politique absolue)
- Documentation de passation de quart
- Escalade sécurité → IT-SecurityMaster
- Détection multi-alertes même client/site = incident multi-composants

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/dispatch [ticket]` | Dispatch ticket ou alerte RMM | Ticket à router |
| `/escalade_sla [ticket]` | Gérer ticket SLA à risque | SLA en dépassement |
| `/handover` | Passation de quart : actifs + alertes | Changement de shift |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Routing documenté (assignation + justification)
- Note SLA escalade
- Rapport de passation de quart
- Note interne CW

### 🔧 Pistes d'amélioration
- Ajouter `/charge` : vue rapide de la charge actuelle par technicien/équipe
- Ajouter `/p1-status` : état de tous les P1 ouverts avec temps d'attente
- Ajouter détection automatique : même client, 3+ alertes en 1h = escalade Commandare-NOC

---

## IT-ReportMaster

> **Rôle :** Expert reporting MSP. Produit des rapports structurés et actionnables depuis les données CW/RMM uniquement.

**Audience :** Coordonnateurs, direction MSP, contacts clients.

**Déclencheur typique :** Fin de mois, réunion QBR, incident P1/P2 résolu, demande de rapport de sécurité.

### Capacités principales
- Postmortem avec 5 Pourquoi et MTTD/MTTR
- Rapport mensuel MSP (SLA, tickets, incidents)
- QBR trimestriel (performance + roadmap)
- Rapport de sécurité mensuel ou post-incident
- Validation des données source (marqueurs `[DONNÉES REQUISES]` si absent)
- Max 3 recommandations actionnables avec propriétaire
- Zéro IP, zéro credentials dans les livrables clients

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/postmortem [billet]` | Postmortem : 5 Pourquoi + MTTD/MTTR | Après P1/P2 résolu |
| `/mensuel [mois]` | Rapport mensuel MSP | Fin de mois |
| `/qbr [trimestre]` | QBR : performance + recommandations | Réunion trimestrielle |
| `/securite [période]` | Rapport sécurité | Revue sécurité |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Rapport postmortem CW-ready
- Dashboard mensuel (tableau)
- Présentation QBR
- Rapport sécurité

### 🔧 Pistes d'amélioration
- Ajouter `/capa [billet]` : initier un plan CAPA depuis un incident récurrent
- Ajouter `/coordo [période]` : rapport opérationnel coordonnateur (lier à TEMPLATE_REPORT_Coordonnateur_V1)
- Ajouter indicateur de tendance automatique : ce mois vs mois précédent pour SLA et volume tickets

---

## IT-NetworkMaster

> **Rôle :** Expert réseau. Diagnostics LAN/WAN/WiFi, configuration firewall, VPN, segmentation VLAN.

**Audience :** Équipe réseau/infrastructure, technicien en intervention réseau.

**Déclencheur typique :** Problème de connectivité, VPN down, reconfiguration firewall, segmentation VLAN.

### Capacités principales
- Diagnostics LAN/WAN/WiFi complets
- Firewalls : Fortinet, WatchGuard, Meraki, SonicWall
- VPN : SSL, IPSec, L2TP
- VLAN : segmentation et planification
- DNS et DHCP diagnostics
- Validation QoS avant tout changement sur trunk SIP
- Notification client obligatoire avant restart firewall (impact WAN)
- Accès documentation réseau et portails

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/diag [symptôme]` | Diagnostic réseau : LAN/WAN/WiFi | Problème connectivité |
| `/firewall [marque]` | Config/diagnostic firewall | Intervention firewall |
| `/vpn [symptôme]` | Diagnostic VPN : SSL/IPSec/L2TP | VPN down ou lent |
| `/vlan [contexte]` | Configuration/segmentation VLAN | Projet réseau |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Rapport de diagnostic réseau
- Guide de configuration firewall/VPN
- Plan de segmentation VLAN
- Note interne + Discussion CW

### Règles critiques
- **Jamais de restart firewall sans notification client** (impact WAN)
- **Valider QoS avant tout changement sur trunk SIP** (sinon VoIP impactée)
- Escalade vers IT-VoIPMaster si impact voix détecté

### 🔧 Pistes d'amélioration
- Ajouter `/qos [contexte]` : validation QoS dédiée avant intervention sur réseau avec VoIP
- Ajouter `/changement [desc]` : plan de changement réseau avec rollback documenté
- Ajouter template de notification client pré-restart firewall (prêt à coller dans CW)

---

## IT-CloudMaster

> **Rôle :** Expert cloud. Diagnostics et résolution M365/Azure/Entra, configuration, licences et conformité.

**Audience :** Équipe cloud/infrastructure, admins M365, techniciens N3 avec accès admin.

**Déclencheur typique :** Problème Exchange Online, MFA bloqué, compte Entra compromis, politique Intune, licence M365.

### Capacités principales
- Exchange Online : flux courriel, connecteurs, règles de transport
- Entra ID / Azure AD : MFA, accès conditionnel, comptes compromis
- Teams, SharePoint, OneDrive : partage, sync, permissions
- Intune : conformité appareils, wipe, politiques MDM/MAM
- Validation licences M365 (actives, expirées, surplus)
- Keepit M365 backup verification
- Détection compte compromis → escalade IT-SecurityMaster
- AWS/GCP diagnostics de base

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/exchange [symptôme]` | Diagnostic Exchange Online | Problème courriel |
| `/entraid [symptôme]` | Entra ID / Azure AD / MFA | Compte ou auth |
| `/teams [symptôme]` | Teams / SharePoint / OneDrive | Collaboration cloud |
| `/intune [symptôme]` | Intune : conformité, wipe, politiques | Gestion appareils |
| `/keepit` | Vérification backup Keepit M365 | Audit sauvegarde M365 |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Diagnostic cloud (faits, hypothèses, actions)
- Rapport de licences
- Checklist de conformité
- Note interne + Discussion CW

### Règles critiques
- Wipe Intune : **approbation superviseur + client obligatoire** avant exécution
- Compte compromis → **IT-SecurityMaster immédiatement**
- Jamais de credentials dans les livrables

### 🔧 Pistes d'amélioration
- Ajouter `/securite-score` : analyse du Secure Score M365 avec recommandations priorisées
- Ajouter `/licences [client]` : rapport licences non utilisées > 90 jours
- Ajouter protocole de validation pour les wipes Intune (double confirmation)

---

## IT-BackupDRMaster

> **Rôle :** Spécialiste sauvegarde et reprise. Diagnostique les jobs Veeam/Datto/Keepit, guide les restaurations, valide les tests DR.

**Audience :** NOC, équipe infrastructure, coordonnateur en cas de DR.

**Déclencheur typique :** Job de sauvegarde en échec, restauration urgente demandée, test DR planifié, activation DR.

### Capacités principales
- Diagnostic jobs Veeam (échec, avertissement, chaîne brisée)
- Datto BCDR : alertes, screenshots, restauration
- Keepit M365 backup management
- Restauration guidée (emplacement original : approbation écrite obligatoire)
- Restauration VM complète : superviseur + client requis
- Plan DR : test ou activation avec décision documentée
- Suppression de point de restauration : superviseur requis

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/triage [job]` | Analyse job Veeam/Datto/Keepit en échec | Job échoué |
| `/restore [contexte]` | Restauration guidée fichier ou VM | Demande de restauration |
| `/dr [client]` | Plan DR : test ou activation | Test DR ou sinistre |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Rapport d'analyse de job
- Procédure de restauration documentée
- Rapport de test DR
- Journal d'activation DR
- Note interne + Discussion CW

### Règles critiques
- **Snapshot DC interdit** → Windows Server Backup uniquement
- Restauration originale : **approbation écrite** dans le billet
- Restauration VM complète : **superviseur + client**
- Suppression point de restauration : **superviseur**

### 🔧 Pistes d'amélioration
- Ajouter `/chain [client]` : validation de la chaîne de sauvegarde complète (jobs + copies hors-site)
- Ajouter `/test-restore [client]` : génère le plan de test de restauration trimestriel
- Ajouter checklist d'approbation intégrée pour restauration originale (avec champs signature)

---

## IT-SecurityMaster

> **Rôle :** Expert cybersécurité. Triage EDR/SIEM, réponse aux incidents, audit posture sécurité, rapports sécurité.

**Audience :** SOC, équipe sécurité, répondants incidents.

**Déclencheur typique :** Alerte EDR, suspicion ransomware, audit CIS/NIST, rapport de sécurité mensuel.

### Capacités principales
- Triage alertes EDR/SIEM : classification + IOC + confinement
- Réponse incident (IR) : Identification → Confinement → Éradication → Rétablissement
- Audit posture sécurité (CIS Controls v8, NIST CSF)
- Rapports sécurité : mensuel ou post-incident
- Protocoles ransomware : NE PAS éteindre, préserver artefacts RAM
- Conformité M365, Purview, audit logs
- Confinement réseau (isolation) sans shutdown machine suspect

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/triage [alerte]` | Triage EDR/SIEM : classification + IOC + confinement | Alerte sécurité reçue |
| `/ir [phase]` | Incident Response : ID/Contain/Eradicate/Recover | IR en cours |
| `/audit` | Audit posture sécurité (CIS/NIST CSF) | Revue sécurité |
| `/rapport [période]` | Rapport sécurité mensuel ou post-incident | Rapport sécurité |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Rapport de triage (classification, IOC, timeline)
- Plan d'action IR (actions par phase)
- Rapport d'audit (findings, recommandations)
- Rapport sécurité

### Règles critiques
- **Machine suspecte : NE PAS éteindre** → préserve artefacts RAM
- **Aucun code PoC/exploit** → décrire les vecteurs uniquement
- Isolation réseau possible, EDR disable → escalade requise
- Ransomware confirmé → IT-UrgenceMaster + coordonnateur immédiat

### 🔧 Pistes d'amélioration
- Ajouter `/ioc [type]` : recherche IOC avec liste de vérification par type (hash, IP, domaine, email)
- Ajouter classification granulaire : True Positive / False Positive / Suspicious dans le triage
- Ajouter timeline d'incident automatique dans le rapport IR (chronologie des événements)

---

## Index des commandes — Tier Pro

| Agent | Commande | Description |
|---|---|---|
| IT-Assistant-N3 | `/start [#billet]` | Triage N3 + plan d'intervention |
| IT-Assistant-N3 | `/script [desc]` | Script PowerShell production-ready |
| IT-Assistant-N3 | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-Assistant-N3 | `/close` | Menu de clôture CW |
| IT-MaintenanceMaster | `/start [#billet]` | Triage + plan + precheck |
| IT-MaintenanceMaster | `/start_maint` | Pack maintenance multi-serveurs |
| IT-MaintenanceMaster | `/script [desc]` | Script PowerShell production-ready |
| IT-MaintenanceMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-MaintenanceMaster | `/close` | Menu de clôture CW |
| IT-MonitoringMaster | `/alerte [détails]` | Analyse alerte RMM |
| IT-MonitoringMaster | `/seuils [type]` | Recommandations seuils KPI |
| IT-MonitoringMaster | `/rapport` | Rapport de santé infrastructure |
| IT-MonitoringMaster | `/config [actif]` | Config monitoring recommandée |
| IT-MonitoringMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-MonitoringMaster | `/close` | Menu de clôture CW |
| IT-NOCDispatcher | `/dispatch [ticket]` | Dispatch ticket ou alerte RMM |
| IT-NOCDispatcher | `/escalade_sla [ticket]` | Gérer ticket SLA à risque |
| IT-NOCDispatcher | `/handover` | Passation de quart |
| IT-NOCDispatcher | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-NOCDispatcher | `/close` | Menu de clôture CW |
| IT-ReportMaster | `/postmortem [billet]` | Postmortem 5 Pourquoi + MTTD/MTTR |
| IT-ReportMaster | `/mensuel [mois]` | Rapport mensuel MSP |
| IT-ReportMaster | `/qbr [trimestre]` | QBR trimestriel |
| IT-ReportMaster | `/securite [période]` | Rapport sécurité |
| IT-ReportMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-ReportMaster | `/close` | Menu de clôture CW |
| IT-NetworkMaster | `/diag [symptôme]` | Diagnostic LAN/WAN/WiFi |
| IT-NetworkMaster | `/firewall [marque]` | Config/diagnostic firewall |
| IT-NetworkMaster | `/vpn [symptôme]` | Diagnostic VPN |
| IT-NetworkMaster | `/vlan [contexte]` | Configuration VLAN |
| IT-NetworkMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-NetworkMaster | `/close` | Menu de clôture CW |
| IT-CloudMaster | `/exchange [symptôme]` | Diagnostic Exchange Online |
| IT-CloudMaster | `/entraid [symptôme]` | Entra ID / MFA / Azure AD |
| IT-CloudMaster | `/teams [symptôme]` | Teams / SharePoint / OneDrive |
| IT-CloudMaster | `/intune [symptôme]` | Intune : conformité, wipe, politiques |
| IT-CloudMaster | `/keepit` | Vérification backup Keepit M365 |
| IT-CloudMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-CloudMaster | `/close` | Menu de clôture CW |
| IT-BackupDRMaster | `/triage [job]` | Analyse job sauvegarde en échec |
| IT-BackupDRMaster | `/restore [contexte]` | Restauration guidée fichier ou VM |
| IT-BackupDRMaster | `/dr [client]` | Plan DR : test ou activation |
| IT-BackupDRMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-BackupDRMaster | `/close` | Menu de clôture CW |
| IT-SecurityMaster | `/triage [alerte]` | Triage EDR/SIEM : classification + IOC |
| IT-SecurityMaster | `/ir [phase]` | Incident Response |
| IT-SecurityMaster | `/audit` | Audit posture sécurité CIS/NIST |
| IT-SecurityMaster | `/rapport [période]` | Rapport sécurité |
| IT-SecurityMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-SecurityMaster | `/close` | Menu de clôture CW |

---

*AGENT_BOOK_Pro_V1 — IT MSP Intelligence — 2026-05-14*
