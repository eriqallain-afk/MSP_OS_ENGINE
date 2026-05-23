# Guide d'utilisation — @IT-TicketScribe (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-TicketScribe ?

**IT-TicketScribe est le rédacteur officiel des livrables ConnectWise.**

Il transforme des notes brutes, des logs ou un résumé verbal en documents CW structurés, clairs et facturables — prêts à coller dans ConnectWise Manage.

| Document | Usage | Audience |
|---|---|---|
| Note Interne CW | Chronologie technique complète, détails internes | Équipe interne uniquement |
| Discussion CW | Résumé client-safe, facturable, visible sur facture | Client |
| Email client | Communication formelle post-intervention | Client |
| Notice Teams | Annonce coordination rapide | Équipe / NOC |

> **Règle fondamentale :** Ce qui ne doit pas être vu par le client va dans la Note Interne — jamais dans la Discussion.

---

## Quand l'utiliser ?

- Tu viens de terminer une intervention et tu dois rédiger la Note Interne + Discussion CW
- Tu dois créer un nouveau ticket CW depuis une description brute
- Tu veux rédiger un email client professionnel après un incident
- Tu dois produire une note de passation pour escalade N1→N2 ou N2→N3
- Tu veux réviser une note existante avant de l'envoyer

---

## Les commandes principales

### `/close` — Menu de clôture complet

La commande principale pour générer tous les livrables d'un ticket fermé.

**Usage :**
```
/close
Billet #77023 — Client : Otto Mfg
Intervention : Nettoyage disque C: sur le serveur de fichiers. Espace libéré : 45 Go via
nettoyage des fichiers temporaires et logs IIS. Services vérifiés. RMM vert.
Durée : 1h15. Technicien : ML.
```

**Menu affiché (puis STOP — attendre ton choix) :**
```
[1] CW Note Interne         (technique, interne)
[2] CW Discussion           (client-safe, facturable)
[3] Email client            (communication formelle)
[4] Notice Teams            (annonce coordination)
[A] Tout                    (1 + 2 + 3 + 4)
```

---

### `/note` — Note Interne CW uniquement

Pour générer seulement la Note Interne technique.

**Usage :**
```
/note
Billet #77041 — Client : Otto Inc
09:15 — Alerte RMM CPU 97% sur SRV-APP01 détectée
09:18 — Connexion RDP au serveur
09:22 — Processus SQLSERVR.EXE à 94% CPU identifié via Task Manager
09:35 — Requête SQL bloquée identifiée via sp_who2 — session terminée
09:40 — CPU retombé à 12% — services stables
Technicien : JF. Durée : 25 min.
```

**Ce que tu obtiens :**
- Note complète avec phrase d'ouverture obligatoire
- Chronologie structurée `[HH:MM] — Action → Résultat`
- Validations listées
- Statut final clair

---

### `/discussion` — Discussion CW client-safe

Pour générer seulement la Discussion visible par le client (facturable).

**Usage :**
```
/discussion
Billet #77041 — Incident performance serveur applicatif chez Otto Inc.
Cause résolue. Durée 25 min. Services opérationnels confirmés.
```

**Règles automatiquement appliquées :**
- Zéro IP, zéro commande, zéro nom de serveur interne
- Phrase d'ouverture obligatoire incluse
- Minimum 4 puces dans TRAVAUX EFFECTUÉS
- Langage non-technique orienté impact utilisateur

---

### `/draft` — Créer un ticket CW depuis une description brute

**Usage :**
```
/draft
Un utilisateur signale qu'il ne reçoit plus ses courriels Outlook depuis ce matin vers 8h30.
Les autres collègues du bureau semblent fonctionnels. Client : Otto Group.
```

**Ce que tu obtiens :**
- Titre structuré avec catégorie
- Priorité suggérée (P1/P2/P3/P4)
- Type d'intervention
- Agent recommandé pour assignation
- Description complète + informations collectées
- Prochaine action suggérée

---

### `/email` — Email client professionnel

**Usage :**
```
/email
Destinataire : Marie Côté, directrice TI, Otto Group
Billet #77055 — Résolution problème Outlook. Services M365 rétablis après correction
de la configuration DNS. Durée interruption : 1h45. Aucune donnée perdue.
```

---

### `/escalade` — Note de transfert

Pour produire une passation propre lors d'un transfert N1→N2, N2→N3 ou vers un spécialiste.

**Usage :**
```
/escalade
De : Martin (N1) vers IT-Assistant-N3
Billet #77062 — Erreur réplication AD sur DC01 depuis 2h.
Actions tentées : redémarrage Netlogon, vérification SYSVOL — toujours en erreur.
Accès RDP disponible. Client : Otto Mfg.
```

---

### `/review` — Réviser une note avant envoi

**Usage :**
```
/review
[Coller la note existante à réviser]
Note pour billet #77070 : J'ai checké le serveur DC-PROD-01 sur l'IP 192.168.10.5
et j'ai resetté le mot de passe de l'admin. Ça marche maintenant.
```

**Ce que tu obtiens :**
- Points problématiques identifiés (`⚠️` / `ℹ️`)
- Version corrigée complète
- Infos sensibles signalées à déplacer

---

### `/kb` — Brief pour IT-KnowledgeKeeper

Génère automatiquement un brief YAML structuré à transmettre à `@IT-KnowledgeKeeper` pour capitalisation.

**Usage :**
```
/kb
(génère automatiquement depuis le contexte de la conversation en cours)
```

---

## Flux de travail recommandé

### Après une intervention résolue

```
1. Intervention terminée dans CW
        ↓
2. /close [coller résumé de l'intervention]
        ↓
3. Choisir [A] pour tout générer
   OU choisir [1] et [2] séparément pour réviser avant d'envoyer
        ↓
4. Coller Note Interne dans CW (onglet Notes internes)
   Coller Discussion dans CW (onglet Discussion — facturable)
        ↓
5. (Optionnel) /kb si incident > 30 min ou cause non évidente
```

### Création rapide de ticket

```
1. Recevoir description brute de l'incident (appel, courriel, Slack)
        ↓
2. /draft [description]
        ↓
3. Créer le ticket dans CW avec le contenu généré
        ↓
4. Assigner selon l'agent recommandé
```

### Escalade propre

```
1. Limite de compétence atteinte ou délai SLA à risque
        ↓
2. /escalade [contexte + actions tentées]
        ↓
3. Coller la note de transfert dans CW
   Aviser l'équipe N+1 via Teams
```

---

## Templates disponibles par type d'intervention

IT-TicketScribe contient 8 templates pré-structurés pour les Discussion CW :

| Type | Déclenchement |
|---|---|
| Patching / Maintenance serveurs | Mentionner "mises à jour", "patching", "maintenance" |
| Incident backup / Sauvegarde | Mentionner "backup", "Veeam", "Datto", "sauvegarde" |
| Réseau / Connectivité | Mentionner "réseau", "VPN", "connectivité", "firewall" |
| Incident utilisateur / Accès AD | Mentionner "mot de passe", "accès", "Active Directory" |
| Microsoft 365 / Cloud | Mentionner "M365", "Outlook", "Teams", "SharePoint" |
| Incident de sécurité | Mentionner "sécurité", "phishing", "malware", "alerte" |
| Urgence P1 / Panne critique | Mentionner "P1", "panne", "critique", "inaccessible" |
| Audit / Vérification de santé | Mentionner "audit", "health check", "vérification", "santé" |

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO IP dans Discussion, Email, Teams | Client-safe — obligatoire |
| ZÉRO credentials dans tout livrable | Sécurité — Passportal uniquement |
| Note Interne : phrase d'ouverture TOUJOURS en premier | Standard CW auditable |
| Discussion : phrase d'ouverture TOUJOURS en premier | Standard CW facturable |
| Minimum 4 puces dans TRAVAUX EFFECTUÉS de la Discussion | Facturation détaillée |
| `[À CONFIRMER]` si info non vérifiable — zéro invention | Intégrité des livrables |
| Temps verbaux : passé composé pour actions réalisées | Clarté de la chronologie |

---

## Questions fréquentes

**Q : Quelle différence entre Note Interne et Discussion CW ?**
La Note Interne est interne à l'équipe — elle peut contenir des noms de serveurs, des logs, des commandes.
La Discussion CW est visible par le client — elle apparaît sur la facture. Jamais d'IP, credentials ou détails techniques dans la Discussion.

**Q : Quelle différence avec IT-ClientDocMaster ?**
IT-TicketScribe documente une intervention (ticket en cours ou fermé).
IT-ClientDocMaster produit de la documentation durable côté client (guides, procédures, rapport d'état d'infrastructure).

**Q : Est-ce que je dois rédiger la Note Interne ET la Discussion pour chaque ticket ?**
Pour les interventions facturables : oui, les deux sont nécessaires. La Note Interne sert l'audit interne, la Discussion sert la facturation client.

**Q : Comment utiliser `/kb` correctement ?**
Tape `/kb` à la fin d'une conversation où l'intervention est documentée. L'agent génère automatiquement le brief YAML complet à coller dans `@IT-KnowledgeKeeper` avec `/kb [brief YAML]`.

**Q : Peut-on utiliser IT-TicketScribe pour un incident sécurité ?**
Oui — utilise le template "Incident de sécurité (ton client-safe)" via `/discussion`. Il est conçu pour ne jamais divulguer de détails sensibles (CVE, vecteur d'attaque) dans les livrables clients.

---

*GUIDE_UTILISATION — IT-TicketScribe v1.0 — MSP Intelligence AI — 2026-05-18*
