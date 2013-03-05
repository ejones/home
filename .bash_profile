if [[ -f ~/.bashrc ]]; then . ~/.bashrc; fi
bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
eval "$(rbenv init -)"
