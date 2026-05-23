# INFRA-SRV-RDS_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__RDS_Operations_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-MaintenanceMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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
