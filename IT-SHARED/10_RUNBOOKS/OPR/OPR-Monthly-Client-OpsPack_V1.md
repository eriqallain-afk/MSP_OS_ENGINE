# OPR-Monthly-Client-OpsPack_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-ReportMaster | @IT-AssetMaster | @IT-Commandare-OPR | @IT-OPS-DossierIA
**Scope :** Préparation du pack mensuel client — métriques SLA, incidents, actions préventives, recommandations, travaux planifiés

---

## Objectif

Produire chaque mois, pour chaque client MSP actif, un pack opérationnel complet comprenant : les métriques de performance du mois, un résumé des incidents résolus, l'état des actions préventives, les recommandations techniques prioritaires et les travaux planifiés pour le mois suivant. Ce pack est la base du suivi client régulier et de la préparation des QBR.

---

## Déclencheurs

- Déclenchement mensuel automatique : dernier jour ouvrable du mois (ou J+2 du mois suivant)
- Demande client avant une réunion de suivi
- Préparation d'une QBR — utiliser comme base de données
- Onboarding client (premier pack après 30 jours)
- Demande de rapport par le gestionnaire de compte

---

## Prérequis

- Accès à ConnectWise Manage (rapports, tickets, time entries)
- Accès à Hudu (actifs, KB, documentation client)
- Accès à la console RMM (N-able) pour métriques uptime et alertes
- Accès à la console Backup pour statistiques de sauvegarde
- Registre EOL à jour (voir OPR-EOL-EOS-RiskRegister)
- Période de référence : du 1er au dernier jour du mois précédent

---

## Procédure

### Étape 1 — Collecte des métriques CW

**1.1 — Métriques tickets**

```
CW → Reports → Service Tickets → Filtrer :
  - Client : [NOM]
  - Période : [01/MM/AAAA – 31/MM/AAAA]
  - Status : Closed

Extraire :
  □ Nombre total de tickets ouverts dans la période
  □ Nombre de tickets fermés dans la période
  □ Nombre de tickets encore ouverts en fin de mois
  □ Répartition par priorité : P1 / P2 / P3 / P4
  □ Répartition par type : Incident / Demande / Maintenance / Projet
  □ Répartition par catégorie : Réseau / Sécurité / Utilisateurs / Serveurs / etc.
  □ Temps moyen de résolution par priorité
  □ Taux de résolution dans les délais SLA (% de tickets dans les temps)
```

**1.2 — Métriques SLA**

```
CW → Reports → SLA → Filtrer par client et période

Extraire :
  □ SLA P1 : temps de réponse moyen vs. SLA contractuel
  □ SLA P2 : temps de réponse moyen vs. SLA contractuel
  □ Tickets en breach SLA (si applicable)
  □ Raisons des breaches (si applicable)
```

**1.3 — Heures imputées**

```
CW → Reports → Time Entries → Filtrer par client et période

Extraire :
  □ Total heures imputées dans la période
  □ Répartition : heures incluses au forfait vs. heures hors forfait
  □ Top 3 des activités par volume d'heures
```

---

### Étape 2 — Collecte des métriques infrastructure

**2.1 — Uptime serveurs (via RMM)**

```
N-able → Reports → Availability → [Client] → [Période]

Pour chaque serveur critique :
  □ Uptime % du mois
  □ Nombre et durée des indisponibilités (planifiées vs. non planifiées)
  □ Alertes déclenchées et nombre d'alertes résolues automatiquement
```

**2.2 — Sauvegardes**

```
Console Backup (Veeam / Datto / autre) → [Client] → Rapport mensuel

Extraire :
  □ Taux de succès des sauvegardes (% jobs OK)
  □ Nombre d'échecs de sauvegarde et résolution
  □ Dernière sauvegarde testée / restauration validée
  □ Capacité utilisée vs. capacité totale
```

**2.3 — Sécurité**

```
Console EDR / Antivirus → [Client] → Rapport mensuel

Extraire :
  □ Nombre de menaces détectées et bloquées
  □ Machines avec protection désactivée ou en retard de mise à jour
  □ Alertes de sécurité traitées
```

---

### Étape 3 — Résumé des incidents du mois

**Pour chaque incident P1/P2 du mois :**

```
INCIDENT : [Titre court]
Date : [YYYY-MM-DD] | Durée : [X heures] | Résolu : [Oui/Non]
Impact : [Description fonctionnelle — ex. : messagerie indisponible pour 15 utilisateurs]
Cause : [En langage client — ex. : panne matérielle sur le serveur de messagerie]
Résolution : [En langage client — ex. : remplacement du composant défaillant]
Action préventive : [Si applicable]
```

---

### Étape 4 — État des actions préventives et maintenance

```
Actions préventives effectuées ce mois :
  □ Patching Windows — [X] serveurs patchés — statut : Conforme
  □ Nettoyage espace disque — [X] serveurs — GB libérés
  □ Revue des comptes inactifs — [X] comptes désactivés
  □ Test de restauration backup — [Actif] — Résultat : [OK/KO]
  □ [Autre action de maintenance]

Actions préventives en cours ou retardées :
  □ [Action] — Raison du retard — Nouvelle ETA
```

---

### Étape 5 — Recommandations techniques

**Classer par priorité (reprendre du registre EOL et des incidents du mois) :**

```
RECOMMANDATIONS — [CLIENT] — [MOIS AAAA]
==========================================

PRIORITÉ HAUTE (action dans les 30 jours) :
• [Recommandation] — Raison : [risque] — Estimation : [coût/effort]

PRIORITÉ MOYENNE (action dans les 90 jours) :
• [Recommandation] — Raison : [bénéfice] — Estimation : [coût/effort]

PLANIFICATION (budget suivant) :
• [Recommandation] — Raison : [évolution] — Estimation : [coût/effort]
```

---

### Étape 6 — Travaux planifiés pour le mois suivant

```
TRAVAUX PLANIFIÉS — [MOIS SUIVANT AAAA]
=========================================
  □ Patching mensuel — [date planifiée] — Fenêtre : [HH:MM–HH:MM]
  □ [Maintenance spécifique] — [date] — Impact attendu : [description]
  □ [Projet en cours] — Étape : [X] — ETA : [date]
  □ [Renouvellement] — [actif] — ETA : [date]
```

---

### Étape 7 — Assembler le pack et le déposer

```
Structure du pack mensuel :
1. Résumé exécutif (1 page — chiffres clés + incident majeur + recommandation top)
2. Métriques tickets et SLA
3. Métriques infrastructure (uptime, backup, sécurité)
4. Résumé des incidents P1/P2
5. Actions préventives effectuées
6. Recommandations prioritaires
7. Travaux planifiés mois suivant

Déposer dans :
  □ CW Manage → [Client] → Attachments → "OpsPack_[Client]_[AAAA-MM].pdf"
  □ Hudu → [Client] → Documents → "Rapports mensuels"
  □ Envoyer au gestionnaire de compte pour révision avant transmission client
```

---

## Template — Résumé exécutif (version client)

```
RAPPORT MENSUEL — [CLIENT] — [MOIS AAAA]
==========================================

EN BREF :
  Tickets traités : [X] | Résolus dans les délais : [X%]
  Uptime serveurs : [X%] | Sauvegardes : [X%] de succès
  Incidents majeurs : [X P1/P2]

POINT POSITIF :
  [Ex. : Aucun incident majeur ce mois — votre infrastructure est stable]

POINT D'ATTENTION :
  [Ex. : 2 serveurs approchent de leur fin de support — recommandation incluse]

PROCHAINE ÉTAPE :
  [Ex. : Maintenance mensuelle planifiée le [date]]

Pour toute question : [Email / téléphone MSP]
```

---

## Livrables attendus

| Livrable | Format | Destination |
|---|---|---|
| Pack mensuel complet | PDF ou document structuré | CW Manage + Hudu |
| Résumé exécutif client-safe | PDF | Transmis au client via gestionnaire de compte |
| Mise à jour registre EOL | Hudu | Hudu → [Client] |
| Actions préventives documentées | CW Note Interne | CW Manage |
| Travaux planifiés confirmés | CW → Tickets / Schedule | CW Manage |

---

## Critères de clôture (DoD)

- [ ] Métriques tickets et SLA extraites et validées
- [ ] Métriques uptime, backup et sécurité collectées
- [ ] Tous les P1/P2 du mois résumés en langage client-safe
- [ ] Actions préventives documentées
- [ ] Recommandations rédigées et priorisées
- [ ] Travaux du mois suivant planifiés dans CW
- [ ] Pack déposé dans CW et Hudu
- [ ] Résumé exécutif validé par le gestionnaire de compte avant transmission
- [ ] Aucun IP, credential, nom de serveur ou détail technique interne dans le document client

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| Données CW incomplètes ou incohérentes | @IT-OPS-DossierIA | Avant fin de préparation du pack |
| SLA breached > 20% ce mois | @IT-Commandare-OPR + gestionnaire de compte | Immédiat — PIR requis |
| Client n'a pas reçu son pack depuis > 2 mois | Gestionnaire de compte | Immédiat |
| Recommandation critique non actée depuis 2 mois | @IT-Commandare-OPR | Escalade formelle par écrit |

---

## Notes MSP

- **Fréquence :** mensuel — tous les clients actifs — délai max : J+5 du mois suivant
- **Ne jamais transmettre le pack directement au client** — passer par le gestionnaire de compte pour valider le ton et les recommandations
- **Base QBR :** ce pack est la source de données des QBR — archiver 12 mois glissants dans Hudu
- **Automatisation possible :** certaines extractions CW peuvent être automatisées via CW Reports Scheduler — contacter @IT-ScriptMaster
- Intégrer les résultats dans **OPR-QBR-DataCollection** lors des trimestres concernés

---

*OPR-Monthly-Client-OpsPack_V1 — IT MSP Intelligence Platform — 2026-05-23*
