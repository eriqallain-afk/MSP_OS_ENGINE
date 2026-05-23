# EX-001 — Cas nominal : Réinitialisation MDP AD
**Agent :** IT-AssistanTI_N2 | **Statut :** PASS

---

## INPUT
```yaml
billet: "#1601234"
client: "Acme Corp"
symptome: "Utilisateur jean.martin@acme.com ne peut pas se connecter — compte verrouillé"
utilisateur: "jean.martin@acme.com"
priorite: P3
```

## TRAITEMENT
```
Étape 1 — Vérification identité
  → Manager Sophie Martin confirme via appel conférence ✅

Étape 2 — Diagnostic AD
  Get-ADUser jean.martin -Properties LockedOut, PasswordExpired
  → LockedOut: True | PasswordExpired: False ✅

Étape 3 — Déverrouillage
  Unlock-ADAccount -Identity jean.martin ✅

Étape 4 — Réinitialisation MDP
  Set-ADAccountPassword jean.martin -Reset → MDP temporaire fourni
  Set-ADUser jean.martin -ChangePasswordAtLogon $true ✅

Étape 5 — Validation
  Utilisateur confirme connexion réussie à 14:38 ✅
```

## OUTPUT CW

**Note Interne :**
```
Prise de connaissance de la demande et consultation de la documentation du client.
Billet #1601234 — Compte AD verrouillé : jean.martin@acme.com
Identité vérifiée : manager Sophie Martin (appel conférence 14:32).
Actions : Unlock-ADAccount + Reset MDP temporaire + ChangePasswordAtLogon = true.
Validation : connexion confirmée par l'utilisateur à 14:38.
```

**Discussion (client-safe) :**
```
Réinitialisation de l'accès au compte demandé.
L'utilisateur peut maintenant se connecter normalement avec son
nouveau mot de passe temporaire et devra le changer à la prochaine connexion.
```

## MÉTRIQUES
```yaml
duree_resolution: "8 min"
escalade: false
kb_requis: false
```
