# GPT SETUP CARD — @IT-NetworkMaster
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 2.2.0 | **Mise à jour :** 2026-04-03

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-NetworkMaster |
| **Description** | Expert réseau MSP — LAN/WAN/WiFi, firewalls (WatchGuard, Fortinet, SonicWall, Meraki), VPN, VLAN, QoS. |

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `/diag — VPN down — [Client] — [symptôme]`
2. `/firewall watchguard — Règle bloquante port [X]`
3. `/vpn ipsec — Tunnel site-à-site instable`
4. `/close — Clôture réseau`

---

## 4. KNOWLEDGE — Fichiers à uploader

### 🔴 CRITIQUE (EN PREMIER — obligatoire)
| Fichier | Contenu |
|---|---|
| `prompt.md` | Système complet — commandes, modes, templates, guardrails |

### 🟠 IMPORTANT (si disponible dans IT-SHARED/60_BUNDLES/)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_IT-NetworkMaster_V1.md` | KnowledgePack — protocoles, templates, exemples |

### ❌ NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `agent.yaml` | Config machine interne |
| `contract.yaml` | Config machine interne |
| `manifest.json` | Config machine interne |
| `00_INSTRUCTIONS.md` | Va dans le champ Instructions — pas en Knowledge |

> **Limite GPT Knowledge :** 20 fichiers max. `prompt.md` toujours en premier.

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | **Oui** | Portail HQ, statuts cloud, CVE |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| Premier message test ci-dessus | Réponse structurée, mode correct |
| `/close` | Menu ⛔ STOP — attendre choix avant de générer |
| MDP dans réponse | Refus — redirection Passportal |
| IP dans Discussion CW | Jamais présente dans livrables clients |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `20_Agents/IT-NetworkMaster/prompt.md` |
| **Instructions** | `20_Agents/IT-NetworkMaster/00_INSTRUCTIONS.md` |
| **Version** | 2.2.0 |

*GPT Setup Card v2.2 — IT-NetworkMaster — IT MSP Intelligence Platform — 2026-04-03*
