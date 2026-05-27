# CLOSE_RebootServeur — Fermeture Reboot serveur
**Agent :** IT-TicketOpr | IT-TicketScribe | IT-SysAdmin
**Usage :** Clôture billet de redémarrage planifié ou d'urgence d'un serveur
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

REBOOT SERVEUR — [NOM SERVEUR] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SERVEUR   : [NOM-SERVEUR]
OS        : [Windows Server XXXX — Build XXXXX]
RÔLE      : [DC / Serveur de fichiers / App Server / RDS / Autre]
TYPE      : [Planifié / Post-patching / Urgence / Demande client]

RAISON DU REBOOT
→ [Post-patching requis / Gel service / Mémoire / Performance / Demande planifiée / Autre]

PRÉCAUTIONS AVANT REBOOT
→ Snapshot créé          : [Oui / Non / Non applicable]
→ Usagers avertis        : [Oui / Non — Nb usagers connectés : X]
→ Fenêtre approuvée      : [Oui / Non]
→ Services préalablement arrêtés : [Oui — Liste / Non]

EXÉCUTION
→ Heure début           : [HH:MM]
→ Heure fin (retour)    : [HH:MM]
→ Durée arrêt total     : [X minutes]

VALIDATIONS POST-REBOOT
→ Services critiques    :
   [ ] Active Directory / DNS    : [✅ / ⚠️]
   [ ] SQL / Base de données     : [✅ / ⚠️]
   [ ] IIS / Application         : [✅ / ⚠️]
   [ ] Sauvegarde                : [✅ / ⚠️]
   [ ] Services personnalisés    : [✅ / ⚠️]
→ Event Viewer          : [Aucune erreur critique / Erreur X notée]
→ Monitoring RMM        : [Aucune alerte active]
→ Connexions testées    : [Oui — OK]

RÉSULTAT
→ Reboot : ✅ Complété avec succès
→ Durée totale : [X minutes]

Technicien : [NOM] | Billet : #[XXXXX] | Durée : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Préparation et coordination du redémarrage du serveur [NOM SERVEUR].
• Redémarrage effectué dans la fenêtre convenue avec un minimum d'impact.
• Validation complète des services après le redémarrage.
• Confirmation que tous les services sont opérationnels.

RÉSULTAT : Serveur redémarré et pleinement opérationnel.
```

---

## [3] EMAIL CLIENT

```
Objet : Redémarrage serveur complété — [Nom Serveur] — [Date]

Bonjour [Prénom],

Le redémarrage de votre serveur [NOM SERVEUR] a été complété avec succès.

TRAVAUX RÉALISÉS
• Redémarrage effectué : [Date HH:MM]–[HH:MM]
• Tous les services validés et opérationnels
• Aucune anomalie détectée

[Si post-patching] : Ce redémarrage faisait suite à l'application des mises
à jour de sécurité récentes.

N'hésitez pas à nous contacter si vous observez quoi que ce soit d'inhabituel.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ REBOOT COMPLÉTÉ — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet  : #[XXXXX]
Serveur : [NOM-SERVEUR]
Fenêtre : [HH:MM]–[HH:MM] ([X min])
Statut  : ✅ Services validés — Opérationnel
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Technicien] | [Date HH:MM]
```
