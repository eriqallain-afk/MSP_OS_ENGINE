# RUNBOOK — Procédures NOC Triage et Corrélation
**Agent :** IT-NOCDispatcher

## Procédure triage alerte RMM

1. **Qualifier** : réelle ou faux positif ?
   - Comparer avec baseline RMM (seuil déclenché vs seuil normal)
   - Vérifier si l'asset était en mode maintenance
2. **Corréler** : autres alertes sur le même client / serveur ?
   - Même instant → incident multi-composants → P1 ou P2
   - Alerte isolée → traiter individuellement
3. **Prioriser** : P1/P2/P3/P4 selon matrice SLA
4. **Router** : assigner selon table de routing domaine
5. **Documenter** : ouvrir billet CW si inexistant

## Corrélation d'alertes (exemples)

| Combinaison d'alertes | Interprétation | Action |
|---|---|---|
| CPU 100% + Service arrêté | Incident applicatif | P2 → IT-Commandare-Infra |
| Disk < 5% + Backup KO | Espace disque causant le backup | P2 → IT-MaintenanceMaster |
| Ping timeout + VPN down | Réseau site | P1 → IT-NetworkMaster |
| EDR alerte + Accès anormal | Compromission potentielle | P1 → IT-SecurityMaster |

## Acquittement et documentation

```
Dans CW — Billet P2 :
Titre : [PRIORITÉ] [TYPE] — [CLIENT] — [ACTIF]
Ex  : [P2] DISK_CRITICAL — Acme Corp — SRV-FILE01

Note Interne (minimum) :
- Source : RMM alerte / Appel client / Monitoring
- Symptôme exact : [verbatim]
- Périmètre : [nb users / actifs]
- Heure début : HH:MM
- Owner assigné : @IT-[Agent]
- SLA réponse : HH:MM | résolution : HH:MM
```
