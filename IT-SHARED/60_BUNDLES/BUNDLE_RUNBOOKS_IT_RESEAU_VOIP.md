# BUNDLE_RUNBOOKS_IT_RESEAU_VOIP
**Bundle Runbooks — IT MSP Intelligence Platform**
**Catégorie :** Réseau, Firewall, VPN, VoIP — Diagnostic et configuration
**Agents consommateurs :** @IT-NetworkMaster | @IT-VoIPMaster | @IT-UrgenceMaster | @IT-Commandare-NOC
**Version :** 1.0 | **Date :** 2026-04-04
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Repo GitHub :** `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_RESEAU_VOIP.md`

> Ce bundle regroupe tous les runbooks de la catégorie **Réseau, Firewall, VPN, VoIP — Diagnostic et configuration**.
> Uploader en Knowledge dans les GPT agents indiqués.
> Les runbooks sont à jour — source canonique dans GitHub.

---

## RB-RESEAU-001 — Diagnostic Réseau — LAN/WAN/VPN

# RUNBOOK — IT_NETWORK_DIAGNOSTIC_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Diagnostic réseau (symptômes -> hypothèses -> tests -> correctifs)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-SupportMaster`
- Steps (ordre canon) :
  - **support** → `IT-SupportMaster`
  - **network** → `IT-NetworkMaster`
  - **infra** → `IT-Commandare-Infra`
  - **report** → `IT-ReportMaster`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---

## RB-RESEAU-002 — Configuration Réseau — Setup initial

# RUNBOOK — Configuration et Diagnostic Réseau
**ID :** RUNBOOK__Network_Setup | **Version :** 2.0
**Agent owner :** IT-NetworkMaster | **Équipe :** TEAM__IT
**Domaine :** INFRA — Réseau
**Date révision :** 2026-03-13

---

## ⚠️ GARDE-FOUS — OBLIGATOIRES
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement la configuration réseau liée au billet actif.
Questions générales IT non liées au ticket → refus et redirection.

**Données sensibles :**
- ❌ JAMAIS : adresses IP dans les livrables client (note interne : toujours masquées aussi)
- ❌ JAMAIS : community strings SNMP, mots de passe switch/routeur, clés VPN
- Remplacer par `[IP MASQUÉE]`, `[CREDENTIALS RÉSEAU MASQUÉS]`
- Note de principe : les IPs sont exclues de TOUS les outputs, même internes

**Actions à risque :**
- Modification VLAN → `⚠️ Impact : interruption réseau potentielle`
- Modification règle firewall → `⚠️ Impact : coupure accès possible` + ticket dédié + approbation

---

## 1. Objectif
Procédures de configuration et de diagnostic réseau MSP :
- Configuration VLAN et switchs gérés
- Diagnostic connectivité LAN/WAN/VPN
- Configuration DNS/DHCP
- Dépannage Firewall (Fortinet, SonicWall, pfSense, Cisco)

---

## 2. Déclencheurs
- Nouveau VLAN à créer pour un client
- Problème de connectivité signalé (ticket support / alerte NOC)
- Onboarding réseau nouveau site
- Modification architecture (ajout équipement, changement ISP)

---

## 3. Diagnostic réseau — Lecture seule (prioritaire)

### 3.1 Tests de base depuis un poste Windows
```powershell
# Collecte complète (lecture seule — aucun impact)
$OutDir = "$env:TEMP\NET_DIAG"; New-Item -ItemType Directory $OutDir -Force | Out-Null

"=== Configuration réseau ===" | Tee-Object "$OutDir\net_config.txt"
ipconfig /all | Tee-Object -Append "$OutDir\net_config.txt"

"=== Table de routage ===" | Tee-Object "$OutDir\routing.txt"
route print | Tee-Object -Append "$OutDir\routing.txt"

"=== Résolution DNS ===" | Tee-Object "$OutDir\dns.txt"
Resolve-DnsName "google.com" -Type A -ErrorAction SilentlyContinue | Tee-Object -Append "$OutDir\dns.txt"
nslookup google.com | Tee-Object -Append "$OutDir\dns.txt"

"=== Test connectivité externe ===" | Tee-Object "$OutDir\connectivity.txt"
Test-NetConnection "8.8.8.8" -InformationLevel Detailed | Tee-Object -Append "$OutDir\connectivity.txt"
Test-NetConnection "1.1.1.1" -Port 443 | Tee-Object -Append "$OutDir\connectivity.txt"

"Diagnostics sauvegardés dans : $OutDir"
```

### 3.2 Diagnostic DNS/DHCP (serveur)
```powershell
# Services DNS et DHCP
Get-Service -Name DNS, DHCPServer -ErrorAction SilentlyContinue |
  Select-Object Name, Status, StartType | Format-Table -Auto

# Événements DNS (2 dernières heures, erreurs seulement)
$Start = (Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$Start} -ErrorAction SilentlyContinue |
  Where-Object {$_.LevelDisplayName -in 'Error','Critical','Warning'} |
  Select-Object -First 20 TimeCreated, Id, Message | Format-Table -Wrap

# Baux DHCP actifs (lecture seule)
Get-DhcpServerv4Scope -ErrorAction SilentlyContinue |
  Select-Object ScopeId, Name, State,
    @{n='Utilisés';e={(Get-DhcpServerv4ScopeStatistics -ScopeId $_.ScopeId).InUse}},
    @{n='Libres';e={  (Get-DhcpServerv4ScopeStatistics -ScopeId $_.ScopeId).Free}} |
  Format-Table -Auto
```

---

## 4. Configuration standard

### 4.1 VLAN — Checklist configuration
- [ ] Numéro VLAN défini et documenté (ex: VLAN 10 = Data, VLAN 20 = Voice, VLAN 99 = Mgmt)
- [ ] Switch(es) : VLAN créé, ports trunk/access configurés
- [ ] Routeur/Firewall : interface sous-interface ou L3 switch configuré
- [ ] DHCP scope créé pour le VLAN (plage, passerelle, DNS)
- [ ] Test de connectivité depuis un poste dans le VLAN

### 4.2 Configuration DNS statique (bonnes pratiques)
```powershell
# Ajouter un enregistrement A (lecture documentation — modifier via console DNS recommandé)
# Validation : tester la résolution après ajout
Resolve-DnsName "[FQDN]" -Server "[SERVEUR-DNS]" -Type A -ErrorAction SilentlyContinue
```

### 4.3 Checklist Firewall (générique)
- [ ] Règle créée avec scope minimal (principe du moindre privilège)
- [ ] Source/destination explicites (pas de ANY/ANY en production)
- [ ] Log activé sur la règle (traçabilité)
- [ ] Test après création (validation que le flux souhaité passe)
- [ ] Documentation dans CW : numéro de règle, objet, durée si temporaire

---

## 5. Dépannage — Arbres de décision

### Problème : site sans Internet

```
Étape 1 → Ping gateway locale  →  KO : problème LAN/switch/VLAN
                                →  OK : continuer
Étape 2 → Ping IP ISP          →  KO : contacter ISP
                                →  OK : continuer
Étape 3 → Résolution DNS        →  KO : DNS en panne ou MAL configuré
                                →  OK : problème applicatif
```

### Problème : VPN ne se connecte pas

```
1. Vérifier statut du service VPN (client et serveur)
2. Vérifier logs VPN (événements d'authentification)
3. Tester depuis réseau externe différent (exclure restriction ISP)
4. Vérifier certificat VPN (expiration ?)
5. Si MFA : vérifier que les codes sont acceptés (synchronisation temps)
→ Escalader IT-SecurityMaster si credentials compromis suspectés
```

---

## 6. Livrables CW

### Note interne
```
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Symptôme : [description]
Tests effectués : [liste des commandes — résultats synthétiques, IPs masquées]
Cause identifiée : [description] / [À CONFIRMER]
Action corrective : [FAIT / SUGGESTION]
Résultat : [OK / [À CONFIRMER]]
Prochaines étapes : [surveillance / test utilisateur / [aucune]]
```

### Discussion client (client-safe)
```
- Analyse de la demande et diagnostic de l'environnement réseau.
- [Action effectuée : ex: Reconfiguration du service DNS / correction du VLAN].
- Validation de la connectivité : [OK / en cours].
- Prochaine étape : [surveillance / test utilisateur / aucune action requise].
```

---

## 7. Escalade
- Incident réseau P1 (site down) → `IT-Commandare-NOC` immédiat
- Architecture complexe (SD-WAN, BGP, multi-sites) → `IT-NetworkMaster` + `IT-CTOMaster`
- Suspicion intrusion réseau → `IT-SecurityMaster` immédiat


---

## RB-RESEAU-003 — Diagnostic VoIP — Qualité audio, SIP, UC

# RUNBOOK — Diagnostic Téléphonie IP & VoIP MSP
**ID :** RUNBOOK__IT_VOIP_DIAGNOSTIC_V1  
**Version :** 1.0 | **Agent :** IT-VoIPMaster  
**Applicable :** Tout incident VoIP/UC (3CX, Teams Phone, SIP trunk, qualité audio)

---

## DÉCLENCHEURS
- Plainte qualité audio (écho, coupures, one-way audio)
- Téléphones ne s'enregistrent plus (registration failure)
- Trunk SIP en échec / pas de tonalité externe
- Teams Phone : appels entrants/sortants impossibles
- Dégradation MOS signalée par utilisateurs

---

## ÉTAPE 1 — QUALIFICATION INITIALE (5 min)

Répondre aux questions :
1. Quel système VoIP ? (3CX / Teams Phone / Cisco CUCM / Mitel / RingCentral / autre)
2. Symptôme précis ? (pas de son / son unidirectionnel / écho / coupures / registration fail)
3. Affecté : 1 poste / un site complet / tous les sites ?
4. Depuis quand ? Changement récent ? (mise à jour, changement réseau, nouveau fournisseur SIP)
5. Appels internes affectés ? Externes ? Les deux ?

**Diagnostic préliminaire :**
- Interne seulement → problème PBX/VLAN/config locale
- Externe seulement → problème trunk SIP / fournisseur
- Interne + externe → problème réseau/QoS ou PBX global

---

## ÉTAPE 2 — TESTS RÉSEAU (10-15 min)

### 2.1 Test latence et jitter vers trunk SIP
```powershell
# Test ping vers IP du trunk SIP (remplacer X.X.X.X)
# ⚠️ Info : lecture seule, aucun impact
Test-NetConnection -ComputerName "sip.provider.com" -Port 5060

# Ping continu pour mesurer jitter
ping -t sip.provider.com | Measure-Object
```

**Seuils :**
- Latence OK : < 80ms | Warning : 80-150ms | Critique : > 150ms
- Packet loss OK : 0% | Warning : 0.5-1% | Critique : > 1%

### 2.2 Vérifier VLAN Voice
```powershell
# Vérifier configuration réseau sur poste VoIP
ipconfig /all | Select-String "IPv4|VLAN"
# Confirmer VLAN Voice séparé du data (bonne pratique)
```

### 2.3 Vérifier QoS
- Confirmer DSCP EF (46) taggé pour flux RTP
- Confirmer politique QoS active sur switch/routeur
- Sur switch Cisco : `show mls qos interface` ou `show policy-map interface`

---

## ÉTAPE 3 — DIAGNOSTIC PAR SYMPTÔME

### Symptôme A : Registration SIP échoue
```
Causes probables :
1. Credentials SIP incorrects (username/password/domain)
2. Firewall bloque UDP 5060 ou TCP 5061
3. NAT traversal mal configuré (STUN/TURN)
4. Serveur SIP inaccessible (résolution DNS)

Tests :
- Depuis PBX : nslookup sip.provider.com
- Wireshark sur port 5060 : capture 401 Unauthorized vs timeout
- Tester depuis hors NAT (connexion directe) pour isoler NAT
```

### Symptôme B : Audio unidirectionnel (one-way audio)
```
Cause quasi-certaine : problème NAT / RTP ports bloqués

Tests :
- Vérifier port range RTP ouvert (typique : UDP 10000-20000)
- Vérifier STUN server configuré dans PBX
- Tester avec softphone sur réseau différent
- Wireshark : flux RTP reçu d'un seul côté
```

### Symptôme C : Écho ou délai
```
Causes probables :
1. Latence WAN > 150ms → écho perceptible
2. AEC (Acoustic Echo Cancellation) désactivé sur téléphone
3. Haut-parleur trop fort côté distant

Tests :
- Mesurer latence vers trunk SIP (voir 2.1)
- Vérifier paramètres AEC dans config téléphone/PBX
- Tester avec casque vs haut-parleur
```

### Symptôme D : Teams Phone ne fonctionne pas
```
Checklist spécifique :
- Licence Phone System attribuée à l'utilisateur ? (Azure AD Admin Center)
- Direct Routing : SBC certifié et certificat valide ?
- Dial plan configuré ? (normalization rules)
- Voice routing policy assignée à l'utilisateur ?

Commandes PowerShell Teams :
# Vérifier licence
Get-MsolUser -UserPrincipalName user@domain.com | Select-Object Licenses
# Vérifier politique voix
Get-CsOnlineUser user@domain.com | Select-Object TeamsUpgradeMode, VoiceRoutingPolicy
```

---

## ÉTAPE 4 — VÉRIFICATIONS 3CX SPÉCIFIQUES

```
Dashboard 3CX :
- Status → Trunks : vérifier statut trunk (Registered/Unregistered)
- Status → Phones : vérifier registrations
- Logs → SIP trace : activer 5 min pour capturer erreurs

Ports à vérifier ouverts vers 3CX :
- TCP 5090 (Tunnel)
- UDP 9000-10999 (RTP media)
- TCP/UDP 5060-5061 (SIP)
- TCP 443, 5000-5001 (Web/Apps)
```

---

## ÉTAPE 5 — RÉSOLUTION ET DOCUMENTATION

### Après résolution :
- [ ] Test appel entrant + sortant validé
- [ ] Test qualité audio (MOS > 3.5 minimum, > 4.0 idéal)
- [ ] Documentation dans CW via IT-TicketScribe
- [ ] KB créé si problème non documenté

### Si non résolu :
- Escalader vers IT-NetworkMaster (problème réseau/QoS confirmé)
- Escalader vers IT-CloudMaster (Teams Phone/M365)
- Contacter fournisseur SIP trunk (si trunk side)


---

## RB-RESEAU-004 — Commandare NOC — Procédures NOC réseau

# RUNBOOK — IT_COMMANDARE_NOC

## Objectif

Commandare NOC: triage/diagnostic initial, sévérité, plan de réponse.

## Déclencheur

- Dès qu’une demande correspond à cet intent dans le routage, ou exécution manuelle.

## Owner

- TEAM__IT (Lead Ops IT)

## SLA cible


Voir la policy : `50_POLICIES/ops/sla.md`

- P1 (critique) : réponse < 15 min, mitigation < 60 min
- P2 (majeur)   : réponse < 1h, mitigation < 4h
- P3 (normal)   : réponse < 4h, mitigation < 2j
- P4 (faible)   : best effort

Règle :
- Si la demande est un **incident IT/OPS**, classifier **P1–P4** (section ci-dessous) et appliquer le SLA correspondant.
- Sinon (requête non-incident), classer **P4** par défaut.

## Logging (OPS) — obligatoire
Référence : `50_POLICIES/ops/logging_schema.md`

Chaque exécution doit produire un log (au minimum) avec :
- request_id
- timestamp
- caller_actor_id
- target_actor_id
- playbook_id
- step_id
- artifacts[]
- log.decisions[]
- log.risks[]
- log.assumptions[]

Règle : le **output final** doit contenir `request_id` et un résumé des décisions/risques.

## Incident severity (P1–P4)
Référence : `50_POLICIES/ops/incident_severity.md`

- P1 : panne totale / données à risque / sécurité
- P2 : fonctionnalité clé KO / impact large
- P3 : bug contournable / impact limité
- P4 : amélioration / dette

Règle : pour tout incident, inclure `incident_severity` dans l’output final + dans le log.

## Inputs attendus
- Demande utilisateur (texte brut) + contexte (dossier/ticket).
- Intent (si déjà détecté) ou signal d’incident (si applicable).
- Contraintes : délais, périmètre, systèmes concernés.

## Outputs attendus
- Résultat final actionnable (résolution / dispatch / KB / décision).
- `request_id` + (si incident) `incident_severity`.
- Artifacts référencés (liens/IDs) + log décisions/risques/assumptions.

## Étapes (alignées `40_RUNBOOKS/playbooks.yaml`)
1. **execute** → `IT-Commandare-NOC`

Règle : si une étape échoue, enregistrer l’échec via le logging OPS et appliquer l’escalade du playbook.

## Prérequis

- Accès aux agents impliqués.
- Dossier/ID de suivi (ticket, dossier client, ou dossier IA).
- Inputs complets (fichiers / texte / consignes).

## Étapes (exécution)

### Étape 1 — execute

- **Acteur** : `IT-Commandare-NOC`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


## Critères de Done

- Toutes les étapes exécutées sans erreur.
- Output final archivé (dossier/ticket mis à jour).
- Si applicable : décision/score final communiqué.

## Exceptions & escalade

- Output incohérent / incomplet → relancer l’étape 1 fois avec inputs clarifiés.
- Blocage persistant → escalader au owner d’équipe + `HUB-AgentMO2-DeputyOrchestrator`.

## Notes / Doc legacy

- N/A


---
