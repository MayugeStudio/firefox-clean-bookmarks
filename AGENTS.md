# AGENTS.md

## Project

`firefox-clean-bookmarks` customizes Firefox for personal use.

Goal: organize bookmark folders by assigning colors to them.

This is done with `userChrome.css`, not a WebExtension, because the WebExtensions API cannot style Firefox's native bookmark UI.

## Config

Edit `folders.conf` (UTF-8), one folder per line:

```
<folder name>=<color>
```

- The folder name must match exactly (case-sensitive).
- Lines starting with `#` are comments.
- `chrome/userChrome.css` is generated from it by the install scripts. Do not edit it by hand (it is gitignored).

## Setup

macOS:

```sh
./install.sh             # Use the default profile
./install.sh <profile>   # Use a specific profile ("Root Directory" in about:profiles)
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
powershell -ExecutionPolicy Bypass -File install.ps1 -ProfileDir <profile>
```

Both scripts are idempotent. They:

- generate `chrome/userChrome.css` from `folders.conf` and put it into `<profile>/chrome/`
  - macOS: as a symlink.
  - Windows: as a copy.
- add `toolkit.legacyUserProfileCustomizations.stylesheets = true` to `<profile>/user.js`

Re-run after editing `folders.conf` or moving this repository. Restart Firefox to apply, because `userChrome.css` is read only at startup.

## Coding rules

- Keep it simple (KISS). Avoid over-engineering and unnecessary abstractions.
- Where to write what:
  - Code: **How**
  - Test code: **What**
  - Commit messages: **Why**
  - Code comments: **Why not** (do not write other kinds of comments)

## Git

- Repository: https://github.com/MayugeStudio/firefox-clean-bookmarks (public)
- Do not commit secrets.
