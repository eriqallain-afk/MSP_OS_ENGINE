# Fichier de référence — Cas stabilité EDR / serveur critique

**Type de cas :** Gel serveur / instabilité post-update EDR / SentinelOne ou équivalent  
**Usage :** Référence interne MSP pour cas similaires  
**Public cible :** IT-SysAdmin, IT-SecurityMaster, NOC, TECH  
**Classification par défaut :** P2 — Stabilité EDR sur serveur critique  
**Statut sécurité par défaut :** Compromission non confirmée tant qu’aucun IOC n’est observé  

---

## 1. Objectif du fichier

Ce document sert de modèle de référence pour traiter un cas où un serveur critique présente un gel, une instabilité RMM/RDP/console, ou un comportement anormal dans une fenêtre de mise à jour EDR.

L’objectif est de :

- préserver les artefacts ;
- éviter les conclusions hâtives ;
- distinguer corrélation et causalité ;
- encadrer les vérifications SentinelOne / EDR ;
- documenter les exclusions et interactions ;
- produire des notes CW et communications client-safe ;
- décider si une escalade vendor est justifiée.

---

## 2. Règles de traitement

### À faire

- Travailler en lecture seule au départ.
- Établir une timeline précise.
- Corréler les événements EDR, Windows, RMM, backup et sécurité.
- Confirmer les versions agent / engine / policy.
- Vérifier les exclusions effectives appliquées au bon scope.
- Documenter les faits observés séparément des hypothèses.
- Escalader vendor si des composants kernel/driver ou VSS/System Writer sont impliqués.

### À ne pas faire

- Ne pas désactiver l’EDR sans escalade et approbation senior.
- Ne pas éteindre une machine suspecte.
- Ne pas conclure à une infection sans IOC.
- Ne pas créer d’exclusion large sur un volume de données.
- Ne pas appliquer `disable_all_monitors` sans justification forte.
- Ne pas redémarrer un serveur critique sans fenêtre/approbation si l’état est stable.

---

## 3. Signaux d’entrée typiques

| Signal | Exemple | Importance |
|---|---|---|
| Gel RMM / RDP / console locale | RMM sans output, RDP bloqué, clavier/souris gelés | Indique un gel couche interactive/admin |
| SMB encore accessible | Partages réseau fonctionnels | Suggère que l’OS n’est pas complètement arrêté |
| Hard reboot requis | Reboot forcé par client ou tech | Perte possible d’artefacts RAM |
| Update EDR récente | Agent version change, engine update, security update | Corrélation à analyser |
| Composant driver/kernel | Device control, anti-tamper, filter driver, cleanup driver | Critique pour escalade vendor |
| VSS / CAPI2 / System Writer | VSS timeout, CAPI2 513 | Interaction possible avec backup/driver/EDR |
| DFSR actif | `dfsrs` haut CPU ou logs DFSR | Facteur aggravant sur serveur de fichiers |
| ThreatLocker / Defender présents | Double contrôle sécurité | Risque d’interopérabilité |
| PendingFileRename | True après update | Indique remplacement de fichiers en attente |

---

## 4. Classification initiale

### Classification recommandée

**P2 — Stabilité EDR / serveur critique**

À maintenir tant que :

- aucun IOC de compromission n’est confirmé ;
- l’EDR est actif et connecté ;
- aucun mouvement latéral n’est observé ;
- aucun chiffrement, exfiltration ou compte compromis n’est confirmé.

### Monter en P1 si

- ransomware actif ;
- DC ou serveur critique compromis ;
- exfiltration confirmée ;
- compte admin compromis ;
- plusieurs serveurs impactés simultanément ;
- EDR désactivé ou tamper actif confirmé ;
- perte de données ou restauration requise.

---

## 5. Données minimales à collecter

### Côté EDR / SentinelOne

| Donnée | Statut |
|---|---|
| Agent version | [À CONFIRMER] |
| Engine / Static AI / Behavioral AI version | [À CONFIRMER] |
| Dernière mise à jour agent | [À CONFIRMER] |
| Dernière mise à jour engine / security content | [À CONFIRMER] |
| Policy effective | [À CONFIRMER] |
| Groupe / site / scope | [À CONFIRMER] |
| Événements agent avant incident | [À CONFIRMER] |
| Événements agent après reboot | [À CONFIRMER] |
| Remediation / quarantine / rollback | [À CONFIRMER] |
| Tamper / anti-tamper / driver block | [À CONFIRMER] |
| Scan intensif ou scan en cours | [À CONFIRMER] |
| Task agent upgrade / repair | [À CONFIRMER] |

### Côté Windows

| Journal | Événements à vérifier |
|---|---|
| System | Service Control Manager, Kernel-PnP, Filter Manager, driver load/unload |
| Application | MSIInstaller, CAPI2, VSS, Perflib, application crash |
| DFS Replication | DFSR backlog, erreurs réplication, contention |
| VSS / volsnap | Writer timeout, snapshot failure |
| Defender | Mode actif/passif, scan, exclusions, erreurs |
| RDP / TermService | Connexions, erreurs session, services |
| Winlogon / LogonUI | Gel login, erreurs interactives |
| ThreatLocker | Blocages, drivers, policies, health service |
| RMM / ScreenConnect | Agent running, scripts bloqués, logs session |

---

## 6. Fenêtre d’analyse recommandée

Toujours analyser au minimum :

```text
T-2h avant le gel → T+1h après le reboot
```

Exemple :

```text
Incident/reboot : 10:20 locale
Fenêtre locale : 08:20 → 11:20
Fenêtre UTC    : convertir selon fuseau client
```

---

## 7. Construction de la timeline

Utiliser une table unique, triée par heure :

| Heure locale | Heure UTC | Source | Événement | Lecture |
|---|---:|---|---|---|
| [À CONFIRMER] | [À CONFIRMER] | EDR Task | Agent upgrade initiated | Corrélation possible |
| [À CONFIRMER] | [À CONFIRMER] | System / SCM | Driver/service failed to load | Signal kernel/driver |
| [À CONFIRMER] | [À CONFIRMER] | EDR | Agent running | Agent actif |
| [À CONFIRMER] | [À CONFIRMER] | System / SCM | Driver/service installed | À valider vendor |
| [À CONFIRMER] | [À CONFIRMER] | Application / CAPI2 | System Writer access denied | Interaction VSS possible |
| [À CONFIRMER] | [À CONFIRMER] | Application / VSS | Writer timeout freeze/thaw | Signal significatif |
| [À CONFIRMER] | [À CONFIRMER] | EDR | Security content update | Post-reboot ou pré-reboot ? |
| [À CONFIRMER] | [À CONFIRMER] | RMM | Test OK / scripts lourds KO | Couche RMM partielle |

---

## 8. Interprétation — corrélation vs causalité

### Formulation recommandée

```text
La corrélation avec l’EDR est renforcée par la présence d’une mise à jour agent/policy/driver dans la même fenêtre que l’incident.
Toutefois, la causalité directe n’est pas démontrée tant qu’aucun événement pré-incident ne confirme un driver reload, repair, scan intensif, remediation, rollback, tamper ou crash agent avant le gel.
```

### À éviter

```text
SentinelOne a causé le gel.
```

### Préférer

```text
La piste SentinelOne upgrade/interoperability est prioritaire et justifie une revue vendor.
```

---

## 9. Analyse des exclusions

### Contrôles requis

| Zone | Vérification |
|---|---|
| DFSR / dfsrs | Exclusions process/path ciblées présentes ? |
| VSS / System Writer | Interaction backup/EDR observée ? |
| Backup | Outil backup actif pendant l’incident ? |
| Defender | Actif ou passif ? Scans simultanés ? |
| ThreatLocker | Blocage PowerShell/WinRM/RMM ? |
| RMM / ScreenConnect | Exclusion interop présente ? |
| Gros volumes | Éviter exclusion volume complet |
| Policy scope | Exclusions appliquées au bon site/groupe/asset ? |

### Décision par défaut

```text
Aucune exclusion additionnelle immédiate.
Recommander seulement des exclusions ciblées si les logs prouvent une contention ou interaction précise.
```

### Mauvaise pratique

```text
Exclure tout le volume de données.
Désactiver tous les moniteurs EDR sur un dossier large.
Désactiver SentinelOne pour tester.
```

---

## 10. Critères d’escalade vendor EDR

Escalader au vendor si un ou plusieurs éléments sont présents :

- driver/service EDR ne charge pas au boot ;
- installation ou remplacement de driver kernel EDR ;
- composant cleanup/repair/rollback observé ;
- VSS writer timeout dans la même fenêtre ;
- CAPI2 System Writer access denied répété ;
- agent upgrade complété immédiatement après reboot ;
- anti-tamper / driver block / device control impliqué ;
- freeze RMM/RDP/console reproduit sur plusieurs updates ;
- même symptôme sur plusieurs mois.

---

## 11. Questions à poser au vendor

```text
1. Le non-chargement temporaire de [COMPOSANT_EDR] au démarrage est-il attendu pendant l’upgrade vers [VERSION_AGENT] ?
2. Quel est le rôle exact de [DRIVER_OU_COMPOSANT] pendant upgrade/repair/cleanup ?
3. Ce composant indique-t-il repair, rollback, driver replacement, force cleanup ou workflow anti-tamper ?
4. Existe-t-il un known issue avec [VERSION_AGENT] sur [OS/BUILD] impliquant VSS, System Writer, CAPI2, DFSR ou backup ?
5. Pouvez-vous confirmer s’il y a eu driver reload, repair, rollback, policy update, scan, remediation, quarantine ou tamper entre [HEURE_DÉBUT] et [HEURE_FIN] ?
6. Recommandez-vous des exclusions ciblées pour serveur de fichiers avec DFSR/VSS/backup ?
7. Recommandez-vous un ring différé pour cette classe de serveurs critiques ?
```

---

## 12. Stratégie recommandée pour updates EDR

### Ring proposé

| Ring | Cible | Délai |
|---|---|---|
| Ring 0 | Lab / postes internes MSP | Immédiat |
| Ring 1 | Postes clients non critiques | +24h |
| Ring 2 | Serveurs non critiques | +3 à 7 jours |
| Ring 3 | Serveurs critiques | +7 à 14 jours |
| Ring 4 | DC / fichiers / DFSR / SQL / RDS / backup | Fenêtre approuvée seulement |

### Post-check obligatoire sur serveurs critiques

- Agent EDR running.
- Management connectivity OK.
- Drivers EDR chargés sans erreur.
- RMM script simple OK.
- RDP ou accès admin OK.
- VSS writers stable.
- DFSR stable.
- Aucune erreur CAPI2/VSS critique nouvelle.
- Aucune action requise côté EDR.
- Aucun reboot pending non planifié.

---

## 13. Modèle de note CW interne

```text
Analyse IT-SecurityMaster effectuée sur cas stabilité EDR / serveur critique.

Classification :
P2 — stabilité EDR sur serveur critique.
Compromission non confirmée.

Constats :
- Symptôme principal : [RMM/RDP/console gelés / autre].
- Le serveur est revenu en ligne après [hard reboot / reboot planifié / sans reboot].
- L’EDR est [online/offline] et [enabled/disabled].
- Version agent observée : [VERSION].
- Une tâche de mise à jour agent [est confirmée / n’est pas confirmée].
- La tâche d’upgrade a été [initiée/completée] à [HEURE].
- Événements post-reboot observés : [liste courte].
- Événements Windows pertinents : [SCM/CAPI2/VSS/DFSR/etc.].
- Aucune compromission confirmée dans les éléments fournis.

Analyse :
La piste EDR upgrade/interoperability est [faible/modérée/forte], mais la causalité directe du gel initial est [non prouvée / confirmée si preuve].
Les facteurs aggravants possibles sont : DFSR, VSS/System Writer, backup, Defender, ThreatLocker, RMM, PendingFileRename, espace disque ou OS legacy.

Exclusions :
Les exclusions existantes couvrent [RMM/backup/ThreatLocker/etc.].
Aucune exclusion explicite [DFSR/VSS/Defender] observée.
Aucune exclusion large recommandée.

Recommandations :
- Ne pas désactiver l’EDR.
- Ne pas ajouter d’exclusion large.
- Collecter les logs locaux sur la fenêtre [HEURE_DÉBUT] à [HEURE_FIN].
- Escalader vendor si composant driver/kernel, VSS timeout ou repair/rollback EDR confirmé.
- Évaluer ring pilote/différé pour updates EDR sur serveurs critiques.
```

---

## 14. Modèle de message client-safe

```text
Bonjour,

Nous avons poursuivi l’analyse de stabilité de la protection endpoint sur le serveur concerné. L’agent de sécurité est présentement [en ligne / à confirmer] et aucune compromission n’est confirmée à ce stade.

Une corrélation avec une mise à jour ou un composant de protection endpoint est en cours de validation. Les journaux montrent certains événements techniques qui justifient une revue approfondie, notamment autour des composants système et de la stabilité post-redémarrage.

Nous ne recommandons pas de désactivation permanente de la protection. Toute modification éventuelle serait ciblée, documentée et approuvée.

La prochaine étape consiste à compléter la corrélation des journaux système et sécurité, puis à valider avec le fournisseur si le comportement observé est attendu ou s’il nécessite un ajustement de configuration.
```

---

## 15. Modèle d’escalade vendor

```text
Subject: P2 - Critical server stability issue during EDR agent upgrade / VSS-System Writer correlation

Asset type: [Server role]
OS: [OS version/build]
EDR agent version: [VERSION]
Incident date: [DATE]
Severity: P2 - critical server stability

Summary:
The server experienced [freeze / RMM-RDP-console loss / other]. Network file shares were [accessible / not accessible / unknown] before reboot. No compromise indicators are confirmed at this time.

EDR timeline:
- Agent version change task: [INITIATED/COMPLETED/TIME]
- Reboot: [TIME]
- Agent/service status: [TIME/STATUS]
- Security content updates: [TIME/LIST]
- Driver/service events: [TIME/LIST]

Windows observations:
- [SCM event]
- [CAPI2 event]
- [VSS event]
- [DFSR event]
- [Defender/ThreatLocker/RMM event]

Questions:
1. Is the observed driver/service behavior expected during upgrade to [VERSION]?
2. What is the role of [COMPONENT] during upgrade/repair/cleanup?
3. Does this indicate repair, rollback, driver replacement or anti-tamper workflow?
4. Are there known issues on [OS/BUILD] involving VSS, System Writer, CAPI2, DFSR or backup?
5. Can you confirm whether driver reload, repair, rollback, policy update, scan, remediation, quarantine or tamper occurred between [START] and [END]?
6. Are specific exclusions or policy adjustments recommended while avoiding broad volume exclusions?
7. Should this server class be placed in a delayed/pilot update ring?

No compromise indicators are confirmed. Requesting validation of agent/driver behavior and safe configuration recommendations.
```

---

## 16. Grille de décision finale

| Résultat d’analyse | Décision |
|---|---|
| Aucun événement EDR avant gel, seulement post-reboot | Corrélation faible à modérée |
| Upgrade task active avant incident et complétée après reboot | Corrélation modérée à forte |
| Driver/service EDR installé ou remplacé avant erreurs VSS/CAPI2 | Corrélation forte |
| VSS timeout + CAPI2 répété + composant driver EDR | Escalade vendor recommandée |
| Remediation/quarantine/tamper confirmé | Investigation sécurité approfondie |
| IOC/malware/mouvement latéral confirmé | Reclasser incident sécurité |
| Symptôme reproduit sur même version agent | Ring différé + vendor obligatoire |
| Logs insuffisants | Maintenir P2, poursuivre collecte |

---

## 17. Résumé standard à retenir

```text
Ce type de cas doit être traité comme un incident de stabilité EDR sur serveur critique, non comme une infection par défaut.
La priorité est de préserver les faits, établir la timeline, distinguer corrélation et causalité, éviter les exclusions larges et escalader vendor lorsque des composants driver/kernel ou VSS/System Writer sont impliqués.
```
