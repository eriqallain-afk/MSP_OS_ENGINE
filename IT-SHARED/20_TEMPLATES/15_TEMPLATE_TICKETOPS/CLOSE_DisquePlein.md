# CLOSE_DisquePlein — Fermeture Disque plein
**Agent :** IT-TicketOpr | IT-TicketScribe | IT-SysAdmin
**Usage :** Clôture billet disque plein ou espace disque critique (serveur ou poste)
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

DISQUE PLEIN — [NOM MACHINE] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MACHINE
→ Nom          : [NOM-MACHINE]
→ OS           : [Windows Server XXXX / Windows / Linux]
→ Volume ciblé : [C: / D: / E: / /var / Autre]
→ Taille totale : [X Go]
→ Espace libre initial : [X Go / X%]

DIAGNOSTIC
→ Cause principale identifiée :
   [ ] Logs applicatifs (IIS / SQL / Event Logs)
   [ ] Fichiers temporaires accumulés
   [ ] Vieux snapshots VMware
   [ ] Sauvegardes locales volumineuses
   [ ] Fichiers utilisateurs non gérés
   [ ] Croissance base de données
   [ ] Autre : [Préciser]

TOP CONSOMMATEURS D'ESPACE
→ [Dossier/Fichier 1] : [X Go]
→ [Dossier/Fichier 2] : [X Go]

ACTIONS EFFECTUÉES
→ [Nettoyage logs / Suppression fichiers temporaires / Archivage / Extension volume]
→ [Taille libérée : X Go]

RÉSULTAT
→ Espace libre après intervention : [X Go / X%]
→ Volume       : [Opérationnel / Toujours surveillé]
→ Alerte RMM   : [Acquittée / Seuil ajusté]

RECOMMANDATION
→ [Politique de rétention logs / Extension disque / Nettoyage planifié mensuel]

Technicien : [NOM] | Billet : #[XXXXX] | Durée : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Analyse de l'utilisation de l'espace disque sur [NOM MACHINE].
• Identification et suppression des fichiers temporaires et journaux obsolètes.
• Libération de [X Go] d'espace sur le volume [X:].
• Validation du bon fonctionnement du système après nettoyage.

RÉSULTAT : Espace disque libéré — Système opérationnel.
```

---

## [3] EMAIL CLIENT

```
Objet : Espace disque rétabli — [Nom Machine] — [Date]

Bonjour [Prénom],

Suite à l'alerte d'espace disque critique sur [NOM MACHINE], nous sommes
intervenus pour libérer de l'espace.

TRAVAUX RÉALISÉS
• Analyse et identification des fichiers volumineux
• Nettoyage et libération de [X Go] d'espace disque
• Validation du bon fonctionnement du système

[Si recommandation] : Nous vous recommandons [action préventive] pour éviter
la récurrence de ce problème.

N'hésitez pas à nous contacter pour toute question.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ DISQUE — ESPACE LIBÉRÉ — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet  : #[XXXXX]
Machine : [NOM-MACHINE]
Volume  : [X:]
Libéré  : [X Go] → Espace libre : [X Go / X%]
Statut  : ✅ Opérationnel
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Technicien] | [Date HH:MM]
```
