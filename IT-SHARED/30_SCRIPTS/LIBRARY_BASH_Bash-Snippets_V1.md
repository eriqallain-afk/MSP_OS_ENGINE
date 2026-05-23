# LIBRARY_BASH_Bash-Snippets_V1
**Agent :** IT-ScriptMaster, IT-Assistant-N3 | IT-MaintenanceMaster | IT-SysAdmin
**Usage :** Snippets Bash/Shell réutilisables — Linux, XCP-ng, switches SSH
**Mis à jour :** 2026-03-20

---

## 1. SYSTÈME LINUX — INFO DE BASE

```bash
# Info système complète
echo "=== HOSTNAME / OS ===" && hostnamectl
echo "=== UPTIME ===" && uptime -p
echo "=== CPU ===" && top -bn1 | grep "Cpu(s)"
echo "=== RAM ===" && free -h
echo "=== DISQUES ===" && df -h | grep -v tmpfs

# Services systemd (actifs et en échec)
systemctl list-units --state=failed
systemctl status [service]
systemctl restart [service]

# Logs système récents
journalctl -xe --no-pager | tail -50
journalctl -u [service] --since "1 hour ago" --no-pager
```

---

## 2. RÉSEAU LINUX

```bash
# Interfaces réseau
ip addr show
ip route show

# Test connectivité
ping -c 4 8.8.8.8
curl -s --max-time 5 https://google.com -o /dev/null && echo "OK" || echo "KO"

# Connexions actives
ss -tunapl | grep ESTABLISHED | head -20
netstat -tunapl | grep ESTABLISHED | head -20

# DNS
dig google.com
nslookup google.com
```

---

## 3. XCP-ng / XENSERVER

```bash
# État des VMs
xe vm-list params=name-label,power-state,VCPUs-number,memory-static-max

# Démarrer / Arrêter une VM
VM_UUID=$(xe vm-list name-label="NOM-VM" --minimal)
xe vm-start uuid=$VM_UUID
xe vm-shutdown uuid=$VM_UUID --force

# Snapshot
xe vm-snapshot vm=$VM_UUID new-name-label="@T12345_Preboot_NOM-VM_$(date +%Y%m%d_%H%M)"

# Espace Storage Repositories
xe sr-list params=name-label,physical-size,physical-utilisation

# Logs hôte
tail -100 /var/log/xensource.log | grep -i "error\|warn\|critical"

# Services hôte
service xapi status
service xenconsoled status
```

---

## 4. MIKROTIK (SSH)

```bash
# État système
/system resource print
/interface print
/ip address print
/ip route print

# Logs récents
/log print where topics~"error" | head -20
/log print where topics~"critical"

# VPN
/ip ipsec active-peers print
/interface l2tp-server sessions print

# Backup config
/system backup save name=backup_$(date +%Y%m%d)
/export file=config_$(date +%Y%m%d)
```

---

## 5. SWITCHES / ÉQUIPEMENTS RÉSEAU (SSH générique)

```bash
# Cisco IOS / IOS-XE
show version
show interfaces status
show ip interface brief
show log | tail
show running-config

# Vérifier l'état des ports
show interfaces status | grep -v notconnect

# Ubiquiti UniFi AP (SSH)
info
cat /var/log/messages | tail -50
set-inform http://[IP_CONTROLEUR]:8080/inform

# Fortinet (CLI)
get system status
get system performance status
get vpn ipsec tunnel summary
diagnose sniffer packet any "host [IP]" 4 10
```

---

## 6. UTILITAIRES COURANTS

```bash
# Chercher un fichier
find / -name "*.conf" -type f 2>/dev/null
find /var/log -name "*.log" -mtime -1  # modifiés depuis 24h

# Espace disque — top dossiers
du -sh /* 2>/dev/null | sort -rh | head -20
du -sh /var/log/* | sort -rh | head -10

# Processus — top par RAM
ps aux --sort=-%mem | head -15

# Processus — top par CPU
ps aux --sort=-%cpu | head -15

# Tuer un processus
kill -9 $(pgrep -f "nom_processus")

# Copier un fichier vers un autre serveur
scp /chemin/fichier.ext user@serveur:/destination/
rsync -avz /source/ user@serveur:/destination/
```

---

## 7. MASQUAGE IP (OBLIGATOIRE DANS LES LOGS)

```bash
# Masquer les IPs dans un output avant de coller dans CW
echo "$OUTPUT" | sed 's/\b\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\b/[IP]/g'

# Utilisation en pipe
cat /var/log/syslog | grep error | sed 's/\b\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\b/[IP]/g'
```
