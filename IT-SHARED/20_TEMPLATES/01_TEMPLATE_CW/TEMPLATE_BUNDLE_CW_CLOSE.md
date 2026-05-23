# TEMPLATE BUNDLE — CW CLOSE
# Usage : Uploader en Knowledge GPT — TOUS les agents IT
# Version : 2.5 — 2026-05-14
# Ce fichier centralise TOUS les templates de fermeture de billet /close

---

# PHRASE D'OUVERTURE CANONIQUE — VERSION UNIQUE OBLIGATOIRE
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

> Applicable à TOUS les templates (T1, T2, T3, T5). Une seule version. Aucune variante.

```
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.
```

**Règles absolues :**
- Ces deux lignes précèdent TOUJOURS le contenu, dans TOUTES les sections PRÉPARATION ET DÉCOUVERTE.
- Aucune variation de formulation — mot pour mot.
- Le champ `TECHNICIEN` vaut `[À CONFIRMER]` si non disponible au moment de la clôture.

---

# RÈGLE DU TITRE — OBLIGATOIRE

Le titre dans la bannière `────────────────────────────────────────────────────────` est **généré par l'agent**
selon le contexte réel du billet. Ce n'est pas un placeholder — c'est une description courte et précise.

**Format attendu :** `[Verbe d'action ou type] — [sujet ou système]`

| Contexte | Exemple de titre |
|---|---|
| Patching mensuel | `Maintenance mensuelle — mises à jour de sécurité` |
| Backup en échec | `Résolution — échec de sauvegarde nocturne` |
| Alerte DHCP | `Analyse d'alerte — capacité d'étendue DHCP` |
| Serveur inaccessible | `Intervention urgente — restauration de service` |
| Pending reboot | `Validation — redémarrage en attente (Windows Update)` |
| Mise à jour réseau | `Mise à jour — équipements réseau` |
| Vérification lecture seule | `Vérification — état général du serveur` |

**Règles :**
- 4 à 8 mots maximum — lisible d'un coup d'œil
- Pas de noms de serveurs, d'IPs, de références techniques internes
- Pas d'articles superflus — aller droit au sujet
- Pas de majuscules complètes — titre de style, pas de cri

---

# TABLEAU DE SÉLECTION DES TEMPLATES

| Situation | Template |
|---|---|
| Intervention standard — maintenance, troubleshooting, audit, alerte | T1 — CW_DISCUSSION |
| Incident P1/P2 complexe — contexte distinct des actions, chronologie requise | T2 — CW_DISCUSSION_STAR |
| Note interne technique — audit trail, usage interne seulement | T3 — CW_NOTE_INTERNE |
| **Diagnostic initial — MasterScript exécuté, résultats à documenter** | **T4 — CW_NOTE_DIAGNOSTIC** |
| Patching multi-serveurs — precheck/postcheck par asset | T5 — CW_NOTE_INTERNE_STAR |
| Notification client par courriel | T6 — EMAIL_CLIENT |
| Notification client — billet issu d'une alerte NOC/monitoring | T6-NOC — EMAIL_CLIENT (variante NOC) |
| Notification Microsoft Teams | T7 — AVIS_TEAMS |
| Mémo interne — coordonnateur, VCIO, escalade interne | T8 — MEMO_INTERNE |

---

# RÈGLES TRANSVERSALES — CW_DISCUSSION (T1 et T2)

> Ces règles s'appliquent à TOUTE Discussion CW, quel que soit le template.

## Ce qui est INTERDIT dans la Discussion client

```
❌ Adresses IP (internes ou externes)
❌ Noms de serveurs, hostnames, équipements internes
❌ Adresses MAC
❌ Codes d'erreur bruts (BAD_ADDRESS, 0x80070005, EventID 7034)
❌ Commandes PowerShell ou CLI
❌ Chemins UNC (\\SRV-FILE01\partage)
❌ Credentials, tokens, clés
❌ Noms de comptes utilisateurs complets
❌ Diagnostics techniques internes (logs, outputs de script)
❌ Horodatage des actions — sauf billet P1/P2 (T2 uniquement)
```

**Formulation autorisée :** symptôme observable → validation effectuée → résultat client → recommandation.

## Niveau de détail — TRAVAUX EFFECTUÉS

| Type d'intervention | Bullets attendus |
|---|---|
| Alerte simple (monitoring, capacité, pending reboot) | **3 à 5 bullets** |
| Troubleshooting standard (backup, réseau, application) | **4 à 6 bullets** |
| Intervention complexe (P1/P2, multi-serveurs, RCA) | **5 à 8 bullets** |

> ❌ Ne pas dépasser 8 bullets — si plus long, c'est une Note Interne.
> ❌ Ne pas descendre sous 3 bullets — le client doit voir la valeur du travail.

---

# TEMPLATE 1 : CW_DISCUSSION

## Quand l'utiliser
Par défaut. Maintenance, troubleshooting, audit, alerte simple. Tout billet standard.
Format bullet points, orienté résultats, lisible par un non-technicien.
Pas d'horodatage des actions.

## Format

```
────────────────────────────────────────────────────────
       [Titre généré selon le contexte du billet]
────────────────────────────────────────────────────────

BILLET : #[XXXXX]
DATE : [YYYY-MM-DD]
TECHNICIEN : [Initiales] ou [À CONFIRMER]
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS :
---------
• [Action 1 — résultat client-visible]
• [Action 2 — résultat client-visible]
• [Action 3 — résultat client-visible]
• [Action 4 — résultat client-visible]

RÉSULTAT :
---------
• [Impact positif pour le client]
• [Confirmation de bon fonctionnement]

RECOMMANDATION : (optionnel)
---------
• [Suggestion si applicable]
```

## Exemples

### Patching de serveurs

```
────────────────────────────────────────────────────────
       Maintenance mensuelle — mises à jour de sécurité
────────────────────────────────────────────────────────

BILLET : #1233455
DATE : 2026-02-10
TECHNICIEN : EA
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS :
---------
• Vérification de l'état des sauvegardes et prise de snapshots pré-intervention
• Vérification de l'état général des serveurs, services et journaux d'événements
• Installation des mises à jour de sécurité Microsoft sur 5 serveurs
• Redémarrages planifiés et supervisés hors heures d'affaires
• Vérification du démarrage de tous les services critiques
• Tests de connectivité et accessibilité des applications

RÉSULTAT :
---------
• Tous les serveurs à jour avec les derniers correctifs de sécurité
• Aucun impact sur les opérations de l'entreprise
• Services opérationnels confirmés

RECOMMANDATION :
---------
• Prochaine fenêtre de maintenance recommandée : Mars 2026
```

### Troubleshooting backup

```
────────────────────────────────────────────────────────
       Résolution — échec de sauvegarde nocturne
────────────────────────────────────────────────────────

BILLET : #1233456
DATE : 2026-02-10
TECHNICIEN : EA
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS :
---------
• Analyse de l'échec de sauvegarde signalé sur le serveur de fichiers
• Identification et résolution de la cause liée à l'espace disponible sur le système de sauvegarde
• Nettoyage des sauvegardes obsolètes selon la politique de rétention
• Lancement manuel de la sauvegarde et vérification de la réussite
• Configuration d'alertes pour prévenir les occurrences futures

RÉSULTAT :
---------
• Sauvegarde fonctionnelle et complétée avec succès
• Protection des données rétablie

RECOMMANDATION :
---------
• Envisager une augmentation de capacité de stockage de sauvegarde d'ici 3 mois
```

### Maintenance réseau

```
────────────────────────────────────────────────────────
       Mise à jour — équipements réseau
────────────────────────────────────────────────────────

BILLET : #1233457
DATE : 2026-02-10
TECHNICIEN : EA
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS :
---------
• Prise de connaissance de la configuration réseau actuelle
• Mise à jour du micrologiciel du pare-feu
• Application des correctifs de sécurité recommandés par le fabricant
• Vérification de la configuration post-mise à jour
• Tests de connectivité Internet et accès distant

RÉSULTAT :
---------
• Équipement réseau à jour avec les dernières protections de sécurité
• Connectivité confirmée sans interruption de service
```

### Alerte NOC — Capacité / Monitoring

```
────────────────────────────────────────────────────────
       Analyse d'alerte — vérification de capacité système
────────────────────────────────────────────────────────

BILLET : #1233459
DATE : 2026-02-10
TECHNICIEN : EA
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS :
---------
• Analyse de l'alerte reçue via le système de surveillance
• Vérification de l'état général du système concerné et confirmation que l'alerte est valide
• Identification de la ressource approchant sa capacité limite
• Action corrective appliquée pour rétablir une utilisation normale
• Validation que l'alerte est résolue et que le système fonctionne normalement

RÉSULTAT :
---------
• Alerte résolue — système opérationnel dans les seuils normaux
• Aucun impact sur les opérations pendant l'intervention

RECOMMANDATION :
---------
• Maintenir une surveillance sur ce composant afin de prévenir une récurrence
```

> **Note :** Ce format s'applique aux alertes : capacité DHCP, espace disque, CPU prolongé,
> quota backup, seuil RAM, surveillance réseau, etc. Titre adapté selon le type d'alerte.

---

# TEMPLATE 2 : CW_DISCUSSION_STAR ← P1/P2 UNIQUEMENT

## Quand l'utiliser
Incidents P1/P2, problèmes complexes avec impact confirmé sur les opérations.
Format STAR : Situation / Tâche / Actions / Résultat.
**Ce template est le seul à inclure les horodatages dans les actions.**

## Format

```
────────────────────────────────────────────────────────
       [Titre généré selon le contexte du billet]
────────────────────────────────────────────────────────

BILLET : #[XXXXX]
DATE : [YYYY-MM-DD]
TECHNICIEN : [Initiales] ou [À CONFIRMER]
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

SITUATION :
---------
• [Contexte — ce qui se passait avant l'intervention, avec heure si P1]

TÂCHE :
---------
• [Objectif de l'intervention]

ACTIONS :
---------
• [HH:MM] [Ce qui a été fait — orienté client, sans jargon]
• [HH:MM] [...]

RÉSULTAT :
---------
• [Impact positif concret — inclure durée d'interruption si applicable]
• [Confirmation fonctionnement]

RECOMMANDATION : (optionnel)
---------
• [Suggestion actionnable]
```

## Exemple — Incident P1 Serveur inaccessible

```
────────────────────────────────────────────────────────
       Intervention urgente — restauration de service
────────────────────────────────────────────────────────

BILLET : #1233460
DATE : 2026-02-10
TECHNICIEN : EA
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

SITUATION :
---------
• Service applicatif inaccessible depuis 14h30 — utilisateurs dans l'impossibilité de travailler

TÂCHE :
---------
• Diagnostiquer et rétablir l'accès dans les meilleurs délais

ACTIONS :
---------
• 14h35 — Prise en charge et diagnostic via la console de gestion
• 15h10 — Redémarrage supervisé du service défaillant
• 15h30 — Vérification et reconfiguration pour assurer la stabilité
• 15h45 — Tests d'accès complets confirmés avant retour en production

RÉSULTAT :
---------
• Service opérationnel depuis 15h45 — durée d'interruption : 1h15
• Accès aux applications confirmé pour tous les utilisateurs

RECOMMANDATION :
---------
• Analyse de la cause racine dans les 48h
• Surveillance renforcée cette semaine
```

---

# TEMPLATE 4 : CW_NOTE_DIAGNOSTIC (MasterScript → CW)

## Quand l'utiliser
Après exécution du MasterScript de diagnostic (`MAINT-SRV-MasterScript_V1.ps1`).
Documente les résultats bruts pour CW — note interne uniquement, visible techniciens seulement.
À générer immédiatement après le script, avant toute action de remédiation.

## Règles
- ✅ Copier les valeurs exactes du script — aucune paraphrase
- ✅ Indiquer CRITIQUE / ATTENTION / OK pour chaque ressource
- ✅ Lister les rôles détectés automatiquement par le script
- ❌ IPs → `[IP MASQUÉE]` | Credentials → jamais
- ❌ Ne pas inclure le bloc PowerShell complet — résumé seulement

## Format

```
═══════════════════════════════════════════════════════════════
DIAGNOSTIC SERVEUR — [NOM SERVEUR] — [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════════════════════

Billet CW   : [#XXXXX]
Technicien  : [Initiales] ou [À CONFIRMER]
Déclencheur : [Motif — alerte / ticket client / maintenance / proactif]

RÔLES DÉTECTÉS
--------------
□ DC / Active Directory   : [Oui / Non]
□ SQL Server              : [Oui / Non]
□ RDS / Remote Desktop    : [Oui / Non]
□ Hyper-V                 : [Oui / Non]
□ Serveur d'impression    : [Oui / Non]
□ IIS / Web               : [Oui / Non]
□ Veeam                   : [Oui / Non]
□ Datto                   : [Oui / Non]

RESSOURCES — ÉTAT GÉNÉRAL
--------------------------
OS           : [ex. Windows Server 2022 Standard]
Uptime       : [Xj Xh Xm — dernier démarrage : YYYY-MM-DD HH:MM]
CPU          : [X% — Normal / ATTENTION / CRITIQUE]
RAM          : [X.XGB / X.XGB — X% — Normal / ATTENTION / CRITIQUE]
Disque C:    : [X.XGB libres / X.XGB — X% — Normal / ATTENTION / CRITIQUE]
[Disque D:]  : [si applicable]

SERVICES ARRÊTÉS (démarrage auto)
----------------------------------
[Liste des services en échec — ou "Aucun"]

ÉVÉNEMENTS CRITIQUES (dernières 24h)
--------------------------------------
[Provider : X occurrences — ex: Service Control Manager : 3]
[ou "Aucune anomalie"]

RÉSULTATS SPÉCIFIQUES AU RÔLE
-------------------------------
[Copier ici le bloc 2 (rôle) du MasterScript — ex: réplication AD, sessions RDS, VMs offline, jobs backup]
[Si plusieurs rôles, un sous-bloc par rôle]

ÉVALUATION INITIALE
--------------------
État général : [✅ Normal | ⚠️ Anomalies mineures | 🔴 Intervention requise]
Priorité suggérée : [P1 / P2 / P3 / Aucun]

PROCHAINES ÉTAPES
-----------------
□ [Action 1]
□ [Action 2]
═══════════════════════════════════════════════════════════════
```

## Exemple — Diagnostic DC avec anomalie disque

```
═══════════════════════════════════════════════════════════════
DIAGNOSTIC SERVEUR — SRV-DC01 — 2026-05-14 09:12
═══════════════════════════════════════════════════════════════

Billet CW   : #T1612445
Technicien  : EA
Déclencheur : Alerte espace disque reçue via RMM

RÔLES DÉTECTÉS
--------------
□ DC / Active Directory   : Oui
□ SQL Server              : Non
□ RDS / Remote Desktop    : Non
□ Hyper-V                 : Non
□ Serveur d'impression    : Non
□ IIS / Web               : Non
□ Veeam                   : Non
□ Datto                   : Non

RESSOURCES — ÉTAT GÉNÉRAL
--------------------------
OS           : Windows Server 2022 Standard
Uptime       : 22j 4h 17m — dernier démarrage : 2026-04-22 04:55
CPU          : 12% — Normal
RAM          : 6.2GB / 16.0GB — 39% — Normal
Disque C:    : 5.1GB libres / 80.0GB — 94% — CRITIQUE
Disque D:    : 45.2GB libres / 500.0GB — 9% — Normal

SERVICES ARRÊTÉS (démarrage auto)
----------------------------------
Aucun

ÉVÉNEMENTS CRITIQUES (dernières 24h)
--------------------------------------
NTDS : 2 occurrences
Disk : 1 occurrence

RÉSULTATS SPÉCIFIQUES AU RÔLE
-------------------------------
[DC] Réplication AD : OK (repadmin /replsummary — 0 échecs)
[DC] SYSVOL NETLOGON : Accessible
[DC] W32tm : Synchronisé
[DC] Directory Service log (24h) : 0 erreur critique

ÉVALUATION INITIALE
--------------------
État général : 🔴 Intervention requise
Priorité suggérée : P3

PROCHAINES ÉTAPES
-----------------
□ Nettoyer CBS.log / Windows\Temp — libérer espace C:
□ Vérifier profils itinérants / sauvegardes locales obsolètes
□ Valider journal NTDS (2 événements)
□ Documenter post-intervention avec T3
═══════════════════════════════════════════════════════════════
```

---

# TEMPLATE 3 : CW_NOTE_INTERNE

## Quand l'utiliser
Pour chaque billet fermé. Documentation technique interne — visible seulement par les techniciens.
Contient les détails techniques complets, commandes, résultats.
**Pas d'horodatage sur les actions sauf billet P1/P2 (mentionner alors l'heure dans la description).**

## Règles
- ✅ Commandes exactes utilisées
- ✅ Résultats observés (outputs, codes retour)
- ✅ Codes d'erreur et sources Event Log
- ❌ IPs → `[IP MASQUÉE]` | Credentials → jamais | Secrets → jamais
- ❌ `[HH:MM]` sur chaque action — sauf si P1/P2 (inclure alors l'heure dans la phrase)

## Format

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE — [TYPE EN MAJUSCULES]
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date        : [YYYY-MM-DD]
Technicien  : [Nom ou initiales] ou [À CONFIRMER]
Client      : [Nom client]
Billet CW   : [#T123456]
Équipements : [Liste — sans IPs]
Type        : [Maintenance / Troubleshooting / Urgence / Audit]

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

CONTEXTE INITIAL
----------------
[Description de la situation initiale et de l'objectif]

DIAGNOSTIC / ANALYSE
--------------------
[Étapes de diagnostic effectuées]
Observations   : [Symptômes, EventID+source, codes erreur]
Cause probable : [Si identifiée]

ACTIONS TECHNIQUES
------------------
Action 1 — [description]
  Résultat : [Résumé]

Action 2 — [description]
  Résultat : [Résumé]

CONFIGURATIONS MODIFIÉES
------------------------
Avant  : [Paramètre] = [Valeur]
Après  : [Paramètre] = [Valeur]
Raison : [Justification]
— ou —
Aucune configuration modifiée.

TESTS DE VALIDATION
--------------------
✓ [Test 1] : OK
✓ [Test 2] : OK

RÉSULTAT FINAL
--------------
État : [RÉSOLU / PARTIELLEMENT RÉSOLU / À SUIVRE]

SUIVI REQUIS
------------
□ [Action de suivi] — Échéance : [date]

POST-INTERVENTION
-----------------
□ Courriel client envoyé : [Oui / Non / Non requis]
□ Documentation Hudu mise à jour : [Oui / Non / Non requis]

TEMPS INTERVENTION
------------------
Temps total : [Xh Ym]
═══════════════════════════════════════════════════════════════
```

## Exemple : Patching Windows Server

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE — PATCHING WINDOWS SERVER
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date        : 2026-02-10
Technicien  : Eric Allain
Client      : Otto Inc Inc.
Billet CW   : #T789456
Équipements : SRV-DC01, SRV-APP01, SRV-SQL01, SRV-FILE01, SRV-WEB01
Type        : Maintenance préventive — patching mensuel

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

CONTEXTE INITIAL
----------------
Fenêtre de maintenance mensuelle approuvée — mises à jour Patch Tuesday Février 2026.
Objectif : 5 serveurs Windows Server 2022.
Backup pré-maintenance confirmé. Snapshots créés avant le début.

ACTIONS TECHNIQUES
------------------
Precheck — vérification espace disque et services sur tous les serveurs
  Résultat : Tous les serveurs disposent de l'espace requis. Aucun pending reboot.

Patching SRV-FILE01 (non-critique en premier)
  Résultat : 15 KB installés, reboot complété, services UP ✓

Patching SRV-WEB01
  Résultat : 15 KB installés, reboot complété, IIS démarré automatiquement ✓

Patching SRV-APP01
  Résultat : 15 KB installés, reboot complété, tous services applicatifs OK ✓

Patching SRV-SQL01
  Résultat : 15 KB installés, reboot complété
  Services SQL post-reboot : MSSQLSERVER Running ✓
  Test connexion DB master : Success ✓

Patching SRV-DC01 (DC en dernier)
  Résultat : 15 KB installés, reboot complété
  Réplication AD : repadmin /replsummary → OK, aucun échec ✓

CONFIGURATIONS MODIFIÉES
------------------------
Aucune configuration modifiée. Installation patches uniquement.

TESTS DE VALIDATION
--------------------
✓ Connectivité tous serveurs : OK
✓ Accès RDP tous serveurs : OK
✓ Services critiques (AD, SQL, IIS, partages) : OK
✓ Accès applications depuis poste test : OK
✓ Event Logs post-patching (aucune erreur critique) : OK

RÉSULTAT FINAL
--------------
État : RÉSOLU — 5/5 serveurs patchés avec succès

SUIVI REQUIS
------------
□ Supprimer snapshots VMware — Échéance : 2026-02-13
□ Surveiller Event Logs 24h

POST-INTERVENTION
-----------------
□ Courriel client envoyé : Oui
□ Documentation Hudu mise à jour : Non requis

TEMPS INTERVENTION
------------------
Temps total : 3h15 — Préparation : 15 min | Patching : 2h40 | Tests : 15 min | Doc : 5 min
═══════════════════════════════════════════════════════════════
```

## Exemple : Troubleshooting Veeam

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE — TROUBLESHOOTING BACKUP VEEAM
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date        : 2026-02-10
Technicien  : Eric Allain
Client      : Otto Inc Inc.
Billet CW   : #T789457
Équipements : SRV-FILE01, VEEAM-SRV
Type        : Troubleshooting urgent — backup failed

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

CONTEXTE INITIAL
----------------
Alerte Veeam : job "Daily Backup - File Servers" en échec.
Erreur : "Insufficient disk space on backup repository".
Impact : backup non complété depuis 24h.

DIAGNOSTIC / ANALYSE
--------------------
Vérification espace repository Backup-Repo-01 :
  Capacité : 10TB | Libre : 45GB (0.45%) ⚠️
Cause identifiée : anciens restore points non supprimés — compact backup désactivé.
Event Log Veeam : ID 190 "Insufficient disk space"

ACTIONS TECHNIQUES
------------------
Identification restore points obsolètes (> 14 jours)
  Résultat : 8 restore points trouvés

Suppression des 8 restore points obsolètes
  Résultat : 1.2TB libéré — espace libre : 12.5% ✓

Correction configuration rétention automatique
  Avant  : Compact full backup = Disabled
  Après  : Compact full backup = Enabled

Relance manuelle du job backup
  Résultat : Job démarré

Vérification job complété
  Résultat : Success — restore point créé ✓

Test de restauration d'un fichier test
  Résultat : Fichier restauré avec succès ✓

TESTS DE VALIDATION
--------------------
✓ Job backup complété sans erreur : OK
✓ Espace repository > 10% : OK (12.5%)
✓ Restore point créé et accessible : OK
✓ Test restore 1 fichier : OK

RÉSULTAT FINAL
--------------
État : RÉSOLU

SUIVI REQUIS
------------
□ Vérifier job ce soir — Échéance : 2026-02-10 23:59
□ Surveiller espace repository — hebdomadairement
□ Révision capacité stockage — Échéance : 2026-08-01

POST-INTERVENTION
-----------------
□ Courriel client envoyé : Oui
□ Documentation Hudu mise à jour : Non requis

TEMPS INTERVENTION
------------------
Temps total : 1h45 — Diagnostic : 20 min | Résolution : 60 min | Tests : 15 min | Doc : 10 min
═══════════════════════════════════════════════════════════════
```

---

# TEMPLATE 5 : CW_NOTE_INTERNE_STAR (par asset — patching multi-serveurs)

## Quand l'utiliser
Maintenance multi-serveurs avec precheck/postcheck par asset. Idéal pour le patching planifié.
Pas d'horodatage sur les actions individuelles.

## Format

```
Billet : [#T...]
Fenêtre : [début → fin]
Intervention : [maintenance / patching / CVE]
Approbations : reboot=[oui/non] | rollback=[oui/non]

═══════════════════════════════════════════════════════════════
[SRV-XXX] — [Rôle] — [OS] — Criticité : [haute / moyenne / basse]
═══════════════════════════════════════════════════════════════

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

PRÉ-CHECK
---------
□ CPU                : [X% — Normal / ATTENTION / CRITIQUE]
□ RAM                : [X.XGB / X.XGB — X%]
□ Espace disque C:   : [X.XGB libres — X% — Normal / ATTENTION / CRITIQUE]
□ Pending reboot     : [Oui / Non]
□ Services arrêtés   : [Liste ou Aucun]
□ Event Logs 24h     : [OK ou anomalies détectées]
□ Backup / snapshot  : [OK / À confirmer]

ACTIONS
-------
[Action] → [Résultat]
[Action] → [Résultat]

POST-CHECK
----------
□ CPU / RAM           : [X% / X% — Normal]
□ Services critiques  : [OK / KO — liste si KO]
□ Pending reboot      : [Oui / Non]
□ Smoke test          : [résultat selon le rôle — ex: ping AD, query SQL, session RDS]
□ Event Logs post-op  : [OK ou nouvelles anomalies]
□ Mode maintenance RMM: [OFF confirmé]

STATUT : [OK / Partiel / Échec]
```

---

# TEMPLATE 6 : EMAIL_CLIENT

## Quand l'utiliser
Après toute intervention visible par le client : maintenance planifiée, incident P1/P2, problème signalé.

## Règles
- ✅ Prénom du contact (personnalisé)
- ✅ Ton professionnel et accessible — lu en < 2 minutes
- ✅ 3 à 5 paragraphes maximum
- ❌ Jargon technique, IPs, noms serveurs, commandes, CVE
- ❌ Promettre ce qui n'est pas confirmé

## Format

```
Objet : [Type intervention] — [Résultat] — Billet #[XXXXX]

Bonjour [Prénom],

[Paragraphe 1 — Contexte : ce qui a été fait, sans détails techniques]

[Paragraphe 2 — Résultat : état des services / impact pour le client]

[Paragraphe 3 — Recommandations si applicable — sinon omettre]

[Paragraphe 4 — Conclusion + disponibilité]

Cordialement,
[Prénom Technicien]
Administrateur système
```

## Exemples

### Maintenance planifiée réussie

```
Objet : Maintenance serveurs complétée — Billet #T789456

Bonjour Marie,

Je vous confirme que la maintenance planifiée de vos serveurs s'est déroulée
sans incident cette nuit. Les mises à jour de sécurité de février 2026 ont été
installées sur vos 5 serveurs. Chaque serveur a été redémarré et tous les services
ont été vérifiés avant la fin de la fenêtre.

Résultat : vos serveurs sont maintenant à jour. Aucun problème n'a été rencontré
et vos opérations peuvent continuer normalement ce matin.

La prochaine fenêtre de maintenance est prévue pour mars 2026. Nous vous
contacterons 2 semaines à l'avance pour confirmer la date exacte.

N'hésitez pas à nous contacter si vous constatez quoi que ce soit d'inhabituel.

Cordialement,
Eric Allain
Administrateur système
```

### Troubleshooting réussi

```
Objet : Problème de sauvegarde résolu — Billet #T789457

Bonjour Pierre,

Suite à l'alerte de ce matin concernant l'échec de sauvegarde, je vous confirme
que le problème a été identifié et résolu.

Nous avons corrigé la cause et relancé la sauvegarde manuellement. Celle-ci s'est
complétée avec succès. Des alertes ont également été mises en place pour prévenir
ce type de situation.

Recommandation : l'espace de stockage dédié aux sauvegardes approche sa capacité
optimale. Nous recommandons de planifier une expansion d'ici 3 mois.

Je reste disponible si vous souhaitez discuter de cette recommandation.

Cordialement,
Eric Allain
Administrateur système
```

### Intervention d'urgence

```
Objet : Intervention urgente complétée — Service restauré — Billet #T789458

Bonjour Sophie,

Je vous confirme que le service inaccessible depuis 14h30 a été restauré et est
maintenant pleinement opérationnel depuis 15h45.

Nous avons diagnostiqué et corrigé un service critique qui ne démarrait plus
correctement. L'accès aux applications a été testé et confirmé avant la remise
en production.

Nous allons surveiller ce système de près pendant 48 heures et effectuer une
analyse approfondie pour identifier la cause racine. Je vous tiendrai informée
des résultats.

Merci de votre patience. N'hésitez pas à nous contacter si vous constatez quoi
que ce soit d'anormal.

Cordialement,
Eric Allain
Administrateur système
```

### Alerte NOC — Intervention suite à monitoring

> Utiliser cette variante quand le billet est issu d'une alerte automatique du système de surveillance.
> L'ouverture avec **"Suite à une alerte reçue par notre département de surveillance..."** est OBLIGATOIRE
> pour que le client comprenne que c'est une détection proactive, pas une plainte de leur part.

```
Objet : Alerte monitoring traitée — [Type d'alerte] — Billet #T789460

Bonjour [Prénom],

Suite à une alerte reçue par notre département de surveillance, nous avons
immédiatement pris en charge une anomalie détectée sur votre infrastructure.

[Paragraphe 2 — Ce qui a été détecté (sans détails techniques) et ce qui a été fait]

[Paragraphe 3 — Résultat : état actuel des systèmes concernés]

[Paragraphe 4 — Recommandations si applicable — sinon omettre]

Cette intervention fait partie de notre surveillance proactive visant à détecter
et corriger les problèmes avant qu'ils n'impactent vos opérations.

N'hésitez pas à nous contacter si vous avez des questions.

Cordialement,
[Prénom Technicien]
Administrateur système
```

### Exemple concret — Alerte espace disque

```
Objet : Alerte monitoring traitée — Espace disque — Billet #T789461

Bonjour Marie,

Suite à une alerte reçue par notre département de surveillance, nous avons
immédiatement pris en charge une anomalie détectée sur votre serveur de fichiers.

Notre système de monitoring a signalé que l'espace disponible sur le disque
principal était descendu sous le seuil critique. Nous avons procédé au nettoyage
des fichiers temporaires et des journaux obsolètes.

Résultat : l'espace disque est revenu à un niveau sain. Votre serveur fonctionne
normalement et aucune interruption de service n'a été nécessaire.

Cette intervention fait partie de notre surveillance proactive visant à détecter
et corriger les problèmes avant qu'ils n'impactent vos opérations.

N'hésitez pas à nous contacter si vous avez des questions.

Cordialement,
Eric Allain
Administrateur système
```

### Problème partiellement résolu

```
Objet : Mise à jour — Intervention en cours — Billet #T789459

Bonjour Nathalie,

Je voulais vous donner une mise à jour sur l'avancement du problème signalé
ce matin.

Nous avons identifié et corrigé la cause principale. La situation fonctionne
maintenant correctement pour la majorité de vos systèmes. Nous continuons
à investiguer un point spécifique sur un composant supplémentaire.

Statut actuel : vos données critiques sont sécurisées. Nous travaillons
activement sur le cas restant et prévoyons le résoudre d'ici la fin de journée.

Je vous recontacte dès que l'intervention est complètement terminée.

Cordialement,
Eric Allain
Administrateur système
```

---

# TEMPLATE 7 : AVIS_TEAMS

## Quand l'utiliser
Au début d'une intervention — générer immédiatement dès que le type d'urgence est connu.
**P1/P2 → variante urgence obligatoire.** Maintenance planifiée → variante standard.

## Règles
- ✅ Icône en première position
- ✅ Ton clair, court, billet mentionné
- ❌ IPs, noms serveurs internes détaillés, commandes, credentials

---

## Variante URGENCE P1/P2 — Format début

```
🔴 P1 — Panne en cours — [CLIENT] (Ticket #[XXXXX])

[Description courte de la panne — ex : Site inaccessible / Hyperviseur en panne / Réseau down]

⏱️ Impact : [services impactés — ex : tous les utilisateurs hors ligne]
🔧 Technicien en charge : [Nom/Initiales]

@NOC @[Coordonnateur des urgences]
```

## Variante URGENCE P1/P2 — Format fin

```
✅ P1 — Service restauré — [CLIENT] (Ticket #[XXXXX])

[Service/rôle] opérationnel depuis [HH:MM] — durée d'interruption : [Xh Ym].
Surveillance active en cours.
```

### Exemple — Site down / Hyperviseur

```
🔴 P1 — Panne en cours — Acme Corp (Ticket #T1612445)

Site inaccessible — hôte Hyper-V en panne suite à défaillance stockage.
Techniciens en intervention — estimation de rétablissement en cours.

⏱️ Impact : tous les services du site hors ligne.
🔧 Technicien en charge : EA

@NOC @CoordUrgences
```

---

## Variante MAINTENANCE PLANIFIÉE — Format début

```
⚠️ Maintenance en cours — [RÔLE DU SERVEUR] (Ticket #[XXXXX])
Client : [CLIENT]

Intervention en cours — [TYPE] sur [rôle/type d'équipement] — redémarrage possible si requis.

⏱️ Impact : indisponibilité temporaire du service durant l'intervention.

Merci.
@NOC
```

## Variante MAINTENANCE PLANIFIÉE — Format fin

```
✅ Intervention terminée — Ticket #[XXXXX]
Client : [CLIENT]

[SERVICE/RÔLE] opérationnel et fonctionnement confirmé.
```

## Exemples — Maintenance

### Maintenance SQL en cours

```
⚠️ Maintenance en cours — Serveur de base de données SQL (Ticket #1600968)
Client : Natpro Inc.

Intervention technique sur le serveur de base de données — redémarrage prévu dans le cadre de la maintenance.

⏱️ Impact : indisponibilité temporaire du serveur et des applications dépendantes de la base de données.

Merci de ne pas vous reconnecter tant que la maintenance n'est pas terminée.
@NOC
```

### Fin de maintenance planifiée

```
✅ Maintenance terminée — Ticket #1600968
Client : Natpro Inc.

Serveurs opérationnels — mises à jour installées et services confirmés.
```

---

# T8 — MEMO_INTERNE

> **Usage :** Communication interne rapide vers coordonnateur, VCIO ou équipe de gestion. Ne va PAS dans CW client. Peut être copié dans un courriel interne, Teams ou note de gestion.
> **Destinataires typiques :** Coordonnateur · VCIO · Gestionnaire de compte · Chef d'équipe NOC

## Structure obligatoire

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MÉMO INTERNE — [TITRE COURT]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
À           : [Coordonnateur / VCIO / Gestionnaire / Chef NOC]
De          : [Technicien / Agent IT]
Date        : [YYYY-MM-DD HH:MM]
Billet      : #[XXXXX]
Client      : [Nom du client]

RAISON
──────
[Motif de l'intervention ou de l'escalade — 1 ligne]

RÉSUMÉ
──────
[Explication technique synthétique — 2 à 4 lignes maximum.
Ce qui a été fait, ce qui a été trouvé, ce qui a été résolu
ou ce qui nécessite un suivi.]

STATUT       : [✅ Résolu | ⚠️ En cours | 🔴 Escaladé]
SUIVI REQUIS : [Oui — [action requise] | Non]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Exemples

### Escalade vers VCIO — Incident de sécurité

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MÉMO INTERNE — Détection d'activité suspecte
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
À           : VCIO
De          : IT-SysAdmin / NOC
Date        : 2026-05-12 14:32
Billet      : #1609234
Client      : Acme Corp

RAISON
──────
Activité suspecte détectée sur un poste de travail — connexions sortantes inhabituelles.

RÉSUMÉ
──────
Lors d'un audit RMM de routine, des connexions sortantes répétées vers une adresse
non répertoriée ont été identifiées. Le poste a été isolé du réseau en attente de
validation. Aucune donnée critique n'a été confirmée compromise à ce stade.
L'utilisateur a été avisé de ne pas utiliser le poste.

STATUT       : ⚠️ En cours
SUIVI REQUIS : Oui — validation VCIO avant réintégration réseau
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Mémo post-intervention — Patching DC

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MÉMO INTERNE — Patching mensuel complété
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
À           : Coordonnateur
De          : IT-MaintenanceMaster / Technicien
Date        : 2026-05-12 22:15
Billet      : #1598701
Client      : TechGroup Inc.

RAISON
──────
Rapport de fin de maintenance mensuelle — patching contrôleur de domaine.

RÉSUMÉ
──────
Mises à jour Windows (14 correctifs) appliquées avec succès sur le contrôleur de
domaine principal. Redémarrage planifié effectué en fenêtre de maintenance approuvée.
Réplication AD, DNS et accès SYSVOL vérifiés et opérationnels post-reboot.
Aucune anomalie détectée.

STATUT       : ✅ Résolu
SUIVI REQUIS : Non
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

*TEMPLATE_BUNDLE_CW_CLOSE v2.5 — IT MSP Intelligence Platform — 2026-05-14*
