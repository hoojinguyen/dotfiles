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
