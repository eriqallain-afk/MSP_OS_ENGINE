# BUNDLE_KP_Commandare-OPR_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** @IT-Commandare-OPR
**Usage :** Uploader en Knowledge dans le GPT IT-Commandare-OPR
**Contenu :** DoD clôture, templates CW/comms, rapports, gestion CMDB, change management, gouvernance
**Mis à jour :** 2026-03-28

---

## 1. DoD (DEFINITION OF DONE) — CHECKLIST DE CLÔTURE

Avant de confirmer la fermeture de TOUT ticket :

### Obligatoire — tout ticket
```
[ ] Cause racine identifiée OU documentée comme inconnue avec hypothèses
[ ] Actions correctives appliquées OU planifiées avec owner + ETA
[ ] CW_NOTE_INTERNE complète :
    - Phrase d'ouverture conforme (voir section 2)
    - Timeline horodatée des actions
    - Commandes exécutées et outputs
    - Anomalies détectées
    - Résultat final
[ ] CW_DISCUSSION STAR complète :
    - Phrase d'ouverture conforme (même que note interne)
    - Orientée facturation — lisible par le client sur la facture
    - Zéro IP, zéro jargon non expliqué
    - Minimum 4 bullet points
```

### Obligatoire — si impact client
```
[ ] Client notifié de la résolution
[ ] Email client envoyé si incident P1/P2
[ ] Notice Teams de clôture publiée si P1/P2
```

### Obligatoire — si asset impacté
```
[ ] CMDB mise à jour (ConnectWise Configurations)
[ ] Documentation Hudu mise à jour si info persistante changée → @IT-ClientDocMaster
```

### Obligatoire — si P1/P2
```
[ ] Post-mortem déclenché (< 5 jours ouvrables)
[ ] KB créé ou mis à jour → @IT-KnowledgeKeeper
[ ] Monitoring ajusté pour prévenir la récurrence → @IT-MonitoringMaster
```

---

## 2. PHRASES D'OUVERTURE CW (OBLIGATOIRE)

Choisir UNE des deux. La même phrase doit apparaître en ouverture de CW_DISCUSSION ET CW_NOTE_INTERNE :

```
Option A : "Prendre connaissance de la demande et connexion à la documentation de l'entreprise."
Option B : "Préparation et découverte. Consultation de la documentation."
```

---

## 3. TEMPLATES CW

### CW_NOTE_INTERNE (technique, usage interne)
```
[Phrase d'ouverture]

## Timeline
- HH:MM — [Action effectuée]
- HH:MM — [Résultat obtenu]
- HH:MM — [Action suivante]
- HH:MM — Résolution confirmée

## Commandes exécutées
[Commandes et outputs pertinents]

## Anomalies détectées
[Tout ce qui sort de l'ordinaire, même si non lié au ticket]

## Résolution
[Description technique de la solution appliquée]

## Suivi requis
[Actions post-intervention si applicable]
```

### CW_DISCUSSION STAR (client-facing, facturation)
```
[Phrase d'ouverture]

• Situation : [description du problème en termes fonctionnels]
• Tâche : [objectif de l'intervention]
• Action : [ce qui a été fait — sans jargon technique]
• Résultat : [état actuel — service rétabli / en suivi / escaladé]

Durée : [X]h[XX]min
```

**Règles CW_DISCUSSION :**
- Minimum 4 bullet points
- Zéro IP, zéro nom de serveur, zéro commande technique
- Lisible par un comptable ou un gestionnaire non-technique
- Visible sur la facture du client

### EMAIL CLIENT — Résolution
```
Objet : [RÉSOLU] [Description courte] — Billet #TXXXXXXX

Bonjour [Nom contact],

Le problème signalé concernant [description fonctionnelle] a été résolu.

Ce qui a été fait :
• [Action 1 en termes fonctionnels]
• [Action 2]

Le service est maintenant pleinement opérationnel. Si vous constatez toute anomalie, n'hésitez pas à nous contacter.

Cordialement,
[Nom] — Support technique
Réf. : #TXXXXXXX
```

### NOTICE TEAMS — Clôture
```
✅ [P1/P2] RÉSOLU | Client : [NOM] | [Type incident]
Billet : #TXXXXXXX
Résolution : [description 1 ligne]
Durée : [X]h[XX]min
Post-mortem : [planifié JJ/MM | non requis]
```

---

## 4. RAPPORTS

### Rapport mensuel MSP — Structure
```
1. Résumé exécutif (1 paragraphe)
2. KPIs du mois
   - Tickets ouverts / résolus / en attente
   - SLA compliance par priorité (P1/P2/P3/P4)
   - MTTR par priorité
   - First Call Resolution %
   - Ticket Reopen Rate
3. Incidents majeurs (P1/P2)
   - Timeline résumée
   - Impact
   - Actions correctives
4. Maintenances effectuées
5. Assets — changements CMDB
6. Recommandations
7. Planification mois suivant
```

### QBR (Quarterly Business Review) — Structure
```
1. Résumé du trimestre
2. Tendances KPIs (3 mois, graphiques)
3. Top incidents et résolutions
4. Projets complétés / en cours
5. Santé infrastructure (monitoring trends)
6. Sécurité — posture et incidents
7. Budget consommé vs planifié
8. Recommandations stratégiques
9. Roadmap trimestre suivant
```

### Post-mortem — Structure
```
1. Résumé incident (qui, quoi, quand, impact)
2. Timeline détaillée
3. Cause racine
4. Facteurs contributifs
5. Actions correctives (owner + ETA)
6. Leçons apprises
7. Monitoring ajusté
```

---

## 5. GESTION CMDB / ASSETS

### Quand mettre à jour la CMDB
```
- Nouveau serveur/équipement déployé
- Serveur retiré ou remplacé
- Changement d'OS, d'IP, de rôle
- EOL atteint → planifier remplacement
- Changement de licence (ajout, retrait, renouvellement)
- Après toute intervention qui modifie la config d'un asset
```

### Champs CMDB obligatoires (ConnectWise Configurations)
```
- Nom (hostname exact)
- Type (Server / Workstation / Network / Printer / etc.)
- Client
- Site
- OS + version
- Rôle principal
- Date d'installation
- Date EOL prévue
- Statut (Active / Retired / Maintenance)
```

### Sous-agents CMDB
| Action | Agent |
|---|---|
| Inventaire HW/SW, lifecycle, EOL | @IT-AssetMaster |
| Documentation opérationnelle Hudu | @IT-ClientDocMaster |
| KB technique | @IT-KnowledgeKeeper |

---

## 6. CHANGE MANAGEMENT

### Processus change request
```
1. Demande reçue (ticket CW ou demande Commandare)
2. Évaluer impact et risque :
   - Qui est impacté ? (utilisateurs, services, clients)
   - Y a-t-il un plan de rollback ?
   - Fenêtre de maintenance requise ?
3. Si impact faible (P4, utilisateur unique) : approuver directement
4. Si impact moyen/élevé :
   - Créer un ticket change request dans CW
   - Documenter le plan d'exécution
   - Obtenir approbation superviseur si P1/P2
   - Planifier la fenêtre de maintenance
   - Communiquer au client
5. Post-change :
   - Validation fonctionnelle
   - CMDB mise à jour
   - Documentation
```

---

## 7. SOUS-AGENTS OPR

| Domaine | Agent mobilisé | Quand |
|---|---|---|
| Notes CW / discussions | @IT-TicketScribe | Rédaction CW standardisée |
| Rapports / QBR / post-mortems | @IT-ReportMaster | Production rapports |
| Assets / CMDB / EOL | @IT-AssetMaster | Mise à jour inventaire |
| KB / documentation technique | @IT-KnowledgeKeeper | Création KB post-incident |
| Documentation client Hudu | @IT-ClientDocMaster | Info persistante post-intervention |

---

## 8. ANTI-PATTERNS OPR

```
❌ Clôturer un ticket sans CW_NOTE_INTERNE complète
❌ Écrire une CW_DISCUSSION avec des IPs ou du jargon technique
❌ Oublier la phrase d'ouverture obligatoire dans CW
❌ Clôturer un P1/P2 sans post-mortem planifié
❌ Modifier la CMDB sans documenter le changement dans le ticket
❌ Envoyer un email client avec des noms de serveurs internes
❌ Approuver un change request sans plan de rollback documenté
❌ Produire un rapport mensuel sans données de SLA compliance
```

---

*BUNDLE_KP_Commandare-OPR_V1 — Version 1.0 — 2026-03-28*
