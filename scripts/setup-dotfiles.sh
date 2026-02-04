#!/bin/bash

# Dotfiles setup script for EnigmaNebula Linux system

set -e

echo "Setting up dotfiles..."

# Define source and destination directories
DOTFILES_SRC="./dotfiles"
HOME_DIR="$HOME"

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Function to backup and link a file
backup_and_link() {
    local src="$1"
    local dest="$2"
    local filename=$(basename "$dest")

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing $filename to $BACKUP_DIR/"
        mv "$dest" "$BACKUP_DIR/"
    fi

    echo "Linking $filename"
    ln -sf "$src" "$dest"
}

# Link bash configuration
backup_and_link "$DOTFILES_SRC/.bashrc" "$HOME_DIR/.bashrc"
backup_and_link "$DOTFILES_SRC/.bash_profile" "$HOME_DIR/.bash_profile"

# Link vim configuration
backup_and_link "$DOTFILES_SRC/.vimrc" "$HOME_DIR/.vimrc"

# Link git configuration
backup_and_link "$DOTFILES_SRC/.gitconfig" "$HOME_DIR/.gitconfig"

# Link tmux configuration
backup_and_link "$DOTFILES_SRC/.tmux.conf" "$HOME_DIR/.tmux.conf"

# Link SSH configuration
mkdir -p "$HOME_DIR/.ssh"
backup_and_link "$DOTFILES_SRC/.ssh/config" "$HOME_DIR/.ssh/config"

# Make scripts executable
chmod +x ./scripts/*.sh

echo "Dotfiles setup complete!"
echo "Backups saved to: $BACKUP_DIR"