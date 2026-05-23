# BUNDLE_KP_AssistanTI-N2_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** IT-Assistant-N2
**Usage :** Uploader en Knowledge dans le GPT IT-Assistant-N2
**Contenu :** Procédures N1/N2 guidées + vérifications identité + scripts + escalades + templates CW
**Mis à jour :** 2026-03-24

---

## POSTURE SUPPORT TÉLÉPHONIQUE

Le technicien a le client **au téléphone**. Chaque réponse doit être :
- **Immédiatement actionnable** — pas de théorie, des étapes numérotées
- **Proactive** — anticiper l'erreur suivante avant qu'elle arrive
- **Protectrice** — les NE PAS FAIRE apparaissent AVANT l'étape risquée
- **Validée** — chaque étape se termine par « qu'est-ce que tu vois ? »

---

## GRILLE DE TRIAGE & PRIORITÉ

| Priorité | Scénario | Action N2 |
|---|---|---|
| **P1 CRITIQUE** | Ransomware, breach, compte admin compromis | ESCALADE OBLIGATOIRE → SOC |
| **P1 CRITIQUE** | Réseau site down, serveur critique inaccessible | ESCALADE OBLIGATOIRE → NOC |
| **P2 URGENT** | M365 inaccessible tous utilisateurs | ESCALADE → TECH |
| **P2 URGENT** | VPN down plusieurs utilisateurs | ESCALADE → NOC |
| **P2 URGENT** | Messagerie arrêtée 1 user, client en attente | Diagnostic Outlook — 20 min max |
| **P3 NORMAL** | MDP, accès dossier, imprimante | Intervention standard |
| **P4 FAIBLE** | Demande informationnelle | Répondre ou rediriger |

---

## PROCÉDURES DÉTAILLÉES PAR TYPE

### A. MOT DE PASSE / COMPTE VERROUILLÉ

**⚠️ VÉRIFICATION IDENTITÉ OBLIGATOIRE — 2 méthodes avant toute action**

Méthodes acceptées :
- Numéro d'employé ou matricule
- Date d'embauche
- Nom du superviseur direct
- Rappeler sur le numéro officiel du dossier (pas celui fourni par l'appelant)

**Réinitialisation MDP — Active Directory :**

ÉTAPES :
1. Ouvrir Active Directory Users and Computers
   Validation : tu vois la liste des OUs du domaine
2. Trouver le compte — chercher par nom ou courriel
3. Clic droit > Properties > Account tab
   Validation : « Account is locked out » coché ou non
4. Si verrouillé : décocher « Account is locked out » > OK
   Validation : la coche disparaît
5. Si réinitialisation requise : Clic droit > Reset Password
   Cocher « User must change password at next logon »
   Validation : message « Password has been changed »
6. Tester la connexion avec l'utilisateur
   Validation : l'utilisateur se connecte et est invité à changer son MDP

NE PAS donner le nouveau MDP par courriel — dire verbalement seulement
NE PAS désactiver « User must change password at next logon » sans autorisation
NE PAS réinitialiser un compte admin sans approbation superviseur

**Réinitialisation MDP — M365 / Entra ID :**

ÉTAPES :
1. Ouvrir admin.microsoft.com
2. Utilisateurs > Utilisateurs actifs > trouver l'utilisateur
3. Cliquer > Réinitialiser le mot de passe
4. Laisser M365 générer un MDP temporaire
   Cocher « Demander à cet utilisateur de changer son MDP à la prochaine connexion »
5. Communiquer verbalement le MDP temporaire
6. L'utilisateur se connecte sur portal.office.com pour le changer
   Validation : connexion réussie

NE PAS envoyer le MDP temporaire par courriel

---

### B. ACCÈS REFUSÉ — DOSSIER OU PARTAGE

**⚠️ RÈGLE FONDAMENTALE**

NE JAMAIS modifier les permissions directement sur un dossier ou fichier
NE JAMAIS cocher « Appliquer aux sous-dossiers » — tu écrases toute la structure
NE JAMAIS ajouter l'utilisateur individuellement — utiliser uniquement les groupes AD

**Étape 0 — Vérification d'autorisation AVANT TOUT**

1. Consulter la fiche client dans Hudu (edocs) — identifier le responsable du dossier
2. Contacter le superviseur de l'utilisateur — obtenir confirmation **écrite** avant de continuer
   NE PAS donner l'accès sur la parole de l'utilisateur lui-même

ÉTAPES (après confirmation reçue) :
1. Clic droit sur le dossier > Propriétés > Sécurité
   Identifier le groupe AD qui contrôle l'accès (ex: GRP_Finance_Lecture)
2. Ouvrir AD Users and Computers > trouver le groupe
3. Clic droit > Properties > Members > Add > taper le nom > OK
   Validation : l'utilisateur apparaît dans Members
4. Demander à l'utilisateur de se déconnecter / reconnecter (ou gpupdate /force)
   Validation : accès au dossier sans erreur

---

### C. IMPRIMANTE / SCANNER

ÉTAPES :

**NIVEAU 1 — Vérifications de base (2 min)**
1. L'imprimante est-elle allumée ? Voyants normaux ?
2. Câble branché des deux côtés ?
3. Papier ? Encre / toner ?

**NIVEAU 2 — File d'attente et spooler**
4. Panneau de configuration > Périphériques et imprimantes
5. Vérifier les jobs bloqués > Imprimante > Annuler tous les documents
6. Si toujours bloqué — redémarrer le spooler :
```powershell
Restart-Service Spooler -Force
Get-PrintJob -PrinterName * | Remove-PrintJob
```
Validation : service redémarre sans erreur

**NIVEAU 3 — Driver et connectivité réseau**
7. Imprimer une page de configuration depuis l'imprimante elle-même
   Si ça s'imprime → problème côté PC, pas imprimante
8. Si problème driver : désinstaller > réinstaller depuis serveur d'impression

NE PAS redémarrer le serveur d'impression sans vérifier si d'autres l'utilisent
NE PAS modifier les paramètres réseau de l'imprimante sans passer par INFRA

---

### D. OUTLOOK / COURRIEL

**Étape 0 — Isoler client vs serveur TOUJOURS en premier**
« Est-ce que d'autres utilisateurs ont le même problème ? »
- OUI → problème serveur/M365 → escalade IT-Commandare-TECH
- NON → problème poste ou profil → continuer

**Outlook ne s'ouvre pas / plante :**

ÉTAPES :
1. Outlook en mode sans échec :
   Windows + R > `outlook.exe /safe` > Entrée
   Validation : Outlook s'ouvre (indiqué dans la barre de titre)
   Si ça fonctionne : un add-in est la cause → désactiver un par un
2. Vérifier le profil :
   Panneau de configuration > Courrier > Afficher les profils
   Créer un nouveau profil de test
3. Vérifier les mises à jour Office :
   Fichier > Compte Office > Mettre à jour maintenant

NE PAS supprimer le profil existant avant d'avoir créé et testé le nouveau
NE PAS réparer Office sans prévenir l'utilisateur (ferme toutes les apps Office)

**Outlook ne reçoit / n'envoie pas :**

ÉTAPES :
1. Tester le webmail : outlook.office.com
   Si webmail fonctionne → problème client Outlook
   Si webmail ne fonctionne pas → escalade IT-Commandare-TECH
2. Vérifier mode Hors connexion :
   Onglet Envoi/Réception > « Travailler hors connexion » — doit être inactif
3. Vérifier statut connexion :
   Icône Outlook en bas à droite > « Connecté Microsoft Exchange »

---

### E. POSTE LENT / GELÉ

ÉTAPES :
1. Vérifier CPU et RAM :
   Clic droit barre des tâches > Gestionnaire des tâches > Performances
   Si CPU > 90% ou RAM > 90% → étape 2
2. Identifier le processus gourmand :
   Onglet Processus > trier par CPU ou Mémoire
   Windows Update en cours ? → normal, attendre
   Antivirus en scan ? → normal, attendre
   Processus inconnu ? → [À CONFIRMER] avant toute action
3. Si processus planté :
   Clic droit > Fin de tâche
   NE PAS terminer : svchost.exe, lsass.exe, csrss.exe, winlogon.exe → crash immédiat
4. Vérifier espace disque :
   Explorateur > Ce PC > disque C: — doit avoir > 10% libre (barre bleue)
   Si rouge (< 10%) : vider corbeille + dossier TEMP
5. Redémarrage si rien ne fonctionne :
```
⚠️ Cette action va fermer toutes les applications ouvertes.
Demander à l'utilisateur de sauvegarder son travail d'abord.
Confirmes-tu le redémarrage ? (oui / non)
```
NE PAS redémarrer de force si des fichiers sont ouverts → risque corruption

---

### F. VPN UTILISATEUR

ÉTAPES :
1. Vérifier Internet de base :
   Ouvrir navigateur > google.com
   Si pas d'Internet → problème réseau local, pas VPN
2. Vérifier les identifiants VPN :
   Le MDP AD a-t-il changé récemment ? Utilise-t-il les bons identifiants ?
3. Vérifier le MFA / DUO :
   L'utilisateur reçoit-il la notification sur son téléphone ?
4. Redémarrer le client VPN :
   Fermer complètement > rouvrir > retenter
   Validation : connexion réussie
5. Si toujours en échec :
   Capturer le message d'erreur exact
   Escalade IT-Commandare-TECH avec le message d'erreur

NE PAS modifier la configuration VPN (serveur, protocole) → c'est INFRA
NE PAS désinstaller/réinstaller le client VPN sans autorisation

---

### G. SHAREPOINT / ONEDRIVE / TEAMS

**⚠️ Même règle que les dossiers partagés :**
NE JAMAIS donner l'accès sans confirmation écrite du propriétaire du site / de l'équipe Teams.

**Accès refusé SharePoint (après autorisation reçue) :**

ÉTAPES :
1. admin.microsoft.com > SharePoint > trouver le site
2. Gérer les membres > ajouter l'utilisateur au groupe approprié :
   Membres = lecture/écriture | Propriétaires = contrôle total | Visiteurs = lecture seule
3. L'utilisateur attend 5 min et réessaie
   Validation : accès sans erreur

NE PAS modifier les permissions au niveau d'un fichier individuel
NE PAS ajouter l'utilisateur en tant que propriétaire sans autorisation explicite

---

## RÈGLE ANTI-ERREUR RMM — Scripts PowerShell

Ne jamais utiliser `Write-Host ""` → utiliser `Write-Host " "` (espace)

Helpers Log/TeeLine — format obligatoire :
```powershell
function Log {
    param([AllowEmptyString()][string]$Text = "", [string]$Color = "White")
    Write-Host $(if ([string]::IsNullOrEmpty($Text)) { " " } else { $Text }) -ForegroundColor $Color
}
```

param() — valeur par défaut non vide obligatoire :
```powershell
param([string]$Serveur = $env:COMPUTERNAME)   # ✅ CORRECT
```

---

## TEMPLATES ESCALADE (/escalade)

### Bloc transfert → NOC
```
[TRANSFERT DÉPARTEMENT NOC]
Billet : #[XXXXXX] | Priorité : P[1/2] | [YYYY-MM-DD HH:MM]
Technicien N2 : [NOM]

SYMPTÔME : [Description précise]
IMPACT : [Utilisateurs affectés / services impactés]
ACTIONS N2 TENTÉES :
  1. [Action — résultat]
  2. [Action — résultat]
ASSETS : [Liste équipements/serveurs concernés]
```

### Bloc transfert → SOC
```
[TRANSFERT DÉPARTEMENT SOC]
Billet : #[XXXXXX] | Priorité : P1 | [YYYY-MM-DD HH:MM]
Type : ☐ Phishing  ☐ Compromission  ☐ Ransomware  ☐ Autre

COMPTE AFFECTÉ : [voir Passportal — ne pas noter ici]
SYMPTÔMES : [Description]
ACTIONS EFFECTUÉES :
  ☐ Compte désactivé
  ☐ Sessions révoquées
  ☐ Règles Outlook vérifiées
```

### Bloc transfert → TECH
```
[TRANSFERT DÉPARTEMENT TECH — N3 requis]
Billet : #[XXXXXX] | Priorité : P[2/3] | [YYYY-MM-DD HH:MM]
Technicien N2 : [NOM] | Durée intervention : [X min]

PROBLÈME : [Description précise]
DIAGNOSTIC EFFECTUÉ :
  1. [Étape — résultat]
  2. [Étape — résultat]
BLOCAGE : [Pourquoi N2 ne peut pas résoudre]
```

---

## CHECKLIST INTERVENTION N2

**Kickoff :**
- [ ] Lire billet CW complet
- [ ] Consulter Hudu (edocs) du client
- [ ] Vérifier identité si MDP (2 méthodes)
- [ ] P1 détecté → escalade immédiate avant tout

**Pendant :**
- [ ] 1 étape à la fois — confirmation à chaque étape
- [ ] NE PAS FAIRE affiché avant chaque étape risquée
- [ ] [À CONFIRMER] si info non vérifiable

**Clôture :**
- [ ] Résolution confirmée par l'utilisateur
- [ ] /close → CW Discussion + Note Interne
- [ ] /kb si P1/P2 ou nouveau type de problème

---

## ESCALADES RAPIDES

| Situation | Destination | Délai |
|---|---|---|
| Ransomware / malware / breach / phishing | SOC | Immédiat |
| Réseau site / infra critique / backup | NOC | Immédiat |
| DC / AD avancé / serveur | INFRA | Immédiat |
| Bloqué > 20 min | TECH (N3) | Après 2e tentative |
| M365 tenant down | TECH | Immédiat |
| > 5 users impactés | NOC ou TECH | < 10 min |

---

## RÈGLES ABSOLUES

1. **JAMAIS** de MDP, tokens, clés API dans les livrables — Passportal uniquement
2. **JAMAIS** d'IP dans les livrables clients
3. **Identité vérifiée** (2 méthodes) avant toute réinitialisation de MDP
4. **Autorisation écrite** obtenue avant tout changement d'accès à un dossier/site
5. **Lecture seule en premier** — confirmer avant d'agir
6. **P1 → escalade immédiate** — aucune tentative de résolution solo
