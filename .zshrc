# History & usability
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS SHARE_HISTORY prompt_subst

# Default programs:
export EDITOR="nvim"
export TERMINAL="foot"
export TERMINAL_PROG="foot"
export BROWSER="firefox"

# Completion
autoload -Uz compinit
compinit

# Colors and Prompt
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[2 q';;      # non-blinking block
        viins|main) echo -ne '\e[6 q';; # non-blinking beam
    esac
}

zle -N zle-keymap-select

zle-line-init() {
    zle -K viins
    echo -ne '\e[6 q'  # non-blinking beam on init
}
zle -N zle-line-init

# Use non-blinking beam on startup
echo -ne '\e[6 q'

# Use non-blinking beam for each new prompt
preexec() { echo -ne '\e[6 q' ;}


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

# Exports
export EDITOR="nvim"
export PATH="$HOME/.local/bin:$PATH"
