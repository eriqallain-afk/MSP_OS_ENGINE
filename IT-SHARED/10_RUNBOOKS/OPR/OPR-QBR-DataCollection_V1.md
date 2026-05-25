# OPR-QBR-DataCollection_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-ReportMaster | @IT-AssetMaster | @IT-Commandare-OPR | @IT-OPS-DossierIA
**Scope :** Collecte de données pour QBR (Quarterly Business Review) — métriques tickets, SLA, uptime, incidents, recommandations

---

## Objectif

Rassembler et structurer toutes les données opérationnelles du trimestre pour préparer la présentation QBR client. Produire un dossier complet, factuel et client-safe couvrant la performance du MSP, l'état de santé de l'infrastructure, les incidents majeurs, les accomplissements et les recommandations pour le trimestre suivant.

---

## Déclencheurs

- Préparation trimestrielle planifiée : J-10 avant le QBR (Q1=mars, Q2=juin, Q3=septembre, Q4=décembre)
- Demande client de présentation de bilan trimestriel
- Renouvellement de contrat MSP — QBR de fin d'année fiscal
- Demande de rapport complet suite à un incident majeur

---

## Prérequis

- Les 3 packs mensuels du trimestre complétés (OPR-Monthly-Client-OpsPack)
- Accès à CW Manage pour extraction des données trimestrielles
- Accès à Hudu pour l'état des actifs et les KB créées
- Accès console RMM pour les métriques uptime trimestrielles
- Accès console Backup pour les statistiques de sauvegarde
- Registre EOL à jour (OPR-EOL-EOS-RiskRegister)
- Liste des CAPA ouverts et fermés (OPR-ProblemManagement-CAPA)
- Période de référence clairement définie : [YYYY-MM-DD au YYYY-MM-DD]

---

## Procédure

### Étape 1 — Définir la période et le périmètre

```
Période QBR : [Q1/Q2/Q3/Q4] — [AAAA]
Du [YYYY-MM-DD] au [YYYY-MM-DD]
Client : [NOM]
Gestionnaire de compte : [NOM]
Date du QBR : [YYYY-MM-DD]
Participants client : [Noms + rôles]
Participants MSP : [Noms + rôles]
```

---

### Étape 2 — Collecte des métriques tickets (CW Manage)

```
CW → Reports → Service Tickets → Période = trimestre complet

MÉTRIQUES À EXTRAIRE :
□ Volume total de tickets ouverts
□ Volume total de tickets fermés
□ Tickets encore ouverts en fin de trimestre
□ Répartition par mois (évolution du volume)
□ Répartition par priorité : P1 / P2 / P3 / P4
□ Répartition par type : Incident / Demande de service / Maintenance / Projet
□ Top 5 des catégories par volume (réseau, sécurité, utilisateurs, serveurs, etc.)
□ Temps moyen de résolution par priorité (MTTR)
□ Taux de résolution dans les délais SLA (%)
□ Taux de premier appel résolu (FCR — First Call Resolution) si disponible
□ Heures totales imputées — répartition forfait vs. hors forfait
□ Top 3 des activités par volume d'heures
```

---

### Étape 3 — Collecte des métriques SLA

```
CW → Reports → SLA → Période = trimestre

□ SLA P1 — Temps de réponse moyen vs. contractuel
□ SLA P1 — Taux de conformité (% dans les temps)
□ SLA P2 — Temps de réponse moyen vs. contractuel
□ SLA P2 — Taux de conformité
□ Nombre de breaches SLA et raisons documentées
□ Trend mensuel : le SLA s'améliore-t-il, se dégrade-t-il ou est-il stable ?
```

---

### Étape 4 — Collecte des métriques infrastructure

**4.1 — Disponibilité / Uptime (RMM)**

```
N-able → Reports → Availability → Période = trimestre

Pour chaque serveur critique :
□ Uptime % trimestriel
□ Nombre d'indisponibilités non planifiées
□ Durée totale des interruptions non planifiées
□ Nombre d'alertes déclenchées vs. résolues automatiquement
□ Availability SLA vs. contractuel (si défini)
```

**4.2 — Sauvegardes**

```
Console Backup → Rapport trimestriel

□ Taux de succès global des sauvegardes (%)
□ Nombre d'échecs et resolution time moyen
□ Tests de restauration effectués (date, actif, résultat)
□ Capacité utilisée et évolution (courbe de croissance)
□ Alertes non résolues ou exceptions documentées
```

**4.3 — Sécurité**

```
Console EDR/Antivirus + Console Email Security

□ Menaces détectées et bloquées (total + ventilation par type)
□ Machines avec protection désactivée ou non à jour
□ Alertes de sécurité traitées
□ Campagnes de phishing bloquées (si solution email security active)
□ Vulnérabilités détectées et corrigées (si scanner de vulnérabilités)
□ Incidents de sécurité P1/P2 (lier aux PIR correspondants)
```

**4.4 — Patching**

```
□ Taux de conformité patching en fin de trimestre (% systèmes à jour)
□ Nombre de patchs critiques déployés
□ Systèmes non patchés et raisons (exception / planifié / bloqué)
```

---

### Étape 5 — Récapitulatif des incidents majeurs du trimestre

```
Pour chaque P1 et P2 du trimestre :

INCIDENT [#] — [DATE]
  Sujet : [Description courte — client-safe]
  Durée : [X heures]
  Cause : [En langage client]
  Résolution : [En langage client]
  Action préventive mise en place : [Oui / Non — description]
  PIR transmis : [Oui / Non]

TENDANCE : [Ex. : 2 incidents réseau vs. 0 au trimestre précédent — corrélé à la saturation du firewall identifiée en mars]
```

---

### Étape 6 — Accomplissements du trimestre

```
Liste des travaux proactifs et améliorations réalisés ce trimestre :

□ [Ex. : Migration de 12 postes vers Windows 11 — terminée le YYYY-MM-DD]
□ [Ex. : Déploiement de l'authentification MFA sur toutes les applications cloud]
□ [Ex. : Réduction du taux d'échec des sauvegardes de 8% à 0.5%]
□ [Ex. : Mise à jour du firewall — firmware passé de v7.2 à v7.4]
□ [Ex. : Documentation Hudu complétée à 100% pour ce client]
□ [Ex. : Zéro incident P1 ce trimestre — performance record]
```

---

### Étape 7 — État du registre EOL et recommandations

```
Depuis OPR-EOL-EOS-RiskRegister :

ÉTAT EOL/EOS DU PARC :
  Actifs critiques EOL : [X] — statut de chaque (en cours de remplacement / planifié / exception)
  Actifs en approche EOL (< 6 mois) : [X]

RECOMMANDATIONS POUR LE TRIMESTRE SUIVANT :
+---+------------------------------------------+----------+----------------------------------+
| # | Recommandation                           | Priorité | Estimation                       |
+---+------------------------------------------+----------+----------------------------------+
| 1 | [Ex. : Remplacement Switch Core — EOL]   | Haute    | [~XXXX$ + X jours de déploiement]|
| 2 | [Ex. : Migration SQL 2016 → 2022]        | Haute    | [~XXXX$ + X heures de service]   |
| 3 | [Ex. : Extension stockage NAS +4TB]      | Moyenne  | [~XXXX$]                         |
| 4 | [Ex. : Déploiement solution MFA avancée] | Moyenne  | [~XXXX$ / mois]                  |
+---+------------------------------------------+----------+----------------------------------+
```

---

### Étape 8 — Assembler le dossier QBR

**Structure complète du dossier QBR :**

```
1. Page de couverture (client, période, date du QBR, participants)
2. Résumé exécutif (1 page — 5 métriques clés + point fort + point d'attention + recommandation #1)
3. Performance tickets et SLA (graphiques si possible — volume mensuel, taux conformité)
4. Disponibilité infrastructure (uptime, backup, sécurité — scorecard)
5. Incidents majeurs du trimestre (P1/P2)
6. Accomplissements MSP (travaux proactifs réalisés)
7. État EOL/EOS du parc
8. Recommandations pour le prochain trimestre (priorisées)
9. Objectifs et engagements Q+1

Déposer dans :
  □ CW Manage → [Client] → Attachments → "QBR_[Client]_[AAAA-QX].pdf"
  □ Hudu → [Client] → Documents → "QBR"
  □ Envoyer au gestionnaire de compte pour validation avant le QBR
```

---

### Étape 9 — Préparer les points de discussion

```
Pour le gestionnaire de compte — points à préparer pour la réunion QBR :

□ Ouvrir sur les accomplissements — commencer positif
□ Présenter les métriques SLA avec contexte (tendance, comparaison Q précédent)
□ Incidents majeurs — bref, factuel, orienté solution (pas d'autoflagellation)
□ Recommandations — prioriser les 2 ou 3 priorités hautes, ne pas surcharger
□ Demander les priorités business du client pour le trimestre suivant
□ Confirmer les dates de maintenance planifiée et les projets en cours
□ Clôturer sur les prochaines étapes avec des dates concrètes
```

---

## Template — Résumé exécutif QBR (version client)

```
REVUE TRIMESTRIELLE — [CLIENT] — [Q] [AAAA]
=============================================

EN CHIFFRES CE TRIMESTRE :
  [X] tickets traités          [X%] résolus dans les délais SLA
  [X%] uptime moyen serveurs   [X%] succès des sauvegardes
  [X] incidents P1/P2          [X] améliorations déployées proactivement

POINT FORT :
  [Ex. : Ce trimestre, aucun incident P1 n'a été enregistré — votre infrastructure est stable et sécurisée.]

POINT D'ATTENTION :
  [Ex. : Deux serveurs approchent de leur fin de support en septembre — nous vous présentons notre recommandation ci-après.]

RECOMMANDATION PRIORITAIRE :
  [Ex. : Planifier le renouvellement des serveurs SRV-FILE01 et SRV-APP02 avant [date] pour maintenir la conformité et le niveau de support.]

PROCHAINES ÉTAPES CONVENUES :
  [Ex. : Soumission de la proposition de renouvellement d'ici le [date]]
```

---

## Livrables attendus

| Livrable | Format | Destination | Délai |
|---|---|---|---|
| Dossier QBR complet | PDF | CW + Hudu + Gestionnaire de compte | J-5 avant QBR |
| Résumé exécutif client-safe | PDF (1 page) | Transmis au client lors du QBR | J du QBR |
| Recommandations formelles | Inclus dans le dossier | Client + CW Opportunities | J-5 avant QBR |
| Propositions de renouvellement | CW Opportunities | Gestionnaire de compte | J du QBR ou J+3 |

---

## Critères de clôture (DoD)

- [ ] Données trimestrielles extraites pour tous les systèmes (tickets, SLA, uptime, backup, sécurité, patching)
- [ ] Incidents P1/P2 du trimestre résumés en version client-safe
- [ ] Accomplissements documentés
- [ ] Recommandations rédigées et priorisées
- [ ] Registre EOL intégré dans les recommandations
- [ ] Dossier QBR assemblé et déposé dans CW et Hudu
- [ ] Validé par le gestionnaire de compte avant transmission
- [ ] Aucun IP, credential, nom de serveur interne dans le document client

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| Données CW incomplètes ou incohérentes | @IT-OPS-DossierIA | J-10 avant QBR |
| SLA contractuel non atteint sur le trimestre | @IT-Commandare-OPR — plan de remédiation requis | J-10 avant QBR |
| Client insatisfait lors du QBR | Gestionnaire de compte + @IT-Commandare-OPR | Immédiat |
| QBR non tenu depuis > 6 mois | @IT-Commandare-OPR + gestionnaire de compte | Planifier dans les 2 semaines |

---

## Notes MSP

- **Rythme QBR :** trimestriel pour tous les clients sous contrat complet — semestriel minimum pour les clients light
- **Base de données :** utiliser les 3 OPR-Monthly-Client-OpsPack du trimestre comme source principale — ne pas recollectar ce qui est déjà documenté
- **Tone du QBR :** partenaire stratégique, pas rapport de justification — le QBR renforce la relation et ouvre des opportunités de upsell
- **Metrics visuelles :** les tableaux de bord avec graphiques ont plus d'impact qu'une liste de chiffres — adapter au niveau de maturité IT du client
- Ce runbook est complémentaire à **OPR-Monthly-Client-OpsPack** — le pack mensuel alimente le QBR

---

*OPR-QBR-DataCollection_V1 — IT MSP Intelligence Platform — 2026-05-23*
