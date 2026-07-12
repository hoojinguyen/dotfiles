#!/bin/bash
# sync.sh - Synchronize dotfiles repository

echo "=================================================="
echo "Synchronizing dotfiles repository..."
echo "=================================================="

# Ensure we're in the dotfiles directory
cd "$(dirname "$0")"

# Check if it is a git repository
if [ ! -d .git ]; then
    echo "Error: Not a git repository. Skipping synchronization."
    exit 1
fi

# Pull latest changes
echo "Pulling latest changes..."
git pull origin main || echo "Warning: git pull failed. Continuing..."

# Check for local changes
if [[ -n $(git status -s) ]]; then
    echo "Local changes detected. Staging, committing, and pushing..."
    git add .
    git commit -m "Auto-update dotfiles ($(date +'%Y-%m-%d %H:%M:%S'))"
    git push origin main || echo "Warning: git push failed. Check your network or credentials."
else
    echo "No local changes to commit."
fi

echo "Synchronization complete!"
