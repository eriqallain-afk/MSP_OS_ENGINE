# CL-001 — Checklist Intervention IT-AssistanTI_FrontLine
**Agent :** IT-AssistanTI_FrontLine | **Version :** 1.1.0

---

## ✅ AVANT CHAQUE INTERVENTION

### Ticket MSPBOT
- [ ] Billet ouvert dans CW et assigné confirmé
- [ ] Priorité lue — P1 → escalade immédiate sans intervention
- [ ] Contexte du billet lu complètement avant de contacter le client
- [ ] Estimation durée faite : < 45 min → résoudre | > 45 min → planifier transfert

### Appel direct
- [ ] Billet CW ouvert ou localisé (numéro client ou nouveau)
- [ ] Client identifié (nom + entreprise)
- [ ] Problème catégorisé dans CW pendant l'écoute

---

## ✅ VÉRIFICATION IDENTITÉ (MDP/Compte uniquement)

- [ ] Identité vérifiée par l'UNE des méthodes suivantes :
  - [ ] Manager confirme en conférence téléphonique
  - [ ] Code employé interne validé (Hudu)
  - [ ] Question de sécurité préétablie (Hudu)
- [ ] Confirmation notée dans CW si refus de réinitialisation

---

## ✅ PENDANT L'INTERVENTION

- [ ] Lecture seule effectuée AVANT toute action corrective
- [ ] ⚠️ Actions destructrices (reboot, suppression) validées explicitement
- [ ] P1 détecté → escalade immédiate — aucune tentative de résolution
- [ ] Sécurité suspecte → @IT-SecurityMaster, ne pas toucher au poste
- [ ] Plusieurs users affectés (> 5) → évaluer P2 → @IT-NOCDispatcher
- [ ] Client informé à chaque étape pendant un appel

---

## ✅ CLÔTURE SI RÉSOLU

- [ ] Résolution confirmée verbalement par l'utilisateur
- [ ] `/close` généré :
  - [ ] CW Note Interne : "Prise de connaissance..." + timeline + commandes + résultats
  - [ ] CW Discussion STAR : client-safe, orientée facturation, zéro IP/commandes
- [ ] Durée de l'intervention notée

---

## ✅ AVANT TRANSFERT

- [ ] `/triage` généré et collé dans CW Note
- [ ] Client informé du transfert et du nom de l'agent/équipe qui reprend
- [ ] Agent recevant le billet a tous les éléments de contexte

---

## ✅ RÈGLES ABSOLUES — RAPPEL

| Règle | ✅ |
|---|---|
| JAMAIS de MDP dans CW ou courriel | |
| JAMAIS d'IP interne dans CW Discussion ou email client | |
| JAMAIS d'action sur un poste non mentionné dans le billet | |
| JAMAIS de tentative de résolution P1 | |
| TOUJOURS identité vérifiée avant réinitialisation MDP | |
| TOUJOURS lecture seule avant action corrective | |
