# aliases-macos.zsh - macOS specific shortcuts & integrations
# This file is only sourced on Darwin systems.

# Applications
alias cors='open -n -a /Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser --args --user-data-dir="/tmp/brave_dev_sess_1" --disable-web-security'
alias nosleep="caffeinate -d -t 99999"

# Antigravity integrations
function ag() {
  open -a "/Applications/Antigravity IDE.app" .
}

# Quick opens using Finder or default macOS handler
alias oz="open ~/.zshrc"
alias oc="open ~/.config"
alias or="open ~"

# macOS clipboard integrations (pbcopy/pbpaste)
alias cpp="pwd | pbcopy"
alias gbc="git branch --show-current | tr -d '\n' | pbcopy"

# Copy file content to clipboard
function cpc() {
    if [[ -f $1 ]]; then
        cat "$1" | pbcopy
        echo "Content of $1 copied to clipboard."
    else
        echo "File not found: $1"
    fi
}

# SSH/Clipboard utilities
alias copypubkey="cat ~/.ssh/id_*.pub 2>/dev/null | head -n 1 | pbcopy && echo 'First SSH public key copied to clipboard.'"

# System & Networking
alias dnsflush="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder && echo 'macOS DNS cache flushed.'"

# Finder & Desktop utilities
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias cleanup_ds="find . -type f -name '.DS_Store' -ls -delete && echo '.DS_Store files cleaned.'"

# Power management
alias lockdisplay="pmset displaysleepnow"
