#!/usr/bin/env bash
# =====================================================================
#  install.sh — bootstrap dos dotfiles (zsh)
#
#  Distros suportadas: Ubuntu/Debian (apt) e Arch (pacman).
#  Reinstala tudo que compõe este ambiente e cria os symlinks dos
#  arquivos de config para o $HOME. É idempotente: rodar de novo só
#  completa o que estiver faltando.
#
#  Uso:
#    ./install.sh             # tudo (pacotes + ferramentas + symlinks)
#    ./install.sh link        # só recria os symlinks dos dotfiles
#    ./install.sh tools       # só ferramentas (sem mexer nos pacotes do SO)
#    SKIP_PKGS=1 ./install.sh # pula a etapa de pacotes do SO (precisa de sudo)
# =====================================================================
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# --- helpers -------------------------------------------------------
c_blue='\033[1;34m'; c_yellow='\033[1;33m'; c_green='\033[1;32m'; c_red='\033[1;31m'; c_off='\033[0m'
log()  { printf "${c_blue}==>${c_off} %s\n" "$*"; }
ok()   { printf "${c_green}  ok${c_off} %s\n" "$*"; }
warn() { printf "${c_yellow}  !!${c_off} %s\n" "$*"; }
err()  { printf "${c_red} ERRO${c_off} %s\n" "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# Carrega o Homebrew no shell atual, se já estiver instalado
load_brew() {
  if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

# Cria um symlink apontando $2 -> $1, fazendo backup do que existir
link() {
  local src="$1" dst="$2"
  [ -e "$src" ] || { warn "fonte ausente, pulando: $src"; return; }
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    ok "link já correto: $dst"; return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR$(dirname "${dst#$HOME}")"
    mv "$dst" "$BACKUP_DIR${dst#$HOME}"
    warn "backup: $dst -> $BACKUP_DIR${dst#$HOME}"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "link: $dst -> $src"
}

# =====================================================================
#  1) Pacotes de sistema — detecta apt (Debian/Ubuntu) ou pacman (Arch)
#     Os nomes de alguns pacotes diferem entre as distros:
#       fd-find/fd · build-essential/base-devel · procps/procps-ng
# =====================================================================
step_pkgs() {
  [ "${SKIP_PKGS:-0}" = "1" ] && { warn "SKIP_PKGS=1, pulando pacotes do SO"; return; }
  if have apt-get; then
    log "Instalando pacotes de sistema (apt)…"
    sudo apt-get update -y
    sudo apt-get install -y \
      zsh tmux kitty eza openfortivpn \
      git curl wget unzip jq \
      wl-clipboard xclip libnotify-bin \
      fd-find fontconfig build-essential procps file
  elif have pacman; then
    log "Instalando pacotes de sistema (pacman)…"
    # -Syu evita partial upgrade (recomendação do Arch); --needed pula o que já existe
    sudo pacman -Syu --needed --noconfirm \
      zsh tmux kitty eza openfortivpn \
      git curl wget unzip jq \
      wl-clipboard xclip libnotify \
      fd fontconfig base-devel procps-ng file
  else
    warn "nenhum gerenciador suportado (apt/pacman) encontrado; instale os pacotes à mão e rode: ./install.sh tools"
    return
  fi
  # zsh como shell padrão
  if [ "$SHELL" != "$(command -v zsh)" ]; then
    log "Definindo zsh como shell padrão (pede senha)…"
    chsh -s "$(command -v zsh)" || warn "não consegui trocar o shell (faça: chsh -s \$(which zsh))"
  fi
}

# =====================================================================
#  2) Oh My Zsh + tema p10k + plugins custom
# =====================================================================
step_omz() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Instalando Oh My Zsh…"
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || warn "falha no omz"
  else
    ok "Oh My Zsh já instalado"
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  clone_or_pull() { # $1 url  $2 dest
    if [ -d "$2" ]; then ok "já presente: $(basename "$2")"; else
      log "clonando $(basename "$2")…"; git clone --depth=1 "$1" "$2" || warn "falha ao clonar $1"
    fi
  }
  clone_or_pull https://github.com/romkatv/powerlevel10k.git              "$custom/themes/powerlevel10k"
  clone_or_pull https://github.com/zsh-users/zsh-autosuggestions.git      "$custom/plugins/zsh-autosuggestions"
  clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting.git  "$custom/plugins/zsh-syntax-highlighting"
}

# =====================================================================
#  3) fzf (instalação por git, como no ~/.fzf.zsh)
# =====================================================================
step_fzf() {
  if [ -d "$HOME/.fzf" ]; then ok "fzf já instalado (~/.fzf)"; return; fi
  log "Instalando fzf…"
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" \
    && "$HOME/.fzf/install" --key-bindings --completion --no-update-rc || warn "falha no fzf"
}

# =====================================================================
#  4) Atuin (histórico de shell)
# =====================================================================
step_atuin() {
  if [ -x "$HOME/.atuin/bin/atuin" ] || have atuin; then ok "atuin já instalado"; return; fi
  log "Instalando atuin…"
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || warn "falha no atuin"
}

# =====================================================================
#  5) Homebrew + pacotes do brew
# =====================================================================
step_brew() {
  if ! have brew && [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    log "Instalando Homebrew…"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || warn "falha no brew"
  else
    ok "Homebrew já instalado"
  fi
  load_brew
  have brew || { warn "brew indisponível, pulando pacotes brew"; return; }
  log "Instalando pacotes brew (asdf, fd, lazygit, neovim, crush)…"
  brew install asdf fd lazygit neovim || warn "alguns pacotes brew falharam"
  brew install charmbracelet/tap/crush || warn "falha ao instalar crush"
}

# =====================================================================
#  6) asdf: plugins + versões do .tool-versions
# =====================================================================
step_asdf() {
  load_brew
  have asdf || { warn "asdf não disponível, pulando"; return; }
  local tv="$DOTFILES_DIR/home/.tool-versions"
  [ -f "$tv" ] || { warn ".tool-versions não encontrado"; return; }
  log "Adicionando plugins do asdf…"
  # plugins extras de URL conhecida; os demais o asdf resolve pelo nome
  declare -A urls=(
    [bun]=https://github.com/cometkim/asdf-bun.git
    [kubectx]=https://github.com/virtualstaticvoid/asdf-kubectx.git
    [tf-summarize]=https://github.com/adamcrews/asdf-tf-summarize.git
  )
  awk '{print $1}' "$tv" | while read -r p; do
    [ -z "$p" ] && continue
    if asdf plugin list 2>/dev/null | grep -qx "$p"; then
      ok "plugin já existe: $p"
    else
      asdf plugin add "$p" "${urls[$p]:-}" >/dev/null 2>&1 && ok "plugin add: $p" || warn "falha no plugin: $p"
    fi
  done
  log "Instalando versões do .tool-versions (pode demorar)…"
  ( cd "$HOME" && cp "$tv" "$HOME/.tool-versions" && asdf install ) || warn "asdf install teve falhas"
}

# =====================================================================
#  7) opencode + awsp (profile switcher) + pacotes npm do .tool-versions
#     Entradas com sufixo "# npm" em .tool-versions são instaladas via
#     `npm i -g` (ex.: tree-sitter-cli). Mantém o versionamento junto
#     com as demais ferramentas.
# =====================================================================
step_npm_tools() {
  local tv="$DOTFILES_DIR/home/.tool-versions"
  [ -f "$tv" ] || { warn ".tool-versions não encontrado"; return; }
  if ! have npm; then warn "npm ausente, pulando pacotes npm do .tool-versions"; return; fi
  log "Instalando pacotes npm versionados em .tool-versions…"
  # formato: "<nome> <versão>  # npm"  (versão pode ficar vazia -> latest)
  awk 'NF>=2 && tolower($3)=="#npm" {print $1"@"$2}' "$tv" | while read -r spec; do
    [ -z "$spec" ] && continue
    if npm ls -g "$spec" >/dev/null 2>&1; then
      ok "já instalado: $spec"
    else
      log "npm i -g $spec"
      npm i -g "$spec" >/dev/null 2>&1 && ok "instalado: $spec" \
        || warn "falha ao instalar $spec"
    fi
  done
}

step_extras() {
  if [ -x "$HOME/.opencode/bin/opencode" ] || have opencode; then
    ok "opencode já instalado"
  else
    log "Instalando opencode…"
    curl -fsSL https://opencode.ai/install | bash || warn "falha no opencode"
  fi

  load_brew
  # awsp: o ~/.zshrc usa `alias awsp="source _awspp"` (binário _awspp no PATH)
  if have _awspp; then
    ok "awsp (_awspp) já presente"
  elif have npm || have bun; then
    log "Instalando awsp (aws profile switcher)…"
    { have bun && bun install -g awsp; } || npm install -g awsp || warn "falha no awsp"
  else
    warn "npm/bun ausentes; instale o awsp depois com: npm i -g awsp"
  fi
}

# =====================================================================
#  8) Fonte FiraCode Nerd Font
# =====================================================================
step_font() {
  if fc-list 2>/dev/null | grep -qi "FiraCode Nerd Font"; then ok "FiraCode Nerd Font já instalada"; return; fi
  log "Instalando FiraCode Nerd Font…"
  local dir="$HOME/.local/share/fonts" tmp
  mkdir -p "$dir"; tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/FiraCode.zip" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip; then
    unzip -oq "$tmp/FiraCode.zip" -d "$dir" && fc-cache -f >/dev/null 2>&1 && ok "fonte instalada"
  else
    warn "falha ao baixar a fonte"
  fi
  rm -rf "$tmp"
}

# =====================================================================
#  9) TPM + plugins do tmux
# =====================================================================
step_tmux() {
  local tpm="$HOME/.tmux/plugins/tpm"
  if [ -d "$tpm" ]; then ok "TPM já instalado"; else
    log "Instalando TPM…"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm" || warn "falha no TPM"
  fi
  if [ -d "$tpm" ] && have tmux; then
    log "Instalando plugins do tmux…"
    "$tpm/bin/install_plugins" >/dev/null 2>&1 && ok "plugins do tmux instalados" \
      || warn "rode dentro do tmux: prefixo + I"
  fi
}

# =====================================================================
#  10) Symlinks dos dotfiles
# =====================================================================
step_link() {
  log "Criando symlinks dos dotfiles…"
  # arquivos diretos no $HOME
  local f
  for f in "$DOTFILES_DIR"/home/.[!.]*; do
    [ -e "$f" ] || continue
    link "$f" "$HOME/$(basename "$f")"
  done
  # ~/.config/...
  link "$DOTFILES_DIR/config/kitty/kitty.conf"           "$HOME/.config/kitty/kitty.conf"
  link "$DOTFILES_DIR/config/kitty/current-theme.conf"   "$HOME/.config/kitty/current-theme.conf"
  link "$DOTFILES_DIR/config/kitty/dark-theme.auto.conf" "$HOME/.config/kitty/dark-theme.auto.conf"
  link "$DOTFILES_DIR/config/kitty/3.png"                "$HOME/.config/kitty/3.png"
  # ~/.config/nvim (config + atalhos do neovim) — symlink do diretório inteiro
  link "$DOTFILES_DIR/config/nvim"                       "$HOME/.config/nvim"
  # ~/.claude/ (hook de notificação)
  link "$DOTFILES_DIR/claude/hooks/claude-notify.sh"     "$HOME/.claude/hooks/claude-notify.sh"
}

# =====================================================================
#  11) Hooks de notificação do Claude Code (merge idempotente)
#      Garante os hooks Stop/Notification no ~/.claude/settings.json
#      sem destruir o restante das configs pessoais.
# =====================================================================
step_claude_hooks() {
  have jq || { warn "jq ausente, pulando hooks do Claude"; return; }
  local s="$HOME/.claude/settings.json" tmp
  mkdir -p "$HOME/.claude/hooks"
  [ -f "$s" ] || echo '{}' > "$s"
  tmp="$(mktemp)"
  if jq --arg stop '$HOME/.claude/hooks/claude-notify.sh stop' \
        --arg notif '$HOME/.claude/hooks/claude-notify.sh notification' '
        def ensure($event; $cmd):
          .hooks[$event] = ((.hooks[$event] // []) as $arr
            | if ($arr | tostring | contains("claude-notify.sh"))
              then $arr
              else $arr + [{hooks:[{type:"command", command:$cmd, timeout:5}]}]
              end);
        ensure("Stop"; $stop) | ensure("Notification"; $notif)
      ' "$s" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$s"; ok "hooks de notificação garantidos em ~/.claude/settings.json"
  else
    rm -f "$tmp"; warn "não consegui atualizar os hooks do Claude (settings.json malformado?)"
  fi
}

# =====================================================================
#  main
# =====================================================================
main() {
  case "${1:-all}" in
    link)  step_link; step_claude_hooks ;;
    tools) step_omz; step_fzf; step_atuin; step_brew; step_asdf; step_npm_tools; step_extras; step_font; step_tmux ;;
    all)
      step_pkgs
      step_omz
      step_fzf
      step_atuin
      step_brew
      step_asdf
      step_npm_tools
      step_extras
      step_font
      step_tmux
      step_link
      step_claude_hooks
      ;;
    *) echo "uso: $0 [all|link|tools]"; exit 1 ;;
  esac
  echo
  log "Concluído. Abra um novo terminal (zsh)."
  [ -d "$BACKUP_DIR" ] && warn "arquivos substituídos foram salvos em: $BACKUP_DIR"
  echo "Notas:"
  echo "  • Dentro do tmux, finalize os plugins com: prefixo (Ctrl-a) + I"
  echo "  • O kitty.conf referencia uma imagem de fundo (~/Pictures/3.png) — ajuste se faltar."
  echo "  • Notificações do Claude: rode /hooks no Claude Code (ou reinicie) p/ recarregar."
  echo "  • 1Password (agente SSH em ~/.1password/agent.sock) deve ser instalado à parte."
}

main "$@"
