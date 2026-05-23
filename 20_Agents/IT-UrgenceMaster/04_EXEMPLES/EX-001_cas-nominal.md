# EX-001 — Exemples Urgences P1/P2 — Cas Nominaux
**Agent :** @IT-UrgenceMaster | **Version :** 1.1 | **Statut :** PASS

---

## EXEMPLE 1 — Panne Hydro-Québec + Retour confirmé (GO)
**Type :** Panne HQ | **Client :** Otto Inc | **Billet :** #T1710001 | **Durée :** 2h15

### Flux suivi

```
04:13 ⚠️ Alerte RMM — serveurs offline
04:15 → /panne
04:16 → Portail HQ : panne confirmée — ETA 06:00
04:17 → Notice Teams postée : ⚠️ Panne en cours — Billet : #T1710001
04:45 → Mise à jour Teams (panne toujours active)
06:05 → Retour courant détecté → /retour
06:06 → Notice Teams : 🔄 Retour en cours — Billet : #T1710001
06:15 → PRECHECK exécuté sur SRV-DC01 + SRV-FILE01
06:17 → GO confirmé (uptime 12 min, services OK, réplication AD OK)
06:18 → Notice Teams : ✅ Systèmes opérationnels — Billet : #T1710001
06:20 → /close [1] Note Interne + [2] Discussion
```

### CW Discussion générée

```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

INTERVENTION: Post-panne Hydro-Québec — Validation retour serveurs
DATE: 2026-03-25
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Prise en charge de l'alerte RMM et validation de la panne Hydro-Québec (confirmée)
• Surveillance du rétablissement du courant et des équipements réseau
• Exécution des vérifications post-retour sur les serveurs critiques
• Validation des services essentiels (authentification, accès aux données, réseau)
• Validation de l'état des sauvegardes post-retour

RÉSULTAT:
• Serveurs opérationnels — services essentiels confirmés fonctionnels
• Aucune perte de données identifiée lors de la validation

RECOMMANDATION:
• Surveiller les journaux système dans les 24h suivant le retour de courant
```

---

## EXEMPLE 2 — Réseau site down (P1 → Escalade NOC)
**Type :** Réseau P1 | **Client :** Municipalité de Kostka | **Billet :** #T1710002

### Flux suivi

```
14:30 → Alerte RMM — tous agents offline, site inaccessible
14:31 → /urgence réseau down — tous serveurs offline
14:32 → Classification P1 — réseau site entier
14:32 → Notice Teams : ⚠️ Urgence P1 en cours — Billet : #T1710002
14:33 → /escalade NOC — bloc CW généré
14:33 → @IT-Commandare-NOC mobilisé
14:35 → Client informé : "Notre équipe est mobilisée"
14:35 → Suivi Teams toutes les 30 min
```

### Bloc escalade généré (/escalade NOC)

```
[TRANSFERT → @IT-Commandare-NOC]
Billet : #T1710002 | Priorité : P1 | 2026-03-25 14:33
Technicien UrgenceMaster : EA

SYMPTÔME : Tous les agents RMM offline simultanément — site entier inaccessible
IMPACT    : Tous utilisateurs — accès serveurs, VPN, applications impactés
DURÉE     : Depuis 14:30 — 3 min d'intervention

ACTIONS EFFECTUÉES :
1. Alerte RMM — vérification : tous agents offline simultanément
2. Classification P1 — réseau site entier (pas un serveur individuel)

RAISON DU TRANSFERT : P1 réseau site — scope @IT-Commandare-NOC
URGENCE : ☑ Immédiate
```

---

## EXEMPLE 3 — Panne partielle + Flag Up (NO-GO)
**Type :** Post-panne HQ + NO-GO | **Client :** Saint-Stanislas | **Billet :** #T1710003

### Contexte

Retour courant confirmé. PRECHECK exécuté. SRV-SQL01 : service SQL Server arrêté
+ pending reboot. Redémarrage hors scope sans fenêtre approuvée.

### Flux

```
/retour → PRECHECK → NO-GO (SQL arrêté + pending reboot SRV-SQL01)
→ /flagup → Flag Up transmis @IT-Commandare-Infra
→ Notice Teams : 🚩 Avertissement — Billet : #T1710003
→ /close [2] Discussion + [4] Teams fin
```

### CW Note Interne — Flag Up

```
Prise de connaissance de la demande et consultation de la documentation du client.

🚩 FLAG UP — DIAGNOSTIC COMPLET / INTERVENTION INCOMPLÈTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet      : #T1710003
Client      : Municipalité de Saint-Stanislas
Technicien  : EA
Date/Heure  : 2026-03-25 07:15
Transmis à  : ☑ Infra

PROBLÈME IDENTIFIÉ :
Symptôme     : SQL Server arrêté + pending reboot sur SRV-SQL01 post-panne HQ
Depuis quand : Retour courant 07:00 — non résolu à 07:15
Impact       : Applications métier dépendantes de SQL inaccessibles

CAUSE IDENTIFIÉE :
Arrêt inattendu du service SQL Server lors de la panne électrique.
Pending reboot présent (ComponentServicing) — indique une mise à jour
en attente avant la panne.
Niveau de confiance : ☑ Très probable

PREUVES :
1. PRECHECK — MSSQLSERVER : Stopped (StartType: Automatic)
2. Pending reboot CBS = True
3. EventLog ID 6008 présent (arrêt brutal à l'heure de la panne)
Artefacts : URGENT_PostRetour_T1710003.log

POURQUOI INCOMPLÈTE :
☑ Fenêtre de maintenance requise : reboot SQL en heures d'affaires = impact DB

ACTIONS REQUISES — @IT-Commandare-Infra :
1. Valider avec le client une fenêtre de reboot SRV-SQL01
2. Après approbation : redémarrer SQL Server + vérifier bases de données
3. Confirmer : applications métier accessibles

RISQUES SI AUCUNE ACTION :
Applications métier SQL inaccessibles jusqu'à la correction.
Délai critique : ☑ < 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### CW Discussion générée

```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

INTERVENTION: Diagnostic post-panne Hydro-Québec — Validation partielle
DATE: 2026-03-25
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Prise en charge de l'alerte et validation de la panne Hydro-Québec
• Surveillance du retour de courant et vérification des équipements réseau
• Exécution des vérifications post-retour sur l'ensemble des serveurs
• Identification d'un service applicatif nécessitant une action planifiée
• Documentation du dossier et transmission à l'équipe infrastructure

RÉSULTAT:
• Serveurs principaux opérationnels — services de base confirmés
• Une action corrective planifiée requise — suivi en cours par l'équipe technique

RECOMMANDATION:
• Planifier la correction du service applicatif en fenêtre approuvée (< 24h)
```
