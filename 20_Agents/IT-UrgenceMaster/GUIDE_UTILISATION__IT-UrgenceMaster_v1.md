# Guide d'utilisation — @IT-UrgenceMaster (v1.0)
> **Pour :** Techniciens N2/N3 MSP — context live P1/P2 uniquement
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-UrgenceMaster ?

**IT-UrgenceMaster est le copilote MSP pour les urgences P1/P2 en contexte live.**

Il ne résout pas l'urgence seul — il guide le technicien pas à pas : qualification rapide, communication coordonnée, décisions sécurisées, escalade au bon agent, et clôture structurée.

| Ce qu'il fait | Ce qu'il ne fait pas |
|---|---|
| Qualifier la situation en quelques secondes | Prendre des décisions techniques seul |
| Forcer la notice Teams immédiate | Résoudre l'urgence sans technicien humain |
| Guider la validation GO / NO-GO | Toucher à un système soupçonné de compromission |
| Piloter la communication (client, direction, équipe) | Reboots multiples simultanés |
| Produire le bloc d'escalade structuré | Laisser un P1 sans escalade |
| Générer tous les livrables de clôture | |

> **Principe clé — dans cet ordre :**
> 1. Quel est le risque immédiat ?
> 2. Faut-il escalader tout de suite ?
> 3. Quelle notice Teams doit partir maintenant ?
> 4. Quelle est la prochaine action la plus sûre ?
> 5. Quel livrable faut-il produire ?

---

## Quand l'utiliser ?

- Panne électrique chez un client — systèmes indisponibles
- Réseau site complet down — utilisateurs bloqués
- Serveur de production critique inaccessible
- Incident sécurité suspecté (comportement anormal, alerte EDR, ransomware)
- Service essentiel P2 dégradé avec risque de dérapage P1
- Retour après panne — validation GO/NO-GO des systèmes
- Tu dois passer l'urgence à une autre équipe proprement (Flag Up)

---

## Les commandes principales

### `/urgence` — Démarrer la gestion d'une urgence

La commande centrale pour toute urgence non-panne-électrique.

**Usage :**
```
/urgence réseau down — Billet #77099
Client : Otto Group — Site principal
Depuis : 14h22 — 35 min d'impact
Symptôme : Tout le trafic internet coupé — firewall inaccessible
Utilisateurs affectés : 60
```

**Ce que tu obtiens :**
- Classification P1 ou P2 avec justification
- Notice Teams immédiate (à poster maintenant)
- Escalade recommandée si P1
- Plan d'action guidé si P2 (5 étapes de diagnostic prudent)
- Prochaine commande recommandée

---

### `/panne` — Panne électrique (Hydro-Québec ou locale)

**Usage :**
```
/panne — Billet #77105
Client : Otto Mfg — Site Laval
Heure alerte : 09:15
```

**Menu affiché :**
```
⚡ PANNE ÉLECTRIQUE — PROTOCOLE ACTIF

Billet CW # :
Client / Site :
Heure alerte :

[1] Panne confirmée Hydro-Québec
[2] Cause locale ou inconnue
[3] Fluctuation / retour progressif
```

**Ce que tu obtiens :**
- Protocole spécifique selon le type de panne
- Actifs critiques à identifier (DC / hyperviseur / firewall / NAS / téléphonie)
- Actions immédiates de mise en maintenance RMM
- Notice Teams initiale prête à poster
- Guide de préparation pour `/retour`

---

### `/retour` — Retour courant / service

À utiliser dès que le courant revient ou qu'un service se rétablit.

**Usage :**
```
/retour — Billet #77105
Courant revenu : 11h03
Client : Otto Mfg — Site Laval
Systèmes à valider : DC01, SRV-FILE01, SWITCH-CORE, NAS-BAK01
```

**Ce que tu obtiens :**
- Notice Teams "Retour détecté" immédiate
- Checklist GO / NO-GO par serveur :

```
Serveur : DC01 — Contrôleur de domaine
□ Accessible (RMM / ping / RDP / console)
□ Uptime > 10 min
□ Pending reboot : O/N
□ Services critiques démarrés
□ Disque C: > 10% libre
□ Event logs critiques revus
□ Réseau OK
□ Réplication AD / SYSVOL / NETLOGON OK
Décision : GO / NO-GO
```

---

### `/escalade` — Bloc de transfert structuré

Quand l'urgence doit être transférée à un agent spécialisé.

**Usage :**
```
/escalade infra
Billet #77099 — Réseau Otto Group
Firewall Fortinet inaccessible — suspicion panne matérielle
Actions tentées : redémarrage console hors bande — pas de réponse
Durée : 52 min — aucun progrès
```

**Ce que tu obtiens :**
```
[TRANSFERT → @IT-Commandare-Infra]
Billet : #77099 | Priorité : P1 | 2026-05-18 15:14
Technicien : [Initiales]

SYMPTÔME : Firewall Fortinet inaccessible — panne matérielle suspectée
IMPACT    : 60 utilisateurs sans internet — site complet bloqué
DURÉE     : 52 min

ACTIONS EFFECTUÉES :
1. Redémarrage console hors bande — pas de réponse
2. Vérification alimentation physique — voyants éteints

RAISON DU TRANSFERT : Intervention matérielle requise sur site
URGENCE : Immédiate
```

---

### `/flagup` — Passation sans résolution complète

Quand le diagnostic est terminé mais que l'intervention ne peut pas être clôturée proprement.

**Usage :**
```
/flagup — Billet #77110
Client : Otto Inc
Situation : Réplication AD en erreur depuis la panne. Diagnostic complet.
Correction requise : intervention N3 sur DC01 en dehors des heures.
Urgence de la suite : < 24h
```

**Ce que tu obtiens :**
- Note interne Flag Up complète
- Notice Teams `🚩` avec actions attendues et délai
- Actions requises clairement formulées pour l'équipe receveuse

---

### `/teams` — Générer une notice Teams

Génère la notice correspondante au moment de l'intervention.

**Usage :**
```
/teams
```

**Menu affiché :**
```
[1] Début d'urgence
[2] Cause / classification confirmée
[3] Retour détecté
[4] GO / NO-GO
[5] Flag Up / action requise
[6] Fin d'intervention
```

**Exemples de notices :**
```
⚠️ P1 — Panne en cours — Billet : #77099
Réseau site complet inaccessible chez Otto Group
Tâche principale : Diagnostic firewall — escalade @IT-Commandare-Infra
Impact : 60 utilisateurs bloqués — intervention en cours

✅ Intervention terminée — Billet : #77099
Réseau rétabli chez Otto Group
Tâche principale : Remplacement firewall défectueux
Impact : Systèmes opérationnels — surveillance normale
```

---

### `/status` — Résumé rapide de l'urgence en cours

**Usage :**
```
/status
```

**Ce que tu obtiens :**
```
📊 STATUS URGENCE
Billet      : #77099
Client      : Otto Group
Type        : Réseau site down
Priorité    : P1
Phase       : Escalade infra — attente intervention sur site
Durée       : 1h12
Statut      : Escaladé → @IT-Commandare-Infra
Teams       : 14:28 — escalade notifiée
Prochaine   : Confirmation arrivée technicien sur site
```

---

### `/close` — Clôture de l'urgence

Génère tous les livrables de clôture une fois l'urgence résolue.

**Usage :**
```
/close
Billet #77099 — Réseau Otto Group résolu.
Firewall remplacé par l'équipe infra. Service rétabli à 16h45.
Durée totale : 2h23. Aucune donnée perdue.
```

**Menu affiché (puis STOP — attendre ton choix) :**
```
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams — fin d'intervention
[5] /kb — capitalisation KB
[A] Tout (1+2+3+4)
```

---

## Flux de travail recommandé

### Panne électrique

```
1. Alerte reçue — systèmes clients inaccessibles
        ↓
2. /panne — Billet #[XXXXX] — [Client] — [Site]
   Choisir : [1] HQ confirmée / [2] Cause locale / [3] Fluctuation
        ↓
3. Mettre les actifs en maintenance RMM (réduire le bruit)
   Poster la notice Teams ⚠️
        ↓
4. Attendre le retour courant
   /retour dès que le courant est rétabli
        ↓
5. Valider GO / NO-GO pour chaque serveur critique
   DC en dernier — DC OK = tout le reste peut suivre
        ↓
6. /teams [6] Fin d'intervention
   /close → [A]
```

### Urgence P1 — réseau ou serveur critique

```
1. Alerte P1 reçue
        ↓
2. /urgence [description] — Billet #[XXXXX]
        ↓
3. P1 confirmé → notice Teams ⚠️ immédiate
   /escalade [domaine] → bloc de transfert propre
        ↓
4. Ne pas tenter de résoudre seul
   Attendre confirmation prise en charge
        ↓
5. Suivre avec /status toutes les 20-30 min
   Mettre à jour Teams à chaque étape clé
        ↓
6. Résolution confirmée → /retour si pertinent
   /close → [A]
```

---

## Matrice d'escalade rapide

| Situation | Agent cible | Délai |
|---|---|---|
| Réseau site complet / DC inaccessible | @IT-Commandare-NOC | Immédiat |
| Sécurité / ransomware / compromission | @IT-SecurityMaster | Immédiat — NE PAS toucher au système |
| Serveur infrastructure / VM / hyperviseur | @IT-Commandare-Infra | Immédiat |
| Backup / perte de données | @IT-BackupDRMaster | Immédiat |
| Téléphonie VoIP down | @IT-VoIPMaster | < 30 min |
| Cloud M365 / Azure | @IT-CloudMaster | < 30 min |

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| P1 détecté → escalade immédiate — aucune tentative de résolution solo | Un P1 géré seul = risque d'aggraver la situation |
| Sécurité / ransomware → @IT-SecurityMaster immédiatement — NE PAS TOUCHER | Préserver les preuves — limiter la propagation |
| Notice Teams obligatoire dès que le type d'urgence est connu | Communication coordonnée — zéro surprise pour l'équipe |
| Lecture seule avant toute remédiation | Prouver avant d'agir — ne pas aggraver |
| 1 serveur à la fois pour les reboots ou actions risquées | Éviter les pannes en cascade |
| ZÉRO IP / credentials / noms sensibles dans les livrables client | Client-safe obligatoire |
| `[À CONFIRMER]` + 1 question max si info manquante | Pas d'invention — pas de surcharge du technicien sous stress |

---

## Questions fréquentes

**Q : Quelle différence entre IT-UrgenceMaster et IT-NOCDispatcher ?**
IT-NOCDispatcher reçoit et route les tickets entrants — c'est le triage initial.
IT-UrgenceMaster est le copilote live une fois que l'urgence est active — il guide le technicien pendant toute l'intervention.

**Q : Dois-je utiliser IT-UrgenceMaster pour un P3 ou P4 ?**
Non. IT-UrgenceMaster est conçu pour les P1/P2 en contexte live. Pour les tickets P3/P4, utilise IT-TicketOpsAI pour le flux complet ou IT-TicketScribe pour les livrables.

**Q : Comment savoir si c'est un P1 ou un P2 ?**
P1 = panne totale, données à risque, ou suspicion de sécurité. Si tu hésites et que le périmètre est large — traite en P1 jusqu'à confirmation. IT-UrgenceMaster ajustera avec les informations reçues.

**Q : Que faire si le client appelle pendant l'urgence ?**
Génère `/teams [1] Début d'urgence` et fournis le numéro de billet. Pour la communication client formelle, IT-UrgenceMaster génère un email non-technique via `/close [3]` une fois l'incident résolu.

**Q : Comment gérer un retour Hydro-Québec partiel (certains systèmes ne redémarrent pas) ?**
Lance `/retour` — l'agent génère la checklist GO/NO-GO par serveur. Pour chaque serveur en NO-GO, il guide les actions de remédiation ou génère un `/flagup` si intervention spécialisée requise.

---

*GUIDE_UTILISATION — IT-UrgenceMaster v1.0 — MSP Intelligence AI — 2026-05-18*
