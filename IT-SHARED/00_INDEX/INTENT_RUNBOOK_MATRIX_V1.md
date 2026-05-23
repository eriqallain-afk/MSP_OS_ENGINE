# INTENT_RUNBOOK_MATRIX_V1 - IT-SHARED

Source of truth: mapping intent to runbook/playbook for IT-OPS-RouterIA.
Format: Markdown + YAML block.

```yaml
version: 1
owner: IT-SHARED

defaults:
  discovery_intent_id: it.discovery.server_role

  role_profile_schema:
    required_fields: [server_name, detected_roles, role_confidence]
    roles_vocab:
      - domain_controller
      - sql_server
      - iis
      - file_server
      - hyperv
      - rds
      - dns
      - dhcp

roles_to_intents:
  domain_controller: it.patching.dc.windows_updates_missing

matrix:
  - intent_id: it.discovery.server_role
    title: "Server role discovery"
    match_hints:
      - "server"
      - "srv"
      - "hostname"
      - "role"
      - "unknown role"
      - "triage"
      - "precheck"
      - "RMM detected"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__SERVER_ROLE_DISCOVERY.md"
    playbook_id: "IT_PB__ROLE_DISCOVERY
    risk_level: low
    required_inputs:
      - server_name
      - access_method
    outputs:
      - role_profile
      - suggested_next_intent_id

  - intent_id: it.patching.dc.windows_updates_missing
    title: "DC patching - Windows Updates missing and reboot required"
    match_hints:
      - "Windows update missing"
      - "updates missing"
      - "patch missing"
      - "reboot required"
      - "domain controller"
      - "RMM"
      - "WSUS"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOK__DC_PATCHING_PRECHECK.md"
    playbook_id: "IT_PB__DC_PATCHING"
    risk_level: high
    required_inputs:
      - server_name
      - maintenance_window
      - change_id
    outputs:
      - runbook_card
      - next_questions

  - intent_id: it.backup.restore.test.trimestriel
    title: "Test de restauration trimestriel / quarterly restore test"
    match_hints:
      - "test de restauration"
      - "restore test"
      - "quarterly restore"
      - "test trimestriel"
      - "DR test"
      - "test backup"
      - "tester la restauration"
      - "valider la restauration"
      - "RTO RPO test"
      - "test reprise"
      - "conformité backup"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Restore_Test_Trimestriel_V1.md"
    playbook_id: null
    risk_level: low
    required_inputs:
      - client_name
      - trimestre
      - scenario_type
      - backup_product
    outputs:
      - runbook_card
      - rapport_trimestriel

  - intent_id: it.backup.status.validation
    title: "NOC backup status validation"
    match_hints:
      - "Valider statut des sauvegardes"
      - "backup status"
      - "Backup Monitor"
      - "Backup Radar"
      - "No Result"
      - "Veeam"
      - "Datto"
      - "Keepit"
      - "SaaS Backup"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Validation_Statut_Sauvegardes_V1.md"
    playbook_id: "IT_PB__BACKUP_STATUS_VALIDATION"
    risk_level: medium
    required_inputs:
      - backup_product
      - backup_job_name
      - alert_status
    outputs:
      - runbook_card
      - next_questions

  - intent_id: it.wks.poste.lent
    title: "Poste de travail lent / performance dégradée"
    match_hints:
      - "poste lent"
      - "ordinateur lent"
      - "rame"
      - "CPU élevé"
      - "RAM pleine"
      - "disque 100%"
      - "slow computer"
      - "performances"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Poste_Lent_V1.md"
    playbook_id: null
    risk_level: low
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.login.impossible
    title: "Impossible de se connecter — Windows / M365 / compte"
    match_hints:
      - "ne peut pas se connecter"
      - "compte verrouillé"
      - "mot de passe incorrect"
      - "password locked"
      - "can't login"
      - "session bloquée"
      - "profil de service utilisateur"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Login_V1.md"
    playbook_id: null
    risk_level: medium
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.outlook.probleme
    title: "Problème Outlook / M365 messagerie client"
    match_hints:
      - "outlook ne démarre pas"
      - "outlook plante"
      - "emails ne se synchronisent pas"
      - "invite mot de passe outlook"
      - "recherche outlook"
      - "profil outlook corrompu"
      - "ost outlook"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Outlook_V1.md"
    playbook_id: null
    risk_level: low
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.teams.audio.video
    title: "Problème Teams / audio-vidéo réunion"
    match_hints:
      - "teams ne fonctionne pas"
      - "pas de son teams"
      - "micro ne fonctionne pas"
      - "caméra non détectée"
      - "teams plante"
      - "ne peut pas rejoindre réunion"
      - "teams lent"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Teams_AV_V1.md"
    playbook_id: null
    risk_level: low
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.imprimante.client
    title: "Imprimante ne fonctionne pas — côté poste client"
    match_hints:
      - "imprimante n'imprime pas"
      - "file d'attente bloquée"
      - "spooler"
      - "imprimante hors ligne"
      - "printer not working"
      - "impossible d'imprimer"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Imprimante_V1.md"
    playbook_id: null
    risk_level: low
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.partage.reseau
    title: "Lecteur réseau / partage SMB inaccessible"
    match_hints:
      - "lecteur réseau disparu"
      - "partage réseau"
      - "lecteur P"
      - "accès refusé partage"
      - "network drive missing"
      - "UNC path"
      - "SMB inaccessible"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Partage_Reseau_V1.md"
    playbook_id: null
    risk_level: low
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.vpn.client
    title: "VPN client ne fonctionne pas"
    match_hints:
      - "vpn ne se connecte pas"
      - "vpn déconnecte"
      - "accès distant impossible"
      - "GlobalProtect"
      - "AnyConnect"
      - "FortiClient"
      - "télétravail vpn"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-VPN_Client_V1.md"
    playbook_id: null
    risk_level: low
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.alerte.av
    title: "Alerte antivirus / comportement suspect sur poste"
    match_hints:
      - "alerte antivirus"
      - "virus détecté"
      - "comportement suspect"
      - "malware"
      - "AV alert"
      - "poste infecté"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Alerte_AV_V1.md"
    playbook_id: null
    risk_level: high
    required_inputs:
      - user_name
      - hostname
      - alert_name
    outputs:
      - runbook_card
      - escalade_securitymaster

  - intent_id: it.wks.profil.corrompu
    title: "Profil utilisateur corrompu ou temporaire"
    match_hints:
      - "profil corrompu"
      - "profil temporaire"
      - "paramètres disparaissent"
      - "service profil utilisateur"
      - "ntuser.dat"
      - "profil .bak"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Profil_Corrompu_V1.md"
    playbook_id: null
    risk_level: medium
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.onboarding
    title: "Onboarding nouveau poste de travail"
    match_hints:
      - "nouveau poste"
      - "déploiement poste"
      - "onboarding poste"
      - "validation poste"
      - "remise poste"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Onboarding_Poste_V1.md"
    playbook_id: null
    risk_level: low
    required_inputs:
      - user_name
      - hostname
    outputs:
      - runbook_card

  - intent_id: it.wks.offboarding
    title: "Offboarding employé — poste et compte"
    match_hints:
      - "départ employé"
      - "offboarding"
      - "wipe poste"
      - "désactiver compte départ"
      - "récupérer poste"
      - "effacement sécurisé"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Offboarding_V1.md"
    playbook_id: null
    risk_level: high
    required_inputs:
      - user_name
      - hostname
      - manager_authorization
    outputs:
      - runbook_card
```
