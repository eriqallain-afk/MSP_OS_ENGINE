# TEMPLATE_DIAG_PostPanneHQ.md
# Intervention — DIAG Post-Panne Hydro-Québec (HQ)
> Template MSP — à copier dans CW (notes internes + discussion client) et à archiver dans le dossier du ticket.
> **⚠️ IPs et chemins UNC : TOUJOURS masqués dans les livrables clients (Discussion + Email)**

---

## 1) Métadonnées (CW)

- **Ticket CW #** : [CW-XXXXX]
- **Client / Site** : [Client] — [Site / Adresse]
- **Priorité / SLA** : [P1/P2/P3] — [SLA]
- **Intervenant** : [Nom]
- **Date/Heure alerte (TZ America/Montreal)** : [YYYY-MM-DD HH:MM]
- **Canal TEAMS** : [#pannes-clients / lien message]
- **RMM Alert ID** : [ID]
- **Type d'incident** : ☐ Panne électrique ☐ Fluctuation ☐ Retour progressif ☐ Autre : [..]
- **Cause présumée** : ☐ Hydro-Québec ☐ UPS/Batterie ☐ Génératrice ☐ Équipement local ☐ Inconnu

---

## 2) Protocole — Réception & Validation Hydro-Québec

### 2.1 Réception de l'alerte

- ☐ Alerte reçue via **RMM**
- ☐ Visible dans **TEAMS** (canal pannes clients)
- ☐ Billet **pris en charge** dans CW (owner/assigné)

**Notice Teams — Alerte reçue (poster immédiatement) :**

**Titre :**
```
⚠️ Panne en cours — Billet : #[CW-XXXXX]
```
**Contenu :**
```
Panne électrique en cours chez [Client / Site]
Tâche principale : Validation Hydro-Québec et surveillance retour courant
Impact : Serveur(s) indisponible(s) — surveillance active
```

### 2.2 Validation portail Hydro-Québec

- **Portail Hydro-Québec** : ☐ Confirmée ☐ Non confirmée ☐ Indisponible
- **Heure de début estimée** : [HH:MM]
- **ETA rétablissement** : [HH:MM] / [Inconnu]
- **Zone / Référence** : [quartier / ref HQ si dispo]
- **Capture / preuve** : [lien / screenshot / note]

**Conclusion Hydro-Québec :**

- ☐ Panne liée à Hydro-Québec → mentionner dans TEAMS + CW
- ☐ Non lié / doute → poursuivre diag local (réseau / UPS / Internet)

**Notice Teams — Résultat validation :**

Panne confirmée HQ :
```
Titre   : ✅ Panne HQ confirmée — Billet : #[CW-XXXXX]
Contenu : Panne Hydro-Québec confirmée chez [Client / Site]
          Début : [HH:MM] | ETA rétablissement : [HH:MM]
          Impact : Serveur(s) indisponible(s) — surveillance active
```

Aucune panne HQ / doute :
```
Titre   : 🔍 Diagnostic local en cours — Billet : #[CW-XXXXX]
Contenu : Aucune panne HQ confirmée chez [Client / Site]
          Tâche principale : Diagnostic WAN / UPS / équipements locaux
          Impact : Serveur(s) indisponible(s) — investigation en cours
```

---

## 3) Périmètre impacté

### 3.1 Symptômes observés

- ☐ Serveurs offline RMM
- ☐ Hyperviseur inaccessible
- ☐ WAN down
- ☐ VPN down
- ☐ Téléphonie impactée
- ☐ Autres : [..]

### 3.2 Inventaire rapide (assets critiques)

> ⚠️ Les IPs sont à usage interne uniquement — ne jamais inclure dans la Discussion CW ou l'email client.

| Rôle | Nom | IP (interne) | Virtuel/Physique | Criticité | Statut initial |
|---|---|---|---|---|---|
| DC | [DC01] | [IP MASQUÉE] | [V/P] | Haute | ☐ Offline ☐ Online |
| Fichiers | [FS01] | [IP MASQUÉE] | [V/P] | Haute | ☐ Offline ☐ Online |
| SQL/App | [SQL01] | [IP MASQUÉE] | [V/P] | Haute | ☐ Offline ☐ Online |
| Hyperviseur | [HV01] | [IP MASQUÉE] | [V/P] | Critique | ☐ Offline ☐ Online |
| FW/Routeur | [FW01] | [IP MASQUÉE] | [V/P] | Critique | ☐ Offline ☐ Online |

---

## 4) Au retour du courant — Conditions lancement post-check

> Objectif : **prouver le retour** et décider **GO / NO-GO** (stabilité + services + erreurs).

### 4.1 Conditions de lancement

- ☐ Portail HQ indique rétablissement / retour stable
- ☐ Équipements (FW/switch/ISP) de retour
- ☐ Agents RMM online (au moins partiel)
- ☐ Fenêtre de surveillance active : [durée]

**Notice Teams — Retour courant détecté :**
```
Titre   : 🔄 Retour courant — Billet : #[CW-XXXXX]
Contenu : Retour courant détecté chez [Client / Site]
          Tâche principale : Validation post-panne des serveurs
          Impact : Serveur(s) en cours de redémarrage — validation en cours
```

---

## 5) Exécution script RMM — Post-Panne / Retour Serveur

- **Nom du script** : [PowerReturn_PostPanne]
- **Paramètres** : LookbackHours=[3] / MinUptimeMinutes=[10] / IncludeDCChecks=[true] / IncludeNetworkTests=[true]
- **Chemin log (preuve)** : [C:\...\POST-PANNE_YYYYMMDD_HHMMSS.log] / [RMM output]

### 5.1 Résultats par serveur

#### Serveur : [NOM]

- **Timestamp** : [YYYY-MM-DD HH:MM:SS]
- **Uptime** : [0d Xh Ym] — **LastBoot** : [YYYY-MM-DD HH:MM]
- **Pending reboot** : ☐ Oui ☐ Non
- **Disques** : ☐ OK ☐ Alerte — détails : [..]
- **Services auto arrêtés** : ☐ Aucun ☐ Oui : [liste]
- **Services critiques** : ☐ OK ☐ KO : [liste]
- **EventLogs (System/App)** : ☐ OK ☐ Erreurs notables : [IDs/Providers]
- **Outage indicators** (41/6008/6005/6006/1074) : ☐ Présents ☐ Non
- **Réseau** : GW ping ☐ OK ☐ KO — DNS externe ☐ OK ☐ KO
- **DC checks** (si DC) : SYSVOL/NETLOGON ☐ OK ☐ KO — Réplication ☐ OK ☐ KO
- **Statut** : ✅ GO ☐ / ❌ NO-GO ☐
- **Raison GO/NO-GO** : [..]
- **Actions immédiates** : [..]

> **Output brut (optionnel)**
```text
[Coller ici le bloc SUMMARY / ISSUES / Proof log]
```

---

## 6) Interprétation & Décision GO / NO-GO (global)

### 6.1 Critères GO (minimum)

- ☐ Serveur accessible (RMM/ICMP/WinRM selon contexte)
- ☐ Uptime > [10–15] minutes (ou services stabilisés)
- ☐ Aucun pending reboot bloquant (ou documenté + planifié)
- ☐ Services critiques (AD/DNS/SQL/IIS/etc.) Running
- ☐ Disques > 10% libres (ou risque contrôlé)
- ☐ Pas d'erreurs EventLog post-retour critiques non expliquées
- ☐ Réseau OK (GW + DNS externe)

### 6.2 Critères NO-GO (bloquants)

- ☐ Services critiques arrêtés (AD/SQL/DNS/Netlogon/KDC…)
- ☐ Erreurs EventLog répétées sur composants critiques (storage, AD, SQL, NIC)
- ☐ Disque plein / corruption / VSS writers en erreur persistante
- ☐ Réseau instable (GW/DNS KO) ou WAN down
- ☐ Réplication AD en échec / SYSVOL absent (si DC)

### 6.3 Décision finale

- **Global** : ✅ GO ☐ / ❌ NO-GO ☐
- **Justification** : [résumé 2–5 lignes]
- **Actions avant GO** (si NO-GO) : [..]

---

## 7) Actions correctives / Remédiations (si nécessaire)

| Action | Serveur | Détails | Responsable | Statut |
|---|---|---|---|---|
| Redémarrer service | [DC01] | [service] / [raison] | [Nom] | ☐ Fait ☐ À faire |
| Ajuster start type | [..] | [Auto → Disabled] | [..] | ☐ Fait ☐ À faire |
| Vérif time sync | [DC01] | VMware Tools / W32Time / PDC | [..] | ☐ Fait ☐ À faire |
| Vérif VSS/Writers | [..] | vssadmin list writers | [..] | ☐ Fait ☐ À faire |
| Test backup | [..] | job test / restore test | [..] | ☐ Fait ☐ À faire |

---

## 8) Communications TEAMS — Journal chronologique

### 8.1 Journal à poster (copier/coller en temps réel)

```
[HH:MM] ⚠️ Alerte panne reçue — prise en charge CW#[XXXXX]
[HH:MM] 🔍 Validation Hydro-Québec : [confirmée / non confirmée] (ETA: [HH:MM])
[HH:MM] 🔄 Retour courant détecté — début validations serveurs
[HH:MM] ✅/❌ Résultat GO/NO-GO — [résumé impacts restants]
[HH:MM] 🏁 Fin de surveillance — billet [fermé / en suivi]
```

### 8.2 Message résultat — client-safe

**✅ Retour confirmé :**
```
Titre   : ✅ Intervention terminée — Billet : #[CW-XXXXX]
Contenu : Intervention terminée chez [Client / Site]
          Tâche principale : Validation post-panne Hydro-Québec
          Statut : Serveurs opérationnels — services validés
```

**⚠️ Retour partiel :**
```
Titre   : ⚠️ Intervention en cours — Billet : #[CW-XXXXX]
Contenu : Validation en cours chez [Client / Site]
          Tâche principale : Correction post-panne — services en stabilisation
          Impact : Certains services nécessitent une action corrective
```

---

## 9) Notes CW — blocs prêts à coller

### 9.1 CW Note Interne (technique)

```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #[XXXXX] — [Client] — Post-panne Hydro-Québec — [YYYY-MM-DD]
Début : [HH:MM] | Fin : [HH:MM] | Durée : [XhYm]

CONTEXTE :
Alerte RMM [HH:MM] — [description symptômes].
Panne HQ [confirmée / non confirmée] — [ref HQ si dispo].

PRECHECK / RÉSULTATS SCRIPT :
[HH:MM] — [Serveur] : Uptime=[Xh] | PendingReboot=[O/N] | Services=[OK/KO] | Disque C=[X%]
[HH:MM] — [Serveur] : [même structure]
[HH:MM] — DC checks : réplication=[OK/KO] | Netlogon=[OK/KO] | SYSVOL=[OK/KO]

DÉCISION GO/NO-GO : [GO / NO-GO]
Justification : [résumé]

ACTIONS EFFECTUÉES :
[HH:MM] — [Action 1] → [Résultat]
[HH:MM] — [Action 2] → [Résultat]

VALIDATION POST-RETOUR :
✓ Services critiques : [liste] → OK
✓ Réseau (GW/DNS) : OK
✓ Réplication AD : OK (si DC)
✓ Sauvegardes à valider : [planifié / vérifié]

STATUT FINAL : ✅ Stable / ⚠️ À surveiller / ❌ Escalade
PIÈCES JOINTES : [POST-PANNE_YYYYMMDD.log]
```

### 9.2 CW Discussion (client-safe — facturable)

```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

INTERVENTION: Post-panne Hydro-Québec — Validation retour serveurs
DATE: [YYYY-MM-DD]
TECHNICIEN: [Initiales]

TRAVAUX EFFECTUÉS :
• Prise en charge de l'alerte et validation de la situation Hydro-Québec
• Surveillance du rétablissement du courant et des équipements réseau
• Exécution des vérifications post-retour sur les serveurs critiques
• Validation des services essentiels (authentification, accès aux données, applications)
• Validation de l'état des sauvegardes post-retour

RÉSULTAT :
• Serveurs opérationnels — services essentiels confirmés fonctionnels
• Aucune perte de données identifiée lors de la validation

RECOMMANDATION : (si applicable)
• [Surveillance recommandée X heures / validation sauvegardes planifiée]
```

---

## 10) Suivi (Post-incident)

- ☐ Vérifier sauvegardes (jobs post-retour + VSS writers)
- ☐ Vérifier intégrité AD (réplication, SYSVOL) si DC
- ☐ Vérifier stockage (SMART/RAID/iLO/iDRAC) si erreurs
- ☐ Planifier correctifs (TPM/SecureBoot certs si applicable)
- ☐ Ajouter leçons apprises / amélioration runbook

---

## 11) Clôture

- **Heure fin intervention** : [HH:MM]
- **Durée totale** : [XhYm]
- **Statut final** : ✅ Stable ☐ / ⚠️ À surveiller ☐ / ❌ Escalade ☐

**Escalade vers :**

| Agent | Quand |
|---|---|
| ☐ @IT-Commandare-Infra | Serveurs / VMs / hyperviseur / stockage |
| ☐ @IT-Commandare-NOC | Coordination opérations NOC post-panne |
| ☐ @IT-NetworkMaster | Réseau / firewall / WAN / VPN instable |
| ☐ @IT-BackupDRMaster | Validation sauvegardes / DR post-retour |
| ☐ @IT-MonitoringMaster | Alertes RMM persistantes / faux positifs post-panne |
| ☐ @IT-VoIPMaster | Téléphonie impactée |
| ☐ @IT-SecurityMaster | Comportement suspect post-panne |

**Pièces jointes / preuves :** [log], [captures], [exports]

**Notice Teams — Clôture :**
```
Titre   : ✅ Intervention terminée — Billet : #[CW-XXXXX]
Contenu : Intervention terminée chez [Client / Site]
          Tâche : Validation post-panne Hydro-Québec
          Statut : Systèmes opérationnels — aucune anomalie critique

```
