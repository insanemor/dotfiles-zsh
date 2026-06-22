#!/usr/bin/env bash
# =====================================================================
#  Uso do MiniMax (Coding Plan / Token Plan) na barra do tmux.
#
#  Le a API key do MiniMax de:
#    1) $MINIMAX_API_KEY      (variavel de ambiente — recomendado)
#    2) ~/.local/share/crush/crush.json  (chave configurada no Crush)
#
#  Endpoint (Coding Plan / Token Plan):
#    GET https://api.minimax.io/v1/token_plan/remains
#    Authorization: Bearer <api-key>
#
#  Schema real (jun/2026):
#    model_remains[].model_name
#    model_remains[].end_time                 epoch ms — fim da janela 5h
#    model_remains[].remains_time             ms ate o reset 5h
#    model_remains[].current_interval_remaining_percent  % RESTANTE (5h)
#    model_remains[].weekly_end_time          epoch ms — fim da janela semanal
#    model_remains[].weekly_remains_time      ms ate o reset semanal
#    model_remains[].current_weekly_remaining_percent   % RESTANTE (7d)
#
#  Cache: ~/.cache/minimax/usage.json   (TTL ~5 min, igual ao do Claude)
#
#  Barra so aparece quando existe uma chave configurada. Para ocultar
#  mesmo com chave presente, defina MINIMAX_BAR=0 no ambiente.
# =====================================================================
set -uo pipefail

CACHE_DIR="$HOME/.cache/minimax"
CACHE_FILE="$CACHE_DIR/usage.json"
mkdir -p "$CACHE_DIR"

[ "${MINIMAX_BAR:-1}" = "0" ] && { printf ''; exit 0; }

# --- chave -------------------------------------------------------------
api_key="${MINIMAX_API_KEY:-}"
if [ -z "$api_key" ] && [ -r "$HOME/.local/share/crush/crush.json" ]; then
  api_key=$(jq -r '.providers.minimax.api_key // empty' \
              "$HOME/.local/share/crush/crush.json" 2>/dev/null)
fi
[ -z "$api_key" ] && { printf ''; exit 0; }

# --- busca (com cache) -------------------------------------------------
endpoint="${MINIMAX_API_ENDPOINT:-https://api.minimax.io/v1/token_plan/remains}"

fetch_minimax() {
  curl -fsS --max-time 4 \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    "$endpoint" 2>/dev/null
}

now=$(date +%s)
use_cache=0
if [ -f "$CACHE_FILE" ]; then
  updated=$(jq -r '.updated // 0' "$CACHE_FILE" 2>/dev/null)
  if [ -n "$updated" ] && [ "$updated" -gt 0 ] 2>/dev/null; then
    [ $(( now - updated )) -lt 300 ] && use_cache=1
  fi
fi

if [ "$use_cache" -eq 0 ]; then
  raw=$(fetch_minimax) || { printf ''; exit 0; }
  printf '%s' "$raw" > "$CACHE_DIR/raw.json"
  jq -n \
    --argjson raw "$raw" \
    --argjson now "$now" \
    '($raw.model_remains // []) as $all
     | ($all | map(select(.model_name != "video")) | .[0] // $all[0] // {}) as $m
     | { model:($m.model_name // ""),
         interval_remaining_pct:($m.current_interval_remaining_percent // null),
         interval_end_ms:(($m.end_time // 0)),
         interval_remains_ms:($m.remains_time // 0),
         weekly_remaining_pct:($m.current_weekly_remaining_percent // null),
         weekly_end_ms:(($m.weekly_end_time // 0)),
         weekly_remains_ms:($m.weekly_remains_time // 0),
         updated:$now }' > "$CACHE_FILE" 2>/dev/null \
    || { printf ''; exit 0; }
fi

# --- leitura do cache --------------------------------------------------
# (campo pode ser null -> transforma em string vazia para parsear seguro)
IFS=$'\t' read -r i5_pct end5 i5_rem w7_pct wend w7_rem updated < <(
  jq -r '[(.interval_remaining_pct // "" | tostring),
          (.interval_end_ms // 0 | tostring),
          (.interval_remains_ms // 0 | tostring),
          (.weekly_remaining_pct // "" | tostring),
          (.weekly_end_ms // 0 | tostring),
          (.weekly_remains_ms // 0 | tostring),
          (.updated // 0 | tostring)] | @tsv' \
     "$CACHE_FILE" 2>/dev/null
)

# Sem % da janela de 5h -> nada a mostrar
[ -z "${i5_pct:-}" ] && { printf ''; exit 0; }

# "remaining_percent" -> uso = 100 - remaining
used5_pct=$(( 100 - ${i5_pct%.*} ))

# Tempo ate o reset 5h — prefere end_time absoluto a remains_time relativo
now_ms=$(( now * 1000 ))
reset5_ms=$end5
[ "$reset5_ms" -le 0 ] 2>/dev/null && reset5_ms=$(( now_ms + i5_rem ))
diff=$(( (reset5_ms - now_ms) / 1000 ))
[ "$diff" -lt 0 ] 2>/dev/null && diff=0
H=$(( diff / 3600 )); M=$(( (diff % 3600) / 60 ))
rem5=$(printf '%dh%02dm' "$H" "$M")

# 7d (semanal) — opcional
weekly_part=""
if [ -n "${w7_pct:-}" ]; then
  used7_pct=$(( 100 - ${w7_pct%.*} ))
  weekly_part=" #[fg=#6f6a8e]7d ${used7_pct}%%"
fi

# Cor por faixa de uso 5h
if   [ "$used5_pct" -ge 90 ]; then c5="#fc5e59"
elif [ "$used5_pct" -ge 70 ]; then c5="#efc11a"
else                                c5="#9dff6e"
fi

CLOCK=$'\uf017'

printf '#[fg=#e9b8b8,bold]MiniMax#[default] #[fg=%s]5h %s%%#[default] #[fg=#c8f9f3]%s %s#[default]%s' \
  "$c5" "$used5_pct" "$CLOCK" "$rem5" "$weekly_part"
