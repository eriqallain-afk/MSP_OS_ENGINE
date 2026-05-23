# TEMPLATE — Plan de Reprise après Sinistre (DR Plan)
**ID :** TEMPLATE_DR_PLAN_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Agent producteur :** IT-Commandare-OPR | IT-SecurityMaster
**Niveau :** Enterprise
**Audience :** Direction technique / Coordonnateur / Équipe IT client | **Révision :** Annuelle minimum
**Complémentaire à :** TEMPLATE_REPORT_DR-Test_V1.md (rapport de test)

---

# PLAN DE REPRISE APRÈS SINISTRE — [CLIENT]

**Référence :** DR-PLAN-[CLIENT]-[ANNÉE]
**Version du plan :** [V1.0]
**Responsable du plan :** [Nom — MSP / Client]
**Approuvé par :** [Nom — Direction client]
**Date d'approbation :** [YYYY-MM-DD]
**Prochaine révision :** [YYYY-MM-DD]

---

## 1. OBJECTIFS ET PORTÉE

### 1.1 Objectifs

Ce plan définit les procédures à suivre pour restaurer les services IT critiques en cas de sinistre majeur : panne matérielle généralisée, incendie, inondation, ransomware, défaillance du site principal.

### 1.2 Périmètre

| Inclus dans ce plan | Exclu |
|---|---|
| [Systèmes / services couverts] | [Systèmes hors périmètre] |
| [Ex : Serveurs de production, AD, ERP] | [Ex : Postes de travail individuels] |
| [Ex : Microsoft 365 / Exchange] | [Ex : Appareils mobiles personnels] |

### 1.3 Objectifs de reprise

| Système / Service | RTO (temps max d'interruption) | RPO (perte de données max acceptable) |
|---|---|---|
| Active Directory / DNS | [Xh] | [Xh] |
| Serveur de fichiers | [Xh] | [Xh] |
| ERP / Application critique | [Xh] | [Xh] |
| Microsoft 365 / Exchange | [Xh] | [Xh] |
| Accès distant / VPN | [Xh] | [Xh] |
| [Autre système critique] | [Xh] | [Xh] |

---

## 2. CLASSIFICATION DES SINISTRES

| Niveau | Description | Exemples | Action |
|---|---|---|---|
| 1 — Incident | Panne d'un composant isolé | Disque défaillant, VM down | Runbook standard — NOC |
| 2 — Sinistre partiel | Perte d'un serveur ou d'un site | Hôte hyperviseur down, incendie salle serveur | DR Plan — activation partielle |
| 3 — Sinistre majeur | Perte totale du site principal | Désastre naturel, ransomware total | DR Plan — activation complète |

---

## 3. ÉQUIPE DE REPRISE (DRT — Disaster Recovery Team)

| Rôle | Nom | Contact principal | Contact secondaire |
|---|---|---|---|
| Coordonnateur DR (MSP) | [Nom] | [Téléphone / Teams] | [Email] |
| Responsable technique (MSP) | [Nom] | [Téléphone] | [Email] |
| Responsable client (décision) | [Nom] | [Téléphone] | [Email] |
| Contact IT client | [Nom] | [Téléphone] | [Email] |
| Fournisseur Internet / WAN | [Fournisseur] | [# support] | [# escalade] |
| Fournisseur matériel | [Fournisseur] | [# support] | [Contrat #] |

**Arbre d'appel :**
1. Coordonnateur DR (MSP) → avise Responsable technique (MSP)
2. Coordonnateur DR → avise Responsable client
3. Responsable technique → active l'équipe NOC/INFRA

---

## 4. INVENTAIRE DES SYSTÈMES CRITIQUES

| Système | Rôle | Localisation | Sauvegarde | Solution DR |
|---|---|---|---|---|
| [Nom serveur] | [Rôle : DC / Fichiers / ERP] | [On-prem / Cloud] | [Solution / Fréquence] | [Réplication / Cloud / Cold standby] |
| [Nom serveur] | [Rôle] | [Localisation] | [Solution] | [Solution DR] |

**Sauvegardes — emplacement hors site :**
- Solution : [Veeam / Datto / Azure Backup / Autre]
- Emplacement : [Cloud / Site secondaire — adresse]
- Accès : Passportal — [référence coffre]
- Dernier test validé : [DATE]

---

## 5. PROCÉDURES DE REPRISE

### 5.1 Déclenchement du plan DR

**Critères d'activation :**
- [ ] Indisponibilité d'un ou plusieurs systèmes critiques > [Xh]
- [ ] Perte physique ou logique du site principal
- [ ] Incident de sécurité majeur (ransomware) affectant la production
- [ ] Décision du Responsable client ou du Coordonnateur DR

**Étape 1 — Évaluation initiale (< 30 minutes)**
- [ ] Identifier l'étendue du sinistre (systèmes impactés, données affectées)
- [ ] Activer l'arbre d'appel DRT
- [ ] Documenter l'heure de début et les premiers constats
- [ ] Ouvrir billet P1 dans CW — Ticket # [À COMPLÉTER]
- [ ] Aviser le Coordonnateur du board client

**Étape 2 — Décision d'activation**
- [ ] Confirmer le niveau de sinistre (1 / 2 / 3)
- [ ] Décision d'activation par [Responsable client + Coordonnateur DR]
- [ ] Communiquer aux utilisateurs — message d'alerte :

```
[CLIENT] — Incident IT en cours — [YYYY-MM-DD HH:MM]
Nos équipes IT travaillent à résoudre une interruption de service.
Systèmes affectés : [liste]
ETA restauration : [estimation ou À confirmer]
Contact : [nom] — [téléphone]
```

---

### 5.2 Reprise — Active Directory / DNS

**Prérequis :** Accès aux sauvegardes NTDS / sauvegarde système DC

| Étape | Action | Responsable | Durée estimée |
|---|---|---|---|
| 1 | Vérifier si DC secondaire (autre site) est disponible | Technicien INFRA | 15 min |
| 2 | Si DC secondaire disponible — pointer DNS vers DC secondaire | Technicien INFRA | 30 min |
| 3 | Si perte totale — restaurer DC depuis sauvegarde (voir Runbook DC) | Technicien INFRA | [Xh] |
| 4 | Valider réplication AD — `repadmin /replsummary` | Technicien INFRA | 15 min |
| 5 | Valider FSMO roles — `netdom query fsmo` | Technicien INFRA | 10 min |

Runbook de référence : `INFRA-AD-DC_Operations_V3.md`

---

### 5.3 Reprise — Serveur de fichiers

| Étape | Action | Responsable | Durée estimée |
|---|---|---|---|
| 1 | Identifier le dernier point de restauration valide | Technicien BACKUP | 15 min |
| 2 | Restaurer vers serveur de secours ou cloud | Technicien BACKUP | [Xh] |
| 3 | Valider intégrité des données — test accès fichiers | Technicien INFRA | 30 min |
| 4 | Rediriger les partages (GPO / DFS) | Technicien INFRA | 30 min |
| 5 | Valider accès utilisateurs | Technicien N2 | 15 min |

---

### 5.4 Reprise — Hyperviseur (Hyper-V / VMware)

| Étape | Action | Responsable | Durée estimée |
|---|---|---|---|
| 1 | Évaluer état RAID / stockage avant tout démarrage VM | Technicien INFRA | 15 min |
| 2 | Restaurer VMs depuis sauvegarde si stockage compromis | Technicien BACKUP | [Xh] |
| 3 | Démarrer VMs dans l'ordre : DC → DNS → Fichiers → Applications | Technicien INFRA | 30 min |
| 4 | Valider chaque VM avant de démarrer la suivante | Technicien INFRA | [Xh] |

Runbook de référence : `INFRA-SRV-HyperV_Operations_V2.md` / `INFRA-SRV-VMware_Operations_V2.md`

---

### 5.5 Reprise — Microsoft 365

| Étape | Action | Responsable | Durée estimée |
|---|---|---|---|
| 1 | Valider accès portail M365 admin.microsoft.com | Technicien INFRA | 15 min |
| 2 | Vérifier état services — admin.microsoft.com/servicestatus | Technicien INFRA | 10 min |
| 3 | Si incident Microsoft — référencer le # d'incident | Technicien INFRA | — |
| 4 | Si perte données — restaurer depuis sauvegarde tierce | Technicien BACKUP | [Xh] |

---

## 6. COMMUNICATION PENDANT LE SINISTRE

| Étape | Communication | Destinataires | Canal | Fréquence |
|---|---|---|---|---|
| Activation DR | Alerte sinistre initial | DRT + Direction client | Teams / Téléphone | Immédiat |
| En cours | Mise à jour de statut | Direction client + utilisateurs | [Courriel / Teams] | Toutes les [Xh] |
| Restauration partielle | Services partiellement rétablis | Tous | [Canal] | Lors de chaque jalon |
| Clôture | Rapport de clôture | Direction client | [Courriel] | ≤ 24h post-reprise |

---

## 7. RETOUR À LA NORMALE

- [ ] Tous les systèmes critiques validés opérationnels
- [ ] Sauvegardes reprises et vérifiées
- [ ] RTO et RPO atteints (ou dérogation documentée)
- [ ] Utilisateurs informés de la reprise complète
- [ ] Rapport post-sinistre initié (voir TEMPLATE_REPORT_Postmortem_V2.md)
- [ ] CAPA ouverte si sinistre récurrent ou systémique (voir TEMPLATE_CAPA_V1.md)
- [ ] Plan DR révisé si des lacunes ont été identifiées

---

## 8. TESTS ET MAINTENANCE DU PLAN

| Activité | Fréquence | Responsable | Dernière date |
|---|---|---|---|
| Revue du plan DR | Annuelle | Coordonnateur DR | [DATE] |
| Test de restauration sauvegarde | Trimestrielle | Technicien BACKUP | [DATE] |
| Test de reprise complet (tabletop) | Annuelle | DRT + Direction client | [DATE] |
| Mise à jour inventaire systèmes | Semestrielle | Technicien INFRA | [DATE] |

Rapport de test : voir `TEMPLATE_REPORT_DR-Test_V1.md`

---

## 9. JOURNAL DES RÉVISIONS

| Version | Date | Modifié par | Description des changements |
|---|---|---|---|
| V1.0 | [YYYY-MM-DD] | [Nom] | Création initiale |

---

*Plan DR — [CLIENT] — Référence : DR-PLAN-[CLIENT]-[ANNÉE] — Approuvé le [DATE]*
*Document confidentiel — usage interne MSP et direction client uniquement*
