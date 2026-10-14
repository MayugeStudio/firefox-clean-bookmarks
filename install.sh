#!/bin/sh
set -eu

FIREFOX_DIR="$HOME/Library/Application Support/Firefox"
REPO_DIR=$(cd "$(dirname "$0")" && pwd)
PREF='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

if [ $# -ge 1 ]; then
  PROFILE_DIR=$1
else
  PROFILE_DIR="$FIREFOX_DIR/$(sed -n 's/^Default=//p' "$FIREFOX_DIR/installs.ini" | head -n 1)"
fi

if [ ! -d "$PROFILE_DIR" ]; then
  echo "Profile not found: $PROFILE_DIR" >&2
  exit 1
fi

SOURCE="$REPO_DIR/chrome/userChrome.css"
mkdir -p "$REPO_DIR/chrome"
{
  echo '@charset "UTF-8";'
  tr -d '\r' < "$REPO_DIR/folders.conf" | while IFS= read -r line || [ -n "$line" ]; do
    case $line in ''|'#'*) continue ;; esac
    # Split at the last "=", because folder names may contain "=" but colors never do.
    name=$(printf '%s' "${line%=*}" | sed 's/[\\"]/\\&/g')
    color=$(printf '%s' "${line##*=}" | tr -d ' \t')
    printf '.bookmark-item[container][label="%s"] {\n  background-color: %s55 !important;\n}\n' "$name" "$color"
  done
} > "$SOURCE"
echo "Generated: $SOURCE"

TARGET="$PROFILE_DIR/chrome/userChrome.css"
mkdir -p "$PROFILE_DIR/chrome"

# Not overwritten, because a regular file may contain the user's own customizations.
if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  echo "A regular file already exists: $TARGET" >&2
  echo "Move it away and run again." >&2
  exit 1
fi
ln -sfn "$SOURCE" "$TARGET"
echo "Linked: $TARGET -> $SOURCE"

# user.js is used instead of editing prefs.js, because Firefox rewrites prefs.js on exit.
if ! grep -qsF "$PREF" "$PROFILE_DIR/user.js"; then
  echo "$PREF" >> "$PROFILE_DIR/user.js"
fi
echo "Pref enabled in: $PROFILE_DIR/user.js"

echo "Restart Firefox to apply."
