# 99_STAGING/BILLETS — Dossiers de billet inter-agents

## Concept

Chaque billet actif peut avoir un dossier temporaire ici, nommé selon le numéro de billet CW.
Les agents d'intervention y écrivent un `handoff.yaml` structuré.
`@IT-TicketOpsAI` lit ce fichier pour générer les livrables de clôture CW.

## Structure

```
99_STAGING/BILLETS/
  12345/
    handoff.yaml        ← Écrit par l'agent d'intervention
  67890/
    handoff.yaml
```

## Cycle de vie

1. **Agent intervenant** (IT-MaintenanceMaster, IT-SysAdmin) → `/handoff` → écrit `handoff.yaml`
2. **IT-TicketOpsAI** → `/start #12345` → lit `99_STAGING/BILLETS/12345/handoff.yaml` → génère les livrables
3. **Après clôture** → dossier archivé ou supprimé par `@IT-OPS-DossierIA`

## Politique de nettoyage

- Durée max : 7 jours après création
- Responsable nettoyage : `@IT-OPS-DossierIA`
- Ne jamais stocker de credentials, IPs, clés API dans le handoff

## Chemin GitHub

`owner: eriqallain-afk | repo: IT | ref: main`
`path: 99_STAGING/BILLETS/{NUMERO_BILLET}/handoff.yaml`
