#!/bin/bash
# install/runtimes.sh - Installs runtime environments (ASDF, Bun, Rust, Global Packages)

echo "=================================================="
echo "Installing and configuring runtime environments..."
echo "=================================================="

# Helper to check if command exists
has_cmd() {
    command -v "$1" &> /dev/null
}

# Load selections if available
SELECTIONS_FILE="$HOME/.dotfiles_selections"
if [ -f "$SELECTIONS_FILE" ]; then
    source "$SELECTIONS_FILE"
fi

# Set defaults to true if not defined
INSTALL_ASDF="${INSTALL_ASDF:-true}"
INSTALL_BUN="${INSTALL_BUN:-true}"
INSTALL_RUST="${INSTALL_RUST:-true}"
INSTALL_NODE="${INSTALL_NODE:-true}"
INSTALL_RUBY="${INSTALL_RUBY:-true}"

# 1. ASDF (if git install needed on Linux and selected)
if [ "$INSTALL_ASDF" = "true" ]; then
    if [ ! -d "$HOME/.asdf" ] && ! has_cmd asdf; then
        echo "Cloning ASDF Git repository..."
        git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.0
    else
        if has_cmd asdf; then
            echo "Updating ASDF..."
            asdf update
        fi
    fi

    # Load ASDF for the current installer script
    if [ -f "$HOME/.asdf/asdf.sh" ]; then
        source "$HOME/.asdf/asdf.sh"
    elif command -v brew &> /dev/null && [ -f "$(brew --prefix asdf 2>/dev/null)/libexec/asdf.sh" ]; then
        source "$(brew --prefix asdf)/libexec/asdf.sh"
    fi

    # ASDF Plugins Setup
    if has_cmd asdf; then
        echo "ASDF detected. Ensuring standard plugins are added..."
        # Add plugins dynamically based on selections
        PLUGINS=""
        if [ "$INSTALL_NODE" = "true" ]; then PLUGINS="$PLUGINS nodejs"; fi
        if [ "$INSTALL_RUBY" = "true" ]; then PLUGINS="$PLUGINS ruby"; fi
        if [ "$INSTALL_BUN" = "true" ]; then PLUGINS="$PLUGINS bun"; fi
        # python is standard
        PLUGINS="$PLUGINS python"

        for plugin in $PLUGINS; do
            if ! asdf plugin list | grep -q "$plugin"; then
                echo "Adding ASDF plugin: $plugin"
                asdf plugin add "$plugin"
            fi
        done
    fi
fi

# 2. Bun
if [ "$INSTALL_BUN" = "true" ]; then
    if ! has_cmd bun; then
        echo "Installing Bun runtime..."
        curl -fsSL https://bun.sh/install | bash
    else
        echo "Upgrading Bun runtime to latest..."
        bun upgrade
    fi
fi

# 3. Rust (Rustup / Cargo)
if [ "$INSTALL_RUST" = "true" ]; then
    if ! has_cmd cargo && ! has_cmd rustup; then
        echo "Installing Rust via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    else
        if has_cmd rustup; then
            echo "Updating Rust via rustup..."
            rustup update
        fi
    fi
fi

# Source cargo for remaining steps in the current script
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 3b. NVM (Node Version Manager) & Node.js
if [ "$INSTALL_NODE" = "true" ]; then
    if [ ! -d "$HOME/.nvm" ]; then
        echo "Installing NVM (Node Version Manager)..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi

    # Load NVM for the current installer run
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if has_cmd nvm; then
        echo "Installing latest Node.js..."
        nvm install node
        nvm use node
        nvm alias default node
    fi

    # 3c. Yarn & pnpm (via Corepack or NPM global)
    if has_cmd corepack; then
        echo "Enabling corepack and preparing latest yarn and pnpm..."
        corepack enable
        corepack prepare yarn@latest pnpm@latest --activate
    elif has_cmd npm; then
        echo "Installing latest yarn and pnpm globally via npm..."
        npm install -g yarn@latest pnpm@latest
    fi
fi

# 3d. Ruby (via rbenv or ASDF)
if [ "$INSTALL_RUBY" = "true" ]; then
    if has_cmd rbenv; then
        eval "$(rbenv init -)"
        LATEST_RUBY=$(rbenv install -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
        if ! rbenv versions | grep -q "$LATEST_RUBY"; then
            echo "Installing latest Ruby version ($LATEST_RUBY) via rbenv (this might take a few minutes)..."
            rbenv install "$LATEST_RUBY"
            rbenv global "$LATEST_RUBY"
        else
            echo "Ruby $LATEST_RUBY is already installed via rbenv."
        fi
    elif has_cmd asdf; then
        if ! asdf list ruby 2>/dev/null | grep -q "latest"; then
            echo "Installing latest Ruby version via asdf (this might take a few minutes)..."
            asdf install ruby latest
            asdf global ruby latest
        else
            echo "Latest Ruby is already installed via asdf."
        fi
    fi
fi

# 5. Global NPM Packages (Only if Node/NPM is active and selected)
if [ "$INSTALL_NODE" = "true" ] && has_cmd npm; then
    echo "Installing global NPM packages..."
    npm install -g @shopify/cli vercel
fi

# 6. Bun Global Packages (Only if Bun is active and selected)
if [ "$INSTALL_BUN" = "true" ] && has_cmd bun; then
    echo "Installing global Bun packages..."
    # Ensure Bun is on path if just installed
    export PATH="$HOME/.bun/bin:$PATH"
    bun install -g clawhub
fi

echo "Runtimes setup complete!"
