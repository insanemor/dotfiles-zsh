#!/usr/bin/env bash
# =====================================================================
#  statusLine do Claude Code.
#  - Recebe um JSON via stdin (dados da sessao do Claude Code).
#  - Extrai o uso de contexto (janela atual) e grava num arquivo
#    para a barra do tmux ler (~/.cache/claude/usage.json).
#  - Tambem imprime uma linha de status para o proprio Claude Code.
#  - Salva o JSON cru em ~/.cache/claude/statusline-input.json para
#    validacao/depuracao da estrutura.
#
#  Historico de schema:
#    <= 2.0.x  -> rate_limits.five_hour.{used_percentage,resets_at}
#                 rate_limits.seven_day.{used_percentage,resets_at}
#                 context_window.used_percentage
#    >= 2.1.x  -> rate_limits removido do payload. Resta apenas
#                 context_window.used_percentage (pode vir null quando
#                 a sessao ainda nao enviou nenhuma mensagem).
# =====================================================================
input=$(cat)

CACHE_DIR="$HOME/.cache/claude"
mkdir -p "$CACHE_DIR"

# 1) salva o JSON cru (debug/validacao)
printf '%s' "$input" > "$CACHE_DIR/statusline-input.json"

# 2) extrai os campos (tab-separated; campos ausentes ficam vazios).
#    Tentamos ambos schemas: rate_limits (legado) E context_window.
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

# 3) grava os dados p/ o tmux (JSON simples).
#    Mantemos os nomes `five_hour_pct`/`seven_day_pct` por retro-compat
#    com ~/.tmux-claude-usage.sh, mas no schema >=2.1 esses dois ficam
#    vazios; o campo principal para a barra passa a ser `context_pct`.
jq -n \
  --arg h5 "${h5:-}" --arg h5r "${h5r:-}" \
  --arg d7 "${d7:-}" --arg d7r "${d7r:-}" \
  --arg ctx "${ctx:-}" \
  '{five_hour_pct:$h5, five_hour_reset:$h5r,
    seven_day_pct:$d7, seven_day_reset:$d7r,
    context_pct:$ctx, updated:(now|floor)}' \
  > "$CACHE_DIR/usage.json" 2>/dev/null

# 4) imprime a status line do proprio Claude Code.
#    Prioridade: 5h (se vier) > ctx. 7d sempre que disponivel.
out="$model"
if [ -n "${h5:-}" ]; then
  out="$out  5h:$(printf '%.0f' "$h5")%"
elif [ -n "${ctx:-}" ]; then
  out="$out  ctx:$(printf '%.0f' "$ctx")%"
fi
[ -n "${d7:-}" ] && out="$out  7d:$(printf '%.0f' "$d7")%"
printf '%s' "$out"
