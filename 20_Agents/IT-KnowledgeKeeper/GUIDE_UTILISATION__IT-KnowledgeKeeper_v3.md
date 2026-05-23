# Guide d'utilisation — @IT-KnowledgeKeeper (v3.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-KnowledgeKeeper ?

**IT-KnowledgeKeeper est la mémoire de savoir-faire de l'équipe.**

Il ne remplace pas ConnectWise (ce qui s'est passé sur un ticket) ni Hudu (ce qui existe chez le client).
Il capture **comment résoudre** un problème — reproductible par n'importe quel technicien, même celui qui n'était pas là.

| Outil | Ce qu'il stocke | Exemple |
|---|---|---|
| ConnectWise | Ce qui s'est passé | « Intervention chez ABC le 15 mai — reboot DC01 » |
| Hudu | Ce qui existe chez le client | « DC01 : Windows Server 2022, IP 10.x.x.x » |
| **KnowledgeKeeper** | **Comment résoudre** | « Cause : probe RMM en conflit Veeam. Solution : étapes 1-4. » |

---

## Quand l'utiliser ?

- Tu viens de résoudre un incident qui a pris > 30 min
- C'est le 2e ou 3e fois que tu vois ce problème
- Tu as trouvé une cause non évidente (piège, comportement inattendu)
- Tu veux chercher si quelqu'un a déjà résolu ce problème avant toi
- Tu veux signaler un pattern au routeur (RouterIA amélioration)

---

## Les commandes principales

### `/kb` — Créer un article KB

La commande principale. Tu fournis un brief de l'incident résolu, l'agent produit un article complet.

**Usage :**
```
/kb
ticket_id: #77010
client: Otto Inc
type_incident: Échec backup Veeam
systeme: Veeam 12.1 / ESXi 8.0
symptomes:
  - Jobs Veeam en échec depuis 3 semaines
  - Erreur : "Failed to retrieve object hierarchy"
cause_racine: Probe RMM générait du trafic non-SSH sur port SSH ESXi — timeouts hostd
actions_realisees:
  - Corrigé le type de check RMM (HTTP → SSH correct)
  - Appliqué rate limit sur checks VMware pendant fenêtre backup
  - Relancé job Veeam manuellement
validations:
  - Plus d'erreur "invalid protocol identifier"
  - Job Veeam réussi 24h après correctif
resultat_final: Résolu
recurrence: non
niveau_technicien: N2
```

**Ce que tu obtiens :**
- Titre SEO : `KB-VEEAM-001 — Veeam : Échecs "Failed to retrieve object hierarchy" — Probe RMM VMware`
- Cause racine confirmée (pas le symptôme — la vraie cause)
- Étapes reproductibles avec validations
- Pièges à éviter
- Fichier prêt à déposer dans `IT-SHARED/90_KB/`

> **Astuce :** Si tu utilises IT-TicketScribe, la commande `/kb_brief` génère exactement ce format — copie-colle directement dans `/kb`.

---

### `/kb-quick` — Article court (N1)

Pour les incidents simples où la solution est rapide et évidente.

**Usage :**
```
/kb-quick
Mise à jour Windows bloquée sur poste W11 — erreur 0x800f0831.
Solution : wuauclt /detectnow + net stop/start wuauserv + redémarrage.
Résolu en 10 min.
```

**Ce que tu obtiens :** Article 5 sections — Symptôme, Cause, Solution rapide, Validation, Piège.

---

### `/search` — Chercher dans la KB

Avant d'ouvrir un billet ou de commencer à diagnostiquer, cherche si ça a déjà été résolu.

**Usage :**
```
/search veeam probe rmm backup échec
/search windows update manquant domain controller
/search exchange hybrid certificate expired
```

**Ce que tu obtiens :**
- Les articles KB correspondants avec résumé et temps estimé
- Si rien trouvé → suggestion d'utiliser `/kb` après résolution

---

### `/pattern` — Détecter les récurrences

Utile en fin de semaine ou de mois pour identifier ce qui revient souvent et qui devrait être documenté.

**Usage :**
```
/pattern
Voici les incidents de la semaine :
- #77010 Veeam échec — backup / ESXi
- #77023 Veeam échec — backup / ESXi (autre client)
- #77041 Probe RMM — faux positifs VMware
- #77088 Backup Datto échec — agent offline
- #76998 Backup Veeam — réplication KO
```

**Ce que tu obtiens :**
- Patterns identifiés avec fréquence
- Recommandation : créer KB ou runbook
- Si un pattern n'a pas d'intent dans RouterIA → suggestion `/suggest-intent`

---

### `/runbook` — Créer un runbook de procédure

Pour les procédures complexes ou multi-étapes qui doivent être reproductibles exactement.

**Usage :**
```
/runbook veeam-probe-conflit-rmm
Procédure complète pour diagnostiquer et corriger les conflits entre probe RMM et jobs Veeam sur ESXi.
Niveau N2. Inclure PRECHECK script, étapes diagnostic, correctif RMM, validation Veeam.
```

---

### `/audit` — Réviser un article KB existant

Pour améliorer un article déjà dans la KB.

**Usage :**
```
/audit KB-VEEAM-001
```

**Ce que tu obtiens :** Score /10, points forts, améliorations suggérées, verdict PUBLIER / ENRICHIR / REFONDRE.

---

### `/suggest-intent` — Améliorer le routage

Quand tu viens de créer une KB sur un nouveau type de problème et que tu penses que RouterIA devrait le reconnaître.

**Usage :**
```
/suggest-intent KB-VEEAM-001
```

**Ce que tu obtiens :**
- Suggestion structurée d'un nouvel intent pour `MASTER_DISPATCH_INDEX_V2.yaml`
- Soumis automatiquement à IT-OPS-QAMaster → validation EA → RouterIA amélioré

> C'est comme ça que la plateforme apprend. Chaque KB bien rédigée peut améliorer le routage de tous les techniciens.

---

### `/index` — Voir tous les articles KB

Affiche l'index complet par domaine et niveau.

---

## Flux de travail recommandé

### Après un incident résolu

```
1. Incident résolu dans CW
        ↓
2. /search — quelqu'un l'a déjà documenté ?
   OUI → /audit [kb-id] si incomplet
   NON → continuer
        ↓
3. /kb [brief de l'intervention]
   OU /kb-quick si N1 simple
        ↓
4. Déposer le fichier dans IT-SHARED/90_KB/
        ↓
5. (Optionnel) /suggest-intent si nouveau type de problème
```

### En fin de semaine / mois

```
1. Rassembler les tickets de la période
        ↓
2. /pattern [liste des tickets]
        ↓
3. Créer les KB manquantes identifiées par /pattern
        ↓
4. /suggest-intent si pattern → intent manquant détecté
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO IP dans les articles KB | Réutilisabilité — chaque client a ses propres IPs |
| ZÉRO credential | Sécurité — Passportal uniquement |
| Cause racine ≠ symptôme | Un article qui dit "Veeam en échec → relancer Veeam" ne sert à rien. La VRAIE cause doit y être. |
| `[À VALIDER]` si tu n'es pas sûr | Mieux qu'une information fausse dans la KB |
| Titre = Système + Symptôme + Solution | Pour que /search fonctionne bien |

---

## Exemples de briefs — du plus simple au plus complet

### Brief minimal (KB_QUICK)
```
/kb-quick
Imprimante réseau disparue après mise à jour Windows — W11 22H2.
Cause : pilote générique remplacé. Fix : réinstaller pilote fabricant.
```

### Brief standard (KB_ARTICLE)
```
/kb
ticket_id: #77023
systeme: Windows Server 2019 / AD DS
symptomes:
  - GPO non appliquée sur 3 postes clients
  - gpresult /r : "Access denied"
cause_racine: Compte machine sorti de l'OU correcte lors d'une réorg AD
actions_realisees:
  - Identifié l'OU source via ADUC
  - Déplacé les comptes machine dans l'OU correcte
  - Forcé gpupdate /force
validations:
  - gpresult /r OK sur les 3 postes
resultat_final: Résolu
niveau_technicien: N2
```

### Brief depuis IT-TicketScribe
```
[Coller le YAML complet généré par /kb_brief de IT-TicketScribe]
```

---

## Où vont les articles créés ?

```
IT-SHARED/90_KB/
├── KB-VEEAM-001__Probe-RMM-VMware.md
├── KB-WU-001__Windows-Update-Missing-DC.md
└── [Nouvel article créé]__[Slug].md

IT-SHARED/10_RUNBOOKS/
└── [Runbooks créés par /runbook]
```

---

## Questions fréquentes

**Q : Quelle différence avec IT-ClientDocMaster ?**
ClientDocMaster crée la fiche technique du client dans Hudu (infrastructure, contacts, accès).
KnowledgeKeeper crée les procédures de résolution réutilisables pour tous les clients.

**Q : Est-ce que je dois créer une KB pour chaque ticket ?**
Non. Seulement si : incident > 30 min, récurrent, cause non évidente, ou procédure nouvelle.

**Q : Qui valide les KB avant publication ?**
Toi-même ou un N2/N3. L'agent produit l'article — tu le révises et le déposes dans `IT-SHARED/90_KB/`.

**Q : Comment améliorer un article déjà publié ?**
Utilise `/audit [kb-id]` puis fournis les nouvelles informations. L'agent génère la version améliorée.

**Q : /suggest-intent fait quoi exactement ?**
Il analyse l'article KB et propose un nouvel intent pour le routeur (RouterIA). Soumis à QAMaster → validé par EA → RouterIA améliore son index. Tu n'as pas besoin de toucher les fichiers d'index — l'agent gère la suggestion.

---

*GUIDE_UTILISATION — IT-KnowledgeKeeper v3.0 — MSP Intelligence AI — 2026-05-18*
