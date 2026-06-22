# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="alanpeabody"

plugins=(
    git
    history-substring-search
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    web-search
    copyfile
    copybuffer
    dirhistory
    jsontools
    command-not-found
    dircycle
)

source $ZSH/oh-my-zsh.sh
source $HOME/.oh-my-zsh/custom/themes/powerlevel10k
source $HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Usaado somentee em maquiinas fisicas com linux 
#setxkbmap -model pc104 -layout us_intl

######################################################################################################################################### alias personalizados

## apps abreviados
alias k="kubectl"
alias tf="terraform"
alias tg="terragrunt"
alias ns="kubens"
alias kx="kubectx"
alias kvu="kubectl view-utilization -h"
# lazygit: TUI de git estilo Source Control (stage/commit/push tudo via teclado)
alias lg="lazygit"
# eza (substituto moderno do ls): icons, grid e diretorios primeiro
alias ls="eza --icons --grid --group-directories-first"
alias ll="eza --icons --long --group-directories-first"
alias la="eza --icons --grid --group-directories-first --all"
alias lt="eza --icons --tree --group-directories-first --level=2"

# # show all the history stored.
# alias history="fc -l 1"


##############################################################################################################   app instalados

# fzf + fd: binário é 'fdfind' no Debian/Ubuntu e 'fd' no Arch/Homebrew
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f'
elif command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f'
fi
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info --height=80%"

# AWSP
alias awsp="source _awspp"

# Homebrew — detecta o caminho conforme o SO (Linux / macOS ARM / macOS Intel)
for _brew in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [ -x "$_brew" ] && eval "$("$_brew" shellenv)" && break
done
unset _brew

# asdf (Homebrew) — shims antes do PATH do sistema para priorizar versões do asdf
export ASDF_DIR="$(brew --prefix asdf)/libexec"
. "$ASDF_DIR/asdf.sh"
export PATH="$HOME/.asdf/shims:$PATH"

# Invert o terminal para ficar sempre para baixo 
print ${(pl:$LINES::\n:):-}


SSH_AUTH_SOCK=~/.1password/agent.sock

##########################################################################################################################################

# VPN

alias vpninterna="sudo openfortivpn -c ~/.openfortivpn/config"

# ##########################################################################################################################################

# Atuin


export ATUIN_NOBIND="true"
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
bindkey '^r' atuin-up-search-viins

##########################################################################################################################################

# Gcloud

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# bun (ccusage e outros binarios globais)
export PATH="$HOME/.bun/bin:$PATH"

##########################################################################################################################################

# tmux: inicia/anexa automaticamente a sessao "main" em terminais interativos.
# Guards: so em shell interativo, fora de outro tmux e fora do terminal do VSCode.
# Para DESATIVAR, basta comentar este bloco.
if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && command -v tmux >/dev/null; then
  tmux attach -t main 2>/dev/null || tmux new -s main
fi

# tmux: publica contexto (git/aws/kube/tf/gcloud/versoes) na barra superior
# e expoe o nome da sessao pro prompt do p10k (segmento tmux_session).
if [[ -n "$TMUX" ]]; then
  export _P9K_TMUX_SESSION=$(tmux display-message -p '#S' 2>/dev/null)
  [[ -f ~/.tmux-statusline.zsh ]] && source ~/.tmux-statusline.zsh
fi
