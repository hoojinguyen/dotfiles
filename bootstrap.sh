#!/bin/bash
# bootstrap.sh - Universal installer for the development environment

# Exit immediately if a command exits with a non-zero status
set -e

echo "=================================================="
echo "   Starting Universal Dotfiles Bootstrap Script   "
echo "=================================================="

# Ensure we're in the dotfiles directory
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd)
export DOTFILES="$DOTFILES_ROOT"

# Ensure all scripts are executable
chmod +x install/*.sh scripts/* sync.sh

# 1. Symlink configs to home directory
echo ""
echo "--> 1. Running symlinks setup..."
bash ./install/symlinks.sh

# 1b. Run interactive onboarding wizard
echo ""
echo "--> 1b. Running interactive onboarding wizard..."
bash ./install/onboarding.sh

# 2. Install OS packages
echo ""
echo "--> 2. Running OS packages installer..."
bash ./install/os-packages.sh

# 3. Setup Oh My Zsh and Plugins
echo ""
echo "--> 3. Installing Oh My Zsh..."
bash ./install/ohmyzsh.sh

# 4. Install tool runtimes
echo ""
echo "--> 4. Setting up language/runtime environments..."
bash ./install/runtimes.sh

# 5. Finalize path settings
export PATH="$HOME/bin:$PATH"

echo ""
echo "=================================================="
echo "Universal Dotfiles Bootstrap Complete!"
echo "--------------------------------------------------"
echo "Next Steps:"
echo "1. Source or restart your terminal: source ~/.zshrc"
echo "2. Edit ~/.secrets to fill in your API keys."
echo "3. Run 'dotfiles help' to see management commands."
echo "=================================================="
