# CLOSE_WindowsUpdateMissing — Fermeture Windows Update manquantes
**Agent :** IT-TicketOpsAI | IT-TicketScribe | IT-MaintenanceMaster
**Usage :** Clôture billet Windows Update en retard, manquantes ou bloquées
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

WINDOWS UPDATE MANQUANTES — [NOM MACHINE] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MACHINE
→ Nom          : [NOM-MACHINE]
→ OS           : [Windows Server XXXX / Windows 10/11 — Build XXXXX]
→ Rôle         : [Serveur de fichiers / DC / Poste de travail / Autre]
→ Dernier patch : [Date ou Inconnu]

DIAGNOSTIC
→ Mises à jour manquantes    : [Nombre] ([X] critiques, [X] importantes)
→ KB manquantes critiques     : [KB XXXXXXX — Description]
→ Raison du retard            : [WU désactivé / WSUS mal configuré / Espace disque / Autre]
→ Erreur WU identifiée        : [Code erreur ou N/A]

ACTIONS EFFECTUÉES
→ [Vérification WSUS / Windows Update configuration]
→ [Correction de la cause racine — ex: réinitialisation agent WU]
→ [Application des mises à jour manquantes]
→ [Reboot si requis]

RÉSULTAT
→ Mises à jour appliquées  : ✅ [Nombre] / [Nombre total]
→ État actuel              : [À jour / Mises à jour restantes planifiées]
→ Agent WU                 : [Fonctionnel]

Technicien : [NOM] | Billet : #[XXXXX] | Durée : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Identification des mises à jour manquantes sur [NOM MACHINE].
• Analyse et correction de la cause empêchant l'application des mises à jour.
• Application des correctifs de sécurité et de qualité en attente.
• Validation du bon fonctionnement du système après les mises à jour.

RÉSULTAT : Système à jour et opérationnel.
```

---

## [3] EMAIL CLIENT

```
Objet : Mise à jour système complétée — [Nom Machine] — [Date]

Bonjour [Prénom],

Suite à la détection de mises à jour manquantes sur [NOM MACHINE], nous avons
procédé à leur application.

TRAVAUX RÉALISÉS
• Diagnostic de la situation et correction de la cause
• Application des mises à jour en attente
• Validation du bon fonctionnement du système

Votre système est maintenant à jour.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ WINDOWS UPDATE — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet  : #[XXXXX]
Machine : [NOM-MACHINE]
Statut  : ✅ Mises à jour appliquées — Système à jour
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Technicien] | [Date HH:MM]
```
