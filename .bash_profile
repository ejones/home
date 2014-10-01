if [[ -f ~/.bashrc ]]; then . ~/.bashrc; fi
bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

alias ll='ls -l'

alias gs='git status'
alias ga='git add'
alias gd='git diff'
alias gc='git checkout'
alias gco='git commit -v'
alias gf='git fetch'
alias gm='git merge'
alias gp='git push'
alias gl='git log --left-right'
alias glg='git log-graph --left-right'
alias gst='git stash'
alias gsm='git submodule'
alias gsmup='git submodule update --init --recursive'
alias gr='git reset'
alias gsh='git show'

# gcb - "Git Checkout Branch"
# (also Great Canadian Bagel)
# WIP!
gcb() {
    git checkout "$1" &&
    git submodule update --init --recursive
}

GOOGLE_CLOUD_COMPLETION="$HOME/google-cloud-sdk/completion.bash.inc"
if [[ -f "$GOOGLE_CLOUD_COMPLETION" ]]; then
    source "$GOOGLE_CLOUD_COMPLETION"
fi

# {{{
# Node Completion - Auto-generated, do not touch.
shopt -s progcomp
for f in $(command ls ~/.node-completion); do
  f="$HOME/.node-completion/$f"
  test -f "$f" && . "$f"
done
# }}}
