# TEMPLATE: CW_DISCUSSION (Note ConnectWise - Facturable)
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Objectif
Générer un résumé en bullet points qui apparaîtra sur la facture client. Doit être:
- ✅ Format STAR
- ✅ Clair et concis
- ✅ Sans informations sensibles (mots de passe, IPs internes, détails sécurité)
- ✅ Orienté valeur/résultats

## Format

```
INTERVENTION: [Type d'intervention]
DATE: [Date]
TECHNICIEN: [Nom ou initiales]

TRAVAUX EFFECTUÉS:
• [Action 1 - résultat client-visible]
• [Action 2 - résultat client-visible]
• [Action 3 - résultat client-visible]
• [Action 4 - résultat client-visible]

RÉSULTAT:
• [Impact positif pour le client]
• [Confirmation de bon fonctionnement]

[Optionnel] RECOMMANDATION:
• [Suggestion pour le client]
```

## Exemples par type d'intervention

### Exemple 1: Patching de serveurs

```
INTERVENTION: Maintenance serveurs (mises à jour sécurité)
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Vérification pré-déploiement
• Vérification de l'état des dernières sauvegardes, prise de Snapshot
• Vérification de l'état général des serveurs, services en cours et fichiers journaux
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

### Exemple 2: Troubleshooting backup

```
INTERVENTION: Résolution problème de sauvegarde
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Prise de connaissance de la demande et connexion à la documentation
• Connexion au serveur de sauvegarde
• Diagnostic de l'échec de sauvegarde du serveur SRV-FILE01
• Résolution du problème d'espace disque sur le dépôt de backup
• Lancement manuel de la sauvegarde et vérification de la réussite
• Mise en place d'alertes pour prévenir futures occurrences

RÉSULTAT:
• Sauvegarde fonctionnelle et complétée avec succès
• Espace libéré sur le dépôt (ancien backups archivés)
• Alertes configurées pour prévenir le problème

RECOMMANDATION:
• Envisager augmentation capacité stockage backup d'ici 3 mois
```

### Exemple 3: Maintenance réseau

```
INTERVENTION: Mise à jour équipements réseau
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Prise de connaissance de la demande et connexion à la documentation
• Mise à jour firmware du pare-feu Watchguard
• Application des correctifs de sécurité recommandés
• Vérification de la configuration post-mise à jour
• Tests de connectivité Internet et VPN

RÉSULTAT:
• Pare-feu mis à jour avec dernières protections de sécurité
• Connectivité confirmée (Internet, VPN, accès distant)
• Aucune interruption de service observée
```

### Exemple 4: Audit/Vérification

```
INTERVENTION: Audit de l'infrastructure serveurs
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Vérification de l'état de santé de 8 serveurs
• Contrôle de l'espace disque disponible
• Analyse des journaux d'événements (30 derniers jours)
• Vérification du statut des services critiques

RÉSULTAT:
• Infrastructure en bon état général
• Quelques alertes mineures identifiées et résolues
• Aucun problème critique détecté

RECOMMANDATION:
• Prévoir nettoyage fichiers temporaires sur SRV-APP01 (espace 85%)
```

### Exemple 5: Intervention d'urgence

```
INTERVENTION: Intervention urgente - Serveur inaccessible
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Diagnostic du serveur SRV-APP01 non accessible
• Redémarrage du serveur via console hyperviseur
• Vérification et correction de l'erreur de démarrage du service
• Restauration complète de l'accessibilité

RÉSULTAT:
• Serveur restauré et fonctionnel
• Services applicatifs redémarrés avec succès
• Utilisateurs peuvent accéder à nouveau aux applications

RECOMMANDATION:
• Surveillance renforcée du serveur sur 48h
• Analyse approfondie planifiée pour identifier cause racine
```

## Règles importantes

### ✅ À FAIRE
- Utiliser langage simple et compréhensible
- Mentionner résultats concrets
- Indiquer impacts positifs pour le client
- Être factuel et précis
- Inclure recommandations si pertinent

### ❌ À ÉVITER
- Jargon technique excessif
- Détails d'implémentation (ports, IPs, commandes)
- Informations sensibles (credentials, vulnérabilités)
- Blâmer ou critiquer
- Promesses non vérifiées

## Variables à personnaliser

```yaml
type_intervention: "[Maintenance/Troubleshooting/Audit/Urgence/...]"
date: "[YYYY-MM-DD]"
technicien: "[Initiales ou nom]"
travaux: "[Liste bullet points 3-6 items]"
resultat: "[Impact client 1-3 points]"
recommandation: "[Optionnel - 1-2 points]"
```

## Longueur recommandée
- **Minimum:** 4-5 bullet points
- **Idéal:** 6-8 bullet points
- **Maximum:** 10 bullet points

**Note:** Le client VOIT cette note sur sa facture. Elle doit démontrer la valeur du travail effectué tout en restant professionnelle et appropriée.

---

*Template version 1.0 - IT-MaintenanceMaster*
