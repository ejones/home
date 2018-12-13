[[ $(uname) = Darwin ]] && PS1=$'\\u:\\W$ '

bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

alias ll='ls -l'

alias gs='git status'
alias ga='git add'
alias gd='git diff'
alias gc='git checkout'
alias gco='git commit -v'
alias gf='git fetch'
alias gm='git merge'
alias gp='git push'
alias gpoh='git push origin HEAD'
alias gl='git log --left-right'
alias glg='git log-graph --left-right'
alias gst='git stash'
alias gsm='git submodule'
alias gsmup='git submodule update --init --recursive'
alias gr='git reset'
alias gsh='git show'
alias gff='git merge --ff-only'
alias gre='git rebase'
alias gb='git branch'
alias fixup='git commit --amend --no-edit'

alias yt='yarn test'
alias ytu='yarn test -u'

alias cdiff140s='cdiff -w140 -s'
alias cdiff0s='cdiff -w0 -s'

alias simple-http='python -mSimpleHTTPServer'
alias grasp='grasp -x js,jsx --parser "(flow-parser, { esproposal_class_instance_fields: true, esproposal_class_static_fields: true, esproposal_decorators: true, esproposal_export_star_as: true, types: true})"'

alias track-ordev='set-upstream origin/develop'

alias gdcas='gds --cached'

alias nsh='nix-shell --pure'

# Work-specific settings/scripts. Not synced publicly!
if [[ -s "$HOME/.work/bashrc" ]]; then
    source "$HOME/.work/bashrc"
fi

