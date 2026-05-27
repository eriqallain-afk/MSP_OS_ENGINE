# CLOSE_RDSLicensing — Fermeture Licences RDS
**Agent :** IT-TicketOpr | IT-TicketScribe | IT-SysAdmin
**Usage :** Clôture billet licences RDS épuisées, expirées ou mal configurées
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

LICENCES RDS — [NOM SERVEUR] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SERVEUR RDS   : [NOM-SERVEUR]
LICENCE SERVER : [NOM-LICENCE-SERVER ou Même serveur]
TYPE LICENCES  : [Per User / Per Device]
SYMPTÔME       : [Connexions refusées / Avertissement expiration / Erreur ID XXXX]

ÉTAT LICENCES — AVANT INTERVENTION
→ Total licences    : [X]
→ Licences utilisées : [X]
→ Licences disponibles : [X]
→ Date d'expiration  : [YYYY-MM-DD ou N/A]
→ Mode grâce active  : [Oui — X jours restants / Non]

DIAGNOSTIC
→ Cause identifiée :
   [ ] Licences épuisées — trop d'usagers actifs
   [ ] Licences expirées
   [ ] Serveur de licences inaccessible
   [ ] Mauvais type de licence (Per User vs Per Device)
   [ ] Grace period expirée sans licences installées
   [ ] Autre : [Préciser]

ACTIONS EFFECTUÉES
→ [Vérification RD Licensing Manager]
→ [Nettoyage des baux de licences expirés / inutilisés]
→ [Activation des nouvelles licences — Clé : [NON INCLUSE — Passportal]]
→ [Redémarrage service Remote Desktop Licensing]
→ [Test de connexion RDS]

ÉTAT LICENCES — APRÈS INTERVENTION
→ Total licences     : [X]
→ Licences disponibles : [X]
→ Connexions testées  : ✅ Fonctionnelles

Technicien : [NOM] | Billet : #[XXXXX] | Durée : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Analyse de l'état des licences d'accès à distance sur [NOM SERVEUR].
• Identification et correction du problème de licences.
• Validation des connexions au serveur après intervention.
• Vérification que tous les usagers peuvent se connecter normalement.

RÉSULTAT : Accès à distance rétabli — Connexions fonctionnelles.
```

---

## [3] EMAIL CLIENT

```
Objet : Accès à distance rétabli — [Nom Client] — [Date]

Bonjour [Prénom],

Suite au problème d'accès à distance signalé sur [NOM SERVEUR], nous avons
corrigé la situation.

TRAVAUX RÉALISÉS
• Diagnostic du problème de licences d'accès à distance
• Correction et validation des connexions
• Tous les accès fonctionnent de nouveau normalement

[Si achat requis] : Nous vous contacterons séparément pour les détails
concernant le renouvellement des licences.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ LICENCES RDS RÉTABLIES — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet  : #[XXXXX]
Serveur : [NOM-SERVEUR]
Licences disponibles : [X / X]
Statut  : ✅ Connexions RDS opérationnelles
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Technicien] | [Date HH:MM]
```
