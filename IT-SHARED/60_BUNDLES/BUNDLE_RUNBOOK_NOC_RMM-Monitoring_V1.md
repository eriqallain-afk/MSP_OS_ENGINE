# BUNDLE RUNBOOK NOC RMM-Monitoring V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-MonitoringMaster, IT-Commandare-NOCDispatcher, IT-Assistant-N3 | IT-MaintenanceMaster | IT-SysAdmin
**Description :** RMM et Monitoring — N-able, ConnectWise RMM, Auvik, Réponse aux alertes
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__NAble_RMM_Operations_V1 -->
## RUNBOOK — N-able (N-sight/N-central) RMM

# RUNBOOK — N-able (N-sight / N-central) : Opérations RMM
**ID :** RUNBOOK__NAble_RMM_Operations_V1
**Version :** 1.0 | **Agents :** IT-MonitoringMaster, IT-Assistant-N3
**Domaine :** NOC — RMM
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS N-ABLE

| Produit | Accès |
|---|---|
| **N-sight RMM** | https://[votre-domaine].systemmonitor.eu.com |
| **N-central** | https://[serveur-ncentral] |

---

## 2. HEALTH CHECK MATINAL N-ABLE

```
Dashboard → Overview
→ Devices Online/Offline/Failed
→ Alertes actives (Critical/Warning)
→ Patch Status : appareils avec patchs manquants

Sites → [Client]
→ Statut par appareil
→ Alertes non acquittées
```

---

## 3. ALERTES N-ABLE — TRAITEMENT

### Acquitter une alerte
```
1. Dashboard → Active Alerts
2. Sélectionner l'alerte → Acknowledge
3. Ajouter un commentaire : "Billet #XXXXXX — en investigation"
4. Traiter l'alerte → Mark as Resolved une fois résolu
```

### Types d'alertes et actions standard

| Type | Seuil typique | Action |
|---|---|---|
| CPU High | > 90% pendant 15 min | Vérifier processus → escalade NOC |
| Disk Space Low | < 10% libre | Nettoyage → escalade INFRA |
| Service Down | Service critique arrêté | Redémarrer → escalade si récurrent |
| Backup Failed | Job Veeam/Datto en échec | Voir runbook backup |
| Device Offline | Plus de heartbeat | Vérifier réseau/alimentation |
| Patch Missing | Patchs critiques manquants | Planifier patching |
| AV/EDR Alert | Menace détectée | Escalade SOC immédiate |

---

## 4. MODE MAINTENANCE N-ABLE

```
⚠️ OBLIGATOIRE avant toute intervention planifiée

N-sight RMM :
1. Devices → [Appareil] → Maintenance
2. Enable Maintenance → durée en minutes
3. Confirmer → les alertes sont suspendues

N-central :
1. Devices → [Appareil] → Actions → Set Maintenance Mode
2. Durée → Confirm

⚠️ TOUJOURS désactiver après l'intervention
```

---

## 5. DÉPLOIEMENT DE SCRIPTS DEPUIS N-ABLE

```
N-sight RMM → Script Manager
1. Sélectionner le ou les appareils cibles
2. Run Task → Script / PowerShell
3. Coller ou choisir le script
4. Exécuter → surveiller les résultats dans Task History

N-central :
1. Configuration → Scheduled Tasks → Add Automation Policy
2. Script Repository → choisir ou uploader le script
3. Assigner aux appareils cibles
4. Voir les résultats dans : Reports → Script Results
```

---

## 6. GESTION DES PATCHS WINDOWS

```
N-sight RMM → Patch Management
→ Approuver les patchs : Security → Approve
→ Planifier le déploiement : Schedule → fenêtre de maintenance

Rapports de patch :
Reports → Patch Status Report → par client
→ Appareils non patchés depuis > 30 jours (attention particulière)
→ Patchs critiques manquants (CVSS > 7.0)
```

---

## 7. RAPPORT MENSUEL N-ABLE

```
Reports → All Reports
→ Device Availability : temps de disponibilité par appareil
→ Patch Compliance : % de conformité patchs
→ Alert Summary : nombre d'alertes par type
→ Performance : CPU/RAM/Disk moyens

Export en PDF pour rapport client mensuel
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS ignorer les alertes Critical sans les acquitter et documenter
⛔ NE JAMAIS exécuter des scripts sur plusieurs clients simultanément sans test préalable
⛔ NE JAMAIS supprimer un appareil de N-able sans désinstaller l'agent d'abord
⛔ NE PAS oublier de désactiver le mode maintenance après intervention
   Les alertes réelles seraient ignorées silencieusement
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| > 20 appareils offline simultanément | NOC | Immédiat |
| Alerte sécurité AV/EDR | SOC | Immédiat |
| N-central/N-sight inaccessible | NOC + INFRA | 30 min |
| Disque critique sur serveur PROD | NOC + INFRA | Dans l'heure |


---
<!-- SOURCE: RUNBOOK__CWRMM_Auvik_Operations_V1 -->
## RUNBOOK — ConnectWise RMM et Auvik

# RUNBOOK — ConnectWise RMM & Auvik : Opérations
**ID :** RUNBOOK__CWRMM_Auvik_Operations_V1
**Version :** 1.0 | **Agents :** IT-MonitoringMaster, IT-Commandare-NOCDispatcher, IT-Assistant-N3
**Domaine :** NOC — RMM & Network Monitoring
**Mis à jour :** 2026-03-20

---

# PARTIE 1 — CONNECTWISE RMM (CW AUTOMATE / COMMAND)

## 1.1 ACCÈS CONNECTWISE RMM

| Produit | Accès |
|---|---|
| **CW Automate (LabTech)** | https://[votre-serveur]:443 |
| **CW Command** | https://command.connectwise.com |
| **CW Manage (PSA)** | https://[votre-serveur]/ConnectWise ou SaaS |

---

## 1.2 HEALTH CHECK MATINAL CW RMM

```
CW Automate → Dashboard
→ Agents Online/Offline
→ Alertes actives par priorité
→ Patch Status

CW Command → Summary
→ Device health par site
→ Alertes NOC
→ Tickets ouverts liés aux alertes
```

---

## 1.3 ALERTES CW RMM — TRAITEMENT

```
CW Automate → Monitors → Alert Tickets
→ Tickets créés automatiquement par les moniteurs

Traitement :
1. Ouvrir le ticket d'alerte dans CW Manage
2. Acquitter l'alerte dans CW Automate
3. Investiguer selon le type d'alerte (voir tableau ci-dessous)
4. Documenter les actions dans la note CW interne
5. Fermer l'alerte si résolue

Moniteurs typiques et actions :

| Moniteur | Seuil | Action |
|---|---|---|
| CPU Alert | > 85% 15 min | Vérifier processus |
| Disk Space | < 10% | Nettoyage + escalade |
| Service Down | Service critique | Restart-Service |
| Windows Update | > 30 jours sans patch | Planifier patching |
| Backup Failure | Job Veeam/Datto | Voir runbook backup |
| Event Log Error | ID 1000/6008/etc | Analyser + escalade |
| Agent Offline | > 5 min | Vérifier réseau |
```

---

## 1.4 SCRIPTS CW AUTOMATE — EXÉCUTION

```
CW Automate → Script Manager
→ Rechercher le script
→ Clic droit → Run Now → sélectionner le ou les appareils
→ Voir les résultats : Script Logs

Créer un script one-shot rapide :
Scripts → New Script → PowerShell → coller le code → Save → Run
```

---

## 1.5 MODE MAINTENANCE CW AUTOMATE

```
Computers → [Ordinateur] → Actions → Set Maintenance Mode
→ Durée : en minutes
→ Tous les moniteurs sont suspendus pendant la durée

⚠️ OBLIGATOIRE avant maintenance planifiée
⚠️ TOUJOURS désactiver après
```

---

## 1.6 PATCH MANAGEMENT CW AUTOMATE

```
Patch Manager → Patch Status
→ Vue par client/site
→ Filtrer : Missing Critical Patches

Approuver et planifier :
1. Patch Policies → sélectionner la politique du client
2. Approuver les catégories : Security Updates, Critical Updates
3. Patch Window : configurer la fenêtre de maintenance (ex: sam 02h00)
4. Results : Patch History → vérifier le résultat
```

---

# PARTIE 2 — AUVIK

## 2.1 PRÉSENTATION AUVIK

Auvik est une solution de **Network Monitoring & Management** cloud.
Il découvre, cartographie et supervise l'infrastructure réseau (switches, routers, firewalls, APs).

**Portail :** https://[votre-domaine].auvik.com

---

## 2.2 HEALTH CHECK AUVIK

```
Dashboard → Overview
→ Devices : Online/Offline/Warning
→ Alertes actives
→ Network Topology : carte du réseau

Devices → [Client]
→ Statut de chaque équipement réseau
→ CPU/Memory/Interface utilization
→ Dernière communication (timestamp)
```

---

## 2.3 ALERTES AUVIK

```
Alerts → Active Alerts
→ Trier par : Severity, Device, Type

Types d'alertes Auvik fréquentes :

| Type | Signification | Action |
|---|---|---|
| Device Offline | Plus de polling SNMP | Vérifier connectivité + escalade NOC |
| Interface Down | Port réseau down | Vérifier câble + appareil connecté |
| High Interface Utilization | Bande passante > seuil | Analyser trafic + escalade NOC |
| Config Change | Configuration modifiée | Vérifier qui a fait le changement |
| License Expiry | Licence équipement proche expiration | Planifier renouvellement |
```

---

## 2.4 TOPOLOGIE ET CARTOGRAPHIE RÉSEAU

```
Network → Topology
→ Vue graphique de l'infrastructure réseau
→ Cliquer sur un équipement → détails (interfaces, IP, MAC, neighbours)

Utile pour :
→ Identifier un équipement inconnu
→ Tracer le chemin réseau entre deux points
→ Identifier les équipements non managés
```

---

## 2.5 HISTORIQUE DE CONFIGURATION (CONFIG BACKUP)

```
Devices → [Équipement] → Configuration
→ Voir les configurations sauvegardées automatiquement
→ Comparer deux versions (diff)
→ Télécharger une version pour restauration

⚠️ Si Auvik détecte un changement de configuration → alerte automatique
→ Vérifier si le changement était planifié
→ Si non planifié : investiguer → escalade SOC si suspect
```

---

## 3. NE PAS FAIRE

### CW RMM
```
⛔ NE JAMAIS exécuter un script à risque (suppression, modification système) sans test
⛔ NE PAS oublier le mode maintenance avant intervention
⛔ NE JAMAIS supprimer un agent CW sans désinstaller logiciellement d'abord
```

### Auvik
```
⛔ NE JAMAIS ignorer une alerte "Config Change" non planifiée — peut indiquer une compromission
⛔ NE PAS supprimer des équipements d'Auvik sans désinstaller l'agent Auvik
⛔ NE PAS modifier les seuils d'alerte sans documenter la raison
```

---

## 4. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Plusieurs équipements offline simultanément (Auvik) | NOC | Immédiat |
| Config Change non planifié sur firewall/switch | SOC | Dans l'heure |
| CW RMM inaccessible | NOC + INFRA | 30 min |
| > 50 alertes critiques simultanées | NOC | Immédiat |


---
<!-- SOURCE: RUNBOOK__Alert_Response -->
## RUNBOOK — Réponse aux Alertes de Monitoring

# RUNBOOK — Réponse aux Alertes de Monitoring
**ID :** RUNBOOK__Alert_Response | **Version :** 2.0
**Agent owner :** IT-MonitoringMaster | **Équipe :** TEAM__IT
**Domaine :** SECURITY/MONITORING — Réponse aux alertes
**Date révision :** 2026-03-13

---

## ⚠️ GARDE-FOUS — OBLIGATOIRES
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement les alertes monitoring du billet actif.
Il ne répond pas aux demandes hors monitoring/alertes IT.

**Données sensibles :**
- ❌ JAMAIS dans les livrables : IPs, seuils de détection, noms de règles SIEM internes
- ❌ Dans les outputs client : aucun détail qui permettrait de contourner les alertes
- Les IOC (indicateurs de compromission) → note interne uniquement, jamais dans le client-safe

**Actions :**
- Désactivation d'une alerte → `⚠️ Impact : angle mort de sécurité` + validation + durée définie
- Modification de seuil → `⚠️ Impact : faux négatifs possibles` + documentation obligatoire

---

## 1. Objectif
Procédures de réponse structurées aux alertes de monitoring :
- ConnectWise RMM (alertes systèmes)
- N-able (performance / disponibilité)
- Auvik (réseau)
- SIEM / Defender XDR (sécurité)
- BackupRadar (backup)

---

## 2. Qualification d'une alerte — Priorité 0

### 2.1 Grille de qualification (remplir pour toute alerte)
```
Source    : [RMM / Auvik / BackupRadar / SIEM / Utilisateur]
Type      : [CPU / Disque / Service / Réseau / Backup / Sécurité / Disponibilité]
Sévérité  : [Critical / Warning / Informational]
Client    : [nom]
Asset     : [serveur/équipement — sans IP]
Heure     : [HH:MM]
Récurrent : [1ère fois / déjà vu — fréquence ?]
Corrélé   : [alerte isolée / liée à d'autres alertes]
```

### 2.2 Table bruit vs alerte réelle

| Pattern | Décision | Action |
|---------|----------|--------|
| Alerte disparaît < 5 min, aucun symptôme | Bruit transitoire | ACK + surveiller 30 min |
| Alerte revient > 3x / heure | Problème réel | Ouvrir ticket P2/P3 |
| Alerte corrélée avec d'autres assets | Incident infra global | Ticket P1 + Commandare |
| Alerte sur actif en maintenance connue | Faux positif maintenance | ACK + noter dans ticket |
| Alerte sécurité (EDR / SIEM) | JAMAIS ignorer | Analyser obligatoirement |

---

## 3. Réponse par type d'alerte

### 3.1 Alertes performance (CPU/RAM/Disque)
```powershell
# Diagnostic ciblé sur l'asset (lecture seule)
# CPU — identification processus
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id,
  @{n='CPU_s';e={[math]::Round($_.CPU,1)}},
  @{n='RAM_MB';e={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -Auto

# RAM — utilisation détaillée
Get-CimInstance Win32_OperatingSystem |
  Select-Object @{n='Total_GB';e={[math]::Round($_.TotalVisibleMemorySize/1MB,1)}},
                @{n='Libre_GB';e={[math]::Round($_.FreePhysicalMemory/1MB,1)}},
                @{n='Utilisé_%';e={[math]::Round((($_.TotalVisibleMemorySize-$_.FreePhysicalMemory)/$_.TotalVisibleMemorySize)*100,1)}} | Format-List

# Disque — libérer si espace critique
Get-PSDrive -PSProvider FileSystem |
  Select-Object Name, @{n='Libre_GB';e={[math]::Round($_.Free/1GB,1)}},
    @{n='Libre_%';e={[math]::Round($_.Free/($_.Free+$_.Used)*100,1)}} | Format-Table -Auto
```

### 3.2 Alertes disponibilité (service / agent offline)
```powershell
# Vérifier état services (lecture seule)
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} |
  Select-Object DisplayName, Name, Status, StartType | Format-Table -Auto

# Dernière communication agent RMM
# → Vérifier dans la console ConnectWise RMM (Last Seen)
# Si agent offline > 30 min et pas de maintenance → alerter NOC

# ⚠️ Impact : redémarrage service affecte utilisateurs connectés
# → Confirmer avant : Restart-Service -Name "[SERVICE]"
```

### 3.3 Alertes Backup (BackupRadar)
```
Échec backup → vérifier dans cet ordre :
1. Espace destination suffisant ? (> 20% libre)
2. Service backup agent running ?
3. Connectivité vers destination ? (réseau / VPN)
4. Credentials de connexion valides ? (vérifier sans afficher)
5. Job bloqué / en conflit avec autre job ?
→ Si 3 échecs consécutifs → P2 + IT-BackupDRMaster
→ Si perte de données possible → P1 + escalade Senior immédiate
```

### 3.4 Alertes Sécurité (EDR / SIEM / Defender)
```
RÈGLE ABSOLUE : aucune alerte sécurité n'est ignorée sans analyse.

Niveau 1 — Triage (5 min max) :
  → Faux positif connu ? (processus légitime mal détecté)
  → Processus signé par éditeur reconnu + comportement normal ?
  → Si OUI → ACK + documenter la règle d'exclusion proposée (sans l'appliquer sans validation)

Niveau 2 — Analyse (si non faux positif évident) :
  → Hash / process path → vérification VirusTotal ou SIEM interne
  → Compte associé → activité anormale ?
  → Asset → d'autres alertes sur cet asset ?
  → Si suspicion → P1 + IT-SecurityMaster IMMÉDIAT

JAMAIS :
  ❌ Supprimer une alerte EDR sans analyse
  ❌ Désactiver EDR même temporairement sans approbation senior + documentation
  ❌ Créer une exclusion globale sans validation IT-SecurityMaster
```

---

## 4. Documentation obligatoire (toute alerte)

### Champs minimaux dans le ticket CW
```yaml
type_alerte    : [catégorie]
source         : [outil monitoring]
heure_détection: [HH:MM]
asset          : [nom — sans IP]
qualification  : [bruit / réel — justification]
actions        : [liste des actions et statuts]
résolution     : [cause + correctif]
durée          : [en minutes si service interrompu]
récurrence     : [première fois / N-ième — historique]
```

---

## 5. Amélioration continue du monitoring

### Règles de maintenance des seuils (mensuelle)
- Seuil CPU : revoir si > 15% de faux positifs sur 30 jours
- Seuil disque : ajuster si croissance données accélérée détectée
- Alerte récurrente identique > 3x/semaine → ticket amélioration + revue seuil
- Nouvelle alerte qui aurait évité un incident → ajouter à la baseline monitoring

---

## 6. Livrables CW

### Note interne
```
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Source alerte  : [outil]
Type           : [catégorie]
Qualification  : [bruit / incident réel]
Sévérité réelle: P[1/2/3/4]
Asset impacté  : [nom — sans IP]
Actions :
  1. [action — FAIT / KO]
  2. [action — FAIT / KO]
Cause          : [identifiée / [À CONFIRMER]]
Résultat       : [alerte résolue / escaladée / planifiée]
Monitoring     : [ACK / seuil ajusté / à surveiller]
```

### Discussion client (client-safe)
```
- Réception et analyse de l'alerte.
- Investigation effectuée : [résumé fonctionnel sans détails techniques].
- Résolution : [correctif appliqué / surveillance renforcée].
- Prochaine étape : [monitoring actif / aucune action requise].
```


---
<!-- SOURCE: TEMPLATE_COM_Teams-Incident-Actif_V1 -->
## TEMPLATE — Communications Teams Incident Actif

# TEMPLATE_COM_Teams-Incident-Actif_V1
**Agent :** IT-TicketScribe, IT-Commandare-NOC
**Usage :** Annonces Teams pendant un incident actif (NOC/P1/P2)
**Mis à jour :** 2026-03-20

---

## DÉCLARATION D'INCIDENT

```
🚨 INCIDENT EN COURS — [DATE] [HH:MM]
📋 Type : [Panne réseau / Service down / Problème M365 / etc.]
⚠️ Impact : [Services affectés] | Utilisateurs touchés : [nombre ou "tous"]

Notre équipe est en intervention.
Prochain point de communication : [HH:MM]
Billet CW : #[XXXXXX]
```

---

## MISE À JOUR PENDANT L'INCIDENT

```
🔄 MISE À JOUR — [DATE] [HH:MM]
📋 Incident #[XXXXXX] — [Type]
✔️ [Action 1 complétée]
⏳ [Action 2 en cours]
ETA résolution : [heure estimée ou "en investigation"]
Prochain point : [HH:MM]
```

---

## RÉSOLUTION D'INCIDENT

```
✅ INCIDENT RÉSOLU — [DATE] [HH:MM]
📋 Incident #[XXXXXX] — [Type]
⏱️ Durée : [X heures Y minutes]
🔧 Cause : [Description fonctionnelle non-technique]
✔️ Tous les services sont rétablis

Un rapport post-incident vous sera transmis sous [24h/48h].
Questions : [email support] | [téléphone]
```

---

## ESCALADE INTERNE (NOC → Département)

```
⬆️ ESCALADE — [DATE] [HH:MM]
📋 Billet #[XXXXXX] — Transféré au département [NOC/SOC/INFRA/TECH]
⚠️ Niveau : P[1/2]
📝 Résumé : [Description courte]
👤 Technicien N2 : [Nom]
```


---
<!-- SOURCE: TEMPLATE_COM_Teams-Maintenance_V1 -->
## TEMPLATE — Communications Teams Maintenance

# TEMPLATE_COM_Teams-Maintenance_V1
**Agent :** IT-TicketScribe, IT-MaintenanceMaster
**Usage :** Annonces Teams — début, fin et incident pendant maintenance
**Mis à jour :** 2026-03-20

---

## ANNONCE DÉBUT DE MAINTENANCE

```
🔧 MAINTENANCE EN COURS
📅 [DATE] | ⏰ [HH:MM] – [HH:MM] (estimé)
📋 [Description courte — ex: Application des mises à jour Windows]

⚠️ Impact : [Service(s) temporairement indisponibles ou ralentis]
Toute interruption sera communiquée ici.

Merci de votre compréhension. 🙏
```

---

## ANNONCE FIN DE MAINTENANCE — SUCCÈS

```
✅ MAINTENANCE TERMINÉE
📅 [DATE] | ⏰ [HH:MM]
✔️ Mises à jour appliquées avec succès
✔️ Tous les services sont opérationnels

En cas d'anomalie, contactez le support : [info contact]
```

---

## ANNONCE FIN DE MAINTENANCE — AVEC SUIVI

```
⚠️ MAINTENANCE TERMINÉE — Suivi requis
📅 [DATE] | ⏰ [HH:MM]
✔️ [Services X, Y] : opérationnels
⏳ [Service Z] : [état actuel / action en cours]

Notre équipe surveille activement la situation.
Prochain point de communication : [HH:MM]
```

---

## ANNONCE INCIDENT PENDANT MAINTENANCE

```
🚨 INCIDENT DÉTECTÉ — MAINTENANCE [DATE]
⚠️ [Service X] : temporairement indisponible

Notre équipe technique traite la situation.
ETA retour à la normale : [heure estimée ou "sous X heures"]
Prochain point de communication : [HH:MM]
```

---

## RÉSOLUTION D'INCIDENT POST-MAINTENANCE

```
✅ RETOUR À LA NORMALE — [DATE] [HH:MM]
🔧 [Service X] : pleinement opérationnel depuis [HH:MM]
📋 Rapport détaillé disponible sur demande

Nous nous excusons pour la gêne occasionnée.
```


---
<!-- SOURCE: CHECKLIST_NOC_Shift-Handover_V1 -->
## CHECKLIST — Shift Handover NOC

# CHECKLIST_NOC_Shift-Handover_V1
**Agent :** IT-Commandare-NOCDispatcher, IT-Commandare-NOC
**Usage :** Passation de quart entre techniciens NOC
**Mis à jour :** 2026-03-20

---

## PASSATION DE QUART — TECHNICIEN SORTANT

**Date/Heure :** _______ | **Technicien sortant :** _______ | **Entrant :** _______

### Incidents actifs en cours

| Billet CW | Client | Priorité | Statut | Prochaine action | ETA |
|---|---|---|---|---|---|
| #_______ | _______ | P___ | _______ | _______ | _______ |
| #_______ | _______ | P___ | _______ | _______ | _______ |

### Alertes RMM non acquittées

- [ ] Vérifier dans Datto RMM / N-able / CW RMM les alertes actives non traitées
- [ ] Alertes acquittées et documentées : ☐ Oui
- [ ] Alertes laissées en attente (avec raison) : _______

### Maintenances en cours ou prévues dans le quart suivant

| Client | Type | Fenêtre | Billet CW | Technicien assigné |
|---|---|---|---|---|
| _______ | _______ | _______ à _______ | #_______ | _______ |

### Points d'attention pour le quart suivant

- [ ] Client en surveillance renforcée : _______
- [ ] Serveur instable à surveiller : _______
- [ ] Backup en attente de validation : _______
- [ ] Fenêtre de maintenance à déclencher : _______
- [ ] Escalade prévue : _______

### Vérifications de fin de quart

- [ ] Tous les billets P1/P2 actifs ont un technicien assigné pour le quart suivant
- [ ] Mode maintenance RMM désactivé sur tous les assets (sauf si maintenance en cours documentée)
- [ ] Notes de passation écrites dans CW sur les billets concernés
- [ ] Technicien entrant briefé verbalement sur les points critiques

---

## RÉCEPTION DE QUART — TECHNICIEN ENTRANT

- [ ] Lu et compris les incidents actifs ci-dessus
- [ ] Vérifié les alertes RMM (dashboard NOC)
- [ ] Confirmé les maintenances prévues dans mon quart
- [ ] Questions posées au technicien sortant : ☐ Aucune  ☐ Répondues

**Signature (entrée de quart) :** _______ à _______
