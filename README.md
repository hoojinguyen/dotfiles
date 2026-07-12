# Universal Modular Dotfiles

A highly portable, secure, and modular development environment configuration designed to work out-of-the-box on both personal macOS workstations and headless Linux VM servers.

## Features

- **Multi-OS Support**: Automatic detection and installation of packages on both **macOS** (via Homebrew) and **Linux/Ubuntu/Debian** (via apt).
- **Safe Secrets Management**: Automatically separates private API keys/tokens into `~/.secrets` to prevent committing them to Git.
- **Zero-Dependency Linking**: The symlink bootstrapper has zero external dependencies, meaning you can configure your environment first, even on clean installations.
- **Modular Shell Architecture**:
  - `config.zsh`: Core settings (history, completion matching, globbing).
  - `aliases.zsh`: Portable commands (git, docker, navigation, Neovim).
  - `aliases-macos.zsh`: macOS specific bindings (clipboard integrations, app launchers).
  - `functions.zsh`: Ported functions (`kp` kill port, `cpfile` cross-platform clipboard copy, folder copying, base64 encoding/decoding).
- **Tmux Integration**: Configured for seamless persistence on remote SSH/VM sessions with scrollback, mouse support, and Vim keybindings.
- **Runtime and Version Managers**: Auto-configures ASDF plugins, Bun, Cargo (Rust), Pipx (Python CLI apps), and global packages.

---

## Directory Structure

```
dotfiles/
├── bootstrap.sh              # Main installer (OS detection, package install, symlinks)
├── sync.sh                   # Auto git pull/commit/push sync script
├── install/                  # Installation modules
│   ├── os-packages.sh        # Installs packages (brew for macOS, apt for Linux)
│   ├── runtimes.sh           # Installs Bun, Rustup, ASDF, Pipx, NVM/fnm, Node
│   ├── symlinks.sh           # Symlinking script (with backups)
│   └── ohmyzsh.sh            # Oh My Zsh and plugins (syntax, autosuggestions)
├── configs/                  # Configurations to be symlinked
│   ├── zsh/                  # Modular Zsh files (.zshrc, .zshenv, aliases, functions)
│   ├── git/                  # Git configs (.gitconfig, .gitignore_global)
│   ├── npm/                  # NPM and Yarn settings
│   ├── tmux/                 # Tmux settings (.tmux.conf)
│   └── pip/                  # Pip settings (pip.conf)
├── scripts/                  # User scripts
│   └── dotfiles              # CLI management script
└── templates/
    └── .secrets.example      # Template for API keys (e.g. GEMINI_API_KEY, GITHUB_TOKEN)
```

---

## Getting Started

### Quick Install (One-liner)
You can clone the repository, pull updates, and launch the interactive setup with a single command:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hoojinguyen/dotfiles/main/bootstrap.sh)"
```

### Next Steps

#### 1. Reload your Shell
After bootstrapping completes:
```bash
source ~/.zshrc
```

#### 2. Configure local secrets
Open `~/.secrets` in your editor to check or fill in your API keys (like `GEMINI_API_KEY`, `GITHUB_PERSONAL_ACCESS_TOKEN`):
```bash
nano ~/.secrets
```

---

## CLI Management (`dotfiles`)

This repository includes a `dotfiles` CLI wrapper linked to `~/bin/dotfiles`. You can run it from anywhere in your shell:

- `dotfiles sync`: Pull latest changes and push local additions.
- `dotfiles status`: Run `git status` inside your dotfiles repository.
- `dotfiles edit`: Open the dotfiles directory in your default editor.
- `dotfiles bootstrap`: Run the setup bootstrapper again.
- `dotfiles help`: Show the help guide.

---

## Uninstalling

If you need to remove the symlinks and restore your original configuration files, you can run the uninstaller script:
```bash
./uninstall.sh
```
This will:
- Safely remove all generated symlinks in your home directory.
- Revert and restore your original configuration files from their latest backups (`*.bak_*`).
- Clean up empty installation folders (like `~/bin` or `~/.pip` if empty).
