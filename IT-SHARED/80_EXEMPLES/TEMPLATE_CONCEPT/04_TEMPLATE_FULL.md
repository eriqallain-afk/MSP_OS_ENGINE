Voici le paquet à créer localement. Copie chaque bloc dans un fichier avec le nom indiqué, puis zippe le dossier.

Dossier :

```text
PACK_AGENT_EXEMPLE_INTERVENTION_MSP/
├── 00_BRIEF_AGENT_COMPLETION.md
├── 01_TEMPLATE_Reference_Intervention_MSP.md
├── 02_TEMPLATE_Reference_Intervention_MSP_DOCX_CONTENU.md
└── 03_TEMPLATE_Page_Demo_MSP.html
```

Le fichier `02_TEMPLATE_Reference_Intervention_MSP_DOCX_CONTENU.md` sert à créer le `.docx` : ouvre Word, colle le contenu, applique les styles Titre 1 / Titre 2 au besoin, puis enregistre sous `02_TEMPLATE_Reference_Intervention_MSP.docx`.

---

## `00_BRIEF_AGENT_COMPLETION.md`

```markdown
# BRIEF — Complétion d’un cas d’intervention MSP

## Objectif

Compléter les fichiers modèles fournis afin de produire un cas d’intervention MSP démontrable, réutilisable et cohérent entre les formats suivants :

1. Une référence interne Markdown.
2. Une version DOCX présentable.
3. Une page HTML publique de démonstration produit.

Le cas doit démontrer la capacité du produit MSP à structurer une intervention complète : diagnostic, analyse, exécution contrôlée, runbooks utilisés, scripts exécutés, décisions prises, livrables ConnectWise et version publique client-safe.

---

## Fichiers à compléter

- `01_TEMPLATE_Reference_Intervention_MSP.md`
- `02_TEMPLATE_Reference_Intervention_MSP.docx`
- `03_TEMPLATE_Page_Demo_MSP.html`

---

## Résultat attendu

Le retour doit être directement exploitable sans réécriture majeure.

Le dossier final doit contenir :

- un cas clair, crédible et structuré;
- une séquence de diagnostic logique;
- les runbooks, garde-fous ou références utilisés;
- les scripts ou commandes exécutés;
- les observations et preuves internes;
- la cause racine ou une mention `[À CONFIRMER]`;
- les actions effectuées;
- le résultat final;
- les suivis recommandés;
- une Note interne CW prête à coller;
- une Discussion CW client-safe prête à coller;
- un email client si applicable;
- une page HTML publique anonymisée.

---

## Règles obligatoires

- Ne jamais inventer une information technique non fournie.
- Utiliser `[À CONFIRMER]` pour tout champ inconnu.
- Ne jamais inclure de mots de passe, secrets, tokens, clés API, codes MFA ou credentials.
- Ne jamais inclure d’IP dans les livrables client, publics, Discussion CW, Email ou Teams.
- Les commandes techniques sont permises uniquement dans les sections internes.
- Anonymiser les noms de clients, utilisateurs, serveurs, domaines et sites dans la page HTML.
- Garder une séparation claire entre :
  - preuve technique interne;
  - livrable ConnectWise;
  - communication client-safe;
  - démonstration publique marketing.

---

## Champs minimum à compléter

### Identification

- Titre du cas : `[À CONFIRMER]`
- Type d’intervention : `[À CONFIRMER]`
- Client du cas : `[À CONFIRMER]`
- Client anonymisé : `[À CONFIRMER]`
- Billet de référence : `[À CONFIRMER]`
- Priorité : `[À CONFIRMER]`
- Impact client : `[À CONFIRMER]`
- Date de l’intervention : `[À CONFIRMER]`

### Diagnostic

- Contexte initial
- Symptômes
- Alertes reçues
- Hypothèses initiales
- Validations effectuées
- Commandes/scripts exécutés
- Résultats observés
- Cause racine
- Facteurs contributifs
- Décision technique

### Exécution

- Actions correctives appliquées
- Actions volontairement non appliquées
- Risques contrôlés
- Validation fonctionnelle
- Résultat final
- Suivi recommandé

### Livrables

- Note interne CW
- Discussion CW client-safe
- Email client si applicable
- Notice Teams si P1/P2
- Résumé public pour page HTML

---

## Critères d’acceptation

Le livrable est accepté seulement si :

- la cause racine est documentée ou explicitement marquée `[À CONFIRMER]`;
- les actions sont traçables;
- les commandes exécutées sont documentées;
- les suivis sont clairs;
- la Discussion CW ne contient aucune donnée sensible;
- la page HTML ne contient aucune information interne;
- les trois fichiers racontent le même cas avec un niveau de détail adapté au public cible;
- le document peut servir de référence pour des interventions futures.

---

## Instruction finale à l’agent

Compléter tous les champs `[À CONFIRMER]` lorsque l’information est disponible.

Ne pas supprimer les sections non utilisées : inscrire `Non applicable` ou `[À CONFIRMER]`.

Ne pas raccourcir la structure. Le but est de produire un exemple complet démontrant la valeur opérationnelle du produit MSP.
```

---

## `01_TEMPLATE_Reference_Intervention_MSP.md`

````markdown
# EXEMPLE DE RÉFÉRENCE — INTERVENTION MSP
## [TITRE DU CAS] — [Résumé court du problème]

**Type de document :** Référence interne / cas modèle réutilisable  
**Client du cas :** [À CONFIRMER]  
**Client anonymisé pour démonstration :** [À CONFIRMER]  
**Billet de référence :** [À CONFIRMER]  
**Priorité :** [À CONFIRMER]  
**Usage :** Réutilisation lors d’interventions similaires MSP  
**Statut :** Modèle à compléter  

---

## But du document

Transformer une intervention MSP complète en modèle de référence pour les techniciens.

Le document doit conserver :

- le contexte initial;
- la séquence d’analyse;
- les scripts ou commandes exécutés;
- les critères de diagnostic;
- les décisions prises;
- les actions effectuées;
- les suivis recommandés;
- les sorties ConnectWise prêtes à coller.

---

## 1. Quand utiliser ce document

Utiliser ce modèle lorsqu’une intervention présente un ou plusieurs des éléments suivants :

- alerte RMM/NOC nécessitant validation technique;
- diagnostic infrastructure, réseau, serveur, poste ou service cloud;
- besoin de documenter une cause racine;
- intervention pouvant devenir une référence future;
- besoin de produire une Note interne CW et une Discussion client-safe;
- cas démontrant la valeur du produit MSP.

---

## 2. Résumé exécutif du cas de référence

Le cas a commencé par :  
`[Décrire l’alerte, la demande ou le symptôme initial]`

L’analyse a confirmé que :  
`[Décrire le constat principal]`

La cause principale retenue est :  
`[Cause racine ou À CONFIRMER]`

Les actions effectuées ont permis de :  
`[Décrire le résultat final]`

Le suivi recommandé est :  
`[Décrire le suivi, s’il y a lieu]`

---

## 3. Runbooks, garde-fous et références utilisés

### 3.1 Utilisés ou référencés directement pendant le cas

- `GUARDRAILS__IT_AGENTS_MASTER` — posture lecture seule d’abord, pas d’invention, validation avant action.
- `TEMPLATE_BUNDLE_CW_CLOSE` — préparation des sorties de clôture CW.
- `[RUNBOOK À CONFIRMER]` — [Rôle du runbook dans l’intervention].
- `[RÉFÉRENCE À CONFIRMER]` — [Rôle de la référence dans l’intervention].

### 3.2 Références complémentaires pertinentes

- Documentation client : `[À CONFIRMER]`
- Documentation fournisseur : `[À CONFIRMER]`
- Historique RMM / NOC : `[À CONFIRMER]`
- Historique ConnectWise : `[À CONFIRMER]`
- KB interne : `[À CONFIRMER]`

---

## 4. Pré-requis

- Accès RMM ou outil équivalent.
- Accès administratif approprié.
- Accès à la documentation client.
- Accès aux journaux ou consoles pertinentes.
- Autorisation de changement si modification de production requise.
- Aucun correctif destructif avant confirmation de la cause principale.

---

## 5. Séquence d’analyse exacte

### 5.1 Étape 1 — Qualification initiale

**Objectif :** comprendre la demande, confirmer le périmètre et éviter toute action prématurée.

```powershell
# Exemple générique — remplacer selon le cas
Write-Host "=== CONTEXTE INITIAL ==="
Write-Host "Client        : [À CONFIRMER]"
Write-Host "Billet        : [À CONFIRMER]"
Write-Host "Système ciblé : [À CONFIRMER]"
Write-Host "Symptôme      : [À CONFIRMER]"
````

**Observations :**

* `[Observation 1]`
* `[Observation 2]`
* `[Observation 3]`

**Point de décision :**

* Si le symptôme est confirmé, poursuivre vers l’analyse ciblée.
* Si le symptôme n’est pas confirmé, documenter les preuves et conserver le billet en surveillance.
* Si l’impact client est élevé, valider la priorité et l’escalade.

---

### 5.2 Étape 2 — Validation de l’état global

**Objectif :** confirmer si le problème est actif, intermittent ou déjà résolu.

```powershell
# Exemple générique — adapter au contexte
Write-Host "=== VALIDATION ÉTAT GLOBAL ==="

# Services
Get-Service |
    Where-Object { $_.Status -ne 'Running' } |
    Select-Object Name, DisplayName, Status |
    Format-Table -AutoSize

# Événements récents critiques
Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=1,2
    StartTime=(Get-Date).AddHours(-24)
} -ErrorAction SilentlyContinue |
Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message |
Select-Object -First 20 |
Format-List
```

**Chercher :**

* erreurs récurrentes;
* arrêt de service;
* dégradation récente;
* corrélation avec alerte RMM/NOC;
* impact utilisateur confirmé.

---

### 5.3 Étape 3 — Analyse ciblée du composant affecté

**Objectif :** isoler la cause technique probable.

```powershell
# Exemple à personnaliser selon le cas
Write-Host "=== ANALYSE CIBLÉE ==="

$Target = "[À CONFIRMER]"

Write-Host "Cible analysée : $Target"

# Ajouter ici les commandes spécifiques :
# - AD / DNS / DHCP
# - Windows Server
# - Microsoft 365
# - sauvegarde
# - stockage
# - réseau
# - poste utilisateur
# - application métier
```

**Résultats observés :**

| Élément vérifié | Résultat      | Interprétation |
| --------------- | ------------- | -------------- |
| [À CONFIRMER]   | [À CONFIRMER] | [À CONFIRMER]  |
| [À CONFIRMER]   | [À CONFIRMER] | [À CONFIRMER]  |
| [À CONFIRMER]   | [À CONFIRMER] | [À CONFIRMER]  |

---

### 5.4 Étape 4 — Hypothèses et élimination

| Hypothèse     | Preuve pour   | Preuve contre | Décision          |
| ------------- | ------------- | ------------- | ----------------- |
| [Hypothèse 1] | [À CONFIRMER] | [À CONFIRMER] | Retenue / écartée |
| [Hypothèse 2] | [À CONFIRMER] | [À CONFIRMER] | Retenue / écartée |
| [Hypothèse 3] | [À CONFIRMER] | [À CONFIRMER] | Retenue / écartée |

---

### 5.5 Étape 5 — Action corrective

**Objectif :** appliquer uniquement les changements nécessaires, validés et documentés.

```powershell
# Exemple — remplacer par les commandes réellement exécutées
Write-Host "=== ACTION CORRECTIVE ==="
Write-Host "[Décrire action corrective]"
```

**Actions effectuées :**

* `[Action 1]`
* `[Action 2]`
* `[Action 3]`

**Actions volontairement non effectuées :**

* `[Action non effectuée]` — raison : `[À CONFIRMER]`

---

### 5.6 Étape 6 — Validation post-action

**Objectif :** confirmer que le service est revenu à l’état attendu.

```powershell
Write-Host "=== VALIDATION POST-ACTION ==="

# Ajouter ici les validations pertinentes :
# - état des services
# - journaux d’événements
# - test fonctionnel
# - validation utilisateur
# - validation RMM
```

**Résultat :**

* État final : `[Résolu / En surveillance / Escaladé / À CONFIRMER]`
* Impact restant : `[Aucun / Partiel / À CONFIRMER]`
* Validation utilisateur : `[Oui / Non / Non applicable / À CONFIRMER]`

---

## 6. Critères de diagnostic

| Situation              | Indices                                                        | Décision                                   |
| ---------------------- | -------------------------------------------------------------- | ------------------------------------------ |
| Incident réel confirmé | Symptôme actif, impact validé, journaux concordants            | Traiter et documenter                      |
| Alerte transitoire     | Symptôme non reproductible, état normal au moment de l’analyse | Documenter et surveiller                   |
| Problème structurel    | Récurrence, capacité insuffisante, configuration fragile       | Recommander un projet ou changement        |
| Symptôme secondaire    | Anomalie réelle mais non responsable du billet                 | Documenter sans surcorriger                |
| Cause inconnue         | Preuves insuffisantes                                          | Inscrire `[À CONFIRMER]` et proposer suivi |

---

## 7. Conclusion du cas de référence

Le diagnostic a permis de conclure que :

`[Conclusion technique complète]`

La cause racine retenue est :

`[Cause racine ou À CONFIRMER]`

Le service est maintenant :

`[État final]`

---

## 8. Recommandations

* `[Recommandation 1]`
* `[Recommandation 2]`
* `[Recommandation 3]`

---

## 9. Livrables ConnectWise

### 9.1 Note interne CW

```text
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

## Timeline
- [HH:MM] — [Action effectuée]
- [HH:MM] — [Résultat obtenu]
- [HH:MM] — [Action corrective ou validation]
- [HH:MM] — Résolution confirmée / suivi requis

## Commandes exécutées
[Inclure commandes et sorties pertinentes]

## Anomalies détectées
[Inclure toute anomalie technique observée]

## Résolution
[Décrire la résolution technique]

## Cause racine
[Cause racine ou À CONFIRMER]

## Suivi requis
[Suivis requis ou Non applicable]
```

---

### 9.2 Discussion CW client-safe

```text
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

• Situation : [Décrire le problème en termes fonctionnels, sans IP ni nom interne.]
• Tâche : [Décrire l’objectif de l’intervention.]
• Action : [Décrire les validations et corrections en langage client.]
• Résultat : [Décrire l’état final du service.]
• Suivi : [Décrire le suivi requis ou indiquer Aucun suivi requis.]

Durée : [X]h[XX]min
```

---

### 9.3 Email client si applicable

```text
Objet : [RÉSOLU] [Description courte] — Billet #[À CONFIRMER]

Bonjour [Nom contact],

Le problème signalé concernant [description fonctionnelle] a été traité.

Ce qui a été fait :
• Analyse de l’état du service concerné.
• Validation des alertes et des symptômes observés.
• Application des actions correctives appropriées.
• Confirmation du retour à l’état attendu.

État actuel :
Le service est [pleinement opérationnel / en surveillance / en attente de validation].

Suivi :
[Suivi requis ou Aucun suivi requis.]

Cordialement,

[Nom]
Support technique
Réf. : #[À CONFIRMER]
```

---

## 10. Version publique — résumé pour page HTML

**Titre public :**
`[Titre public du cas]`

**Problème présenté :**
`[Décrire le problème sans données internes.]`

**Valeur démontrée :**

* diagnostic structuré;
* séquence de validation claire;
* exécution contrôlée;
* réduction du risque;
* documentation complète;
* livrables CW prêts à utiliser;
* communication client-safe.

**Résultat public :**
`[Résultat en langage démonstration produit]`

````

---

## `02_TEMPLATE_Reference_Intervention_MSP_DOCX_CONTENU.md`

```markdown
# EXEMPLE DE RÉFÉRENCE — INTERVENTION MSP

## [TITRE DU CAS] — [Résumé court du problème]

| Champ | Valeur |
|---|---|
| Type de document | Référence interne / cas modèle réutilisable |
| Client du cas | [À CONFIRMER] |
| Client anonymisé | [À CONFIRMER] |
| Billet de référence | [À CONFIRMER] |
| Priorité | [À CONFIRMER] |
| Usage | Réutilisation lors d’interventions MSP similaires |
| Statut | Modèle à compléter |

---

# But du document

Transformer une intervention MSP complète en référence interne réutilisable.

Le document conserve la séquence d’analyse utilisée, les scripts ou commandes exécutés, les critères de diagnostic, les décisions prises, les actions effectuées, ainsi que les sorties ConnectWise prêtes à coller.

---

# 1. Quand utiliser ce document

Utiliser ce modèle lorsqu’une alerte, une demande client ou un incident nécessite une analyse technique complète et une documentation uniforme.

Exemples :

- alerte NOC ou RMM;
- panne ou dégradation de service;
- incident serveur, réseau, poste, cloud ou application;
- intervention nécessitant une cause racine;
- cas pouvant servir de référence future;
- démonstration de la valeur opérationnelle MSP.

---

# 2. Résumé exécutif du cas

Le cas a commencé par :

[À CONFIRMER]

L’analyse a confirmé que :

[À CONFIRMER]

La cause principale retenue est :

[À CONFIRMER]

Les actions effectuées ont permis de :

[À CONFIRMER]

Le suivi recommandé est :

[À CONFIRMER]

---

# 3. Runbooks, garde-fous et références utilisés

## 3.1 Références utilisées pendant le cas

- GUARDRAILS__IT_AGENTS_MASTER — posture lecture seule d’abord, validation avant action, aucune invention.
- TEMPLATE_BUNDLE_CW_CLOSE — préparation des sorties de clôture ConnectWise.
- [RUNBOOK À CONFIRMER] — [Rôle dans l’intervention].
- [RÉFÉRENCE À CONFIRMER] — [Rôle dans l’intervention].

## 3.2 Références complémentaires

- Documentation client : [À CONFIRMER]
- Historique ConnectWise : [À CONFIRMER]
- Historique RMM / NOC : [À CONFIRMER]
- Documentation fournisseur : [À CONFIRMER]
- KB interne : [À CONFIRMER]

---

# 4. Pré-requis

- Accès RMM ou outil équivalent.
- Accès administratif approprié.
- Accès à la documentation client.
- Accès aux journaux ou consoles pertinentes.
- Autorisation de changement si modification de production requise.
- Aucun correctif destructif avant confirmation de la cause principale.

---

# 5. Séquence d’analyse

## 5.1 Étape 1 — Qualification initiale

Objectif : comprendre la demande, confirmer le périmètre et éviter toute action prématurée.

Commandes ou actions :

[À CONFIRMER]

Observations :

- [Observation 1]
- [Observation 2]
- [Observation 3]

Point de décision :

- Si le symptôme est confirmé, poursuivre vers l’analyse ciblée.
- Si le symptôme n’est pas confirmé, documenter les preuves et surveiller.
- Si l’impact est élevé, valider la priorité et l’escalade.

---

## 5.2 Étape 2 — Validation de l’état global

Objectif : confirmer si le problème est actif, intermittent ou déjà résolu.

Commandes ou actions :

[À CONFIRMER]

Éléments recherchés :

- erreurs récurrentes;
- arrêt de service;
- dégradation récente;
- corrélation avec alerte RMM/NOC;
- impact utilisateur confirmé.

Résultat :

[À CONFIRMER]

---

## 5.3 Étape 3 — Analyse ciblée

Objectif : isoler la cause technique probable.

| Élément vérifié | Résultat | Interprétation |
|---|---|---|
| [À CONFIRMER] | [À CONFIRMER] | [À CONFIRMER] |
| [À CONFIRMER] | [À CONFIRMER] | [À CONFIRMER] |
| [À CONFIRMER] | [À CONFIRMER] | [À CONFIRMER] |

---

## 5.4 Étape 4 — Hypothèses

| Hypothèse | Preuve pour | Preuve contre | Décision |
|---|---|---|---|
| [Hypothèse 1] | [À CONFIRMER] | [À CONFIRMER] | Retenue / écartée |
| [Hypothèse 2] | [À CONFIRMER] | [À CONFIRMER] | Retenue / écartée |
| [Hypothèse 3] | [À CONFIRMER] | [À CONFIRMER] | Retenue / écartée |

---

## 5.5 Étape 5 — Action corrective

Objectif : appliquer uniquement les changements nécessaires, validés et documentés.

Actions effectuées :

- [Action 1]
- [Action 2]
- [Action 3]

Actions volontairement non effectuées :

- [Action non effectuée] — raison : [À CONFIRMER]

Risques contrôlés :

- [Risque 1]
- [Risque 2]

---

## 5.6 Étape 6 — Validation post-action

Objectif : confirmer que le service est revenu à l’état attendu.

Validations effectuées :

- [Validation 1]
- [Validation 2]
- [Validation 3]

Résultat :

- État final : [Résolu / En surveillance / Escaladé / À CONFIRMER]
- Impact restant : [Aucun / Partiel / À CONFIRMER]
- Validation utilisateur : [Oui / Non / Non applicable / À CONFIRMER]

---

# 6. Critères de diagnostic

| Situation | Indices | Décision |
|---|---|---|
| Incident réel confirmé | Symptôme actif, impact validé, journaux concordants | Traiter et documenter |
| Alerte transitoire | Symptôme non reproductible, état normal au moment de l’analyse | Documenter et surveiller |
| Problème structurel | Récurrence, capacité insuffisante, configuration fragile | Recommander un projet ou changement |
| Symptôme secondaire | Anomalie réelle mais non responsable du billet | Documenter sans surcorriger |
| Cause inconnue | Preuves insuffisantes | Inscrire [À CONFIRMER] et proposer suivi |

---

# 7. Conclusion

Le diagnostic a permis de conclure que :

[À CONFIRMER]

Cause racine :

[À CONFIRMER]

Résultat final :

[À CONFIRMER]

Suivi recommandé :

[À CONFIRMER]

---

# 8. Livrables ConnectWise

## 8.1 Note interne CW

Prendre connaissance de la demande et consultation de la documentation.  
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

### Timeline

- [HH:MM] — [Action effectuée]
- [HH:MM] — [Résultat obtenu]
- [HH:MM] — [Action corrective ou validation]
- [HH:MM] — Résolution confirmée / suivi requis

### Commandes exécutées

[Inclure commandes et sorties pertinentes]

### Anomalies détectées

[Inclure toute anomalie technique observée]

### Résolution

[Décrire la résolution technique]

### Cause racine

[Cause racine ou À CONFIRMER]

### Suivi requis

[Suivis requis ou Non applicable]

---

## 8.2 Discussion CW client-safe

Prendre connaissance de la demande et consultation de la documentation.  
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

• Situation : [Décrire le problème en termes fonctionnels, sans IP ni nom interne.]  
• Tâche : [Décrire l’objectif de l’intervention.]  
• Action : [Décrire les validations et corrections en langage client.]  
• Résultat : [Décrire l’état final du service.]  
• Suivi : [Décrire le suivi requis ou indiquer Aucun suivi requis.]

Durée : [X]h[XX]min

---

## 8.3 Email client si applicable

Objet : [RÉSOLU] [Description courte] — Billet #[À CONFIRMER]

Bonjour [Nom contact],

Le problème signalé concernant [description fonctionnelle] a été traité.

Ce qui a été fait :

• Analyse de l’état du service concerné.  
• Validation des alertes et des symptômes observés.  
• Application des actions correctives appropriées.  
• Confirmation du retour à l’état attendu.

État actuel :

Le service est [pleinement opérationnel / en surveillance / en attente de validation].

Suivi :

[Suivi requis ou Aucun suivi requis.]

Cordialement,

[Nom]  
Support technique  
Réf. : #[À CONFIRMER]

---

# 9. Résumé public pour page HTML

Titre public :

[À CONFIRMER]

Problème présenté :

[À CONFIRMER]

Valeur démontrée :

- diagnostic structuré;
- séquence de validation claire;
- exécution contrôlée;
- réduction du risque;
- documentation complète;
- livrables CW prêts à utiliser;
- communication client-safe.

Résultat public :

[À CONFIRMER]
````

---

