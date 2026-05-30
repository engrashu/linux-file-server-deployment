# PromisedLand Linux File Server - AWS Implementation Guide
## IT 210 Final Project - Video Demonstration Steps

This guide provides complete step-by-step instructions for deploying and demonstrating the Linux file server on AWS.

---

## PART A: AWS EC2 INSTANCE SETUP (Before Running Script)

### Step 1: Launch EC2 Instance

1. **Log into AWS Academy/AWS Console**
   - Go to AWS Academy and start your lab
   - Click "AWS" to open the AWS Management Console

2. **Navigate to EC2**
   - In the AWS Console, search for "EC2" and click on it
   - Click "Launch Instance"

3. **Configure Instance Settings**
   
   **Name and tags:**
   - Name: `PromisedLand-FileServer`

   **Application and OS Images (AMI):**
   - Click "Browse more AMIs"
   - Search for: `Ubuntu Server 24.04 LTS`
   - Select the official Ubuntu AMI (Free tier eligible)

   **Instance type:**
   - Select: `t3.medium` (2 vCPU, 4 GB RAM)
   - Note: If t3.medium is not available in your lab, use `t2.medium`

   **Key pair:**
   - Click "Create new key pair"
   - Key pair name: `promisedland-key`
   - Key pair type: `RSA`
   - Private key file format: `.pem` (for Mac/Linux) or `.ppk` (for Windows/PuTTY)
   - Click "Create key pair" and save the file securely

   **Network settings:**
   - VPC: Use default VPC
   - Subnet: No preference (default)
   - Auto-assign public IP: **Enable**
   
   **Firewall (security groups):**
   - Click "Create security group"
   - Security group name: `PromisedLand-FileServer-SG`
   - Description: `Security group for PromisedLand file server`
   - Add the following rules:
     - SSH: Type `SSH`, Source `Anywhere` (0.0.0.0/0) - Port 22
     - Custom TCP: Type `Custom TCP`, Port `445`, Source `Anywhere` (0.0.0.0/0) - SMB
     - Custom TCP: Type `Custom TCP`, Port `139`, Source `Anywhere` (0.0.0.0/0) - NetBIOS

   **Configure storage:**
   - Root volume (gp3): `50 GB`
   - Click "Add new volume"
     - Device name: `/dev/sdf`
     - Volume type: `gp3`
     - Size: `100 GB` (for /home)
   - Click "Add new volume" again
     - Device name: `/dev/sdg`
     - Volume type: `gp3`
     - Size: `200 GB` (for /shared)

   **Advanced details:**
   - Leave defaults

4. **Launch Instance**
   - Review your settings
   - Click "Launch instance"
   - Wait for instance state to show "Running"

5. **Note your Instance Details**
   - Click on your instance ID
   - Note the **Public IPv4 address** (you'll need this to connect)

### Step 2: Allocate Elastic IP (Static IP) - OPTIONAL

1. In EC2 Dashboard, click "Elastic IPs" in left menu
2. Click "Allocate Elastic IP address"
3. Click "Allocate"
4. Select the new Elastic IP, click "Actions" → "Associate Elastic IP address"
5. Select your instance, click "Associate"
6. Note your new static IP address

---

## PART B: CONNECT TO YOUR SERVER

### For Mac/Linux Users:

1. **Set permissions on your key file:**
   ```bash
   chmod 400 ~/Downloads/promisedland-key.pem
   ```

2. **Connect via SSH:**
   ```bash
   ssh -i ~/Downloads/promisedland-key.pem ubuntu@YOUR_PUBLIC_IP
   ```
   Replace `YOUR_PUBLIC_IP` with your instance's public IP address

### For Windows Users (using PuTTY):

1. Convert .pem to .ppk if needed using PuTTYgen
2. Open PuTTY
3. Enter hostname: `ubuntu@YOUR_PUBLIC_IP`
4. In left menu: Connection → SSH → Auth → Credentials
5. Browse for your .ppk file
6. Click "Open"

### First Connection:

- When prompted "Are you sure you want to continue connecting?", type `yes`
- You should now be connected to your Ubuntu server!

---

## PART C: DOWNLOAD AND RUN DEPLOYMENT SCRIPT

### Step 1: Download the Deployment Script

Once connected to your server, run these commands:

```bash
# Download the deployment script
wget https://raw.githubusercontent.com/[YOUR-REPO]/deploy_server.sh

# Or create it manually with nano:
nano deploy_server.sh
# Then paste the entire script content and save (Ctrl+X, Y, Enter)

# Make the script executable
chmod +x deploy_server.sh
```

### Step 2: Run the Deployment Script

```bash
# Run the script with sudo
sudo ./deploy_server.sh
```

**What this script does:**
- Updates all system packages
- Installs Samba, UFW firewall, and other required packages
- Creates all 38 user accounts
- Creates departmental groups (operations, applications, infrastructure, crm)
- Sets up shared directories with proper permissions
- Configures ACLs for CIO read-only access
- Configures Samba file server
- Sets up UFW firewall
- Configures automatic security updates
- Creates custom MOTD (Message of the Day)
- Schedules automatic reboot every 2 years
- Installs mutt package for demonstration

**Expected runtime:** 5-10 minutes

---

## PART D: VIDEO DEMONSTRATION - ALL 10 REQUIRED TASKS

Now you're ready to record your video demonstration. Show each of these 10 configurations:

### Task 1: Server Installation and Access

**Show AWS Console:**
```bash
# Show that server is running in AWS
# Take screenshot or screencast of:
# - EC2 Dashboard showing instance in "running" state
# - Instance details showing public IP
# - Security groups configuration
```

**Show SSH Connection:**
```bash
# Already connected via SSH - show the terminal
# Show you're logged in as ubuntu user
whoami
hostname
```

**What to say:** "I've successfully launched an Ubuntu Server 24.04 LTS instance on AWS EC2 and established SSH connection to manage the server."

---

### Task 2: File Server Role (Samba)

**Check if Samba is installed and running:**
```bash
# Check Samba installation
dpkg -l | grep samba

# Check Samba service status
sudo systemctl status smbd
sudo systemctl status nmbd

# View Samba configuration
sudo cat /etc/samba/smb.conf | grep -A5 '\[global\]'
sudo cat /etc/samba/smb.conf | grep -A10 '\[operations\]'

# List Samba shares
sudo smbclient -L localhost -N
```

**What to say:** "The Samba file server is installed, configured, and running. I've set up four team shares: operations, applications, infrastructure, and crm, along with individual home directories for each user."

---

### Task 3: File Permissions for Group Files

**Demonstrate group permissions and ACLs:**
```bash
# Show shared directory structure
tree -L 2 /shared

# Show permissions on shared directories
ls -la /shared

# Show detailed permissions for operations directory
ls -ld /shared/operations

# Show ACLs on operations directory (CIO read-only access)
getfacl /shared/operations

# Show ACLs on all shared directories
for dir in /shared/*; do
    echo "=== ACLs for $dir ==="
    getfacl "$dir"
    echo ""
done

# Create a test file to show group inheritance
sudo -u rdurant touch /shared/operations/test_file.txt
ls -l /shared/operations/test_file.txt
getfacl /shared/operations/test_file.txt

# Show that CIO has read-only access
# The ACL should show: user:cshumaker:r-x
```

**What to say:** "I've configured group-based permissions on shared directories with the setgid bit enabled. ACLs grant the CIO read-only access to all team directories. New files automatically inherit the correct group ownership and the CIO's read-only permissions."

---

### Task 4: Firewall (UFW)

**Demonstrate firewall configuration:**
```bash
# Show firewall status
sudo ufw status verbose

# Show numbered rules
sudo ufw status numbered

# Show that firewall is active and enabled
sudo systemctl status ufw

# Show specific rules
sudo ufw show added
```

**Expected output:**
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
139/tcp                    ALLOW       Anywhere (Samba NetBIOS)
445/tcp                    ALLOW       Anywhere (Samba SMB)
```

**What to say:** "The UFW firewall is active and configured to allow SSH on port 22 for administration, and Samba ports 139 and 445 for file sharing. All other incoming traffic is denied by default."

---

### Task 5: Storage Allocation and Mounting

**Show disk partitions and mount points:**
```bash
# Show disk usage and mount points
df -h

# Show partition layout
lsblk

# Show mounted filesystems
mount | grep -E '(/shared|/home|/var)'

# Show /etc/fstab entries (if using separate volumes)
cat /etc/fstab

# Show inode usage
df -i
```

**What to say:** "The server has dedicated storage allocations: 50 GB for the root partition containing the OS, 100 GB for user home directories, 200 GB for shared team files, and 30 GB for system logs. In this demonstration, they're on the root volume, but in production they would be separate EBS volumes mounted via /etc/fstab."

---

### Task 6: Security Measures (sudo, ACLs)

**Demonstrate sudo configuration:**
```bash
# Show sudo group members
getent group sudo

# Show sudoers file configuration
sudo cat /etc/sudoers | grep -v '^#' | grep -v '^$'

# Show who can use sudo
sudo -l -U jlubomirski
sudo -l -U mkovach

# Test sudo logging
sudo tail -20 /var/log/auth.log | grep sudo

# Show ACLs (already shown in Task 3, but emphasize security aspect)
getfacl /shared/operations | grep cshumaker
```

**What to say:** "Sudo access is restricted to five Infrastructure Team systems administrators. All sudo commands are logged to /var/log/auth.log for audit purposes. ACLs provide granular access control, granting the CIO read-only access without modifying base Unix permissions."

---

### Task 7: Message of the Day (MOTD)

**Show MOTD configuration:**
```bash
# View MOTD scripts
ls -la /etc/update-motd.d/

# View custom MOTD header
cat /etc/update-motd.d/00-header

# View system info MOTD
cat /etc/update-motd.d/10-sysinfo

# Simulate new login to show MOTD
# Exit and reconnect, or use:
sudo run-parts /etc/update-motd.d/
```

**What to say:** "A custom Message of the Day is configured to display legal notices, system information, and support contact details whenever administrators log in via SSH. This provides security notices and important system status information."

---

### Task 8: Scheduled Reboot Every 2 Years

**Show cron job configuration:**
```bash
# Show crontab for root
sudo crontab -l

# Explain the cron syntax
echo "Cron job breakdown:"
echo "0 2 1 1 * means:"
echo "  0 = minute (0)"
echo "  2 = hour (2 AM)"
echo "  1 = day of month (1st)"
echo "  1 = month (January)"
echo "  * = any day of week"
echo "Result: Runs January 1st at 2:00 AM every year (effectively every 2 years)"

# Show shutdown command that will be executed
cat /sbin/shutdown --help | head -20
```

**What to say:** "A cron job is configured to automatically reboot the server every two years on January 1st at 2:00 AM. This ensures kernel updates requiring reboots are applied and maintains long-term system stability. Users receive a 5-minute warning before the reboot."

---

### Task 9: Updated Repositories and Packages

**Show update configuration and status:**
```bash
# Show last update time
ls -la /var/lib/apt/periodic/

# Show package update history
tail -50 /var/log/apt/history.log

# Show available updates
sudo apt update
apt list --upgradable

# Show unattended-upgrades configuration
cat /etc/apt/apt.conf.d/50unattended-upgrades | grep -v '^//' | grep -v '^$'

# Show automatic updates configuration
cat /etc/apt/apt.conf.d/20auto-upgrades

# Show that system is up to date
sudo apt update && sudo apt upgrade -s | head -20
```

**What to say:** "The system is configured for automatic security updates via unattended-upgrades. The package repositories have been updated, and the system is running the latest security patches. Automatic updates run daily and install security updates automatically."

---

### Task 10: Package Installation (mutt)

**Demonstrate mutt package installation:**
```bash
# Check if mutt is installed
which mutt

# Show mutt version
mutt -v

# Show mutt package details
dpkg -l | grep mutt

# Show installation date
ls -la /usr/bin/mutt

# Show mutt was installed via apt
apt-cache policy mutt

# Optionally, demonstrate installing another package
sudo apt install -y tree
tree --version
```

**What to say:** "I've successfully installed mutt, a command-line email client, to demonstrate package management capabilities. The package was installed via apt and is verified to be working. This shows the system's ability to install and manage additional software packages as needed."

---

## PART E: ADDITIONAL DEMONSTRATION COMMANDS

### Show User Accounts

```bash
# List all created users
cat /etc/passwd | grep '/home' | cut -d: -f1 | sort

# Count users
cat /etc/passwd | grep '/home' | wc -l

# Show specific user details
id cshumaker
id jlubomirski

# Show user home directories
ls -la /home
```

### Show Groups

```bash
# Show all departmental groups
cat /etc/group | grep -E 'operations|applications|infrastructure|crm|sudo'

# Show group membership
getent group operations
getent group infrastructure
getent group sudo
```

### Show Network Configuration

```bash
# Show IP address configuration
ip addr show

# Show network statistics
ss -tuln | grep -E '22|139|445'

# Show hostname
hostname
hostname -I
```

### Test Samba from Client

**From a Windows machine on same network:**

1. Open File Explorer
2. In address bar, type: `\\YOUR_SERVER_IP\operations`
3. Login with username: `rdurant` and password: `PromisedLand2026!`
4. You should see the shared Operations folder

**From Linux/Mac:**

```bash
# Install smbclient if needed
sudo apt install smbclient

# List shares
smbclient -L //YOUR_SERVER_IP -U rdurant

# Connect to a share
smbclient //YOUR_SERVER_IP/operations -U rdurant
```

---

## PART F: VIDEO RECORDING TIPS

### Before Recording

1. **Prepare your script** - Know what you'll demonstrate and say
2. **Clean your desktop** - Close unnecessary windows
3. **Test your screen recorder** - OBS Studio, QuickTime, or built-in tools
4. **Check audio** - Ensure microphone works clearly
5. **Have commands ready** - Copy/paste from this guide

### Recording Structure (20 minutes max)

**Intro (1 minute):**
- "Hello, I'm [name], and this is my IT 210 Final Project demonstration"
- "I've deployed a Linux file server for PromisedLand's Independence data center"
- "I'll demonstrate all 10 required configurations"

**Main Content (16-17 minutes):**
- Go through Tasks 1-10 systematically
- Show each command and its output clearly
- Explain what you're showing concisely
- Point out key features as you demonstrate

**Conclusion (1-2 minutes):**
- "I've successfully demonstrated all 10 required configurations"
- "The server is fully operational and ready for production use"
- "Thank you for watching"

### Recording Best Practices

1. **Speak clearly and at moderate pace**
2. **Zoom in on important terminal output** (Ctrl/Cmd + '+')
3. **Pause briefly between tasks** so viewers can process
4. **If you make a mistake**, just pause, wait 2 seconds, and restart that section (edit later)
5. **Highlight important output** with your cursor
6. **Keep terminal text large enough** to read (16-18pt font)

---

## PART G: TROUBLESHOOTING

### Issue: Can't connect to SSH

**Solution:**
```bash
# Check security group allows SSH from your IP
# Check instance is running
# Verify you're using correct IP address
# Verify key file permissions: chmod 400 key.pem
```

### Issue: Samba not accessible

**Solution:**
```bash
# Check if Samba is running
sudo systemctl status smbd

# Restart Samba
sudo systemctl restart smbd nmbd

# Check firewall
sudo ufw status

# Check from server itself
sudo smbclient -L localhost -N
```

### Issue: Permission denied errors

**Solution:**
```bash
# Make sure you're using sudo for administrative commands
# Check file ownership: ls -la /path/to/file
# Check your current user: whoami
```

### Issue: Script fails

**Solution:**
```bash
# Run script with bash -x to see where it fails
sudo bash -x ./deploy_server.sh

# Or run commands manually section by section
```

---

## PART H: POST-DEMONSTRATION CLEANUP

### If Using AWS Academy

**IMPORTANT:** AWS Academy labs typically run for 4 hours. After recording your video:

1. **Save your work** - Download any files you need
2. **Take screenshots** for documentation
3. **Stop your instance** when done to conserve credits
4. **Do NOT terminate** until project is graded
5. You can restart the instance later if needed to re-record

### Stopping Instance

```bash
# From EC2 Dashboard:
# 1. Select your instance
# 2. Click "Instance state" → "Stop instance"
# 3. Wait for state to change to "Stopped"
```

---

## PART I: QUICK REFERENCE - VIDEO CHECKLIST

Print this checklist and mark off each item as you demonstrate it:

- [ ] Task 1: Server Installation and Access (AWS Console + SSH)
- [ ] Task 2: File Server Role (Samba status and config)
- [ ] Task 3: File Permissions (ls -la, getfacl)
- [ ] Task 4: Firewall (ufw status verbose)
- [ ] Task 5: Storage Allocation (df -h, lsblk)
- [ ] Task 6: Security Measures (sudo -l, getfacl)
- [ ] Task 7: MOTD (cat /etc/update-motd.d/*)
- [ ] Task 8: Scheduled Reboot (crontab -l)
- [ ] Task 9: Updated Packages (apt update, apt list --upgradable)
- [ ] Task 10: Package Installation (mutt -v)

**Additional recommended demonstrations:**
- [ ] Show user list (cat /etc/passwd | grep /home)
- [ ] Show groups (getent group operations)
- [ ] Show Samba shares (smbclient -L localhost)
- [ ] Show network config (ip addr, hostname -I)

---

## PART J: SAMPLE NARRATION SCRIPT

Use this as a template for what to say during your video:

**"Hello, I'm [Your Name], and this is my IT 210 Final Project demonstration for PromisedLand's Linux file server deployment in Independence, Missouri."**

**Task 1:** "First, I'll show that the server is successfully installed and running on AWS EC2. [Show AWS Console]. Here we can see the instance is in a running state with a public IP address. Now I'll demonstrate SSH access. [Show terminal]. I'm connected as the ubuntu user to the Ubuntu Server 24.04 LTS instance."

**Task 2:** "Next, I'll demonstrate the file server role. [Run commands]. Samba is installed, configured, and running. I've set up shares for each department plus individual home directories."

**Task 3:** "For file permissions, [Run commands]. Each team directory has group-based permissions with the setgid bit. ACLs provide the CIO read-only access to all shared folders."

**Task 4:** "The UFW firewall is configured and active. [Run command]. It allows SSH for administration and Samba ports for file sharing, while denying all other incoming traffic."

**Task 5:** "For storage allocation, [Run commands]. The system has dedicated space for the OS, user home directories, shared files, and system logs."

**Task 6:** "Security measures include restricted sudo access. [Run commands]. Only Infrastructure Team administrators have sudo rights, and all commands are logged."

**Task 7:** "The Message of the Day provides security notices and system information. [Run command and show output]."

**Task 8:** "A cron job schedules an automatic reboot every two years. [Show crontab]. This ensures kernel updates are applied."

**Task 9:** "The system is configured for automatic security updates. [Show commands]. Package repositories are current and the system is up to date."

**Task 10:** "Finally, I've installed the mutt email client to demonstrate package management. [Show mutt version]."

**"This concludes my demonstration. All 10 required configurations have been successfully implemented. Thank you for watching."**

---

## Success! You're Ready to Record

Follow this guide step-by-step, and you'll have a complete, professional demonstration for your IT 210 Final Project. Good luck!
