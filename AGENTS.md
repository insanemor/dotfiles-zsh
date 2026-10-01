# AGENTS.md

Operational notes for agents working in this dotfiles repository. This is a
personal dotfiles repo (zsh + kitty + herdr + Claude Code), not a typical
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
│   ├── .claude-statusline.sh  # Claude Code statusLine → writes the cache file above
│   └── .tool-versions         # asdf-managed versions (single source of truth)
├── config/kitty/              # → ~/.config/kitty/
│   ├── kitty.conf
│   ├── current-theme.conf     # kitty rewrites this on theme switch
│   ├── dark-theme.auto.conf
│   └── 3.png                  # background image (versioned, symlinked)
├── config/herdr/              # → ~/.config/herdr/   (substituto do tmux)
│   └── config.toml            # prefix Ctrl-b, splits |/-, hjkl, popups lazygit/lazydocker
├── claude/hooks/              # → ~/.claude/hooks/
│   └── claude-notify.sh       # Stop/Notification → notify-send + BEL
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

`./install.sh` installs `herdr` via its official curl script in `step_herdr`
(runs after `step_link` so `~/.config/herdr/` exists). On first launch the
herdr server picks up `config.toml` from the symlink automatically; on
subsequent edits, reload inside herdr with **`prefix + shift + r`** (the
default), or run `herdr server reload-config` from any pane.

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
- Nerd Font icons are inlined as `$'<glyph>'` in zsh scripts. The
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
- Writes `\a` (BEL) to **`/dev/tty`** (the shell's own controlling tty —
  which, inside a herdr pane, IS the pane's tty). This is what makes the
  bell cross SSH and trigger kitty/Windows Terminal flashes.
- Exits 0 always.

### Claude Code usage in the herdr sidebar

The sidebar (`prefix + w`) is **not** enabled by default. `config/herdr/config.toml`
declares `[ui.sidebar.agents]` and `[ui.sidebar.spaces]` explicitly. The Spaces
rows include `branch`, `git_status`, the custom `$local_branches` token, and
`$claude_usage` (5h/7d/ctx percentages from `~/.cache/claude/usage.json`).

The `$claude_usage` token is provided by the **herdr-claude-usage plugin**
(`alejodelosrios/herdr-claude-usage`), installed by `install.sh`
(`step_herdr_claude_usage`). It is **not** a native herdr feature; the plugin
runs a Python monitor that reads the same `usage.json` and posts metadata
into the focused workspace. **First-time setup inside an active herdr session:**

```sh
herdr plugin action invoke start --plugin unit1.claude-usage
```

After the first `start`, the monitor hooks into `workspace.created` and
`pane.created` events automatically — no need to re-run it on every restart.

The `$local_branches` token is provided by the **local `git-status` plugin**
in `config/herdr/plugins/git-status/` (manifest + `publish.py`), linked by
`install.sh` (`step_herdr_git_status`) via `herdr plugin link`. It listens
to `workspace.created` / `pane.created` / `pane.focused` and posts a
compact branch list + dirty marker to the focused pane, so the sidebar
shows every local branch (e.g. `main* dev feat/foo ±2`) without opening
lazygit just to check.

The `~/.tmux-claude-usage.sh` and `~/.tmux-minimax-usage.sh` files were
removed in the herdr migration; usage now lives in the herdr sidebar
itself (`prefix + w`) instead of a top statusline.

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
- **The `.zshrc` herdr auto-attach has exceptions.** It executes
  `herdr --session main` only in interactive shells that are NOT inside
  another herdr (`$HERDR_ENV`), NOT the VS Code integrated terminal
  (`$TERM_PROGRAM`), and NOT a dropdown terminal. `_is_dropdown_terminal`
  checks `GUAKE_TAB_UUID` first, then walks the `/proc` parent chain for
  `guake`/`yakuake`. The env var is the reliable signal for Guake — its
  terminal process is often reparented to systemd, so the process walk alone
  would miss it; the /proc walk covers Yakuake's first shell (before any
  herdr exists).
- **Session persistence is on by default** via herdr's built-in
  `[session] resume_agents_on_restore = true` (Claude Code/Codex/etc
  resume their conversations after server restart) and
  `[experimental] pane_history = true` (replays recent terminal output
  after a full restart). The `config/herdr/config.toml` keeps these on;
  no separate plugin manager is required (herdr is a single Rust binary).
  This interacts with the .zshrc auto-attach: the first shell after a
  reboot runs `herdr --session main`, which boots the server and resumes
  any saved agents.
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
3. Inside herdr: `prefix + shift + r` to reload `config.toml`
   (or run `herdr server reload-config` from any pane).
4. Open a new shell (or `exec zsh`) to pick up `.zshrc` / `.zshenv` changes.
5. For Claude Code: `/hooks` → reload, or restart the Claude session.

There are no automated tests; verification is opening a new shell and seeing
that the prompt, status bar, and hooks look right.
