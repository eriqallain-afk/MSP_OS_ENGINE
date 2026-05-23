# Guide d'utilisation — @IT-AssetMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-AssetMaster ?

**IT-AssetMaster est le gestionnaire de la CMDB et du cycle de vie des actifs IT.**

Il ne remplace pas Hudu (documentation opérationnelle) ni les notes CW (ce qui s'est passé). Il gère **ce qu'on possède, son état, sa conformité et son cycle de vie** — inventaire matériel, licences logicielles, dates EOL/EOS, couverture de garantie.

| Outil | Ce qu'il stocke | Exemple |
|---|---|---|
| ConnectWise | Ce qui s'est passé | « Intervention sur ACME-SRV-MTL-001 le 15 mai » |
| Hudu | Ce qui existe chez le client | « ACME-SRV-MTL-001 : Windows Server 2022, rôle DC » |
| **AssetMaster** | **Ce qui est dans le parc, son état et ses risques** | « ACME-SRV-MTL-001 : EOL dans 6 mois — dévis requis » |

> **Source de vérité : ConnectWise Configurations uniquement.** Aucune donnée inventée — `[À CONFIRMER]` si non confirmé dans CW.

---

## Quand l'utiliser ?

- Tu dois produire un inventaire complet du parc IT d'un client
- Tu veux savoir quels équipements sont en fin de vie (EOL/EOS) dans les 6-12 prochains mois
- Tu prépares un rapport CMDB pour une réunion client
- Tu dois auditer les licences — expirations, sur-licensing, conformité
- Tu veux suivre le cycle de vie d'un actif spécifique (de l'achat au retrait)
- Une licence de sécurité (EDR, backup, firewall) est sur le point d'expirer

---

## Les commandes principales

### `/inventaire [client]` — Audit inventaire matériel et logiciel

La commande principale. Tu fournis le nom du client, l'agent produit un audit CMDB complet.

**Usage :**
```
/inventaire Metal-Pless
```

**Ce que tu obtiens :**
- Liste des actifs hardware par catégorie (serveurs, réseau, postes, périphériques)
- Statut de chaque actif : Active / EOL / EOS / À remplacer / Retired
- Actifs présents dans le RMM mais absents de CW (gaps)
- Actifs sans heartbeat RMM depuis > 30 jours (fantômes)
- Recommandations priorisées par risque (haute / moyenne / basse)

**Exemple de données à fournir :**
```
/inventaire Metal-Pless
Source : export CW Configurations joint ci-dessous + export N-able
[Coller l'export CSV ou les lignes de données]
```

---

### `/eol [client]` — Rapport EOL/EOS équipements

Pour identifier les équipements et logiciels en fin de vie, avec les dates fabricant.

**Usage :**
```
/eol Metal-Pless
/eol Metal-Pless — focus serveurs Windows 2012 et 2016
```

**Ce que tu obtiens :**
- Liste des actifs avec statut EOL/EOS et date exacte
- Niveaux de risque associés
- Recommandations de remplacement priorisées par urgence

**Règle de déclenchement :**

| Horizon EOL | Action |
|---|---|
| EOL dans 12 mois | Planifier le remplacement |
| EOL dans 6 mois | Urgence — devis requis |
| EOL dépassé | Risque critique — documenter + informer client |

---

### `/licences [client]` — Audit licences logicielles

Pour vérifier la conformité des licences — expirations, quantités, écarts.

**Usage :**
```
/licences Metal-Pless
/licences Metal-Pless — Microsoft 365 + SentinelOne + Veeam
```

**Ce que tu obtiens :**
- Licences actives avec dates d'expiration et quantités
- Licences expirant dans les 60 prochains jours
- Licences déjà expirées (risque conformité immédiat)
- Écarts entre licences assignées et installations détectées (over/under licensing)

**Produits à surveiller en priorité :**
- SentinelOne / CrowdStrike — expiration = brèche potentielle
- Veeam / Datto — expiration = perte de données
- Microsoft 365 — expiration = service interrompu
- WatchGuard / Fortinet — LiveSecurity expiré = firmware non supporté

---

### `/audit [client]` — Audit CMDB trimestriel

Pour un audit de conformité complet de la CMDB CW — doublons, champs manquants, actifs fantômes.

**Usage :**
```
/audit Metal-Pless
```

**Ce que tu obtiens :**
- Champs CW obligatoires manquants (serial number, EOL date, site)
- Doublons détectés (même hostname ou serial dans 2 enregistrements)
- Actifs sans type ou sans site (impossible à filtrer)
- Score de conformité CMDB

---

### `/cycle [asset]` — Gestion cycle de vie d'un équipement

Pour suivre un actif spécifique de son déploiement à son retrait.

**Usage :**
```
/cycle ACME-SRV-MTL-001
/cycle ACME-FW-QC-001
```

**Ce que tu obtiens :**
- Phase actuelle dans le cycle de vie : Procurement → Déploiement → Opération → Maintenance → Décommission
- Dates clés : achat, garantie, EOL fabricant, EOS
- Action requise : renouveler / planifier_remplacement / décommissionner / aucune

---

### `/close` — Clôture CW

Menu de clôture pour générer Note Interne, Discussion CW, Email client ou Notice Teams.

**Usage :**
```
/close
```
L'agent affiche le menu — tu choisis ce que tu veux générer. Il attend ta réponse avant de produire quoi que ce soit.

---

## Flux de travail

### Avant une réunion client trimestrielle

```
1. Exporter CW Configurations pour le client
   ↓
2. /inventaire [client] — audit complet
   ↓
3. /eol [client] — identifier les risques EOL dans 12 mois
   ↓
4. /licences [client] — vérifier conformité licences
   ↓
5. Rapport prêt pour présentation client
```

### Quand une alerte EOL arrive

```
1. Alerte EOL reçue (RMM, CW, ou détection manuelle)
   ↓
2. /cycle [asset] — évaluer l'urgence et la phase
   ↓
3. Si EOL dans 6 mois → escalade @IT-Commandare-OPR
4. Si licence sécurité expirée → escalade @IT-SecurityMaster
   ↓
5. /close — documenter dans CW
```

### Après déploiement d'un nouvel équipement

```
1. Équipement déployé
   ↓
2. Créer l'actif dans CW Configurations
   (Convention : [CLIENT]-[TYPE]-[SITE]-[SEQ] — ex: ACME-SRV-MTL-001)
   ↓
3. Remplir tous les champs obligatoires :
   Name / Type / Status / Manufacturer / Model / Serial / EOL Date / Site
   ↓
4. Handoff → @IT-ClientDocMaster pour fiche Hudu
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Source CMDB = ConnectWise uniquement | Évite les inventaires contradictoires |
| `[À CONFIRMER]` si données non confirmées dans CW | Zéro invention — données CMDB fiables uniquement |
| EOL ≠ EOS | EOL = fin de support (plus de patches) / EOS = fin de vente (plus commercialisé) — distinction critique |
| ZÉRO IP dans les livrables clients | Convention de confidentialité MSP |
| ZÉRO credentials dans les livrables | Passportal uniquement |
| EOL critique = escalade immédiate | Serveur ou firewall EOL = risque sécurité croissant |
| Licence sécurité expirée = P1 | EDR/backup expiré = brèche ou perte données potentielle |

---

## Questions fréquentes

**Q : Quelle différence entre EOL et EOS ?**
EOL (End of Life) = le fabricant ne publie plus de patches ni de corrections de sécurité. C'est le risque critique. EOS (End of Sale) = le produit n'est plus vendu. Un actif EOS peut encore être supporté (EOL pas encore atteint).

**Q : Que faire si un actif n'est pas dans CW ?**
Ne pas l'inventer. Marquer `[À CONFIRMER]` et déclencher un `/audit` pour identifier le gap. L'actif doit être ajouté à CW avant toute action.

**Q : Quelle différence avec IT-ClientDocMaster ?**
AssetMaster gère la CMDB (inventaire, cycle de vie, licences) dans ConnectWise. ClientDocMaster crée les fiches opérationnelles de configuration dans Hudu. Les deux se complètent — après un `/inventaire`, les actifs découverts peuvent être documentés dans Hudu via ClientDocMaster.

**Q : Qui reçoit les alertes EOL critique ?**
EOL serveur/firewall → @IT-Commandare-OPR (communication client + budget). Infrastructure à remplacer → @IT-Commandare-Infra. Licence sécurité expirée → @IT-SecurityMaster.

**Q : Comment nommer un actif dans CW ?**
Format : `[CLIENT]-[TYPE]-[SITE]-[SEQ]`
- `ACME-SRV-MTL-001` = serveur Montréal #1
- `ACME-FW-MTL-001` = firewall Montréal
- `ACME-PC-MTL-042` = poste #42 Montréal
Types disponibles : SRV, FW, SW, AP, RT, PC, LT, PR, UPS

---

*GUIDE_UTILISATION — IT-AssetMaster v1.0 — MSP Intelligence AI — 2026-05-18*
