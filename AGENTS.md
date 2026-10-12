# AGENTS.md

## Project

`firefox-clean-bookmarks` is a Firefox extension (WebExtension) for personal use.
It is not planned to be published on addons.mozilla.org.

Goal: organize bookmark folders by assigning colors to them.

## Tech stack

- Plain JavaScript, HTML, CSS (no framework, no bundler unless really needed)
- WebExtensions API (`browser.*` namespace, Promise-based)
- [`web-ext`](https://github.com/mozilla/web-ext) for running and linting

## Commands

```sh
npx web-ext run    # Launch Firefox with the extension loaded
npx web-ext lint   # Validate manifest and source
npx web-ext build  # Create a zip in web-ext-artifacts/
```

For manual loading: open `about:debugging#/runtime/this-firefox` → "Load Temporary Add-on…" → select `manifest.json`.

## Coding rules

- Keep it simple (KISS). Avoid over-engineering and unnecessary abstractions.
- Request only the minimum permissions in `manifest.json`.
- Where to write what:
  - Code: **How**
  - Test code: **What**
  - Commit messages: **Why**
  - Code comments: **Why not** (do not write other kinds of comments)

## Git

- Repository: https://github.com/MayugeStudio/firefox-clean-bookmarks (public)
- Do not commit secrets or build artifacts (`web-ext-artifacts/`).
