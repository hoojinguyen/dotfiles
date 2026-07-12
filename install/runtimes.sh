#!/bin/bash
# install/runtimes.sh - Installs runtime environments (ASDF, Bun, Rust, Global Packages)

echo "=================================================="
echo "Installing and configuring runtime environments..."
echo "=================================================="

# Helper to check if command exists
has_cmd() {
    command -v "$1" &> /dev/null
}

# 1. ASDF (if git install needed on Linux)
if [ ! -d "$HOME/.asdf" ] && ! has_cmd asdf; then
    echo "Cloning ASDF Git repository..."
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.0
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
    for plugin in nodejs python ruby bun; do
        if ! asdf plugin list | grep -q "$plugin"; then
            echo "Adding ASDF plugin: $plugin"
            asdf plugin add "$plugin"
        fi
    done
fi

# 2. Bun
if ! has_cmd bun; then
    echo "Installing Bun runtime..."
    curl -fsSL https://bun.sh/install | bash
fi

# 3. Rust (Rustup / Cargo)
if ! has_cmd cargo && ! has_cmd rustup; then
    echo "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# Source cargo for remaining steps in the current script
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 3b. NVM (Node Version Manager) & Node.js
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

# 3d. Ruby (via rbenv or ASDF)
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

# 5. Global NPM Packages (Only if Node/NPM is active)
if has_cmd npm; then
    echo "Installing global NPM packages..."
    npm install -g @shopify/cli vercel
fi

# 6. Bun Global Packages
if has_cmd bun; then
    echo "Installing global Bun packages..."
    bun install -g clawhub
fi

echo "Runtimes setup complete!"
