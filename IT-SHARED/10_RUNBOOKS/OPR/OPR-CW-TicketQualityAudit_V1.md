# OPR-CW-TicketQualityAudit_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-TicketOpr | @IT-TicketScribe | @IT-QAMaster | @IT-Commandare-OPR
**Scope :** Audit qualité ticket ConnectWise avant fermeture — applicable à tous les agents et techniciens

---

## Objectif

S'assurer qu'aucun ticket ConnectWise n'est fermé sans satisfaire la définition de fini (DoD) opérationnelle MSP : contexte clair, cause documentée, actions traçables, validation effectuée, mise à jour client-safe, et prochaines étapes identifiées. Ce runbook est la porte de qualité finale avant toute fermeture de ticket.

---

## Déclencheurs

- Demande de fermeture de ticket (`/close` ou bouton Close dans CW)
- Note interne ou discussion manquante ou insuffisante
- Temps imputé sans description claire des travaux
- Incident P1/P2 résolu — artefacts post-incident obligatoires
- QAMaster en revue de qualité planifiée
- Technicien qui demande la validation avant de passer à autre chose

---

## Prérequis

| Champ | Valeur |
|---|---|
| Ticket ID | [À CONFIRMER] |
| Client | [À CONFIRMER] |
| Priorité / Sévérité | [À CONFIRMER] |
| Statut actuel | [À CONFIRMER] |
| Impact confirmé | [À CONFIRMER] |
| Technicien / Agent propriétaire | [À CONFIRMER] |

---

## Procédure

### Étape 1 — Lecture complète du ticket

```
1. Lire le titre du ticket — est-il descriptif ? (ex. "Serveur SRV-APP01 inaccessible" > "ticket urgent")
2. Lire la description originale — quel était le problème signalé ?
3. Lire toutes les notes internes — actions prises, commandes, résultats, observations
4. Lire la discussion CW — est-elle présente ? est-elle client-safe ?
5. Lire les entrées de temps — le temps imputé correspond-il aux actions décrites ?
6. Vérifier les pièces jointes — logs, captures d'écran, rapports ?
```

---

### Étape 2 — Vérifier la cause documentée

**Grille d'évaluation :**

| Niveau | Description | Action requise |
|---|---|---|
| Cause connue | Cause technique identifiée et documentée | OK — passer à l'étape 3 |
| Cause probable | Hypothèse documentée avec justification | OK — noter "hypothèse" dans la note |
| Cause inconnue | Problème disparu sans explication | Documenter : "Cause inconnue — hypothèse : [X]. Monitoring augmenté." |
| Cause absente | Aucune mention de la cause | Bloquer la fermeture — compléter obligatoire |

```
Formulation recommandée pour la Note Interne CW :

CAUSE :
- [Connue] : Le service SQL Server (MSSQLSERVER) était arrêté suite à une corruption du fichier de log de transaction. Espace disque D: à 98%.
- [Probable] : Probable saturation du disque D: causée par une croissance excessive des logs SQL non archivés.
- [Inconnue] : Cause non déterminée — le service s'est relancé spontanément. Hypothèse : redémarrage automatique suite à timeout. Monitoring WMI ajouté.
```

---

### Étape 3 — Vérifier les actions et résultats

**La Note Interne DOIT contenir :**

```
ACTIONS EFFECTUÉES :
1. [Action concrète] — [résultat observé]
   Ex. : Redémarrage du service MSSQLSERVER — service opérationnel en 45 sec
2. [Action] — [résultat]
   Ex. : Libération espace disque D: (suppression logs > 90 jours) — D: libéré de 45 GB → 62% utilisé
3. [Validation] — [méthode de test]
   Ex. : Test applicatif avec l'utilisateur [Prénom] — connexion SQL confirmée à 14h32

VALIDATION :
- Test effectué par : [Technicien / Utilisateur]
- Méthode : [connexion applicative / ping / telnet / test fonctionnel / supervision]
- Résultat : [OK / KO / partiel]
- Heure de validation : [HH:MM]
```

---

### Étape 4 — Vérifier la discussion client-safe

**La Discussion CW DOIT contenir :**

```
Phrase d'ouverture OBLIGATOIRE :
"Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise."

Corps — version client-safe :
TRAVAUX EFFECTUÉS :
• [Description fonctionnelle sans détails techniques internes]
  Ex. : Résolution d'un problème d'accès au système de gestion
• [Impact résolu et validation]
  Ex. : Le système est de nouveau accessible — accès confirmé avec l'utilisateur concerné

RÉSULTAT :
• [Situation actuelle en langage client]
  Ex. : Service rétabli et opérationnel depuis [heure]
• [Prochaine étape si applicable]
  Ex. : Surveillance renforcée activée — rapport de suivi d'ici 48h
```

**Liste de contrôle client-safe — AUCUN de ces éléments dans la Discussion :**
```
⛔ Adresses IP internes (192.168.x.x, 10.x.x.x)
⛔ Noms de serveurs internes (SRV-AD01, DC-PROD)
⛔ Credentials, mots de passe, tokens (même masqués partiellement)
⛔ Commandes PowerShell ou CLI
⛔ Logs d'erreur bruts
⛔ Noms de vulnérabilités ou CVE
⛔ Détails d'architecture interne
```

---

### Étape 5 — Vérifier les prochaines actions

```
Si le problème est résolu à 100% → indiquer "Aucune action requise."

Si des actions sont en attente :
PROCHAINES ACTIONS :
- [Action] — Propriétaire : [Nom/Agent] — ETA : [date]
  Ex. : Extension disque D: — @IT-SysAdmin — ETA : 2026-05-30
- [Action] — Propriétaire : [Nom/Agent] — ETA : [date]
  Ex. : Mise en place alerte seuil disque 80% — @IT-MonitoringMaster — ETA : 2026-05-27
```

---

### Étape 6 — Vérifications spécifiques P1/P2

**Si le ticket est P1 ou P2, les éléments supplémentaires sont OBLIGATOIRES :**

```
□ Post-incident review planifiée (voir OPR-PostIncident-Review-P1P2_V1)
   → Ticket séparé créé ou intégré dans ce ticket avant fermeture
□ Timeline complète documentée (heure de détection, heure de résolution, actions clés)
□ Parties prenantes notifiées de la résolution (email client ou Discussion CW)
□ Problème récurrent ? → Ouvrir un Problem Record (voir OPR-ProblemManagement-CAPA_V1)
□ Rapport client-safe transmis dans les 24h
```

---

### Étape 7 — Mises à jour documentaires

```
□ Hudu mis à jour si un actif a changé de configuration, d'IP, de rôle, de credentials
□ Article KB créé ou mis à jour si la résolution est reproductible
   → Créer dans Hudu → [Client] → KB ou dans IT-SHARED/RUNBOOKS si générique
□ CMDB CW mise à jour si un actif a changé de statut
```

---

### Étape 8 — Décision de fermeture

| Condition | Décision |
|---|---|
| Tous les critères DoD satisfaits | Fermer le ticket |
| Cause manquante ou non documentée | Bloquer — compléter avant fermeture |
| Discussion CW absente | Bloquer — rédiger avant fermeture |
| Actions pendantes avec owner et ETA | Fermer avec note "Suivi actif — [actions]" |
| P1/P2 sans post-incident review | Bloquer — créer le ticket PIR d'abord |
| Validation non effectuée | Bloquer — retester ou documenter l'impossibilité |

---

## Artefacts obligatoires

| Artefact | P3/P4 | P2 | P1 |
|---|---|---|---|
| Note Interne CW (cause + actions + validation) | Obligatoire | Obligatoire | Obligatoire |
| Discussion CW client-safe | Obligatoire | Obligatoire | Obligatoire |
| Entrées de temps avec description | Obligatoire | Obligatoire | Obligatoire |
| Log ou capture d'écran en pièce jointe | Recommandé | Obligatoire | Obligatoire |
| Ticket Post-Incident Review séparé | Non requis | Obligatoire | Obligatoire |
| Mise à jour Hudu / CMDB | Si applicable | Si applicable | Obligatoire |
| Article KB | Si reproductible | Si reproductible | Obligatoire |

---

## Livrables attendus

- Note Interne CW complète : cause, actions, validation, prochaines étapes
- Discussion CW rédigée et client-safe
- Hudu et CMDB à jour si applicable
- Ticket PIR créé pour tous les P1/P2

---

## Critères de clôture (DoD)

- [ ] Cause documentée (connue, probable, ou inconnue avec hypothèse)
- [ ] Actions effectuées et résultats décrits dans la Note Interne
- [ ] Validation effectuée et documentée (méthode + résultat + heure)
- [ ] Discussion CW client-safe rédigée (aucun secret, IP, credential, commande)
- [ ] Prochaines actions identifiées avec propriétaire et ETA (si applicable)
- [ ] Ticket PIR créé pour tous les P1/P2
- [ ] Hudu et CMDB mis à jour si nécessaire
- [ ] Article KB créé ou mis à jour si résolution reproductible

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| Résolution technique manquante (cause inconnue persistante) | Propriétaire technique | Immédiat |
| P1/P2 sans post-incident review > 48h | @IT-ReportMaster | 48h max |
| Problème récurrent (3e occurrence) | @IT-KnowledgeKeeper + @IT-QAMaster | Prochain jour ouvrable |
| Ticket fermé sans DoD satisfait (détecté en QA) | @IT-QAMaster → incident QA loggué | Correction avant fin de journée |
| Credentials détectés dans la Discussion CW | @IT-SecurityMaster | Immédiat — P1 sécurité |

---

## Notes MSP

- Ce runbook est un **contrat de qualité** — tout ticket fermé sans satisfaire ce DoD génère un incident QA
- La phrase d'ouverture CW ("Prise de connaissance de la demande...") est **non négociable** dans toute Note Interne
- Les agents IA (IT-TicketOpr, IT-TicketScribe) appliquent ce runbook automatiquement lors de toute clôture
- Un ticket avec une bonne Note Interne et une mauvaise Discussion bloque quand même la fermeture
- **Règle d'or :** si un technicien junior reprend le ticket demain sans contexte, la note doit lui permettre de comprendre en 2 minutes ce qui s'est passé

---

*OPR-CW-TicketQualityAudit_V1 — IT MSP Intelligence Platform — 2026-05-23*
