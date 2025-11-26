# History & usability
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS SHARE_HISTORY prompt_subst

# Completion
autoload -Uz compinit
compinit

# Simple Git Integraion
git_prompt() {
  local branch dirty

  # Only if we're in a git repo
  if command git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(
      git symbolic-ref --short HEAD 2>/dev/null || \
      git describe --tags --exact-match 2>/dev/null || \
      git rev-parse --short HEAD 2>/dev/null
    )

    # Dirty flag: "*" if there are changes
    if ! git diff --quiet --ignore-submodules HEAD 2>/dev/null; then
      dirty="*"
    fi

    # Print with color, no newline
    print -n " %{$fg[cyan]%}(${branch}${dirty})%{$reset_color%}"
  fi
}

# Colors and Prompt
autoload -U colors && colors
PS1="%B%{$fg[red]%}[\
%{$fg[yellow]%}%n\
%{$fg[green]%}@\
%{$fg[blue]%}%M \
%{$fg[magenta]%}%~\
\$(git_prompt)\
%{$fg[red]%}]%{$reset_color%}$%b "


# Use vim-style keybindings in zsh
bindkey -v

# Make ESC in insert mode feel snappy
KEYTIMEOUT=1

# Cursor shape: block in NORMAL mode, beam in INSERT mode
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    # NORMAL mode → block cursor
    echo -ne '\e[2 q'
  else
    # INSERT mode → beam cursor
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select

# Set initial cursor shape when the line editor starts
function zle-line-init {
  echo -ne '\e[6 q'   # start in INSERT mode → beam cursor
}
zle -N zle-line-init

# Optional: when a command is accepted, go back to block
function zle-line-finish {
  echo -ne '\e[2 q'
}
zle -N zle-line-finish


# Autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting
# IMPORTANT: load this LAST
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Aliases
alias v='nvim'
alias cfg='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
if type _git &>/dev/null; then
  compdef _git cfg
fi

