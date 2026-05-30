#!/bin/bash
# UFW Firewall Rules — PromisedLand File Server
# Author: Ashu Betrand

echo "Configuring UFW firewall..."

# Reset to defaults
ufw --force reset

# Default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH — admin access only
ufw allow 22/tcp comment 'SSH admin access'

# Allow Samba — internal file sharing
ufw allow 445/tcp comment 'Samba SMB file sharing'
ufw allow 139/tcp comment 'Samba NetBIOS'

# Enable firewall
ufw --force enable

echo "Firewall configured."
ufw status verbose
