# BUNDLE_INFRA_LINUX_V1
**Catégorie :** Administration Linux — Serveurs, services, diagnostic
**Agents :** @IT-MaintenanceMaster | @IT-Assistant-N3 | @IT-Commandare-Infra | IT-SysAdmin
**Version :** 1.0 | **Date :** 2026-04-05

---

## RB-LINUX-001 — Diagnostic serveur Linux — PRECHECK

```bash
# Uptime et charge
uptime
top -bn1 | head -5

# CPU, RAM, disque
free -h
df -h
iostat -x 1 3

# Processus les plus gourmands
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

# Connexions réseau actives
ss -tulnp
netstat -tulnp  # si ss non disponible

# Logs systeme recents
journalctl -xe --since "1 hour ago" --priority=3  # Erreurs seulement
tail -100 /var/log/syslog  # Ubuntu/Debian
tail -100 /var/log/messages  # CentOS/RHEL

# Services critiques
systemctl list-units --state=failed
systemctl status [NomService]
```

---

## RB-LINUX-002 — Gestion des services Linux (systemd)

```bash
# Lister tous les services actifs
systemctl list-units --type=service --state=running

# Démarrer / arrêter / redémarrer
systemctl start NomService
systemctl stop NomService
systemctl restart NomService
systemctl reload NomService     # Recharger config sans interruption

# Activer / désactiver au démarrage
systemctl enable NomService
systemctl disable NomService

# Statut détaillé + derniers logs
systemctl status NomService -l --no-pager

# Journaux du service
journalctl -u NomService --since "1 hour ago" -f  # -f = suivi temps réel
```

---

## RB-LINUX-003 — Gestion des mises à jour Linux

```bash
# Ubuntu / Debian
apt update && apt list --upgradable 2>/dev/null
apt upgrade -y
apt autoremove -y
apt autoclean

# CentOS / RHEL / Rocky Linux
dnf check-update
dnf update -y
dnf autoremove -y

# Vérifier si redémarrage requis
cat /var/run/reboot-required 2>/dev/null && echo "REBOOT REQUIS" || echo "Pas de redémarrage requis"
# OU
needs-restarting -r  # CentOS/RHEL

# Planifier une maintenance avec redémarrage
shutdown -r +5 "Redémarrage maintenance programmé dans 5 min"
shutdown -c  # Annuler
```

---

## RB-LINUX-004 — Gestion des utilisateurs Linux

```bash
# Lister les utilisateurs avec shell
cat /etc/passwd | grep -v nologin | grep -v false

# Créer un utilisateur
useradd -m -s /bin/bash NomUtilisateur
passwd NomUtilisateur

# Ajouter au groupe sudo
usermod -aG sudo NomUtilisateur   # Ubuntu/Debian
usermod -aG wheel NomUtilisateur  # CentOS/RHEL

# Verrouiller / déverrouiller un compte
usermod -L NomUtilisateur  # Lock
usermod -U NomUtilisateur  # Unlock

# Dernières connexions
last -10
lastlog | grep -v "Never logged"

# Tentatives de connexion echouees
grep "Failed password" /var/log/auth.log | tail -20
journalctl -u sshd | grep "Failed" | tail -20
```

---

## RB-LINUX-005 — SSH — Diagnostic et sécurisation

```bash
# Tester la connexion SSH
ssh -v utilisateur@serveur  # -v = verbose (debug)

# Vérifier le service SSH
systemctl status sshd

# Voir la configuration SSH active
sshd -T | grep -E "PasswordAuthentication|PermitRootLogin|Port|AllowUsers"

# Sécuriser SSH (sshd_config)
vim /etc/ssh/sshd_config
# Recommandations :
# PermitRootLogin no
# PasswordAuthentication no  (utiliser les clés SSH)
# Port 22  → changer si exposé sur Internet
# AllowUsers utilisateur1 utilisateur2
# MaxAuthTries 3

# Recharger SSH apres modification
systemctl reload sshd

# Gestion des clés SSH autorisees
cat ~/.ssh/authorized_keys  # Verifier les cles autorisees
```

---

## RB-LINUX-006 — Firewall Linux (UFW / firewalld)

```bash
# UFW (Ubuntu/Debian)
ufw status verbose
ufw allow 22/tcp    # SSH
ufw allow 443/tcp   # HTTPS
ufw deny 23/tcp     # Telnet
ufw enable
ufw reload

# firewalld (CentOS/RHEL)
firewall-cmd --list-all
firewall-cmd --add-service=https --permanent
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload
firewall-cmd --state
```
