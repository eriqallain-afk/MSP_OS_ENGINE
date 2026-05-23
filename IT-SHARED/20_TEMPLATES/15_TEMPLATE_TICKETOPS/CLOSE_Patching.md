# CLOSE_Patching — Fermeture Patching Serveurs
**Agent :** IT-TicketOpsAI | IT-TicketScribe | IT-MaintenanceMaster
**Usage :** Clôture billet de patching Windows / Linux serveurs
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

PATCHING — [NOM SERVEUR(S)] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SERVEURS TRAITÉS
→ [Serveur 1] — [OS / Version]
→ [Serveur 2] — [OS / Version]

MISES À JOUR APPLIQUÉES
→ [Nombre] mises à jour installées
→ KB critiques : [KB XXXXXXX, KB XXXXXXX]
→ Catégories : [Security / Quality / Feature]

PRÉCAUTIONS
→ Snapshot VMware créé avant intervention : [Oui / Non]
→ Fenêtre approuvée par le client : [Oui / Non]

RÉSULTAT
→ Mises à jour : ✅ Appliquées avec succès
→ Reboot : [Effectué / Planifié / Non requis]
→ Services post-reboot : ✅ Tous opérationnels

VALIDATIONS POST-PATCH
→ Event Viewer : [Aucune erreur critique / Erreur X notée]
→ Services critiques : [Liste — tous actifs]
→ Monitoring RMM : [Aucune alerte active]

Technicien : [NOM] | Billet : #[XXXXX] | Durée : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Analyse de l'état des mises à jour en attente sur les serveurs concernés.
• Application des mises à jour Windows — [Nombre] correctifs installés.
• Redémarrage des serveurs effectué dans la fenêtre convenue.
• Validation post-patching — services, événements et disponibilité confirmés.

RÉSULTAT : Serveurs à jour et opérationnels.

Pour toute question, n'hésitez pas à nous contacter.
```

---

## [3] EMAIL CLIENT

```
Objet : Mise à jour serveurs complétée — [Nom Client] — [Date]

Bonjour [Prénom],

Nous avons complété l'application des mises à jour sur vos serveurs lors de la
fenêtre convenue du [Date].

TRAVAUX RÉALISÉS
• [Nombre] mises à jour de sécurité et de qualité installées
• Redémarrage effectué et services validés
• Aucune anomalie détectée après l'intervention

Vos serveurs sont à jour et pleinement opérationnels.

N'hésitez pas à nous contacter si vous observez quoi que ce soit d'inhabituel.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ PATCHING COMPLÉTÉ — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet : #[XXXXX]
Serveurs : [Liste]
Statut : ✅ Mises à jour appliquées — Services opérationnels
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Technicien] | [Date HH:MM]
```
