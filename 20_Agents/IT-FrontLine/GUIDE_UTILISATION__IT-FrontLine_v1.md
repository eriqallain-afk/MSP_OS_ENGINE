# Guide d'utilisation — @IT-FrontLine (v1.0)
> **Pour :** Techniciens N1/N2 MSP — premier contact client
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-FrontLine ?

**IT-FrontLine est le point d'entrée de toute demande d'assistance MSP.**

Il gère deux sources de travail simultanément : les appels directs entrants et les billets MSPBOT poussés par priorité. Dans les deux cas, il qualifie, triage, résout ce qui est de niveau N1/N2, et structure le transfert si l'intervention dépasse son périmètre.

| Source | Description | Commande |
|---|---|---|
| Appel direct | Client appelle en direct — guidage temps réel | `/appel` |
| Billet MSPBOT | Billet poussé automatiquement par priorité | `/ticket #XXXXX` |

**Ce qu'il fait :**
- Accueil client avec phrases prêtes à dire (mode appel)
- Triage P1 à P4 structuré avec matrice SLA
- Résolution N1/N2 : MDP, comptes, accès, imprimantes, Outlook, VPN, postes
- Escalade structurée vers N2/N3 selon le domaine
- Clôture CW complète : Note Interne, Discussion, Email client, notice Teams

**Ce qu'il ne fait PAS :**
- Il ne tente jamais de résolution solo sur un P1 — escalade immédiate obligatoire
- Il ne gère pas les incidents d'infrastructure, d'architecture ou de serveurs
- Il ne traite pas les incidents de sécurité active (ransomware, breach)

---

## Quand l'utiliser ?

- Un client appelle en direct pour un problème IT
- MSPBOT t'a poussé un billet N2 et tu dois agir rapidement
- Tu dois qualifier un incident avant de le transférer
- Tu veux fermer proprement un billet avec tous les livrables CW
- Tu as besoin d'une notice Teams pour le NOC avant de commencer

**Distinction avec les autres agents de support :**

| Agent | Niveau | Utiliser quand |
|---|---|---|
| **IT-FrontLine** | N1/N2 | Premier contact — appels + billets entrants, MDP, imprimantes, Outlook, VPN simple |
| IT-Assistant-N2 | N2 | Problème résiste au N1 — AD avancé, M365, postes complexes |
| IT-Assistant-N3 | N3 | Architecture, DC/AD, RDS, Hyper-V, SQL, scripts production |
| IT-SysAdmin | Senior | Admin système : patching, serveurs, virtualisation, infrastructure complète |

---

## Les commandes principales

### `/appel` — Démarrer un appel entrant

La commande principale pour les appels directs. Elle lance le script d'accueil et le menu de triage en temps réel, avec deux flux simultanés : ce que tu **dis** au client et ce que tu **fais** en parallèle.

**Usage :**
```
/appel
```

**Ce que tu obtiens :**
```
📞 APPEL ENTRANT
━━━━━━━━━━━━━━━━━━━━━━━━

Client a un numéro de billet ?

[1] Oui — il donne son numéro CW
[2] Non — créer maintenant
```

Puis, selon le problème identifié, un menu de triage avec 11 catégories + urgence P1 :
```
[1] Mot de passe / compte verrouillé
[2] Accès refusé (dossier, partage, application)
[3] Lecteur réseau manquant
[4] Imprimante
[5] Outlook — erreur, n'ouvre pas, sync KO
...
[P] URGENCE — service critique, plusieurs users
```

Chaque catégorie produit les étapes concrètes avec les commandes PowerShell à exécuter.

---

### `/ticket #XXXXX` — Traiter un billet MSPBOT

Pour les billets reçus automatiquement de MSPBOT. Colle le numéro ou le contenu complet du billet.

**Usage :**
```
/ticket #44002
```

ou en collant le contenu :
```
/ticket
Client : Dupont Construction
Sujet : Imprimante réseau hors ligne depuis ce matin
Priorité : P3
```

**Ce que tu obtiens :**
```
🎫 BILLET N2 — #44002
━━━━━━━━━━━━━━━━━━━━━━━━
Source    : MSPBOT [P3 — auto]
Client    : Dupont Construction
Sujet     : Imprimante réseau hors ligne
━━━━━━━━━━━━━━━━━━━━━━━━

PLAN D'ACTION :
[Étapes de diagnostic imprimante]

Temps estimé : 15 min

[1] Commencer — afficher les étapes complètes
[2] Contacter le client d'abord
[3] Ce billet dépasse mon scope → transférer
```

---

### `/triage` — Note de qualification avant transfert

À utiliser avant tout transfert vers N2, N3 ou un agent spécialisé. Produit une note structurée à coller dans ConnectWise.

**Usage :**
```
/triage
```

**Ce que tu obtiens :**
```
📋 NOTE DE TRIAGE CW
━━━━━━━━━━━━━━━━━━━━━━━━
Source      : Appel direct | Billet MSPBOT
Billet      : #44002
Client      : Dupont Construction
Utilisateur : Jean Martin
Heure       : 09:42

Problème rapporté :
[Symptôme exact — pas interprété]

Catégorie   : Imprimante
Priorité    : P3
Nb users    : 1

Actions tentées :
□ Redémarrage spooler — file toujours bloquée

Résolution   : Non résolu
Transféré vers : @IT-NetworkMaster
━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### `/close` — Clôture complète du billet

Sur `/close`, un menu s'affiche — l'agent attend ton choix avant de générer quoi que ce soit.

**Usage :**
```
/close
```

**Ce que tu obtiens (menu) :**
```
📋 Clôture — Billet #44002
━━━━━━━━━━━━━━━━━━━━━━━━
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[A] Tout (1+2+3)

Que veux-tu générer ?
```

Choisis [A] pour tout générer d'un coup. La CW Discussion commence toujours par la phrase obligatoire :
```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.
```

Règle Discussion CW : jamais d'IP, jamais de noms de serveurs, minimum 4 puces dans les travaux effectués.

---

### `/status` — Résumé de l'intervention en cours

Utile pour faire le point rapidement pendant une intervention.

**Usage :**
```
/status
```

**Ce que tu obtiens :**
```
📊 STATUS
━━━━━━━━━━━━━━━━━━━━━━━━
Billet     : #44002
Client     : Dupont Construction
Source     : Appel | MSPBOT
Catégorie  : Imprimante
Priorité   : P3
Durée      : 12 min
Statut     : En cours
Prochaine  : Réinstaller driver fabricant
```

---

## Flux de travail recommandé

### Mode appel entrant

```
1. Client appelle
       ↓
2. /appel — script d'accueil + identification + numéro billet
       ↓
3. Menu triage → catégorie identifiée
       ↓
4. Arbre de résolution N1/N2 — étapes concrètes affichées
   └─ P1 détecté → escalade immédiate (< 5 min)
   └─ P2 → @IT-NOCDispatcher si multi-users (< 10 min)
       ↓
5. Résolu → /close [A] — tous les livrables CW
   Non résolu → /triage + escalade vers l'agent approprié
       ↓
6. Notice Teams générée automatiquement à /close si maintenance
```

### Mode billet MSPBOT

```
1. MSPBOT pousse le billet
       ↓
2. /ticket #XXXXX — plan d'action immédiat
       ↓
3. [1] Commencer les étapes
       ↓
4. Résolu → /close
   Non résolu → /triage + [3] Transférer
```

### Matrice de décision escalade

| Situation | Destination | Délai |
|---|---|---|
| P1 — ransomware, breach, réseau site down | @IT-Commandare-NOC ou @IT-SecurityMaster | Immédiat |
| P1 — serveur critique inaccessible | @IT-Commandare-Infra | < 5 min |
| P2 — > 5 users impactés | @IT-NOCDispatcher | < 10 min |
| MFA, Exchange, Entra | @IT-CloudMaster | Immédiat |
| Téléphonie, SIP | @IT-VoIPMaster | Immédiat |
| VPN complexe, firewall | @IT-NetworkMaster | Immédiat |
| Sécurité, comportement suspect | @IT-SecurityMaster | Immédiat |
| N3 technique — serveur, profil, AD avancé | @IT-Assistant-N3 | Immédiat |

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO MDP capturé ou transmis | Passportal uniquement — sans exception |
| Identité vérifiée avant réinitialisation MDP | Appel ou manager en conférence |
| P1 détecté → escalade — aucune tentative solo | Le FrontLine ne résout pas les P1 |
| `[À CONFIRMER]` si info non confirmée | Jamais d'invention — 1 question max |
| Notice Teams dès que le type d'intervention est connu | Le NOC doit être informé avant la fin |
| Jamais d'IP dans la CW Discussion | Visible sur la facture client |
| Minimum 4 puces dans les travaux effectués (CW Discussion) | Standard de facturation MSP |
| Processus inconnu dans le Gestionnaire des tâches | → @IT-SecurityMaster immédiatement |
| Règles Outlook ForwardTo externe | → @IT-SecurityMaster immédiatement |

---

## Questions fréquentes

**Q : Quelle différence entre IT-FrontLine et IT-Assistant-N2 ?**
FrontLine est le premier contact — il gère les appels entrants, le triage et les résolutions N1/N2 standard (MDP, imprimantes, Outlook simple, VPN utilisateur). IT-Assistant-N2 est le coach technique : il intervient quand le problème résiste au FrontLine, avec plus de profondeur sur AD, M365 et les postes complexes.

**Q : Quand escalader vers N3 vs N2 ?**
N2 : compte AD, accès fichiers, Outlook, VPN utilisateur, poste lent. N3 : serveur impliqué, profil corrompu profond, bug applicatif lié à la base de données, configuration serveur.

**Q : La notice Teams est obligatoire pour tous les billets ?**
Oui — directive du NOC. L'agent propose automatiquement de la générer dès que le type d'intervention est connu. Elle peut être générée maintenant ou à /close.

**Q : Que faire si le client ne peut pas confirmer son identité pour un reset MDP ?**
Répondre : "Je ne peux pas réinitialiser sans confirmation d'identité. Votre gestionnaire peut nous appeler en conférence et on règle ça immédiatement." — noter la tentative dans CW.

**Q : Comment éviter les erreurs sur les scripts PowerShell générés ?**
Utiliser `Write-Host " "` (avec espace) plutôt que `Write-Host ""` — les chaînes vides causent des erreurs dans N-able / CW RMM. L'agent applique cette règle automatiquement.

---

*GUIDE_UTILISATION — IT-FrontLine v1.0 — MSP Intelligence AI — 2026-05-18*
