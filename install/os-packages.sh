#!/bin/bash
# install/os-packages.sh - Installs system packages on macOS and Linux (Ubuntu/Debian)

OS="$(uname -s)"

# Load selections if available
SELECTIONS_FILE="$HOME/.dotfiles_selections"
if [ -f "$SELECTIONS_FILE" ]; then
    source "$SELECTIONS_FILE"
fi

# Set defaults to true if not defined
INSTALL_LAZYGIT="${INSTALL_LAZYGIT:-true}"
INSTALL_GH="${INSTALL_GH:-true}"
INSTALL_ASDF="${INSTALL_ASDF:-true}"
INSTALL_RBENV="${INSTALL_RBENV:-true}"
INSTALL_UV="${INSTALL_UV:-true}"
INSTALL_PIPX="${INSTALL_PIPX:-true}"
INSTALL_DOCKER="${INSTALL_DOCKER:-true}"

echo "=================================================="
echo "Installing system packages for OS: $OS..."
echo "=================================================="

# Function to check if command exists
has_cmd() {
    command -v "$1" &> /dev/null
}

if [ "$OS" = "Darwin" ]; then
    # macOS package installation via Homebrew
    if ! has_cmd brew; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for the current running shell
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    echo "Updating Homebrew..."
    brew update

    # Generate temporary Brewfile based on selections
    TEMP_BREWFILE=$(mktemp)
    cat <<EOT > "$TEMP_BREWFILE"
tap "homebrew/bundle"
brew "git"
brew "zsh"
brew "curl"
brew "coreutils"
brew "tmux"
brew "bat"
brew "eza"
brew "fzf"
brew "fd"
brew "git-delta"
brew "jq"
EOT

    if [ "$INSTALL_LAZYGIT" = "true" ]; then echo 'brew "lazygit"' >> "$TEMP_BREWFILE"; fi
    if [ "$INSTALL_GH" = "true" ]; then echo 'brew "gh"' >> "$TEMP_BREWFILE"; fi
    if [ "$INSTALL_UV" = "true" ]; then echo 'brew "uv"' >> "$TEMP_BREWFILE"; fi
    if [ "$INSTALL_PIPX" = "true" ]; then echo 'brew "pipx"' >> "$TEMP_BREWFILE"; fi
    if [ "$INSTALL_ASDF" = "true" ]; then echo 'brew "asdf"' >> "$TEMP_BREWFILE"; fi
    if [ "$INSTALL_RBENV" = "true" ]; then echo 'brew "rbenv"' >> "$TEMP_BREWFILE"; fi
    if [ "$INSTALL_DOCKER" = "true" ]; then echo 'cask "docker"' >> "$TEMP_BREWFILE"; fi

    echo "Installing Homebrew packages via generated Brewfile..."
    brew bundle --file="$TEMP_BREWFILE"
    rm "$TEMP_BREWFILE"

elif [ "$OS" = "Linux" ]; then
    # Linux package installation via apt-get (Ubuntu/Debian)
    if [ -f /etc/debian_version ]; then
        echo "Debian/Ubuntu detected."
        
        # Helper to prepend sudo if not root
        SUDO=""
        if [ "$EUID" -ne 0 ]; then
            if has_cmd sudo; then
                SUDO="sudo"
            else
                echo "WARNING: Not running as root and 'sudo' is not installed. Package installation might fail."
            fi
        fi

        echo "Updating apt repositories..."
        $SUDO apt-get update -y

        echo "Installing core utilities..."
        
        # Build apt package list dynamically based on selections
        APT_PKGS="git zsh curl build-essential tmux fzf jq bat eza git-delta fd-find"
        if [ "$INSTALL_LAZYGIT" = "true" ]; then APT_PKGS="$APT_PKGS lazygit"; fi
        if [ "$INSTALL_GH" = "true" ]; then APT_PKGS="$APT_PKGS gh"; fi
        if [ "$INSTALL_DOCKER" = "true" ]; then APT_PKGS="$APT_PKGS docker.io docker-buildx"; fi

        $SUDO apt-get install -y $APT_PKGS 2>/dev/null || {
            echo "Standard install command encountered errors. Trying fallback subset..."
            $SUDO apt-get install -y git zsh curl build-essential tmux fzf jq bat fd-find
        }

        # Create symlink for fd command (Debian/Ubuntu packages fd-find as fdfind)
        if has_cmd fdfind && ! has_cmd fd; then
            echo "Creating symlink for fd-find..."
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        fi

        # Install uv and pipx if selected and not installed via apt
        if [ "$INSTALL_UV" = "true" ] && ! has_cmd uv; then
            echo "Installing uv package manager..."
            curl -LsSf https://astral.sh/uv/install.sh | sh
        fi
        if [ "$INSTALL_PIPX" = "true" ] && ! has_cmd pipx; then
            echo "Installing pipx..."
            python3 -m pip install --user pipx 2>/dev/null || $SUDO apt-get install -y pipx
        fi
    else
        echo "Unsupported Linux distribution. Please install packages manually."
    fi
else
    echo "Unsupported OS: $OS"
fi

echo "Package installation complete!"
