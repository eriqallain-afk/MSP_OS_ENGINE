# Guide d'utilisation — @IT-OPS-DossierIA (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP, agents de la plateforme
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-OPS-DossierIA ?

**IT-OPS-DossierIA est la mémoire opérationnelle de chaque intervention.**

Il consolide tout ce qui s'est passé pendant un run — ticket d'origine, intent détecté, runbook exécuté, étapes réalisées, décisions prises, risques identifiés — et produit un **dossier ITSM structuré** prêt à coller dans ServiceNow, Jira, Halo ou ConnectWise.

| Outil | Ce qu'il fait |
|---|---|
| **RouterIA** | Détecte l'intent et choisit le runbook |
| **PlaybookRunner** | Exécute le runbook step by step |
| **DossierIA** | Archive tout — produit le dossier traçable, déclenche DOC_SYNC |

DossierIA n'exécute rien. Il ne diagnostique pas. Il **consolide et archive** — avec une règle absolue : **zéro invention**. Ce qui n'est pas fourni est marqué `<missing>`.

---

## Quand l'utiliser ?

- En fin d'intervention, pour générer la Note CW et la timeline complète
- Après un run PlaybookRunner, pour produire le livrable ITSM
- Pour créer un postmortem structuré après un incident P1/P2
- Pour générer une passation (Flag Up) vers l'équipe de relève
- Pour vérifier quels documents DOC_SYNC doivent être mis à jour après un changement

---

## Les commandes principales

### Dossier complet après intervention

La commande principale. Tu fournis le contexte de l'intervention, DossierIA produit le dossier YAML complet avec Note CW et timeline.

**Usage :**
```
Voici les outputs de l'intervention sur le billet #77201 — génère le dossier ITSM complet.

ticket_id: #77201
client: Otto Inc
intent: it.windows.update_missing
runbook: RUNBOOK__IT_PATCH_DC_V1
etapes_executees:
  - T+00:00 — Prechecks DC : disque OK, réplication AD OK, backup confirmé
  - T+00:10 — Téléchargement KB5034441 via WSUS
  - T+00:25 — Installation patch — succès
  - T+00:40 — Reboot planifié — maintenance_window approuvée
  - T+01:00 — Post-check DC : tous les services OK, réplication active
decisions:
  - Reboot autorisé car backup confirmé et DC secondaire actif
risques:
  - Un seul DC sur le site — reboot planifié hors heures ouvrées
resultat: Résolu
```

**Ce que tu obtiens :**
- YAML strict avec `result.dossier.ticket_update_md` (Note CW markdown)
- `timeline` : événements datés de T+00:00 à résolution
- `evidence` : outputs collés ou référencés
- `closure` : statut + suivis
- `next_actions` : items DOC_SYNC si applicable
- `log.decisions` et `log.risks`

---

### Postmortem après incident P1/P2

Pour les incidents P1/P2, DossierIA produit un postmortem structuré qui sépare ce qui est prouvé de ce qui est hypothèse.

**Usage :**
```
Génère un postmortem pour l'incident P1 du 2026-05-17.

client: ABC Corp
type: Panne réseau — lien WAN principal coupé
debut: 14:32 | fin: 16:45 | duree: 2h13m
cause_probable: Défaillance équipement FAI — modem câble
cause_confirmee: Confirmé par le FAI le lendemain — remplacement modem
impact: 45 utilisateurs sans accès pendant 2h13m
actions_correctives:
  - Lien de secours LTE activé à 14:47 — rétabli accès partiel
  - Remplacement modem planifié le 2026-05-18
actions_preventives:
  - Valider le test automatique du lien LTE de secours
  - Ajouter monitoring dédié sur le lien principal
```

**Ce que tu obtiens :**
- Section `cause_probable` vs `cause_confirmee` — séparées, jamais fusionnées
- Actions correctives avec owner + ETA
- Actions préventives + `runbook_improvements` suggérés

---

### Passation structurée (Flag Up)

Quand l'intervention doit être transmise à une autre équipe ou au quart suivant.

**Usage :**
```
Dossier en cours — Flag Up requis pour l'équipe de soir.

billet: #77315
client: Otto Transport
statut_actuel: En cours — runbook à 60%
derniere_action: Isolation du poste compromis à 15:30
prochaine_etape: Scan EDR complet — résultats attendus dans 2h
point_attention: Ne pas reconnecter le poste au réseau avant résultats EDR
agent_suivant: IT-SecurityMaster
```

**Ce que tu obtiens :**
- Bloc de passation structuré prêt pour Teams
- Contexte complet pour l'équipe de relève
- `next_actions` avec owner et ETA clairement définis

---

### Vérification DOC_SYNC

Après tout changement de plateforme (nouvel agent, nouveau runbook, nouveau playbook), DossierIA identifie les documents à mettre à jour.

**Usage :**
```
Quels documents DOC_SYNC dois-je mettre à jour ?
Changement effectué : ajout de l'agent IT-TicketOpr à la plateforme.
```

**Ce que tu obtiens :**
```yaml
next_actions:
  - "[DOC_SYNC] agents_index.yaml — ajouter IT-TicketOpr"
  - "[DOC_SYNC] FACTORY_MANIFEST_IT.yaml — stats.total_agents"
  - "[DOC_SYNC] CLAUDE.md — section 3 Les 32 agents"
  - "[DOC_SYNC] MASTER_DISPATCH_INDEX_V2.yaml — si nouveaux intents"
```

---

## Flux de travail recommandé

### Fin d'intervention standard

```
1. Intervention terminée — résultat confirmé
        ↓
2. Coller les outputs PlaybookRunner dans DossierIA
   /dossier [brief complet de l'intervention]
        ↓
3. DossierIA produit : Note CW + timeline + closure + DOC_SYNC
        ↓
4. Copier la Note CW dans ConnectWise (billet concerné)
        ↓
5. Appliquer les items [DOC_SYNC] identifiés
```

### Après un incident P1/P2

```
1. Incident stabilisé — services rétablis
        ↓
2. /dossier [outputs complets de l'incident]
   + demander le postmortem explicitement
        ↓
3. DossierIA produit : dossier + postmortem (cause probable vs confirmée)
        ↓
4. Partager le postmortem avec IT-Commandare-OPR pour clôture formelle
        ↓
5. IT-KnowledgeKeeper → /kb si nouvelle cause racine documentable
```

### En cas de Flag Up

```
1. Intervention incomplète — passation nécessaire
        ↓
2. /flagup [contexte + statut + prochaine étape + agent cible]
        ↓
3. DossierIA produit : bloc de passation + notice Teams
        ↓
4. Coller la notice dans le canal Teams MSP
        ↓
5. L'équipe de relève reprend avec le contexte complet
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO invention | DossierIA marque `"<missing>"` — jamais il ne comble un vide par de l'imagination |
| ZÉRO IP dans les livrables CW_DISCUSSION | Visible sur facture client — sécurité et confidentialité |
| ZÉRO credential dans aucun champ | Les credentials restent dans Passportal — jamais dans un dossier |
| `[DOC_SYNC]` obligatoire à chaque run | La plateforme reste cohérente seulement si les index sont à jour |
| Cause probable ≠ cause confirmée | Un postmortem avec hypothèses comme faits est dangereux |
| `risk_level: high` → prérequis obligatoires | Maintenance_window + change_id + backup avant tout dossier high-risk |

---

## Questions fréquentes

**Q : Quelle différence avec IT-OPS-PlaybookRunner ?**
PlaybookRunner exécute les étapes du runbook avec l'humain. DossierIA archive ce qui s'est passé et produit le livrable ITSM. PlaybookRunner alimente DossierIA via son `handoff_to_dossier`.

**Q : Dois-je utiliser DossierIA pour chaque ticket ?**
Non — seulement pour les interventions qui méritent traçabilité : incidents P1/P2, runbooks à risque élevé, interventions > 30 min, ou tout changement de plateforme.

**Q : Que faire si DossierIA met `"<missing>"` partout ?**
Fournis plus de contexte. DossierIA ne peut archiver que ce qu'on lui donne. Colle les outputs PlaybookRunner ou les notes prises pendant l'intervention.

**Q : Le DOC_SYNC est obligatoire ?**
Oui — c'est une règle du prompt. DossierIA vérifie `00_INDEX/DOC_SYNC_MATRIX.md` à la fin de chaque run et liste dans `next_actions` les documents à synchroniser. Tu dois les appliquer.

**Q : Puis-je utiliser DossierIA sans avoir passé par RouterIA et PlaybookRunner ?**
Oui. DossierIA peut archiver n'importe quelle intervention — même si tu n'as pas utilisé RouterIA. Fournis simplement le contexte complet de ce qui s'est passé.

---

*GUIDE_UTILISATION — IT-OPS-DossierIA v1.0 — MSP Intelligence AI — 2026-05-18*
