#!/bin/bash
# install/onboarding.sh - Interactive onboarding wizard for universal dotfiles

# Source paths
DOTFILES_ROOT="${DOTFILES:-$HOME/dotfiles}"
SELECTIONS_FILE="$HOME/.dotfiles_selections"
GIT_LOCAL_CONFIG="$HOME/.gitconfig.local"
SECRETS_FILE="$HOME/.secrets"

# Colors for rich output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print banner
echo -e "${MAGENTA}==================================================${NC}"
echo -e "${MAGENTA}${BOLD}     🚀 Welcome to Universal Dotfiles Onboarding 🚀 ${NC}"
echo -e "${MAGENTA}==================================================${NC}"
echo "This wizard will help you customize your environment."
echo ""

# Helper to check if command exists
has_cmd() {
    command -v "$1" &> /dev/null
}

# Helper for Yes/No prompts
ask_yes_no() {
    local prompt="$1"
    local default="$2" # y or n
    local reply
    while true; do
        if [ "$default" = "y" ]; then
            read -r -p "$(echo -e "${CYAN}${prompt} [Y/n]: ${NC}")" reply
        else
            read -r -p "$(echo -e "${CYAN}${prompt} [y/N]: ${NC}")" reply
        fi
        
        reply=$(echo "$reply" | tr '[:upper:]' '[:lower:]')
        if [ -z "$reply" ]; then
            reply="$default"
        fi
        
        if [ "$reply" = "y" ] || [ "$reply" = "yes" ]; then
            return 0
        elif [ "$reply" = "n" ] || [ "$reply" = "no" ]; then
            return 1
        fi
        echo -e "${RED}Invalid input. Please enter 'y' or 'n'.${NC}"
    done
}

# Check non-interactive terminal
if [ ! -t 0 ]; then
    echo "Non-interactive terminal detected. Skipping onboarding prompts and using defaults."
    if [ ! -f "$SELECTIONS_FILE" ]; then
        cat <<EOT > "$SELECTIONS_FILE"
INSTALL_LAZYGIT=true
INSTALL_GH=true
INSTALL_ASDF=true
INSTALL_RBENV=true
INSTALL_UV=true
INSTALL_PIPX=true
INSTALL_NODE=true
INSTALL_BUN=true
INSTALL_RUST=true
INSTALL_RUBY=true
INSTALL_DOCKER=true
EOT
    fi
    exit 0
fi

# Load existing selections if available
if [ -f "$SELECTIONS_FILE" ]; then
    source "$SELECTIONS_FILE"
    echo -e "${YELLOW}Loaded previous selections from $SELECTIONS_FILE${NC}"
fi

# Default values if not already set
INSTALL_LAZYGIT="${INSTALL_LAZYGIT:-true}"
INSTALL_GH="${INSTALL_GH:-true}"
INSTALL_ASDF="${INSTALL_ASDF:-true}"
INSTALL_RBENV="${INSTALL_RBENV:-true}"
INSTALL_UV="${INSTALL_UV:-true}"
INSTALL_PIPX="${INSTALL_PIPX:-true}"
INSTALL_NODE="${INSTALL_NODE:-true}"
INSTALL_BUN="${INSTALL_BUN:-true}"
INSTALL_RUST="${INSTALL_RUST:-true}"
INSTALL_RUBY="${INSTALL_RUBY:-true}"
INSTALL_DOCKER="${INSTALL_DOCKER:-true}"

# 1. Tool Customization Wizard
echo -e "${BOLD}--- 1. Customize Tool & Runtime Installation ---${NC}"
if ask_yes_no "Would you like to customize which optional tools/runtimes to install?" "n"; then
    
    if ask_yes_no "Install Git CLI enhancements (lazygit, GitHub CLI)?" "$( [ "$INSTALL_LAZYGIT" = "true" ] && echo "y" || echo "n" )"; then
        INSTALL_LAZYGIT=true
        INSTALL_GH=true
    else
        INSTALL_LAZYGIT=false
        INSTALL_GH=false
    fi

    if ask_yes_no "Install Version Managers (asdf, rbenv)?" "$( [ "$INSTALL_ASDF" = "true" ] && echo "y" || echo "n" )"; then
        INSTALL_ASDF=true
        INSTALL_RBENV=true
    else
        INSTALL_ASDF=false
        INSTALL_RBENV=false
    fi

    if ask_yes_no "Install Python tools (uv, pipx)?" "$( [ "$INSTALL_UV" = "true" ] && echo "y" || echo "n" )"; then
        INSTALL_UV=true
        INSTALL_PIPX=true
    else
        INSTALL_UV=false
        INSTALL_PIPX=false
    fi

    if ask_yes_no "Install Node.js environment (NVM, Node, Yarn, pnpm)?" "$( [ "$INSTALL_NODE" = "true" ] && echo "y" || echo "n" )"; then
        INSTALL_NODE=true
    else
        INSTALL_NODE=false
    fi

    if ask_yes_no "Install Bun JavaScript/TypeScript runtime?" "$( [ "$INSTALL_BUN" = "true" ] && echo "y" || echo "n" )"; then
        INSTALL_BUN=true
    else
        INSTALL_BUN=false
    fi

    if ask_yes_no "Install Rust & Cargo?" "$( [ "$INSTALL_RUST" = "true" ] && echo "y" || echo "n" )"; then
        INSTALL_RUST=true
    else
        INSTALL_RUST=false
    fi

    if ask_yes_no "Install Ruby?" "$( [ "$INSTALL_RUBY" = "true" ] && echo "y" || echo "n" )"; then
        INSTALL_RUBY=true
    else
        INSTALL_RUBY=false
    fi

    if ask_yes_no "Install Docker?" "$( [ "$INSTALL_DOCKER" = "true" ] && echo "y" || echo "n" )"; then
        INSTALL_DOCKER=true
    else
        INSTALL_DOCKER=false
    fi
else
    echo "Installing all default tools and runtimes."
fi

# Write selections to state file
cat <<EOT > "$SELECTIONS_FILE"
INSTALL_LAZYGIT=$INSTALL_LAZYGIT
INSTALL_GH=$INSTALL_GH
INSTALL_ASDF=$INSTALL_ASDF
INSTALL_RBENV=$INSTALL_RBENV
INSTALL_UV=$INSTALL_UV
INSTALL_PIPX=$INSTALL_PIPX
INSTALL_NODE=$INSTALL_NODE
INSTALL_BUN=$INSTALL_BUN
INSTALL_RUST=$INSTALL_RUST
INSTALL_RUBY=$INSTALL_RUBY
INSTALL_DOCKER=$INSTALL_DOCKER
EOT

echo -e "${GREEN}✓ Installation selections saved to $SELECTIONS_FILE${NC}"
echo ""

# 2. Git Configuration Setup
echo -e "${BOLD}--- 2. Configure Local Git Settings ---${NC}"
if ask_yes_no "Would you like to configure your local Git identity now?" "y"; then
    # Fetch current values if ~/.gitconfig.local already exists
    CURRENT_NAME=""
    CURRENT_EMAIL=""
    CURRENT_EDITOR=""
    if [ -f "$GIT_LOCAL_CONFIG" ]; then
        CURRENT_NAME=$(git config --file "$GIT_LOCAL_CONFIG" user.name 2>/dev/null || echo "")
        CURRENT_EMAIL=$(git config --file "$GIT_LOCAL_CONFIG" user.email 2>/dev/null || echo "")
        CURRENT_EDITOR=$(git config --file "$GIT_LOCAL_CONFIG" core.editor 2>/dev/null || echo "")
    fi
    
    # Defaults fallback if empty
    CURRENT_NAME="${CURRENT_NAME:-$(git config --global user.name 2>/dev/null || echo "")}"
    CURRENT_EMAIL="${CURRENT_EMAIL:-$(git config --global user.email 2>/dev/null || echo "")}"
    CURRENT_EDITOR="${CURRENT_EDITOR:-$(git config --global core.editor 2>/dev/null || echo 'open -a "/Applications/Antigravity.app" --wait')}"

    read -r -p "$(echo -e "${CYAN}Enter your Git name [$CURRENT_NAME]: ${NC}")" git_name
    git_name="${git_name:-$CURRENT_NAME}"

    read -r -p "$(echo -e "${CYAN}Enter your Git email [$CURRENT_EMAIL]: ${NC}")" git_email
    git_email="${git_email:-$CURRENT_EMAIL}"

    read -r -p "$(echo -e "${CYAN}Enter your preferred editor [$CURRENT_EDITOR]: ${NC}")" git_editor
    git_editor="${git_editor:-$CURRENT_EDITOR}"

    # Write to ~/.gitconfig.local
    if [ -n "$git_name" ]; then
        git config --file "$GIT_LOCAL_CONFIG" user.name "$git_name"
    fi
    if [ -n "$git_email" ]; then
        git config --file "$GIT_LOCAL_CONFIG" user.email "$git_email"
    fi
    if [ -n "$git_editor" ]; then
        git config --file "$GIT_LOCAL_CONFIG" core.editor "$git_editor"
    fi
    
    echo -e "${GREEN}✓ Local Git configuration saved to $GIT_LOCAL_CONFIG${NC}"
else
    echo "Skipping Git configuration."
fi
echo ""

# 3. Local Secrets / Environment Variables Setup
echo -e "${BOLD}--- 3. Configure Local API Keys / Environment Secrets ---${NC}"
if ask_yes_no "Would you like to configure environment secrets (API keys for Gemini, Github, etc.)?" "y"; then
    bash "$DOTFILES_ROOT/install/secrets-setup.sh"
else
    echo "Skipping environment secrets configuration."
fi
echo ""

# 4. SSH Key Configuration
echo -e "${BOLD}--- 4. Configure SSH Keys ---${NC}"
if ask_yes_no "Would you like to set up / verify your SSH keys?" "y"; then
    bash "$DOTFILES_ROOT/install/ssh-setup.sh"
else
    echo "Skipping SSH key configuration."
fi
echo ""

echo -e "${GREEN}${BOLD}🎉 Onboarding configuration completed successfully! 🎉${NC}"
echo -e "${MAGENTA}==================================================${NC}"
echo ""
