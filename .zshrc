# History & usability
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS SHARE_HISTORY prompt_subst

export EDITOR="/usr/bin/nvim"

# Completion
autoload -Uz compinit
compinit

# Colors and Prompt
autoload -U colors && colors
PS1="%B%{$fg[red]%}[\
%{$fg[yellow]%}%n\
%{$fg[green]%}@\
%{$fg[blue]%}%M \
%{$fg[magenta]%}%~\
%{$fg[red]%}]%{$reset_color%}$%b "


# Use vim-style keybindings in zsh
bindkey -v

# Make ESC in insert mode feel snappy
KEYTIMEOUT=1

# Autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting
# IMPORTANT: load this LAST
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Aliases
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias cfg='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
if type _git &>/dev/null; then
  compdef _git cfg
fi

