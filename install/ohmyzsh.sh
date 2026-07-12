#!/bin/bash
# install/ohmyzsh.sh - Install Oh My Zsh and plugins

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "=================================================="
echo "Configuring Oh My Zsh and plugins..."
echo "=================================================="

# Function to clone plugin if it doesn't exist
install_plugin() {
    local repo=$1
    local name=$2
    if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
        echo "Installing Oh My Zsh plugin: $name..."
        git clone --depth 1 "$repo" "$ZSH_CUSTOM/plugins/$name"
    else
        echo "Plugin $name already installed."
    fi
}

# Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh (unattended)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install custom plugins
install_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting"
install_plugin "https://github.com/zsh-users/zsh-completions" "zsh-completions"

# Install Pure theme (sindresorhus/pure)
if [ ! -d "$ZSH_CUSTOM/themes/pure" ]; then
    echo "Installing Pure theme..."
    mkdir -p "$ZSH_CUSTOM/themes/pure"
    git clone --depth 1 https://github.com/sindresorhus/pure.git "$ZSH_CUSTOM/themes/pure"
    # Create symlink for Oh My Zsh to pick it up
    ln -sf "$ZSH_CUSTOM/themes/pure/pure.zsh" "$ZSH_CUSTOM/themes/pure.zsh-theme"
fi

echo "Oh My Zsh configurations setup successfully!"
