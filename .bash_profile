export ORDEV=origin/develop
export ORMAS=origin/master

if [[ -f ~/.bashrc ]]; then . ~/.bashrc; fi
bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi

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

# Completion
if [[ -s "$(brew --prefix)/etc/bash_completion" ]]; then
    . "$(brew --prefix)/etc/bash_completion"

    __git_complete ga _git_add
    __git_complete gd _git_diff
    __git_complete gc _git_checkout
    __git_complete gco _git_commit
    __git_complete gf _git_fetch
    __git_complete gm _git_merge
    __git_complete gp _git_push
    __git_complete gl _git_log
    __git_complete gst _git_stash
    __git_complete gsm _git_submodule
    __git_complete gr _git_reset
    __git_complete gsh _git_show
    __git_complete gff _git_merge
    __git_complete gb _git_branch
fi

stashed() {
    git stash -u && { "$@"; git stash pop; }
}

set-upstream() {
    git branch --set-upstream-to="$1"
}

alias track-ordev='set-upstream origin/develop'

gds() {
    git diff -w "$@" | cdiff -w"$(($(tput cols) > 280 ? 140 : 0))" -s
}

gss() {
    git show -w "$@" | cdiff -w"$(($(tput cols) > 280 ? 140 : 0))" -s
}

alias gdcas='gds --cached'

GOOGLE_CLOUD_COMPLETION="$HOME/google-cloud-sdk/completion.bash.inc"
if [[ -f "$GOOGLE_CLOUD_COMPLETION" ]]; then
    source "$GOOGLE_CLOUD_COMPLETION"
fi

if [[ -s "$(brew --prefix)/etc/profile.d/autojump.sh" ]]; then
    source "$(brew --prefix)/etc/profile.d/autojump.sh"
fi

# {{{
# Node Completion - Auto-generated, do not touch.
shopt -s progcomp
for f in $(command ls ~/.node-completion); do
  f="$HOME/.node-completion/$f"
  test -f "$f" && . "$f"
done
# }}}

if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    source "$HOME/.rvm/scripts/rvm"
fi

if [[ -s "$HOME/.work/bashrc" ]]; then
    source "$HOME/.work/bashrc"
fi
