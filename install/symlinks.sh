#!/bin/bash
# install/symlinks.sh - Cross-platform configuration symlinker

# Ensure DOTFILES_ROOT is set
DOTFILES_ROOT="${DOTFILES:-$HOME/.dotfiles}"

echo "=================================================="
echo "Creating symlinks to $HOME..."
echo "=================================================="

# Function to safely create symlink with backups
link_file() {
    local src="$1"
    local dst="$2"
    local filename=$(basename "$dst")
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dst")"
    
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ -L "$dst" ]; then
            # Current file is already a symlink, overwrite it
            echo "Updating symlink: $dst -> $src"
            ln -sf "$src" "$dst"
        else
            # Current file is a regular file/directory, back it up
            local backup="$dst.bak_$(date +%Y%m%d_%H%M%S)"
            echo "WARNING: Regular file exists at $dst. Backing up to $backup"
            mv "$dst" "$backup"
            echo "Linking: $dst -> $src"
            ln -sf "$src" "$dst"
        fi
    else
        echo "Creating new symlink: $dst -> $src"
        ln -sf "$src" "$dst"
    fi
}

# Zsh Configurations
link_file "$DOTFILES_ROOT/configs/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_ROOT/configs/zsh/.zshenv" "$HOME/.zshenv"

# Git Configurations
link_file "$DOTFILES_ROOT/configs/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_ROOT/configs/git/.gitignore_global" "$HOME/.gitignore_global"

# NPM Configurations
link_file "$DOTFILES_ROOT/configs/npm/.npmrc" "$HOME/.npmrc"
link_file "$DOTFILES_ROOT/configs/npm/.yarnrc" "$HOME/.yarnrc"

# Pip Configurations
link_file "$DOTFILES_ROOT/configs/pip/pip.conf" "$HOME/.pip/pip.conf"

# Tmux Configuration
link_file "$DOTFILES_ROOT/configs/tmux/.tmux.conf" "$HOME/.tmux.conf"

# SSH Configuration (with multiplexing socket folder setup)
mkdir -p "$HOME/.ssh/sockets"
link_file "$DOTFILES_ROOT/configs/ssh/config" "$HOME/.ssh/config"

# Vim Configuration
link_file "$DOTFILES_ROOT/configs/vim/.vimrc" "$HOME/.vimrc"

# CLI Script Configuration
link_file "$DOTFILES_ROOT/scripts/dotfiles" "$HOME/bin/dotfiles"


# Copy secrets template if ~/.secrets doesn't exist
if [ ! -f "$HOME/.secrets" ]; then
    echo "Creating ~/.secrets from template..."
    cp "$DOTFILES_ROOT/templates/.secrets.example" "$HOME/.secrets"
    echo "--------------------------------------------------"
    echo "IMPORTANT: ~/.secrets has been created."
    echo "Please open it and add your API keys/personal tokens!"
    echo "--------------------------------------------------"
fi

echo "Symlinking complete!"
