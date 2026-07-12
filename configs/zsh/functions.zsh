# functions.zsh - Custom cross-platform shell functions

# Create a new directory and enter it
mkd() {
  mkdir -p "$@" && cd "$@"
}

# Find file with pattern
ff() {
  find . -type f -iname "*$1*"
}

# Find directory with pattern
fd() {
  find . -type d -iname "*$1*"
}

# Extract any archive
extract() {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"      ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Kill processes running on specified ports
# Usage: kp 3000 8080
kp() {
    if [ $# -eq 0 ]; then
        echo "Usage: kp <port1> [port2] [port3] ..."
        return 1
    fi

    for port in "$@"
    do
        if ! [[ "$port" =~ ^[0-9]+$ ]]; then
            echo "Error: '$port' is not a valid port number."
            continue
        fi

        pid=$(lsof -ti :"$port")
        if [ -z "$pid" ]; then
            echo "No process found running on port $port"
        else
            echo "Killing process $pid running on port $port"
            kill -9 $pid
        fi
    done
}

# Show what's listening on ports
ports() {
  lsof -i -P -n | grep LISTEN
}

# Get size of file or directory
getsize() {
  du -sh "$@"
}

# Quick backup of a file
backup() {
  cp "$1" "${1}.bak_$(date +%Y%m%d_%H%M%S)"
}

# Encodes and decodes base64 strings (cross-platform compatible)
encode() {
  echo -n "$1" | base64
}

decode() {
  if [ "$(uname)" = "Darwin" ]; then
    echo -n "$1" | base64 -D
  else
    echo -n "$1" | base64 -d
  fi
}

# Pretty print JSON using Python
json() {
  python3 -m json.tool "$@"
}

# Cross-platform file content copier to clipboard
cpfile() {
  if [ ! -f "$1" ]; then
    echo "File not found: $1"
    return 1
  fi
  if command -v pbcopy &> /dev/null; then
    cat "$1" | pbcopy
    echo "Content of $1 copied to macOS clipboard."
  elif command -v wl-copy &> /dev/null; then
    cat "$1" | wl-copy
    echo "Content of $1 copied to Wayland clipboard."
  elif command -v xclip &> /dev/null; then
    cat "$1" | xclip -selection clipboard
    echo "Content of $1 copied to X11 clipboard."
  else
    echo "No clipboard command available (pbcopy, wl-copy, xclip)."
  fi
}

# Copy folder recursively
cpff() {
  local source_dir="$1"
  local dest_dir="$2"

  if [[ -d "$source_dir" ]]; then
    cp -r "$source_dir" "$dest_dir"
    echo "Folder copied from $source_dir to $dest_dir"
  else
    echo "Source directory does not exist: $source_dir"
  fi
}

# Remove all nested folders matching name
# Usage: rmf node_modules -r (recursively)
#        rmf build (only in current folder)
rmf() {
  local folder_name="$1"
  local flag="$2"

  if [[ "$flag" == "-r" ]]; then
    find . -name "$folder_name" -type d -prune -print -exec rm -rf '{}' \;
  else
    find . -maxdepth 1 -name "$folder_name" -type d -print -exec rm -rf '{}' \;
  fi
}

# Search for text in files
search() {
  grep -rn "$1" "${2:-.}"
}

# Show all custom functions
funcs() {
  grep "^[a-zA-Z0-9_-]*()" "$DOTFILES/configs/zsh/functions.zsh"
}

# Query cheat.sh command sheets
cheat() {
  echo "Usage: cheat <command>"
  curl -s "https://cheat.sh/$1"
}

# ==============================================================================
# Interactive Shell Utilities (fzf-powered)
# ==============================================================================

# Project Jumper: Scan and jump to projects in Hooji folder
pj() {
  local search_dirs=()
  [ -d "$HOME/Hooji/My-Projects" ] && search_dirs+=("$HOME/Hooji/My-Projects")
  [ -d "$HOME/Hooji/tools" ] && search_dirs+=("$HOME/Hooji/tools")
  
  if [ ${#search_dirs[@]} -eq 0 ]; then
    echo "No project directories found. Configure search_dirs in functions.zsh."
    return 1
  fi

  local dir
  if command -v fd &> /dev/null; then
    dir=$(fd . "${search_dirs[@]}" --max-depth 2 --type d --exclude .git --exclude node_modules | fzf --height 40% --reverse --prompt="Jump to Project > ")
  else
    dir=$(find "${search_dirs[@]}" -maxdepth 2 -type d -not -path '*/.*' -not -path '*/node_modules*' 2>/dev/null | fzf --height 40% --reverse --prompt="Jump to Project > ")
  fi

  if [ -n "$dir" ]; then
    cd "$dir" || return
    echo "Switched to: $PWD"
    
    # Prompt to open in editor if set
    local editor_cmd="code"
    if [ -n "$EDITOR" ]; then
      editor_cmd="$EDITOR"
    fi
    echo -n "Open in editor ($editor_cmd)? [y/N] "
    read -k 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if command -v "$editor_cmd" &> /dev/null; then
        "$editor_cmd" .
      else
        $editor_cmd .
      fi
    fi
  fi
}

# Interactive Process Killer
fk() {
  local pid
  if [ "$(uname)" = "Darwin" ]; then
    pid=$(ps -ef -u "$USER" | fzf --height 40% --reverse --header="Kill Process (Enter to kill, Esc to abort)" --preview "echo {}" --preview-window=down:1:wrap | awk '{print $2}')
  else
    pid=$(ps -ef --user "$USER" | fzf --height 40% --reverse --header="Kill Process (Enter to kill, Esc to abort)" --preview "echo {}" --preview-window=down:1:wrap | awk '{print $2}')
  fi
  if [ -n "$pid" ]; then
    echo "Killing process $pid..."
    kill -9 "$pid"
  fi
}

# Interactive Git Branch Checkout
fco() {
  local branches branch
  branches=$(git branch --all --color=always | grep -v '/HEAD ->') || return
  branch=$(echo "$branches" | fzf --height 40% --reverse --ansi --prompt="Checkout Branch > " --preview "git log --oneline --graph --color=always {1} | head -n 20")
  if [ -n "$branch" ]; then
    local target_branch=$(echo "$branch" | sed "s/.* //" | sed "s#remotes/origin/##")
    git checkout "$target_branch"
  fi
}

# Interactive Git Commit Explorer (Enter to view full diff)
fshow() {
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | \
    fzf --ansi --no-sort --reverse --tiebreak=index --prompt="Git commits > " \
      --preview "echo {} | grep -o '[a-f0-9]\{7,40\}' | head -1 | xargs -I % sh -c 'git show --color=always %'" \
      --bind "enter:execute(echo {} | grep -o '[a-f0-9]\{7,40\}' | head -1 | xargs -I % sh -c 'git show % | less')"
}

# Interactive File Finder with bat preview
fwind() {
  local file
  if command -v fd &> /dev/null; then
    file=$(fd --type f --hidden --exclude .git --exclude node_modules | fzf --height 50% --reverse --prompt="Find File > " --preview "bat --color=always --style=numbers --line-range :500 {}")
  else
    file=$(find . -type f -not -path '*/.*' -not -path '*/node_modules*' 2>/dev/null | fzf --height 50% --reverse --prompt="Find File > " --preview "bat --color=always --style=numbers --line-range :500 {}")
  fi
  
  if [ -n "$file" ]; then
    if command -v code &> /dev/null; then
      code "$file"
    elif [ -n "$EDITOR" ]; then
      $EDITOR "$file"
    else
      nano "$file"
    fi
  fi
}

# Interactive Docker Exec Shell Launcher
dexec() {
  local container
  container=$(docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}" | grep -v "CONTAINER ID" | fzf --height 40% --reverse --prompt="Select Container > " --header="Docker Exec Shell")
  if [ -n "$container" ]; then
    local container_id=$(echo "$container" | awk '{print $1}')
    local container_name=$(echo "$container" | awk '{print $2}')
    echo "Connecting to $container_name ($container_id)..."
    docker exec -it "$container_id" /bin/bash 2>/dev/null || docker exec -it "$container_id" /bin/sh
  fi
}

