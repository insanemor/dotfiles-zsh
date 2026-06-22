# AGENTS.md

Operational notes for agents working in this dotfiles repository. This is a
personal dotfiles repo (zsh + kitty + tmux + Claude Code), not a typical
software project — there is no `package.json`, no test suite, and no build
step. The "commands" are bash steps inside `install.sh`, and the "source
files" are shell scripts and config snippets.

## Repository layout

```
.
├── install.sh                 # bootstrap: installs packages + tools + creates symlinks
├── README.md                  # human-readable docs (in Portuguese)
├── home/                      # files linked directly into $HOME
│   ├── .zshrc                 # main zsh config (oh-my-zsh, p10k, aliases, PATH)
│   ├── .fzf.zsh               # fzf shell integration
│   ├── .p10k.zsh              # Powerlevel10k prompt config (large, auto-generated)
│   ├── .tmux.conf             # tmux config (prefix Ctrl-a, status bar styling, TPM)
│   ├── .tmux-statusline.zsh   # shell hook → writes @env_info to tmux status bar
│   ├── .tmux-claude-usage.sh  # reads ~/.cache/claude/usage.json, renders Claude usage
│   ├── .tmux-minimax-usage.sh # fetches MiniMax Coding Plan quota, renders usage
│   ├── .claude-statusline.sh  # Claude Code statusLine → writes the cache file above
│   └── .tool-versions         # asdf-managed versions (single source of truth)
├── config/kitty/              # → ~/.config/kitty/
│   ├── kitty.conf
│   ├── current-theme.conf     # kitty rewrites this on theme switch
│   ├── dark-theme.auto.conf
│   └── 3.png                  # background image (versioned, symlinked)
├── claude/hooks/              # → ~/.claude/hooks/
│   └── claude-notify.sh       # Stop/Notification → notify-send + tmux bell
└── bin/_awspp                 # reference copy of the awsp helper (real one ships in /usr/local/bin)
```

`.gitignore` only excludes editor backups (`*.bak`, `*.swp`, `*.pre-claude.bak`).

## Essential commands

There is no build, lint, or test step. The only top-level entry point is
`install.sh`, and it has three sub-modes:

```bash
./install.sh             # default: ALL (system packages + tools + symlinks)
./install.sh link        # ONLY symlinks + Claude hook merge into settings.json
./install.sh tools       # userland tools only (no sudo / no system packages)
SKIP_PKGS=1 ./install.sh # skip the apt/pacman step but keep going
```

After `./install.sh`, inside an active tmux session run **`prefix + I`** (with
prefix = `Ctrl-a`) to finalize TPM plugin installation.

After editing `~/.tmux.conf`, reload it inside tmux with **`prefix + r`**.

After editing `claude/hooks/claude-notify.sh`, run `/hooks` inside Claude Code
(or restart the Claude session) to reload the merged `settings.json`.

`install.sh` is **idempotent**: it skips work already done, makes backups of
existing dotfiles to `~/.dotfiles-backup/<timestamp>/`, and only relinks a
symlink when `readlink -f` of source and destination differ. Re-running it is
safe.

## Conventions and patterns

### Shell script style

- `install.sh` uses `set -uo pipefail` (not `-e`; many steps tolerate partial
  failure with `|| warn ...`).
- Stdlib helpers in `install.sh`: `log`, `ok`, `warn`, `err`, `have`, `link`,
  `load_brew`. Use them — they emit colored prefixed output.
- The `link` helper:
  - Bails with a warning if the source doesn't exist (won't create a dangling link).
  - Bails "already correct" if `readlink -f` matches.
  - Otherwise moves any existing `$dst` into `$BACKUP_DIR` (preserving relative
    path under `$HOME`) before `ln -s`.
- After running, `install.sh` prints hints at the bottom — keep those hints in
  sync if you add a new manual step.

### Dotfile / config style

- Paths use `~`/`$HOME`, never hard-coded usernames. Do not introduce them.
- Many tools probe multiple locations (e.g., `fdfind` vs `fd`,
  `/home/linuxbrew/.linuxbrew/bin/brew` vs `/opt/homebrew/bin/brew` vs
  `/usr/local/bin/brew`). Match the existing pattern when adding cross-OS
  detection.
- Nerd Font icons are inlined as `$'<glyph>'` in zsh scripts and as
  `\#<codepoint>` Powerline glyphs (`\ue0bc`, etc.) in `tmux.conf`. The
  installed font is `FiraCode Nerd Font Mono`.

### Claude Code hooks

`install.sh` (`step_claude_hooks`) does an **idempotent merge** into
`~/.claude/settings.json`: it adds `Stop` and `Notification` hooks pointing at
`claude-notify.sh stop` and `claude-notify.sh notification` only if a
`claude-notify.sh` reference isn't already present (string match on the
serialized array). Do NOT replace the whole file — preserve the user's other
hooks.

The hook itself (`claude/hooks/claude-notify.sh`):
- Reads event JSON from stdin (may be empty).
- Sends a `notify-send` desktop notification (requires `libnotify` / `libnotify-bin`).
- Writes `\a` (BEL) to the **active tmux pane's tty** via
  `tmux display-message -p '#{pane_tty}'`. This is what makes the bell cross
  SSH and trigger kitty/Windows Terminal flashes.
- Exits 0 always.

### Tmux status bar data flow

Two files cooperate to display Claude usage in the tmux status bar:

1. `~/.claude-statusline.sh` — wired in by Claude Code itself as the
   `statusLine` command. Receives event JSON on stdin, extracts
   `rate_limits.five_hour` / `seven_day` / `context_window`, writes the
   parsed snapshot to `~/.cache/claude/usage.json`, and prints the status
   line string.
2. `~/.tmux-claude-usage.sh` — sourced into the status-left string in
   `tmux.conf`. It `pgrep -x claude` first (silent if Claude isn't running),
   drops the segment when data is >5 min stale, and colors the 5h percentage
   green/yellow/red at <70/<90/≥90.
3. `~/.tmux-minimax-usage.sh` — same slot in `tmux.conf`, fetches the
   Coding Plan quota directly from `https://api.minimax.io/v1/token_plan/remains`
   with the user's Bearer key (env `MINIMAX_API_KEY`, or falls back to
   the MiniMax key in `~/.local/share/crush/crush.json`). Uses the
   `current_interval_remaining_percent` / `current_weekly_remaining_percent`
   fields; caches to `~/.cache/minimax/usage.json` for 5 min. Silent when
   no key is set or `MINIMAX_BAR=0`. (Note: the MiniMax API exposes the
   remaining percent directly — no subtraction from "total" needed; the
   `total`/`usage_count` fields are 0 for this plan tier and were a
   red-herring from older docs.)

`~/.tmux-statusline.zsh` is a zsh `precmd` hook (runs in the background via
`&!`) that pushes git/k8s/tf/aws/gcloud/python/node info into the tmux
`@env_info` option — that's what feeds the right side of the bar. The git
section uses `git status -sbunormal` (porcelain, no submodules, untracked
included) and parses: branch name, `↑N` (ahead) / `↓N` (behind) from the
`[ahead N, behind M]` line, and dirty counts as `+N` (staged) / `!N`
(unstaged) / `?N` (untracked). It runs in `&!` so the git status overhead
(~2ms) doesn't block the prompt.

### asdf

`home/.tool-versions` is the single source of truth for managed versions.
`install.sh` (`step_asdf`) adds plugins for each line (with a small override
map for plugins that need explicit Git URLs: `bun`, `kubectx`,
`tf-summarize`), then runs `asdf install` from `$HOME`. To add a tool,
append a line to `.tool-versions` and re-run `./install.sh tools`.

### npm tools versioned in `.tool-versions`

Linhas terminadas em `# npm` (ex.: `tree-sitter-cli 0.26.9  # npm`) são
instaladas por `step_npm_tools` via `npm i -g`. Use para pacotes sem
plugin asdf.

## Things to watch out for

- **`install.sh` runs `sudo apt-get` / `sudo pacman` and `chsh`** when run as
  `all` (default). Do not run that mode unattended in CI without
  `SKIP_PKGS=1` and a `brew` that's already provisioned.
- **The default symlink loop globs `home/.[!.]*`** — adding a file whose name
  starts with `..` won't get linked; adding one starting with `.` will.
- **`install.sh` requires `curl`, `git`, and `jq`** to be present. The first
  apt/pacman step installs `jq`; if you're running `tools` on a fresh box
  without `jq`, the Claude hook merge step will be skipped with a warning.
- **`/home/linuxbrew/.linuxbrew/bin/brew`** is detected but `eval`'d via
  `load_brew` only inside install steps. The `.zshrc` independently probes
  the three brew paths at shell startup — order matters there: asdf shims
  are prepended AFTER brew shellenv.
- **The `awsp` alias is `alias awsp="source _awspp"`** — this relies on
  `_awspp` being on `PATH`. The `install.sh` doesn't symlink it; it expects
  the global `npm install -g awsp` to drop it in `/usr/local/bin`. The copy
  in `bin/_awspp` is reference-only (note the typo "Usaado somentee…" in
  `~/.zshrc` line 40 is in the original file, not a clue).
- **Background in tmux status update**: `_tmux_refresh_env` runs `&!` so it
  doesn't block the prompt, but it also calls `tmux refresh-client -S` which
  redraws the bar.
- **1Password SSH agent** (`SSH_AUTH_SOCK=~/.1password/agent.sock` in `.zshrc`)
  is referenced but the agent is NOT installed by `install.sh` — README
  explicitly calls this out as a manual step.
- **`.p10k.zsh` is 80KB** of auto-generated config from `p10k configure`. Do
  not hand-edit; re-run `p10k configure` and replace the file if the prompt
  needs to change.
- **`background_image` in `kitty.conf` is silently overridden by the included
  theme files.** `kitty.conf` line 3271 does `include current-theme.conf` (and
  the dark variant), and the kitty docs explicitly state (kitty.conf
  ~line 1733): *"when using auto_color_scheme, background_image is
  overridden by the color scheme file and must be set inside it to take
  effect"*. As a result, putting `background_image` only in `kitty.conf` is a
  no-op — it must also live in **both** `config/kitty/current-theme.conf` and
  `config/kitty/dark-theme.auto.conf`. If you add a new theme file (kitty
  switches via `kitten themes`), remember to copy the two `background_image*`
  lines into it too, or the background will disappear.

## Editing workflow

1. Make changes to files inside `home/`, `config/`, `claude/`, or `bin/`.
2. Run `./install.sh link` to refresh the symlinks + re-merge Claude hooks.
3. Inside tmux: `prefix + r` to reload `tmux.conf`.
4. Open a new shell (or `exec zsh`) to pick up `.zshrc` / `.zshenv` changes.
5. For Claude Code: `/hooks` → reload, or restart the Claude session.

There are no automated tests; verification is opening a new shell and seeing
that the prompt, status bar, and hooks look right.
