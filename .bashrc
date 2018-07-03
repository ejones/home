export PATH="$HOME/bin:$HOME/arcanist/arcanist/bin:$HOME/.cljr/bin:$HOME/.rbenv/bin:/usr/local/opt/node@6/bin:/usr/local/share/npm/bin:/usr/local/sbin:/usr/local/bin:$HOME/.rvm/bin:$PATH"
export PATH="$(yarn global bin):$PATH"

# Per the rbenv docs, uses Homebrew dirs instead of ~/.rbenv for rbenv
export RBENV_ROOT="/usr/local/var/rbenv"

# These lines update PATH for the Google Cloud SDK.
GOOGLE_CLOUD_PATH="$HOME/google-cloud-sdk/path.bash.inc"
if [[ -f "$GOOGLE_CLOUD_PATH" ]]; then
    source "$GOOGLE_CLOUD_PATH"
fi

# Work-specific settings/scripts. Not synced publicly!
if [[ -s "$HOME/.work/bashrc" ]]; then
    source "$HOME/.work/bashrc"
fi

# export JAVA_HOME=$(/usr/libexec/java_home -version 1.8)
