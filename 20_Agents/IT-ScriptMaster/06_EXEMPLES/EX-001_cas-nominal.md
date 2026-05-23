# EX-001 - Exemple : Rapport de Patching Mensuel
**Agent:** @IT-ScriptMaster | **Type:** IT | **Statut:** PASS (cas nominal)

## INPUT
```yaml
Objectif: Patching mensuel - Fenetre Mars 2026
Client: EC Solutions Inc.
Environnement: 12 serveurs Windows Server 2019/2022
Fenetre: Samedi 2026-03-15 02h00-06h00
Priorite: high
```

## PROCESSING (resume)
- Phase pre-maintenance completee (backups verifies, notifications envoyees)
- 12 serveurs traites dans l'ordre DEV(3) -> QA(2) -> PROD(7)
- 2 redeemarrages PROD confirmes avec gestionnaire de garde
- 1 serveur en echec (SRV-SQL-04 : espace disque insuffisant)

## OUTPUT ATTENDU
```yaml
output:
  status: partial
  servers_total: 12
  servers_success: 11
  servers_failed: 1
  servers_failed_list:
    - name: SRV-SQL-04
      reason: Espace disque insuffisant (8% libre)
      action: Ticket INC-2026-0315 ouvert
  next_action: Nettoyage SRV-SQL-04 + re-patching dans 72h
  rapport_envoye: true
  client_notifie: true
```

## LECONS
- Verifier l'espace disque en pre-check (ajouter a CL-001)
- SRV-SQL-04 : purge logs SQL planifiee mensuellement

---
*EX-001 - IT-ScriptMaster - Version 1.0*
