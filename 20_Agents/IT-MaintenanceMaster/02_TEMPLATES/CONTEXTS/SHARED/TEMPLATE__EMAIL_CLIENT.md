# TEMPLATE: EMAIL_CLIENT (Notification client)

## Objectif
Générer un email professionnel pour notifier le client après une intervention. Doit être:
- ✅ Professionnel et rassurant
- ✅ Clair sur ce qui a été fait et le résultat
- ✅ Client-friendly (non-technique sauf si demandé)
- ✅ Inclure prochaines étapes si applicable

## Format

```
Objet: [Type intervention] - [Résultat] - [Système/Serveur]

Bonjour [Prénom],

[Paragraphe d'introduction - contexte]

[Paragraphe résumé travaux]

[Paragraphe résultat/statut]

[Optionnel: Paragraphe recommandations]

[Paragraphe conclusion]

Cordialement,
[Nom]
[Titre]
[Entreprise]
[Téléphone]
```

## Exemples par type d'intervention

### Exemple 1: Maintenance planifiée réussie

```
Objet: Maintenance serveurs complétée avec succès - Otto Inc

Bonjour Marie,

Je vous confirme que la maintenance planifiée de vos serveurs s'est déroulée 
sans incident cette nuit, de 20h00 à 23h15.

Nous avons installé les mises à jour de sécurité Microsoft de février 2026 
sur vos 5 serveurs (DC, App, SQL, File, Web). Chaque serveur a été redémarré 
et tous les services ont été vérifiés. Les applications métier ont été testées 
et sont pleinement fonctionnelles.

Résultat: Vos serveurs sont maintenant à jour avec les derniers correctifs de 
sécurité. Aucun problème n'a été rencontré et vos opérations peuvent continuer 
normalement ce matin.

La prochaine fenêtre de maintenance est prévue pour mars 2026. Nous vous 
contacterons 2 semaines à l'avance pour planifier la date exacte.

N'hésitez pas si vous avez des questions ou si vous constatez quoi que ce soit 
d'inhabituel.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 2: Troubleshooting réussi

```
Objet: Problème de sauvegarde résolu - SRV-FILE01

Bonjour Pierre,

Suite à l'alerte de ce matin concernant l'échec de sauvegarde du serveur 
SRV-FILE01, je vous confirme que le problème a été identifié et résolu.

Le problème était causé par un manque d'espace sur le système de sauvegarde. 
Nous avons nettoyé les anciennes sauvegardes selon la politique de rétention 
et relancé la sauvegarde manuellement. Celle-ci s'est complétée avec succès.

Résultat: Votre serveur de fichiers est maintenant sauvegardé correctement et 
nous avons mis en place des alertes pour prévenir ce type de situation à l'avenir.

Recommandation: L'espace de stockage pour les sauvegardes approche sa capacité 
maximale (87% utilisé). Nous recommandons de planifier une expansion du stockage 
d'ici 3-4 mois pour assurer la continuité des sauvegardes.

Je reste disponible si vous souhaitez discuter de cette recommandation ou si 
vous avez des questions.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 3: Intervention d'urgence

```
Objet: Intervention urgente complétée - SRV-APP01 restauré

Bonjour Sophie,

Je vous confirme que le serveur SRV-APP01 qui était inaccessible depuis 14h30 
a été restauré et est maintenant pleinement opérationnel.

Nous avons diagnostiqué un problème de service critique qui ne démarrait plus 
automatiquement. Le serveur a été redémarré et le service a été reconfiguré 
pour assurer un démarrage fiable. Nous avons testé l'accès à vos applications 
et tout fonctionne normalement.

Résultat: Le serveur est opérationnel depuis 15:45. Vos utilisateurs peuvent 
accéder à nouveau aux applications sans restriction.

Pour prévenir une récurrence, nous allons surveiller ce serveur de près pendant 
48 heures et effectuer une analyse approfondie pour identifier la cause racine 
du problème. Je vous tiendrai informée des résultats.

Merci de votre patience durant cette interruption. N'hésitez pas à nous contacter 
si vous constatez quelque chose d'anormal.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 4: Mise à jour équipement réseau

```
Objet: Mise à jour pare-feu complétée - Watchguard

Bonjour Marc,

La mise à jour de votre pare-feu Watchguard prévue pour ce soir s'est déroulée 
avec succès, sans interruption de vos opérations.

Nous avons installé la dernière version du firmware qui inclut d'importantes 
améliorations de sécurité et corrections de vulnérabilités. Les règles de 
pare-feu, la configuration VPN et tous vos accès distants ont été vérifiés et 
fonctionnent correctement.

Résultat: Votre pare-feu est maintenant à jour avec les dernières protections. 
Aucun changement n'affecte vos utilisateurs - tout fonctionne exactement comme 
avant, mais de façon plus sécurisée.

Cette mise à jour renforce la sécurité de votre réseau contre les menaces 
récemment découvertes. Aucune action n'est requise de votre part.

Si vous ou vos utilisateurs constatez quelque chose d'inhabituel dans les 
prochains jours, n'hésitez pas à nous contacter immédiatement.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 5: Audit/Vérification

```
Objet: Audit infrastructure complété - Otto Inc

Bonjour Christine,

Tel que prévu, nous avons effectué un audit de santé de votre infrastructure 
serveurs ce matin.

Nous avons vérifié l'état de vos 8 serveurs, analysé l'utilisation des 
ressources (CPU, mémoire, espace disque), examiné les journaux d'événements 
des 30 derniers jours et contrôlé le statut de tous les services critiques.

Résultat: Votre infrastructure est en bon état général. Nous avons identifié 
et corrigé quelques alertes mineures. Aucun problème critique n'a été détecté.

Recommandation: Le serveur SRV-APP01 utilise 85% de son espace disque. Nous 
recommandons un nettoyage des fichiers temporaires dans les prochaines 2 semaines 
pour éviter tout problème d'espace. Nous pouvons effectuer cette opération lors 
de votre prochaine fenêtre de maintenance.

Je vous enverrai le rapport détaillé d'audit par email séparé d'ici demain 
en fin de journée.

N'hésitez pas si vous avez des questions sur les résultats de cet audit.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 6: Maintenance avec impacts mineurs

```
Objet: Maintenance SQL Server complétée - Redémarrage plus long que prévu

Bonjour Daniel,

La maintenance de votre serveur SQL (SRV-SQL01) prévue hier soir s'est bien 
déroulée, bien que le redémarrage ait pris un peu plus de temps que prévu.

Nous avons installé les mises à jour critiques SQL Server 2022. Le redémarrage 
a duré environ 12 minutes au lieu des 5 minutes habituelles, en raison de la 
taille de vos bases de données. C'est parfaitement normal pour un serveur SQL 
de cette envergure.

Résultat: SQL Server est maintenant à jour et fonctionne normalement. Toutes 
vos bases de données sont en ligne et accessibles. Nous avons testé les 
connexions et les performances sont excellentes.

Le temps de redémarrage prolongé n'a pas d'impact sur vos opérations car 
l'intervention était planifiée hors heures d'affaires. Tout est rentré dans 
l'ordre ce matin comme prévu.

Merci de votre confiance. N'hésitez pas si vous avez des questions.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 7: Problème partiellement résolu

```
Objet: Intervention en cours - Problème backup partiellement résolu

Bonjour Nathalie,

Suite au problème de sauvegarde signalé ce matin, je voulais vous donner une 
mise à jour sur l'avancement.

Nous avons identifié la cause du problème (espace disque insuffisant sur le 
système de backup) et libéré de l'espace. La sauvegarde fonctionne maintenant 
pour la plupart de vos serveurs. Toutefois, nous continuons à investiguer un 
problème spécifique sur le serveur SRV-APP02.

Statut actuel:
• SRV-FILE01: Backup fonctionnel ✓
• SRV-SQL01: Backup fonctionnel ✓
• SRV-DC01: Backup fonctionnel ✓
• SRV-APP02: En cours d'investigation (erreur différente)

Nous travaillons activement sur SRV-APP02 et prévoyons résoudre le problème 
d'ici la fin de journée. Je vous tiendrai informée dès que tout sera résolu.

Vos données critiques sur les 3 autres serveurs sont maintenant protégées. 
Le problème restant n'affecte pas vos opérations quotidiennes.

Je vous recontacte dès que l'intervention est complétée.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

## Règles importantes

### ✅ À FAIRE
- Utiliser prénom du contact (personnalisé)
- Commencer par contexte clair
- Expliquer ce qui a été fait (vulgarisé)
- Indiquer résultat/impact
- Mentionner prochaines étapes si applicable
- Ton professionnel mais accessible
- Offrir disponibilité pour questions

### ❌ À ÉVITER
- Jargon technique excessif
- Détails trop techniques non sollicités
- Blâmer ou critiquer
- Créer inquiétude inutile
- Promesses non réalistes
- Ton trop décontracté

## Variantes de ton selon situation

**Maintenance réussie:** ✅ Ton rassurant et positif
**Problème résolu:** ✅ Ton professionnel et confiant
**Urgence résolue:** ✅ Ton empathique et transparent
**Problème en cours:** ⚠️ Ton honnête mais rassurant
**Recommandation importante:** 💡 Ton consultatif

## Variables à personnaliser

```yaml
destinataire_prenom: "[Prénom]"
type_intervention: "[Maintenance/Troubleshooting/Audit/Urgence]"
systemes_concernes: "[Serveurs/Équipements]"
resume_travaux: "[Ce qui a été fait]"
resultat: "[Statut actuel]"
recommandations: "[Si applicable]"
prochaines_etapes: "[Si applicable]"
signature_nom: "[Nom complet]"
signature_titre: "[Titre/Rôle]"
signature_entreprise: "[Nom entreprise]"
signature_telephone: "[(XXX) XXX-XXXX]"
```

## Longueur recommandée
- **Minimum:** 3 paragraphes
- **Idéal:** 4-5 paragraphes
- **Maximum:** 6 paragraphes

**Note:** Email doit être lu en < 2 minutes. Aller droit au but tout en étant complet.

---

*Template version 1.0 - IT-MaintenanceMaster*
