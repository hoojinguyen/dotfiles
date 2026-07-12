# .zshenv - Environment variables for ZSH

# Set the path to the dotfiles directory
export DOTFILES="$HOME/.dotfiles"

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
