MOI: /start Service Ticket #0001234 - Script Monitor - Windows Update pending reboot is triggered on CLT-SRV01 (WIN-CLT00001) ...
Otto Inc
Description initiale: ---##@@UpdateFromNOC@@##---
Original Ticket Subject: Script Monitor -  Windows Update pending reboot is triggered on CLT-SRV01  (WIN-CLT00001) at the site Main-MGMT  / Priority - Low

MOI: Le cient redémarre les serveurs lui-même, nous allons vérifier si tout est OK et lui envoyer un courriel 



GPT: Billet **#0001234** pris en charge.

**Triage**

* **Type** : vérification / maintenance légère suite à alerte NOC `Windows Update pending reboot`
* **Priorité** : **Low / P4**
* **Actif** : `CLT-SRV01` (`WIN-CLT00001`)
* **Contexte** : le client gère lui-même les redémarrages, donc la bonne approche ici est un **contrôle post-reboot en lecture seule**, puis communication client-safe. Le runbook recommande d’identifier les flags de pending reboot, valider l’uptime, l’espace disque, les services auto arrêtés et les Event Logs récents avant toute autre décision.  

**Action 1 — lecture seule uniquement**
À lancer sur **CLT-SRV01** pour confirmer si l’alerte est maintenant résolue et si le serveur est sain.

```powershell
$Start = (Get-Date).AddHours(-2)
$os = Get-CimInstance Win32_OperatingSystem

$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'

Write-Host "=== HOST / UPTIME ==="
[pscustomobject]@{
    Hostname      = $env:COMPUTERNAME
    OS            = $os.Caption
    LastBoot      = $os.LastBootUpTime
    UptimeDays    = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays,2)
} | Format-List

Write-Host " "
Write-Host "=== PENDING REBOOT FLAGS ==="
[pscustomobject]@{
    CBS_RebootPending           = $CBS
    WU_RebootRequired           = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending      = $CCM
    PendingReboot               = ($CBS -or $WU -or $PFR -or $CCM)
} | Format-List

Write-Host " "
Write-Host "=== DISKS ==="
Get-PSDrive -PSProvider FileSystem |
    Where-Object { $_.Used -gt 0 } |
    Select-Object Name,
        @{N='FreeGB';E={[math]::Round($_.Free/1GB,2)}},
        @{N='FreePct';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== AUTO SERVICES NOT RUNNING ==="
Get-Service |
    Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' } |
    Select-Object Name, DisplayName, Status, StartType |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== RECENT SYSTEM / APPLICATION ERRORS (2H) ==="
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First 20 TimeCreated, Id, ProviderName, Message |
    Format-Table -Wrap

Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First 20 TimeCreated, Id, ProviderName, Message |
    Format-Table -Wrap

Write-Host " "
Write-Host "=== LAST HOTFIXES ==="
Get-HotFix |
    Sort-Object InstalledOn -Descending |
    Select-Object -First 10 HotFixID, InstalledOn, Description |
    Format-Table -AutoSize

Write-Host " "
Write-Host "=== SQL SERVICES (IF PRESENT) ==="
Get-Service |
    Where-Object { $_.Name -match 'MSSQL|SQLSERVERAGENT|SQLAgent' } |
    Select-Object Name, Status, StartType |
    Format-Table -AutoSize
```

**Décision attendue après Action 1**

* Si `PendingReboot = False`, services OK, pas d’erreurs critiques post-reboot et monitoring revenu normal, on clôture en **vérification complétée / aucun correctif appliqué**. Le template de clôture demande justement de confirmer **services**, **monitoring**, **backups si applicable** et **validation utilisateur si applicable**. 
* Si `PendingReboot = True`, il faut documenter **quel flag** reste actif. Le runbook dit d’escalader si, après deux redémarrages, le flag **CBS** persiste.  

**Notice Teams**

Objet : ⚠️ Vérification en cours – CLT-SRV01 (DB) (Ticket #0001234)
Client : Otto Inc

Intervention en cours pour validation de l’alerte Windows Update / pending reboot sur le serveur CLT-SRV01.

⏱️ Impact : aucun impact prévu à ce stade. Vérifications en lecture seule seulement. Aucun redémarrage effectué par notre équipe.

Merci.

@NOC

**CW Note interne — brouillon prêt à coller**

```text
────────────────────────────────────────────────────────
        VÉRIFICATION ALERTE PENDING REBOOT
────────────────────────────────────────────────────────

BILLET: #0001234
CLIENT: Otto Inc
DATE: [À CONFIRMER]

PRÉPARATION ET DÉCOUVERTE
---------
Prise de connaissance de la demande et consultation de la documentation du client.

RÉSUMÉ
---------
Alerte NOC reçue indiquant un Windows Update pending reboot sur le serveur CLT-SRV01.
Le client gère lui-même les redémarrages serveurs. Intervention orientée validation post-reboot en lecture seule avant communication client.

TRAVAUX EFFECTUÉS
---------
• Connexion au RMM et analyse de l’état global et des alertes actives.
• Vérification de l’heure du dernier redémarrage du serveur.
• Vérification des indicateurs de pending reboot (CBS / Windows Update / PendingFileRename / CCM).
• Vérification de l’espace disque, des services automatiques arrêtés et des journaux System/Application récents.
• Vérification de l’état des services SQL [À CONFIRMER].

AVERTISSEMENTS OBSERVÉS
---------
• [À CONFIRMER]

ÉVÉNEMENT OBSERVÉ APRÈS L’INTERVENTION
---------
• [À CONFIRMER]

CONSTAT TECHNIQUE
---------
• Pending reboot : [À CONFIRMER]
• Dernier redémarrage : [À CONFIRMER]
• Services automatiques arrêtés : [À CONFIRMER]
• Event Logs critiques post-reboot : [À CONFIRMER]
• Monitoring revenu normal : [À CONFIRMER]

STATUT
---------
• [À CONFIRMER]

SUIVI RECOMMANDÉ
---------
• Si le flag pending reboot est disparu et que l’état est stable : clôture du billet.
• Si un flag pending reboot demeure actif : documenter lequel et recommander suivi avec le client.
• Si le flag CBS persiste après redémarrages client répétés : escalade Infra.
```

**CW Discussion — client-safe**

```text
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.
• Vérification de l’état du serveur à la suite de l’alerte reçue.
• Contrôles effectués sur l’état général, les services et les journaux récents.
• Validation du statut de redémarrage en attente liée aux mises à jour Windows.
• Aucune action intrusive effectuée de notre côté à cette étape.
• Communication client préparée avec le statut observé.
```

**Courriel client — à envoyer si validation OK**

Bonjour [Prénom],

Nous avons effectué les vérifications sur le serveur concerné à la suite de l’alerte indiquant un redémarrage en attente lié aux mises à jour Windows.

Nos contrôles visaient à confirmer l’état général du serveur après le redémarrage effectué de votre côté, ainsi que la présence éventuelle d’éléments en attente. À ce stade, [le serveur est stable et l’alerte n’est plus active / un indicateur demeure en attente — À AJUSTER SELON RÉSULTAT].

Aucune action intrusive n’a été réalisée de notre côté durant cette validation. Nous avons uniquement procédé à des vérifications de contrôle.

N’hésitez pas à nous aviser si vous observez un comportement inhabituel. Nous poursuivrons le suivi au besoin.

Cordialement,
[Nom]

Colle-moi l’output de **l’Action 1** et je te retourne immédiatement la **note interne finale**, la **discussion CW finale** et le **courriel client finalisé**.


MOI: === HOST / UPTIME ===


Hostname   : CLT-SRV01
OS         : Microsoft Windows Server 2025 Standard
LastBoot   : 1/28/2026 10:21:26 AM
UptimeDays : 75.49



 
=== PENDING REBOOT FLAGS ===


CBS_RebootPending           : True
WU_RebootRequired           : True
PendingFileRenameOperations : True
CCMClientRebootPending      : False
PendingReboot               : True



 
=== DISKS ===

Name FreeGB FreePct
---- ------ -------
C    311.14      78


 
=== AUTO SERVICES NOT RUNNING ===

Name                                       DisplayName                                    Status StartType
----                                       -----------                                    ------ ---------
AppXSvc                                    AppX Deployment Service (AppXSVC)             Stopped Automatic
edgeupdate                                 Microsoft Edge Update Service (edgeupdate)    Stopped Automatic
Elastic Agent                              Elastic Agent                                 Stopped Automatic
Otto.Transactional.Sync.WindowsService Otto.Transactional.Sync.WindowsService    Stopped Automatic
InventorySvc                               Inventory and Compatibility Appraisal service Stopped Automatic
MongoConnector                             MongoConnector                                Stopped Automatic
RemoteRegistry                             Remote Registry                               Stopped Automatic
sppsvc                                     Software Protection                           Stopped Automatic
TrustedInstaller                           Windows Modules Installer                     Stopped Automatic


 
=== RECENT SYSTEM / APPLICATION ERRORS (2H) ===
 
=== LAST HOTFIXES ===

HotFixID  InstalledOn           Description    
--------  -----------           -----------    
KB5078739 3/29/2026 12:00:00 AM Security Update
KB5078740 3/29/2026 12:00:00 AM Security Update
KB5066131 1/15/2026 12:00:00 AM Update         
KB5072725 1/15/2026 12:00:00 AM Security Update


 
=== SQL SERVICES (IF PRESENT) ===




GPT: Constat confirmé.

**Diagnostic**

* L’alerte est **valide** et **non résolue**.
* Le serveur **n’a pas redémarré depuis le 28 janvier 2026 à 10:21**.
* Les indicateurs **CBS**, **Windows Update** et **PendingFileRenameOperations** sont tous encore à **True**, donc un **redémarrage reste requis**.
* L’espace disque sur `C:` est bon.
* Aucun événement **Error/Critical** n’apparaît dans les 2 dernières heures.
* Plusieurs services en démarrage automatique sont arrêtés; sans preuve applicative, ils doivent rester **[À CONFIRMER]** et ne doivent pas être déclarés normaux. Les contrôles de fin doivent justement documenter ce qui reste **À SUIVRE** si ce n’est pas validé.   

**Conclusion opérationnelle**

* **Pas de fermeture en “résolu”.**
* Statut recommandé : **À SUIVRE / En attente d’action client**.
* Comme le client redémarre ses serveurs lui-même, la prochaine étape logique est de **lui demander un redémarrage planifié du serveur**, puis de refaire un **post-check lecture seule**.
* Le guardrail impose qu’une action intrusive comme un reboot soit explicitement validée et faite **un serveur à la fois**. 

**Action 2**
Demander au client d’effectuer un redémarrage du serveur dans sa fenêtre habituelle, puis refaire le contrôle post-reboot.

**CW Note interne — prêt à coller**

```text
────────────────────────────────────────────────────────
        VÉRIFICATION ALERTE PENDING REBOOT
────────────────────────────────────────────────────────

BILLET: #0001234
CLIENT: Otto Inc
DATE: 2026-04-13

PRÉPARATION ET DÉCOUVERTE
---------
Prise de connaissance de la demande et consultation de la documentation du client.

RÉSUMÉ
---------
Alerte NOC reçue indiquant un Windows Update pending reboot sur le serveur CLT-SRV01.
Le client gère lui-même les redémarrages serveurs. Intervention effectuée en lecture seule afin de valider l’état réel du serveur avant communication client.

TRAVAUX EFFECTUÉS
---------
• Connexion au serveur et collecte de l’état système.
• Vérification de l’heure du dernier redémarrage.
• Vérification des indicateurs de pending reboot (CBS / Windows Update / PendingFileRename / CCM).
• Vérification de l’espace disque disponible.
• Vérification des services automatiques non démarrés.
• Vérification des journaux System/Application récents.
• Vérification de la présence de services SQL via détection standard.

AVERTISSEMENTS OBSERVÉS
---------
• Le serveur n’a pas été redémarré depuis le 2026-01-28 10:21.
• Les indicateurs CBS_RebootPending, WU_RebootRequired et PendingFileRenameOperations sont toujours actifs.
• Plusieurs services automatiques apparaissent arrêtés et demeurent à valider côté applicatif.
• Aucun service SQL détecté par la vérification standard. Rôle exact de la charge applicative à reconfirmer si requis.

ÉVÉNEMENT OBSERVÉ APRÈS L’INTERVENTION
---------
• Aucun événement Error/Critical relevé dans les 2 dernières heures dans les journaux System/Application.
• Aucun correctif appliqué par notre équipe.
• Aucune action intrusive effectuée.

CONSTAT TECHNIQUE
---------
• Pending reboot : OUI
• Dernier redémarrage : 2026-01-28 10:21:26
• Uptime observé : 75.49 jours
• Espace disque C: : 311.14 GB libres (78 %)
• Services automatiques arrêtés observés : AppXSvc, edgeupdate, Elastic Agent, Otto.Transactional.Sync.WindowsService, InventorySvc, MongoConnector, RemoteRegistry, sppsvc, TrustedInstaller
• Services SQL : [À CONFIRMER] / non détectés par la vérification standard
• Monitoring revenu normal : [À CONFIRMER]

STATUT
---------
• À SUIVRE — redémarrage toujours requis côté client.
• Billet non résolu à cette étape.

SUIVI RECOMMANDÉ
---------
• Aviser le client qu’un redémarrage du serveur demeure requis afin de compléter l’installation des mises à jour.
• Une fois le redémarrage effectué par le client, refaire un post-check lecture seule :
  - confirmer disparition des flags de pending reboot
  - confirmer services critiques / applicatifs
  - confirmer état du monitoring
• Si les mêmes flags persistent après redémarrage client, poursuivre l’investigation et documenter le flag résiduel exact.
```

**CW Discussion — client-safe**

```text
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.
• Vérification complétée sur le serveur concerné à la suite de l’alerte de redémarrage en attente.
• Les contrôles effectués confirment qu’un redémarrage demeure requis pour finaliser les mises à jour Windows.
• Aucun changement ni redémarrage n’a été effectué de notre côté.
• L’environnement semble stable à ce stade, mais le billet demeure en suivi en attente de l’action planifiée par le client.
• Une nouvelle validation sera effectuée après le redémarrage.
```

**Courriel client — prêt à envoyer**

Bonjour,

Nous avons effectué les vérifications sur le serveur concerné à la suite de l’alerte indiquant un redémarrage





MOI: Probablement que le serveur devra être redémarré à deux reprises pour faire tomber les alertes



GPT: Oui, c’est **plausible**.

Avec **CBS + Windows Update + PendingFileRenameOperations** tous à `True`, il est fréquent qu’un **premier redémarrage** lance ou finalise une phase, puis qu’un **second redémarrage** soit encore nécessaire pour faire tomber tous les indicateurs. Je le formulerais comme ceci :

* **Redémarrage 1** : requis
* **Redémarrage 2** : **possiblement requis** selon l’état des indicateurs après le premier

Je ne l’écrirais pas comme une certitude, mais comme une **possibilité forte** à prévoir.

**Formulation recommandée au client**

Bonjour,

Nous avons complété la vérification sur le serveur concerné à la suite de l’alerte de redémarrage en attente liée aux mises à jour Windows.

Les contrôles confirment qu’un redémarrage du serveur demeure requis afin de finaliser le traitement des mises à jour. Selon le comportement observé après ce redémarrage, un second redémarrage pourrait également être nécessaire pour que l’ensemble des indicateurs revienne à la normale.

Aucune action intrusive ni aucun redémarrage n’ont été effectués de notre côté. Comme convenu, cette étape demeure sous votre gestion.

Une fois le redémarrage effectué, nous pourrons refaire une validation afin de confirmer que l’état est revenu normal et que l’alerte est bien résolue.

Cordialement,
[Nom]

**CW Discussion ajustée**

```text
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.
• Vérification complétée sur le serveur concerné à la suite de l’alerte de redémarrage en attente.
• Les contrôles effectués confirment qu’un redémarrage demeure requis pour finaliser les mises à jour Windows.
• Selon l’état observé après ce redémarrage, un second redémarrage pourrait être nécessaire avant disparition complète des indicateurs.
• Aucun changement ni redémarrage n’a été effectué de notre côté.
• Le billet demeure en suivi en attente de l’action planifiée par le client puis d’une validation post-redémarrage.
```

**Phrase à ajouter dans la note interne**

```text
Compte tenu des indicateurs de pending reboot simultanément actifs, il est probable qu’un premier redémarrage soit requis pour poursuivre la finalisation des mises à jour et qu’un second redémarrage puisse être nécessaire avant retour complet à un état normal.
```

La prochaine action reste la même : **faire effectuer 1 redémarrage par le client, puis revalider**.


MOI: IL ne sait pas qu'on l'a vérifier au départ, nous avons reçu une alerte ,et je sais qu'il les redémarre lui-même.. J'ai fait une vérification identique dernièrement. On va lui fournir un peu plus d'information , les trois fla, sans détail et aviser pour les deux redémarrage suggérés


GPT: Parfait. On le tourne comme une **notification basée sur l’alerte reçue**, avec un peu plus d’info, sans entrer dans le détail technique, et en recommandant **jusqu’à deux redémarrages**.

**Courriel client révisé**

Bonjour,

Nous avons reçu une alerte indiquant qu’un redémarrage demeure en attente sur le serveur concerné à la suite des mises à jour Windows.

L’alerte fait présentement ressortir trois indicateurs encore actifs :

* CBS RebootPending
* Windows Update RebootRequired
* PendingFileRenameOperations

Comme vous effectuez habituellement les redémarrages de vos serveurs, nous vous recommandons de prévoir un premier redémarrage du serveur. Selon l’état observé par la suite, un second redémarrage pourrait également être nécessaire afin que les indicateurs reviennent complètement à la normale.

Une fois les redémarrages effectués, nous pourrons valider de nouveau si l’alerte est bien résolue.

Cordialement,
[Nom]

**CW Discussion révisée**

```text
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.
• Réception et analyse d’une alerte de redémarrage en attente liée aux mises à jour Windows sur le serveur concerné.
• L’alerte indique que trois indicateurs de redémarrage demeurent actifs.
• Comme le client effectue habituellement lui-même les redémarrages serveurs, une communication a été préparée afin de recommander un premier redémarrage, avec possibilité d’un second si l’alerte persiste.
• Billet laissé en suivi en attente de l’action client, puis d’une validation subséquente.
```

**Note interne révisée**

```text
────────────────────────────────────────────────────────
        VÉRIFICATION ALERTE PENDING REBOOT
────────────────────────────────────────────────────────

BILLET: #0001234
CLIENT: Otto Inc
DATE: 2026-04-13

PRÉPARATION ET DÉCOUVERTE
---------
Prise de connaissance de la demande et consultation de la documentation du client.

RÉSUMÉ
---------
Alerte NOC reçue indiquant un Windows Update pending reboot sur le serveur CLT-SRV01.
Le client gère lui-même les redémarrages serveurs. Vérification lecture seule effectuée afin de confirmer l’état avant communication.

TRAVAUX EFFECTUÉS
---------
• Connexion au serveur et collecte de l’état système.
• Vérification du dernier redémarrage observé.
• Vérification des indicateurs de pending reboot.
• Vérification de l’espace disque et des journaux récents.
• Revue des services automatiques non démarrés.

AVERTISSEMENTS OBSERVÉS
---------
• Dernier redémarrage observé : 2026-01-28 10:21:26
• Trois indicateurs de pending reboot toujours actifs :
  - CBS_RebootPending
  - WU_RebootRequired
  - PendingFileRenameOperations
• Plusieurs services automatiques apparaissent arrêtés et demeurent à valider côté applicatif.

ÉVÉNEMENT OBSERVÉ APRÈS L’INTERVENTION
---------
• Aucun événement Error/Critical relevé dans les 2 dernières heures dans les journaux vérifiés.
• Aucune action intrusive effectuée.

CONSTAT TECHNIQUE
---------
• Pending reboot : OUI
• Uptime observé : 75.49 jours
• Espace disque C: : 311.14 GB libres (78 %)
• Le serveur nécessitera minimalement un redémarrage client.
• Il est probable qu’un second redémarrage soit requis avant disparition complète des indicateurs.

STATUT
---------
• À SUIVRE — en attente de redémarrage(s) côté client.

SUIVI RECOMMANDÉ
---------
• Aviser le client que l’alerte indique encore trois flags actifs.
• Recommander un premier redémarrage, puis un second au besoin si l’alerte demeure présente.
• Refaire un contrôle lecture seule après les redémarrages client.
```

Version plus directe, au cas où tu veux un courriel plus court :

Bonjour,

Nous avons reçu une alerte indiquant qu’un redémarrage demeure en attente sur le serveur concerné après les mises à jour Windows.

Trois indicateurs sont actuellement encore présents :

* CBS RebootPending
* Windows Update RebootRequired
* PendingFileRenameOperations

Comme vous effectuez habituellement les redémarrages de vos serveurs, nous vous recommandons de procéder à un premier redémarrage. Un second pourrait être nécessaire si les indicateurs demeurent actifs par la suite.

Nous pourrons ensuite revérifier l’état de l’alerte au besoin.

Cordialement,
[Nom]


MOI: Indique que j'ai vérifier le serveur pour valider que le serveur était prêt et ok pour etre redémarré


GPT: Oui — je le mettrais ainsi, de façon prudente et propre :

**Formulation recommandée**

* `Nous avons également vérifié l’état général du serveur afin de confirmer qu’aucun élément bloquant apparent n’était présent et qu’un redémarrage planifié pouvait être envisagé.`

**Courriel client révisé**

Bonjour,

Nous avons reçu une alerte indiquant qu’un redémarrage demeure en attente sur le serveur concerné à la suite des mises à jour Windows.

Nous avons également vérifié l’état général du serveur afin de confirmer qu’aucun élément bloquant apparent n’était présent et qu’un redémarrage planifié pouvait être envisagé.

L’alerte fait présentement ressortir trois indicateurs encore actifs :

* CBS RebootPending
* Windows Update RebootRequired
* PendingFileRenameOperations

Comme vous effectuez habituellement les redémarrages de vos serveurs, nous vous recommandons de prévoir un premier redémarrage du serveur. Selon l’état observé par la suite, un second redémarrage pourrait également être nécessaire afin que les indicateurs reviennent complètement à la normale.

Une fois les redémarrages effectués, nous pourrons valider de nouveau si l’alerte est bien résolue.

Cordialement,
[Nom]

**CW Discussion révisée**

```text
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.
• Réception et analyse d’une alerte de redémarrage en attente liée aux mises à jour Windows sur le serveur concerné.
• Vérification de l’état général du serveur afin de confirmer qu’aucun élément bloquant apparent n’était visible avant un redémarrage planifié.
• L’alerte indique que trois indicateurs de redémarrage demeurent actifs.
• Comme le client effectue habituellement lui-même les redémarrages serveurs, une communication a été préparée afin de recommander un premier redémarrage, avec possibilité d’un second si l’alerte persiste.
• Billet laissé en suivi en attente de l’action client, puis d’une validation subséquente.
```

**Phrase à insérer dans la note interne**

```text
Une vérification de l’état général du serveur a également été effectuée afin de confirmer qu’aucun élément bloquant apparent n’était présent avant un redémarrage planifié.
```

Je corrigerais aussi la tournure en interne de cette façon :

* `J’ai vérifié le serveur pour valider qu’il semblait prêt à être redémarré.`



