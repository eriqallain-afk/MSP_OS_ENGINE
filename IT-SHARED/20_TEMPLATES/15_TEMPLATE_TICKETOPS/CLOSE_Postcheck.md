# CLOSE_Postcheck — Fermeture Postcheck post-intervention
**Agent :** IT-TicketOpr | IT-TicketScribe | IT-SysAdmin | IT-MaintenanceMaster
**Usage :** Clôture avec liste de vérification complète post-intervention (tout type)
**Version :** 1.0 — 2026-05-08

---

## [1] NOTE INTERNE CW

```
Prise de connaissance de la demande et consultation de la documentation du client.

POSTCHECK — [TYPE INTERVENTION] — [NOM MACHINE] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INTERVENTION    : [Description en une ligne]
MACHINE/ENV     : [NOM-MACHINE / Environnement]
TECHNICIEN      : [NOM]
HEURE DÉBUT     : [HH:MM]
HEURE FIN       : [HH:MM]

━━━━ CHECKLIST POSTCHECK ━━━━

SYSTÈME
[✅/⚠️/N/A] Démarrage et disponibilité du serveur/service
[✅/⚠️/N/A] CPU / RAM / Disque dans les seuils normaux
[✅/⚠️/N/A] Aucune erreur critique dans Event Viewer
[✅/⚠️/N/A] Monitoring RMM — aucune alerte active

SERVICES CRITIQUES
[✅/⚠️/N/A] Active Directory / DNS
[✅/⚠️/N/A] SQL Server / Base de données
[✅/⚠️/N/A] IIS / Services web / Applications
[✅/⚠️/N/A] Services de sauvegarde
[✅/⚠️/N/A] Services personnalisés : [Lister]

RÉSEAU
[✅/⚠️/N/A] Connectivité réseau confirmée
[✅/⚠️/N/A] Résolution DNS fonctionnelle
[✅/⚠️/N/A] Accès à distance (RDP/VPN) fonctionnel

DONNÉES & PROTECTION
[✅/⚠️/N/A] Intégrité données vérifiée
[✅/⚠️/N/A] Sauvegarde post-intervention programmée ou exécutée
[✅/⚠️/N/A] Snapshot supprimé (si applicable — après validation)

FONCTIONNEL
[✅/⚠️/N/A] Test utilisateur confirmé
[✅/⚠️/N/A] Application(s) fonctionnelles
[✅/⚠️/N/A] Impression / Partages accessibles si applicable

DOCUMENTATION
[✅/⚠️/N/A] CMDB / Hudu mis à jour
[✅/⚠️/N/A] KB créée si nouvel incident résolu
[✅/⚠️/N/A] Billet CW à jour

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RÉSULTAT GLOBAL : ✅ Postcheck complété — Aucun problème résiduel
[Ou] : ⚠️ Point en suspens — [Préciser l'anomalie et l'action de suivi]

Technicien : [NOM] | Billet : #[XXXXX] | Durée totale : [HH:MM]
```

---

## [2] DISCUSSION CW (client-safe)

```
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS
• Réalisation d'une vérification complète post-intervention sur [NOM MACHINE/ENV].
• Validation des services, performances et accès utilisateurs.
• Confirmation de l'intégrité des données et de la protection par sauvegarde.
• Aucune anomalie résiduelle détectée à la suite de l'intervention.

RÉSULTAT : Système pleinement opérationnel — Postcheck validé.
```

---

## [3] EMAIL CLIENT

```
Objet : Rapport post-intervention — [Nom Client] — [Date]

Bonjour [Prénom],

Suite à notre intervention du [Date], nous avons effectué une vérification
complète pour vous confirmer que tout est en ordre.

POINTS VÉRIFIÉS
• Services et performances du système : ✅ Normal
• Accès utilisateurs : ✅ Fonctionnel
• Protection des données (sauvegarde) : ✅ Active
• Aucune anomalie résiduelle détectée

Tout est opérationnel. N'hésitez pas à nous contacter si vous avez des questions.

Cordialement,
[NOM TECHNICIEN]
Support TI — [NOM MSP]
```

---

## [4] NOTICE TEAMS

```
✅ POSTCHECK VALIDÉ — [Nom Client]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet      : #[XXXXX]
Intervention: [Type]
Machine/Env : [NOM]
Statut      : ✅ Tous les points validés — Aucune anomalie
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Technicien] | [Date HH:MM]
```
