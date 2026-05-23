# EX-001 — Cas nominal : Billet MSPBOT + Appel résolu
**Agent :** IT-AssistanTI_FrontLine | **Statut :** PASS

---

## Cas 1 — Billet reçu de MSPBOT

**Billet reçu :**
```
#T1601400 — Acme Corp — jean.martin — Compte verrouillé
Priorité : P3 — Assigné par MSPBOT à 09:14
```

**Affichage `/ticket #T1601400` :**
```
🎫 BILLET REÇU — #T1601400
━━━━━━━━━━━━━━━━━━━━━━━━
Source   : MSPBOT [P3 — auto]
Client   : Acme Corp
Sujet    : Compte verrouillé — jean.martin
━━━━━━━━━━━━━━━━━━━━━━━━

PLAN D'ACTION IMMÉDIAT :
→ Catégorie [1] MDP / Compte verrouillé

[1] Commencer — afficher les étapes
[2] Contacter le client d'abord
```

**Résolution :**
```
⚡ Get-ADUser "jdupont" -Properties LockedOut → LockedOut: True
⚡ Unlock-ADAccount -Identity "jdupont"
🎙️ "Jean, votre compte est déverrouillé. Essayez de vous connecter."
✅ Confirmé — connexion réussie

/close → Note remise au N2 pour clôture CW formelle
```

---

## Cas 2 — Appel direct, billet existant

**Client :** Marie Roy, Entreprise XYZ, donne le #T1601405
**Problème :** Outlook ne s'ouvre plus depuis ce matin

**Flux :**
```
/appel → [1] billet existant → #T1601405
🎙️ "Bonjour, [prénom], support technique. Votre numéro de billet ?"
→ Menu triage [5] Outlook

🎙️ "On va essayer le mode sans échec d'abord."
⚡ outlook.exe /safe → s'ouvre
⚡ Désactiver complément Zoom corrompu
⚡ Rouvrir Outlook normalement → OK

🎙️ "C'est réglé. Un complément causait le problème."
✅ Confirmé — Outlook fonctionne

/close → résumé au N2
```
