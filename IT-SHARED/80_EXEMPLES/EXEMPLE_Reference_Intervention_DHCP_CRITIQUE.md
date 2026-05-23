# Cas de référence — Alerte DHCP capacité élevée / BAD_ADDRESS récurrents

## Objet
Document de référence interne basé sur une intervention réelle de diagnostic DHCP afin de servir de modèle pour les cas similaires :
- alerte NOC « DHCP Scope 95 % / 100 % »
- étendue presque saturée
- présence de `BAD_ADDRESS` / `Declined`
- besoin de distinguer **déchet DHCP** vs **équipement réellement actif**
- besoin de conclure rapidement si le problème est **ponctuel** ou **structurel**

---

## Contexte source
- **Client** : St-Jerome Chevrolet
- **Billet initial** : #1734264
- **Billet de revalidation** : #1739615
- **Intervention initiale** : 2026-04-28
- **Revalidation** : 2026-05-04
- **Serveur concerné** : DC01
- **Service concerné** : DHCP Server
- **Étendue principale analysée** : `10.60.0.0`
- **Nom de l’étendue** : `V1-CHEVROLET-DATA`

> Note : la deuxième intervention a eu lieu la semaine suivant l’intervention initiale. Le problème était toujours présent lors de la revalidation.

---

## Symptôme initial
Le monitor NOC signalait une étendue DHCP en saturation critique sur l’étendue DATA du site.

Exemple de signalement initial :
- **Free** : 1
- **InUse** : 190

Après validation manuelle pendant l’intervention :
- **Free** : 10 puis 8 lors de la revalidation
- **InUse** : 181 puis 183
- **Reserved** : 58
- **PercentageInUse** : ~94,76 % puis ~95,81 %

---

## Résumé technique du cas
### État confirmé
- Le service **DHCPServer** était **Running / Automatic**
- L’étendue concernée était **Active**
- Le problème était **localisé à l’étendue DATA**, pas à tout le service DHCP
- Les autres étendues Chevrolet n’étaient pas en surcharge comparable
- La durée des baux était déjà courte : **2 heures**
- La pression sur le pool était aggravée par :
  - **58 réservations**
  - **35 exclusions**
  - plusieurs `BAD_ADDRESS` / `Declined`
  - quelques entrées incohérentes ou stale

### Résultat clé
Le problème n’était **pas** une panne DHCP.  
Le problème était une **pression de capacité sur l’étendue**, avec en plus des **conflits IP / bad leases**.

---

## Démarche appliquée
## 1) Validation lecture seule du service et du scope
Vérifications faites :
- état du service DHCP
- configuration de l’étendue
- statistiques de l’étendue
- répartition des baux par état
- événements DHCP récents

### Constat
- Service DHCP sain
- Scope actif
- Aucun indice d’incident global du rôle DHCP
- Saturation réelle du scope DATA

---

## 2) Vérification des autres scopes du même client
Objectif :
- déterminer si le problème était global au serveur DHCP ou limité à un VLAN / scope

### Constat
Seule l’étendue **DATA** Chevrolet était réellement en tension.
Les autres scopes du client étaient dans un état acceptable.

---

## 3) Analyse des réservations et exclusions
Vérifications faites :
- plages d’exclusion
- réservations complètes
- nombre de réservations
- réservations inactives

### Constat
Le pool utile était fortement réduit par :
- **58 réservations**
- **35 exclusions**

Présence de **5 InactiveReservation** lors de l’analyse.

---

## 4) Analyse des `BAD_ADDRESS` / `Declined`
Vérifications faites :
- extraction des leases `BAD_ADDRESS`
- validation de la présence réelle des IP par ping
- distinction entre :
  - entrées stale / fantômes
  - adresses réellement actives sur le réseau

### Cas identifiés
Des `BAD_ADDRESS` étaient présents, dont notamment :
- des IP qui **répondaient au ping** → présomption d’équipement actif / conflit réel / IP statique
- des IP **hors plage active**, avec horodatage ancien et ne répondant pas → présomption d’entrées stale

### Action sécuritaire appliquée
Seules les IP répondant aux critères suivants ont été nettoyées :
- hors plage active
- pas de réservation
- pas d’exclusion
- ne répondent pas au ping
- stale / incohérentes

Dans ce cas :
- **.252** et **.253** ont été supprimées des `BadLeases`
- **.21** et **.240** n’ont **pas** été supprimées car elles semblaient correspondre à des équipements actifs / conflits réels

---

## 5) Pivot réseau / passerelle L3
Quand une IP `BAD_ADDRESS` répond au ping mais n’est ni en réservation ni en exclusion, la logique DHCP ne suffit plus.

### Démarche appliquée
- récupération de la passerelle de l’étendue via l’option DHCP
- identification du VLAN concerné
- recommandation de vérifier l’ARP / voisinage **sur la passerelle L3 / firewall / switch**, et non depuis le DC

### Raison
Le serveur DHCP / DC n’est pas toujours le bon point d’observation pour retrouver le MAC réel d’un équipement actif.

---

## Constat final de l’intervention initiale
### Ce qui a été confirmé
- service DHCP opérationnel
- étendue DATA presque saturée
- autres scopes du client non critiques
- présence d’entrées bad/stale
- présence de conflits / IP actives non à supprimer à l’aveugle
- situation de fond **structurelle**

### Ce qui a été fait
- collecte complète en lecture seule
- nettoyage ciblé de 2 `BadLeases` stale
- validation post-nettoyage

### Ce qui n’a pas été fait
- aucun élargissement de plage
- aucune suppression d’IP actives en conflit
- aucune modification risquée sans validation réseau / projet

---

## Constat lors de la revalidation (semaine suivante)
La semaine suivante, une nouvelle alerte a été reçue sur la même étendue.

### Revalidation rapide
- service DHCP toujours sain
- scope toujours actif
- **Free = 8**
- **InUse = 183**
- **Reserved = 58**
- **PercentageInUse ≈ 95,81 %**
- **Declined = 3**

### Conclusion de revalidation
Le problème était **toujours présent**.  
Aucune amélioration structurelle n’avait été apportée.  
Le cas devait être traité comme un **enjeu de capacité / design**, pas comme un simple incident ponctuel.

---

## Leçons à retenir pour les cas similaires
### À faire
1. **Lecture seule d’abord**
2. Vérifier si le problème est **localisé à un scope** ou **global au service**
3. Vérifier :
   - service DHCP
   - config du scope
   - stats
   - réservations
   - exclusions
   - `BadLeases`
   - autres scopes du client
4. Ne supprimer que les `BadLeases` clairement **stale**
5. Si une IP `BAD_ADDRESS` répond au ping, **ne pas supprimer à l’aveugle**
6. Basculer vers la **passerelle L3** pour identifier le MAC / port réel
7. Si l’alerte revient quelques jours plus tard sans changement de fond, conclure :
   - **état inchangé**
   - **aucune amélioration structurelle**
   - **mise en projet recommandée**

### À éviter
- supprimer des `BAD_ADDRESS` encore actives sans validation
- conclure trop vite à un problème purement DHCP
- modifier la plage ou les exclusions sans revue plus large
- traiter ce type de cas récurrent comme un simple incident ponctuel

---

## Indicateurs qui pointent vers un problème structurel
- étendue > 95 %
- nombre élevé de réservations
- nombre élevé d’exclusions
- retour récurrent des alertes
- `Declined` persistants
- équipements actifs dans / autour du pool
- besoin de revoir l’adressage statique ou la taille réelle du pool

---

## Scripts / commandes utiles utilisés dans ce cas
### Validation de base
- `Get-Service DHCPServer`
- `Get-DhcpServerv4Scope`
- `Get-DhcpServerv4ScopeStatistics`
- `Get-DhcpServerv4Lease`
- `Get-DhcpServerv4Lease -BadLeases`
- `Get-DhcpServerv4Reservation`
- `Get-DhcpServerv4ExclusionRange`
- `Get-DhcpServerv4OptionValue -OptionId 3`

### Validation réseau / cohérence
- `Resolve-DnsName -Type PTR`
- `Test-Connection`
- `Get-NetNeighbor`
- vérification ARP / voisinage sur la passerelle L3

---

## Runbooks utilisés / référencés
### Utilisés directement ou comme cadre de travail
1. **GUARDRAILS__IT_AGENTS_MASTER.md**  
   Utilisé comme garde-fou de conduite :
   - lecture seule d’abord
   - zéro invention
   - une action à la fois
   - pas de suppression risquée sans validation

2. **TEMPLATE_BUNDLE_CW_CLOSE.md**  
   Utilisé pour structurer les livrables de fermeture :
   - note interne
   - discussion CW
   - email client
   - formulation client-safe

### Référencés pendant l’intervention
3. **RUNBOOK_MENU_CONTEXTUEL_V4.md**  
   Utilisé pour repérer les références internes disponibles.

4. **BUNDLE_RUNBOOK_INFRA_Firewall-VPN_V1.md**  
   Référencé lorsque l’analyse a dû pivoter du DHCP vers l’identification réseau / passerelle / ARP / firewall.

5. **INFRA-AD-DC_PrePost_Validation_V2.md**  
   Référencé comme garde-fou car le rôle DHCP était hébergé sur un **DC**.
   Aucun reboot ni changement intrusive n’a été effectué dans ce cas.

### Important
- **Aucun runbook DHCP dédié explicite n’a été identifié dans le knowledge disponible pendant cette intervention.**
- Le cas a donc été traité à partir :
  - des commandes DHCP natives
  - des garde-fous
  - du bundle de fermeture CW
  - des références réseau pour la partie ARP / passerelle

---

## Décision recommandée pour les cas similaires
### Si amélioration ponctuelle seulement
Fermer l’incident avec :
- état validé
- correctif minimal documenté
- surveillance maintenue

### Si l’alerte revient et que rien de structurel n’a changé
Recommander une **mise en projet** pour :
- révision de capacité DHCP
- revue des exclusions
- revue des réservations
- validation des IP statiques réelles
- nettoyage documentaire
- décision sur élargissement de plage / redesign du segment

---

## Formulation type de conclusion interne
> Le service DHCP est fonctionnel et l’étendue concernée demeure active, mais la capacité disponible reste très serrée.  
> La situation observée est cohérente avec une pression structurelle sur le pool, aggravée par le volume de réservations, d’exclusions et par la présence de conflits / bad leases.  
> Un correctif ponctuel peut soulager marginalement la situation, mais une révision structurée de l’étendue demeure recommandée pour corriger le problème de façon durable.

---

## Statut de ce cas de référence
**Référence valide** pour les billets de type :
- DHCP scope 95 %
- DHCP scope 100 %
- BAD_ADDRESS récurrents
- conflict / declined + ping positif
- saturation locale d’un scope sans panne globale du service
