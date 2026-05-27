# OPR-PostIncident-Review-P1P2_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-ReportMaster | @IT-Commandare-OPR | @IT-UrgenceMaster | @IT-QAMaster
**Scope :** Revue post-incident P1/P2 — timeline, cause racine, facteurs contributifs, CAPA, rapport client-safe

---

## Objectif

Produire pour chaque incident majeur (P1/P2) résolu ou stabilisé : un rapport post-incident complet avec timeline validée, analyse de cause racine (ou hypothèse documentée), facteurs contributifs identifiés, actions correctives et préventives (CAPA) assignées, et rapport client-safe transmissible. Prévenir la récurrence et démontrer la maturité opérationnelle du MSP.

---

## Déclencheurs

- Tout incident P1 résolu ou stabilisé — délai max : 24h après résolution
- Tout incident P2 avec impact client confirmé — délai max : 48h après résolution
- Incident ayant déclenché une escalade, une war room ou une intervention hors-heures
- Incident de sécurité (ransomware, breach, compromission de compte)
- Incident récurrent (3e occurrence sur le même système dans les 90 jours)
- Demande client de rapport post-incident

---

## Prérequis

| Champ | Valeur |
|---|---|
| Ticket ID | [À CONFIRMER] |
| Client | [À CONFIRMER] |
| Priorité | P1 / P2 |
| Heure de détection | [YYYY-MM-DD HH:MM] |
| Heure de résolution | [YYYY-MM-DD HH:MM] |
| Durée totale d'impact | [X heures X minutes] |
| Impact confirmé | [X utilisateurs / services affectés] |
| Propriétaire technique | [Nom du technicien principal] |

---

## Procédure

### Étape 1 — Rassembler les données brutes

```
1. Lire l'intégralité du ticket CW : description, notes internes, time entries, alertes liées
2. Récupérer les logs de monitoring (N-able, LogicMonitor) pour la fenêtre de l'incident
3. Récupérer les event logs système pertinents (Windows Event Viewer, Syslog)
4. Identifier tous les intervenants : techniciens, agents, fournisseurs tiers impliqués
5. Récupérer les communications client envoyées pendant l'incident
6. Identifier les alertes qui auraient dû se déclencher et ne l'ont pas fait
```

---

### Étape 2 — Construire la timeline

**Format de timeline (à compléter chronologiquement) :**

```
TIMELINE — [CLIENT] — INCIDENT [TICKET #]
==========================================

[YYYY-MM-DD HH:MM] DÉTECTION
  → Source : [Alerte automatique / Appel client / Technicien]
  → Symptôme initial : [Description]

[HH:MM] TRIAGE
  → Priorisé : P1 / P2
  → Assigné à : [Technicien]
  → Client notifié : [Oui/Non — canal utilisé]

[HH:MM] [ACTION TECHNIQUE]
  → [Description de l'action effectuée]
  → [Résultat observé]

[HH:MM] ESCALADE (si applicable)
  → Vers : [Technicien N3 / Fournisseur / Agent spécialisé]
  → Raison : [Blocage / compétence requise]

[HH:MM] [ACTION TECHNIQUE]
  → [Description]
  → [Résultat]

[HH:MM] RÉSOLUTION PARTIELLE (si applicable)
  → [Service partiellement rétabli — description]
  → Client notifié : [Oui — HH:MM]

[HH:MM] RÉSOLUTION COMPLÈTE
  → [Service pleinement opérationnel — confirmation]
  → Client notifié : [Oui — HH:MM]
  → Validation effectuée par : [Nom / méthode]

DURÉE TOTALE D'IMPACT : [X h X min]
DURÉE TTRS (Time to Resolve Service) : [X h X min depuis la détection]
```

---

### Étape 3 — Analyse de cause racine (RCA)

**Méthode des 5 Pourquoi :**

```
Symptôme observé : [Description du problème visible]

Pourquoi 1 : Pourquoi le service [X] était-il indisponible ?
→ Parce que [réponse technique 1]

Pourquoi 2 : Pourquoi [réponse 1] s'est-il produit ?
→ Parce que [réponse technique 2]

Pourquoi 3 : Pourquoi [réponse 2] s'est-il produit ?
→ Parce que [réponse technique 3]

Pourquoi 4 : Pourquoi [réponse 3] n'a-t-il pas été détecté plus tôt ?
→ Parce que [absence de monitoring / alerte mal configurée / procédure manquante]

Pourquoi 5 : Pourquoi [réponse 4] existait-il ?
→ Cause racine : [conclusion — ex. : absence de politique de monitoring sur les volumes de logs SQL]
```

**Niveaux de certitude de la cause :**

| Niveau | Description | Formulation dans le rapport |
|---|---|---|
| Confirmée | Cause prouvée par logs et tests | "Cause confirmée : [description]" |
| Probable | Cause la plus vraisemblable avec justification | "Cause probable : [description] — justification : [X]" |
| Inconnue | Incident disparu sans explication claire | "Cause non déterminée. Hypothèse : [X]. Surveillance renforcée activée." |

---

### Étape 4 — Facteurs contributifs

```
Identifier et documenter les facteurs qui ont aggravé ou permis l'incident :

□ Facteur humain : [Ex. : intervention manuelle sans ticket associé]
□ Facteur technique : [Ex. : espace disque non surveillé au-delà de 85%]
□ Facteur de processus : [Ex. : pas de test de restauration en 6 mois]
□ Facteur fournisseur : [Ex. : délai de réponse fournisseur > 4h]
□ Gap de monitoring : [Ex. : alerte sur service SQL non configurée]
□ Gap de documentation : [Ex. : runbook de reprise inexistant pour ce scénario]
```

---

### Étape 5 — CAPA (Actions Correctives et Préventives)

**Format CAPA — une ligne par action :**

```
CAPA TRACKER — [CLIENT] — INCIDENT [TICKET #]
===============================================

ACTIONS CORRECTIVES (empêcher la récurrence immédiate) :
| # | Action | Responsable | ETA | Vérification | Statut |
|---|---|---|---|---|---|
| 1 | [Ex. : Configurer alerte seuil disque à 80% sur tous les serveurs SQL] | @IT-MonitoringMaster | 2026-05-30 | Alerte test déclenchée avec succès | En cours |
| 2 | [Ex. : Implémenter politique d'archivage des logs SQL automatique] | @IT-SysAdmin | 2026-06-07 | Script planifié actif + log vérifié après 7 jours | À faire |

ACTIONS PRÉVENTIVES (éviter qu'un incident similaire arrive ailleurs) :
| # | Action | Responsable | ETA | Vérification | Statut |
|---|---|---|---|---|---|
| 1 | [Ex. : Auditer l'espace disque sur tous les serveurs SQL de tous les clients] | @IT-MaintenanceMaster | 2026-05-31 | Rapport d'audit transmis | À faire |
| 2 | [Ex. : Créer runbook spécifique saturation logs SQL] | @IT-KnowledgeKeeper | 2026-06-14 | Runbook publié dans Hudu | À faire |
```

---

### Étape 6 — Rédiger le rapport client-safe

```
RAPPORT POST-INCIDENT — [CLIENT]
Date : [YYYY-MM-DD]
Référence : [Ticket #]
==================================

RÉSUMÉ EXÉCUTIF :
Le [date], votre [service — ex. : système de gestion des ressources humaines] a subi une interruption d'une durée de [X heures]. Nos équipes ont été mobilisées immédiatement et le service a été pleinement rétabli à [heure].

IMPACT :
[Nombre] utilisateurs ont été affectés pendant [durée]. [Description fonctionnelle de l'impact — ex. : l'accès aux données de gestion était temporairement indisponible.]

CAUSE :
[Explication en langage non technique — ex. : Un espace de stockage interne est arrivé à saturation, ce qui a entraîné l'arrêt automatique du service de base de données.]

CE QUE NOUS AVONS FAIT :
• [Action 1 en termes simples — ex. : Identification et libération de l'espace de stockage]
• [Action 2 — ex. : Redémarrage contrôlé du service et validation du fonctionnement]
• [Action 3 — ex. : Vérification de l'intégrité des données]

MESURES PRISES POUR ÉVITER LA RÉCURRENCE :
• [Action préventive 1 en termes simples]
• [Action préventive 2]

PROCHAINES ÉTAPES :
• [Si applicable — ex. : Planification d'une extension de capacité de stockage — ETA : [date]]

Nous nous excusons pour la gêne occasionnée. N'hésitez pas à nous contacter pour toute question.
```

---

### Étape 7 — Documenter et archiver

```
□ Rapport PIR final ajouté en pièce jointe dans le ticket CW
□ Note Interne CW mise à jour avec le CAPA tracker complet
□ Hudu → [Client] → Incidents → créer article : "[DATE] - Incident [description courte]"
   Inclure : timeline technique, RCA, CAPA — pour référence future et prévention
□ Vérifier si une mise à jour du runbook ou de la KB est requise
   → Si oui : créer ticket pour @IT-KnowledgeKeeper
□ Vérifier si une alerte de monitoring doit être ajoutée
   → Si oui : créer ticket pour @IT-MonitoringMaster
□ Si incident de sécurité : déclencher OPR-ProblemManagement-CAPA en parallèle
```

---

## Livrables attendus

| Livrable | Audience | Délai |
|---|---|---|
| Timeline technique complète | Interne CW (Note Interne) | 24h (P1) / 48h (P2) |
| Rapport RCA avec facteurs contributifs | Interne CW | 24h (P1) / 48h (P2) |
| CAPA tracker avec owners et ETAs | Interne CW | 24h (P1) / 48h (P2) |
| Rapport client-safe | Client (via gestionnaire de compte) | 48h (P1) / 72h (P2) |
| Article Hudu archivé | Hudu interne | 48h |
| Tickets CAPA créés dans CW | Techniciens/agents assignés | 24h |

---

## Critères de clôture (DoD)

- [ ] Impact et durée documentés avec précision (heure de détection et heure de résolution)
- [ ] Timeline chronologique validée par les techniciens impliqués
- [ ] RCA complété (cause confirmée, probable, ou inconnue avec hypothèse)
- [ ] Facteurs contributifs identifiés (au moins 2)
- [ ] CAPA : chaque action a un propriétaire, une ETA et une méthode de vérification
- [ ] Rapport client-safe rédigé, validé, transmis
- [ ] Article Hudu créé pour archivage et prévention future
- [ ] Aucun IP, credential, nom de serveur interne dans le rapport client
- [ ] Monitoring ou runbook mis à jour si gap identifié

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| CAPA non assigné 24h après clôture de l'incident | @IT-Commandare-OPR | Immédiat |
| CAPA non exécuté > 2 semaines | @IT-QAMaster | Incident QA |
| Incident récurrent malgré CAPA antérieur | @IT-Commandare-OPR + @IT-QAMaster | Revue d'urgence |
| Client insatisfait du rapport ou demande un appel | @IT-Commandare-OPR + gestionnaire de compte | 4h |
| Incident de sécurité confirmé | @IT-SecurityMaster | Immédiat — processus parallèle |

---

## Notes MSP

- **Délai non négociable :** P1 = rapport PIR dans les 24h après résolution, P2 = 48h — aucune exception sans approbation @IT-Commandare-OPR
- **Format court acceptable :** pour les P2 simples avec cause évidente, la timeline peut être raccourcie — l'essentiel est le CAPA
- **Langage client :** tester le rapport avec ce critère — "un gestionnaire non technique peut-il le comprendre en 2 minutes ?"
- **Archive Hudu :** chaque PIR archivé prévient le prochain incident identique — c'est un investissement, pas une formalité
- Le CAPA tracker doit être intégré dans le suivi **OPR-Weekly-OpsReview** jusqu'à clôture de toutes les actions

---

*OPR-PostIncident-Review-P1P2_V1 — IT MSP Intelligence Platform — 2026-05-23*
