# CLOSE_DNS-DHCP — Fermeture Problème DNS/DHCP
**Agent :** IT-TicketOpsAI | IT-TicketScribe | IT-NetworkMaster
**Usage :** Clôture billet DNS en panne, DHCP épuisé, résolution nom défaillante
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

DNS/DHCP — [PROBLÈME] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SERVICE AFFECTÉ : [DNS / DHCP / Les deux]
SERVEUR         : [NOM-SERVEUR] — [IP]
RÔLE            : [DC / Serveur DNS dédié / Routeur / Pare-feu]

SYMPTÔMES RAPPORTÉS
→ [Résolution de noms en échec / Aucune IP attribuée / Lenteur réseau / Autre]
→ Usagers affectés : [Nombre / Tous / Département X]

DIAGNOSTIC
→ Service DNS  : [Arrêté / En erreur / Fonctionnel]
→ Service DHCP : [Arrêté / Pool épuisé / En erreur / Fonctionnel]
→ Pool DHCP    : [X IPs disponibles / Étendue : X.X.X.X–X.X.X.X]
→ Forwarders   : [Vérifiés — 8.8.8.8, 1.1.1.1 ou DC interne]
→ Zone DNS     : [Vérifiée — aucune entrée manquante / Entrée X corrigée]
→ Erreurs logs : [Event ID XXXX — Description ou N/A]

ACTIONS EFFECTUÉES
→ [Redémarrage service / Nettoyage baux DHCP expirés / Ajout entrée DNS / Extension pool]
→ [Ipconfig /flushdns sur postes affectés si applicable]
→ [Test de résolution post-correction]

RÉSULTAT
→ DNS  : ✅ Résolution fonctionnelle
→ DHCP : ✅ Attribution IPs normale
→ Postes testés : [Noms — OK]

Technicien : [NOM] | Billet : #[XXXXX] | Durée : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Diagnostic du service réseau affecté et identification de la cause.
• Correction du problème de [résolution de noms / attribution d'adresses IP].
• Validation du bon fonctionnement réseau sur les postes concernés.
• Vérification générale des services réseau critiques.

RÉSULTAT : Services réseau rétablis — Connexions opérationnelles.
```

---

## [3] EMAIL CLIENT

```
Objet : Services réseau rétablis — [Nom Client] — [Date]

Bonjour [Prénom],

Suite au problème de connectivité réseau signalé, nous sommes intervenus et
avons rétabli les services affectés.

TRAVAUX RÉALISÉS
• Diagnostic et identification de la cause
• Correction du service [DNS / DHCP]
• Validation de la connexion sur les postes concernés

Votre réseau fonctionne de nouveau normalement.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ DNS/DHCP RÉTABLI — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet  : #[XXXXX]
Serveur : [NOM-SERVEUR]
Service : [DNS / DHCP / Les deux]
Statut  : ✅ Services opérationnels — Réseau rétabli
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Technicien] | [Date HH:MM]
```
