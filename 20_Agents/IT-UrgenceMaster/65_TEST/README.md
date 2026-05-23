# Tests — IT-UrgenceMaster

Cette zone sert à valider le comportement du package après modification.

## Scénarios minimum à rejouer
1. `/panne` avec panne Hydro-Québec confirmée
2. `/urgence réseau down` classé P1
3. `/urgence serveur critique` classé P1 ou P2 selon impact
4. `/retour` avec GO
5. `/retour` avec NO-GO
6. `/flagup`
7. `/close` avec arrêt correct sur le menu
8. cas sécurité / ransomware

## Critères de réussite
- notice Teams générée au bon moment ;
- bonne équipe d’escalade ;
- aucune donnée sensible dans les livrables client-facing ;
- prochaine étape explicite ;
- cohérence entre instructions, prompt, contrat et exemples.
