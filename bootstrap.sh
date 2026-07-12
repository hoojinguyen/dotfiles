#!/bin/bash
# bootstrap.sh - Universal installer for the development environment

# Exit immediately if a command exits with a non-zero status
set -e

# Resolve script directory first
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd)

# Check if running standalone (e.g. via curl without a cloned repository)
if [ ! -d "./install" ] || [ ! -f "./install/symlinks.sh" ]; then
    echo "=================================================="
    echo "   Installer running in Remote/Standalone mode   "
    echo "=================================================="
    echo "Cloning the dotfiles repository to ~/dotfiles..."
    echo ""

    # Ensure git is installed
    if ! command -v git &> /dev/null; then
        if [ "$(uname -s)" = "Darwin" ]; then
            echo "Git is not installed. Installing Xcode Command Line Tools..."
            xcode-select --install
            echo "Please re-run this command once Xcode Command Line Tools are installed."
        else
            echo "Git is not installed. Attempting to install git..."
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y git
            else
                echo "Error: git is required. Please install git manually and re-run."
            fi
        fi
        
        if ! command -v git &> /dev/null; then
            exit 1
        fi
    fi

    # Clone or update the repository
    if [ ! -d "$HOME/dotfiles" ]; then
        git clone https://github.com/hoojinguyen/dotfiles.git "$HOME/dotfiles"
    else
        echo "Directory ~/dotfiles already exists. Pulling latest changes..."
        cd "$HOME/dotfiles"
        git pull
    fi

    # Execute the local bootstrapped script
    echo ""
    echo "Restarting installer from cloned repository..."
    exec bash "$HOME/dotfiles/bootstrap.sh" "$@"
fi

export DOTFILES="$DOTFILES_ROOT"

echo "=================================================="
echo "   Starting Universal Dotfiles Bootstrap Script   "
echo "=================================================="

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
