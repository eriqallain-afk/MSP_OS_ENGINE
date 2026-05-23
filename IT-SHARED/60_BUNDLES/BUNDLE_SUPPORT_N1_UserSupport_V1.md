# BUNDLE_SUPPORT_N1_UserSupport_V1
**Catégorie :** Support N1 — Premier contact et résolution rapide
**Agents :** @IT-FrontLine | @IT-Assistant-N2 | @IT-Commandare-NOCDispatcher | IT-MaintenanceMaster | IT-SysAdmin
**Version :** 1.0 | **Date :** 2026-04-05

---

## RB-N1-001 — Réinitialisation de mot de passe (MDP Reset)

**Durée estimée :** 5 min | **Priorité :** P3/P4

### Prérequis
- Vérifier l'identité de l'utilisateur (ticket CW + confirmation manager si nécessaire)
- Accès Active Directory ou M365 Admin Center

### Étapes AD On-Premise
1. Ouvrir **Active Directory Users and Computers** (ADUC)
2. Rechercher le compte : `Ctrl+F` → saisir le nom
3. Clic droit sur le compte → **Reset Password**
4. Saisir le nouveau MDP temporaire (respecter la politique de complexité)
5. Cocher **User must change password at next logon** ✅
6. Cliquer **OK**
7. Vérifier que le compte n'est pas verrouillé (onglet Account → Unlock account si nécessaire)

### Étapes M365 / Entra ID
1. Ouvrir [admin.microsoft.com](https://admin.microsoft.com) → Users → Active Users
2. Rechercher l'utilisateur → cliquer son nom
3. Onglet **Account** → **Reset password**
4. Générer un MDP aléatoire ou saisir manuellement
5. Cocher **Require this user to change their password when they first sign in**
6. Cliquer **Reset password** → copier le MDP dans le ticket CW (Note Interne — jamais Discussion)
7. Communiquer le MDP par téléphone uniquement — jamais par email

### Validations post-action
- [ ] L'utilisateur peut se connecter avec le nouveau MDP
- [ ] Le MDP a bien été changé lors de la première connexion
- [ ] Aucun autre compte associé n'est impacté

### Escalade
- Compte verrouillé répétitivement → @IT-SecurityMaster (comportement suspect)
- Sync Entra Connect problématique → @IT-Assistant-N3

---

## RB-N1-002 — Création et gestion de compte utilisateur

**Durée estimée :** 15 min | **Priorité :** P3

### Prérequis
- Formulaire d'onboarding approuvé (nom, titre, département, manager, date début)
- Droits d'administration AD + M365

### Création compte AD
1. ADUC → clic droit sur l'OU correcte → New → User
2. Remplir : First name, Last name, User logon name (format standard : prénom.nom@domaine.com)
3. MDP initial temporaire → **User must change password at next logon** ✅
4. Ajouter aux groupes appropriés (département, applications métier)
5. Configurer le profil : téléphone, titre, département, manager, bureau

### Création compte M365
1. admin.microsoft.com → Users → Active Users → Add a user
2. Assigner la licence appropriée (Microsoft 365 Business Standard/E3/etc.)
3. Configurer Exchange Online (boîte aux lettres activée automatiquement)
4. Configurer MFA : Authentication methods → ajouter méthode principale
5. Groupes M365 et SharePoint selon le département

### Validations post-action
- [ ] Connexion Windows AD fonctionnelle
- [ ] Email envoi/réception fonctionnel
- [ ] MFA configuré et testé
- [ ] Accès applications métier validé
- [ ] Sync Entra Connect vérifiée (si hybride) — délai max 30 min

---

## RB-N1-003 — Dépannage imprimante réseau

**Durée estimée :** 10-20 min | **Priorité :** P3

### Diagnostic initial (poser ces questions)
- L'imprimante est-elle allumée et connectée au réseau ?
- Le problème touche un seul poste ou tous les postes ?
- Imprimante partagée (serveur print) ou IP directe ?
- Message d'erreur affiché ?

### Scénario A — Un seul poste impacté
1. Panneau de configuration → Devices and Printers
2. Clic droit sur l'imprimante → **See what's printing** → annuler tous les jobs en attente
3. Clic droit → **Properties** → **Print Test Page**
4. Si échec : supprimer et réajouter l'imprimante
   ```
   Ajouter imprimante → Ajouter via adresse IP ou nom d'hôte
   Entrer l'IP de l'imprimante → sélectionner le driver
   ```
5. Redémarrer le spouleur d'impression :
   ```
   services.msc → Print Spooler → Redémarrer
   ```

### Scénario B — Tous les postes impactés
1. Vérifier que l'imprimante est joignable :
   ```
   ping [IP_IMPRIMANTE]
   ```
2. Accéder à l'interface web de l'imprimante : `http://[IP_IMPRIMANTE]`
3. Vérifier l'état des consommables (toner, papier, tambour)
4. Redémarrer l'imprimante (éteindre 30 secondes)
5. Si imprimante partagée via serveur print → redémarrer le service Print Spooler sur le serveur

### Scénario C — Imprimante hors réseau
1. Vérifier câble réseau ou connexion Wi-Fi de l'imprimante
2. Vérifier que l'IP n'a pas changé (DHCP → envisager IP statique)
3. Imprimer la page de configuration réseau depuis l'imprimante (bouton physique)

### Validations post-action
- [ ] Page de test imprimée avec succès
- [ ] Tâche test depuis le poste utilisateur réussie
- [ ] Consommables > 15% restants

### Escalade
- Problème persistant → @IT-Assistant-N3 (configuration réseau avancée)
- Imprimante défectueuse → contacter le fournisseur de service (numéro dans Hudu)

---

## RB-N1-004 — Dépannage connectivité Wi-Fi / réseau

**Durée estimée :** 10 min | **Priorité :** P3

### Diagnostic rapide
```
# Sur le poste utilisateur :
ipconfig /all          → vérifier IP obtenue (169.x.x.x = pas de DHCP)
ping 8.8.8.8           → test connectivité Internet
ping [gateway]         → test passerelle
nslookup google.com    → test DNS
```

### Problème Wi-Fi — un seul poste
1. Déconnecter et reconnecter au SSID
2. Oublier le réseau et reconnecter (entrer le MDP Wi-Fi)
3. `ipconfig /release` puis `ipconfig /renew`
4. Désactiver/réactiver la carte réseau
5. Mettre à jour les drivers Wi-Fi si nécessaire

### Problème réseau — multiple postes
1. Vérifier que le switch/AP est allumé (voyants)
2. Escalader immédiatement → @IT-NetworkMaster si site entier impacté

### Validations post-action
- [ ] IP valide obtenue (pas 169.x.x.x, pas 0.0.0.0)
- [ ] Internet accessible
- [ ] Ressources réseau accessibles (partages, imprimantes)

---

## RB-N1-005 — Installation et configuration de logiciels standards

**Durée estimée :** 15-30 min | **Priorité :** P4

### Logiciels MSP standards (déployables via RMM)
| Logiciel | Méthode déploiement | Notes |
|---|---|---|
| Microsoft 365 Apps | M365 Admin → déploiement | Licence requise |
| Adobe Acrobat Reader | RMM script ou MSI | Gratuit |
| 7-Zip | RMM script | |
| Google Chrome | RMM script ou GPO | |
| VPN Client | Selon solution (WatchGuard, FortiClient) | Voir Passportal |
| Teams | Inclus M365 Apps | |

### Déploiement via RMM (N-able / CW)
1. Identifier le poste dans la console RMM
2. Policy ou script d'installation → exécuter sur le poste cible
3. Vérifier le statut d'exécution dans la console
4. Demander à l'utilisateur de confirmer l'installation

### Installation manuelle
1. Télécharger depuis la source officielle uniquement
2. Exécuter en tant qu'administrateur
3. Suivre l'assistant d'installation
4. Configurer selon les standards MSP (langue, options par défaut)
5. Tester le fonctionnement

### Validations post-action
- [ ] Logiciel lancé et fonctionnel
- [ ] Licences activées si applicable
- [ ] Mises à jour appliquées

---

## RB-N1-006 — Dépannage VPN client utilisateur

**Durée estimée :** 10-15 min | **Priorité :** P3

### Causes communes
1. Credentials expirés ou MDP changé récemment
2. Client VPN non à jour
3. Firewall local bloque le VPN
4. MFA requis mais non configuré

### Diagnostic WatchGuard Mobile VPN SSL
1. Vérifier que le service WatchGuard Mobile VPN est démarré
2. Confirmer les credentials (utiliser le nouveau MDP si récemment changé)
3. Vérifier la connexion Internet de base avant le VPN
4. Consulter les logs du client VPN (menu → View Logs)

### Diagnostic FortiClient
1. Vérifier la connexion Internet
2. Tester telnet sur le port VPN : `telnet [IP_FIREWALL] 443`
3. Réinstaller le client si les logs montrent des erreurs de certificat

### Escalade
- VPN down pour plusieurs utilisateurs → @IT-NetworkMaster
- Problème MFA → @IT-CloudMaster (si M365/Entra MFA)

---

## RB-N1-007 — Assistance applications métier (support de base)

**Durée estimée :** Variable | **Priorité :** P3

### Approche standard
1. Identifier l'application exacte et la version
2. Reproduire le problème avec l'utilisateur
3. Vérifier si d'autres utilisateurs sont impactés
4. Consulter la documentation Hudu du client pour l'application
5. Vérifier les logs d'application (Event Viewer → Application)

### Cas communs
- **Application ne s'ouvre pas** → réparer l'installation, vérifier les dépendances (.NET, VCREDIST)
- **Erreur de connexion base de données** → vérifier que SQL Server est démarré
- **Lenteur** → vérifier ressources système (RAM, CPU, disque)
- **Erreur de licence** → vérifier la date d'expiration et contacter l'éditeur

### Escalade systématique
- Application métier critique → @IT-Assistant-N3
- Erreur SQL ou base de données → @IT-Assistant-N3
- Application cloud (SaaS) → vérifier le statut du service (status page éditeur)
