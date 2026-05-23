# Guide d'utilisation — @IT-ClientDocMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-ClientDocMaster ?

**IT-ClientDocMaster crée et maintient la documentation des objets IT clients dans Hudu.**

À partir de n'importe quelle conversation, note CW ou brief d'agent, il extrait les informations persistantes sur les objets IT impliqués et génère les fiches prêtes à coller directement dans Hudu.

> **Règle fondamentale — 3 destinations distinctes :**
> - Ce qui S'EST PASSÉ → **ConnectWise** (billet, note interne, discussion)
> - Ce QUI EXISTE chez le client → **Hudu** (fiche objet IT)
> - Ce qu'on SAIT FAIRE → **KB MSP** (@IT-KnowledgeKeeper)

| Outil | Ce qu'il documente | Exemple |
|---|---|---|
| ConnectWise | L'événement — ce qui s'est passé | « Billet #77010 — reboot DC01 — 2026-05-15 » |
| **ClientDocMaster → Hudu** | **L'objet IT — ce qui existe** | « DC01 : Win Server 2022, rôle AD DS, hyperviseur ESXi-01 » |
| KnowledgeKeeper | La procédure — comment résoudre | « Conflit probe RMM + Veeam — étapes 1-4 » |

IT-ClientDocMaster ne remplace pas KnowledgeKeeper. Si tu veux documenter **comment résoudre** un problème → `/kb` dans @IT-KnowledgeKeeper. Si tu veux documenter **ce qui existe** chez le client → IT-ClientDocMaster.

---

## Quand l'utiliser ?

- Tu viens de déployer un nouveau serveur, hyperviseur, firewall, NAS ou UPS — fiche Hudu à créer
- Une intervention a révélé des informations sur un objet IT non encore documenté dans Hudu
- Tu as une conversation de support ou une note CW brute — extraire les infos Hudu
- Une config a changé (VLAN, trunk SIP, firmware) — fiche Hudu à mettre à jour
- Tu veux auditer la complétude de la documentation Hudu d'un client
- Tu dois créer des liaisons entre fiches Hudu (VM → Hyperviseur, Switch → Firewall)

---

## Les commandes principales

### `/analyse [coller texte]` — Extracteur de conversation brute

**La commande la plus puissante.** Accepte n'importe quelle forme de texte sans structure imposée — conversation de support, note CW, email, log d'intervention, YAML d'agent.

**Usage :**
```
/analyse [coller la note CW de l'intervention]
```
```
/analyse [coller la conversation de support complète]
```
```
/analyse [coller le brief YAML de l'agent IT-MaintenanceMaster]
```

**Ce que tu obtiens :**
1. Rapport d'inventaire des objets détectés avec niveau de confiance :
   - CONFIRMÉ = info explicite dans le texte
   - PARTIEL = info partielle à compléter
   - À VALIDER = incertitude — à vérifier

2. Fiches Hudu complètes pour chaque objet détecté

3. Récapitulatif des actions Hudu à effectuer (CRÉER / METTRE À JOUR / LIER)

> L'agent distingue automatiquement ce qui est persistant (à documenter) de ce qui est incident (à ignorer). Il n'extrait jamais les symptômes, commandes exécutées ou causes de panne — seulement les propriétés de l'objet IT.

---

### `/fiche [type] [contexte]` — Créer/mettre à jour une fiche par type

Pour créer une fiche Hudu directement sans passer par `/analyse`.

**Commandes disponibles par type :**

| Commande | Type de fiche |
|---|---|
| `/serveur [contexte]` | Serveur physique ou VM (voir aussi `/vm`) |
| `/vm [contexte]` | Machine virtuelle avec infos hyperviseur |
| `/hyperviseur [contexte]` | VMware ESXi, Hyper-V, Proxmox |
| `/reseau [contexte]` | Firewall, switch, WAP, modem/ONT |
| `/nas [contexte]` | Synology, QNAP, TrueNAS |
| `/ups [contexte]` | Onduleur / UPS |
| `/pbx [contexte]` | Téléphonie IP — 3CX, Teams Phone |
| `/backup [contexte]` | Solution backup — Veeam, Datto, Keepit |
| `/application [contexte]` | Application métier |
| `/compte [contexte]` | Compte AD, M365, admin local, service |
| `/licence [contexte]` | Licence logicielle |
| `/procedure [contexte]` | Procédure opérationnelle |

**Usage :**
```
/serveur Nouveau serveur déployé chez Metal-Pless — Windows Server 2022 — rôle DC — hostname METAL-SRV-MTL-001

/hyperviseur ESXi 8.0 Update 2 déployé chez ACME — 2 sockets 10 cœurs — 256 GB RAM — héberge 8 VMs

/backup Veeam B&R 12.1 chez Metal-Pless — protège 5 serveurs — backup quotidien 23h — rétention 30 jours
```

---

### `/vm [contexte]` — Fiche machine virtuelle

Pour documenter une VM avec ses informations d'hébergement.

**Usage :**
```
/vm METAL-VM-DC01 — Windows Server 2022 — rôle DC + DNS — 4 vCPU 16 GB RAM — hébergé sur ESXi-01 — datastore SSD-01
```

**Ce que tu obtiens :**
- Fiche SERVEUR enrichie avec infos hyperviseur (plateforme, ressources allouées, datastore)
- Section HÉBERGEMENT avec lien vers la fiche hyperviseur
- Liaisons à créer : VM → Hyperviseur, VM → Switch, VM → Backup

---

### `/update [type] [nom] [nouvelles infos]` — Mettre à jour une fiche existante

Pour modifier des champs spécifiques sans régénérer toute la fiche.

**Usage :**
```
/update firewall ACME-FW-MTL-001 firmware mis à jour — 12.1.4 → 12.2.1 — billet #78002

/update serveur METAL-SRV-MTL-001 RAM upgradée — 64 GB → 128 GB — intervention 2026-05-14

/update licence Veeam chez Metal-Pless — renouvellement effectué — nouvelle expiration 2027-05-31
```

**Ce que tu obtiens :**
- Liste des champs à modifier avec ancienne → nouvelle valeur
- Entrée HISTORIQUE à ajouter dans la fiche
- Liaisons à mettre à jour si applicable

---

### `/link [objet A] [objet B]` — Documenter une liaison

Pour créer les liaisons entre deux fiches Hudu.

**Usage :**
```
/link VM METAL-VM-DC01 vers Hyperviseur ESXi-01
/link Switch ACME-SW-MTL-001 vers Firewall ACME-FW-MTL-001
/link Serveur Veeam vers NAS SYNOLOGY-01 (datastore backup)
```

**Ce que tu obtiens :**
- Instructions précises : sur quelle fiche ajouter quoi
- Liaisons montantes ET descendantes (les deux côtés de la relation)

---

### `/audit [client]` — Auditer la documentation Hudu d'un client

Pour identifier les fiches manquantes ou incomplètes.

**Usage :**
```
/audit Metal-Pless
/audit Metal-Pless — focus serveurs et hyperviseurs
```

---

### `/close` — Clôture CW

Menu de clôture pour générer Note Interne, Discussion CW, Email client ou Notice Teams.

**Usage :**
```
/close
```
L'agent affiche le menu — il attend ta réponse avant de produire quoi que ce soit.

---

## Flux de travail

### Après déploiement d'un équipement

```
1. Équipement déployé — serveur, firewall, NAS, UPS, etc.
   ↓
2. /[type] [contexte complet] — créer la fiche Hudu
   ex: /serveur ou /hyperviseur ou /reseau
   ↓
3. /link [objet A] [objet B] — créer les liaisons
   ↓
4. Coller le contenu dans Hudu (Notes-Editor + champs structurés)
   ↓
5. /close — documenter dans CW
```

### Après une intervention — extraire les infos Hudu

```
1. Intervention terminée dans CW
   ↓
2. Copier la note d'intervention ou le brief d'agent
   ↓
3. /analyse [coller le texte]
   ↓
4. Vérifier le rapport d'inventaire (objets détectés + confiance)
   ↓
5. Pour chaque objet CONFIRMÉ → coller la fiche dans Hudu
   Pour PARTIEL ou À VALIDER → compléter les [À COMPLÉTER]
   ↓
6. /link pour créer les liaisons identifiées
```

### Audit documentation client trimestriel

```
1. /audit [client]
   ↓
2. Lister les fiches manquantes et champs critiques vides
   ↓
3. Pour chaque lacune → /[type] ou /update correspondant
   ↓
4. Valider les liaisons montantes/descendantes sur chaque fiche
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Hudu = CE QUI EXISTE, CW = CE QUI S'EST PASSÉ | Ne pas mélanger les deux plateformes |
| ZÉRO mot de passe dans Hudu | Passportal uniquement — sécurité des accès |
| ZÉRO IP dans Notes-Editor | IP dans les champs Network de Hudu uniquement |
| `[À COMPLÉTER]` jamais vide | Un champ vide est pire qu'un champ marqué à compléter |
| Liaisons montantes ET descendantes obligatoires | Une fiche VM sans lien vers son hyperviseur est inutile |
| Une fiche = un objet | Ne pas mélanger deux équipements dans une seule fiche |
| Ne jamais publier avec `[À COMPLÉTER]` sur accès ou rôle | Un accès incorrect peut bloquer une intervention en urgence |

**SLA documentation :**
- Nouveau serveur / hyperviseur déployé → fiche dans les 24h
- Changement configuration réseau → fiche dans les 24h
- Équipement non documenté découvert lors d'une intervention → avant `/close`

---

## Questions fréquentes

**Q : Quelle différence entre IT-ClientDocMaster et @IT-KnowledgeKeeper ?**
ClientDocMaster documente **ce qui existe chez le client** dans Hudu — fiches objets IT, configurations, liaisons. KnowledgeKeeper documente **comment résoudre** des problèmes dans la KB MSP — procédures réutilisables pour tous les clients. Exemple : la fiche Hudu du serveur DC01 → ClientDocMaster. La procédure pour corriger un conflit Veeam/probe RMM → KnowledgeKeeper.

**Q : Je n'ai pas toutes les infos pour compléter une fiche — que faire ?**
Mettre `[À COMPLÉTER]` pour les champs non critiques. Ne jamais inventer. Pour les champs critiques (accès, rôle), ne pas publier la fiche tant que l'info n'est pas confirmée. Escalader vers l'agent compétent pour récupérer l'info manquante (ex: @IT-NetworkMaster pour les VLANs d'un firewall).

**Q : `/analyse` vs `/brief` — quelle différence ?**
`/analyse` accepte n'importe quel texte non structuré — conversation brute, email, note CW. C'est la commande universelle. `/brief` est optimisé pour les briefs YAML structurés produits par d'autres agents (ex: output de @IT-MaintenanceMaster). En cas de doute, utiliser `/analyse`.

**Q : Comment documenter une VM sans connaître tous les détails de l'hyperviseur ?**
Créer la fiche VM avec les infos disponibles. Marquer `[À COMPLÉTER]` pour les champs manquants. Ajouter `→ [FICHE À CRÉER : NomHyperviseur]` dans les liaisons. Escalader vers @IT-Commandare-Infra pour récupérer les infos hyperviseur.

**Q : Qui peut alimenter IT-ClientDocMaster ?**
N'importe quel technicien. N'importe quel agent peut envoyer son brief ou output à ClientDocMaster via `/analyse`. C'est conçu pour fonctionner à partir de sources imparfaites — conversations brutes incluses.

---

*GUIDE_UTILISATION — IT-ClientDocMaster v1.0 — MSP Intelligence AI — 2026-05-18*
