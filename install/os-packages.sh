#!/bin/bash
# install/os-packages.sh - Installs system packages on macOS and Linux (Ubuntu/Debian)

OS="$(uname -s)"

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

    # List of formulae to install
    echo "Installing Brew formulae..."
    brew install git zsh curl bat eza fzf gh jq lazygit uv pipx asdf rbenv coreutils tmux

    # Install Docker Desktop (Cask) on macOS
    if ! has_cmd docker; then
        echo "Installing Docker Desktop..."
        brew install --cask docker
    fi

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
        $SUDO apt-get install -y git zsh curl build-essential tmux fzf jq bat eza lazygit python3-pip python3-venv docker.io docker-buildx 2>/dev/null || {
            echo "Standard install command encountered errors. Trying fallback subset..."
            $SUDO apt-get install -y git zsh curl build-essential tmux fzf jq bat 
        }

        # Install uv and pipx if not installed via apt
        if ! has_cmd uv; then
            echo "Installing uv package manager..."
            curl -LsSf https://astral.sh/uv/install.sh | sh
        fi
        if ! has_cmd pipx; then
            echo "Installing pipx..."
            python3 -m pip install --user pipx 2>/dev/null || apt-get install -y pipx
        fi
    else
        echo "Unsupported Linux distribution. Please install packages manually."
    fi
else
    echo "Unsupported OS: $OS"
fi

echo "Package installation complete!"
