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
│   └── kitty/                 # vai para ~/.config/kitty/
│       ├── kitty.conf
│       ├── current-theme.conf
│       └── dark-theme.auto.conf
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
./install.sh link       # só recria os symlinks dos dotfiles
./install.sh tools      # só ferramentas (não mexe no apt)
SKIP_APT=1 ./install.sh # pula a etapa de apt
```

O script é **idempotente** (pode rodar de novo) e faz **backup** de qualquer
arquivo existente em `~/.dotfiles-backup/<timestamp>/` antes de criar os symlinks.

## O que é instalado

| Categoria        | Itens |
|------------------|-------|
| Pacotes do SO    | zsh, tmux, kitty, eza, openfortivpn, git, curl, jq, wl-clipboard, xclip, fd, fontconfig, build-essential (via apt no Debian/Ubuntu ou pacman no Arch — nomes ajustados por distro) |
| Shell            | Oh My Zsh, Powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting |
| Ferramentas      | fzf, atuin, opencode, awsp |
| Homebrew         | asdf, fd, lazygit, neovim, charmbracelet/tap/crush |
| asdf (.tool-versions) | awscli, bun, gcloud, helm, k3d, k9s, kubectl, kubectx, nodejs, terraform, terragrunt, tf-summarize, velero |
| tmux             | TPM + tmux-sensible, tmux-yank, tmux-resurrect, tmux-continuum |
| Fonte            | FiraCode Nerd Font |

## tmux

- Prefixo trocado para **Ctrl-a**.
- Após instalar, finalize os plugins dentro do tmux com **prefixo + I**.
- A barra superior mostra git/aws/kube/terraform/gcloud (via `.tmux-statusline.zsh`)
  e o uso do Claude Code (via `.tmux-claude-usage.sh`).
- O `~/.zshrc` anexa automaticamente à sessão `main` em terminais interativos
  (exceto no terminal integrado do VS Code).

## kitty

- Tema ativo em `current-theme.conf` (o kitty regrava esse arquivo ao trocar tema).
- O `kitty.conf` aponta para uma imagem de fundo em `~/Pictures/3.png` — ajuste o
  caminho ou remova a linha `background_image` se a imagem não existir.

## Portabilidade

Os caminhos usam `~`/`$HOME` (sem nome de usuário fixo), então funcionam em
qualquer máquina/usuário:

- O Homebrew é detectado automaticamente conforme o SO (Linux `/home/linuxbrew`,
  macOS ARM `/opt/homebrew`, macOS Intel `/usr/local`).
- O `kitty.conf` usa `~/Pictures/3.png` na imagem de fundo. O kitty expande `~`
  em `background_image`; no `map f9 ... set-background-image` o `~` pode não ser
  expandido em todos os builds — ajuste se a imagem não carregar por esse atalho.

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
