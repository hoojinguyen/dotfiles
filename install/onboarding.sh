#!/bin/bash
# install/onboarding.sh - Interactive onboarding wizard for universal dotfiles

# Source paths
DOTFILES_ROOT="${DOTFILES:-$HOME/.dotfiles}"
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

# Version detectors
get_asdf_ver() {
    if has_cmd asdf; then
        echo -n " (Detected: v$(asdf --version | awk '{print $1}'))"
    elif [ -d "$HOME/.asdf" ]; then
        echo -n " (Detected in ~/.asdf)"
    fi
}
get_rbenv_ver() {
    if has_cmd rbenv; then
        echo -n " (Detected: v$(rbenv --version | awk '{print $2}'))"
    fi
}
get_uv_ver() {
    if has_cmd uv; then
        echo -n " (Detected: v$(uv --version | awk '{print $2}'))"
    fi
}
get_pipx_ver() {
    if has_cmd pipx; then
        echo -n " (Detected: v$(pipx --version))"
    fi
}
get_node_ver() {
    if has_cmd node; then
        echo -n " (Detected: $(node --version))"
    fi
}
get_bun_ver() {
    if has_cmd bun; then
        echo -n " (Detected: v$(bun --version))"
    fi
}
get_rust_ver() {
    if has_cmd rustc; then
        echo -n " (Detected: $(rustc --version | awk '{print $2}'))"
    fi
}
get_ruby_ver() {
    if has_cmd ruby; then
        echo -n " (Detected: v$(ruby --version | awk '{print $2}'))"
    fi
}
get_docker_ver() {
    if has_cmd docker; then
        echo -n " (Detected: v$(docker --version | awk '{print $3}' | tr -d ','))"
    fi
}
get_lazygit_ver() {
    if has_cmd lazygit; then
        echo -n " (Detected)"
    fi
}
get_gh_ver() {
    if has_cmd gh; then
        echo -n " (Detected: v$(gh --version | head -n1 | awk '{print $3}'))"
    fi
}

# Helper to prompt for a tool's installation/update
prompt_tool() {
    local tool_name="$1"
    local var_name="$2"
    local ver_info="$3"
    
    if [ -n "$ver_info" ]; then
        if ask_yes_no "$tool_name$ver_info is already installed. Do you want to check/update it to the latest version?" "n"; then
            eval "$var_name=true"
        else
            eval "$var_name=false"
        fi
    else
        if ask_yes_no "Install $tool_name?" "y"; then
            eval "$var_name=true"
        else
            eval "$var_name=false"
        fi
    fi
}

# Check non-interactive terminal
if [ ! -t 0 ]; then
    echo "Non-interactive terminal detected. Skipping onboarding prompts and using defaults."
    if [ ! -f "$SELECTIONS_FILE" ]; then
        # Default guard in non-interactive shell: skip already installed tools
        INSTALL_LAZYGIT_VAL=true; if has_cmd lazygit; then INSTALL_LAZYGIT_VAL=false; fi
        INSTALL_GH_VAL=true; if has_cmd gh; then INSTALL_GH_VAL=false; fi
        INSTALL_ASDF_VAL=true; if has_cmd asdf || [ -d "$HOME/.asdf" ]; then INSTALL_ASDF_VAL=false; fi
        INSTALL_RBENV_VAL=true; if has_cmd rbenv; then INSTALL_RBENV_VAL=false; fi
        INSTALL_UV_VAL=true; if has_cmd uv; then INSTALL_UV_VAL=false; fi
        INSTALL_PIPX_VAL=true; if has_cmd pipx; then INSTALL_PIPX_VAL=false; fi
        INSTALL_NODE_VAL=true; if has_cmd node; then INSTALL_NODE_VAL=false; fi
        INSTALL_BUN_VAL=true; if has_cmd bun; then INSTALL_BUN_VAL=false; fi
        INSTALL_RUST_VAL=true; if has_cmd rustc; then INSTALL_RUST_VAL=false; fi
        INSTALL_RUBY_VAL=true; if has_cmd ruby; then INSTALL_RUBY_VAL=false; fi
        INSTALL_DOCKER_VAL=true; if has_cmd docker; then INSTALL_DOCKER_VAL=false; fi
        
        cat <<EOT > "$SELECTIONS_FILE"
INSTALL_LAZYGIT=$INSTALL_LAZYGIT_VAL
INSTALL_GH=$INSTALL_GH_VAL
INSTALL_ASDF=$INSTALL_ASDF_VAL
INSTALL_RBENV=$INSTALL_RBENV_VAL
INSTALL_UV=$INSTALL_UV_VAL
INSTALL_PIPX=$INSTALL_PIPX_VAL
INSTALL_NODE=$INSTALL_NODE_VAL
INSTALL_BUN=$INSTALL_BUN_VAL
INSTALL_RUST=$INSTALL_RUST_VAL
INSTALL_RUBY=$INSTALL_RUBY_VAL
INSTALL_DOCKER=$INSTALL_DOCKER_VAL
EOT
    fi
    exit 0
fi

# Load existing selections if available
if [ -f "$SELECTIONS_FILE" ]; then
    source "$SELECTIONS_FILE"
    echo -e "${YELLOW}Loaded previous selections from $SELECTIONS_FILE${NC}"
fi

# 1. Tool Customization Wizard
echo -e "${BOLD}--- 1. Customize Tool & Runtime Installation ---${NC}"
if ask_yes_no "Would you like to customize which optional tools/runtimes to install?" "n"; then
    
    prompt_tool "Lazygit" "INSTALL_LAZYGIT" "$(get_lazygit_ver)"
    prompt_tool "GitHub CLI" "INSTALL_GH" "$(get_gh_ver)"
    
    # Version managers are often tied, but we can check them individually
    asdf_installed="$(get_asdf_ver)"
    rbenv_installed="$(get_rbenv_ver)"
    if [ -n "$asdf_installed" ] || [ -n "$rbenv_installed" ]; then
        if ask_yes_no "Version Managers (ASDF/rbenv)$asdf_installed$rbenv_installed are already installed. Update them?" "n"; then
            INSTALL_ASDF=true
            INSTALL_RBENV=true
        else
            INSTALL_ASDF=false
            INSTALL_RBENV=false
        fi
    else
        if ask_yes_no "Install Version Managers (ASDF, rbenv)?" "y"; then
            INSTALL_ASDF=true
            INSTALL_RBENV=true
        else
            INSTALL_ASDF=false
            INSTALL_RBENV=false
        fi
    fi

    # Python package tools
    uv_installed="$(get_uv_ver)"
    pipx_installed="$(get_pipx_ver)"
    if [ -n "$uv_installed" ] || [ -n "$pipx_installed" ]; then
        if ask_yes_no "Python tools (uv/pipx)$uv_installed$pipx_installed are already installed. Update them?" "n"; then
            INSTALL_UV=true
            INSTALL_PIPX=true
        else
            INSTALL_UV=false
            INSTALL_PIPX=false
        fi
    else
        if ask_yes_no "Install Python tools (uv, pipx)?" "y"; then
            INSTALL_UV=true
            INSTALL_PIPX=true
        else
            INSTALL_UV=false
            INSTALL_PIPX=false
        fi
    fi

    prompt_tool "Node.js (NVM, NPM, Yarn, pnpm)" "INSTALL_NODE" "$(get_node_ver)"
    prompt_tool "Bun JavaScript/TypeScript runtime" "INSTALL_BUN" "$(get_bun_ver)"
    prompt_tool "Rust & Cargo" "INSTALL_RUST" "$(get_rust_ver)"
    prompt_tool "Ruby environment" "INSTALL_RUBY" "$(get_ruby_ver)"
    prompt_tool "Docker" "INSTALL_DOCKER" "$(get_docker_ver)"
else
    echo -e "${YELLOW}Running in default mode. Checking system for already installed tools...${NC}"
    # Guard: default to skipping already installed, installing missing
    INSTALL_LAZYGIT=true; if has_cmd lazygit; then INSTALL_LAZYGIT=false; fi
    INSTALL_GH=true; if has_cmd gh; then INSTALL_GH=false; fi
    INSTALL_ASDF=true; if has_cmd asdf || [ -d "$HOME/.asdf" ]; then INSTALL_ASDF=false; fi
    INSTALL_RBENV=true; if has_cmd rbenv; then INSTALL_RBENV=false; fi
    INSTALL_UV=true; if has_cmd uv; then INSTALL_UV=false; fi
    INSTALL_PIPX=true; if has_cmd pipx; then INSTALL_PIPX=false; fi
    INSTALL_NODE=true; if has_cmd node; then INSTALL_NODE=false; fi
    INSTALL_BUN=true; if has_cmd bun; then INSTALL_BUN=false; fi
    INSTALL_RUST=true; if has_cmd rustc; then INSTALL_RUST=false; fi
    INSTALL_RUBY=true; if has_cmd ruby; then INSTALL_RUBY=false; fi
    INSTALL_DOCKER=true; if has_cmd docker; then INSTALL_DOCKER=false; fi
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
