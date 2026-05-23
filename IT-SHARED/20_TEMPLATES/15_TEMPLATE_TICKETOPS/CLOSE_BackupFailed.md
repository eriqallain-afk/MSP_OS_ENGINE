# CLOSE_BackupFailed — Fermeture Backup échoué
**Agent :** IT-TicketOpsAI | IT-TicketScribe | IT-BackupDRMaster
**Usage :** Clôture billet de sauvegarde en échec (Veeam, Backup Exec, Windows Backup, autre)
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

BACKUP ÉCHOUÉ — [NOM JOB] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SOLUTION DE BACKUP : [Veeam / Backup Exec / Windows Server Backup / Autre]
JOB CONCERNÉ       : [Nom du job]
SERVEUR SOURCE     : [NOM-SERVEUR]
DESTINATION        : [NAS / Cloud / Tape / Autre]
DATE DERNIER SUCCÈS : [YYYY-MM-DD ou Inconnu]

DIAGNOSTIC
→ Code d'erreur    : [Code / Message exact]
→ Cause identifiée : [Espace insuffisant / Connexion perdue / Agent / VSS / Credentials / Autre]
→ Éléments vérifiés :
   [ ] Logs de la solution backup
   [ ] Espace disponible destination
   [ ] Connectivité réseau vers destination
   [ ] Agent backup sur le serveur source
   [ ] Certificats / credentials

ACTIONS EFFECTUÉES
→ [Correction cause racine]
→ [Relance manuelle du job]
→ [Validation du résultat]

RÉSULTAT
→ Job relancé       : ✅ Succès / ⚠️ Succès partiel / 🔴 Toujours en échec
→ Données protégées : [Oui / Partiel — préciser]
→ RPO actuel        : [Durée depuis dernier backup valide]

⚠️ Si toujours en échec → Escalade @IT-BackupDRMaster

Technicien : [NOM] | Billet : #[XXXXX] | Durée : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Analyse de l'alerte de sauvegarde et identification de la cause de l'échec.
• Correction du problème empêchant la bonne exécution de la sauvegarde.
• Relance du processus de sauvegarde et validation du résultat.
• Vérification de l'intégrité des données sauvegardées.

RÉSULTAT : Sauvegarde complétée avec succès — données protégées.
```

---

## [3] EMAIL CLIENT

```
Objet : Sauvegarde rétablie — [Nom Client] — [Date]

Bonjour [Prénom],

Nous avons reçu une alerte concernant votre sauvegarde automatique et nous
sommes intervenus pour corriger la situation.

TRAVAUX RÉALISÉS
• Diagnostic de la cause de l'échec
• Correction et relance de la sauvegarde
• Validation que vos données sont protégées

Votre sauvegarde fonctionne de nouveau normalement.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ BACKUP RÉTABLI — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet  : #[XXXXX]
Job     : [Nom du job]
Serveur : [NOM-SERVEUR]
Statut  : ✅ Sauvegarde complétée — Données protégées
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Technicien] | [Date HH:MM]
```
