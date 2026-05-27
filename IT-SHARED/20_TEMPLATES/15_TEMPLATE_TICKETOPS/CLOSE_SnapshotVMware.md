# CLOSE_SnapshotVMware — Fermeture Snapshot VMware
**Agent :** IT-TicketOpr | IT-TicketScribe | IT-SysAdmin
**Usage :** Clôture billet de création / suppression / restauration de snapshot VMware
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

SNAPSHOT VMWARE — [NOM VM] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OPÉRATION : [Création / Suppression / Restauration]

VM CIBLÉE
→ Nom VM      : [NOM-VM]
→ Host ESXi   : [NOM-HOST]
→ Datastore   : [NOM-DATASTORE]
→ RAM / CPU   : [X Go / X vCPU]
→ Taille VM   : [X Go]

SNAPSHOT
→ Nom          : [Description snapshot]
→ Date/Heure   : [YYYY-MM-DD HH:MM]
→ Taille prise : [X Go]
→ With memory  : [Oui / Non]
→ Quiesce      : [Oui / Non]

RAISON
→ [Avant patching / Avant changement majeur / Demande client / Autre]

RÉSULTAT
→ Opération    : ✅ Succès
→ État VM      : [En fonction / Éteinte]
→ Services     : [Validés post-opération]

⚠️ RAPPEL : Supprimer le snapshot dans [X jours] — [Date limite : YYYY-MM-DD]

Technicien : [NOM] | Billet : #[XXXXX] | Durée : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Vérification de l'état de la machine virtuelle avant l'opération.
• [Création / Suppression / Restauration] du point de restauration VMware sur [NOM VM].
• Validation du bon fonctionnement des services après l'opération.
• Documentation du snapshot dans le système de suivi.

RÉSULTAT : Opération complétée avec succès.
```

---

## [3] EMAIL CLIENT

```
Objet : Snapshot VMware [créé / supprimé / restauré] — [Nom VM] — [Date]

Bonjour [Prénom],

Nous avons [créé / supprimé / restauré] le point de restauration VMware
sur votre serveur [NOM VM] tel que demandé.

L'opération s'est déroulée sans incident et les services ont été validés.

[Si création] : Ce snapshot sera conservé jusqu'au [Date limite] puis supprimé
pour libérer l'espace de stockage.

N'hésitez pas à nous contacter pour toute question.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ SNAPSHOT VMWARE — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet : #[XXXXX]
VM     : [NOM-VM]
Action : [Créé / Supprimé / Restauré]
Statut : ✅ Succès — Services opérationnels
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ Suppression prévue : [Date si applicable]
@[Technicien] | [Date HH:MM]
```
