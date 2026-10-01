# dotfiles

Meus dotfiles (zsh + kitty + herdr) e um script de bootstrap para reinstalar
o ambiente do zero. Suporta **Ubuntu/Debian** (apt) e **Arch** (pacman) — o
`install.sh` detecta a distro automaticamente.

## Estrutura

```
.
├── install.sh                 # bootstrap: instala tudo + cria os symlinks
├── home/                      # arquivos que vão direto no $HOME
│   ├── .zshrc
│   ├── .fzf.zsh
│   ├── .p10k.zsh              # tema do prompt (Powerlevel10k)
│   ├── .claude-statusline.sh  # statusLine do Claude Code
│   └── .tool-versions         # versões geridas pelo asdf
├── config/
│   ├── kitty/                 # vai para ~/.config/kitty/
│   │   ├── kitty.conf
│   │   ├── current-theme.conf
│   │   ├── dark-theme.auto.conf
│   │   └── 3.png              # imagem de fundo (versionada junto da config)
│   ├── herdr/                 # vai para ~/.config/herdr/   (substituto do tmux)
│   │   └── config.toml        # prefix Ctrl-a, splits |/-, hjkl, popups lazygit/lazydocker
│   ├── nvim/                  # vai para ~/.config/nvim/ (init.lua, lua/, lazy-lock.json)
│   └── lazygit/
│       └── config.yml         # tema (combina com o kitty) + layout focado
├── claude/
│   └── hooks/
│       └── claude-notify.sh   # notificação (desktop + bell) -> ~/.claude/hooks/
└── bin/
    └── _awspp                 # cópia de referência do helper do awsp
```

## Instalação

```bash
git clone <este-repo> ~/dotfiles
cd ~/dotfiles
./install.sh            # tudo: pacotes + ferramentas + symlinks
```

Outros modos:

```bash
./install.sh link        # só recria os symlinks + hooks do Claude
./install.sh tools       # só ferramentas (não mexe nos pacotes do SO)
SKIP_PKGS=1 ./install.sh # pula a etapa de pacotes do SO
```

O script é **idempotente** (pode rodar de novo) e faz **backup** de qualquer
arquivo existente em `~/.dotfiles-backup/<timestamp>/` antes de criar os symlinks.

## O que é instalado

| Categoria        | Itens |
|------------------|-------|
| Pacotes do SO    | zsh, tmux, kitty, eza, openfortivpn, git, curl, jq, wl-clipboard, xclip, libnotify, fd, fontconfig, build-essential (via apt no Debian/Ubuntu ou pacman no Arch — nomes ajustados por distro) |
| Shell            | Oh My Zsh, Powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting |
| Ferramentas      | fzf, atuin, opencode, awsp |
| Homebrew         | asdf, fd, lazygit, neovim, charmbracelet/tap/crush |
| asdf (.tool-versions) | awscli, bun, gcloud, helm, k3d, k9s, kubectl, kubectx, nodejs, terraform, terragrunt, tf-summarize, velero |
| herdr            | binary único em ~/.local/bin (instalado via script oficial em `step_herdr`); config em `~/.config/herdr/config.toml` (symlink deste repo) |
| nvim             | config completa (init.lua + lua/) + lazy-lock.json → ~/.config/nvim |
| lazygit          | tema (laranja/roxo, combina com o kitty) + layout focado → ~/.config/lazygit |
| Claude Code      | hooks de notificação (Stop/Notification) → notify-send + bell no tty |
| Fonte            | FiraCode Nerd Font |

## Notificações do Claude Code

`claude/hooks/claude-notify.sh` dispara em dois eventos do Claude Code:

- **Stop** — quando o Claude termina de responder.
- **Notification** — quando o Claude está aguardando você (permissão/input).

Em cada evento faz duas coisas:
1. `notify-send` — notificação no desktop Linux (quando você está na máquina).
2. Um **bell** escrito em `/dev/tty` (o tty do shell atual — dentro do
   herdr isso é o tty da pane em foco). Atravessa o herdr e o SSH, tocando/
   piscando tanto no kitty quanto no Windows Terminal (acesso remoto).

O `install.sh` cria o symlink em `~/.claude/hooks/` e faz um **merge idempotente**
dos hooks em `~/.claude/settings.json` (preserva o resto das suas configs). Após
instalar numa máquina nova, rode `/hooks` no Claude Code (ou reinicie) para
recarregar a config. Para o bell aparecer no Windows Terminal, ajuste o
`bellStyle` no perfil (ex.: `"window"` ou `"taskbar"`).

## herdr

[herdr](https://herdr.dev) é um terminal multiplexer focado em AI coding agents
(escrito em Rust, agent-aware: detecta automaticamente se o Claude Code/Codex/etc
está **working/blocked/idle/done** lendo o output do painel). Substitui o tmux
com a mesma memória muscular — o `config/herdr/config.toml` deste repo
reproduz os atalhos do antigo `.tmux.conf`:

| Ação                            | Atalho            | Equivalente no tmux |
|---------------------------------|-------------------|---------------------|
| Prefixo                         | `Ctrl-a`          | `Ctrl-a`            |
| Split vertical                  | `prefix + \|`     | `prefix + \|`       |
| Split horizontal                | `prefix + -`      | `prefix + -`        |
| Navegar entre paineis           | `Alt + setas` ou `prefix + h/j/k/l` | idem |
| Swap de paineis                 | `prefix + Shift + h/j/k/l` | idem |
| Fechar painel                   | `prefix + x`      | `prefix + x`        |
| Zoom painel (tela cheia)        | `prefix + z`      | `prefix + z`        |
| Modo resize (hjkl, Esc sai)     | `prefix + r`      | `prefix + r` (resize) |
| Nova tab (janela)               | `prefix + c`      | `prefix + c` (new-window) |
| Fechar tab                      | `prefix + Shift + x` | `prefix + &` (kill-window) |
| Nova workspace (sessão)         | `prefix + Shift + n` | `prefix + Ctrl-n` |
| Fechar workspace                | `prefix + Shift + d` | `prefix + :kill-session` |
| Renomear workspace              | `prefix + Shift + w` | `prefix + $` |
| Ir para workspace               | `prefix + g`      | `prefix + s` (choose-tree) |
| Trocar workspaces sem prefixo   | `Ctrl + Up/Down`  | idem                |
| Trocar tabs sem prefixo         | `Shift + Left/Right` | idem              |
| lazygit (popup 90%)             | `prefix + Shift + g` | `prefix + G`      |
| lazydocker (popup 90%)          | `prefix + Alt + d`   | `prefix + D`     |
| Recarregar config               | `prefix + Shift + r` | `prefix + r` (source-file) |
| Lista de todos os atalhos       | `prefix + ?`      | `prefix + ?`        |

(O `prefix + Shift + r` para reload é o default do herdr; trocar `prefix + r`
por resize mode é uma escolha consciente — no tmux era `r` que recarregava,
aqui é `r` que entra no resize mode.)

- **Persistência de sessão.** `resume_agents_on_restore = true` faz
  Claude Code/Codex/etc retomarem as conversas após restart do servidor;
  `pane_history = true` (experimental) reproduz o conteúdo recente dos
  painéis. **Substitui** o antigo par tmux-resurrect + tmux-continuum.
- O `~/.zshrc` executa `herdr --session main` automaticamente em terminais
  interativos — **exceto** no terminal integrado do VS Code e em **terminais
  dropdown (Guake/Yakuake)**, que abrem o zsh puro, sem herdr. A detecção usa
  a env var `GUAKE_TAB_UUID` e, como fallback, sobe a árvore de processos via
  `/proc` procurando `guake`/`yakuake`.
- Após editar `config/herdr/config.toml`, recarregue dentro do herdr com
  **`prefix + Shift + r`**, ou rode `herdr server reload-config` em qualquer
  painel.

> **Por que `prefix + Alt + d` para lazydocker?** O `prefix + Shift + d` colide
> com `close_workspace`, e `prefix + Shift + [hjkl]` colidem com os 4
> `swap_pane_*`. `prefix + Alt + d` é o atalho livre mais próximo do
> mnemônico.

## kitty

- Tema ativo em `current-theme.conf` (o kitty regrava esse arquivo ao trocar tema).
- A imagem de fundo (`background_image`) aponta para `~/.config/kitty/3.png`, que
  o `install.sh` symlinka a partir de `config/kitty/3.png` no repo. Para trocar a
  imagem, substitua esse arquivo no repo.
- **Legibilidade do fundo (`background_tint`).** Controla o quanto a imagem
  aparece: `0` = imagem em força total (atrapalha o texto), `1` = bem apagada.
  Usamos **`0.85`** (imagem suave, texto legível). O kitty aplica o
  `dark-theme.auto.conf` automaticamente no modo escuro do SO, e esse arquivo
  sobrescreveria o tint do `kitty.conf` — por isso o `background_tint` está
  padronizado em `0.85` no `kitty.conf` **e** em cada arquivo de tema
  (`current-theme.conf`, `dark-theme.auto.conf`). Para deixar a imagem mais ou
  menos visível, ajuste o **mesmo** valor nos três lugares. Ao adicionar um tema novo, copie-as para lá também.

## nvim

Config baseada em lazy.nvim, versionada inteira em `config/nvim/` e symlinkada
para `~/.config/nvim/` (atalhos em `lua/config/keymaps.lua`, plugins em
`lua/plugins/`). O `lazy-lock.json` fixa as versões dos plugins. Na primeira vez
que abrir o `nvim` numa máquina nova, o lazy.nvim baixa os plugins
automaticamente (ou rode `:Lazy sync`).

## lazygit

Tema com a paleta do kitty (laranja/roxo) e interface focada, em
`config/lazygit/config.yml` → `~/.config/lazygit/config.yml`.

- **`expandFocusedSidePanel: true`** — o painel em foco domina a tela e os demais
  encolhem; navegando com `2` (Files), `3` (Branches) e `4` (Commits) você vê
  praticamente só o painel relevante. O lazygit **não** permite esconder os
  painéis Status (`1`) e Stash (`5`) da barra — isso é o mais perto disso.
- **`showCommandLog: false`** — esconde o log de comandos (interface mais limpa).
- **`nerdFontsVersion: "3"`** — ícones (usa a FiraCode Nerd Font).

Para mudar as cores, edite o bloco `gui.theme`. Abrir: alias `lg` (do `.zshrc`)
ou, dentro do herdr, `prefix + Shift + g` (popup flutuante).

## Atualizar uma máquina já configurada

Os atalhos de kitty/herdr/nvim moram nos arquivos versionados. Para puxar as
mudanças numa máquina que já rodou o instalador:

```bash
cd ~/dotfiles && git pull && ./install.sh link
```

Depois recarregue cada app (os atalhos novos só valem após o reload):
- **kitty**: `Ctrl+Shift+F5` (ou feche/reabra a janela)
- **herdr**: `prefix + Shift + r` (recarrega `config.toml`) ou `herdr server reload-config`
- **nvim**: reabra; se necessário, `:Lazy sync`

## Portabilidade

Os caminhos usam `~`/`$HOME` (sem nome de usuário fixo), então funcionam em
qualquer máquina/usuário:

- O Homebrew é detectado automaticamente conforme o SO (Linux `/home/linuxbrew`,
  macOS ARM `/opt/homebrew`, macOS Intel `/usr/local`).
- A imagem de fundo do kitty é versionada em `config/kitty/3.png` e symlinkada
  para `~/.config/kitty/3.png` (o `kitty.conf` aponta para lá). Assim ela viaja
  junto com a config — sem depender de `~/Pictures`.

## Copiar/colar (kitty + herdr)

- Como o `~/.zshrc` entra no herdr automaticamente e o herdr captura o mouse,
  arrastar o mouse seleciona dentro do **herdr** (copy-mode), não do kitty.
- Para copiar no Wayland é preciso o `wl-clipboard` (o `install.sh` já instala);
  o herdr e o kitty o utilizam para escrever no clipboard.
- Atalhos: copiar `Ctrl+Shift+C`, colar `Ctrl+Shift+V`, colar seleção `Shift+Insert`.
- Para selecionar ignorando o herdr (direto no kitty), segure **Shift** ao arrastar.

## Pontos a instalar/configurar à parte

- `_awspp` é instalado em `/usr/local/bin` pelo pacote `awsp` (o `install.sh`
  instala via `npm`/`bun`); a cópia em `bin/` é só referência.
- 1Password (agente SSH em `~/.1password/agent.sock`) precisa ser instalado à parte.
