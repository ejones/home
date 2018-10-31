export EDITOR=vim

export ORDEV=origin/develop
export ORMAS=origin/master

export HAXE_STD_PATH="/usr/local/lib/haxe/std"

export PATH="$HOME/bin:$HOME/arcanist/arcanist/bin:$HOME/Library/Python/2.7/bin:$PATH"

# These lines update PATH for the Google Cloud SDK.
GOOGLE_CLOUD_PATH="$HOME/google-cloud-sdk/path.bash.inc"
if [[ -f "$GOOGLE_CLOUD_PATH" ]]; then
    source "$GOOGLE_CLOUD_PATH"
fi

# export JAVA_HOME=$(/usr/libexec/java_home -version 1.8)

if type rbenv >/dev/null 2>&1; then eval "$(rbenv init - --no-rehash)"; fi
if type nodenv >/dev/null 2>&1; then eval "$(nodenv init - --no-rehash)"; fi

if [[ -f ~/.bashrc ]]; then . ~/.bashrc; fi

stashed() {
    git stash -u && { "$@"; git stash pop; }
}

setupstream() {
    git branch --set-upstream-to="$1"
}

gds() {
    git diff -w "$@" | cdiff -w"$(($(tput cols) > 280 ? 140 : 0))" -s
}

gss() {
    git show -w "$@" | cdiff -w"$(($(tput cols) > 280 ? 140 : 0))" -s
}

export -f stashed setupstream gds gss

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
