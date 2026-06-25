# dotfiles

Meus dotfiles (zsh + kitty + tmux) e um script de bootstrap para reinstalar
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
│   ├── .tmux.conf
│   ├── .tmux-statusline.zsh   # contexto (git/aws/kube/tf/gcloud) na barra do tmux
│   ├── .tmux-claude-usage.sh  # uso do Claude Code na barra do tmux
│   ├── .claude-statusline.sh  # statusLine do Claude Code (alimenta o item acima)
│   └── .tool-versions         # versões geridas pelo asdf
├── config/
│   ├── kitty/                 # vai para ~/.config/kitty/
│   │   ├── kitty.conf
│   │   ├── current-theme.conf
│   │   ├── dark-theme.auto.conf
│   │   └── 3.png              # imagem de fundo (versionada junto da config)
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
| tmux             | TPM + tmux-sensible, tmux-yank, tmux-resurrect, tmux-continuum |
| nvim             | config completa (init.lua + lua/) + lazy-lock.json → ~/.config/nvim |
| lazygit          | tema (laranja/roxo, combina com o kitty) + layout focado → ~/.config/lazygit |
| Claude Code      | hooks de notificação (Stop/Notification) → notify-send + bell no tmux |
| Headroom         | compression proxy + MCP server (instalado via `uv tool`; usado pelo Claude Code e pelo Crush/MiniMax) |
| Fonte            | FiraCode Nerd Font |

## Notificações do Claude Code

`claude/hooks/claude-notify.sh` dispara em dois eventos do Claude Code:

- **Stop** — quando o Claude termina de responder.
- **Notification** — quando o Claude está aguardando você (permissão/input).

Em cada evento faz duas coisas:
1. `notify-send` — notificação no desktop Linux (quando você está na máquina).
2. Um **bell** escrito no tty do painel ativo do tmux — atravessa o tmux e o
   SSH, tocando/piscando tanto no kitty quanto no Windows Terminal (acesso remoto).

O `install.sh` cria o symlink em `~/.claude/hooks/` e faz um **merge idempotente**
dos hooks em `~/.claude/settings.json` (preserva o resto das suas configs). Após
instalar numa máquina nova, rode `/hooks` no Claude Code (ou reinicie) para
recarregar a config. Para o bell aparecer no Windows Terminal, ajuste o
`bellStyle` no perfil (ex.: `"window"` ou `"taskbar"`).

## Headroom (compression proxy + MCP)

[Headroom](https://github.com/headroomlabs-ai/headroom) é um proxy local que
comprime tool outputs / logs / RAG / arquivos **antes** de chegarem no LLM
(60–95% menos tokens, respostas equivalentes) e expõe um MCP server para o
modelo recuperar o conteúdo original sob demanda (CCR). Funciona com qualquer
cliente OpenAI/Anthropic-compatível, então dá para usar tanto com o **Claude
Code** quanto com o **Crush** apontando para a MiniMax.

Instalação e uso:

```bash
# 1) instalar (já faz parte do ./install.sh)
uv tool install "headroom-ai[all]"

# 2) registrar o MCP no Claude Code (idempotente)
headroom mcp install

# 3a) Claude Code: rodar com o proxy
ANTHROPIC_BASE_URL=http://127.0.0.1:8787 claude
# ou, de forma resumida, o wrapper oficial:
headroom wrap claude
# atalhos do .zshrc: hr, hrw, hrp, hrs

# 3b) Crush / MiniMax: o provider 'minimax-hr' em crush.json
# já aponta para http://127.0.0.1:8787/v1 e o proxy encaminha para
# https://api.minimax.io/v1 (OPENAI_TARGET_API_URL). É só manter
# 'headroom proxy' em execução e usar o crush normalmente.

# 4) acompanhar a economia
headroom perf     # relatório agregado
headroom stats    # snapshot ao vivo
curl -s http://127.0.0.1:8787/stats | jq
```

O `install.sh` (`step_headroom`) deixa o proxy rodando em background em
`http://127.0.0.1:8787` (log em `~/.cache/headroom/proxy.log`) e registra o
MCP server no Claude Code. O `.zshrc` auto-inicia o proxy na primeira seção
de shell caso ele não esteja de pé, e expõe os atalhos `hr` / `hrw` / `hrp` /
`hrs`. Para ativar o corte de tokens de output (5x mais caro em Opus):

```bash
export HEADROOM_OUTPUT_SHAPER=1
headroom proxy --port 8787
```

## tmux

- Prefixo trocado para **Ctrl-a**.
- Após instalar, finalize os plugins dentro do tmux com **prefixo + I**.
- A barra superior mostra git/aws/kube/terraform/gcloud (via `.tmux-statusline.zsh`)
  e o uso do Claude Code (via `.tmux-claude-usage.sh`).
- O `~/.zshrc` anexa automaticamente à sessão `main` em terminais interativos
  (exceto no terminal integrado do VS Code).

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
ou, dentro do tmux, `Ctrl-a` + `G` (popup flutuante).

## Atualizar uma máquina já configurada

Os atalhos de kitty/tmux/nvim moram nos arquivos versionados. Para puxar as
mudanças numa máquina que já rodou o instalador:

```bash
cd ~/dotfiles && git pull && ./install.sh link
```

Depois recarregue cada app (os atalhos novos só valem após o reload):
- **kitty**: `Ctrl+Shift+F5` (ou feche/reabra a janela)
- **tmux**: `Ctrl-a` + `r` (recarrega o `.tmux.conf`)
- **nvim**: reabra; se necessário, `:Lazy sync`

## Portabilidade

Os caminhos usam `~`/`$HOME` (sem nome de usuário fixo), então funcionam em
qualquer máquina/usuário:

- O Homebrew é detectado automaticamente conforme o SO (Linux `/home/linuxbrew`,
  macOS ARM `/opt/homebrew`, macOS Intel `/usr/local`).
- A imagem de fundo do kitty é versionada em `config/kitty/3.png` e symlinkada
  para `~/.config/kitty/3.png` (o `kitty.conf` aponta para lá). Assim ela viaja
  junto com a config — sem depender de `~/Pictures`.

## Copiar/colar (kitty + tmux)

- Como o `~/.zshrc` entra no tmux automaticamente e o tmux usa `mouse on`,
  arrastar o mouse seleciona dentro do **tmux** (copy-mode), não do kitty.
- Para copiar no Wayland é preciso o `wl-clipboard` (o `install.sh` já instala);
  o `tmux-yank` e o kitty o utilizam para escrever no clipboard.
- Atalhos: copiar `Ctrl+Shift+C`, colar `Ctrl+Shift+V`, colar seleção `Shift+Insert`.
- Para selecionar ignorando o tmux (direto no kitty), segure **Shift** ao arrastar.

## Pontos a instalar/configurar à parte

- `_awspp` é instalado em `/usr/local/bin` pelo pacote `awsp` (o `install.sh`
  instala via `npm`/`bun`); a cópia em `bin/` é só referência.
- 1Password (agente SSH em `~/.1password/agent.sock`) precisa ser instalado à parte.
