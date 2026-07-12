# aliases.zsh - Cross-platform shell shortcuts

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias cdf="cd $DOTFILES"
alias n="cd"
alias b="cd .."

# LS Configuration (Eza -> Colorls -> Standard LS)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias l='eza -l --icons --group-directories-first'
elif command -v colorls &> /dev/null; then
    alias ls='colorls --group-directories-first'
    alias ll='colorls -lA --sd --group-directories-first'
    alias la='colorls -A --group-directories-first'
    alias l='colorls -l --group-directories-first'
else
    if [ "$(uname)" = "Darwin" ]; then
        alias ls="ls -G"
        alias ll="ls -alF"
        alias la="ls -A"
        alias l="ls -CF"
    else
        alias ls="ls --color=auto"
        alias ll="ls -alF --color=auto"
        alias la="ls -A --color=auto"
        alias l="ls -CF --color=auto"
    fi
fi

alias tree='tree --gitignore'

# Git
alias g="git"
alias gcl="git clone"
alias gf="git fetch"
alias gs="git status"
alias gpl="git pull"
alias gl="git pull"
alias gps="git push"
alias gp="git push"
alias gpsf="git push --force-with-lease"
alias gpsup="git push --set-upstream origin \$(git symbolic-ref --short -q HEAD)"
alias gri="git rebase -i"
alias gcm="git commit -m"
alias gcme="git commit --allow-empty -m"
alias gca="git commit --amend"
alias gcan!="git commit -v -a --no-edit --amend"
alias gck="git checkout"
alias gco="git checkout"
alias gckn="git checkout -b"
alias gckb="git checkout -b"
alias gcb="git checkout -b"
alias gsw="git switch"
alias gswc="git switch -c"
alias gb="git branch"
alias gd="git diff"
alias gdc="git diff --cached"
alias grs="git restore"
alias grss="git restore --staged"
alias glg="git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"
alias gaa="git add ."
alias gst="git stash"
alias gstp="git stash pop"
alias gclean="git clean -fd"
alias gpristine="git reset --hard && git clean -ffdx"
alias lg="lazygit"

# Docker
alias d="docker"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dim="docker images"
alias dima="docker images -a"
alias dl="docker logs"
alias dlf="docker logs -f"
alias dst="docker stop"
alias drmc="docker rm"
alias drmi="docker rmi"

# Docker Compose
alias dc="docker compose"
alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
alias dcr="docker compose restart"
alias dcl="docker compose logs"
alias dclf="docker compose logs -f"
alias dce="docker compose exec"
alias dcb="docker compose build"

# Helpers & Systems
alias c="clear"
alias cl="clear"
alias cla="clear -a"
alias sz="source ~/.zshrc && echo \"Sourced.\""
alias reload="source ~/.zshrc && echo \"Zsh configuration reloaded.\""
alias myip="curl -s https://icanhazip.com"
alias grep="grep --color=auto"
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias h="history"
alias hg="history | grep"
alias h1="history | tail -10"
alias h2="history | tail -20"
alias h5="history | tail -50"
alias path='echo -e ${PATH//:/\\n}'
alias ez="open ~/.zshrc"
alias es="open ~/.secrets"
alias q="exit"

# Project directory quick-jumps (if directory exists)
if [ -d "$HOME/Hooji/My-Projects" ]; then
    alias cdp="cd $HOME/Hooji/My-Projects"
    alias cdpr="cd $HOME/Hooji/My-Projects"
fi

# Neovim & Vim
alias v="nvim ."
alias vc="nvim"
alias zz="zellij"
alias lv="lvim"
alias lvo="lvim ."

# Node / NPM / Yarn / PNPM
alias ni="npm install"
alias ns="npm start"
alias nt="npm test"
alias y="yarn install"
alias yi="yarn install"
alias yinocypress="CYPRESS_INSTALL_BINARY=0 yarn install"
alias ys="yarn start"
alias yd="yarn dev"
alias ydb="yarn debug"
alias ytwnc="yarn test --watch --no-coverage"
alias ytwc="yarn test --watch --coverage"
alias yt="yarn test"
alias yts="yarn test -u"
alias ysnt="yarn start-metro-bundle"
alias yl="yarn list"
alias yw="yarn why"
alias ytd="yarn test:debug"

alias pn="pnpm"
alias pni="pnpm install"
alias pna="pnpm add"
alias pnad="pnpm add -D"
alias pnd="pnpm dev"
alias pns="pnpm start"
alias pnt="pnpm test"
alias pnx="pnpm dlx"

# Python
alias py="python3"
alias ipy="ipython"
alias venv="python3 -m venv .venv && source .venv/bin/activate"

# AI tools
alias ca="claude"
alias 9r="9router"
alias ol="ollama"
