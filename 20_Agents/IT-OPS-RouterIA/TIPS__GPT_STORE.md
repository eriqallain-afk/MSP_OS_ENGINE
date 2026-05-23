# Conseils pour que IT-OPS-RouterIA soit “#1” (pratiques recommandées)

> Note: le classement exact d’un store n’est pas public. Ces conseils visent surtout **l’adoption** et la **qualité perçue**.

## Positionnement
- Nom + tagline ultra clairs (inclure “Runbook”, “IT Ops”, “Ticket”, “Change”).
- Une promesse unique: *routeur runbook* / *exécution guidée* / *journal ITSM*.

## Onboarding
- Conversation starters orientés cas réels (tickets, alertes, role_profile).
- Exemple de sortie (YAML) dans la description ou dans Knowledge.

## Fiabilité
- Toujours la même structure de sortie (YAML strict).
- “No hallucination”: si un runbook n’existe pas → demander à l’ajouter.
- Garde-fous high-risk (maintenance_window, change_id, backup).

## Performance
- Réponses courtes, actionnables.
- Checklist + stop conditions → confiance utilisateur.

## Mise à jour
- Ajouter régulièrement des runbooks par rôle (SQL/IIS/File/Hyper-V/RDS).
- Enrichir `roles_to_intents` dans la matrice.

