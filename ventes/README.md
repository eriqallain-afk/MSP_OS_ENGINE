# /ventes — Pipeline Opportunités Projets MSP

> **MODULE PROJETS — Activation future par EA**
> Cette structure fait partie du MODULE_PROJETS, actuellement en préparation.
> Spec complète : `99_STAGING/Draft/MODULE_PROJETS/MODULE_PROJETS__SPEC_v1.md`
> Agent IT-ProjetSOW : `99_STAGING/Draft/MODULE_PROJETS/IT-ProjetSOW/`

---

## Rôle de ce dossier

Dossier d'intégration entre les agents terrain et l'agent IT-ProjetSOW.

Les agents terrain autorisés créent des entrées pipeline via `/escalade-ventes`.
IT-ProjetSOW lit ces fichiers et génère les estimations et SOW clients.

**La commande `/escalade-ventes` n'est pas encore intégrée dans les agents terrain.**
Elle sera ajoutée lors de l'activation du MODULE_PROJETS (validation EA requise).

---

## Structure

```
ventes/
├── README.md                  ← Ce fichier
├── SCHEMA_OPPORTUNITY.yaml    ← Schéma de référence pour les agents terrain
├── ACCESS_CONTROL.md          ← Permissions lecture/écriture par agent
├── opportunities/             ← Fichiers écrits par les agents terrain (via /escalade-ventes)
├── estimations/               ← Estimations générées par IT-ProjetSOW
└── approved/                  ← Projets approuvés par le client
```

---

## Agents autorisés à écrire dans /opportunities/

FrontLine, N2, N3, SysAdmin, MaintenanceMaster, OnOffBoarder,
NetworkMaster, SecurityMaster, BackupDRMaster, CloudMaster

Accès complet : IT-ProjetSOW (lecture + écriture estimations + approved)

Voir `ACCESS_CONTROL.md` pour le détail des permissions.

---

*Structure permanente — Module non actif — MSP Intelligence AI — 2026-05-19*
