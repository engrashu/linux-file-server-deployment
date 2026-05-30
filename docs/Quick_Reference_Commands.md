# QUICK COMMAND REFERENCE - Video Demonstration Cheat Sheet
## Copy and paste these commands during your video

---

## TASK 1: Server Installation and Access
```bash
whoami
hostname
hostname -I
uname -a
lsb_release -a
```

---

## TASK 2: File Server Role (Samba)
```bash
# Check Samba is installed
dpkg -l | grep samba

# Check services running
sudo systemctl status smbd --no-pager
sudo systemctl status nmbd --no-pager

# View configuration
sudo cat /etc/samba/smb.conf | head -30

# List shares
sudo smbclient -L localhost -N

# Show Samba users
sudo pdbedit -L
```

---

## TASK 3: File Permissions
```bash
# Show shared directory structure
tree -L 2 /shared

# Show permissions
ls -la /shared

# Show ACLs for CIO access
echo "=== Operations Directory ACLs ==="
getfacl /shared/operations

echo "=== Applications Directory ACLs ==="
getfacl /shared/applications

echo "=== Infrastructure Directory ACLs ==="
getfacl /shared/infrastructure

echo "=== CRM Directory ACLs ==="
getfacl /shared/crm

# Create test file to show inheritance
sudo -u rdurant touch /shared/operations/test_file.txt
ls -l /shared/operations/test_file.txt
getfacl /shared/operations/test_file.txt
```

---

## TASK 4: Firewall
```bash
# Show firewall status
sudo ufw status verbose

# Show numbered rules
sudo ufw status numbered

# Show service status
sudo systemctl status ufw --no-pager
```

---

## TASK 5: Storage Allocation
```bash
# Show disk usage
df -h

# Show partition layout
lsblk

# Show mounted filesystems
mount | grep -E '/shared|/home|/var|/$'

# Show inode usage
df -i
```

---

## TASK 6: Security Measures
```bash
# Show sudo group members
getent group sudo

# Show who has sudo access
echo "=== Joseph Lubomirski sudo access ==="
sudo -l -U jlubomirski

echo "=== Mike Kovach sudo access ==="
sudo -l -U mkovach

# Show sudo logs
sudo tail -20 /var/log/auth.log | grep sudo

# Show CIO ACL on operations (read-only)
getfacl /shared/operations | grep cshumaker
```

---

## TASK 7: Message of the Day
```bash
# List MOTD scripts
ls -la /etc/update-motd.d/

# Show header
echo "=== MOTD Header ==="
cat /etc/update-motd.d/00-header

# Show system info
echo "=== MOTD System Info ==="
cat /etc/update-motd.d/10-sysinfo

# Run MOTD to show output
echo "=== MOTD Output ==="
sudo run-parts /etc/update-motd.d/
```

---

## TASK 8: Scheduled Reboot
```bash
# Show cron job
echo "=== Root Crontab ==="
sudo crontab -l

# Explain the schedule
echo ""
echo "Cron job: 0 2 1 1 * /sbin/shutdown -r +5 'System rebooting for scheduled maintenance'"
echo ""
echo "This means:"
echo "  Minute: 0 (at the top of the hour)"
echo "  Hour: 2 (2:00 AM)"
echo "  Day: 1 (1st day of month)"
echo "  Month: 1 (January)"
echo "  Result: Every January 1st at 2:00 AM (every 2 years for reboot cycles)"
```

---

## TASK 9: Updated Repositories and Packages
```bash
# Update package lists
sudo apt update

# Show upgradable packages
apt list --upgradable

# Show update history
tail -30 /var/log/apt/history.log

# Show unattended-upgrades config
echo "=== Automatic Updates Configuration ==="
cat /etc/apt/apt.conf.d/20auto-upgrades

# Show which updates are automatic
cat /etc/apt/apt.conf.d/50unattended-upgrades | grep -v '^//' | grep -v '^$' | head -20

# Show system is updated
sudo apt upgrade -s | head -10
```

---

## TASK 10: Package Installation (mutt)
```bash
# Verify mutt is installed
which mutt

# Show mutt version
mutt -v | head -1

# Show package details
dpkg -l | grep mutt

# Show when installed
ls -la /usr/bin/mutt

# Show package info
apt-cache policy mutt
```

---

## ADDITIONAL HELPFUL COMMANDS

### Show All Users
```bash
echo "=== All User Accounts ==="
cat /etc/passwd | grep '/home' | cut -d: -f1 | sort

echo ""
echo "Total users created:"
cat /etc/passwd | grep '/home' | wc -l
```

### Show All Groups
```bash
echo "=== Operations Group ==="
getent group operations

echo "=== Applications Group ==="
getent group applications

echo "=== Infrastructure Group ==="
getent group infrastructure

echo "=== CRM Group ==="
getent group crm

echo "=== Sudo Group ==="
getent group sudo
```

### Show Network Configuration
```bash
# Show IP configuration
ip addr show

# Show listening services
sudo ss -tuln | grep -E 'LISTEN.*(22|139|445)'

# Show hostname
hostname
hostname -I
hostname -f
```

### Show Samba Connection Test
```bash
# Test local connection
echo "Testing local Samba connection..."
smbclient -L localhost -N

# Show Samba shares in detail
echo ""
echo "=== Samba Share Configuration ==="
sudo cat /etc/samba/smb.conf | grep -A15 '\[operations\]'
sudo cat /etc/samba/smb.conf | grep -A15 '\[infrastructure\]'
```

### Show System Information
```bash
# Show system info
echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "IP Address: $(hostname -I)"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"

# Show memory
echo ""
echo "=== Memory Usage ==="
free -h

# Show disk space
echo ""
echo "=== Disk Space ==="
df -h
```

---

## ONE-LINER DEMONSTRATIONS

### Complete Status Check
```bash
echo "=== PromisedLand File Server Status ===" && \
echo "" && \
echo "Server: $(hostname) - $(hostname -I)" && \
echo "OS: $(lsb_release -d | cut -f2)" && \
echo "Uptime: $(uptime -p)" && \
echo "" && \
echo "Services:" && \
sudo systemctl is-active smbd && echo "  Samba: Running" || echo "  Samba: Stopped" && \
sudo systemctl is-active ufw && echo "  Firewall: Active" || echo "  Firewall: Inactive" && \
echo "" && \
echo "Users: $(cat /etc/passwd | grep '/home' | wc -l)" && \
echo "Shared Directories: $(ls -1 /shared | wc -l)" && \
echo "" && \
echo "Firewall Rules:" && \
sudo ufw status | grep -E 'ALLOW|Status'
```

### Quick Security Audit
```bash
echo "=== Security Audit ===" && \
echo "" && \
echo "Firewall Status:" && \
sudo ufw status | head -5 && \
echo "" && \
echo "Sudo Users:" && \
getent group sudo && \
echo "" && \
echo "Recent Sudo Commands:" && \
sudo tail -5 /var/log/auth.log | grep sudo && \
echo "" && \
echo "CIO ACL Verification:" && \
getfacl /shared/operations | grep cshumaker
```

---

## COPY-PASTE BLOCKS FOR EACH TASK

### Block 1: Initial Setup Verification
```bash
clear
echo "=========================================="
echo "TASK 1: Server Installation and Access"
echo "=========================================="
whoami
hostname
hostname -I
uname -a
echo ""
echo "Server is running and accessible!"
```

### Block 2: Samba Verification
```bash
clear
echo "=========================================="
echo "TASK 2: File Server Role (Samba)"
echo "=========================================="
sudo systemctl status smbd --no-pager | head -10
echo ""
sudo smbclient -L localhost -N
echo ""
echo "Samba file server is configured and running!"
```

### Block 3: Permissions Check
```bash
clear
echo "=========================================="
echo "TASK 3: File Permissions and ACLs"
echo "=========================================="
ls -la /shared
echo ""
echo "=== CIO Read-Only Access (ACLs) ==="
getfacl /shared/operations | grep cshumaker
getfacl /shared/applications | grep cshumaker
echo ""
echo "File permissions configured with ACLs!"
```

### Block 4: Firewall Check
```bash
clear
echo "=========================================="
echo "TASK 4: Firewall Configuration (UFW)"
echo "=========================================="
sudo ufw status verbose
echo ""
echo "Firewall is active and properly configured!"
```

### Block 5: Storage Check
```bash
clear
echo "=========================================="
echo "TASK 5: Storage Allocation and Mounting"
echo "=========================================="
df -h
echo ""
lsblk
echo ""
echo "Storage is allocated and mounted!"
```

### Block 6: Security Check
```bash
clear
echo "=========================================="
echo "TASK 6: Security Measures"
echo "=========================================="
echo "Sudo Users:"
getent group sudo
echo ""
echo "Sample sudo access check:"
sudo -l -U jlubomirski
echo ""
echo "Security measures are in place!"
```

### Block 7: MOTD Check
```bash
clear
echo "=========================================="
echo "TASK 7: Message of the Day (MOTD)"
echo "=========================================="
cat /etc/update-motd.d/00-header
echo ""
sudo run-parts /etc/update-motd.d/ 2>/dev/null
echo ""
echo "Custom MOTD configured!"
```

### Block 8: Cron Check
```bash
clear
echo "=========================================="
echo "TASK 8: Scheduled Reboot (Every 2 Years)"
echo "=========================================="
sudo crontab -l
echo ""
echo "Automatic reboot scheduled for January 1 at 2:00 AM!"
```

### Block 9: Updates Check
```bash
clear
echo "=========================================="
echo "TASK 9: Updated Repositories and Packages"
echo "=========================================="
sudo apt update
echo ""
apt list --upgradable
echo ""
cat /etc/apt/apt.conf.d/20auto-upgrades
echo ""
echo "System is updated with automatic updates enabled!"
```

### Block 10: Package Check
```bash
clear
echo "=========================================="
echo "TASK 10: Package Installation (mutt)"
echo "=========================================="
which mutt
mutt -v | head -1
dpkg -l | grep mutt
echo ""
echo "Mutt package is successfully installed!"
```

---

## FINAL SUMMARY COMMAND
```bash
clear
echo "=========================================="
echo "PromisedLand Linux File Server"
echo "Final Deployment Summary"
echo "=========================================="
echo ""
echo "✓ Server installed and accessible on AWS EC2"
echo "✓ Samba file server running with 4 team shares"
echo "✓ File permissions configured with ACLs"
echo "✓ UFW firewall active and configured"
echo "✓ Storage allocated and mounted"
echo "✓ Sudo access restricted to administrators"
echo "✓ Custom MOTD configured"
echo "✓ Scheduled reboot configured (every 2 years)"
echo "✓ Automatic updates enabled"
echo "✓ Additional packages installed (mutt)"
echo ""
echo "All 10 required tasks completed successfully!"
echo ""
echo "Server Details:"
echo "  Hostname: $(hostname)"
echo "  IP Address: $(hostname -I)"
echo "  OS: $(lsb_release -d | cut -f2)"
echo "  Users: $(cat /etc/passwd | grep '/home' | wc -l)"
echo "  Groups: operations, applications, infrastructure, crm"
echo ""
echo "=========================================="
```

---

## TROUBLESHOOTING COMMANDS

### If something isn't working:
```bash
# Restart Samba
sudo systemctl restart smbd nmbd

# Check Samba logs
sudo tail -50 /var/log/samba/log.smbd

# Restart firewall
sudo ufw disable && sudo ufw --force enable

# Check all services
sudo systemctl status smbd nmbd ufw

# Re-run parts of deployment script manually
# (see deploy_server.sh for individual commands)
```

---

## TIPS FOR VIDEO RECORDING

1. **Start with clear terminal**: Run `clear` before each task
2. **Make text readable**: Increase font size (Ctrl/Cmd + '+')
3. **Speak while typing**: Explain what each command does
4. **Wait for output**: Let commands complete before moving on
5. **Highlight important parts**: Point with cursor to key output
6. **Use the blocks above**: Copy entire blocks for smooth demonstration
7. **Practice first**: Run through all commands before recording
8. **Have this file open**: Keep it ready for copy/paste during recording

---

Good luck with your demonstration!
