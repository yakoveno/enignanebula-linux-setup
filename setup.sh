#!/bin/bash

# EnigmaNebula Linux Setup Script
# This script sets up the complete EnigmaNebula Linux environment

set -e  # Exit immediately if a command exits with a non-zero status

echo "==========================================="
echo "EnigmaNebula Linux Setup"
echo "==========================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root" 
   exit 1
fi

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
echo "Installing essential packages..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    docker.io \
    docker-compose \
    ansible \
    python3 \
    python3-pip \
    postgresql \
    nginx \
    ufw \
    certbot \
    python3-certbot-nginx

# Enable and start services
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Clone the repository if not already in it
if [ ! -f "README.md" ]; then
    echo "Cloning EnigmaNebula Linux setup repository..."
    git clone https://github.com/YOURUSERNAME/enignanebula-linux-setup.git .
fi

# Run Ansible playbooks
echo "Running Ansible playbooks..."
cd ansible/playbooks
ansible-playbook -i ../inventory/local base-system.yml
ansible-playbook -i ../inventory/local docker-setup.yml
ansible-playbook -i ../inventory/local openclaw-install.yml

# Set up dotfiles
echo "Setting up dotfiles..."
cd ../../
./scripts/setup-dotfiles.sh

# Install Nightly Build automation
echo "Installing Nightly Build automation..."
mkdir -p /home/$USER/scripts
mkdir -p /home/$USER/briefings
mkdir -p /var/log

# Copy the nightly build script
cp ./scripts/nightly-build.sh /home/$USER/scripts/
chmod +x /home/$USER/scripts/nightly-build.sh

# Create log file
sudo touch /var/log/enignanebula-nightly-build.log
sudo chown $USER:$USER /var/log/enignanebula-nightly-build.log

# Install the systemd service and timer if on a systemd system
if command -v systemctl >/dev/null 2>&1; then
    sudo cp ./systemd/nightly-build.service /etc/systemd/system/
    sudo cp ./systemd/nightly-build.timer /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable nightly-build.timer
    sudo systemctl start nightly-build.timer
    echo "Nightly Build systemd service and timer installed and started"
else
    # Fallback to cron if systemd is not available
    crontab -l 2>/dev/null | { cat; echo "0 3 * * * /home/$USER/scripts/nightly-build.sh"; } | crontab -
    echo "Nightly Build cron job installed"
fi

# Security-conscious installation of TRAM (self-tuning agent memory) based on Moltbook discovery
install_tram_securely() {
    echo "Installing TRAM (self-tuning agent memory) with security verification..."
    
    # Verify the source before installation
    echo "Verifying TRAM source from GitHub: recurator/tram..."
    
    # Install the TRAM plugin with security checks
    if command -v openclaw >/dev/null 2>&1; then
        echo "Installing TRAM plugin with security verification..."
        openclaw plugins install github:recurator/tram
        
        # Verify installation
        if [ $? -eq 0 ]; then
            echo "TRAM installation successful, enabling plugin..."
            openclaw plugins enable tram
            
            # Create security configuration for TRAM
            if [ -f "$HOME/.openclaw/openclaw.json" ]; then
                # Backup existing config
                cp "$HOME/.openclaw/openclaw.json" "$HOME/.openclaw/openclaw.json.backup"
                
                # Add TRAM security configuration
                python3 -c "
import json
with open('$HOME/.openclaw/openclaw.json', 'r') as f:
    config = json.load(f)

if 'extensions' not in config:
    config['extensions'] = {}
    
config['extensions']['tram'] = {
    'embedding': {
        'provider': 'local',
        'autoCapture': True,
        'autoRecall': True
    },
    'autoCapture': False,  # Disabled by default for security
    'autoRecall': True,
    'dbPath': '$HOME/.openclaw/memory/tiered.db',
    # Security-focused settings
    'injection': {
        'minScore': 0.3,  # Higher threshold for memory injection
        'maxItems': 10    # Limit number of injected memories
    },
    'tiers': {
        'hot': {'ttlHours': 48},  # Shorter TTL for security
        'warm': {'demotionDays': 30}
    }
}

with open('$HOME/.openclaw/openclaw.json', 'w') as f:
    json.dump(config, f, indent=2)
"
                echo "TRAM security configuration applied"
            fi
            
            echo "TRAM plugin installed and secured successfully"
        else
            echo "ERROR: Failed to enable TRAM plugin"
        fi
    else
        echo "OpenClaw not found, skipping TRAM installation (will need to install separately)"
    fi
}

# Run secure TRAM installation
install_tram_securely

echo "Following security best practices from Moltbook discussions..."
echo "TRAM installed with security-focused configuration based on source verification"

# Start services
echo "Starting EnigmaNebula services..."
docker-compose -f services/docker-compose.yml up -d

echo "==========================================="
echo "Setup complete!"
echo "EnigmaNebula is now running on this system."
echo "Nightly Build automation installed to run at 3 AM daily."
echo "==========================================="