# BUNDLE_INFRA_DNS_Domains_V1
**Catégorie :** DNS, noms de domaine, enregistrements, registrars
**Agents :** @IT-NetworkMaster | @IT-CloudMaster | @IT-Commandare-Infra | IT-MaintenanceMaster | IT-SysAdmin
**Version :** 1.0 | **Date :** 2026-04-05

---

## RB-DNS-001 — Diagnostic DNS — Résolution et propagation

**Durée estimée :** 10-20 min | **Priorité :** P2/P3

### Outils de diagnostic DNS
```powershell
# Résolution basique
nslookup domaine.com
nslookup domaine.com 8.8.8.8          # Forcer le serveur Google DNS
nslookup -type=MX domaine.com         # Enregistrements mail
nslookup -type=TXT domaine.com        # SPF / DKIM / DMARC / verification
nslookup -type=NS domaine.com         # Serveurs de noms autoritaires

# Résolution avancée (PowerShell)
Resolve-DnsName domaine.com -Type A
Resolve-DnsName domaine.com -Type MX
Resolve-DnsName domaine.com -Type TXT
Resolve-DnsName domaine.com -Server 8.8.8.8

# Vider le cache DNS local
ipconfig /flushdns
Clear-DnsClientCache

# Vérifier le cache DNS local
ipconfig /displaydns | findstr domaine.com
```

```bash
# Linux / macOS
dig domaine.com
dig domaine.com MX
dig domaine.com TXT
dig domaine.com NS
dig @8.8.8.8 domaine.com              # Forcer serveur DNS spécifique
dig +trace domaine.com                # Tracer la résolution complète

# Vérifier la propagation globale
# → Utiliser : https://dnschecker.org ou https://whatsmydns.net
```

### Vérification enregistrements email (SPF / DKIM / DMARC)
```powershell
# SPF (doit contenir include: ou ip4:)
nslookup -type=TXT domaine.com | findstr "v=spf1"

# DMARC
nslookup -type=TXT _dmarc.domaine.com

# DKIM (remplacer selector par le vrai sélecteur)
nslookup -type=TXT selector._domainkey.domaine.com
```

### Diagnostic TTL et propagation
```
TTL (Time To Live) = durée de vie en cache DNS (en secondes)
- TTL 300 = 5 min — changements propagés en ~5 min
- TTL 3600 = 1h — propagation en ~1h
- TTL 86400 = 24h — propagation en ~24h

Bonne pratique avant un changement DNS critique :
→ Réduire le TTL à 300 (5 min) 24-48h avant le changement
→ Effectuer le changement
→ Vérifier la propagation → remonter le TTL à 3600 ou 86400
```

---

## RB-DNS-002 — Gestion des enregistrements DNS courants

### Types d'enregistrements DNS

| Type | Usage | Exemple |
|---|---|---|
| A | IPv4 d'un hôte | `www → 1.2.3.4` |
| AAAA | IPv6 d'un hôte | `www → 2001:db8::1` |
| CNAME | Alias vers un autre nom | `mail → mailserver.domaine.com` |
| MX | Serveur(s) de messagerie | `@ → 10 mail.domaine.com` |
| TXT | Données texte (SPF, DKIM, DMARC, vérification) | `v=spf1 include:spf.protection.outlook.com -all` |
| NS | Serveurs de noms de la zone | `@ → ns1.registrar.com` |
| SOA | Autorité de la zone (généré auto) | — |
| PTR | Résolution inverse (IP → nom) | `4.3.2.1.in-addr.arpa → srv01.domaine.com` |
| SRV | Services spécifiques (SIP, Teams) | `_sip._tcp.domaine.com` |

### Enregistrements M365 requis
```
# Après migration vers Exchange Online — enregistrements obligatoires :
MX    : @       → domaine-com.mail.protection.outlook.com  (priorité 0)
CNAME : autodiscover → autodiscover.outlook.com
CNAME : lyncdiscover → webdir.online.lync.com
CNAME : sip        → sipdir.online.lync.com
TXT   : @       → v=spf1 include:spf.protection.outlook.com -all
TXT   : selector1._domainkey → [valeur DKIM depuis M365 Admin]
TXT   : _dmarc  → v=DMARC1; p=quarantine; rua=mailto:dmarc@domaine.com
```

### Enregistrements Google Workspace requis
```
MX    : @    → 1 aspmx.l.google.com
MX    : @    → 5 alt1.aspmx.l.google.com
MX    : @    → 5 alt2.aspmx.l.google.com
MX    : @    → 10 alt3.aspmx.l.google.com
MX    : @    → 10 alt4.aspmx.l.google.com
TXT   : @    → v=spf1 include:_spf.google.com -all
CNAME : google._domainkey → [valeur depuis Google Admin]
```

---

## RB-DNS-003 — Gestion des noms de domaine (Registrars)

### Registrars courants MSP

| Registrar | Console | Renouvellement |
|---|---|---|
| Namecheap | namecheap.com | Auto-renew recommandé |
| GoDaddy | godaddy.com | Vérifier date expiration |
| Cloudflare | cloudflare.com | DNS + Registrar combiné |
| CIRA (.ca) | cira.ca | Via revendeur agréé |
| Network Solutions | networksolutions.com | — |

### Transfert de domaine vers Cloudflare (recommandé)
```
Étapes :
1. Vérifier que le domaine a plus de 60 jours
2. Déverrouiller le domaine chez l'ancien registrar (Registrar Lock → OFF)
3. Obtenir le code de transfert (EPP/Auth code) chez l'ancien registrar
4. Cloudflare → Domains → Transfer Domain → saisir le code EPP
5. Confirmer par email (email du propriétaire du domaine)
6. Délai : 5-7 jours ouvrables
7. Les DNS sont préservés automatiquement par Cloudflare

IMPORTANT :
→ Ne pas modifier les NS pendant le transfert
→ Vérifier que l'email whois est accessible avant de commencer
→ Conserver le code EPP confidentiel → Passportal
```

### Vérification d'expiration de domaine
```powershell
# Windows (nécessite whois ou via web)
# Utiliser : https://lookup.icann.org ou https://who.is

# Commande whois (Linux)
whois domaine.com | grep -i "expir"
```

### Renouvellement d'urgence
```
Si le domaine a expiré (<30 jours) :
1. Se connecter au registrar → le domaine est en "Redemption Period"
2. Renouveler immédiatement — frais de rédemption possibles (+50-200$)
3. Propagation DNS : 24-48h après renouvellement
4. Vérifier que les emails et le site fonctionnent

Si le domaine a expiré (>30 jours) :
→ Risque de libération publique → agir en urgence
→ Contacter le registrar pour procédure de rachat
```

---

## RB-DNS-004 — DNS interne Windows Server (Active Directory)

### Vérification santé DNS AD
```powershell
# Vérifier le service DNS
Get-Service DNS | Select-Object Name, Status, StartType

# Tester la résolution interne
Resolve-DnsName domaine.local
Resolve-DnsName dc01.domaine.local

# Vérifier les enregistrements SRV (critiques pour AD)
nslookup -type=SRV _ldap._tcp.domaine.local
nslookup -type=SRV _kerberos._tcp.domaine.local

# Nettoyer et réenregistrer les SRV
ipconfig /registerdns
dnscmd /clearcache

# Vérifier les zones DNS
Get-DnsServerZone

# Diagnostic complet DNS
dcdiag /test:dns /v
```

### Problème résolution DNS AD courant
```powershell
# Les clients ne trouvent pas le DC
# Vérifier que les DNS clients pointent vers le DC
Get-NetIPConfiguration | Select-Object InterfaceAlias, DNSServer*

# Enregistrements manquants — forcer la réenregistration
ipconfig /registerdns
net stop netlogon
net start netlogon
# Attendre 5 min et retester
```
