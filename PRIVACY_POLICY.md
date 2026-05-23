# Privacy Policy — IT MSP Intelligence Platform

**Repository :** eriqallain-afk/IT
**Owner :** EA4A (Eric Allain)
**Effective date :** 2026-04-11
**Last updated :** 2026-04-11

---

## 1. Overview

This repository contains configuration files, runbooks, scripts, and GPT agent instructions for the **IT MSP Intelligence Platform** — an internal toolset used to assist IT technicians in a Managed Service Provider (MSP) context.

This Privacy Policy describes how data is handled in relation to the contents of this repository and the GPT agents it powers.

---

## 2. Data Collected

This repository **does not collect, store, or process personal data** directly.

The files contained herein are:
- Technical runbooks and operational procedures
- PowerShell and Bash scripts for IT infrastructure management
- GPT agent configuration files (instructions, prompts, knowledge packs)
- YAML index and routing files

**No personally identifiable information (PII)** is intentionally stored in this repository. Any reference to individuals (e.g., technician names, client contact names) in templates is represented as a placeholder such as `[NomClient]`, `[Technicien]`, or `[À COMPLÉTER]`.

---

## 3. Credentials and Sensitive Data

This repository applies a strict **zero-credential policy**:

- No passwords, API keys, tokens, or secrets are stored in any file.
- All credential references are redirected to **Passportal** or equivalent secure vault.
- IP addresses of client infrastructure are never stored in documentation files — they belong in the client's Hudu record or equivalent CMDB.
- Any file found to contain credentials is considered a **critical error** and must be remediated immediately.

If you discover a credential accidentally committed, report it immediately via GitHub Issues or contact the repository owner directly.

---

## 4. GPT Agent Usage

The GPT agents configured by this repository operate under the following data handling rules:

- Agents are **copilots** — they assist technicians and do not act autonomously on production systems.
- Agents do not store conversation history beyond the active session.
- Agents are instructed never to reproduce credentials, client IP addresses, or sensitive infrastructure details in client-facing outputs (ConnectWise Discussion, email, Teams notices).
- Agent outputs containing confidential technical details are restricted to **internal notes** (ConnectWise Note Interne) only.

---

## 5. Client Data

This platform is used in the context of managed IT services for enterprise clients. The following rules apply:

- Client infrastructure data (hostnames, IPs, configurations) is managed in **Hudu** and **ConnectWise** — not in this repository.
- No client-specific data is committed to this repository.
- Runbooks and templates use generic placeholders (`[NomClient]`, `[IP_SERVEUR]`, etc.) that are filled at runtime by the technician.

---

## 6. Repository Access

- This repository is **private** by default.
- Access is granted on a need-to-know basis by the repository owner.
- GitHub Actions and GPT Actions use read-only tokens scoped to this repository.
- Token `IT-MSP-GPT-Reader` is a read-only access token — it grants no write or admin permissions.

---

## 7. Third-Party Services

This platform integrates with the following third-party services:

| Service | Purpose | Privacy Policy |
|---|---|---|
| OpenAI (Custom GPTs) | AI agent execution | https://openai.com/privacy |
| GitHub | Repository hosting | https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement |
| ConnectWise | Ticketing / PSA | https://www.connectwise.com/company/privacy |
| Hudu | Documentation / CMDB | https://www.hudu.com/privacy-policy |
| N-able | RMM monitoring | https://www.n-able.com/legal/privacy-policy |

The owner of this repository is not responsible for the privacy practices of these third-party services.

---

## 8. Data Retention

- This repository retains file history through Git version control.
- Deleted files remain accessible in Git history — if sensitive data is accidentally committed, a full history rewrite (`git filter-repo`) may be required.
- Agent conversation data is not retained by this repository — retention is governed by the applicable OpenAI or enterprise GPT platform policy.

---

## 9. Changes to This Policy

This policy may be updated to reflect changes in the platform, integrations, or applicable regulations. The **Last updated** date at the top of this document will reflect any changes. Significant changes will be noted in the repository changelog.

---

## 10. Contact

For questions, concerns, or to report a security issue related to this repository:

**Owner :** EA4A — Eric Allain
**GitHub :** https://github.com/eriqallain-afk
**Security issues :** Open a private GitHub Security Advisory or contact the owner directly.

---

*IT MSP Intelligence Platform — Privacy Policy — EA4A — 2026-04-11*
