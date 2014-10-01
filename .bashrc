export PATH="$HOME/bin:$HOME/.cljr/bin:$HOME/.rbenv/bin:/usr/local/share/npm/bin:/usr/local/sbin:/usr/local/bin:$PATH"

# Per the rbenv docs, uses Homebrew dirs instead of ~/.rbenv for rbenv
export RBENV_ROOT="/usr/local/var/rbenv"

# These lines update PATH for the Google Cloud SDK.
GOOGLE_CLOUD_PATH="$HOME/google-cloud-sdk/path.bash.inc"
if [[ -f "$GOOGLE_CLOUD_PATH" ]]; then
    source "$GOOGLE_CLOUD_PATH"
fi
