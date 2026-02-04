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

# Start services
echo "Starting EnigmaNebula services..."
docker-compose -f services/docker-compose.yml up -d

echo "==========================================="
echo "Setup complete!"
echo "EnigmaNebula is now running on this system."
echo "==========================================="