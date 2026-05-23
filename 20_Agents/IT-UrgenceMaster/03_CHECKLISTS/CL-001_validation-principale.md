# CL-001 — Checklist Intervention Urgence P1/P2
**Agent :** @IT-UrgenceMaster | **Version :** 1.1 | **Date :** 2026-03-24

---

## A. RÉCEPTION DE L'URGENCE

- [ ] Billet CW créé et pris en charge (owner assigné)
- [ ] Type d'urgence classifié : Panne HQ | Réseau | Serveur | Multi-services | Autre
- [ ] Priorité définie : P1 / P2
- [ ] Notice Teams postée immédiatement (#billet obligatoire)
- [ ] Client/site identifié avec précision

---

## B. PANNE HQ SPÉCIFIQUE

- [ ] Portail HQ vérifié : hydroquebec.com/pannes
- [ ] Panne confirmée / non confirmée / indisponible
- [ ] ETA rétablissement noté
- [ ] Assets critiques offline identifiés dans RMM
- [ ] Assets en mode maintenance RMM (éviter alert fatigue)
- [ ] Si non confirmée HQ → diagnostic local démarré (UPS / réseau / équipements)

---

## C. URGENCE P1 — ESCALADE

- [ ] Classification P1 confirmée
- [ ] Notice Teams P1 postée immédiatement
- [ ] /escalade [domaine] exécuté — bloc CW généré et collé
- [ ] Agent cible notifié
- [ ] Client informé : "Notre équipe est mobilisée — mise à jour dans 15 min"
- [ ] Suivi Teams toutes les 30 min
- [ ] NE PAS tenter de résoudre seul ✋

---

## D. URGENCE P2 — DIAGNOSTIC

- [ ] Notice Teams postée
- [ ] Lecture seule effectuée avant toute action
- [ ] Périmètre exact documenté (nb users, services impactés)
- [ ] Depuis quand / changements récents identifiés
- [ ] GO/NO-GO évalué avant toute remédiation risquée
- [ ] Si > 30 min sans progrès → reclassifié P1

---

## E. VALIDATION GO/NO-GO (par serveur)

Pour chaque serveur critique :

- [ ] Accessible (ping / RMM / RDP)
- [ ] Uptime > 10 min (alimentation stabilisée)
- [ ] Pending reboot : noté et documenté
- [ ] Services critiques Running :
  - [ ] AD / Netlogon / KDC (si DC)
  - [ ] DNS
  - [ ] SQL Server (si applicable)
  - [ ] IIS / services métier (si applicable)
- [ ] Disque C: > 10% libre
- [ ] EventLogs post-retour : IDs 41/6008/6005/6006 vérifiés
- [ ] Réseau : GW ping OK + DNS externe OK
- [ ] DC spécifique :
  - [ ] repadmin /replsummary → OK
  - [ ] dcdiag /test:replications → OK
  - [ ] SYSVOL / NETLOGON partagés → OK
- [ ] Décision : ✅ GO / ❌ NO-GO — raison documentée

---

## F. NOTICES TEAMS — SUIVI

- [ ] Alerte initiale postée (⚠️)
- [ ] Cause identifiée postée (✅ HQ confirmée / 🔍 diagnostic)
- [ ] Retour / services détecté posté (🔄)
- [ ] GO/NO-GO résultat posté
- [ ] Flag Up posté si applicable (🚩)
- [ ] Fin d'intervention postée (✅)
- [ ] **Numéro de billet présent dans chaque notice**

---

## G. CLÔTURE (/close)

- [ ] Menu affiché — STOP — choix du technicien attendu avant génération
- [ ] CW Note Interne :
  - [ ] Commence par "Prise de connaissance de la demande..."
  - [ ] Chronologie horodatée complète
  - [ ] Zéro IP dans la note
  - [ ] Statut final clair (Résolu / À surveiller / Flag Up)
- [ ] CW Discussion :
  - [ ] Commence par "Préparation et découverte..."
  - [ ] Liste à puces — minimum 4 puces
  - [ ] 100% client-safe (zéro IP, commandes, noms de serveurs)
- [ ] Email client (si requis) : ton professionnel, orienté résultat
- [ ] Sauvegardes : validées ou planification notée dans CW

---

## H. GARDES-FOUS — VÉRIFICATION FINALE

- [ ] Aucun credential / IP dans les livrables clients
- [ ] Si sécurité suspectée → @IT-SecurityMaster appelé (poste non touché)
- [ ] Reboots DC effectués 1 à la fois avec post-check AD
- [ ] Flag Up transmis si intervention incomplète
- [ ] /kb proposé si P1 ou nouveau type de problème
