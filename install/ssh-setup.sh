#!/bin/bash
# install/ssh-setup.sh - Automates SSH key generation, registering, and clipboard copying

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUB_KEY="${SSH_KEY}.pub"

echo "=================================================="
echo "Setting up SSH Keys..."
echo "=================================================="

# Function to copy public key to clipboard
copy_key_to_clipboard() {
    if [ -f "$SSH_PUB_KEY" ]; then
        if command -v pbcopy &> /dev/null; then
            cat "$SSH_PUB_KEY" | pbcopy
            echo "Public key copied to macOS clipboard."
        elif command -v wl-copy &> /dev/null; then
            cat "$SSH_PUB_KEY" | wl-copy
            echo "Public key copied to Wayland clipboard."
        elif command -v xclip &> /dev/null; then
            cat "$SSH_PUB_KEY" | xclip -selection clipboard
            echo "Public key copied to X11 clipboard."
        else
            echo "Could not copy automatically. Please copy the key below:"
            cat "$SSH_PUB_KEY"
        fi
    fi
}

if [ -f "$SSH_KEY" ]; then
    echo "SSH key already exists at $SSH_KEY."
    copy_key_to_clipboard
else
    # Check if we are running in an interactive terminal
    if [ ! -t 0 ]; then
        echo "Non-interactive terminal detected. Skipping SSH key setup."
        exit 0
    fi

    read -r -p "No SSH key found at $SSH_KEY. Generate one now? [y/N]: " gen_key
    if [[ "$gen_key" =~ ^[Yy]$ ]]; then
        # Default email from gitconfig if available
        DEFAULT_EMAIL=$(git config --global user.email 2>/dev/null || echo "vanhoinguyen98@gmail.com")
        read -r -p "Enter email comment for SSH key [$DEFAULT_EMAIL]: " email
        email="${email:-$DEFAULT_EMAIL}"

        echo "Generating Ed25519 SSH key..."
        mkdir -p "$HOME/.ssh"
        ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""

        echo "Starting SSH Agent and registering key..."
        eval "$(ssh-agent -s)"
        
        # Configure SSH Agent persistence on macOS
        if [ "$(uname)" = "Darwin" ]; then
            # Add to ~/.ssh/config if not already there
            if [ -f "$HOME/.ssh/config" ] && ! grep -q "UseKeychain" "$HOME/.ssh/config"; then
                echo "Adding UseKeychain configuration to ~/.ssh/config..."
                cat <<EOT >> "$HOME/.ssh/config"

# macOS Keychain integration
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOT
            fi
            ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || ssh-add "$SSH_KEY"
        else
            ssh-add "$SSH_KEY"
        fi

        copy_key_to_clipboard

        # Auto GitHub Upload if 'gh' CLI is active and authenticated
        if command -v gh &> /dev/null && gh auth status &>/dev/null; then
            read -r -p "Detected GitHub CLI (gh) is authenticated. Upload this SSH key to GitHub? [y/N]: " upload_gh
            if [[ "$upload_gh" =~ ^[Yy]$ ]]; then
                key_title="Dotfiles Key ($(hostname) - $(date +%Y-%m-%d))"
                gh ssh-key add "$SSH_PUB_KEY" --title "$key_title" && echo "SSH key successfully added to GitHub!"
            fi
        fi
    else
        echo "SSH key generation skipped."
    fi
fi
