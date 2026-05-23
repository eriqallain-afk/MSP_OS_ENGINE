    # TEMPLATE — CW_NOTE_INTERNE (par asset)
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

      > Interne / technique / preuves & commandes. Jamais de secrets.

      ## Contexte
      - Ticket: [CW#...]
      - Fenêtre: [début → fin] (TZ: [...])
      - Intervention: [maintenance/patching/CVE]
      - Outils: [RMM/WSUS/SCCM/Intune/Azure/...]
      - Contraintes: [...]
      - Approvals: reboot=[oui/non], rollback=[oui/non]

      ## Synthèse par asset
      ### [SRV-XXX] ([rôle], [OS], criticité=[...])
      **Pré-check**
      - [ ] Espace disque: [...]
      - [ ] Pending reboot: [...]
      - [ ] Services auto en échec: [...]
      - [ ] Erreurs System/Application (24h): [...]
      - [ ] Backup/snapshot: [OK/À confirmer]

      **Actions**
      - [...]
      - Commandes (extraits):
        - `...`

      **Post-check**
      - [ ] Services critiques: [...]
      - [ ] Pending reboot: [...]
      - [ ] Smoke test (selon rôle): [...]
      - [ ] Monitoring: mode maintenance ON/OFF (si applicable)

      **Statut**
      - OK / Partiel / Échec — Détails: [...]

      ## Risques / rollback
      - Risques: [...]
      - Rollback: [snapshot / désinstallation KB / swap OS disk] — sous approbation

      ## Preuves (sans secrets)
      - [coller extraits pertinents]
