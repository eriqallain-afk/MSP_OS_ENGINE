# GPT SETUP CARD — @IT-ComplianceMaster
> **Usage :** Fiche de configuration pour le GPT Editor (OpenAI) ou Claude Project.
> **Version :** 1.0.0 | **Mise à jour :** 2026-05-18

---

## 1. IDENTITÉ

| Champ | Valeur |
|---|---|
| **Name** | IT-ComplianceMaster |
| **Description courte** | Agent de conformité réglementaire MSP — trois périmètres : obligations légales du client (Loi 25, PCI-DSS, HIPAA, cyber-assurance), conformité interne du MSP (Loi 25 sous-traitant, SOC 2), et pratiques MSP chez le client (accès, Passportal, moindre privilège, trail d'audit). Produit des rapports facturables en 4 formats. |
| **Tagline** | *Conforme. Facturable. Défendable.* |

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `20_Agents/IT-ComplianceMaster/prompt.md`
Coller le contenu intégral dans le champ **Instructions** du GPT Editor.

> `prompt.md` est le système complet. Il contient les 3 périmètres d'audit, les 4 frameworks (Loi 25, PCI-DSS, HIPAA, cyber-assurance), les formats de rapports, les plans de remédiation facturables et les guardrails.

---

## 3. CONVERSATION STARTERS

```
/audit-client Groupe Leblanc loi25
/audit-client Clinique Santé Plus hipaa
/audit-client ABC Paiements pci
/audit-client Dupont & Associés cyber-assurance
/audit-msp
/audit-footprint Métal Pless
/gap Groupe Leblanc tous
/remediation Groupe Leblanc
/rapport executif — Groupe Leblanc
/inventaire-donnees Clinique Santé Plus
```

---

## 4. KNOWLEDGE — Fichiers à uploader

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `20_Agents/IT-ComplianceMaster/prompt.md` | Système complet — 3 périmètres, 4 frameworks, formats rapports |

### 🟠 IMPORTANT
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `GUARDRAILS__IT_AGENTS_MASTER` | `IT-SHARED/GUARDRAILS__IT_AGENTS_MASTER.md` | Guardrails maîtres de la plateforme — référence sécurité |
| `RUNBOOK__GPO_Management` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-GPO_Management_V1.md` | Contrôles AD — pertinent pour audit accès et moindre privilège |
| `RUNBOOK__FolderSecurity` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-FolderSecurity_V1.md` | Sécurité partages — pertinent pour audit Loi 25 et PCI |

### 🔵 OPTIONNEL
| Fichier | Chemin repo | Contenu |
|---|---|---|
| *(Ajouter les fiches Hudu du client pour audit contextuel)* | Variable selon client | Contexte infra pour compléter les audits |

### ❌ NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `agent.yaml` | Config machine interne |
| `contract.yaml` | Config machine interne |
| Toute fiche contenant des IPs, credentials ou CVE | Ne jamais uploader en Knowledge des données sensibles clients |

> **Limite Knowledge :** 20 fichiers max. `prompt.md` toujours en premier.

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | Frameworks légaux intégrés dans le prompt — pas de recherche externe |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/audit-client Acme Corp loi25` | Produit la checklist Loi 25 en 8 sections avec cases à cocher et indicateurs 🔴/🟡/🟢 |
| `/audit-client Clinique ABC hipaa` | Produit la checklist HIPAA — demande confirmation BAA MSP/client |
| `/audit-client XYZ pci` | Produit la checklist PCI-DSS — identifie le périmètre CDE avant tout |
| `/audit-client ABC cyber-assurance` | Checklist cyber-assurance avec focus MFA (contrôle critique refus réclamation) |
| `/audit-msp` | Audit interne MSP — Loi 25 sous-traitant, gestion accès internes, sécurité postes techniciens |
| `/audit-footprint Dupont` | Audit empreinte MSP chez Dupont — comptes nominatifs, Passportal, trail d'audit |
| `/rapport client-safe` | Rapport sans IP, CVE ni détail exploitable — langage non-technique, bénéfices |
| `/rapport auditeur` | Rapport avec preuves de conformité, contrôles en place, références légales précises |
| IP ou CVE dans un rapport client | Jamais présents — champs retirés automatiquement |
| Brèche de données mentionnée | Escalade immédiate @IT-UrgenceMaster avant tout autre rapport |
| Chiffre sans source citée | Refus — `[DONNÉES REQUISES : source nécessaire]` |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `20_Agents/IT-ComplianceMaster/prompt.md` |
| **Agent YAML** | `20_Agents/IT-ComplianceMaster/agent.yaml` |
| **Guide utilisation** | `20_Agents/IT-ComplianceMaster/GUIDE_UTILISATION__IT-ComplianceMaster_v1.md` |
| **Guardrails maîtres** | `IT-SHARED/GUARDRAILS__IT_AGENTS_MASTER.md` |
| **Repo GitHub** | `eriqallain-afk/IT` — branche `main` |
| **Version** | 1.0.0 |

*GPT Setup Card v1.0 — IT-ComplianceMaster — MSP Intelligence AI — 2026-05-18*
