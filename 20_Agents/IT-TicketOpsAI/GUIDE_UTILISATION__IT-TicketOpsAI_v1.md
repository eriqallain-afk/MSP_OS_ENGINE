# Guide d'utilisation — @IT-TicketOpsAI (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-TicketOpsAI ?

**IT-TicketOpsAI est le copilote du cycle complet d'un billet IT.**

Il ne remplace pas ConnectWise (la plateforme) ni le technicien (le jugement humain).
Il structure l'intervention de A à Z : triage, analyse serveur, runbook guidé, livrables CW et clôture.

| Étape | Ce que fait IT-TicketOpsAI |
|---|---|
| Ouverture | Analyse la description, détecte l'intent, identifie le rôle serveur |
| Diagnostic | Fournit un script PowerShell d'analyse serveur à exécuter |
| Intervention | Guide étape par étape via le runbook correspondant |
| Validation | Script postcheck pour confirmer la résolution |
| Clôture | Génère Note Interne, Discussion client-safe, email, Teams |

---

## Quand l'utiliser ?

- Tu ouvres un billet et tu ne sais pas par où commencer
- Tu dois documenter une intervention dans CW (Note Interne + Discussion)
- Tu veux valider un script PowerShell avant de l'exécuter en production
- Tu dois produire un mémo interne ou une notice Teams
- Tu termines une intervention et tu veux générer tous les livrables de clôture

---

## Les commandes principales

### `/start` — Lancer le flux complet

La commande principale. L'agent analyse le contexte, détecte l'intent et guide la suite.

**Usage :**
```
/start #77010 Le serveur de fichiers SRV-FS01 affiche une alerte disque C: à 92% depuis ce matin. Client : Entreprise ABC.
```

**Ce que tu obtiens :**
- Résumé du billet capturé
- Intent détecté (ex. `it.disk.full`)
- Demande d'analyse serveur si le rôle n'est pas confirmé
- Script PowerShell prêt à copier-coller

---

### `/analyse` — Script d'analyse serveur

Fournit le script `SCRIPT_Analyse_Serveur_TicketOps_V1.ps1` complet, prêt à exécuter.

**Usage :**
```
/analyse
```

**Instructions d'exécution :**
1. Ouvrir PowerShell en administrateur sur le serveur concerné
2. Exécuter : `.\SCRIPT_Analyse_Serveur_TicketOps_V1.ps1 -Ticket "77010"`
3. Copier le bloc YAML en output
4. Coller avec `/role_profile [YAML]`

---

### `/role_profile` — Transmettre les résultats d'analyse

Après avoir exécuté le script d'analyse, colle le YAML résultant ici.

**Usage :**
```
/role_profile
ticketops_hint:
  router_intent: it.disk.full
  detected_role: FILE_SERVER
  template_suggere: CLOSE_DisquePlein
role_profile:
  server_name: SRV-FS01
  os_caption: Windows Server 2022
  uptime_days: 142
  detected_roles: [FileServer]
resource_summary:
  disk_critical: [C:]
  pending_reboot: false
  services_stopped: []
```

**Ce que tu obtiens :**
- Confirmation du rôle et des alertes détectées
- Runbook sélectionné automatiquement
- Template de clôture suggéré
- Prochaine commande : `/run`

---

### `/run` — Runbook guidé étape par étape

Démarre l'intervention selon le runbook chargé.

**Usage :**
```
/run
```

**Ce que tu obtiens :**
- Précautions avant intervention (snapshot, fenêtre maintenance, client averti)
- Étapes numérotées avec résultat attendu pour chacune
- Validation postcheck à la fin
- Commandes `/script [étape]` disponibles pour chaque étape

---

### `/script` — Script PowerShell ciblé

Fournit le script adapté à l'étape en cours du runbook.

**Usage :**
```
/script
```

**Ce que tu obtiens :**
```
Script avec :
- Portée indiquée (Local / Domaine)
- Niveau de risque (Faible / Moyen)
- Procédure de rollback si applicable
```

---

### `/script-check` — Valider un script avant exécution

Analyse un script PowerShell pour détecter les risques avant de l'exécuter.

**Usage :**
```
/script-check
$disks = Get-PSDrive -PSProvider FileSystem
foreach ($d in $disks) {
    Write-Host "$($d.Name): $([math]::Round($d.Free/1GB, 2)) Go libres"
}
```

**Ce que tu obtiens :**
- Risques identifiés (probabilité / impact)
- Prérequis (snapshot, approbation client)
- Verdict : Approuvé / Modifications requises / Non recommandé

---

### `/close` — Menu de fermeture

Génère tous les livrables CW pour clore le billet.

**Usage :**
```
/close
```

**Menu affiché (puis STOP — attendre ton choix) :**
```
[1] Note Interne CW
[2] Discussion CW (client-safe)
[3] Email client
[4] Notice Teams
[A] Tout (1+2+3+4)
```

---

### `/memo` — Mémo interne rapide

**Usage :**
```
/memo @Jean-François
Billet #77010 — Disque C: nettoyé sur SRV-FS01. Espace libéré : 38 Go.
Surveillance 24h recommandée avant d'archiver.
```

---

### `/risques` — Évaluer et documenter les risques

**Usage :**
```
/risques
Intervention prévue : extension du volume C: sur le contrôleur de domaine DC01.
Heure planifiée : 22h00 hors heures d'affaires.
```

---

### `/handoff` — Passation vers coordonnateur

Génère un fichier `handoff.yaml` structuré pour continuer l'intervention avec un autre technicien.

**Usage :**
```
/handoff
```

---

## Flux de travail recommandé

### Flux complet — Discovery-first

```
1. /start #[XXXXX] [description du billet]
        ↓
2. Agent analyse l'intent
   Rôle serveur connu? → /run directement
   Rôle inconnu? → /analyse
        ↓
3. Exécuter le script sur le serveur
   /role_profile [coller YAML]
        ↓
4. /run → suivre les étapes guidées
   /script si un script est requis à une étape
        ↓
5. Toutes les étapes complétées?
   → Postcheck exécuté et confirmé
        ↓
6. /close → choisir [A] pour tout générer
        ↓
7. (Optionnel) /handoff si passation requise
```

### Flux rapide — Clôture directe

```
Tu as déjà résolu le problème et tu veux juste les livrables CW :

/start #[XXXXX] [contexte résolu]
       ↓
/close → [A]
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO IP dans Discussion, Email, Teams | Livrables visibles par le client — confidentialité |
| ZÉRO credentials dans tout livrable | Passportal uniquement |
| Note Interne commence toujours par la phrase d'ouverture | Standard CW obligatoire |
| `/script-check` avant tout script risque moyen/élevé | Éviter les incidents de production |
| Discovery-first — analyser avant d'intervenir | Ne jamais agir à l'aveugle sur un serveur |
| `[À CONFIRMER]` si info manquante — jamais inventer | Zéro hallucination dans les livrables |

---

## Questions fréquentes

**Q : Quelle différence entre IT-TicketOpsAI et IT-TicketScribe ?**
IT-TicketOpsAI pilote l'intervention complète (triage, runbook, scripts, clôture).
IT-TicketScribe est spécialisé dans la rédaction CW uniquement — utile quand tu veux juste rédiger une note sans passer par le flux complet.

**Q : Que faire si l'agent ne reconnaît pas l'intent du billet ?**
L'agent indique `it.discovery.server_role` et demande d'exécuter `/analyse`. Suis le flux — après avoir collé le YAML, il sélectionnera le bon runbook.

**Q : Est-ce que je dois exécuter tous les scripts proposés ?**
Non. Les scripts sont proposés, pas obligatoires. Utilise `/script-check` si tu as un doute. Pour les scripts à risque élevé, l'approbation d'un N3 est recommandée.

**Q : Que se passe-t-il si un script retourne une erreur ?**
Colle le message d'erreur dans l'agent — il analysera et proposera un diagnostic ou une étape corrective.

**Q : Comment passer le billet à un autre technicien proprement ?**
Utilise `/handoff`. L'agent génère un fichier YAML structuré à déposer dans `99_STAGING/BILLETS/{ticket}/` — l'autre technicien peut reprendre avec `/start #[XXXXX]`.

---

*GUIDE_UTILISATION — IT-TicketOpsAI v1.0 — MSP Intelligence AI — 2026-05-18*
