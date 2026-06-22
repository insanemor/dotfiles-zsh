#!/usr/bin/env bash
# =====================================================================
#  statusLine do Claude Code.
#  - Recebe um JSON via stdin (dados da sessao do Claude Code).
#  - Extrai os rate limits OFICIAIS (5h e 7d) e grava num arquivo
#    para a barra do tmux ler (~/.cache/claude/usage.json).
#  - Tambem imprime uma linha de status para o proprio Claude Code.
#  - Salva o JSON cru em ~/.cache/claude/statusline-input.json para
#    validacao/depuracao da estrutura.
# =====================================================================
input=$(cat)

CACHE_DIR="$HOME/.cache/claude"
mkdir -p "$CACHE_DIR"

# 1) salva o JSON cru (debug/validacao)
printf '%s' "$input" > "$CACHE_DIR/statusline-input.json"

# 2) extrai os campos (tab-separated; campos ausentes ficam vazios)
IFS=$'\t' read -r model h5 h5r d7 d7r ctx < <(
  printf '%s' "$input" | jq -r '
    [ (.model.display_name // "Claude"),
      (.rate_limits.five_hour.used_percentage // ""),
      (.rate_limits.five_hour.resets_at // ""),
      (.rate_limits.seven_day.used_percentage // ""),
      (.rate_limits.seven_day.resets_at // ""),
      (.context_window.used_percentage // "")
    ] | @tsv' 2>/dev/null
)

# 3) grava os dados p/ o tmux (JSON simples)
jq -n \
  --arg h5 "${h5:-}" --arg h5r "${h5r:-}" \
  --arg d7 "${d7:-}" --arg d7r "${d7r:-}" \
  --arg ctx "${ctx:-}" \
  '{five_hour_pct:$h5, five_hour_reset:$h5r,
    seven_day_pct:$d7, seven_day_reset:$d7r,
    context_pct:$ctx, updated:(now|floor)}' \
  > "$CACHE_DIR/usage.json" 2>/dev/null

# 4) imprime a status line do proprio Claude Code
out="$model"
[ -n "${h5:-}" ] && out="$out  5h:$(printf '%.0f' "$h5")%"
[ -n "${d7:-}" ] && out="$out  7d:$(printf '%.0f' "$d7")%"
[ -n "${ctx:-}" ] && out="$out  ctx:$(printf '%.0f' "$ctx")%"
printf '%s' "$out"
