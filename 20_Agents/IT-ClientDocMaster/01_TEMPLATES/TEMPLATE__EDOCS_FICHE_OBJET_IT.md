# TEMPLATE — Fiches Objet IT (edocs)

**Usage :** Coller le contenu de la fiche correspondante dans l'éditeur edocs.
Chaque objet IT = une fiche distincte. Les liaisons sont des liens hypertexte vers d'autres fiches edocs.

> ⚠️ Règles absolues :
> - **Zéro mot de passe** — les identifiants vivent dans Passportal. Indiquer le compte à utiliser, pas le secret.
> - **Zéro IP interne** dans les sections visibles client.
> - Chaque champ `[À COMPLÉTER]` doit être rempli avant publication. Jamais laisser un champ vide publié.
> - Les liaisons `→` indiquent une dépendance réelle. Ne pas créer de liaison sans vérification.

---

## TYPE : APPLICATION

```
FICHE : APPLICATION
Nom               : [Nom de l'application]
Éditeur / Vendor  : [Éditeur]
Version actuelle  : [X.X.X]
URL d'accès       : [URL ou N/A si local]
Type de déploiement : [ ] On-premise  [ ] Cloud  [ ] Hybride

DESCRIPTION
[1-2 phrases : à quoi ça sert pour le client]

COMPTES & ACCÈS
Compte admin      : [Nom du compte — identifiant dans Passportal]
Compte service    : [Nom du compte — identifiant dans Passportal]
Accès console     : [Comment y accéder : RDP / URL / VPN requis?]

PROCÉDURES CLÉS
Mise à jour       : [Étapes de mise à jour OU → lien vers fiche PROCÉDURE]
Redémarrage       : [Ordre de redémarrage des services / serveurs]
Restauration      : [Procédure de restauration OU → lien vers fiche PROCÉDURE]

LIAISONS MONTANTES (dépend de)
→ [Nom fiche Serveur hébergeant l'application]
→ [Nom fiche Licence associée]
→ [Nom fiche Backup de ce serveur]

LIAISONS DESCENDANTES (est utilisé par)
→ [Nom fiche autre application qui en dépend, si applicable]

NOTES TECHNIQUES
[Particularités, contraintes, points d'attention]

DERNIÈRE MISE À JOUR
Date    : [YYYY-MM-DD]
Par     : [Technicien]
Ticket  : [#CW si applicable]
```

---

## TYPE : SERVEUR

```
FICHE : SERVEUR
Nom du serveur    : [NomMachine]
Rôle principal    : [Ex: Contrôleur de domaine / SQL / RDS / Fichiers / Hyperviseur]
Rôles secondaires : [Ex: DNS, DHCP, Print Server]
OS                : [Windows Server 20XX — Standard/Datacenter]
Version build     : [YYYY-MM-DD ou numéro de build]
Emplacement       : [ ] On-premise  [ ] VM (hyperviseur: [NomHost])  [ ] Cloud Azure

SPÉCIFICATIONS
CPU               : [Ex: 4 vCPU]
RAM               : [Ex: 16 GB]
Stockage          : [Ex: C: 100GB (OS), D: 500GB (Données)]

ACCÈS
Accès admin       : [Compte à utiliser — identifiant dans Passportal]
Accès RDP         : [ ] Direct  [ ] VPN requis  [ ] Jump server : [Nom]
Console hyperviseur : [Nom hyperviseur / URL vSphere ou Hyper-V]

RÔLE CRITIQUE
[ ] Oui — Impact majeur si hors service
[ ] Non — Services redondants disponibles

APPLICATIONS HÉBERGÉES
→ [Nom fiche Application 1]
→ [Nom fiche Application 2]

LIAISONS MONTANTES (dépend de)
→ [Nom fiche Hyperviseur, si VM]
→ [Nom fiche Domaine / AD, si joint au domaine]

LIAISONS DESCENDANTES (sert à)
→ [Nom fiche Backup de ce serveur]
→ [Noms fiches des applications hébergées]

NOTES TECHNIQUES
[Particularités : ex. EntraID Sync actif sur ce serveur, rôle FSMO, etc.]

DERNIÈRE MISE À JOUR
Date    : [YYYY-MM-DD]
Par     : [Technicien]
Ticket  : [#CW si applicable]
```

---

## TYPE : BACKUP

```
FICHE : BACKUP
Nom de la fiche   : [Ex: Backup VEEAM — NomClient]
Solution          : [ ] VEEAM  [ ] Datto  [ ] Azure Backup  [ ] Autre: [___]
Type              : [ ] On-premise  [ ] Cloud  [ ] Hybride

--- SI VEEAM ---
Serveur VEEAM     : [Nom du serveur — → lien fiche Serveur]
Console           : [URL ou RDP + chemin]
Compte d'accès    : [Compte à utiliser — identifiant dans Passportal]
Dépôt primaire    : [Emplacement + capacité]
Dépôt secondaire  : [Emplacement + capacité, ou N/A]
Sauvegarde externe: [OU / Comment — Ex: rotation disques USB, répertoire réseau]

--- SI DATTO ---
Portail Datto     : [URL portail]
Compte Datto      : [Quel compte — identifiant dans Passportal]
Appliance locale  : [Nom/modèle] ou N/A
Rétention cloud   : [Ex: 1 an]

PLANIFICATION
Fréquence         : [Ex: Quotidien 23h00, hebdo image complète]
Rétention locale  : [Ex: 30 jours]
Rétention externe : [Ex: 90 jours]

TEST DE RESTAURATION
Fréquence test    : [Ex: Mensuel]
Dernier test OK   : [YYYY-MM-DD]
Procédure test    : [→ lien fiche PROCÉDURE ou étapes courtes]

ALERTES
Destinataires alerte : [Email(s) qui reçoivent les alertes d'échec]

LIAISONS MONTANTES (protège)
→ [Nom fiche Serveur 1]
→ [Nom fiche Serveur 2]

NOTES TECHNIQUES
[Exclusions, particularités, jobs spéciaux]

DERNIÈRE MISE À JOUR
Date    : [YYYY-MM-DD]
Par     : [Technicien]
Ticket  : [#CW si applicable]
```

---

## TYPE : LICENCE

```
FICHE : LICENCE
Produit           : [Nom du produit licencié]
Éditeur           : [Éditeur / Vendor]
Type de licence   : [Ex: Perpétuelle / Abonnement annuel / Par utilisateur / Par appareil]
Nombre de licences: [X unités]
Date d'expiration : [YYYY-MM-DD ou N/A si perpétuelle]
Renouvellement    : [Automatique / Manuel — X jours avant expiration]

ACHAT & CONTACT
Acheté via        : [Revendeur ou direct]
Contact vendeur   : [Nom / Email / Tél]
Numéro de contrat : [Réf. contrat ou N/A]

CLÉ / NUMÉRO DE SÉRIE
Emplacement clé   : [Passportal — entrée : NomEntrée] ou [→ lien fiche Compte/Accès]

LIAISON APPLICATION
→ [Nom fiche Application associée à cette licence]

NOTES
[Restrictions, conditions particulières, modules inclus]

DERNIÈRE MISE À JOUR
Date    : [YYYY-MM-DD]
Par     : [Technicien]
Ticket  : [#CW si applicable]
```

---

## TYPE : PROCÉDURE

```
FICHE : PROCÉDURE
Titre             : [Action à effectuer — Ex: Mise à jour Maestro]
Système concerné  : [Application / Serveur / Service]
Fréquence         : [Ex: À chaque mise à jour / Mensuel / Ad hoc]
Niveau requis     : [ ] N1  [ ] N2  [ ] N3
Durée estimée     : [X minutes]

PRÉREQUIS
- [Prérequis 1 — ex: snapshot pris avant]
- [Prérequis 2 — ex: avertir le client]
- [Prérequis 3 — ex: fenêtre maintenance confirmée]

ÉTAPES
1. [Action précise]
   Validation : [Comment vérifier que c'est OK]
2. [Action précise]
   Validation : [Comment vérifier]
3. [...]

VALIDATION FINALE
- [ ] [Test 1]
- [ ] [Test 2]

ROLLBACK / ANNULATION
[Comment annuler / revenir en arrière si échec]

EN CAS D'ÉCHEC
→ Escalader à : [Rôle ou agent — ex: IT-AssistanTI_N3]
→ Ticket à ouvrir : [Catégorie CW suggérée]

LIAISONS
→ [Nom fiche Application concernée]
→ [Nom fiche Serveur concerné]

DERNIÈRE MISE À JOUR
Date    : [YYYY-MM-DD]
Par     : [Technicien]
Ticket  : [#CW si applicable]
```

---

## TYPE : RÉSEAU / PARE-FEU

```
FICHE : RÉSEAU
Composant         : [Ex: Pare-feu Watchguard / Switch Core / VPN]
Modèle            : [Modèle exact]
Firmware          : [Version actuelle]
Emplacement       : [Salle serveur / Rack X / Cloud]

ACCÈS ADMINISTRATION
Console admin     : [URL ou IP interne]
Compte admin      : [Compte à utiliser — identifiant dans Passportal]
Accès hors-site   : [VPN requis? Comment?]

CONFIGURATION CLÉS
VPN               : [Type / utilisateurs concernés / → fiche PROCÉDURE connexion VPN]
Règles critiques  : [Résumé des règles importantes — ex: port 443 ouvert vers SRV-APP01]
VLAN              : [Liste si applicable]

LIAISONS MONTANTES (connecté à)
→ [Nom fiche FAI / Connexion Internet]
→ [Nom fiche hyperviseur si virtuel]

LIAISONS DESCENDANTES (dessert)
→ [Nom fiche Switch(es)]
→ [Nom fiche Serveurs critiques]

NOTES TECHNIQUES
[Particularités, contrat de support, numéro de série]

DERNIÈRE MISE À JOUR
Date    : [YYYY-MM-DD]
Par     : [Technicien]
Ticket  : [#CW si applicable]
```

