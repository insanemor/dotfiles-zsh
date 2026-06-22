# ~/.tmux-statusline.zsh
# =====================================================================
#  Publica o contexto do shell (git, aws, kube, terraform, gcloud,
#  venv e versoes) numa opcao do tmux (@env_info), exibida na barra
#  superior. Roda em BACKGROUND (&!) para nao travar o prompt do zsh.
#  Reflete sempre o painel ativo (onde o ultimo prompt rodou).
# =====================================================================

# Icones Nerd Font (o zsh expande \u em runtime -> glifo real)
typeset -g _TMUX_ICON_GIT=$''    # branch
typeset -g _TMUX_ICON_K8S=$'☸'    # ☸
typeset -g _TMUX_ICON_NODE=$'⬢'   # ⬢
typeset -g _TMUX_ICON_PY=$''     # python

_tmux_refresh_env() {
  [[ -n $TMUX ]] || return
  {
    emulate -L zsh
    local out=""

    # --- git (branch ou hash curto) ---
    local gb
    gb=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) \
      || gb=$(command git rev-parse --short HEAD 2>/dev/null)
    [[ -n $gb ]] && out+="#[fg=#9dff6e]${_TMUX_ICON_GIT} ${gb}#[default]   "

    # --- kubernetes (le do ~/.kube/config, instantaneo) ---
    local kc
    kc=$(command awk '/^current-context:/{print $2; exit}' ~/.kube/config 2>/dev/null)
    kc=${kc##*cluster/}   # ARN do EKS -> mostra so o nome do cluster
    [[ -n $kc ]] && out+="#[fg=#c39df5]${_TMUX_ICON_K8S} ${kc}#[default]   "

    # --- terraform workspace ---
    if [[ -f .terraform/environment ]]; then
      local tw; tw=$(<.terraform/environment)
      out+="#[fg=#b48ead]tf:${tw}#[default]   "
    fi

    # --- aws profile (variavel de ambiente do shell) ---
    local awsp=${AWS_PROFILE:-${AWS_VAULT:-$AWS_DEFAULT_PROFILE}}
    [[ -n $awsp ]] && out+="#[fg=#ff9738]aws:${awsp}#[default]   "

    # --- gcloud project (le do arquivo de config ativo, instantaneo) ---
    local gcfg=~/.config/gcloud/active_config
    if [[ -f $gcfg ]]; then
      local gname; gname=$(<$gcfg)
      local gproj; gproj=$(command awk -F'= ' '/^project/{print $2; exit}' \
        ~/.config/gcloud/configurations/config_${gname} 2>/dev/null)
      [[ -n $gproj ]] && out+="#[fg=#4aa0ff]gcp:${gproj}#[default]   "
    fi

    # --- python venv (variavel de ambiente) ---
    [[ -n $VIRTUAL_ENV ]] && out+="#[fg=#6fa497](${VIRTUAL_ENV:t})#[default]   "

    # --- node (apenas em projeto node) ---
    if [[ -f package.json ]]; then
      local nv; nv=$(command node -v 2>/dev/null)
      [[ -n $nv ]] && out+="#[fg=#9dff6e]${_TMUX_ICON_NODE} ${nv}#[default]   "
    fi

    # --- python version (quando relevante) ---
    if [[ -n $VIRTUAL_ENV || -f .python-version ]]; then
      local pv; pv=$(command python3 --version 2>/dev/null)
      [[ -n $pv ]] && out+="#[fg=#6fa497]${_TMUX_ICON_PY} ${pv#Python }#[default]   "
    fi

    command tmux set -g @env_info "$out" 2>/dev/null
    command tmux refresh-client -S 2>/dev/null
  } &!
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _tmux_refresh_env
