# .zshrc - Main shell configuration file

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(
  git
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  colored-man-pages
  history
  npm
  yarn
  docker
)

# Source Oh My Zsh (if installed)
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Load modular configs
if [ -d "$DOTFILES/configs/zsh" ]; then
  source "$DOTFILES/configs/zsh/config.zsh"
  source "$DOTFILES/configs/zsh/aliases.zsh"
  source "$DOTFILES/configs/zsh/functions.zsh"

  # Source macOS-specific aliases if running on macOS
  if [ "$(uname)" = "Darwin" ] && [ -f "$DOTFILES/configs/zsh/aliases-macos.zsh" ]; then
    source "$DOTFILES/configs/zsh/aliases-macos.zsh"
  fi
fi

# Load local/private secrets
if [ -f "$HOME/.secrets" ]; then
  source "$HOME/.secrets"
fi

# ==============================================================================
# Version Managers & Runtimes Configuration (VM & Cross-Platform Safe)
# ==============================================================================

# 1. Bun runtime
export BUN_INSTALL="$HOME/.bun"
if [ -d "$BUN_INSTALL" ]; then
  export PATH="$BUN_INSTALL/bin:$PATH"
  [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
fi

# 2. Cargo / Rust
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# 3. ASDF version manager (Git-installed vs Homebrew-installed)
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  source "$HOME/.asdf/asdf.sh"
elif command -v brew &> /dev/null && [ -f "$(brew --prefix asdf 2>/dev/null)/libexec/asdf.sh" ]; then
  source "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# 4. Rbenv (Ruby)
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init -)"
fi

# 5. Pipx (Python CLI applications)
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# 6. NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# 7. Go Environment
if command -v go &> /dev/null; then
  export GOPATH="$(go env GOPATH 2>/dev/null || echo "$HOME/go")"
  export PATH="$PATH:$GOPATH/bin"
fi

# 8. FZF Integrations (Keybindings & Fuzzy Completion)
if command -v fzf &> /dev/null; then
  if [ -d "/opt/homebrew/opt/fzf/shell" ]; then
    source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" 2>/dev/null
    source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2>/dev/null
  elif [ -f "/usr/share/doc/fzf/examples/key-bindings.zsh" ]; then
    source "/usr/share/doc/fzf/examples/key-bindings.zsh" 2>/dev/null
    source "/usr/share/doc/fzf/examples/completion.zsh" 2>/dev/null
  fi
fi

# 9. Modern Shell Enhancements (Zoxide & Direnv hooks if installed)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# 10. Local machine overrides (not tracked in Git)
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi



# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
