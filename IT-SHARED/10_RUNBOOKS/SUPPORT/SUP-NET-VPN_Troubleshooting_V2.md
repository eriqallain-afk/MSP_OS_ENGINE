# SUP-NET-VPN_Troubleshooting_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Assistant-N2 | @IT-FrontLine | @IT-MaintenanceMaster | @IT-SysAdmin
**Département :** SUP | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__VPN_Client_Troubleshooting_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** SUPPORT — VPN utilisateur
**Mis à jour :** 2026-03-20

---

## 1. ARBRE DE DÉCISION VPN

```
L'utilisateur ne peut pas se connecter au VPN
│
├─ Pas de connexion Internet de base
│   → Résoudre d'abord la connexion Internet — le VPN ne peut pas fonctionner sans
│
├─ Le client VPN ne s'ouvre pas / plante
│   → Désinstaller / réinstaller le client VPN
│   → Vérifier la version du client (compatibilité OS)
│
├─ Erreur d'authentification (mauvais identifiants)
│   → Vérifier les identifiants (voir procédure)
│   → Vérifier si compte AD/M365 verrouillé ou expiré
│   → Vérifier MFA / DUO
│
├─ Erreur de connexion (timeout, serveur inaccessible)
│   → Vérifier l'adresse du serveur VPN dans la configuration client
│   → Vérifier que les ports VPN ne sont pas bloqués (FAI, autre firewall)
│   → Tester depuis un autre réseau (5G mobile)
│
└─ VPN connecté mais aucun accès aux ressources internes
    → Problème de routes ou de DNS VPN
    → Escalader réseau INFRA
```

---

## 2. VÉRIFICATIONS PRÉALABLES (TOUJOURS)

```
Avant de dépanner le VPN :

1. L'utilisateur a-t-il Internet ?
   → Ouvrir google.com dans un navigateur
   ✅ Fonctionne → problème VPN spécifique
   ❌ Ne fonctionne pas → résoudre d'abord Internet

2. La solution VPN du client est-elle documentée ?
   → Hudu → [Client] → Network Infrastructure → [Firewall/VPN]
   → Voir le type : WatchGuard SSL, FortiClient, SonicWall, Meraki Client VPN, etc.

3. Les identifiants VPN sont-ils corrects ?
   → Demander le nom d'utilisateur
   ⛔ NE JAMAIS demander le mot de passe — demander de le ressaisir
   → Vérifier que le compte n'est pas verrouillé dans AD
```

---

## 3. WATCHGUARD MOBILE VPN SSL

```
Client : WatchGuard Mobile VPN with SSL

Erreur "Cannot connect to the server" :
1. Vérifier l'adresse du serveur dans la config client
2. Vérifier depuis le poste : Test-NetConnection -ComputerName [GATEWAY] -Port 443
3. Vérifier que le port 443 n'est pas bloqué par le FAI de l'utilisateur
4. Essayer depuis un réseau différent (partage 4G/5G mobile)

Erreur d'authentification :
1. Vérifier les identifiants AD (même compte que Windows)
2. Vérifier que l'utilisateur est dans le bon groupe AD (ex: VPN_Users)
3. Vérifier le MFA/DUO si configuré
4. Vérifier dans WatchGuard Web UI : Authentication → Users (compte verrouillé ?)

Connecté mais pas accès aux ressources :
1. Vérifier que le client VPN obtient bien une IP du pool VPN
   → Cmd : ipconfig | find "tun"
2. Vérifier la table de routage
   → Cmd : route print | find "10." (ou le sous-réseau interne du client)
3. Tester un ping vers le DC
4. Si OK mais DNS KO : vérifier le DNS dans la config SSL VPN côté WatchGuard
```

---

## 4. FORTICLIENT (FORTINET)

```
Client : FortiClient VPN ou FortiClient EMS

Erreur "-7200" ou "Unable to logon to the server" :
→ Vérifier l'adresse du portail VPN dans FortiClient
→ Vérifier le port : généralement 443 ou 10443

Erreur de certificat :
→ Vérifier si le certificat du FortiGate est expiré
→ Option temporaire : désactiver la vérification du certificat (⚠️ non recommandé en production)

Réinstallation FortiClient :
1. Désinstaller FortiClient
2. Redémarrer le poste
3. Télécharger la version correcte depuis le portail du client ou Fortinet
4. Réinstaller → reconfigurer le portail VPN
```

---

## 5. SONICWALL NETEXTENDER

```
Client : NetExtender (SonicWall)

Erreur de connexion :
→ Vérifier l'adresse du serveur SSL VPN
→ Vérifier les identifiants (domain\username ou username seul selon la config)

Mise à jour NetExtender :
1. Désinstaller NetExtender
2. Aller sur le portail SSL VPN web : https://[SONICWALL]/sslvpn
3. Télécharger et réinstaller la dernière version

Erreur "Connection terminated" :
→ Peut être dû à des règles de session timeout sur le SonicWall
→ Escalader réseau INFRA avec les logs du client
```

---

## 6. CISCO ANYCONNECT / SECURE CLIENT

```
Client : Cisco AnyConnect / Cisco Secure Client

Réinstallation propre :
1. Désinstaller AnyConnect (Programmes et fonctionnalités)
2. Vérifier qu'aucun service Cisco VPN ne reste : services.msc → chercher "Cisco"
3. Redémarrer
4. Réinstaller depuis le portail ASA ou le package fourni

Erreur "VPN establishment capability for a remote user is disabled" :
→ Le profil VPN ne permet pas les connexions à distance depuis cet appareil
→ Escalader réseau INFRA

Erreur de certificat :
→ Vérifier l'expiration du certificat sur l'ASA/FTD
→ Escalader INFRA si certificat expiré
```

---

## 7. MERAKI CLIENT VPN (IPSec natif Windows)

```
Utilise le client VPN natif Windows L2TP/IPSec

Dépannage connexion :
1. Vérifier Paramètres Windows → VPN → [Connexion VPN]
2. Vérifier l'adresse du serveur (IP publique du MX Meraki)
3. Vérifier la clé partagée (voir Passportal)
4. Vérifier les identifiants

Erreur "Error 789: L2TP connection failed" :
→ Souvent un problème de clé partagée incorrecte
→ Vérifier et reconfigurer la connexion VPN

Erreur "Error 800: Unable to establish VPN" :
→ Bloquer par un firewall ou le NAT de l'utilisateur
→ Tester depuis un réseau différent

Fix registre pour L2TP derrière NAT :
```powershell
# Activer le support NAT-T pour L2TP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent" `
    -Name "AssumeUDPEncapsulationContextOnSendRule" -Value 2 -Type DWord
Restart-Computer -Force  # Redémarrage requis
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS demander le mot de passe VPN à l'utilisateur — utiliser Passportal si nécessaire
⛔ NE JAMAIS modifier la configuration VPN côté serveur sans billet CW et approbation
⛔ NE PAS désactiver le MFA pour faciliter la connexion VPN
⛔ NE JAMAIS donner des informations sur l'adresse interne des serveurs via les appels
⛔ NE PAS ignorer une erreur de certificat expiré — escalader immédiatement INFRA
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Plusieurs utilisateurs VPN down simultanément | NOC | Immédiat |
| Certificat VPN expiré | INFRA | Dans l'heure |
| VPN connecté mais aucune ressource accessible | NOC / INFRA | 30 min |
| Compte AD verrouillé répété (possible brute force) | SOC | Dans l'heure |

```
