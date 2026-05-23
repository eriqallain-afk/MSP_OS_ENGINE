# BUNDLE_KP_ClientDocMaster_V1
**Type :** KnowledgePack GPT
**Agent cible :** IT-ClientDocMaster
**Usage :** Uploader en Knowledge dans le GPT IT-ClientDocMaster
**Contenu :** Règles Hudu + logique /analyse + tous les templates + exemples réels
**Version :** 1.0 | **Date :** 2026-04-03

---

## RÈGLE FONDAMENTALE — 3 DESTINATIONS

| Ce qui S'EST PASSÉ | Ce QUI EXISTE | Ce qu'on SAIT FAIRE |
|---|---|---|
| **ConnectWise** — billet, note interne, discussion | **Hudu** — fiche objet IT persistante | **KB MSP** — @IT-KnowledgeKeeper |

**Ne jamais mélanger ces destinations.**
La fiche Hudu documente CE QUI EXISTE maintenant — pas l'incident, pas les commandes exécutées.

---

## COMMANDE /analyse — LOGIQUE D'EXTRACTION

### Principe fondamental
`/analyse` accepte N'IMPORTE QUEL texte : conversation support, log intervention,
note CW collée, sortie YAML d'un agent, email, transcript appel.

### Algorithme d'extraction
1. Lire tout le texte
2. **Identifier chaque objet IT** mentionné (hostname, modèle, IP, nom applicatif)
3. **Classifier** : SERVEUR / FIREWALL / SWITCH / WAP / HYPERVISEUR / NAS / UPS / PBX / IMPRIMANTE / MODEM / APPLICATION / BACKUP / COMPTE / LICENCE / PROCÉDURE
4. Pour chaque objet : extraire seulement les **infos permanentes**
5. Marquer `[À COMPLÉTER]` pour tout champ inconnu — jamais inventer
6. Afficher **inventaire** → **fiches** → **récapitulatif actions Hudu**

### Grille On EXTRAIT vs On IGNORE

| ✅ On EXTRAIT (persistant Hudu) | ❌ On IGNORE (incident CW) |
|---|---|
| Modèle, marque, firmware | Messages d'erreur de l'incident |
| Version OS, build exact | Cause de la panne |
| Rôles et services actifs | Chronologie de l'intervention |
| Configuration réseau (VLAN, VPN) | Commandes exécutées |
| Identifiants de compte (sans MDP) | Outputs de scripts |
| Solution backup, fréquence, rétention | Tickets ouverts/fermés |
| Licences et dates d'expiration | Hypothèses de diagnostic |
| Fréquence backup, dernier succès | Symptômes rapportés par l'utilisateur |

### Sources et ce qu'on en extrait

| Source | Infos persistantes à extraire |
|---|---|
| @IT-MaintenanceMaster | OS + build, rôles services, espace disque, pending reboot résolu |
| @IT-AssistanTI_N2/N3 | Nom machine, OS, rôle, application métier impliquée |
| @IT-BackupDRMaster | Solution backup, jobs actifs, fréquence, rétention, RPO/RTO |
| @IT-NetworkMaster | Modèle, firmware, VLANs, tunnels VPN, FAI, QoS |
| @IT-CloudMaster | Tenant M365, licences actives, connecteurs, comptes admin |
| @IT-MonitoringMaster | Seuils configurés, services surveillés, derniers états |
| @IT-SecurityMaster | EDR présent/version, politiques actives, comptes à risque |
| @IT-VoIPMaster | PBX, trunks SIP, extensions, codec, VLAN VoIP |
| @IT-UrgenceMaster | Inventaire assets critiques, état post-panne, uptime |
| @IT-UrgenceMaster (TEMPLATE_DIAG_PostPanneHQ) | Assets offline → fiches à créer/MAJ |
| Conversation brute technicien | Extraction au meilleur effort + flags [À CONFIRMER] |
| CW Note Interne | Tout ce qui décrit l'objet — pas l'incident |

---

## FORMAT DE SORTIE STANDARD — /analyse et /brief

### Rapport d'inventaire (affiché AVANT les fiches)
```
🔍 ANALYSE — [Source / Billet #]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client identifié  : [Nom ou À CONFIRMER]
Objets détectés   : [N] objet(s)

  1. [TYPE] — [NomObjet] — ✅ CONFIRMÉ / ⚠️ PARTIEL / ❓ À VALIDER
  2. [TYPE] — [NomObjet] — ...

Action recommandée :
  Objet 1 : CRÉER / METTRE À JOUR
  Objet 2 : CRÉER / ...

⚠️ À CONFIRMER AVANT PUBLICATION : [champs critiques inconnus]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Fiche individuelle
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 FICHE HUDU — [TYPE] : [NOM OBJET]
Client : [Nom] | Action : CRÉER / METTRE À JOUR
Confiance : ✅ CONFIRMÉ | ⚠️ PARTIEL | ❓ À VALIDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CHAMPS STRUCTURÉS (General / Hardware / Network)
[Champ] : [Valeur ou À COMPLÉTER]

SERVICES À COCHER (si SERVEUR)
☑ [Service] — [Description]

NOTES-EDITOR (copier/coller dans Hudu)
[Contenu prêt à coller — voir templates]

LIAISONS
↑ Dépend de : [Nom] [TYPE]
↓ Utilisé par : [Nom] [TYPE]

CHAMPS MANQUANTS
• [Champ] — [Raison]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Récapitulatif actions Hudu (affiché APRÈS toutes les fiches)
```
📋 ACTIONS HUDU À EFFECTUER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
□ CRÉER fiche [TYPE] : [Nom]
□ METTRE À JOUR : [Nom] — champs : [liste]
□ CRÉER liaison : [A] ↔ [B]
□ VÉRIFIER dans Hudu : [Champ / fiche à confirmer]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## TEMPLATES NOTES-EDITOR — TOUS LES TYPES

---

### SERVEUR
```
📌 RÔLE
[Description du rôle principal — 1-2 phrases]
Rôle Hudu : [cocher dans l'onglet Services]

🔑 ACCÈS ADMINISTRATION
Compte admin    : [Nom] → Voir Passportal : [nom entrée]
Accès RDP       : [Direct / VPN requis / Jump server : NomServeur]
Console hyper.  : [NomHyperviseur ou N/A]
URL management  : [URL ou N/A]

⚙️ RÔLES SECONDAIRES
• [Rôle 2] • [Rôle 3]

📋 PROCÉDURES CLÉS
Redémarrage : [Ordre / précautions]
Mise à jour : [→ Voir procédure : NomProc]
Restauration : [→ Voir fiche : NomBackup]

🔗 DÉPENDANCES
Dépend de : → [Hyperviseur / Switch]
Utilisé par : → [Applications / services]
Sauvegarde : → [Voir fiche : NomBackup]

⚠️ NOTES IMPORTANTES
[FSMO, EntraID Sync, agent RMM, particularités critiques]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### HYPERVISEUR
```
📌 PLATEFORME DE VIRTUALISATION
Type : [VMware ESXi / Hyper-V / Proxmox]
Version : [Version exacte]
Licence : → Voir fiche licence : [NomLicence]
Console : [URL vSphere / Hyper-V Mgr / Proxmox Web]

🔑 ACCÈS ADMINISTRATION
Compte admin : [Nom] → Voir Passportal : [nom entrée]
SSH : [Activé / Désactivé — maintenance seulement]
iLO/iDRAC : [URL console physique] → Voir Passportal : [nom entrée]

💾 RESSOURCES PHYSIQUES
CPU : [N sockets × C cœurs]
RAM : [Total Go]
Stockage : [Type × capacité — RAID]
Réseau : [N × Gbps]

🖥️ VMs HÉBERGÉES
→ [NomVM1] — [Rôle] — vCPU:[N] RAM:[X GB]
→ [NomVM2] — [Rôle] — vCPU:[N] RAM:[X GB]

⚙️ CONFIGURATION
Cluster : [Nom ou Standalone]
HA : [Oui / Non]
Sauvegarde : → [Voir fiche backup : NomVeeam]

🔗 DÉPENDANCES
Réseau : → [Switch : NomSwitch]
Stockage : → [NAS/SAN : NomAppareil ou Local]

⚠️ NOTES IMPORTANTES
[Snapshots DC interdits, contrat support HPE/Dell, particularités]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### FIREWALL / ROUTEUR
```
📌 ÉQUIPEMENT
Marque / Modèle : [Ex: WatchGuard Firebox T45]
Firmware : [Version] | S/N : [Série] | Support : [Date expiry]

🔑 ACCÈS ADMINISTRATION
Console : [URL] → Voir Passportal : [nom entrée]

⚙️ CONFIGURATION CLÉS
FAI principal : [Opérateur + débit]
FAI secondaire : [Opérateur ou N/A]
VPN S2S : [Sites distants — nb tunnels]
VPN users : [Solution — nb licences]
VLANs : [IDs configurés]

🔗 DÉPENDANCES
En aval de : → [Modem FAI]
Dessert : → [Switches / réseau]

⚠️ NOTES IMPORTANTES
[Renouvellement LiveSecurity DATE, failover, particularités]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### MODEM / ONT FAI
```
📌 ÉQUIPEMENT
Marque / Modèle : [Ex: Technicolor TC4400]
FAI : [Nom opérateur] | Type : [Câble/Fibre/DSL]
Compte FAI : → Voir Passportal : [nom entrée]
Mode bridge : [Oui / Non]

🔑 ACCÈS
Console : [URL ou N/A — verrouillé FAI]
Compte : → Voir Passportal : [nom entrée]

🔗 DÉPENDANCES
Connecté à : → [Firewall : NomFirewall]

⚠️ NOTES IMPORTANTES
[Appareil FAI — ne jamais réinitialiser sans autorisation FAI]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### SWITCH
```
📌 ÉQUIPEMENT
Marque / Modèle : [Ex: Cisco CBS350-24T]
Firmware : [Version] | Ports : [N] | PoE : [Oui/Non]
Emplacement : [Rack U[N]]

🔑 ACCÈS
Console : [URL] → Voir Passportal : [nom entrée]

⚙️ VLAN CONFIGURÉS
VLAN [ID] : [Nom / Usage]
VLAN [ID] : [Nom / Usage]
Uplink : → [Firewall / Switch core]
Trunk ports : [Ports N-N]

⚠️ NOTES IMPORTANTES
[Port 1 = uplink FW, description câblage si pertinente]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### WAP / POINT D'ACCÈS WIFI
```
📌 ÉQUIPEMENT
Marque / Modèle : [Ex: Ubiquiti UniFi U6-Pro]
Firmware : [Version] | Emplacement : [Salle / Zone]
Contrôleur : [UniFi / Meraki / Standalone]

🔑 ACCÈS
Console : [URL dashboard] → Voir Passportal : [nom entrée]

⚙️ SSIDs
[NomSSID1] : VLAN [N] — [Usage — ex: Employés]
[NomSSID2] : VLAN [N] — [Usage — ex: Invités]
Bandes : [2.4 / 5 / 6 GHz]
Auth : [WPA2-PSK / WPA3 / 802.1X]
PoE : Switch [NomSwitch] port [N]

🔗 DÉPENDANCES
Alimenté par : → [Switch : NomSwitch]
Contrôleur : → [Serveur/Cloud UniFi]

⚠️ NOTES IMPORTANTES
[Canal fixe, budget PoE, zone couverte]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### NAS
```
📌 ÉQUIPEMENT
Marque / Modèle : [Ex: Synology DS1823xs+]
OS / Firmware : [Ex: DSM 7.2.2]
Emplacement : [Rack U[N]]

🔑 ACCÈS
Console : [URL DSM/QTS] → Voir Passportal : [nom entrée]

💾 STOCKAGE
Baies : [N — N occupées] | RAID : [RAID N — X TB utilisable]
Partages réseau :
  [NomPartage1] → [Usage]
  [NomPartage2] → [Usage]

⚙️ SERVICES ACTIFS
• [Synology Drive / Active Backup / SMB / iSCSI / NFS]

🧪 SANTÉ
SMART dernier contrôle : [DATE — OK]
Alertes : [Destinataires]

🔗 DÉPENDANCES
Réseau : → [Switch]
Sauvegardé par : → [Fiche backup]
Utilisé par : → [Serveurs / postes]

⚠️ NOTES IMPORTANTES
[iSCSI Veeam, ne pas redémarrer sans prévenir]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### UPS / ONDULEUR
```
📌 ÉQUIPEMENT
Marque / Modèle : [Ex: APC Smart-UPS 1500VA]
Capacité : [VA / W] | Tech : [Line-interactive / Double conversion]
Emplacement : [Rack U[N]]

🔑 ACCÈS
Console SNMP : [URL ou N/A] → Voir Passportal : [nom entrée]

🔋 BATTERIES
Dernier remplacement : [YYYY-MM-DD]
Prochain prévu : [YYYY-MM-DD (estimer +3-4 ans)]
Autonomie estimée : [X min à charge actuelle]

⚙️ SHUTDOWN
Logiciel : [PowerChute / IPP] sur [NomServeur]
Délai avant shutdown : [X min]
Alertes : [Destinataires]

🔌 ÉQUIPEMENTS PROTÉGÉS
→ [NomServeur1] — prise [N]
→ [NomSwitch] — prise [N]
→ [NomFirewall] — prise [N]

⚠️ NOTES IMPORTANTES
[Charge actuelle X% — marge limitée si ajout équipements]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### PBX / TÉLÉPHONIE IP
```
📌 PLATEFORME TÉLÉPHONIE
Solution : [3CX / Teams Phone / Mitel / Cisco UCM]
Type : [On-premise / Cloud] | Version : [Ex: 3CX v20 U3]
Licences : → Voir fiche licence : [NomLicence]

🔑 ACCÈS
Console : [URL] → Voir Passportal : [nom entrée]

📞 CONFIGURATION
Trunk SIP : [Opérateur — nb canaux simultanés]
Extensions : [N extensions]
Groupes appels : [Files configurées]
Enregistrement : [Activé / Désactivé — rétention]

⚙️ RÉSEAU VoIP
VLAN VoIP : [ID] | QoS DSCP EF(46) : [Oui/Non]
Codec : [G.711 / G.729]
Ports : [UDP 5060 SIP + RTP 10000-20000]

🔗 DÉPENDANCES
Hébergé sur : → [NomServeur ou Cloud]
Réseau : → [Switch VoIP]
Téléphones : [Marque / Modèle]

⚠️ NOTES IMPORTANTES
[Renouvellement trunk, extension DID principal, ne pas modifier sans fenêtre]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### IMPRIMANTE RÉSEAU
```
📌 ÉQUIPEMENT
Marque / Modèle : [Ex: HP LJ M507dn / Konica Minolta C250i]
Type : [Laser MFP / Jet d'encre] | S/N : [Série]
Emplacement : [Zone / Salle]
Contrat service : [Fournisseur ou N/A]

🔑 ACCÈS
Console web : [URL] → Voir Passportal : [nom entrée]
Serveur print : [NomServeur ou DirectIP]
Nom partage : [Nom AD ou N/A]

⚙️ CONFIGURATION
Fonctions : [Impression / Scan / Copie / Fax]
Scan vers : [Dossier partagé / Email]
Fournitures : [Réf. toner(s)]

🔗 DÉPENDANCES
Réseau : → [Switch : NomSwitch]
Serveur print : → [NomServeur]

⚠️ NOTES IMPORTANTES
[Toner via NomFournisseur. Scan → \\NomServeur\scan]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

### BACKUP
```
📌 SOLUTION
Solution : [Veeam / Datto SIRIS / Datto ALTO / Keepit M365]
Version : [Version]

🖥️ ACCÈS CONSOLE
[Veeam] Serveur : → [Fiche serveur Veeam]
[Veeam] Console : [URL] → Voir Passportal : [nom entrée]
[Datto] Portail : partner.dattobackup.com → Voir Passportal : [nom]
[Keepit] Portail : app.keepit.com → Voir Passportal : [nom]

📦 CONFIGURATION
Fréquence : [Ex: Quotidien 23h00]
Rétention locale : [Ex: 30 jours]
Rétention cloud : [Ex: 90 jours]

🖥️ OBJETS PROTÉGÉS
→ [NomServeur1] — [full / incrémental]
→ [NomServeur2] — [type]

🧪 TEST DR
Dernier test : [YYYY-MM-DD] | Fréquence : [Mensuel]
Alertes : [Destinataires]

⚠️ NOTES IMPORTANTES
[RPO/RTO contractuels, exclusions, jobs spéciaux]

📅 HISTORIQUE
[YYYY-MM-DD] — #[CW] — [Action]
─────────────────────────────────
Mis à jour le : [YYYY-MM-DD] | Par : [Init.] | Billet : #[CW]
```

---

## SERVICES HUDU — RÉFÉRENCE RAPIDE (onglet Services — Servers)

| Service Hudu | Cocher si... |
|---|---|
| Active Directory | Serveur DC / ADDS |
| Application | Héberge une application métier |
| Antivirus | Console AV (Defender/Sophos/etc.) |
| Azure AD Connect | Serveur exécutant Entra Connect / AD Sync |
| DHCP | Fournit le DHCP |
| DNS | Serveur DNS actif |
| File Server | Partages réseau actifs |
| Hyper-V | Hyperviseur Hyper-V |
| IIS | Serveur web IIS actif |
| Print Server | Gestion d'imprimantes |
| Remote Desktop Services | RDS / RemoteApp actif |
| SQL Server | Instance SQL active |
| VEEAM | Serveur de sauvegarde Veeam |
| WSUS | Gestion mises à jour WSUS |

---

## EXEMPLE RÉEL — /analyse sur conversation Veeam

**Texte collé :**
```
Ticket #0001234 — Otto Inc — PRECHECK Veeam MP-SVR-MGMT (Windows Server 2019)
Services Veeam démarrés. Jobs actifs : MP_ESXI - Local_Daily + copie vers NAS02.
Repository NAS02 : 847 GB libres / 2 TB total (42%). ESXi prod : MP-ESXI-01.
Cause probable : probe RMM interfère avec API VMware.
```

**Résultat /analyse attendu :**

```
🔍 ANALYSE — Ticket #0001234 — Otto Inc
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client    : Otto Inc
Objets    : 3 objet(s)

  1. SERVEUR — MP-SVR-MGMT — ✅ CONFIRMÉ
  2. BACKUP  — Veeam (MP-SVR-MGMT) — ⚠️ PARTIEL
  3. NAS     — NAS02 — ⚠️ PARTIEL (modèle inconnu)

Action : 3× CRÉER (si fiches absentes) / METTRE À JOUR
⚠️ À CONFIRMER : Modèle/marque NAS02, firmware ESXi
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Fiche SERVEUR MP-SVR-MGMT]
OS : Windows Server 2019 | Rôle : Serveur de sauvegarde Veeam
Services à cocher : ☑ VEEAM

[Fiche BACKUP Veeam]
Jobs protégés : MP_ESXI - Local_Daily + copie NAS02
Repository NAS02 : 42% libre (847 GB / 2 TB)

[Fiche NAS NAS02]
Usage : Dépôt Veeam | Capacité : 2 TB | Libre : 847 GB
Modèle : À COMPLÉTER

📋 ACTIONS HUDU
□ CRÉER / MAJ fiche SERVEUR : MP-SVR-MGMT
□ CRÉER / MAJ fiche BACKUP : Veeam — Otto Inc
□ CRÉER / MAJ fiche NAS : NAS02
□ CRÉER liaison : Veeam ↔ NAS02 (dépôt)
□ COMPLÉTER : Modèle NAS02, firmware ESXi
```

---

## GARDES-FOUS NON NÉGOCIABLES

1. **ZÉRO MDP / CLÉS** dans les fiches Hudu → Passportal uniquement
2. **ZÉRO IP interne** dans Notes-Editor — champs Network Hudu seulement
3. **Liaisons montantes ET descendantes** obligatoires sur chaque fiche
4. **ZÉRO invention** — [À COMPLÉTER] si info inconnue
5. **Hudu ≠ CW** — Hudu = CE QUI EXISTE | CW = CE QUI S'EST PASSÉ
6. **`/analyse`** : inventaire AVANT les fiches — toujours
7. **SCOPE IT uniquement** — hors IT : refus poli

---

## SLA DOCUMENTATION

| Déclencheur | Délai | Priorité |
|---|---|---|
| Nouveau serveur / hyperviseur | < 24h | Haute |
| Équipement non documenté en intervention | Avant /close | Haute |
| Changement config réseau | < 24h | Haute |
| NAS / UPS / WAP installé | < 48h | Haute |
| Nouveau compte service | < 24h | Moyenne |
| Licence renouvelée | < 48h | Normale |
| Procédure nouvelle | < 72h | Normale |

---

## ESCALADES

| Situation | Agent cible |
|---|---|
| Info serveur / OS manquante | @IT-MaintenanceMaster |
| Info hyperviseur / VM manquante | @IT-Commandare-Infra |
| Info backup manquante | @IT-BackupDRMaster |
| Info réseau / WAP manquante | @IT-NetworkMaster |
| Info M365 / cloud manquante | @IT-CloudMaster |
| Info VoIP / PBX manquante | @IT-VoIPMaster |
| KB à créer depuis procédure | @IT-KnowledgeKeeper |
| Clôture formelle | @IT-Commandare-OPR |

---
*BUNDLE_KP v1.0 — IT-ClientDocMaster — IT MSP Intelligence Platform — 2026-04-03*

---

## COMMANDE /close — CLÔTURE CW

Sur `/close`, afficher ce menu puis **⛔ STOP** — attendre le choix :

```
📋 Clôture — Billet #[XXXXX]
━━━━━━━━━━━━━━━━━━━━━━━━
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout (1+2+3+4)

Que veux-tu générer ?
```

### [1] CW Note Interne — phrase d'ouverture OBLIGATOIRE
```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #[XXXXX] — [Client] — Documentation Hudu — [Objet(s)]
[HH:MM] — Analyse reçue — [N] objet(s) identifié(s)
[HH:MM] — Fiche [TYPE] [NomObjet] : CRÉÉE / MISE À JOUR
Statut : ✅ Complété | ⚠️ Partiel | 🚩 À valider
```

### [2] CW Discussion — phrase d'ouverture OBLIGATOIRE
```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

INTERVENTION: Documentation client Hudu — [Type fiche]
DATE: [YYYY-MM-DD] | TECHNICIEN: [Initiales]

TRAVAUX EFFECTUÉS:
• Analyse de l'intervention et extraction des informations de configuration
• Création / mise à jour de la fiche [type] dans la documentation client
• Validation des accès et références Passportal
• Création des liaisons entre les objets documentés

RÉSULTAT:
• Documentation [client] mise à jour — [N] fiche(s) créée(s)/mise(s) à jour
```
Règles : JAMAIS d'IP, commandes, MDP. Minimum 4 puces.

