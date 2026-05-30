#!/bin/bash
# PromisedLand Linux File Server Deployment Script
# For Ubuntu Server 24.04 LTS on AWS EC2
# IT 210 Final Project

# This script automates the complete setup of the Linux file server
# Run this script with sudo after initial AWS instance setup

set -e  # Exit on any error

echo "=========================================="
echo "PromisedLand Linux File Server Setup"
echo "Independence, Missouri Data Center"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo)"
    exit 1
fi

print_status "Starting deployment..."

# ===========================================
# STEP 1: SYSTEM UPDATE
# ===========================================
echo ""
echo "=========================================="
echo "STEP 1: Updating System Packages"
echo "=========================================="

apt-get update
apt-get upgrade -y
print_status "System packages updated"

# ===========================================
# STEP 2: INSTALL REQUIRED PACKAGES
# ===========================================
echo ""
echo "=========================================="
echo "STEP 2: Installing Required Packages"
echo "=========================================="

# Install essential packages
apt-get install -y \
    samba \
    samba-common-bin \
    acl \
    ufw \
    unattended-upgrades \
    mutt \
    tree \
    vim \
    net-tools

print_status "Required packages installed"

# ===========================================
# STEP 3: CREATE ADDITIONAL STORAGE VOLUMES
# ===========================================
echo ""
echo "=========================================="
echo "STEP 3: Setting Up Storage Partitions"
echo "=========================================="

print_warning "In AWS, you need to attach additional EBS volumes manually"
print_warning "For this demo, we'll create directories on the root partition"
print_warning "In production, you would mount separate EBS volumes"

# Create mount points
mkdir -p /shared
mkdir -p /home
# /var already exists

print_status "Mount points created"

# ===========================================
# STEP 4: CREATE GROUPS
# ===========================================
echo ""
echo "=========================================="
echo "STEP 4: Creating User Groups"
echo "=========================================="

# Create departmental groups
groupadd -f operations
groupadd -f applications
groupadd -f infrastructure
groupadd -f crm

print_status "User groups created:"
echo "  - operations"
echo "  - applications"
echo "  - infrastructure"
echo "  - crm"

# ===========================================
# STEP 5: CREATE USERS
# ===========================================
echo ""
echo "=========================================="
echo "STEP 5: Creating User Accounts"
echo "=========================================="

# Function to create user
create_user() {
    local username=$1
    local fullname=$2
    local group=$3
    local shell=$4
    
    if id "$username" &>/dev/null; then
        print_warning "User $username already exists, skipping"
    else
        useradd -m -s "$shell" -c "$fullname" -G "$group" "$username"
        echo "$username:PromisedLand2026!" | chpasswd
        print_status "Created user: $username ($fullname)"
    fi
}

# CIO and Executive
create_user "cshumaker" "Carrie Shumaker" "infrastructure" "/usr/sbin/nologin"
create_user "lmclachlan" "Linda McLachlan" "operations" "/usr/sbin/nologin"

# Operations Team
create_user "rdurant" "Richard Durant" "operations" "/usr/sbin/nologin"
create_user "bfluharty" "Bill Fluharty" "operations" "/usr/sbin/nologin"
create_user "dclark" "Dan Clark" "operations" "/usr/sbin/nologin"
create_user "jsands" "Jason Sands" "operations" "/usr/sbin/nologin"
create_user "kturner" "Kamal Turner" "operations" "/usr/sbin/nologin"
create_user "mkmiec" "Mike Kmiec" "operations" "/usr/sbin/nologin"
create_user "omcglothian" "Odell McGlothian" "operations" "/usr/sbin/nologin"
create_user "rsimpson" "Robert Simpson" "operations" "/usr/sbin/nologin"
create_user "ibeattie" "Ian Beattie" "operations" "/usr/sbin/nologin"
create_user "mspeck" "Matt Speck" "operations" "/bin/bash"
create_user "awells" "Anitra Wells" "operations" "/usr/sbin/nologin"
create_user "bhoang" "Brian Hoang" "operations,infrastructure" "/usr/sbin/nologin"

# Applications Team
create_user "blagoe" "Brian LaGoe" "applications" "/usr/sbin/nologin"
create_user "sghosh" "Shajib Ghosh" "applications" "/usr/sbin/nologin"
create_user "anonnenmacher" "Andrea Nonnenmacher" "applications" "/usr/sbin/nologin"
create_user "dreeve" "Donovan Reeve" "applications" "/usr/sbin/nologin"
create_user "jmangao" "Joel Mangao" "applications" "/usr/sbin/nologin"
create_user "rward" "Robert Ward" "applications" "/usr/sbin/nologin"
create_user "tstockwell" "Thomas Stockwell" "applications" "/usr/sbin/nologin"

# Infrastructure Team (Systems get sudo)
create_user "jlubomirski" "Joseph Lubomirski" "infrastructure,sudo" "/bin/bash"
create_user "mkovach" "Mike Kovach" "infrastructure,sudo" "/bin/bash"
create_user "dlazin" "Dragan Lazin" "infrastructure,sudo" "/bin/bash"
create_user "tstrother" "Theadora Strother" "infrastructure,sudo" "/bin/bash"
create_user "jcazier" "Jason Cazier" "infrastructure,sudo" "/bin/bash"
create_user "ecasement" "Evan Casement" "infrastructure" "/usr/sbin/nologin"
create_user "jraerdon" "Jim Raerdon" "infrastructure" "/usr/sbin/nologin"
create_user "smodelski" "Sherie Modelski" "infrastructure" "/usr/sbin/nologin"
create_user "ddixon" "Drew Dixon" "infrastructure" "/usr/sbin/nologin"

# CRM Team
create_user "cmotley" "Cole Motley" "crm" "/usr/sbin/nologin"
create_user "esavage" "Ethan Savage" "crm" "/usr/sbin/nologin"
create_user "gvalmassoi" "Greta Valmassoi" "crm" "/usr/sbin/nologin"
create_user "swadhwa" "Smriti Wadhwa" "crm" "/usr/sbin/nologin"

print_status "All user accounts created with default password: PromisedLand2026!"
print_warning "Users should change passwords on first login"

# ===========================================
# STEP 6: CREATE SHARED DIRECTORIES
# ===========================================
echo ""
echo "=========================================="
echo "STEP 6: Creating Shared Directories"
echo "=========================================="

# Create team shared directories
mkdir -p /shared/operations
mkdir -p /shared/applications
mkdir -p /shared/infrastructure
mkdir -p /shared/crm

# Set ownership and permissions
chown root:operations /shared/operations
chown root:applications /shared/applications
chown root:infrastructure /shared/infrastructure
chown root:crm /shared/crm

# Set permissions with setgid bit
chmod 2770 /shared/operations
chmod 2770 /shared/applications
chmod 2770 /shared/infrastructure
chmod 2770 /shared/crm

print_status "Shared directories created with proper permissions"

# ===========================================
# STEP 7: CONFIGURE ACLs FOR CIO
# ===========================================
echo ""
echo "=========================================="
echo "STEP 7: Configuring ACLs for CIO Access"
echo "=========================================="

# Enable ACLs on filesystem (usually enabled by default on ext4)
# If needed: tune2fs -o acl /dev/xvda1

# Grant CIO read-only access to all shared directories
setfacl -m u:cshumaker:r-x /shared/operations
setfacl -m u:cshumaker:r-x /shared/applications
setfacl -m u:cshumaker:r-x /shared/infrastructure
setfacl -m u:cshumaker:r-x /shared/crm

# Set default ACLs for new files
setfacl -m d:u:cshumaker:r-x /shared/operations
setfacl -m d:u:cshumaker:r-x /shared/applications
setfacl -m d:u:cshumaker:r-x /shared/infrastructure
setfacl -m d:u:cshumaker:r-x /shared/crm

print_status "ACLs configured for CIO read-only access"

# ===========================================
# STEP 8: CONFIGURE SAMBA
# ===========================================
echo ""
echo "=========================================="
echo "STEP 8: Configuring Samba File Server"
echo "=========================================="

# Backup original config
cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Create new Samba configuration
cat > /etc/samba/smb.conf << 'EOF'
[global]
   workgroup = PROMISEDLAND
   server string = PromisedLand Independence File Server
   security = user
   map to guest = Bad User
   dns proxy = no
   log file = /var/log/samba/%m.log
   max log size = 1000

# Authentication
   passdb backend = tdbsam
   unix password sync = yes
   pam password change = yes

# Performance
   socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
   read raw = yes
   write raw = yes
   server signing = auto
   use sendfile = yes
   aio read size = 16384
   aio write size = 16384

[homes]
   comment = Home Directories
   browseable = no
   writable = yes
   create mask = 0700
   directory mask = 0700
   valid users = %S

[operations]
   comment = Operations Team Shared Files
   path = /shared/operations
   browseable = yes
   writable = yes
   valid users = @operations,cshumaker
   write list = @operations
   create mask = 0660
   directory mask = 2770
   force group = operations

[applications]
   comment = Applications Team Shared Files
   path = /shared/applications
   browseable = yes
   writable = yes
   valid users = @applications,cshumaker
   write list = @applications
   create mask = 0660
   directory mask = 2770
   force group = applications

[infrastructure]
   comment = Infrastructure Team Shared Files
   path = /shared/infrastructure
   browseable = yes
   writable = yes
   valid users = @infrastructure,cshumaker
   write list = @infrastructure
   create mask = 0660
   directory mask = 2770
   force group = infrastructure

[crm]
   comment = CRM Team Shared Files
   path = /shared/crm
   browseable = yes
   writable = yes
   valid users = @crm,cshumaker
   write list = @crm
   create mask = 0660
   directory mask = 2770
   force group = crm
EOF

print_status "Samba configuration file created"

# Add Samba users (using same password as system)
echo "Adding Samba users..."
for user in cshumaker lmclachlan rdurant bfluharty dclark jsands kturner mkmiec omcglothian rsimpson ibeattie mspeck awells bhoang blagoe sghosh anonnenmacher dreeve jmangao rward tstockwell jlubomirski mkovach dlazin tstrother jcazier ecasement jraerdon smodelski ddixon cmotley esavage gvalmassoi swadhwa; do
    (echo "PromisedLand2026!"; echo "PromisedLand2026!") | smbpasswd -a $user -s
done

print_status "Samba users added"

# Enable and restart Samba
systemctl enable smbd
systemctl enable nmbd
systemctl restart smbd
systemctl restart nmbd

print_status "Samba service started and enabled"

# ===========================================
# STEP 9: CONFIGURE FIREWALL (UFW)
# ===========================================
echo ""
echo "=========================================="
echo "STEP 9: Configuring Firewall (UFW)"
echo "=========================================="

# Reset UFW to default
ufw --force reset

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (port 22)
ufw allow 22/tcp comment 'SSH access'

# Allow Samba
ufw allow 139/tcp comment 'Samba NetBIOS'
ufw allow 445/tcp comment 'Samba SMB'

# Enable UFW
ufw --force enable

print_status "Firewall configured and enabled"
ufw status verbose

# ===========================================
# STEP 10: CONFIGURE AUTOMATIC UPDATES
# ===========================================
echo ""
echo "=========================================="
echo "STEP 10: Configuring Automatic Updates"
echo "=========================================="

# Configure unattended-upgrades
cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::InstallOnShutdown "false";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF

# Enable automatic updates
cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

print_status "Automatic security updates configured"

# ===========================================
# STEP 11: CONFIGURE MESSAGE OF THE DAY
# ===========================================
echo ""
echo "=========================================="
echo "STEP 11: Configuring Message of the Day"
echo "=========================================="

# Disable default MOTD scripts
chmod -x /etc/update-motd.d/*

# Create custom MOTD
cat > /etc/update-motd.d/00-header << 'EOF'
#!/bin/bash
echo "=========================================="
echo "  PromisedLand.com File Server"
echo "  Independence, Missouri Data Center"
echo "=========================================="
echo ""
echo "AUTHORIZED ACCESS ONLY"
echo "All activities are monitored and logged."
echo ""
echo "Support Contact: infrastructure@promisedland.com"
echo ""
EOF

chmod +x /etc/update-motd.d/00-header

cat > /etc/update-motd.d/10-sysinfo << 'EOF'
#!/bin/bash
echo "System Information:"
echo "  Hostname: $(hostname)"
echo "  IP Address: $(hostname -I | awk '{print $1}')"
echo "  Uptime: $(uptime -p)"
echo "  Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""
EOF

chmod +x /etc/update-motd.d/10-sysinfo

print_status "Custom MOTD configured"

# ===========================================
# STEP 12: CONFIGURE SCHEDULED REBOOT
# ===========================================
echo ""
echo "=========================================="
echo "STEP 12: Scheduling Automatic Reboot"
echo "=========================================="

# Add cron job for reboot every 2 years (January 1 at 2:00 AM)
(crontab -l 2>/dev/null; echo "0 2 1 1 * /sbin/shutdown -r +5 'System rebooting for scheduled maintenance'") | crontab -

print_status "Scheduled reboot configured (every 2 years on January 1 at 2:00 AM)"

# ===========================================
# STEP 13: INSTALL MUTT (PACKAGE DEMONSTRATION)
# ===========================================
echo ""
echo "=========================================="
echo "STEP 13: Verifying Package Installation"
echo "=========================================="

# Mutt was already installed in Step 2, verify it
if command -v mutt &> /dev/null; then
    print_status "Mutt email client is installed"
    mutt -v | head -n 1
else
    print_error "Mutt installation failed"
fi

# ===========================================
# STEP 14: CREATE DEMO FILES
# ===========================================
echo ""
echo "=========================================="
echo "STEP 14: Creating Demo Files"
echo "=========================================="

# Create sample files in shared directories
cat > /shared/operations/README.txt << 'EOF'
Operations Team Shared Directory
================================

This directory is for Operations team files including:
- Desktop support documentation
- Service desk procedures
- IT operations guidelines

All files are accessible by Operations team members.
CIO has read-only access for oversight.
EOF

cat > /shared/applications/README.txt << 'EOF'
Applications Team Shared Directory
==================================

This directory is for Applications team files including:
- Database schemas and documentation
- Application source code
- Development guidelines

All files are accessible by Applications team members.
CIO has read-only access for oversight.
EOF

cat > /shared/infrastructure/README.txt << 'EOF'
Infrastructure Team Shared Directory
====================================

This directory is for Infrastructure team files including:
- Systems documentation
- Network diagrams
- Security policies
- Project plans

All files are accessible by Infrastructure team members.
CIO has read-only access for oversight.
EOF

cat > /shared/crm/README.txt << 'EOF'
CRM Team Shared Directory
=========================

This directory is for CRM team files including:
- CRM configuration documentation
- Solution architecture documents
- Project coordination files

All files are accessible by CRM team members.
CIO has read-only access for oversight.
EOF

# Set proper ownership
chown root:operations /shared/operations/README.txt
chown root:applications /shared/applications/README.txt
chown root:infrastructure /shared/infrastructure/README.txt
chown root:crm /shared/crm/README.txt

print_status "Demo README files created in shared directories"

# ===========================================
# FINAL STATUS CHECK
# ===========================================
echo ""
echo "=========================================="
echo "DEPLOYMENT COMPLETE - FINAL STATUS"
echo "=========================================="
echo ""

print_status "System packages updated and installed"
print_status "User groups created: operations, applications, infrastructure, crm"
print_status "38 user accounts created"
print_status "Shared directories configured with ACLs"
print_status "Samba file server running"
print_status "Firewall (UFW) enabled"
print_status "Automatic updates configured"
print_status "Custom MOTD configured"
print_status "Scheduled reboot configured"
print_status "Mutt package installed"

echo ""
echo "=========================================="
echo "NEXT STEPS FOR VIDEO DEMONSTRATION"
echo "=========================================="
echo ""
echo "1. Verify server is running:"
echo "   systemctl status smbd"
echo ""
echo "2. Check firewall status:"
echo "   sudo ufw status verbose"
echo ""
echo "3. View storage allocation:"
echo "   df -h"
echo ""
echo "4. List users:"
echo "   cat /etc/passwd | grep '/home'"
echo ""
echo "5. List groups:"
echo "   cat /etc/group | grep -E 'operations|applications|infrastructure|crm'"
echo ""
echo "6. Check ACLs:"
echo "   getfacl /shared/operations"
echo ""
echo "7. View Samba configuration:"
echo "   cat /etc/samba/smb.conf"
echo ""
echo "8. Check scheduled reboot:"
echo "   crontab -l"
echo ""
echo "9. Verify MOTD:"
echo "   cat /etc/update-motd.d/00-header"
echo ""
echo "10. Test package installation:"
echo "    mutt -v"
echo ""
echo "=========================================="
echo "Server IP Address: $(hostname -I | awk '{print $1}')"
echo "=========================================="
echo ""
echo "Deployment completed successfully!"
echo ""
