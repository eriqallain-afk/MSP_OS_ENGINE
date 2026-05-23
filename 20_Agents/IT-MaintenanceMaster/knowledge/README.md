# IT-MaintenanceMaster Knowledge Pack v1

## Vue d'ensemble

Ce Knowledge Pack équipe IT-MaintenanceMaster pour assister lors d'interventions de maintenance IT avec génération automatique de documentation ConnectWise.

## Capacités

### 🔧 Assistance opérationnelle
- Analyse captures d'écran (Event Logs, erreurs, status)
- Commandes PowerShell contextuelles
- Suggestion des prochaines étapes
- Suivi multi-serveurs simultanés

### 📋 Plateformes supportées
- **Serveurs:** Windows Server, Linux, VMware ESXi, Hyper-V
- **Réseau:** Watchguard, Fortinet, Cisco, Ubiquiti
- **Backup:** VEEAM, Datto
- **Virtualisation:** VMware vSphere, Hyper-V Manager

### 📝 Génération documentation ConnectWise
- **CW_DISCUSSION:** Résumé facturable (bullet points, client-friendly)
- **CW_NOTE_INTERNE:** Documentation technique (base de connaissance)
- **EMAIL_CLIENT:** Notification personnalisée

## Structure

```
IT-MaintenanceMaster_KnowledgePack_v1/
├── README.md (ce fichier)
│
├── 01_TEMPLATES_CW/
│   ├── TEMPLATE__CW_DISCUSSION.md
│   ├── TEMPLATE__CW_NOTE_INTERNE.md
│   └── TEMPLATE__EMAIL_CLIENT.md
│
├── 02_RUNBOOKS_MAINTENANCE/
│   ├── RUNBOOK__Patching_Windows_Server.md
│   ├── RUNBOOK__Patching_ESXi.md
│   ├── RUNBOOK__Maintenance_Reseau.md
│   ├── RUNBOOK__Backup_Troubleshooting_VEEAM.md
│   └── RUNBOOK__Backup_Troubleshooting_Datto.md
│
├── 03_CHECKLISTS/
│   ├── CHECKLIST__Pre_Maintenance.md
│   ├── CHECKLIST__Post_Maintenance.md
│   └── CHECKLIST__Rollback_Procedure.md
│
├── 04_POWERSHELL_LIBRARY/
│   ├── POWERSHELL__Server_Management.md
│   ├── POWERSHELL__Event_Log_Analysis.md
│   ├── POWERSHELL__Network_Diagnostics.md
│   └── POWERSHELL__Backup_Verification.md
│
└── 05_TROUBLESHOOTING/
    ├── TROUBLESHOOT__Event_Log_Errors.md
    ├── TROUBLESHOOT__Hypervisor_Issues.md
    └── TROUBLESHOOT__Network_Equipment.md
```

## Workflow typique

1. **Début intervention:** Fournir contexte (serveurs, objectif)
2. **Pendant travaux:** Partager captures, erreurs, status
3. **IT-MaintenanceMaster:**
   - Analyse images/textes
   - Suggère commandes PowerShell
   - Propose prochaines étapes
   - Track progression
4. **Fin intervention:** Génère CW_DISCUSSION + CW_NOTE_INTERNE + EMAIL

## Utilisation

### Exemple 1: Patching de 5 serveurs
```
User: Je commence patching de SRV-DC01, SRV-APP01, SRV-SQL01, SRV-FILE01, SRV-WEB01
      Voici status pré-maintenance [colle screenshot]

MaintenanceMaster:
- Analyse screenshot
- Vérifie prerequisites
- Donne checklist pré-maintenance
- Suggère ordre de patching (DC en dernier)
- Fournit commandes PowerShell pour status updates
```

### Exemple 2: Erreur VEEAM
```
User: Job backup failed, voici l'erreur [screenshot Event Log VEEAM]

MaintenanceMaster:
- Identifie code erreur
- Consulte TROUBLESHOOT__Backup_Verification
- Propose diagnostic steps
- Fournit commandes vérification
```

### Exemple 3: Fin d'intervention
```
User: Intervention terminée, génère documentation CW

MaintenanceMaster:
- CW_DISCUSSION: "• Mise à jour sécurité appliquée sur 5 serveurs
                  • Redémarrages effectués avec succès
                  • Tous les services restaurés"
- CW_NOTE_INTERNE: [Détails techniques complets]
- EMAIL_CLIENT: [Notification professionnelle]
```

## Version
v1.0 - Février 2026
