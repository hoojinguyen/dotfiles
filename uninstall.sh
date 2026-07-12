#!/bin/bash
# uninstall.sh - Remove symlinks and restore backups of original configurations

echo "=================================================="
echo "      Removing Dotfiles Symlinks & Restoring      "
echo "=================================================="

# List of symlinks that were managed by the installer
FILES_TO_UNLINK=(
    "$HOME/.zshrc"
    "$HOME/.zshenv"
    "$HOME/.gitconfig"
    "$HOME/.gitignore_global"
    "$HOME/.npmrc"
    "$HOME/.yarnrc"
    "$HOME/.pip/pip.conf"
    "$HOME/.tmux.conf"
    "$HOME/.ssh/config"
    "$HOME/.vimrc"
    "$HOME/bin/dotfiles"
)

# Function to safely unlink and restore backup if it exists
unlink_file() {
    local target="$1"
    
    if [ -L "$target" ]; then
        echo "Removing symlink: $target"
        rm "$target"
        
        # Look for backups of this file (e.g. filename.bak_YYYYMMDD_HHMMSS)
        # Using a pattern match to find backups
        local backups=($(ls -d "${target}.bak_"* 2>/dev/null | sort -r))
        
        if [ ${#backups[@]} -gt 0 ]; then
            local latest_backup="${backups[0]}"
            echo "Restoring latest backup: $latest_backup -> $target"
            mv "$latest_backup" "$target"
            
            # Print info about other remaining backups if any
            if [ ${#backups[@]} -gt 1 ]; then
                echo "Note: Older backups still remain:"
                for ((i=1; i<${#backups[@]}; i++)); do
                    echo "  - ${backups[i]}"
                done
            fi
        else
            echo "No backup found for $target."
        fi
    elif [ -e "$target" ]; then
        echo "Skipping: $target is a regular file/directory (not a symlink)."
    else
        echo "Skipping: $target does not exist."
    fi
    echo "--------------------------------------------------"
}

for file in "${FILES_TO_UNLINK[@]}"; do
    unlink_file "$file"
done

# Clean up empty directories if left behind
if [ -d "$HOME/.pip" ] && [ -z "$(ls -A "$HOME/.pip" 2>/dev/null)" ]; then
    echo "Removing empty directory: ~/.pip"
    rmdir "$HOME/.pip"
fi

if [ -d "$HOME/bin" ] && [ -z "$(ls -A "$HOME/bin" 2>/dev/null)" ]; then
    echo "Removing empty directory: ~/bin"
    rmdir "$HOME/bin"
fi

echo ""
echo "Unlinking complete! Please restart your terminal or source your shell configuration."
echo "=================================================="
