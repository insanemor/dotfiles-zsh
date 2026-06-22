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

    # --- git (branch + ahead/behind + dirty) ---
    # git status -sbunormal: por-branch, sem submodules, untracked visivel
    # (omite o `untracked` na flag NAO mostra os "??", o que esvazia o contador).
    # ~2ms em repo local; roda em &! no precmd, entao nao trava o prompt.
    local gi
    gi=$(command git status -sbunormal 2>/dev/null) || gi=""
    if [[ -n $gi ]]; then
      # primeira linha: "## <branch>..." ou "## <hash>... [ahead N, behind M]"
      local gb
      gb=$(printf '%s' "$gi" | head -1)
      gb=${gb##*## }            # tira o "## "
      gb=${gb%%...*}             # tira "...origin/X" pra mostrar so o branch local
      out+="#[fg=#9dff6e]${_TMUX_ICON_GIT} ${gb}#[default]"

      # ahead/behind: a parte entre [...] na primeira linha
      local ab
      ab=$(printf '%s' "$gi" | head -1 | grep -oE '\[.*\]' | head -1)
      if [[ -n $ab ]]; then
        # "ahead 2, behind 1" -> icones coloridos
        local a b
        a=$(printf '%s' "$ab" | grep -oE 'ahead [0-9]+' | grep -oE '[0-9]+')
        b=$(printf '%s' "$ab" | grep -oE 'behind [0-9]+' | grep -oE '[0-9]+')
        [[ -n $a && $a -gt 0 ]] && out+=" #[fg=#efc11a]↑${a}#[default]"
        [[ -n $b && $b -gt 0 ]] && out+=" #[fg=#fc5e59]↓${b}#[default]"
      fi

      # arquivos modificados. Formato de `git status -sbunormal`:
      #   "XY foo"   -> X = index (staged), Y = worktree (unstaged), espacos se ausentes
      #   "?? foo"   -> untracked
      # awk (NR>1) pula a linha de branch. awk eh mais robusto que grep
      # pra contar linhas com regex contendo '?[]' (globs do shell).
      local staged unstaged untracked
      staged=$(printf '%s' "$gi" | awk 'NR>1 && /^[MDARC] / {n++} END{print n+0}')
      unstaged=$(printf '%s' "$gi" | awk 'NR>1 && /^.[MDARC] / {n++} END{print n+0}')
      untracked=$(printf '%s' "$gi" | awk 'NR>1 && /^[?][?] / {n++} END{print n+0}')
      [[ -n $staged   && $staged   -gt 0 ]] && out+=" #[fg=#9dff6e]+${staged}#[default]"
      [[ -n $unstaged && $unstaged -gt 0 ]] && out+=" #[fg=#efc11a]!${unstaged}#[default]"
      [[ -n $untracked&& $untracked -gt 0 ]] && out+=" #[fg=#c39df5]?${untracked}#[default]"
      out+="   "
    fi

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
