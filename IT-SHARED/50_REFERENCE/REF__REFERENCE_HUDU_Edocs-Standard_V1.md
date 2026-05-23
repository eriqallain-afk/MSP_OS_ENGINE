# RÉFÉRENCE — Standard edocs MSP

**Usage :** Guide de référence pour tous les agents qui génèrent ou mettent à jour
des fiches edocs. À lire avant tout output de type EDOCS_CAPTURE.

---

## Principe fondamental

edocs documente **ce qui existe** chez le client — pas ce qui s'est passé.

| Ce qui s'est passé | Ce qui existe |
|---|---|
| → ConnectWise (ticket, notes) | → edocs (fiche objet IT) |
| → KB MSP (KnowledgeKeeper) | → edocs (fiche procédure client) |

Un technicien qui ouvre edocs doit trouver **l'état permanent** de l'environnement,
pas l'historique des incidents.

---

## Taxonomie des types d'objets

| Type | Quand créer | Exemples |
|---|---|---|
| `APPLICATION` | Toute app métier installée ou en SaaS | Maestro, QuickBooks, AutoCAD, Teams |
| `SERVEUR` | Tout serveur physique ou VM avec un rôle | SRV-SQL01, SRV-DC01, SRV-RDS01 |
| `BACKUP` | Toute solution de sauvegarde configurée | VEEAM on-prem, Datto, Azure Backup |
| `LICENCE` | Toute licence à renouveler ou à retrouver | Licence Maestro, Windows Server, M365 |
| `PROCÉDURE` | Toute opération répétable propre au client | Mise à jour Maestro, Ajout utilisateur M365 |
| `RÉSEAU` | Équipements réseau administrés | Watchguard, Switch HP, VPN SSL |

---

## Modèle de liaison — Règles strictes

### Sens des liaisons

```
LIAISON MONTANTE  (cette fiche dépend de)
  Application Maestro  →  Serveur SQL Maestro
  Application Maestro  →  Licence Maestro
  Serveur SQL Maestro  →  Backup VEEAM

LIAISON DESCENDANTE  (cette fiche est utilisée par)
  Serveur SQL Maestro  →  Application Maestro
  Backup VEEAM         →  Serveur SQL Maestro
                       →  Serveur RDS Maestro
                       →  Serveur DC01
```

### Dans l'éditeur edocs
- Chaque liaison = lien hypertexte cliquable vers la fiche cible
- Format de mention dans la fiche générée par l'agent :
  `→ [Nom exact de la fiche cible] (lien à créer dans edocs)`
- Si la fiche cible n'existe pas encore :
  `→ [Nom suggéré — FICHE À CRÉER]`

### Règle de cohérence bidirectionnelle
Si la fiche A liste B en liaison descendante,
la fiche B DOIT lister A en liaison montante.
L'agent qui crée une fiche doit signaler les fiches à mettre à jour.

---

## Ce qu'on NE met PAS dans edocs

| Interdit | Pourquoi | Où ça va plutôt |
|---|---|---|
| Mots de passe / secrets | Sécurité | Passportal |
| Historique des incidents | Pas une CMDB événementielle | CW ticket |
| Procédures génériques MSP | Pas spécifique au client | KB MSP (KnowledgeKeeper) |
| IPs internes visibles dans sections client | Sécurité | Notes internes CW uniquement |
| `[À COMPLÉTER]` publié | Incomplet = inutilisable | Brouillon jusqu'à validation |

---

## Qualité d'une fiche edocs — Checklist avant publication

- [ ] Type d'objet clairement identifié (Application / Serveur / Backup / Licence / Procédure / Réseau)
- [ ] Nom de la fiche correspond à la convention de nommage : `[TYPE] — [NomObjet]`
- [ ] Zéro mot de passe (Passportal référencé à la place)
- [ ] Liaisons montantes ET descendantes remplies
- [ ] Toutes les fiches liées existent OU marquées comme "À CRÉER"
- [ ] Compte d'accès identifié (le nom du compte, pas le mot de passe)
- [ ] Dernière mise à jour remplie (date + technicien + ticket CW)
- [ ] Zéro champ `[À COMPLÉTER]` publié sans valeur

---

## Convention de nommage des fiches edocs

```
[TYPE] — [NomObjet]

Exemples :
APPLICATION — Maestro
SERVEUR — SRV-SQL01 (Maestro)
SERVEUR — SRV-DC01 (Contrôleur de domaine principal)
BACKUP — VEEAM On-premise
BACKUP — Datto — NomClient
LICENCE — Maestro (Annuelle)
PROCÉDURE — Mise à jour Maestro
RÉSEAU — Pare-feu Watchguard M270
```

---

## Relation edocs ↔ Agents IT MSP

| Action | Agent responsable | Output |
|---|---|---|
| Fermeture ticket → capture objet IT | `@IT-TicketScribe` (MODE=EDOCS_CAPTURE) | Fiche edocs prête à coller |
| Découverte d'info pendant intervention | `@IT-TicketScribe` (MODE=EDOCS_CAPTURE) | Fiche edocs mise à jour |
| Article KB générique | `@IT-KnowledgeKeeper` | Article KB MSP (pas edocs) |
| Note d'intervention | `@IT-TicketScribe` (MODE=NOTE_INTERNE) | CW Internal Note |

