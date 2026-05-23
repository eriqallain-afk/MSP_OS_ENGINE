# EX-001 — Cas nominal : Patching mensuel + estimation + clôture
**Agent :** IT-MaintenanceMaster v3.0 | **Statut :** PASS

---

## INPUT : Estimation avant la fenêtre
```
/estimé — Patching mensuel Acme Corp — 4 serveurs Windows Server 2022
```

## OUTPUT /estimé
```yaml
estimation:
  client: "Acme Corp"
  type: "fenetre_maintenance"
  taches:
    - no: 1
      description: "Vérification backups + snapshots pre-patch"
      duree_min: 15
      duree_max: 30
      risques: "Backup KO = report maintenance"
    - no: 2
      description: "Patching Windows — 4 serveurs"
      duree_min: 90
      duree_max: 150
      risques: "Reboot prolongé si KB cumulatifs"
    - no: 3
      description: "Validation post-patch — tous serveurs"
      duree_min: 20
      duree_max: 40
  resume:
    fenetre_recommandee: "4h (22h00 → 02h00)"
    prerequis_globaux:
      - "Approbation client par écrit"
      - "Backups vérifiés"
    note_client: "Maintenance planifiée pour l'application des mises à jour
      de sécurité mensuelles. Durée estimée : 3 à 4 heures. Impact : aucun
      pendant la nuit. Confirmation requise avant le début."
```

---

## INPUT : /start_maint
```
/start_maint — Billet #T1601200 — Acme Corp
4 serveurs : SRV-DC01, SRV-FILE01, SRV-SQL01, SRV-RDS01
Fenêtre : 22h00 → 02h00
```

## OUTPUT /start_maint (extrait)
```yaml
result:
  ordre_traitement:
    - "SRV-FILE01 (non-critique)"
    - "SRV-SQL01 (applicatif)"
    - "SRV-RDS01 (accès distant)"
    - "SRV-DC01 (DC — en dernier)"
  snapshots_a_creer:
    - "@T1601200_Preboot_SRV-DC01_SNAP_20260322_2100"
    - "@T1601200_Preboot_SRV-FILE01_SNAP_20260322_2100"
  teams_proposition: "🔧 Acme Corp — Maintenance en cours | 22h00 → 02h00 | Tous les serveurs"
```

---

## INPUT : /check après precheck DC01
```
/check
Hostname: SRV-DC01 | LastBoot: 2026-02-15 | PendingReboot: False
C: 67% libre | RAM libre: 4.2 GB
```

## OUTPUT /check
```yaml
analyse:
  statut_global: "OK"
  elements:
    - element: "Espace disque C:"
      valeur: "67% libre"
      statut: "✅ Normal"
    - element: "PendingReboot"
      valeur: "False"
      statut: "✅ OK — pas de reboot en attente avant le patch"
    - element: "Uptime"
      valeur: "35 jours"
      statut: "✅ Acceptable"
prochaine_action: "Créer snapshot Preboot → lancer patching"
```

---

## /close — Sélection [1+2]

**CW Note Interne :**
```
Prise de connaissance de la demande et consultation de la documentation du client.
Billet #T1601200 — Patching mensuel Acme Corp — 4 serveurs.
Fenêtre 22:00-01:45. Ordre : SRV-FILE01 → SRV-SQL01 → SRV-RDS01 → SRV-DC01.
Snapshots Preboot créés sur tous les serveurs avant le début.
4 serveurs patchés avec succès. Reboots confirmés. Tous les services opérationnels.
Snapshots Postpatch créés. Monitoring retourné au vert à 01:47.
```

**CW Discussion STAR :**
```
Application des mises à jour de sécurité mensuelles planifiées sur les serveurs.
Toutes les mises à jour ont été appliquées avec succès et tous les services
sont opérationnels. Aucun impact constaté.
```
