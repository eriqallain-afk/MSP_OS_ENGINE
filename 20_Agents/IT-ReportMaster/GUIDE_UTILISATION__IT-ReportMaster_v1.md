# Guide d'utilisation — @IT-ReportMaster (v1.0)
> **Pour :** Techniciens N2/N3, coordonnateurs, responsables MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-ReportMaster ?

**IT-ReportMaster est le moteur de production de rapports IT pour le MSP.**

Il transforme des données brutes (exports CW, alertes RMM, listes de tickets) en rapports structurés, professionnels et prêts à livrer — au client, à la direction ou à l'équipe interne.

| Audience | Type de rapport | Exemple |
|---|---|---|
| Équipe interne | Technique, détaillé, métriques | Weekly NOC, rapport patching interne |
| Client | Non-technique, orienté impact | Rapport mensuel, incident-summary |
| Direction / QBR | Stratégique, tendances, ROI | QBR trimestriel, rapport EOL |

> **Règle fondamentale :** Zéro chiffre inventé — toute donnée manquante est marquée `[DONNÉES REQUISES : ...]` avec une source attendue (CW / RMM / Veeam).

---

## Quand l'utiliser ?

- Tu dois produire le rapport mensuel client (fin de mois)
- Un incident P1/P2 est résolu et un postmortem est requis
- Le QBR trimestriel approche et tu dois préparer les données
- Tu dois livrer un rapport de posture sécurité ou de compliance patching
- Tu veux produire un résumé d'incident lisible par un client non-technique

---

## Les commandes principales

### `/postmortem` — Rapport Postmortem P1/P2

La commande la plus utilisée après un incident majeur.

**Usage :**
```
/postmortem #77055
Client : Otto Group
Type incident : Panne service Exchange Online
Durée interruption : 1h45
MTTD : 8 min (alerte RMM) | MTTA : 12 min | MTTR : 1h45
Utilisateurs impactés : 47
Cause : Certificat MX expiré — non renouvelé automatiquement
Actions correctives : Renouvellement certificat, configuration alerte expiration 30j
```

**Ce que tu obtiens :**
- Résumé exécutif (2-3 phrases, lisible par un directeur)
- Métriques MTTD / MTTA / MTTR vs SLA
- Timeline complète avec horodatage
- Analyse cause racine (méthode 5 Whys)
- Actions correctives et préventives avec owner et échéance
- Leçons apprises

---

### `/mensuel` — Rapport Mensuel MSP

Rapport mensuel complet pour un client.

**Usage :**
```
/mensuel Mai 2026 — Otto Group
Tickets ouverts : 34 | Tickets fermés : 31 | En attente : 3
Temps moyen résolution : 2h15
SLA P1 : 100% | SLA P2 : 94% | SLA P3 : 91%
Incidents P1 : 1 (billet #77055 — résolu) | Incidents P2 : 3
Maintenances : Patching mensuel 2026-05-14 — 8 serveurs — succès
CSAT : 4,6/5
```

**Ce que tu obtiens :**
- Résumé exécutif avec indice de santé global
- Tableau performance opérationnelle avec tendances vs mois précédent
- Tableau conformité SLA par niveau
- Disponibilité infrastructure par composant
- Incidents notables du mois
- Maintenances réalisées
- Recommandations actionnables (max 3)
- Prochaines actions planifiées

---

### `/qbr` — Quarterly Business Review

Rapport trimestriel stratégique pour la direction client.

**Usage :**
```
/qbr Q2 2026 — Otto Group
[Coller les données agrégées des 3 mois : tickets, SLA, incidents, uptime,
maintenances, projets en cours, risques identifiés]
```

**Ce que tu obtiens :**
- Score de santé IT trimestriel avec tendance vs Q-1
- Performance vs objectifs du trimestre
- Évolution comparative Q-1 vs Q
- Roadmap infrastructure (projets complétés / en cours / planifiés)
- Risques identifiés avec plan de mitigation
- Recommandations stratégiques Q+1 avec investissement estimé et ROI attendu
- Plan d'action Q+1 mois par mois

---

### `/securite` — Rapport de Posture Sécurité

**Usage :**
```
/securite Mai 2026 — Otto Mfg
Incidents sécurité : 1 phishing intercepté (2026-05-07) — aucune compromission
Couverture EDR : 98% des endpoints
MFA activé : 87% des comptes
Patches critiques appliqués : 96%
Vulnérabilités actives : 2 moyennes (à patcher avant 2026-06-15)
Backup testé : Oui (2026-05-10)
Formation sécurité : 78% des utilisateurs
```

---

### `/patching` — Rapport Compliance Patching

**Usage :**
```
/patching Mai 2026 — Otto Inc
Source : RMM NinjaRMM
8 serveurs dans le scope — 7 patchés avec succès — 1 exclu (SRV-SQL02 : maintenance planifiée juin)
Échec : 0 | Redémarrages en attente : 0 | Compliance : 87,5%
```

---

### `/backup` — Rapport Santé Backup

**Usage :**
```
/backup Mai 2026 — Otto Mfg
Source : Veeam Backup & Replication 12.1
Jobs exécutés : 62 | Succès : 59 | Avertissements : 2 | Échecs : 1
Taux de succès : 95,2%
Dernier test restauration : 2026-05-15 — OK
Espace repository : 4,2 To utilisés / 8 To — 3,8 To libres
```

---

### `/health` — Rapport Santé Infrastructure

**Usage :**
```
/health — Entreprise ABC
Source : RMM 2026-05-18
[Coller export RMM : serveurs, CPU, RAM, disques, uptime, services critiques]
```

---

### `/incident-summary` — Résumé Incident (Version Client)

Pour communiquer un incident à un client en langage non-technique.

**Usage :**
```
/incident-summary #77055
Client : Otto Group
Incident : Service courriel inaccessible 1h45 ce matin
Cause : Problème de configuration résolu par notre équipe
Impact : 47 utilisateurs — aucune donnée perdue
```

---

### `/eol` — Rapport Équipements Fin de Vie/Support

**Usage :**
```
/eol — Entreprise ABC
Source : CMDB / RMM 2026-05-18
Windows Server 2012 R2 : 2 serveurs (EOL dépassé — Oct 2023)
Windows 10 : 6 postes (EOL Jan 2025 — dépassé)
Switch Cisco SG300 : 1 (EOS 2024)
```

---

### `/close` — Clôture multi-sorties CW

Après avoir produit un rapport, génère les livrables CW correspondants.

**Usage :**
```
/close
```

**Menu affiché (puis STOP — attendre ton choix) :**
```
[1] CW Note Interne (technique)
[2] CW Discussion (facturable client)
[3] Email client (non-technique)
[4] Notice Teams
[A] Tout générer (1+2+3+4)
```

---

## Flux de travail recommandé

### Cycle mensuel (fin de mois)

```
1. Exporter les données depuis CW (tickets, SLA) et RMM (uptime, alertes)
        ↓
2. /mensuel [mois] [client] [données exportées]
        ↓
3. Vérifier les données — compléter les [DONNÉES REQUISES]
        ↓
4. /close → [3] Email client pour livraison
        ↓
5. Archiver dans SharePoint / Hudu
```

### Après un incident P1/P2

```
1. Incident résolu — billet CW fermé
        ↓
2. /postmortem #[XXXXX] [données de l'incident]
        ↓
3. Réviser avec l'équipe (valider les actions préventives)
        ↓
4. /close → [1] Note Interne + [3] Email client
        ↓
5. Planifier les actions préventives dans CW
```

### QBR trimestriel

```
1. Agréger 3 rapports mensuels + données infrastructure
        ↓
2. /qbr [trimestre] [client] [données]
        ↓
3. Préparer la présentation (slide deck ou document Word)
        ↓
4. Planifier la réunion client
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO IP / hostname interne dans les rapports clients | Client-safe obligatoire |
| ZÉRO credentials / chemins internes | Sécurité des données |
| Chiffres = source citée (CW / RMM / Veeam) | Crédibilité du rapport |
| `[DONNÉES REQUISES : ...]` si données manquantes | Jamais de valeurs fictives |
| Résumé exécutif toujours en premier | Lisible par un directeur non-technique |
| Recommandations : max 3, actionnables, avec owner et délai | Rapport actionnable, pas décoratif |

---

## Questions fréquentes

**Q : Que faire si je n'ai pas toutes les données avant de lancer la commande ?**
Lance la commande avec les données disponibles. L'agent indique exactement `[DONNÉES REQUISES : source CW / RMM]` pour chaque champ manquant — tu complètes avant la livraison.

**Q : Peut-on générer plusieurs sorties depuis un même rapport ?**
Oui. Après avoir généré le rapport avec `/postmortem` par exemple, tape `/close [A]` pour obtenir la Note Interne technique, la Discussion facturable, l'email client et la notice Teams — tous cohérents et calibrés pour leur audience.

**Q : Qui valide le postmortem avant de le livrer au client ?**
IT-Commandare-TECH valide les postmortem P1 dans les 48h suivant l'incident. Le rapport est livré au client après validation interne.

**Q : Quelle différence entre `/incident-summary` et `/postmortem` ?**
`/postmortem` est un document interne détaillé avec cause racine, métriques et actions préventives.
`/incident-summary` est une version client non-technique — 1 page, pas de jargon, orientée impact et résolution.

**Q : Comment inclure des données de plusieurs mois pour le QBR ?**
Génère d'abord les 3 rapports `/mensuel`, puis colle les données agrégées dans `/qbr`. L'agent calcule les tendances trimestrielles automatiquement.

---

*GUIDE_UTILISATION — IT-ReportMaster v1.0 — MSP Intelligence AI — 2026-05-18*
