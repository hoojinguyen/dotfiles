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
