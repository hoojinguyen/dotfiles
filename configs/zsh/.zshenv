# .zshenv - Environment variables for ZSH

# Set the path to the dotfiles directory (dynamically resolved if symlinked)
if [ -L "$HOME/.zshenv" ]; then
    export DOTFILES=$(dirname $(dirname $(dirname $(readlink "$HOME/.zshenv"))))
fi

# Fallback to ~/.dotfiles if dynamic resolution fails or resolves to a non-existent directory
if [ -z "$DOTFILES" ] || [ ! -d "$DOTFILES" ]; then
    export DOTFILES="$HOME/.dotfiles"
fi

# Set the default editor (fallback to nano on headless systems)
if command -v code &> /dev/null; then
    export EDITOR='code --wait'
    export VISUAL='code --wait'
else
    export EDITOR='nano'
    export VISUAL='nano'
fi

# Ensure the PATH is set correctly (supporting macOS homebrew and local binaries)
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"

# ZSH specific variables
export ZSH_CACHE_DIR="$HOME/.cache/zsh"
mkdir -p "$ZSH_CACHE_DIR"
