# REFERENCE_MASTER_Writing-Standards-et-Metriques_V1
**Agent :** IT-TicketScribe, IT-ReportMaster, IT-KnowledgeKeeper
**Usage :** Standards de rédaction CW + définitions des métriques MSP
**Mis à jour :** 2026-03-20

---

# PARTIE 1 — STANDARDS DE RÉDACTION

## Règles absolues (tous les livrables)

```
✅ Langue : français professionnel — pas d'abréviations ambiguës
✅ Temps : passé composé pour les actions, présent pour l'état actuel
✅ Preuves : chaque action FAIT doit avoir une preuve ou [À CONFIRMER]
✅ CW Discussion : 100% client-safe — ni IPs, ni noms de serveurs internes,
   ni CVE détaillés, ni credentials
✅ Note Interne : commence TOUJOURS par "Prise de connaissance de la demande
   et consultation de la documentation du client."

⛔ Jamais : "probablement", "peut-être", "je pense que" dans une note technique
⛔ Jamais : mots de passe dans CW, Hudu, Teams ou emails
⛔ Jamais : IPs internes dans la CW Discussion ou l'email client
```

## Note Interne CW — Structure obligatoire

```
1. Prise de connaissance... (ligne obligatoire)
2. Contexte (ticket, client, assets, fenêtre)
3. Symptôme / impact
4. Timeline des actions (numérotée, avec preuves)
5. Diagnostic (cause identifiée)
6. Actions réalisées
7. Résultat et validations
8. Prochaines étapes (si applicable)
```

## CW Discussion — Règles

```
Format STAR : Situation → Tâche → Action → Résultat
Court : 3-6 lignes maximum
Facturable : décrire la valeur, pas le détail technique
Neutre : jamais de faute implicite vers le client

Mots bannis dans la Discussion :
"erreur", "bug", "problème", "anomalie" → remplacer par "comportement",
"situation à corriger", "ajustement requis"
```

---

# PARTIE 2 — MÉTRIQUES MSP

## Métriques de service

| Métrique | Définition | Formule | Cible |
|---|---|---|---|
| **MTTR** | Temps moyen de résolution | Σ(temps résolution) / nb tickets | P1 < 4h, P2 < 8h |
| **MTBF** | Temps moyen entre pannes | Période / nb incidents | ↑ = meilleur |
| **FCR** | Résolution au premier contact | Tickets résolus N1 / total × 100 | > 70% |
| **Reopen Rate** | Taux de réouverture | Tickets rouverts / fermés × 100 | < 5% |
| **SLA Compliance** | Respect des délais SLA | Tickets dans SLA / total × 100 | > 95% |
| **Uptime** | Disponibilité infrastructure | Temps opérationnel / total × 100 | > 99.5% |

## Métriques sécurité

| Métrique | Définition | Cible |
|---|---|---|
| **Patch Compliance** | % assets patchés dans les 30j | 100% patchs critiques |
| **MFA Coverage** | % utilisateurs avec MFA | 100% admins, > 90% users |
| **EDR Coverage** | % assets avec EDR actif | 100% |
| **Backup Success Rate** | % jobs backup réussis (30j) | > 98% |
| **Secure Score** | Score M365 Secure Score | > 60% |

## Calculs utiles

```powershell
# Calcul MTTR depuis CW (exemple en jours)
# (À adapter selon l'API CW ou l'export CSV)
$tickets = Import-Csv "tickets_export.csv"
$mttr = ($tickets | Where-Object {$_.Status -eq 'Closed'} |
    ForEach-Object {
        $open  = [datetime]$_.DateCreated
        $close = [datetime]$_.DateClosed
        ($close - $open).TotalHours
    } | Measure-Object -Average).Average
"MTTR moyen : $([math]::Round($mttr,1)) heures"
```
