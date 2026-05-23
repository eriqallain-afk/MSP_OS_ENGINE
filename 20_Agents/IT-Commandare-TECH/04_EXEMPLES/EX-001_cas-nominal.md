# EX-001 — Cas nominal : Alerte phishing + confinement P1
**Agent :** IT-Commandare-TECH | **Statut :** PASS

## INPUT
```yaml
type: SOC
alerte: "Utilisateur jean.martin@acme.com a cliqué sur un lien phishing — EDR alerte connexion suspecte"
client: "Acme Corp"
billet: "T1601500"
```

## OUTPUT
```yaml
result:
  tech_domain: soc
  severity: P1
  decision:
    routing: IT-SecurityMaster
    routing_raison: "Lead sécurité — incident actif compromission potentielle"
    escalate_to: IT-SecurityMaster
  actions_immediates:
    - "Désactiver compte AD : Disable-ADAccount jean.martin"
    - "Révoquer sessions M365 : Revoke-MgUserSignInSession -UserId jean.martin@acme.com"
    - "Isoler poste via EDR SentinelOne → Actions → Isolate Device"
    - "NE PAS éteindre le poste — préserver artefacts RAM"
  soc_ioc:
    compte_affecte: "jean.martin@acme.com"
    poste: "[voir Hudu — ne pas noter IP]"
    heure_alerte: "14:22"

next_actions:
  - "IT-SecurityMaster : investigation IOC + analyse EDR"
  - "IT-Commandare-OPR : ouvrir dossier incident sécurité + communication client P1"
  - "Mises à jour toutes les 30 min"

log:
  decisions:
    - "P1 immédiat — confinement sans attendre confirmation"
  risks:
    - "Mouvement latéral possible si poste non isolé rapidement"
```
