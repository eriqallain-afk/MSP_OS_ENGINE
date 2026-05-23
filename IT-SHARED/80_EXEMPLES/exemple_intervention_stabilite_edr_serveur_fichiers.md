# Exemple d’intervention — Stabilité EDR sur serveur de fichiers critique

**Type :** Référence interne MSP  
**Cas :** Serveur de fichiers critique avec accès administratifs gelés après suspicion de mise à jour EDR  
**Priorité type :** P2  
**Usage :** Aide-mémoire pour incidents similaires, escalade sécurité et livrables CW  
**Version :** 1.0  
**Date :** 2026-05-18  

---

## 1. Résumé exécutif

Ce cas documente une intervention sur un serveur de fichiers critique dont les accès administratifs sont devenus non fonctionnels, alors que les partages réseau demeuraient accessibles.

Le client associait l’incident à une mise à jour SentinelOne. Un hard reboot a été requis pour récupérer l’administration du serveur. Après le redémarrage, l’analyse a montré une séquence notable : driver SentinelOne non chargé au boot, agent SentinelOne revenu actif, installation d’un composant kernel SentinelOne, puis erreurs CAPI2/System Writer et timeout VSS.

La cause racine du gel initial n’a pas été prouvée. La corrélation SentinelOne / driver / VSS-System Writer / CAPI2 était toutefois suffisamment forte pour justifier une escalade vers IT-SecurityMaster et/ou le fournisseur EDR.

---

## 2. Objectif du document

Utiliser ce fichier comme référence lorsque :

- un serveur critique reste partiellement fonctionnel mais n’est plus administrable;
- RMM, RDP, console locale ou WinRM sont gelés ou non exploitables;
- un agent EDR, un agent de sécurité ou un contrôle applicatif est soupçonné;
- le RMM ne retourne pas correctement les scripts longs;
- un hard reboot a été nécessaire;
- il faut documenter clairement les faits, hypothèses, actions, résultats et suivis.

---

## 3. Runbooks et références utilisés

| Runbook / fichier | Usage |
|---|---|
| `IT-SHARED/10_RUNBOOKS/00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md` | Garde-fous : lecture seule d’abord, prudence sur actions risquées, séparation faits/hypothèses, aucun secret dans les livrables. |
| `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-HealthCheck_V2.md` | Cadre de diagnostic serveur : OS, uptime, disques, services, processus, événements. |
| `IT-SHARED/30_SCRIPTS/MAINT-SRV-MasterScript_V1.ps1` | Diagnostic initial proposé. Dans ce cas, jugé trop lourd via RMM et remplacé par des micro-collectes ciblées. |
| `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-PendingReboot_V2.md` | Interprétation de `PendingFileRename=True` et logique GO/HOLD/NO-GO avant redémarrage. |
| `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE_BUNDLE_CW_CLOSE.md` | Génération des livrables T2 — Discussion STAR et T3 — Note interne. |

---

## 4. Symptômes typiques

- Serveur de fichiers critique fortement dégradé.
- RMM / ScreenConnect non fonctionnel ou ne retourne pas d’output.
- RDP non fonctionnel.
- WinRM bloqué ou non exploitable.
- Console locale ou hors bande rapportée comme gelée.
- Services en état instable ou gelés.
- Partages réseau encore accessibles.
- Suspicion client d’un incident lié à une mise à jour EDR.
- Historique possible d’incidents similaires.
- Hard reboot nécessaire en dernier recours.

---

## 5. Garde-fous appliqués

- Lecture seule d’abord dès que le serveur est exploitable.
- Ne pas désactiver SentinelOne ou l’EDR de façon permanente.
- Ne pas créer d’exclusion large sur un volume complet.
- Ne pas conclure à une infection sans IOC confirmé.
- Ne pas conclure que SentinelOne est la cause racine sans validation vendor.
- Ne pas relancer de script lourd si le RMM affiche une fenêtre grise ou ne retourne pas l’output.
- Préférer des micro-collectes ciblées, une à la fois.
- Documenter les faits confirmés séparément des hypothèses.

---

## 6. Données techniques observées dans le cas de référence

| Élément | Observation |
|---|---|
| OS | Microsoft Windows Storage Server 2016 Standard |
| Version | 10.0.14393 |
| Rôle | Serveur de fichiers / stockage |
| Dernier boot | 2026-05-15 10:20:33 |
| Pending reboot | `PendingFileRename=True`, `CBS=False`, `WU=False` |
| Volume de données | Environ 5,5 % libre, seuil critique |
| EDR | SentinelOne actif après redémarrage |
| Sécurité additionnelle | ThreatLocker et Defender observés actifs |
| RMM | ScreenConnect actif après redémarrage |
| Services fichiers | DFSR / LanmanServer revenus actifs |

---

## 7. Timeline de référence

| Heure locale | Source | Événement |
|---|---|---|
| 10:20 | Intervention | Hard reboot effectué en dernier recours. |
| 10:21:20 | SCM | `DFSR`, `LanmanServer`, `WinRM` entrent en état Running. |
| 10:21:21 | SCM | `ScreenConnect Client` entre en état Running. |
| 10:21:21 | SCM | `WinDefend` entre en état Running. |
| 10:21:36 | SCM | `SentinelDeviceControl` ne charge pas au démarrage. |
| 10:21:36 | SCM | `ThreatLockerService` entre en état Running. |
| 10:22:23 | SCM | `Sentinel Agent` entre en état Running. |
| 10:27:29 | SCM | Installation de `SentinelObliterator.sys` depuis `C:\\Windows\\Temp\\SentinelOneInstaller\\temp_content\\`. |
| 10:28:11 | Application | `CAPI2` Event ID 513 — System Writer / Access denied. |
| 10:30:12 | Application | `VSS` Event ID 8229 — timeout entre Freeze et Thaw. |
| 10:30:19 | Application | `CAPI2` Event ID 513 répété. |
| 17:32:08 | RMM | Test RMM léger confirmé OK. |

---

## 8. Interprétation technique

### Faits confirmés

- Le serveur est revenu en ligne après hard reboot.
- Les services critiques réseau/fichiers/admin sont revenus Running.
- SentinelOne est revenu actif après redémarrage.
- Un driver SentinelOne n’a pas chargé au boot.
- Un composant kernel SentinelOne a été installé post-reboot.
- Des erreurs VSS/System Writer/CAPI2 sont survenues quelques minutes après.
- Aucun IOC ou indicateur de compromission n’a été confirmé.

### Hypothèse principale

Incident de stabilité ou d’interopérabilité impliquant possiblement :

- mise à jour ou réparation SentinelOne;
- composant driver/kernel EDR;
- VSS / System Writer / CAPI2;
- serveur de fichiers avec DFSR;
- ThreatLocker;
- Defender;
- espace disque critique;
- pending reboot par remplacement de fichiers.

### Ce qui n’est pas prouvé

- SentinelOne comme cause racine du gel initial.
- Infection ou compromission.
- Clic utilisateur.
- Problème M365.
- Exclusion manquante comme cause directe.
- Conflit ThreatLocker/SentinelOne comme cause prouvée.

---

## 9. Procédure recommandée pour cas similaire

### Étape 1 — Triage

1. Confirmer l’impact utilisateur.
2. Confirmer si les partages ou applications répondent encore.
3. Identifier les accès encore possibles : RMM, RDP, console, iDRAC/iLO, hyperviseur.
4. Éviter tout reboot si les partages sont encore utilisés, sauf si validé en urgence.
5. Confirmer backup récent et absence de job critique en cours lorsque possible.

### Étape 2 — Si RMM ne retourne pas les scripts longs

Utiliser un test minimal :

```powershell
$Out="C:\\Windows\\Temp\\RMM_TEST.txt"
"TEST RMM OK - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $Out -Encoding UTF8
Get-Content $Out
```

### Étape 3 — Micro-collectes ciblées

Collecter un bloc à la fois :

- services critiques;
- pending reboot;
- disques;
- System / Service Control Manager;
- Application / CAPI2 / VSS / MSIInstaller;
- événements EDR si disponibles.

### Étape 4 — Analyse sécurité

Escalader vers l’équipe sécurité si :

- driver EDR ne charge pas au boot;
- composant kernel EDR installé post-reboot;
- VSS/System Writer/CAPI2 échoue après activité EDR;
- historique de récidive après mises à jour EDR;
- client demande une explication technique ou une prévention.

---

## 10. Décisions opérationnelles de référence

| Décision | Raison |
|---|---|
| Ne pas relancer le MasterScript complet | Trop lourd pour RMM dans ce cas; fenêtre grise / absence d’output. |
| Utiliser des scripts courts | Réduit le risque et améliore la lisibilité. |
| Ne pas désactiver EDR | Aucune preuve que la désactivation est requise ou sécuritaire. |
| Ne pas ajouter d’exclusion large | Risque sécurité élevé sans preuve. |
| Escalader IT-SecurityMaster | Validation des versions, drivers, exclusions et known issues requise. |
| Préparer message client-safe | Le client doit être rassuré sans attribution causale non prouvée. |

---

## 11. Brief IT-SecurityMaster — modèle

```text
[ESCALADE → IT-SecurityMaster]

Ticket      : #[À CONFIRMER]
Client      : [À CONFIRMER]
Serveur     : [À CONFIRMER]
Demande     : Contrôle exclusions EDR / analyse stabilité agent
Priorité    : P2

CONTEXTE
--------
Serveur critique avec gel des accès administratifs. Les services de fichiers étaient encore accessibles avant redémarrage. Un hard reboot a été nécessaire pour récupérer l’administration.

ÉTAT OBSERVÉ
------------
OS : [À CONFIRMER]
Rôle : serveur de fichiers / stockage
Pending reboot : [À CONFIRMER]
Espace disque : [À CONFIRMER]
Agents observés : EDR, ThreatLocker, Defender, RMM, DFSR

ÉVÉNEMENTS NOTABLES
-------------------
- Driver EDR non chargé au boot : [À CONFIRMER]
- Agent EDR revenu Running : [À CONFIRMER]
- Composant kernel EDR installé post-reboot : [À CONFIRMER]
- CAPI2/System Writer : [À CONFIRMER]
- VSS writer timeout : [À CONFIRMER]

DEMANDE
-------
Valider version agent, comportement driver, exclusions applicables, known issues et stratégie de ring pilote/différé pour serveurs critiques.

CONTRAINTES
-----------
Ne pas désactiver EDR.
Ne pas créer d’exclusion large.
Ne pas conclure à une compromission sans preuve.
```

---

## 12. Questions à poser au vendor / SOC

1. Le non-chargement du driver EDR au boot est-il attendu pendant l’upgrade?
2. Quel est le rôle exact du composant kernel observé?
3. S’agit-il d’un upgrade normal, repair, cleanup, rollback ou driver replacement?
4. Y a-t-il eu service restart, driver reload ou anti-tamper event?
5. Y a-t-il eu scan intensif, remediation, quarantine ou policy update?
6. La version agent a-t-elle des known issues avec :
   - Windows Server / Storage Server 2016;
   - VSS/System Writer;
   - DFSR;
   - gros volumes de fichiers;
   - ThreatLocker;
   - Defender;
   - RMM / ScreenConnect?
7. Un ring pilote/différé est-il recommandé pour les serveurs critiques?

---

## 13. Message client-safe — modèle

```text
Bonjour,

Nous avons poursuivi l’analyse technique après le retour en ligne du serveur. Les journaux montrent que les services principaux sont revenus correctement après le redémarrage, incluant les services de fichiers, d’administration distante et de sécurité.

Nous avons toutefois identifié des événements liés à la protection endpoint et à des composants système de sauvegarde/instantané Windows dans les minutes suivant le redémarrage. Ces éléments renforcent l’hypothèse d’un problème d’interaction ou de stabilité autour de la mise à jour de l’agent de sécurité, mais ne permettent pas de conclure à une cause racine définitive sans validation additionnelle par l’équipe sécurité ou le fournisseur.

Aucun élément analysé à ce stade ne confirme une compromission ou un clic utilisateur malveillant. La recommandation est de poursuivre l’analyse avec l’équipe sécurité afin de valider la mise à jour de l’agent, les exclusions applicables et la stratégie de déploiement des mises à jour sur ce serveur critique.
```

---

## 14. T2 — Discussion STAR — modèle

```text
────────────────────────────────────────────────────────
       Intervention urgente — stabilité serveur fichiers
────────────────────────────────────────────────────────

BILLET : #[À CONFIRMER]
DATE : [YYYY-MM-DD]
TECHNICIEN : [À CONFIRMER]
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

SITUATION :
---------
• Le client a signalé un blocage majeur des accès administratifs à un serveur de fichiers critique, alors que les partages réseau demeuraient accessibles pour les utilisateurs.

TÂCHE :
---------
• Rétablir l’accès administratif au serveur, valider son retour en service et documenter les éléments pouvant expliquer la récurrence du problème.

ACTIONS :
---------
• [HH:MM] — Redémarrage forcé effectué en dernier recours afin de récupérer l’accès au système.
• [HH:MM] — Validation du redémarrage des services principaux du serveur, incluant les services réseau, fichiers et accès distant.
• [HH:MM] — Validation du retour en ligne des services de sécurité et de gestion à distance.
• [HH:MM] — Identification d’une activité de mise à jour ou de remplacement de composant de l’agent de sécurité après le redémarrage.
• [HH:MM] — Analyse d’événements système liés aux composants Windows d’instantané/sauvegarde et à la protection endpoint.

RÉSULTAT :
---------
• Le serveur est revenu en ligne après redémarrage et les services critiques ont été confirmés opérationnels.
• Les accès de gestion sont redevenus fonctionnels pour permettre la poursuite de l’analyse.
• Aucun élément analysé à ce stade ne confirme une compromission ou un clic utilisateur malveillant.
• La corrélation avec une mise à jour de l’agent de sécurité est renforcée, mais la cause racine demeure à confirmer par l’équipe sécurité ou le fournisseur.

RECOMMANDATION :
---------
• Poursuivre l’analyse avec l’équipe sécurité afin de valider la mise à jour de l’agent, les exclusions applicables et la stratégie de déploiement des mises à jour sur les serveurs critiques.
```

---

## 15. T3 — Note interne — modèle

```text
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE — STABILITÉ EDR SERVEUR
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
-----------------------
Date        : [YYYY-MM-DD]
Technicien  : [À CONFIRMER]
Client      : [À CONFIRMER]
Billet CW   : #[À CONFIRMER]
Équipements : [À CONFIRMER]
Type        : Troubleshooting / Urgence / Escalade sécurité

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

CONTEXTE INITIAL
----------------
Serveur critique avec gel majeur de la couche interactive/admin alors que les services de fichiers demeuraient accessibles.

DIAGNOSTIC / ANALYSE
--------------------
OS observé : [À CONFIRMER]
Pending reboot : [À CONFIRMER]
Espace disque : [À CONFIRMER]
Services observés : EDR, RMM, ThreatLocker, Defender, DFSR, VSS

Événements notables :
- Driver EDR non chargé au boot : [À CONFIRMER]
- Agent EDR revenu Running : [À CONFIRMER]
- Composant kernel EDR installé post-reboot : [À CONFIRMER]
- CAPI2 / System Writer : [À CONFIRMER]
- VSS writer timeout : [À CONFIRMER]

Analyse :
La séquence renforce l’hypothèse d’un problème de stabilité/interoperabilité lié à l’EDR, ses composants driver/kernel et les composants VSS/System Writer/CAPI2. La causalité du gel initial n’est pas prouvée.

CONFIGURATIONS MODIFIÉES
-------------------------
Aucune configuration modifiée par l’analyse.
Aucune exclusion EDR ajoutée.
Aucune désactivation EDR effectuée.
Aucune exclusion large appliquée.

RÉSULTAT FINAL
--------------
État : PARTIELLEMENT RÉSOLU / À SUIVRE

SUIVI REQUIS
------------
■ IT-SecurityMaster / vendor EDR : valider comportement driver et upgrade agent.
■ IT-SecurityMaster : revoir exclusions applicables.
■ INFRA / client : planifier action sur l’espace disque si sous seuil critique.
═══════════════════════════════════════════════════════════════
```

---

## 16. Critères de fermeture

Le billet peut être fermé ou partiellement fermé si :

- serveur revenu en ligne;
- services critiques opérationnels;
- accès d’administration récupéré;
- partages/applications validés;
- escalade sécurité/vendor créée ou documentée;
- client informé avec message prudent;
- suivis séparés créés au besoin.

Ne pas fermer comme cause racine confirmée si :

- logs vendor non validés;
- événements avant reboot incomplets;
- comportement driver non confirmé;
- aucune preuve directe ne relie l’upgrade au gel initial.

---

## 17. Tags recommandés

```text
P2
Serveur critique
Serveur fichiers
EDR
SentinelOne
ThreatLocker
VSS
CAPI2
System Writer
RMM
ScreenConnect
PendingFileRename
Hard reboot
Stabilité agent
Escalade sécurité
Vendor escalation
```

---

## 18. Leçons apprises

1. Un serveur peut être partiellement opérationnel tout en étant administrativement gelé.
2. Une corrélation EDR forte ne suffit pas à prouver une cause racine.
3. Les scripts lourds doivent être remplacés par des micro-collectes lorsque le RMM ne retourne pas l’output.
4. Les erreurs VSS/System Writer/CAPI2 après activité EDR kernel méritent une escalade.
5. Les exclusions larges sont à éviter sans preuve.
6. La communication client doit rester prudente et non accusatoire.
7. La qualité MSP vient autant de la méthode, de la traçabilité et des livrables que de la remise en ligne.

---

**Fin du fichier de référence.**
