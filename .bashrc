#
# ~/.bashrc
#

echo; pfetch

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fullvalgrind='valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes'

# Prompt prefix
PS1='[ \u : \W ] $ '
