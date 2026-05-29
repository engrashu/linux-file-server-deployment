# linux-file-server-deployment
Enterprise Ubuntu Server deployment on AWS EC2 with Samba, UFW, ACLs, and automation
# 🐧 Linux File Server Deployment — PromisedLand Data Center

> **Enterprise-grade Ubuntu Server deployment on AWS EC2 with Samba, UFW firewall, ACL-based permissions, and automated maintenance.**

[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/ec2/)
[![Samba](https://img.shields.io/badge/Samba-File_Server-003399?style=for-the-badge&logo=samba&logoColor=white)](https://www.samba.org/)
[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

## 📋 Project Overview

This project is a full Linux system administration deployment for **PromisedLand.com's** new data center in **Independence, Missouri**. It demonstrates real-world enterprise IT skills including:

- Provisioning a Linux server on AWS EC2
- Configuring a Samba (SMB/CIFS) file server for 38 users across 4 departments
- Implementing group-based access control using Unix permissions and ACLs
- Hardening the server with UFW firewall rules
- Automating security updates and system maintenance via cron

This was built as a **Final Project for IT 210 (Linux System Administration)** and serves as a practical demonstration of core Linux skills applicable to DevOps, Cloud, and SysAdmin roles.

---

## 🏗️ Architecture

```
AWS EC2 (Ubuntu 24.04 LTS)
│
├── /                  → 50 GB  (OS, applications)
├── /home              → 100 GB (38 user home directories)
├── /shared            → 200 GB (departmental shares)
│   ├── /operations    → Operations Team (read/write)
│   ├── /applications  → Applications Team (read/write)
│   ├── /infrastructure→ Infrastructure Team (read/write)
│   └── /crm           → CRM Team (read/write)
└── /var               → 30 GB  (logs, temp files)

CIO (cshumaker) → Read-only ACL access to ALL /shared/* directories
```

---

## 👥 Organizational Structure

The user/group design mirrors the real PromisedLand IT org chart:

| Team | Manager | Members | Linux Group |
|---|---|---|---|
| Operations | Richard Durant | 13 staff | `operations` |
| Applications | Brian LaGoe | 7 staff | `applications` |
| Infrastructure | Joseph Lubomirski | 9 staff | `infrastructure` |
| CRM | Cole Motley | 4 staff | `crm` |
| Admins | (Infrastructure Systems) | 5 staff | `sudo` |

---

## 🚀 Features Implemented

| # | Feature | Technology Used |
|---|---|---|
| 1 | Cloud server provisioning | AWS EC2, Ubuntu 24.04 LTS |
| 2 | Centralized file sharing | Samba 4.x (SMB/CIFS protocol) |
| 3 | Group-based file permissions | Unix chmod, chown, setgid bit |
| 4 | CIO executive read-only access | POSIX ACLs (`setfacl`) |
| 5 | Network firewall | UFW (ports 22, 139, 445) |
| 6 | Storage partitioning | EBS volumes, ext4 filesystem |
| 7 | Least-privilege sudo access | `/etc/sudoers`, sudo group |
| 8 | SSH hardening | Key-based auth, root login disabled |
| 9 | Automated security updates | `unattended-upgrades` |
| 10 | System maintenance automation | `cron` (scheduled reboot) |
| 11 | Login security banner | Custom MOTD scripts |
| 12 | Package management | apt, mutt installation |

---

## 📂 Repository Structure

```
linux-file-server-deployment/
│
├── README.md                        ← You are here
├── deploy_server.sh                 ← Full automated deployment script
├── docs/
│   ├── Linux_Deployment_Proposal.pdf    ← Full written proposal
│   ├── AWS_Implementation_Guide.md      ← Step-by-step AWS setup guide
│   └── Quick_Reference_Commands.md      ← Demo command cheat sheet
├── config/
│   ├── smb.conf                     ← Samba configuration file
│   ├── ufw-rules.sh                 ← Firewall rules setup
│   ├── motd-header                  ← Custom Message of the Day
│   └── crontab-root                 ← Scheduled maintenance cron job
└── screenshots/
    ├── aws-ec2-instance.png
    ├── samba-shares.png
    ├── acl-permissions.png
    ├── ufw-status.png
    └── crontab.png
```

---

## ⚡ Quick Start

### Prerequisites
- AWS Account (or AWS Academy access)
- SSH key pair (`.pem` file)
- Ubuntu Server 24.04 LTS EC2 instance running

### 1. Clone this repository
```bash
git clone https://github.com/engrashu/linux-file-server-deployment.git
cd linux-file-server-deployment
```

### 2. SSH into your EC2 instance
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

### 3. Upload and run the deployment script
```bash
# On your local machine, upload the script:
scp -i your-key.pem deploy_server.sh ubuntu@YOUR_EC2_PUBLIC_IP:~/

# On the server:
chmod +x deploy_server.sh
sudo ./deploy_server.sh
```

That's it! The script sets up everything in one run (~5-10 minutes).

---

## 🔧 Key Configuration Details

### Samba Share (smb.conf excerpt)
```ini
[operations]
   comment = Operations Team Shared Files
   path = /shared/operations
   valid users = @operations, cshumaker
   write list = @operations
   create mask = 0660
   directory mask = 2770
   force group = operations
```

### ACL — CIO Read-Only Access
```bash
# Grant read-only access to all shared directories
setfacl -m u:cshumaker:r-x /shared/operations
setfacl -m u:cshumaker:r-x /shared/applications
setfacl -m u:cshumaker:r-x /shared/infrastructure
setfacl -m u:cshumaker:r-x /shared/crm

# Apply to all future files created inside those directories
setfacl -m d:u:cshumaker:r-x /shared/operations
```

### UFW Firewall Rules
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH (admin access)
sudo ufw allow 445/tcp   # Samba SMB
sudo ufw allow 139/tcp   # Samba NetBIOS
sudo ufw enable
```

### Automated Reboot (Cron)
```bash
# Reboot every 2 years — January 1st at 2:00 AM
0 2 1 1 * /sbin/shutdown -r +5 'System rebooting for scheduled maintenance'
```

### Verify Deployment
```bash
# Check Samba is running
sudo systemctl status smbd

# Verify firewall is active
sudo ufw status verbose

# Verify ACLs
getfacl /shared/operations

# Check scheduled reboot
sudo crontab -l

# Check auto-updates config
cat /etc/apt/apt.conf.d/20auto-upgrades
```

---

## 🔒 Security Highlights

- **Firewall:** UFW blocks all traffic by default; only SSH and Samba ports are open
- **SSH:** Password authentication disabled; key-based only; root login disabled
- **Sudo:** Restricted to 5 Infrastructure Team admins — no other user has elevated access
- **ACLs:** CIO has read-only visibility across all departments without write risk
- **SetGID:** Group ownership inherited on all new files in shared directories
- **Updates:** Security patches applied automatically via `unattended-upgrades`
- **Logging:** All sudo commands logged to `/var/log/auth.log`

---

## 📄 Documentation

| Document | Description |
|---|---|
| [Written Proposal](docs/Linux_Deployment_Proposal.pdf) | Full formal deployment proposal submitted for IT 210 |
| [AWS Implementation Guide](docs/AWS_Implementation_Guide.md) | Step-by-step EC2 setup and SSH connection guide |
| [Quick Reference](docs/Quick_Reference_Commands.md) | Copy-paste commands for all 10 demonstration tasks |

---

## 🛠️ Technologies Used

- **OS:** Ubuntu Server 24.04 LTS
- **Cloud:** Amazon Web Services (EC2, EBS, Elastic IP)
- **File Server:** Samba 4.x (SMB/CIFS)
- **Firewall:** UFW (Uncomplicated Firewall)
- **Access Control:** POSIX ACLs (`setfacl`, `getfacl`)
- **Automation:** Bash scripting, Cron, unattended-upgrades
- **SSH Hardening:** OpenSSH with key-based authentication

---

## 📸 Screenshots

> *(Add screenshots from your video demonstration here)*

| AWS EC2 Instance | Samba Shares | ACL Permissions |
|---|---|---|
| ![EC2](screenshots/aws-ec2-instance.png) | ![Samba](screenshots/samba-shares.png) | ![ACL](screenshots/acl-permissions.png) |

---

## 👤 Author

**Ashu Betrand**
- GitHub: [@engrashu](https://github.com/engrashu)
- LinkedIn: [linkedin.com/in/bashu24](https://www.linkedin.com/in/bashu24)
- Location: Douala, Cameroon

---

## 📃 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

*Built as part of IT 210 — Linux System Administration coursework, demonstrating real-world enterprise Linux deployment skills.*
