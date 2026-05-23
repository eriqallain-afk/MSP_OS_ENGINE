# Guide d'utilisation — @IT-Assistant-N2 (v1.0)
> **Pour :** Techniciens N1/N2 MSP — support technique intermédiaire
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-Assistant-N2 ?

**IT-Assistant-N2 est le coach technique MSP pour les interventions de niveau 2.**

Il guide le technicien pas à pas pendant que le client est en ligne au téléphone. Chaque étape est numérotée, immédiatement actionnable, avec des validations concrètes pour confirmer que l'action a fonctionné — et des avertissements NE PAS FAIRE avant chaque étape risquée.

Il intervient quand le problème résiste au FrontLine (N1) et se concentre sur les incidents plus complexes : réinitialisation MDP AD et M365, gestion des accès fichiers et SharePoint, dépannage Outlook avancé, VPN utilisateur, postes de travail lents ou gelés.

**Ce qu'il fait :**
- Guide structuré étape par étape avec validations — client en ligne pendant l'intervention
- Vérification d'identité avant toute action sur un compte
- Vérification d'autorisation avant tout ajout d'accès (pas juste la parole de l'utilisateur)
- Scripts PowerShell avec standards RMM compatibles
- Escalade automatique P1 — bloc CW prêt à coller
- Clôture CW complète : Note Interne, Discussion, Email, Teams

**Ce qu'il ne fait PAS :**
- Administration serveurs et infrastructure
- AD avancé : réplication DC, FSMO, GPO complexes
- Virtualisation, backup, réseau infrastructure
- Scripts PowerShell complexes (→ IT-Assistant-N3)

---

## Quand l'utiliser ?

- Le FrontLine (N1) n'a pas pu résoudre le problème
- Un billet N2 arrive directement avec un problème de compte, d'accès ou de poste
- Tu dois réinitialiser un MDP AD ou M365 avec vérification d'identité
- Tu gères un problème d'accès dossier ou SharePoint avec confirmation d'autorisation
- Outlook ne s'ouvre pas ou ne synchronise pas
- Le VPN d'un utilisateur ne se connecte pas
- Le poste est lent ou gelé et tu dois diagnostiquer

**Distinction avec les agents voisins :**

| Agent | Niveau | Utiliser quand |
|---|---|---|
| IT-FrontLine | N1/N2 | Premier contact — appels entrants, triage, résolutions rapides |
| **IT-Assistant-N2** | N2 | Problème résiste au N1 — AD standard, M365, postes complexes |
| IT-Assistant-N3 | N3 | Serveurs impliqués, DC/AD, RDS, Hyper-V, SQL, scripts production |
| IT-SysAdmin | Senior | Admin système : patching, infrastructure, virtualisation |

---

## Les commandes principales

### `/start` — Nouvelle intervention N2

La commande principale. Elle produit immédiatement le triage, la priorité, et les premières étapes.

**Usage :**
```
/start #33001
Client : Dupont Construction
Utilisateur : Marie Lefebvre
Problème : Compte AD verrouillé depuis ce matin — ne peut pas se connecter
```

**Ce que tu obtiens :**
```
TRIAGE
Type : MOT DE PASSE / COMPTE VERROUILLÉ
Priorité : P3
Utilisateur : Marie Lefebvre — département : [À CONFIRMER]
Client en ligne ? Oui / Non

⚠️ VÉRIFICATION D'IDENTITÉ OBLIGATOIRE AVANT TOUTE ACTION

ÉTAPES :
1. Vérifier l'état du compte dans ADUC
   ✅ Validation : tu vois la fiche de l'utilisateur — "Account is locked out" coché

2. Vérifier l'identité — choisir 2 méthodes :
   → Numéro d'employé | Date d'embauche | Nom du superviseur

3. Si identité confirmée — déverrouiller :
   → Clic droit > Properties > Account > décocher "Account is locked out"
   ✅ Validation : coche disparaît

4. Tester la connexion avec l'utilisateur
   ✅ Validation : connexion réussie

⛔ NE PAS réinitialiser sans confirmation d'identité
⛔ NE PAS donner le nouveau MDP par courriel — verbal uniquement
```

---

### `/escalade` — Générer le bloc CW de transfert

À utiliser pour transférer vers NOC, SOC, INFRA ou TECH. L'agent détermine le bon département selon le type d'incident.

**Usage :**
```
/escalade
```

ou sur déclenchement automatique P1 :
```
⚠️ [ESCALADE REQUISE — P1]
Ce billet dépasse le périmètre N1/N2.
Informe ton superviseur maintenant.
Tape /escalade pour générer le bloc CW à coller avant de transférer.
```

**Ce que tu obtiens (exemple TECH) :**
```
═══════════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT TECH (Support N3)
Billet : #33001 | Priorité : P3
Technicien N2 : [NOM] | Date/Heure : 2026-05-18 10:15
═══════════════════════════════════════════════════

PROBLÉMATIQUE
Profil utilisateur corrompu — impossible de créer un nouveau profil standard

CE QUI A ÉTÉ TENTÉ (N2)
1. Vérification ADUC — compte OK
2. Renommage profil .OLD — nouveau profil créé mais données inaccessibles
3. gpupdate /force — aucun changement

DURÉE INTERVENTION N2 : 35 minutes
CLIENT EN ATTENTE : ☑ Oui
SLA À RISQUE : ☐ Non

HYPOTHÈSE ACTUELLE
Profil itinérant configuré sur serveur de fichiers — permission corrompue
═══════════════════════════════════════════════════
```

**Règle de routage :**
| Situation | Département |
|---|---|
| Ransomware, malware, breach, phishing | SOC |
| Réseau site, infra critique, backup | NOC |
| Serveur, DC, AD avancé, infrastructure | INFRA |
| Bloqué N2, RCA requis, problème non résolu | TECH |

---

### `/kb` — Brief pour IT-KnowledgeKeeper

Après une résolution, génère un brief YAML structuré prêt à coller dans IT-KnowledgeKeeper.

**Usage :**
```
/kb
```

**Ce que tu obtiens :**
```yaml
kb_brief:
  ticket_id: "#33001"
  type_incident: "mot_de_passe"
  systeme_concerne: "AD"
  niveau_technicien_requis: "N2"
  temps_resolution_estime: "20min"
  recurrence_connue: "non"

  symptomes_observes:
    - "Compte AD verrouillé — utilisateur ne peut pas se connecter"
    - "Aucune modification récente de MDP"

  cause_racine_identifiee: >
    Script de synchronisation tiers (outil RH) génère des tentatives
    d'auth répétées avec ancien MDP mis en cache — déclenche lockout policy.

  actions_realisees:
    - seq: 1
      action: "Déverrouillage du compte ADUC"
      resultat: "Compte déverrouillé"
```

---

### `/close` — Clôture complète

Génère les 4 livrables CW. Sur `/close`, un menu s'affiche — l'agent attend ton choix.

**Usage :**
```
/close
```

**Ce que tu obtiens :**
```
📋 Clôture — Billet #33001
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[A] Tout (1+2+3)

Que veux-tu générer ?
```

La CW Discussion commence toujours par :
```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.
```

Règles : jamais d'IP, jamais de noms de serveurs, minimum 4 puces dans TRAVAUX EFFECTUÉS.

---

### `/status` — Résumé de l'intervention en cours

**Usage :**
```
/status
```

Affiche : billet, client, type, priorité, durée, statut actuel, prochaine action.

---

## Flux de travail recommandé

### Intervention standard N2

```
1. Billet reçu (FrontLine ou MSPBOT)
       ↓
2. /start [#billet + description]
   → Triage + priorité + premières étapes
       ↓
3. Vérification identité ou autorisation (si MDP ou accès)
       ↓
4. Intervention guidée étape par étape
   └─ P1 détecté → /escalade immédiat
   └─ Bloqué 20 min → proposer escalade TECH
       ↓
5. Validation : utilisateur confirme que ça fonctionne
       ↓
6. /close → [A] Tous les livrables CW
       ↓
7. (Optionnel) /kb si incident > 30 min ou cause non évidente
```

### Notice Teams — déclenchement automatique

Dès que le type d'intervention est connu, l'agent propose :
```
📣 Veux-tu que je génère la notice Teams maintenant ?
   Elle sera postée ce soir pour informer l'équipe NOC.
   [O] Oui — générer maintenant  [N] Non — générer à /close
```

Format de la notice :
```
⚠️ Maintenance en cours — Billet : #33001
Maintenance en cours chez Dupont Construction
Tâche principale : Réinitialisation profil utilisateur
Impact : Accès utilisateur temporairement indisponible
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| JAMAIS de réinitialisation MDP sans vérification d'identité | Sécurité — un attaquant peut se faire passer pour un employé |
| JAMAIS d'accès dossier/SharePoint sans confirmation du superviseur | La parole de l'utilisateur ne suffit pas |
| JAMAIS de permissions directement sur un dossier | Utiliser les groupes AD uniquement — écrase toute la hiérarchie |
| JAMAIS `Apply to subfolders` sur les permissions | Détruit la structure héritée pour tous les autres utilisateurs |
| ZÉRO IP dans les livrables clients | Jamais dans CW Discussion ni Email |
| Confirmation explicite avant reboot ou suppression | L'agent affiche le warning et attend — jamais automatique |
| P1 à l'ouverture → escalade sans question | Pas de tentative N2 sur un P1 |
| P2 qui monte en P1 → escalade automatique | Proposée immédiatement par l'agent |
| Bloqué 20 min → l'agent propose TECH | Ne pas s'acharner seul |
| DUO bypass code → noter "BypassCode généré (code non consigné)" | Jamais le code lui-même |

---

## Questions fréquentes

**Q : Quelle différence entre IT-Assistant-N2 et IT-FrontLine ?**
FrontLine est le premier contact : il gère les appels entrants, le triage et les cas rapides N1. IT-Assistant-N2 est le coach technique N2 : il intervient quand le problème résiste, avec une profondeur plus grande sur AD, M365, postes et accès.

**Q : Quelle différence entre IT-Assistant-N2 et IT-Assistant-N3 ?**
N2 traite les incidents utilisateur : MDP, accès fichiers, imprimantes, Outlook, VPN utilisateur, poste lent. N3 prend en charge les incidents serveur : DC/AD avancé (réplication, FSMO, DNS), RDS, Hyper-V, SQL, scripts PowerShell production.

**Q : Que faire si SharePoint refuse l'accès et que le propriétaire du site ne répond pas ?**
Ne pas donner l'accès. Documenter la tentative dans CW et informer le gestionnaire du client. La confirmation écrite du propriétaire est obligatoire avant toute action.

**Q : L'agent peut-il générer des scripts PowerShell ?**
Il peut générer des scripts simples compatibles RMM (anti-erreur chaîne vide, `[AllowEmptyString()]`). Pour les scripts complexes de production (multi-serveurs, maintenance, audit), utiliser IT-Assistant-N3 ou IT-SysAdmin.

**Q : Comment utiliser /escalade si le client est encore en ligne ?**
Taper /escalade pour générer le bloc CW, colle-le dans ConnectWise avant de transférer le billet. Dis au client : "Je vous transfère à un spécialiste qui aura toutes les informations — vous aurez une réponse dans [délai]."

---

*GUIDE_UTILISATION — IT-Assistant-N2 v1.0 — MSP Intelligence AI — 2026-05-18*
