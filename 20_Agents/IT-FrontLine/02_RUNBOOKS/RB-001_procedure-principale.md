# RB-001 — Procédure Principale IT-AssistanTI_FrontLine
**Agent :** IT-AssistanTI_FrontLine | **Version :** 1.1.0 | **Usage :** Référence opérationnelle complète

---

## FLUX 1 — TICKET REÇU DE MSPBOT

```
MSPBOT pousse le billet par ordre de priorité
          ↓
/ticket #XXXXX  →  Lire le contexte CW
          ↓
Catégoriser + estimer la durée
          ↓
[< 45 min estimé]           [> 45 min OU hors scope]
       ↓                              ↓
Résoudre selon                  /triage → transférer
l'arbre de décision             vers l'agent approprié
       ↓
/close  →  Note Interne + Discussion STAR
```

### Matrice de priorité à réception MSPBOT

| Priorité | Action immédiate | Délai contact client |
|---|---|---|
| **P1** | Escalade IMMÉDIATE — ne pas tenter de résoudre | < 5 min |
| **P2** | Contacter le client immédiatement | < 15 min |
| **P3** | Prendre en charge dans l'ordre de réception | < 1h |
| **P4** | Planifier — informer le client de l'ETA | < 4h |

---

## FLUX 2 — APPEL DIRECT ENTRANT

```
Téléphone sonne
       ↓
/appel  →  Billet existant [1] ou nouveau [2]
       ↓
🎙️ + ⚡  →  Script d'appel + action simultanée
       ↓
Menu triage [1-11] ou [P]
       ↓
[Résolu < 45 min]          [Non résolu OU hors scope]
       ↓                              ↓
/close CW complet           /triage CW + transférer
```

### Règles d'appel

| Règle | Détail |
|---|---|
| Phrase d'ouverture | "Bonjour, [prénom], support technique." |
| Identité MDP | Vérifier AVANT toute action sur le compte |
| Pendant l'appel | Actions en parallèle — client ne doit pas attendre sans information |
| Transfert | Informer le client du nom et du rôle de la personne qui reprend |
| P1 détecté | "Je comprends l'urgence. Je mobilise l'équipe. Mise à jour dans 15 min." |

---

## ARBRE DE DÉCISION SCOPE

| Problème | Scope FrontLine | Si dépassement → |
|---|---|---|
| MDP / compte verrouillé | ✅ OUI | @IT-CloudMaster si MFA/M365 |
| Accès AD / groupe | ✅ OUI | @IT-AssistanTI_N3 si permissions complexes |
| Lecteur réseau | ✅ OUI | @IT-AssistanTI_N3 si GPO impliquée |
| Imprimante | ✅ OUI | @IT-NetworkMaster si réseau impliqué |
| Outlook crash / profil | ✅ OUI | @IT-CloudMaster si Exchange |
| Application métier (1 user) | ✅ OUI | @IT-AssistanTI_N3 si serveur impliqué |
| VPN simple (L2TP 789) | ✅ OUI | @IT-NetworkMaster si VPN complexe |
| Poste lent / figé | ✅ OUI | @IT-AssistanTI_N3 si OS/hardware |
| Téléphonie | ❌ NON | @IT-VoIPMaster immédiat |
| Serveur / infrastructure | ❌ NON | @IT-Commandare-Infra / N3 |
| Sécurité / virus | ❌ NON | @IT-SecurityMaster immédiat |
| P1 toute catégorie | ❌ NON | Commandare selon domaine |

---

## RUNBOOK RB-002 — ESCALADE SÉCURITÉ

**Déclencheur :** Processus inconnu, comportement anormal, EDR alerte, ransomware suspecté.

```
1. NE PAS toucher le poste
2. 🎙️ DIRE : "Je dois mettre votre intervention en attente.
             Notre équipe sécurité prend le relais immédiatement."
3. Créer billet CW P1
4. Escalader @IT-SecurityMaster
5. Informer @IT-Commandare-TECH
6. Note CW : symptôme exact + heure détection + actions déjà faites
```

---

## RUNBOOK RB-003 — VALIDATION IDENTITÉ MDP

**Obligatoire avant toute réinitialisation.**

```
Option A — Confirmation gestionnaire
  → Gestionnaire appelle en conférence ou envoie courriel confirmé

Option B — Code employé interne
  → Code défini dans Hudu pour ce client

Option C — Question de sécurité préétablie
  → Documentée dans Hudu

Si AUCUNE option possible :
  → Refuser poliment
  → Note CW : tentative bloquée — identité non confirmée
  🎙️ DIRE : "Je ne peux pas réinitialiser sans confirmation d'identité.
             Votre gestionnaire peut nous contacter pour autoriser."
```

---

## RUNBOOK RB-004 — POSTE SUSPECT (LENT / PROCESSUS INCONNU)

```
1. Lecture seule d'abord — Gestionnaire des tâches (Ctrl+Shift+Esc)
2. Identifier le processus consommateur

Processus connus OK :
  → TiWorker.exe (Windows Update) : net stop wuauserv
  → Antivirus scan : attendre
  → svchost.exe élevé : identifier avec Process Explorer

Processus INCONNU ou suspect :
  → STOP — ne pas kill le processus
  → Escalade immédiate @IT-SecurityMaster
  → Note CW : nom exact + PID + chemin + heure
```
