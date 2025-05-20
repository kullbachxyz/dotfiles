#
#
# ~/.bashrc
#
# Add ~/.local/bin and all subdirectories to PATH
while IFS= read -r -d '' dir; do
     [[ ":$PATH:" != *":$dir:"* ]] && PATH="$dir:$PATH"
done < <(find "$HOME/.local/bin" -type d -print0)
# Globals
export EDITOR=vim
export TERMINAL=st
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias gsrc="cd ~/.local/src"
alias gbin="cd ~/.local/bin"

alias clip="xclip -selection clipboard"

# PS1='[\u@\h \W]\$ '
PS1="\[\e[1;31m\][\[\e[0;33m\]\u\[\e[0;32m\]@\[\e[0;34m\]\h \[\e[0;35m\]\w\[\e[1;31m\]]\[\e[0m\]\$ "


alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
