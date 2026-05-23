# BUNDLE RUNBOOK INFRA RDS-Operations V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-Assistant-N3, IT-MaintenanceMaster | IT-SysAdmin
**Description :** Remote Desktop Services — Session Broker, RemoteApp, Health Check
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__RDS_Operations_V1 -->
## RUNBOOK — RDS Session Broker et RemoteApp

# RUNBOOK — Remote Desktop Services (RDS) : Session Broker & RemoteApp
**ID :** RUNBOOK__RDS_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-MaintenanceMaster
**Domaine :** INFRA — Remote Desktop Services
**Mis à jour :** 2026-03-20

---

## 1. ARCHITECTURE RDS TYPIQUE MSP

```
Client → RD Gateway → RD Broker → RD Session Host(s)
                    ↓
              RD Web Access
              RD Licensing
```

**Composants clés :**
- **RD Connection Broker** — distribue les sessions, gère la reconnexion
- **RD Session Host** — héberge les sessions et applications
- **RD Gateway** — accès sécurisé depuis Internet (HTTPS 443)
- **RD Web Access** — portail web RemoteApp
- **RD Licensing** — gestion des CAL RDS

---

## 2. VÉRIFICATION SANTÉ RDS — HEALTH CHECK

```powershell
Start-Transcript -Path "C:\IT_LOGS\DIAG\RDS_HealthCheck_$(Get-Date -Format 'yyyyMMdd_HHmm').log"

# Services RDS critiques
Write-Host "=== SERVICES RDS ===" -ForegroundColor Cyan
$RDSServices = @(
    'TermService',      # Remote Desktop Services
    'SessionEnv',       # Remote Desktop Configuration
    'UmRdpService',     # Remote Desktop Device Redirector
    'RpcSs',            # RPC (requis)
    'TSGateway'         # RD Gateway (si installé)
)
Get-Service $RDSServices -ErrorAction SilentlyContinue |
    Select-Object Name, DisplayName, Status, StartType | Format-Table -AutoSize

# Sessions actives
Write-Host "=== SESSIONS ACTIVES ===" -ForegroundColor Cyan
query session

# Utilisateurs connectés
Write-Host "=== UTILISATEURS ===" -ForegroundColor Cyan
query user

# Ressources serveur
Write-Host "=== RESSOURCES ===" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    CPU_Usage = "$((Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average)%"
    RAM_Free_GB = [math]::Round($os.FreePhysicalMemory/1MB, 1)
    RAM_Total_GB = [math]::Round($os.TotalVisibleMemorySize/1MB, 1)
    Disk_C_Free_GB = [math]::Round((Get-PSDrive C).Free/1GB, 1)
} | Format-List

Stop-Transcript
```

---

## 3. DÉPANNAGE — UTILISATEUR NE PEUT PAS SE CONNECTER

### Arbre de décision
```
L'utilisateur ne peut pas se connecter en RDS
│
├─ Message "The remote computer could not be found"
│   → Vérifier DNS + connectivité réseau + RD Gateway
│
├─ Message "Access denied"
│   → Vérifier groupe "Remote Desktop Users" ou "RDP_Acces" dans AD
│   → Vérifier GPO qui bloquent l'accès RDP
│
├─ Message "The connection was denied because the user account is not authorized"
│   → Vérifier propriétés utilisateur AD → onglet Remote control
│   → Vérifier "Allow log on through Remote Desktop Services" GPO
│
├─ Message "Your session has been disconnected"
│   → Vérifier limites de session dans GPO (timeout, déconnexion)
│   → Vérifier le profil itinérant si applicable
│
└─ Connexion réussie mais application ne démarre pas
    → Vérifier les RemoteApp publiées dans RD RemoteApp Manager
    → Vérifier les droits sur l'application
```

### Vérifier et ajouter l'accès RDP
```powershell
# ⛔ NE PAS activer l'accès RDP à un utilisateur individuellement
# Utiliser le groupe AD approprié

# Vérifier les membres du groupe Remote Desktop Users
Get-ADGroupMember "Remote Desktop Users" | Select-Object Name, SamAccountName

# Ajouter l'utilisateur au groupe approprié
Add-ADGroupMember -Identity "Remote Desktop Users" -Members "prenom.nom"
# OU selon la convention du client :
Add-ADGroupMember -Identity "GRP_RDP_Utilisateurs" -Members "prenom.nom"
```

### Vérifier les limites de session GPO
```powershell
# Vérifier les paramètres GPO RDS appliqués
gpresult /h "C:\IT_LOGS\DIAG\GPResult_RDS.html" /f
# Ouvrir le fichier HTML pour analyser les politiques appliquées

# Chemins GPO pertinents :
# Computer > Admin Templates > Windows Components > Remote Desktop Services
# > RD Session Host > Session Time Limits
# > RD Session Host > Connections
```

---

## 4. DÉPANNAGE — SESSIONS FANTÔMES (GHOST SESSIONS)

```powershell
# Lister toutes les sessions incluant déconnectées
query session

# Identifier les sessions avec statut "Disc" (déconnectées)
# Réinitialiser une session fantôme (remplacer ID par le numéro de session)
Reset-Session 3 /server:NOM_SERVEUR_RDS

# Forcer déconnexion d'une session (si reset ne suffit pas)
logoff 3 /server:NOM_SERVEUR_RDS

# ⛔ NE PAS tuer les sessions sans avoir averti l'utilisateur
# ⛔ NE PAS déconnecter la session Console (ID 0)
```

---

## 5. GESTION REMOTEAPP

### Vérifier les applications publiées
```powershell
# Sur le serveur RD Session Host ou via Server Manager
Import-Module RemoteDesktop

# Lister les RemoteApp publiées
Get-RDRemoteApp -CollectionName "NomCollection" |
    Select-Object DisplayName, FilePath, Alias | Format-Table -AutoSize
```

### Publier une nouvelle RemoteApp
```powershell
# ⚠️ Vérifier que l'application est installée sur TOUS les Session Hosts de la collection
New-RDRemoteApp `
    -CollectionName "NomCollection" `
    -DisplayName "Nom Application" `
    -FilePath "C:\Program Files\App\app.exe" `
    -Alias "NomApp"

# Assigner les groupes AD qui peuvent accéder à cette RemoteApp
Set-RDRemoteApp `
    -CollectionName "NomCollection" `
    -Alias "NomApp" `
    -UserGroups @("DOMAINE\GRP_App_Users")
```

---

## 6. RD GATEWAY — VÉRIFICATION

```powershell
# Services RD Gateway
Get-Service TSGateway | Select-Object Name, Status, StartType

# Vérifier le certificat SSL RD Gateway (expiration)
$cert = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -match "gateway.domaine.com" }
[pscustomobject]@{
    Subject = $cert.Subject
    Expiration = $cert.NotAfter
    JoursRestants = ($cert.NotAfter - (Get-Date)).Days
}
```

---

## 7. REBOOT SESSION HOST — PROCÉDURE

```powershell
# ⚠️ AVANT de reboôter un Session Host :
# 1. Vider le serveur des utilisateurs actifs

# Mode drain — nouvelles connexions redirigées vers d'autres hôtes
Set-RDSessionHost -SessionHost "NOM_HOST.domaine.com" `
    -NewConnectionAllowed No -ConnectionBroker "NOM_BROKER.domaine.com"

# Vérifier qu'il n'y a plus de sessions actives
query session /server:NOM_HOST

# Attendre / déconnecter les sessions restantes
# Puis procéder au reboot
Restart-Computer -ComputerName "NOM_HOST" -Force

# Après reboot — réactiver les connexions
Set-RDSessionHost -SessionHost "NOM_HOST.domaine.com" `
    -NewConnectionAllowed Yes -ConnectionBroker "NOM_BROKER.domaine.com"
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS reboôter tous les Session Hosts en même temps
⛔ NE JAMAIS donner les droits administrateur local sur un RDS à un utilisateur standard
⛔ NE JAMAIS installer des logiciels sur un Session Host sans mode installation
   → toujours utiliser : change user /install avant l'installation
   → puis : change user /execute après
⛔ NE JAMAIS mapper un lecteur réseau en dur dans un profil RDS
   → utiliser les GPO de redirection de dossiers
⛔ NE JAMAIS désactiver le monitoring sur un Session Host pendant une maintenance
   sans avoir informé le NOC
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Broker RD inaccessible (tous les utilisateurs impactés) | NOC | Immédiat |
| Certificat RD Gateway expiré | INFRA | Dans l'heure |
| > 50 utilisateurs déconnectés simultanément | NOC | Immédiat |
| Problème de licence RDS (CAL épuisées) | TECH | Dans l'heure |


---
<!-- SOURCE: TEMPLATE_MAINTENANCE_MAJ-CVE-et-Planifiee_V1 -->
## TEMPLATE — Alerte CVE et Briefing Pré-Maintenance

# TEMPLATE_MAINTENANCE_MAJ-CVE-et-Planifiee_V1
**Agent :** IT-MaintenanceMaster, IT-Assistant-N3
**Usage :** Communication interne pour mise à jour CVE urgente + briefing pré-maintenance
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — ALERTE CVE / PATCH URGENCE

```
═══════════════════════════════════════════════
ALERTE PATCH SÉCURITÉ URGENT
Date          : [YYYY-MM-DD]
Rédigé par    : [NOM TECHNICIEN]
Billet CW     : #[XXXXXX]
═══════════════════════════════════════════════

VULNÉRABILITÉ
CVE           : [CVE-YYYY-XXXXX]
CVSS Score    : [X.X] — [Critical / High / Medium]
Produit affecté : [Windows Server / Exchange / etc.]
Versions affectées : [Lister les versions]

DESCRIPTION FONCTIONNELLE
[Ce que la vulnérabilité permet — sans détails exploitables]

PATCH DISPONIBLE
Microsoft KB  : [KB XXXXXXX]
Source        : [URL Microsoft Security Update Guide]
Date de sortie : [Date]

CLIENTS AFFECTÉS (à vérifier dans CW/CMDB)
→ [Client 1] — [Versions détectées via RMM]
→ [Client 2]

PLAN D'ACTION
Priorité      : [Immédiat / Dans les 48h / Cycle normal]
Fenêtre requise : [Oui — après heures / Non — peut s'appliquer en production]
Rollback possible : [Oui (snapshot requis) / Non]

ACTIONS
[ ] Snapshot VMs critiques avant application
[ ] Appliquer via CW RMM / WSUS / Windows Update
[ ] Valider post-patch (Event Viewer + services)
[ ] Mettre à jour CMDB (date dernier patch)
[ ] Documenter dans CW avec résultats
═══════════════════════════════════════════════
```

---

## PARTIE 2 — BRIEFING PRÉ-MAINTENANCE (Équipe IT)

```
═══════════════════════════════════════════════
BRIEFING PRÉ-MAINTENANCE
Date/Heure    : [YYYY-MM-DD HH:MM]–[HH:MM]
Client        : [NOM]
Owner         : @[Technicien assigné]
Backup        : @[Technicien backup]
Billet CW     : #[XXXXXX]
Procédure     : [lien runbook ou playbook]
═══════════════════════════════════════════════

SCOPE
Serveurs/équipements : [Liste — sans IPs]
Ordre d'intervention : [Non-critiques → critiques]
Approbation reboots  : ☐ Reçue / ☐ À confirmer

POINTS D'ATTENTION
→ [Risque 1 — ex: SRV-SQL01 = serveur de production actif]
→ [Risque 2 — ex: Pas de DC secondaire]

PRÉREQUIS VALIDÉS
[ ] Backup/snapshot < 24h confirmé pour serveurs critiques
[ ] Fenêtre de maintenance approuvée par client
[ ] Accès admin validé (RDP/RMM)
[ ] NOC alerté — monitoring renforcé pendant la fenêtre
[ ] Plan de rollback documenté

COMMUNICATION
Début : Annonce Teams au canal [NOM CANAL]
Fin   : Email rapport client dans les [2h] post-maintenance
═══════════════════════════════════════════════
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
<!-- SOURCE: CHECKLIST_MAINTENANCE_Pre-Maintenance_V1 -->
## CHECKLIST — Pré-Maintenance

# CHECKLIST_MAINTENANCE_Pre-Maintenance_V1
**Agent :** IT-MaintenanceMaster, IT-Assistant-N3
**Usage :** Avant toute maintenance planifiée (patching, redémarrage, déploiement)
**Mis à jour :** 2026-03-20

---

## PRÉ-MAINTENANCE — À compléter AVANT de commencer

### Contexte et autorisation
- [ ] Billet CW ouvert : #_______
- [ ] Fenêtre de maintenance confirmée : _______ à _______ (heure locale)
- [ ] Approbation reboots obtenue : ☐ Oui  ☐ Non requis
- [ ] Client informé (email/Teams J-48h) : ☐ Fait  ☐ Non requis
- [ ] Équipe IT briefée : ☐ Fait  ☐ Solo

### Backup et snapshots
- [ ] Backup récent confirmé (< 24h) pour chaque serveur critique
- [ ] Snapshot créé sur VMs critiques (avec nom conforme : @[Ticket]_Preboot_[VM]_SNAP_[Date])
- [ ] Point de restauration Datto validé (screenshot présent)
- [ ] Dernière restauration testée (mensuel) : ☐ OK  ☐ Non vérifié

### Vérifications système (par serveur)
- [ ] Espace disque > 10% libre sur C: et volumes data
- [ ] Services critiques démarrés et stables
- [ ] Pending reboot = False (ou reboot planifié dans cette fenêtre)
- [ ] Event Log : aucune erreur critique récente non résolue
- [ ] Sessions RDS actives vérifiées (si reboot prévu : utilisateurs avertis)

### Monitoring et accès
- [ ] Mode maintenance activé dans RMM (Datto RMM / N-able / CW RMM)
- [ ] Accès admin validé (RDP / RMM / Console)
- [ ] VPN connecté si intervention à distance
- [ ] Numéro de contact client d'urgence noté : _______

### Ordre d'intervention (pour plusieurs serveurs)
```
Ordre recommandé (critiques en dernier) :
1. Serveurs non-critiques / secondaires
2. Serveurs applicatifs (ERP, web, app)
3. Serveurs SQL / bases de données
4. Serveurs de fichiers
5. RDS / accès distant
6. Domain Controllers (en dernier — un seul à la fois)
```

### GO / NO-GO
- [ ] Toutes les cases ci-dessus validées → **GO**
- [ ] Au moins un item bloquant non résolu → **NO-GO — documenter dans CW et reprogrammer**


---
<!-- SOURCE: CHECKLIST_Precheck+Postcheck -->
## CHECKLIST — Precheck/Postcheck Générique

# CHECKLIST — PRECHECK (Generic Windows Server)

- [ ] Uptime / last boot
- [ ] Pending reboot (CBS/WU/PendingFileRename/CCM)
- [ ] CPU/RAM (si perf incident)
- [ ] Disques (C: + volumes data) — espace libre
- [ ] Services critiques (selon rôle)
- [ ] Sessions (RDS) si reboot prévu
- [ ] Event Logs: System/Application (Errors/Critical sur 1–2h)
- [ ] Backups : dernier job OK (si maintenance)
- [ ] Monitoring: alertes actives vs baseline



# CHECKLIST — POSTCHECK (Generic Windows Server)

- [ ] Host en ligne (ping/RMM)
- [ ] Services critiques OK
- [ ] Event Logs post-action: Kernel-Power, disk/NTFS, service failures
- [ ] Pending reboot = False (ou expliqué)
- [ ] App/partage/URL test rapide
- [ ] Monitoring back to green / alertes normalisées
- [ ] Backups: pas d'échec post-reprise

