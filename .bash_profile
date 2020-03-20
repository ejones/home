export EDITOR=vim
export ORMAS=origin/master

export PATH="$HOME/bin:$HOME/.yarn/bin:$PATH"

# These lines update PATH for the Google Cloud SDK.
GOOGLE_CLOUD_PATH="$HOME/google-cloud-sdk/path.bash.inc"
if [[ -f "$GOOGLE_CLOUD_PATH" ]]; then
    source "$GOOGLE_CLOUD_PATH"
fi

# export JAVA_HOME=$(/usr/libexec/java_home -version 1.8)

# type rbenv >/dev/null 2>&1 && eval "$(rbenv init - --no-rehash)"
# type nodenv >/dev/null 2>&1 && eval "$(nodenv init - --no-rehash)"

type nix-shims >/dev/null 2>&1 && eval "$(nix-shims init)"

if [[ -f ~/.bashrc ]]; then . ~/.bashrc; fi

stashed() {
    git stash -u && { "$@"; git stash pop; }
}

setupstream() {
    git branch --set-upstream-to="$1"
}

gds() {
    git diff -w "$@" | ydiff -w"$(($(tput cols) > 280 ? 140 : 0))" -s
}

gss() {
    git show -w "$@" | ydiff -w"$(($(tput cols) > 280 ? 140 : 0))" -s
}

othersessions() {
    who -u |
    while read name _line _time1 _time2 idle pid _comment; do
      if [ "$name" = "$(whoami)" ] && [ "$idle" != "." ]; then
        pgrep -P "$pid"
      fi
    done
}

simplehttp() {
    cd "$2" && python -mhttp.server "$1"
}

export -f stashed setupstream gds gss othersessions iterm2copy simplehttp

if type brew >/dev/null 2>&1 && [[ -s "$(brew --prefix)/etc/profile.d/autojump.sh" ]]; then
    source "$(brew --prefix)/etc/profile.d/autojump.sh"
fi

# Completion
# if [[ -s "$(brew --prefix)/etc/bash_completion" ]]; then
#     . "$(brew --prefix)/etc/bash_completion"

#     __git_complete ga _git_add
#     __git_complete gd _git_diff
#     __git_complete gc _git_checkout
#     __git_complete gco _git_commit
#     __git_complete gf _git_fetch
#     __git_complete gm _git_merge
#     __git_complete gp _git_push
#     __git_complete gl _git_log
#     __git_complete gst _git_stash
#     __git_complete gsm _git_submodule
#     __git_complete gr _git_reset
#     __git_complete gsh _git_show
#     __git_complete gff _git_merge
#     __git_complete gb _git_branch
# fi

if [[ -n "$(othersessions)" ]]; then
    echo 'There are suspended sessions:'
    psme
    read -p 'Do you want to kill them? [y/N] ' -r
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        kill $(othersessions)
    fi
fi

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
if [ -e /Users/evan/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/evan/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
