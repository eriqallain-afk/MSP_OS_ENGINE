# EXEMPLES_CLOSE_CW_REELS.md
# Exemples réels de fermetures CW — Référence qualité pour les agents
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Usage :** Uploader en Knowledge GPT — les agents s'en inspirent pour /close
**Standard :** CW Discussion = liste à puces client-safe | Note Interne = chronologie technique
**Mis à jour :** 2026-03-24 <!-- Remplacer par la date réelle de mise à jour ou indiquer "date future à titre d'exemple" si intentionnel -->

---

## EXEMPLE 1 — Diagnostic Veeam ESXi (intervention partielle — diagnostic complet)
**Ticket :** #0001234 | **Client :** Otto Inc | **Type :** Backup / VMware

### CW Discussion (client-safe — facturable)

```

INTERVENTION: Diagnostic — Échecs récurrents de sauvegarde Veeam
DATE: 2026-03-20
TECHNICIEN: EA

PRÉPARATION ET DÉCOURVERTE.
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS:
• Prise en charge du billet — revue de l'historique des échecs Veeam (plusieurs semaines)
• Connexion au serveur de gestion des sauvegardes et collecte du diagnostic complet
• Analyse des journaux de l'environnement de virtualisation et corrélation avec les fenêtres de sauvegarde
• Identification de la cause probable : interférences entre l'outil de supervision et le système de virtualisation
• Compilation du dossier de diagnostic et transmission à l'équipe de supervision pour correction

RÉSULTAT:
• Cause probable identifiée et documentée
• Actions correctives clairement définies pour l'équipe responsable
• Retest des sauvegardes planifié après correctif

RECOMMANDATION:
• Surveiller les sauvegardes 24h après le correctif appliqué par l'équipe de supervision
```

### CW Note Interne (technique)

```

Billet #0001234 — Otto Inc — Échecs récurrents Veeam "Failed to retrieve object hierarchy"
Début : 20:00 | Fin : 23:00 | Durée : ~3h

PRÉPARATION ET DÉCOURVERTE.
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

DIAGNOSTIC EFFECTUÉ:
- Collecte PRECHECK Veeam sur serveur de management — jobs, sessions, dépôts, services
- Corrélation logs ESXi (hostd/vpxa) avec fenêtre backup → timeouts SoapAdapter confirmés
- Identification trafic anormal probe RMM sur port SSH ("invalid protocol identifier")
- Hypothèse principale confirmée : polling RMM trop fréquent → timeouts hostd → échec inventaire VMware

ACTIONS EFFECTUÉES:
- Script PRECHECK_VEEAM exécuté et archivé
- Analyse corrélée des logs VMware et Veeam
- Aucune modification appliquée (hors ownership — dossier RMM)

À TRANSFÉRER À L'ÉQUIPE RMM:
1. Corriger le module SSH (trafic non-SSH sur port 22)
2. Ajuster le polling VMware API pendant la fenêtre backup (02:00-03:00)
3. Confirmer correction → relancer job MP_ESXI - Local_Daily manuellement

STATUT: Diagnostic terminé — Correctif en attente équipe RMM
```

---
*Ajouter les prochaines bonnes interventions dans ce fichier*

---

## EXEMPLE 2 — Windows Update Missing sur DC (intervention partielle + Flag Up)
**Ticket :** #0001234 | **Client :** Otto Inc | **Type :** Maintenance / NOC

### Contexte
Alerte RMM : aucune mise à jour critique/sécurité installée depuis ~2 mois sur CLT-DC01.
PRECHECK effectué. Pending Reboot identifié et corrigé (reboot contrôlé). Updates critiques
toujours manquantes après reboot — patching non exécuté (hors scope / RMM owner).

### CW Discussion (client-safe — facturable)

```
───────────────────────────────────────────────────────────────────────────────
# Diagnostic et maintenance — Mises à jour manquantes (contrôleur de domaine)
───────────────────────────────────────────────────────────────────────────────

DATE: 2026-03-26
TECHNICIEN: EA

PRÉPARATION ET DÉCOURVERTE.
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS:
• Prise en charge de l'alerte de surveillance — vérification de l'état des mises à jour du serveur
• Diagnostic complet de l'état du système (espace disque, services, politiques de mise à jour)
• Vérification de la santé du contrôleur de domaine (réplication, services d'authentification)
• Identification d'un redémarrage en attente bloquant l'application des mises à jour
• Redémarrage contrôlé du serveur hors heures d'affaires avec validation post-redémarrage
• Transmission du dossier à l'équipe NOC pour planification du cycle de mise à jour

RÉSULTAT:
• Redémarrage en attente corrigé — serveur opérationnel et services d'authentification confirmés
• Mises à jour critiques identifiées — planification requise par l'équipe NOC
• Aucun impact sur les utilisateurs durant l'intervention

RECOMMANDATION:
• Planifier l'installation des mises à jour critiques via la politique de gestion RMM
```

### CW Note Interne (technique)

```
```markdown
────────────────────────────────────────────────────────
# CPU MONITOR / TÂCHE PLANIFIÉE / LANCEMENTS MULTIPLES
────────────────────────────────────────────────────────

```

🚩 FLAG UP — Billet #0001234 — Municipalité De Otto Inc
CLT-DC01 (kostka.local) — Windows Update Missing / Patching non exécuté

PRÉPARATION ET DÉCOURVERTE.
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

PRECHECK (22:13):
- OS         : Windows Server 2019 — Uptime depuis 2026-01-23 (~62 jours)
- Disque C:  : 22.8 GB libres (19%) — OK
- Pending Reboot : True (PendingFileRename) — CAUSE PRINCIPALE
- wuauserv   : Stopped (Manual) — normal si RMM géré
- WSUS       : UseWUServer=0 (pas de WSUS — WU Internet direct)
- AUOptions  : 1 (notification/choix — pas d'install automatique)
- Dernier KB : KB5068791 — 2026-01-24 (~62 jours) — CONFORME À L'ALERTE

ACTIONS EFFECTUÉES:
— PRECHECK OS/disque/services/WU + santé DC (repadmin/dcdiag) → OK
— Redémarrage contrôlé DC (objectif : résoudre Pending Reboot)
— Post-check DC : repadmin /replsummary → OK | dcdiag → OK
— Vérification updates post-reboot :
     Missing (total)           : 5
     Missing (Critique/Sécu)   : 2
     → 2026-03 CU Windows Server 2019 x64 KB5078752
     → SQL Server 2017 Security Update (GDR) KB5077472 [À VALIDER]

RÉSULTAT POST-REBOOT:
- LastBootUpTime : 2026-03-26 22:29
- PendingReboot  : False ✓
- Updates critiques toujours manquantes → patching non exécuté (RMM owner)

POINT D'ATTENTION:
KB SQL Server 2017 listé sur ce DC — valider si SQL est réellement présent/attendu sur ce DC.
AUOptions=1 peut empêcher l'installation automatique si le RMM ne force pas l'application.

ESCALADE → NOC:
Valider politique patching client (RMM/exclusions/fenêtre/reboot orchestration).
Lancer cycle patching RMM ou planifier fenêtre — surveiller disparition monitor.

STATUT: PARTIEL / À SUIVRE
```

### Notice Teams

```
Titre   : 🚩 Avertissement — Billet : #0001234
Contenu : Maintenance en cours chez Municipalité De Otto Inc
          Tâche principale : Diagnostic Windows Update Missing — CLT-DC01
          Impact : Serveur(s) indisponible(s) lors de la maintenance
```
