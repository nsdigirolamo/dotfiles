#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Show MOTD
fastfetch

# Prompt Prefix
PS1='[ \u : \W ] $ '

# Aliases
alias ls='ls --color=auto --group-directories-first --classify'
alias cdls='function _cdls(){ cd $1; ls; };_cdls'
alias grep='grep --color=auto'
alias please='sudo'
alias fullvalgrind='\
    valgrind \
    --leak-check=full \
    --show-leak-kinds=all \
    --track-origins=yes \
    --verbose \
    --log-file=valgrind-out.txt'
alias prettydiff="\
    diff \
    --old-group-format=$'\nOLD:\n\e[0;31m%<\e[0m' \
    --new-group-format=$'NEW:\n\e[0;31m%>\e[0m\n' \
    --unchanged-group-format=$'SAME:\n\e[0;32m%=\e[0m'"
