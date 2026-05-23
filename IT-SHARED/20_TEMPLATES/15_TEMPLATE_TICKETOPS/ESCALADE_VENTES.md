# ESCALADE VENTES — Template agent terrain → IT-ProjetSOW

**Usage :** Utiliser ce template quand une intervention terrain révèle un besoin de projet (migration, upgrade, nouveau déploiement, SOW). Permet d'escalader formellement vers IT-ProjetSOW via le pipeline `/ventes/`.

---

## QUAND ESCALADER ?

Déclencher une escalade ventes si l'une des conditions suivantes est vraie :

| Signal détecté | Exemple concret |
|---|---|
| Infrastructure obsolète ou insuffisante | Serveur en fin de vie, pas de DR, storage saturé |
| Besoin de migration identifié | AD sur-site → Azure AD, Exchange → M365 |
| Lacune de sécurité structurelle | Pas d'EDR, pas de MFA, pare-feu hors support |
| Nouveau déploiement requis | Nouveau site, nouveaux postes en masse, VoIP |
| Onboarding client — lacunes détectées | IT-OnOffBoarder phase /gap → projets identifiés |
| Client demande un devis / chiffrage | Demande directe lors d'un ticket |
| Problème récurrent non résolu par N1/N2 | Root cause = infrastructure inadéquate |

---

## ÉTAPE 1 — Remplir le fichier opportunité

Copier le schéma de référence :
```
/ventes/SCHEMA_OPPORTUNITY.yaml
```

Remplir **tous les champs obligatoires** (laisser `[À VALIDER]` si information manquante — ne jamais inventer) :

```yaml
# Fichier à sauvegarder sous :
# /ventes/opportunities/OPP-{YYYYMMDD}-{NNN}.yaml
# Exemple : OPP-20260519-001.yaml

schema_version: "1.0"
opportunite_id: "OPP-{YYYYMMDD}-{NNN}"
date_detection: "{YYYY-MM-DD}"
agent_source: "{Ton ID agent}"          # ex: IT-FrontLine, IT-SysAdmin
billet_source: "{#XXXXX}"              # Ticket CW d'origine
technicien: "{Tes initiales}"
statut: "NOUVEAU"

client:
  nom: "{Nom du client}"
  contact_principal: "{Décideur}"
  email: "{email}"
  telephone: "{téléphone}"
  type: "{PME | Entreprise | OBNL | Municipal}"
  relation_msp: "{Nouveau | Existant}"

besoin:
  titre: "{Titre court — ex: Migration AD vers Azure AD}"
  categorie: "{Infrastructure | Migration | Sécurité | Cloud | Réseau | Backup | VoIP | Autre}"
  sous_categorie: "{ex: Virtualisation | M365 | Active Directory | Firewall...}"
  description: |
    {Description du besoin tel que détecté — 3 à 5 phrases minimum}
  declencheur: "{Ce qui a mené à cette détection — ex: incident, maintenance, demande client}"
  urgence: "{Faible | Normale | Haute | Critique}"

contexte_technique:
  infrastructure_actuelle: |
    {Ce qui est connu de l'infra — sans IPs ni credentials}
  lacunes_identifiees:
    - "{Lacune principale}"
    - "{Lacune secondaire si applicable}"
  risques_si_non_adresse: |
    {Risque business ou technique si le projet n'est pas réalisé}

estimation_preliminaire:
  effort_approximatif: "{Petit <1j | Moyen 1-5j | Grand 5-20j | Majeur >20j}"
  budget_approximatif: "{<$5K | $5K-$20K | $20K-$100K | >$100K}"
  type_projet: "{Forfait | Régie | Abonnement | Hybride}"

liens:
  handoff_onoffboarder: "{Chemin handoff IT-OnOffBoarder si applicable — sinon: N/A}"
  documentation_client: "{Lien Hudu si applicable — sinon: N/A}"
  billet_cw: "{#XXXXX}"
```

---

## ÉTAPE 2 — Déposer le fichier

Nommer le fichier selon la convention :
```
OPP-{YYYYMMDD}-{NNN}.yaml
```
Exemples : `OPP-20260519-001.yaml`, `OPP-20260519-002.yaml`

Déposer dans :
```
/ventes/opportunities/
```

---

## ÉTAPE 3 — Notifier IT-ProjetSOW

Une fois le fichier déposé, notifier IT-ProjetSOW avec le message suivant dans le ticket CW :

```
@IT-ProjetSOW — Nouvelle opportunité détectée
ID : OPP-{YYYYMMDD}-{NNN}
Client : {Nom du client}
Besoin : {Titre court}
Urgence : {Faible | Normale | Haute | Critique}
Fichier déposé dans /ventes/opportunities/

/lire OPP-{YYYYMMDD}-{NNN}
```

IT-ProjetSOW prendra en charge l'analyse, l'estimation et la rédaction du SOW.

---

## RÈGLES D'ESCALADE

| Règle | Détail |
|---|---|
| Agents autorisés | Voir `/ventes/ACCESS_CONTROL.md` pour la liste complète |
| Format obligatoire | Respecter le schéma YAML — tout champ manquant = `[À VALIDER]` |
| Pas de prix dans l'opportunité | L'estimation est générée par IT-ProjetSOW — pas par l'agent terrain |
| Confidentialité | Aucune IP, credential, token dans le fichier opportunité |
| Validation finale | Tout prix soumis au client = validation EA obligatoire |

---

## CAS SPÉCIAL — Handoff IT-OnOffBoarder

Si l'opportunité est issue d'un onboarding IT-OnOffBoarder (phase `/gap` ou `/upgrade`) :

1. Inclure le chemin du handoff dans `liens.handoff_onoffboarder`
2. Les lacunes identifiées dans le handoff YAML alimentent directement le champ `contexte_technique.lacunes_identifiees`
3. Mentionner `relation_msp: "Nouveau"` dans le bloc client

---

*Template v1.0 — Escalade Ventes — MSP Intelligence AI — 2026-05-19*
