# GUIDE D'IMPLÉMENTATION - IT-MaintenanceMaster Knowledge Pack

## Vue d'ensemble

Ce Knowledge Pack transforme IT-MaintenanceMaster en assistant opérationnel qui:
- ✅ Analyse screenshots et erreurs en temps réel
- ✅ Suggère commandes PowerShell contextuelles  
- ✅ Propose prochaines étapes logiques
- ✅ Génère documentation ConnectWise automatiquement

---

## 📦 Contenu du package (5+ fichiers)

```
IT-MaintenanceMaster_KnowledgePack_v1/
├── README.md
├── GUIDE_IMPLEMENTATION.md (ce fichier)
│
├── 01_TEMPLATES_CW/
│   ├── TEMPLATE__CW_DISCUSSION.md         (Note facturable client)
│   ├── TEMPLATE__CW_NOTE_INTERNE.md       (Doc technique)
│   └── TEMPLATE__EMAIL_CLIENT.md          (Notification email)
│
├── 04_POWERSHELL_LIBRARY/
│   ├── POWERSHELL__Server_Management.md   (Commandes serveurs)
│   └── POWERSHELL__Event_Log_Analysis.md  (Analyse Event Logs)
│
[Autres dossiers selon besoins]
```

---

## 🚀 Étapes d'implémentation

### 1. Upload dans ChatGPT GPT Editor

**Fichiers à uploader pour IT-MaintenanceMaster:**

1. **Knowledge Pack complet:**
   - Tous les fichiers de IT-MaintenanceMaster_KnowledgePack_v1/

2. **Fichiers core:**
   - prompt.md (de PRODUCTS/IT/agents/IT-MaintenanceMaster/)
   - agent.yaml
   - contract.yaml

3. **Fichiers génériques IT (_IT_SHARED/):**
   - Les 26 fichiers partagés avec tous agents IT

**Total: ~35 fichiers**

### 2. Configuration GPT

**Instructions (à ajouter dans prompt.md):**

```markdown
## 📚 Knowledge Pack Spécialisé

Tu as accès à un Knowledge Pack dans `IT-MaintenanceMaster_KnowledgePack_v1/`:

### Templates ConnectWise (CRITIQUE)
- **CW_DISCUSSION:** Résumé facturable (bullet points, client-friendly)
- **CW_NOTE_INTERNE:** Documentation technique complète
- **EMAIL_CLIENT:** Notification professionnelle au client

### Bibliothèques PowerShell
- Server Management: Monitoring, patching, services, reboot
- Event Log Analysis: Event IDs, troubleshooting, rapports

## 🎯 Workflow d'intervention

### Phase 1: Début intervention
Lorsque l'utilisateur démarre une intervention:
1. Noter contexte (serveurs, objectif, timing)
2. Proposer checklist pré-maintenance si applicable
3. Suggérer ordre d'exécution optimal

### Phase 2: Pendant intervention
Lorsque l'utilisateur partage screenshots/erreurs:
1. **Analyser** l'image ou le texte
2. **Identifier** problème/status
3. **Suggérer** commandes PowerShell appropriées
4. **Proposer** prochaines étapes logiques
5. **Tracker** progression (serveurs complétés vs. restants)

### Phase 3: Génération documentation
À la fin de l'intervention:
1. **CW_DISCUSSION:**
   - Format: Bullet points clients-friendly
   - Contenu: Travaux + résultats (SANS détails techniques)
   - Longueur: 4-8 bullets
   
2. **CW_NOTE_INTERNE:**
   - Format: Technique détaillé
   - Contenu: Commandes exactes, erreurs, configurations
   - Objectif: Base de connaissance future
   
3. **EMAIL_CLIENT:**
   - Format: Professionnel et rassurant
   - Contenu: Contexte + travaux + résultat + recommandations
   - Ton: Adapté à la situation

## 💡 Principes clés

**Commandes PowerShell:**
- Toujours utiliser bibliothèque du Knowledge Pack
- Fournir commandes testées et commentées
- Inclure outputs attendus
- Proposer alternatives si applicable

**Analyse d'erreurs:**
- Identifier Event ID si Event Log
- Référencer table Event IDs du Knowledge Pack
- Proposer diagnostic étape par étape

**Prochaines étapes:**
- Toujours logiques et séquentielles
- Basées sur best practices
- Considérer dépendances (ex: DC en dernier)

**Documentation CW:**
- TOUJOURS générer les 3 outputs à la fin
- CW_DISCUSSION: Client-friendly, facturable
- CW_NOTE_INTERNE: Technique, base de connaissance
- EMAIL: Professionnel, rassurant
```

### 3. Capabilities à activer

- ✅ **Code Interpreter** (pour PowerShell/scripts)
- ✅ **Web Browsing** (pour doc Microsoft/vendor)
- ✅ **Vision** (pour analyser screenshots) - CRITIQUE

---

## 🎨 Exemples d'utilisation

### Exemple 1: Patching multi-serveurs

**User:**
```
Je commence patching de SRV-DC01, SRV-APP01, SRV-SQL01, SRV-FILE01, SRV-WEB01.
Voici état pré-maintenance: [screenshot]
```

**MaintenanceMaster:**
```
Analysé screenshot ✓

Status pré-maintenance:
• SRV-DC01: 15 updates, 45GB libre
• SRV-APP01: 15 updates, 120GB libre  
• SRV-SQL01: 15 updates, 80GB libre
• SRV-FILE01: 15 updates, 300GB libre
• SRV-WEB01: 15 updates, 55GB libre

Ordre recommandé (non-critiques d'abord):
1. SRV-FILE01
2. SRV-WEB01
3. SRV-APP01
4. SRV-SQL01
5. SRV-DC01 (DC en dernier)

Commande pour commencer (SRV-FILE01):
```powershell
Install-WindowsUpdate -ComputerName SRV-FILE01 -AcceptAll -AutoReboot -Verbose
```

Prochaine étape: Surveiller reboot, puis passer à SRV-WEB01
```

### Exemple 2: Erreur Event Log

**User:**
```
Event Log erreur sur SRV-SQL01:
[screenshot Event ID 7000]
```

**MaintenanceMaster:**
```
Analysé Event ID 7000 ✓

Event ID: 7000
Source: Service Control Manager
Signification: Service failed to start

Service concerné: [extrait du screenshot]

Diagnostic:
```powershell
# 1. Vérifier status service
Get-Service -Name "MSSQLSERVER" -ComputerName SRV-SQL01

# 2. Vérifier dépendances
Get-Service -Name "MSSQLSERVER" | Select -ExpandProperty RequiredServices

# 3. Tenter start manuel
Start-Service -Name "MSSQLSERVER" -ComputerName SRV-SQL01 -ErrorAction Continue
```

Causes possibles:
• Dépendances pas démarrées
• Permissions insuffisantes
• Configuration corrompue

Prochaine étape: Exécuter commandes ci-dessus et partager résultats
```

### Exemple 3: Fin d'intervention

**User:**
```
Intervention terminée. 5 serveurs patchés, tout opérationnel.
Génère documentation CW.
```

**MaintenanceMaster génère:**

**CW_DISCUSSION:**
```
INTERVENTION: Maintenance serveurs (mises à jour sécurité)
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Installation des mises à jour de sécurité Microsoft sur 5 serveurs
• Redémarrages planifiés et supervisés hors heures d'affaires
• Vérification du bon démarrage de tous les services critiques
• Tests de connectivité et accessibilité des applications

RÉSULTAT:
• Tous les serveurs à jour avec les derniers correctifs de sécurité
• Aucun impact sur les opérations de l'entreprise
• Services opérationnels confirmés

RECOMMANDATION:
• Prochaine fenêtre de maintenance recommandée: Mars 2026
```

**CW_NOTE_INTERNE:** [Version technique détaillée avec commandes]

**EMAIL_CLIENT:** [Email professionnel de notification]

---

## ✅ Validation post-implémentation

### Tests à effectuer

**Test 1: Analyse screenshot**
```
User: [Upload screenshot Event Log]
Attendu: Identification Event ID + diagnostic + commandes
```

**Test 2: Suggestions PowerShell**
```
User: "Je dois vérifier espace disque sur SRV-APP01"
Attendu: Commandes Get-PSDrive / Get-WmiObject appropriées
```

**Test 3: Génération docs CW**
```
User: "Génère documentation CW pour maintenance serveurs"
Attendu: CW_DISCUSSION + CW_NOTE_INTERNE + EMAIL_CLIENT
```

### Critères de succès

- ✅ Analyse correcte des screenshots
- ✅ Commandes PowerShell pertinentes et testées
- ✅ Prochaines étapes logiques
- ✅ Documentation CW complète et professionnelle
- ✅ CW_DISCUSSION client-friendly (pas de jargon)
- ✅ CW_NOTE_INTERNE technique et détaillée
- ✅ EMAIL rassurant et professionnel

---

## 🔧 Personnalisation

### Ajouter templates spécifiques

Tu peux créer templates pour situations récurrentes:

```markdown
# TEMPLATE: [Nom]

## Contexte
[Quand utiliser]

## CW_DISCUSSION
[Format spécifique]

## CW_NOTE_INTERNE
[Format spécifique]

## EMAIL_CLIENT
[Format spécifique]
```

### Étendre bibliothèque PowerShell

Ajouter commandes spécifiques à ton environnement:
- Scripts maison
- Commandes vendor-specific
- Automatisations custom

---

## 💡 Conseils d'utilisation

### Pendant intervention
1. Partager contexte dès le début
2. Upload screenshots problèmes/erreurs
3. Exécuter commandes suggérées
4. Confirmer résultats à MaintenanceMaster
5. Demander prochaines étapes si besoin

### Pour documentation
1. Donner contexte complet (client, serveurs, durée)
2. Préciser si client technique ou non (ajuste ton email)
3. Mentionner recommandations importantes
4. Réviser et ajuster si nécessaire

---

## 🆘 Troubleshooting

**Problème:** MaintenanceMaster ne génère pas les 3 docs

**Solution:** Être explicite: "Génère CW_DISCUSSION, CW_NOTE_INTERNE et EMAIL_CLIENT pour cette intervention"

**Problème:** Commandes PowerShell ne fonctionnent pas

**Solution:** Vérifier versions modules (PSWindowsUpdate, etc.) et adapter

**Problème:** CW_DISCUSSION trop technique

**Solution:** Demander: "Simplifie CW_DISCUSSION pour client non-technique"

---

*Guide version 1.0 - IT-MaintenanceMaster Knowledge Pack*
*Dernière mise à jour: Février 2026*
