# config.zsh - Core ZSH options

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# History options
setopt HIST_IGNORE_DUPS       # Do not record an event that was just recorded.
setopt HIST_IGNORE_ALL_DUPS   # Delete old recorded duplicated events.
setopt HIST_FIND_NO_DUPS      # Do not display a line previously found.
setopt HIST_IGNORE_SPACE      # Do not record an event starting with a space.
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from each line.
setopt SHARE_HISTORY          # Share history between sessions.

# UI/Interactive options
setopt AUTO_CD                # If a command is not found, but it is a directory, cd into it.
setopt AUTO_PUSHD             # Make cd push the old directory onto the directory stack.
setopt PUSHD_IGNORE_DUPS      # Don't push multiple copies of the same directory onto the stack.
setopt EXTENDED_GLOB          # Treat #, ~, and ^ as part of patterns for filename generation.

# Initialize completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
