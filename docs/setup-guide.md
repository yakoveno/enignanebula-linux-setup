# EnigmaNebula Linux Setup Guide

This document provides a comprehensive guide for setting up the EnigmaNebula Linux system.

## Prerequisites

- Ubuntu Server 20.04 LTS or later
- At least 8GB RAM (16GB recommended)
- 50GB+ disk space for OS and applications
- Internet connection
- SSH access

## Installation Steps

### Method 1: Fresh Installation

1. Download Ubuntu Server ISO and create bootable USB
2. Boot the target machine from the USB
3. Install Ubuntu Server with default settings
4. After installation, log in and run:

```bash
git clone git@github.com:YOURUSERNAME/enignanebula-linux-setup.git
cd enignanebula-linux-setup
chmod +x setup.sh
./setup.sh
```

### Method 2: Manual Setup

If you prefer to set up components manually:

1. Install base packages:
```bash
sudo apt update && sudo apt install -y curl git vim docker.io docker-compose ansible python3
```

2. Enable Docker:
```bash
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

3. Run individual Ansible playbooks:
```bash
cd ansible/playbooks
ansible-playbook -i ../inventory/local base-system.yml
ansible-playbook -i ../inventory/local docker-setup.yml
ansible-playbook -i ../inventory/local openclaw-install.yml
```

4. Set up services:
```bash
cd ../..
./scripts/setup-dotfiles.sh
docker-compose -f services/docker-compose.yml up -d
```

## Post-Installation

After installation completes:

1. The system will automatically start EnigmaNebula
2. OpenClaw gateway will be accessible at `http://localhost:18789`
3. Check service status with `docker ps | grep enignanebula`
4. View logs with `docker logs enignanebula-openclaw`

## Security Configuration

The setup includes:

- UFW firewall with SSH, HTTP, HTTPS, and OpenClaw ports open
- Fail2Ban for intrusion prevention
- SSH key-based authentication
- Regular security updates (configure as needed)

## Updating the System

To update the system:

1. Pull the latest changes:
```bash
cd enignanebula-linux-setup
git pull origin main
```

2. Re-run the setup script:
```bash
./setup.sh
```

## Troubleshooting

### OpenClaw Service Not Starting

1. Check logs:
```bash
docker logs enignanebula-openclaw
```

2. Verify configuration:
```bash
ls -la ~/.openclaw/
cat ~/.openclaw/openclaw.json
```

### Docker Issues

1. Check Docker status:
```bash
sudo systemctl status docker
```

2. Check container status:
```bash
docker ps -a
```

### SSH Connection Problems

1. Verify SSH key is added to GitHub
2. Test connection:
```bash
ssh -T git@github.com
```

## Migration from Existing System

To migrate from an existing OpenClaw installation:

1. Back up your current workspace:
```bash
tar -czf openclaw-backup.tar.gz ~/.openclaw/workspace
```

2. Copy the backup to the new system:
```bash
scp openclaw-backup.tar.gz user@new-system:/tmp/
```

3. Restore on the new system:
```bash
cd ~
tar -xzf /tmp/openclaw-backup.tar.gz
```

## Maintenance Tasks

### Regular Maintenance

1. Update the system weekly:
```bash
sudo apt update && sudo apt upgrade -y
```

2. Clean Docker resources monthly:
```bash
docker system prune -a
```

3. Rotate logs:
```bash
sudo journalctl --vacuum-time=30d
```

### Backup Strategy

The system automatically backs up critical configurations to:
- `/home/enignanebula/.openclaw/workspace/` - Main workspace
- `/home/enignanebula/.openclaw/openclaw.json` - Configuration

Set up regular backups of these directories to a secure location.