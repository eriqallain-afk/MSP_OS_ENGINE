# MAINT-SRV-AuditTrimestriel_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** MAINT | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__IT_AUDIT_TRIMESTRIEL_V1
**Catégorie :** MAINTENANCE / AUDIT
**Agents :** @IT-MaintenanceMaster | @IT-Assistant-N3 | @IT-CloudMaster | IT-SysAdmin
**Fréquence :** Trimestrielle (Q1 / Q2 / Q3 / Q4)
**Durée estimée :** 3-5h selon environnement
**Version :** 1.0 | **Date :** 2026-04-06

---

## PRÉREQUIS

- Accès administrateur AD, M365, Firewall, vCenter/Hyper-V
- Accès physique à la salle serveur
- Accès Passportal (credentials client)
- Billet CW ouvert — type : Maintenance / Audit
- Notice Teams envoyée avant le début

---

## TASK 1 — INFRASTRUCTURE (Serveurs & Environnement)

### Objectif
Valider l'état physique et logiciel de l'infrastructure serveur.

### Vérifications

**État physique de l'environnement**
- [ ] Température salle serveur dans les normes (< 27°C)
- [ ] Aucun voyant d'erreur visible sur les équipements rack
- [ ] Câblage organisé — aucun câble déconnecté ou endommagé
- [ ] Accès physique sécurisé (serrure, contrôle d'accès)

**État physique des appareils**
- [ ] Serveurs : voyants STATUS verts, ventilateurs fonctionnels
- [ ] Vérifier les journaux iDRAC / iLO / IPMI pour erreurs matérielles récentes
- [ ] Disques : état RAID validé (aucun disque dégradé ou manquant)

```powershell
# État disques et RAID via WMIC
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus
Get-VirtualDisk  | Select-Object FriendlyName, HealthStatus, OperationalStatus
```

**Applications non-utilisées**
- [ ] Inventorier les applications installées — identifier celles non utilisées depuis 90 jours
- [ ] Licences récupérables identifiées et documentées dans Hudu

```powershell
# Applications installées + date dernière utilisation
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
  Select-Object DisplayName, DisplayVersion, InstallDate |
  Where-Object {$_.DisplayName} | Sort-Object DisplayName | Format-Table
```

**État de désuétude (EOL/EOS)**
- [ ] Vérifier OS Windows Server : date fin support mainstream / extended
- [ ] Vérifier versions SQL Server, Exchange, IIS si applicable
- [ ] Documenter tout équipement EOL dans Hudu avec date planifiée de remplacement

**État du UPS**
- [ ] Autonomie affichée ≥ 80% de la capacité nominale
- [ ] Dernière date de test de bascule (< 6 mois)
- [ ] Date de remplacement batterie documentée dans Hudu
- [ ] Alertes email UPS configurées et testées

### Résolution Task 1
```
Statut : [ ] OK  [ ] Non-conformités détectées
Observations :
Actions requises :
Billet créé : # ____________
```

---

## TASK 2 — INFRASTRUCTURE (Appliances — NAS, PBX, NVR, etc.)

### Objectif
Valider l'état des équipements spécialisés et la récupérabilité des données critiques.

### Vérifications

**État des accès**
- [ ] Comptes administrateurs — MDP changé depuis < 90 jours (vérifier Passportal)
- [ ] Comptes réguliers — aucun compte inactif depuis > 30 jours
- [ ] Accès web management désactivé depuis Internet (sauf VPN)
- [ ] 2FA activé sur les interfaces d'administration si supporté

**État physique de l'environnement**
- [ ] Appliances accessibles, voyants normaux
- [ ] Température et ventilation correctes
- [ ] Câblage propre et étiqueté

**État UPS dédié appliances (si distinct)**
- [ ] Autonomie validée
- [ ] Batterie dans les normes

**État de désuétude des appliances**

| Équipement | Modèle | Firmware | EOL Date | Statut |
|---|---|---|---|---|
| NAS | | | | |
| PBX | | | | |
| NVR | | | | |
| Autre | | | | |

- [ ] Firmware à jour sur tous les équipements
- [ ] EOL documenté dans Hudu pour tout équipement à remplacer

**Test de recouvrement des données**
- [ ] NAS : test de restauration d'un fichier depuis la dernière sauvegarde
- [ ] PBX : configuration sauvegardée et restauration testée
- [ ] VPN : configuration exportée et sauvegardée dans Hudu/Passportal
- [ ] Résultat du test documenté avec date et technicien

**Validation renouvellement des contrats**
- [ ] Contrats de support/garantie — dates d'expiration vérifiées
- [ ] Abonnements ISP/mobiles — dates de renouvellement notées
- [ ] Alertes de renouvellement créées dans CW si < 90 jours

### Résolution Task 2
```
Statut : [ ] OK  [ ] Non-conformités détectées
Tests de recouvrement : [ ] Réussi  [ ] Échoué — Détails :
Contrats à renouveler :
Billet créé : # ____________
```

---

## TASK 3 — INFRASTRUCTURE RÉSEAU

### Objectif
Valider la configuration, la sécurité et la robustesse de l'infrastructure réseau.

### Vérifications

**Ports forwards — utilité**
- [ ] Lister tous les ports ouverts vers l'extérieur
- [ ] Valider qu'ils sont tous documentés et toujours nécessaires
- [ ] Supprimer ou désactiver les règles obsolètes
- [ ] Documenter la liste finale dans Hudu

**Validation DNS**
```powershell
# Vérification des enregistrements clés
Resolve-DnsName domaine.com -Type A
Resolve-DnsName domaine.com -Type MX
Resolve-DnsName domaine.com -Type TXT   # SPF / DKIM / DMARC
nslookup -type=SRV _ldap._tcp.domaine.local   # DNS AD interne
dcdiag /test:dns /v
```
- [ ] Enregistrements A, MX, TXT (SPF, DKIM, DMARC) valides
- [ ] DNS interne AD — SRV records présents et résolus
- [ ] Pas de zones zombies ou d'enregistrements obsolètes

**Validation DHCP**
```powershell
# État du DHCP
Get-DhcpServerv4Scope | Select-Object ScopeId, Name, State, StartRange, EndRange
Get-DhcpServerv4ScopeStatistics | Select-Object ScopeId, PercentageInUse, Free
Get-DhcpServerv4Lease | Where-Object {$_.LeaseExpiryTime -lt (Get-Date)} | Measure-Object
```
- [ ] Utilisation < 80% de l'étendue (sinon étendre ou nettoyer)
- [ ] Réservations documentées dans Hudu
- [ ] Baux expirés nettoyés

**Vérification VLANs**
- [ ] Segmentation VLAN conforme à la documentation Hudu
- [ ] Ports trunk configurés correctement
- [ ] VLAN management inaccessible depuis les VLANs utilisateurs
- [ ] Inter-VLAN routing conforme aux politiques de sécurité

**État physique câblage**
- [ ] Câblage patch panel propre et étiqueté
- [ ] Aucun câble endommagé visible
- [ ] Prises murales documentées dans Hudu
- [ ] Salle de télécoms propre et sécurisée

**État de vie des équipements réseau**

| Équipement | Modèle | Firmware actuel | EOL | Action |
|---|---|---|---|---|
| Firewall | | | | |
| Switch core | | | | |
| Switch accès | | | | |
| WAP | | | | |

- [ ] Firmware à jour sur tous les équipements réseau
- [ ] Équipements EOL documentés avec plan de remplacement

**Renouvellement ISP / Mobile**
- [ ] Contrat ISP — date d'expiration notée
- [ ] Lignes mobiles — date de renouvellement notée
- [ ] Alertes dans CW créées si < 90 jours

**Test de recouvrement système réseau**
- [ ] Configuration firewall sauvegardée (export + Hudu)
- [ ] Configuration switch(es) sauvegardée
- [ ] Test failover WAN validé (si redondance présente)
- [ ] VPN site-à-site testé — tunnel actif et fonctionnel

### Résolution Task 3
```
Statut : [ ] OK  [ ] Non-conformités détectées
Règles de pare-feu supprimées :
Équipements EOL identifiés :
Billet créé : # ____________
```

---

## TASK 4 — CLOUD / MICROSOFT 365

### Objectif
Valider la conformité, la sécurité et l'optimisation de l'environnement M365 et cloud.

### Vérifications

**Vérification des licences M365**
- [ ] Générer le rapport d'utilisation des licences (M365 Admin Center → Rapports → Utilisation)
- [ ] Identifier les licences non assignées ou assignées à des comptes inactifs
- [ ] Comparer le nombre de licences actives vs facturées
- [ ] Documenter les économies potentielles dans le billet CW

```powershell
# Licences assignées via PowerShell
Connect-MgGraph -Scopes "User.Read.All","Organization.Read.All"
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits,
  @{N='Total';E={$_.PrepaidUnits.Enabled}} | Format-Table
```

**Activité OneDrive sur les postes**
- [ ] Vérifier la synchronisation OneDrive sur les postes (aucune erreur persistante)
- [ ] Identifier les utilisateurs avec quota > 80%
- [ ] Vérifier les partages externes actifs et leur justification

**Vérification GPOs / Intune**
- [ ] Passer en revue les GPOs actives — supprimer les obsolètes
- [ ] Intune : appareils non-conformes identifiés et documentés
- [ ] Politiques de conformité Intune à jour (chiffrement, MFA, antivirus)

```powershell
# GPOs avec liens actifs
Get-GPO -All | Where-Object {$_.GpoStatus -ne 'AllSettingsDisabled'} |
  Select-Object DisplayName, GpoStatus, ModificationTime | Sort-Object ModificationTime -Descending
```

**Vérification utilisateurs actifs**
- [ ] Comptes sans connexion depuis > 90 jours — désactiver ou documenter
- [ ] MFA activé sur 100% des comptes (vérifier via Entra ID)
- [ ] Comptes admin dédiés — pas d'utilisation quotidienne pour les tâches standard
- [ ] Comptes de service — MDP non expirant, documentés dans Passportal

```powershell
# Dernière connexion des utilisateurs
Get-MgUser -All -Property DisplayName, UserPrincipalName, SignInActivity |
  Select-Object DisplayName, UserPrincipalName,
    @{N='DernièreConnexion';E={$_.SignInActivity.LastSignInDateTime}} |
  Where-Object {$_.DernièreConnexion -lt (Get-Date).AddDays(-90)} | Format-Table
```

**État des certificats SSL**
- [ ] Lister tous les certificats SSL (domaines publics + internes)
- [ ] Alerter si expiration < 60 jours
- [ ] Certificats wildcard — couvrent-ils tous les sous-domaines actifs ?

| Domaine | Émetteur | Expiration | Statut |
|---|---|---|---|
| | | | |
| | | | |

**Revalidation DNS des noms de domaine**
- [ ] Enregistrements MX pointent vers Exchange Online / Google
- [ ] SPF valide et inclut tous les expéditeurs autorisés
- [ ] DKIM configuré et sélecteurs actifs dans M365 Admin
- [ ] DMARC configuré avec politique minimale `p=quarantine`
- [ ] Date d'expiration du nom de domaine chez le registrar (> 60 jours)

```powershell
Resolve-DnsName domaine.com -Type MX
Resolve-DnsName domaine.com -Type TXT   # Chercher v=spf1
Resolve-DnsName _dmarc.domaine.com -Type TXT
Resolve-DnsName selector1._domainkey.domaine.com -Type TXT
```

### Résolution Task 4
```
Statut : [ ] OK  [ ] Non-conformités détectées
Licences récupérables :
Comptes désactivés :
Certificats SSL à renouveler :
Billet créé : # ____________
```

---

## CLÔTURE DE L'AUDIT

### Résumé global

| Section | Statut | Non-conformités | Billet suivi |
|---|---|---|---|
| Task 1 — Infrastructure | [ ] OK  [ ] ⚠️ | | |
| Task 2 — Appliances | [ ] OK  [ ] ⚠️ | | |
| Task 3 — Réseau | [ ] OK  [ ] ⚠️ | | |
| Task 4 — Cloud / M365 | [ ] OK  [ ] ⚠️ | | |

### Actions post-audit
- [ ] Billets créés pour toutes les non-conformités
- [ ] Documentation Hudu mise à jour (versions firmware, dates contrats, EOL)
- [ ] Rapport d'audit transmis au client si requis
- [ ] Prochain audit planifié dans CW

### CW — Note Interne
```
Prise de connaissance de la demande et consultation de la documentation du client.

Audit trimestriel [Q_] [ANNÉE] complété pour [CLIENT].
Technicien : [Initiales] | Durée : [Xh]
Non-conformités : [N] | Billets créés : [N]
```

### CW — Discussion
```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

TRAVAUX EFFECTUÉS :
• Audit de l'infrastructure physique (serveurs, UPS, câblage)
• Audit des appliances et validation des tests de recouvrement
• Audit réseau (firewall, switches, DNS, DHCP, VLANs)
• Audit Cloud M365 (licences, utilisateurs, GPOs, certificats SSL, DNS)
• Documentation Hudu mise à jour
• [N] non-conformités documentées et billets de suivi créés

RÉSULTAT :
• Audit [Q_] [ANNÉE] complété
• [Statut global : Conforme / Non-conformités mineures / Actions requises]
```
