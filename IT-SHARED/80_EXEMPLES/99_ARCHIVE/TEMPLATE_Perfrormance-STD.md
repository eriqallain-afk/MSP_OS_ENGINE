Voici un **template maître d’intervention MSP**, pensé pour être à la fois :
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

* un **modèle opérationnel réutilisable** par un tech,
* un **exemple concret et premium** pour présenter la qualité du service MSP,
* et un **cas vitrine** basé sur un incident typique de surcharge CPU prolongée sur serveur.

Je l’ai aligné sur les règles de clôture, la séparation **note interne vs discussion client**, l’ouverture obligatoire des livrables, la notice Teams au bon moment, et la logique MSP complète : **détection → triage → communication → diagnostic → remédiation → validation → clôture**.   

---

# TEMPLATE MAÎTRE — INTERVENTION MSP COMPLÈTE

## Cas d’usage vitrine : surcharge CPU prolongée sur serveur de fichiers

### 1. FICHE D’INTERVENTION

```text
BILLET : #[XXXXX]
CLIENT : [Nom du client]
SITE : [Nom du site]
ACTIF : [Nom du serveur]
TYPE : Incident performance serveur
SOURCE : Monitoring / RMM / Alerte NOC
SYMPTÔME : CPU à 100 % pendant [X] minutes
DATE : [YYYY-MM-DD]
TECHNICIEN : [Nom ou initiales]
PRIORITÉ INITIALE : [P2 / P3]
IMPACT INITIAL : [À confirmer / partiel / majeur]
```

---

### 2. RÉSUMÉ EXÉCUTIF

```text
Une alerte de performance a été reçue pour une utilisation processeur anormalement élevée sur un serveur critique.
L’intervention a été prise en charge selon une approche MSP structurée : qualification, collecte en lecture seule, analyse des processus dominants, validation de l’impact, décision de remédiation, puis validation post-intervention.
L’objectif n’était pas seulement de faire redescendre le CPU, mais de sécuriser le service, protéger la continuité des opérations et fournir une traçabilité complète dans ConnectWise.
```

---

### 3. NOTICE TEAMS — DÉBUT D’INTERVENTION

La notice Teams doit être proposée dès que le type d’intervention est connu, avant les actions intrusives. 

🔧 Maintenance en cours — Billet : #[XXXXX]
Client : [Nom du client]
Tâche principale : Investigation d’une surcharge CPU prolongée sur [Nom du serveur]
Impact : [À confirmer / ralentissements observés / redémarrage potentiellement requis]

---

### 4. TRIAGE INITIAL

```text
OBJECTIF
Déterminer rapidement si l’on est en présence :
- d’un pic transitoire,
- d’une saturation réelle,
- d’une maintenance système légitime,
- d’un comportement applicatif anormal,
- ou d’un incident nécessitant une escalade.

LECTURE INITIALE
- Vérifier si la surcharge est encore active
- Confirmer si les utilisateurs sont impactés
- Identifier les processus dominants
- Vérifier si un redémarrage est en attente
- Valider si des tâches de maintenance, sécurité ou backup sont en cours
```

---

### 5. PLAN D’ACTION MSP

```text
PHASE 1 — COLLECTE
Collecte des éléments en lecture seule pour confirmer la réalité de l’alerte et identifier la cause probable.

PHASE 2 — ANALYSE
Corrélation entre les lectures CPU, les processus dominants, les tâches en cours, les événements système et l’état de maintenance Windows.

PHASE 3 — DÉCISION
Choix entre :
- surveillance,
- correction ciblée,
- redémarrage contrôlé,
- ou escalade.

PHASE 4 — VALIDATION
Vérification du retour à la normale :
- CPU,
- services critiques,
- accessibilité du serveur,
- absence d’impact résiduel.

PHASE 5 — CLÔTURE
Documentation complète :
- CW Note Interne
- CW Discussion client-safe
- notice Teams de fin
- recommandation de suivi
```

---

### 6. JOURNAL D’INTERVENTION LIVE

```text
[HH:MM] Alerte reçue via monitoring pour CPU 100 % prolongé sur [Serveur].
[HH:MM] Billet ouvert et prise en charge de l’incident.
[HH:MM] Qualification initiale : incident de performance serveur, impact à confirmer.
[HH:MM] Notice Teams préparée / envoyée.
[HH:MM] Collecte lecture seule effectuée : compteurs CPU, processus, services, état système.
[HH:MM] Confirmation que la saturation CPU est réelle.
[HH:MM] Processus dominants identifiés : [liste synthétique].
[HH:MM] Vérification de l’état de redémarrage en attente et du contexte de maintenance.
[HH:MM] Analyse consolidée : surcharge probablement liée à [cause probable].
[HH:MM] Décision : [surveillance / reboot contrôlé / autre].
[HH:MM] ⚠️ Impact communiqué avant action intrusive.
[HH:MM] Action corrective exécutée.
[HH:MM] Validation post-action : serveur joignable, services opérationnels, CPU revenu normal.
[HH:MM] Billet documenté et clôture préparée.
```

---

### 7. ANALYSE TECHNIQUE — VERSION “PREMIUM”

```text
L’analyse a permis de confirmer que l’alerte ne relevait pas d’un faux positif de monitoring.
Les lectures ont démontré une saturation CPU soutenue, compatible avec une charge réelle sur le serveur.

Les processus observés pendant l’incident ont révélé une pression importante provenant d’activités système et d’agents de sécurité/sauvegarde.
Le portrait était cohérent avec un chevauchement de charges légitimes :
- moteur antivirus,
- agent EDR,
- activité WMI,
- maintenance Windows,
- et, selon le contexte, traitement de sauvegarde.

Cette approche est importante dans un contexte MSP :
on ne cherche pas seulement “ce qui consomme du CPU”, on cherche à distinguer un comportement attendu, un empilement de tâches mal synchronisées, ou une anomalie nécessitant une réponse plus agressive.
```

---

### 8. DÉCISION DE REMÉDIATION

```text
DÉCISION RETENUE
Un redémarrage contrôlé a été recommandé puis exécuté afin de :
- finaliser l’état système,
- libérer les opérations en attente,
- confirmer le retour à la normale,
- et réduire le risque de récidive immédiate.

JUSTIFICATION
Le redémarrage n’a pas été utilisé comme raccourci.
Il a été retenu comme action mesurée après :
- confirmation de la saturation CPU,
- collecte des éléments techniques,
- validation du contexte de maintenance,
- et évaluation de l’impact.
```

---

### 9. AVIS D’IMPACT AVANT ACTION

```text
⚠️ Impact : redémarrage planifié du serveur [Nom du serveur].
Conséquence attendue : interruption temporaire des accès aux partages et aux services dépendants pendant le redémarrage et la remise en ligne.
Validation requise avant exécution.
```

---

### 10. VALIDATION POST-INTERVENTION

```text
VALIDATIONS EFFECTUÉES
- Serveur redémarré avec succès
- Accessibilité confirmée
- Fonctionnement général confirmé
- Niveau CPU revenu à la normale
- Aucun impact résiduel confirmé au moment de la validation
- Surveillance recommandée pour confirmer la stabilité

CONCLUSION TECHNIQUE
Incident stabilisé après redémarrage contrôlé.
Cause probable : chevauchement d’activités système, sécurité et/ou sauvegarde, avec contexte de maintenance observé durant l’investigation.
Aucun indicateur clair d’incident de sécurité actif retenu dans le cadre du billet.
```

---

## 11. CW NOTE INTERNE — TEMPLATE COMPLET

La note interne doit contenir l’ouverture obligatoire, un journal clair, des constats, les actions et le résultat. Le contenu interne peut être détaillé, tant qu’il reste propre et exploitable.  

```text
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Billet : #[XXXXX]
Client : [Nom du client]
Site : [Nom du site]
Actif : [Nom du serveur]
Type : Incident performance / CPU élevé prolongé

Contexte :
Alerte reçue pour utilisation processeur prolongée sur le serveur concerné.
Investigation démarrée en lecture seule afin de confirmer la réalité de l’alerte et d’identifier la cause probable.

Chronologie :
- [HH:MM] Alerte prise en charge
- [HH:MM] Validation de la surcharge CPU
- [HH:MM] Analyse des processus dominants
- [HH:MM] Vérifications complémentaires sur l’état système et le contexte de maintenance
- [HH:MM] Décision de remédiation
- [HH:MM] Redémarrage effectué
- [HH:MM] Validation finale du retour au fonctionnement normal

Constats techniques :
- CPU réellement élevé pendant la période d’alerte
- Principaux processus observés : [processus 1], [processus 2], [processus 3], [processus 4]
- Contexte compatible avec un chevauchement de charges système / sécurité / sauvegarde
- [Pending reboot observé / non observé]
- Aucun processus inconnu ou comportement clairement malveillant retenu dans le cadre du billet

Actions effectuées :
- Revue de l’alerte et qualification de l’impact
- Collecte lecture seule des indicateurs système
- Analyse des processus et du contexte de maintenance
- Recommandation de remédiation adaptée
- Redémarrage contrôlé du serveur
- Validation post-intervention

Résultat :
Serveur redémarré avec succès et fonctionnement normal confirmé.
Incident stabilisé.
Surveillance recommandée afin de confirmer l’absence de récurrence.

Suivi :
- Confirmer l’absence de nouvelle alerte CPU prolongée
- Revoir la planification des tâches de sécurité / sauvegarde si la condition se reproduit
```

---

## 12. CW DISCUSSION — VERSION FACTURABLE / CLIENT-SAFE

La discussion client doit utiliser l’ouverture obligatoire, rester lisible, orientée résultats, sans détails sensibles ni techniques internes.  

```text
---------
INTERVENTION: Diagnostic et rétablissement d’une surcharge CPU sur serveur
---------

DATE: [YYYY-MM-DD]
TECHNICIEN: [Initiales]
---------

PRÉPARATION ET DÉCOUVERTE:
---------
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

TRAVAUX EFFECTUÉS:
---------
• Analyse de l’alerte de performance signalant une utilisation processeur prolongée sur le serveur concerné
• Vérification de l’état général du système afin de confirmer la réalité de la surcharge
• Identification des principales activités en cours susceptibles de générer une charge élevée
• Validation qu’il s’agissait d’un incident de performance réel et non d’une alerte transitoire
• Application d’une action corrective contrôlée afin de rétablir un fonctionnement stable
• Validation complète après intervention afin de confirmer le retour du serveur à un état opérationnel

RÉSULTAT:
---------
• Serveur redémarré avec succès et fonctionnement normal confirmé
• Incident stabilisé et aucun impact résiduel confirmé à la fin de l’intervention

RECOMMANDATION:
---------
• Maintenir une surveillance du serveur pour confirmer l’absence de récurrence
```

---

## 13. EMAIL CLIENT — VERSION OPTIONNELLE

Bonjour,

Nous vous confirmons que l’intervention effectuée sur votre serveur a été complétée avec succès.

Notre équipe a pris en charge une alerte de performance liée à une utilisation processeur anormalement élevée. Après analyse, une action corrective contrôlée a été appliquée, suivie d’une validation complète de l’état du système.

À l’issue de l’intervention :

* le serveur est opérationnel,
* le fonctionnement général a été confirmé,
* et aucune anomalie résiduelle n’a été constatée au moment de la validation.

Nous maintenons une surveillance afin de confirmer la stabilité dans le temps.

Cordialement,

[Signature MSP]

---

## 14. NOTICE TEAMS — FIN D’INTERVENTION

✅ Intervention terminée — Billet : #[XXXXX]
Client : [Nom du client]
Tâche principale : Validation post-intervention sur [Nom du serveur] après surcharge CPU prolongée
Impact : Serveur opérationnel et fonctionnement normal confirmé

---

## 15. VERSION “EXEMPLE MARKETING” PRÊTE À MONTRER

```text
Chez [Nom MSP], une alerte critique ne se traite jamais “au feeling”.

Dans ce cas réel de surcharge CPU prolongée sur un serveur de fichiers, l’intervention a été menée comme un service managé mature :
détection proactive, triage structuré, communication immédiate, diagnostic technique en lecture seule, décision argumentée, action corrective contrôlée, validation complète, puis documentation ConnectWise prête à l’emploi.

Résultat :
- incident confirmé rapidement,
- cause probable isolée sans improvisation,
- service rétabli proprement,
- communication claire pour les équipes,
- et clôture professionnelle, exploitable autant par le client que par les opérations internes.

C’est exactement la valeur d’un MSP bien outillé :
moins de bruit, plus de méthode, plus de traçabilité, plus de confiance.

Bref :
du cœur, du process… et du CPU en masse, mais juste quand il faut.
```

---

## 16. MODE D’EMPLOI

```text
UTILISATION
1. Remplacer tous les champs entre crochets
2. Adapter la priorité et l’impact
3. Conserver la séparation stricte :
   - NOTE INTERNE = détaillée
   - DISCUSSION = client-safe
4. Retirer tout élément hors périmètre du billet actif
5. Ajouter une recommandation de suivi seulement si elle apporte une vraie valeur
```

---

## 17. POSITIONNEMENT PRODUIT MSP — PHRASE COURTE

```text
Un bon MSP ne se contente pas de réagir à une alerte.
Il transforme un incident en intervention maîtrisée, traçable, rassurante et reproductible.
```

Si tu veux, je peux maintenant te faire la **V2 en mode brochure premium**, avec un ton encore plus “vente / wow / haut de gamme MSP”.
