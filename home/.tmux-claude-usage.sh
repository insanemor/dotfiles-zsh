#!/usr/bin/env bash
# =====================================================================
#  Uso do Claude Code na barra do tmux.
#
#  Le ~/.cache/claude/usage.json, que e gravado pelo statusLine do
#  Claude Code (~/.claude-statusline.sh). O schema mudou entre
#  versoes do Claude Code:
#
#    <= 2.0.x: rate_limits.five_hour/seven_day -> five_hour_pct /
#               seven_day_pct no cache.
#    >= 2.1.x: rate_limits removido. Resta context_window.used_percentage
#               -> context_pct no cache. E o unico dado confiavel
#               disponivel no payload do statusLine.
#
#  Estrategia de exibicao (em ordem de prioridade):
#    1) five_hour_pct + remaining ate o reset  (se vier)
#    2) senao, context_pct  (janela de contexto ocupada)
#  seven_day_pct e sempre adicionado quando presente.
#
#  So mostra quando ha um processo `claude` ativo. Se os dados forem
#  antigos (Claude fechado ha tempo) ou ausentes, nao mostra nada.
# =====================================================================
USAGE_FILE="$HOME/.cache/claude/usage.json"
CLOCK=$'\uf017'   # icone de relogio (Nerd Font)

# So quando o Claude Code estiver aberto
pgrep -x claude >/dev/null 2>&1 || { printf ''; exit 0; }
[ -f "$USAGE_FILE" ] || { printf ''; exit 0; }

# Le os dados oficiais. O `read` do bash com IFS colapsa campos
# vazios consecutivos (testes com TAB, |, etc. todos colocam o
# ultimo valor na primeira variavel). Para contornar, usamos
# `jq -r '@sh "..."'` que produz atribuicoes shell-safe que o
# `eval` popula corretamente mesmo com varios campos vazios.
eval "$(jq -r '@sh "H5=\(.five_hour_pct  // "" | tostring)
                  H5R=\(.five_hour_reset // "" | tostring)
                  D7=\(.seven_day_pct  // "" | tostring)
                  D7R=\(.seven_day_reset // "" | tostring)
                  CTX=\(.context_pct    // "" | tostring)
                  UPD=\(.updated        // 0  | tostring)"' "$USAGE_FILE" 2>/dev/null)" \
  || { printf ''; exit 0; }

# Sem nenhum dado utilisavel -> nada a mostrar
# (ex.: login por API key, que nao recebe context_window; statusLine
#  ainda nao rodou nesta sessao; ou schema mudou e nao reconhecemos).
[ -z "${H5:-}" ] && [ -z "${CTX:-}" ] && { printf ''; exit 0; }

# Descarta dados velhos (> 5 min) p/ nao mostrar info defasada
now=$(date +%s)
if [ -n "${UPD:-}" ] && [ "$UPD" -gt 0 ] 2>/dev/null; then
  [ $(( now - UPD )) -gt 300 ] && { printf ''; exit 0; }
fi

# Escolhe o rotulo + o valor principal: rate limit 5h se existir,
# senao cai para a janela de contexto.
if [ -n "${H5:-}" ]; then
  label="5h"
  raw="$H5"
else
  label="ctx"
  raw="$CTX"
fi

# So renderiza se o valor for numerico (defesa contra lixo vazando
# no read com IFS=tab). Se vier "null" do jq, cai fora.
case "$raw" in
  ''|*[!0-9.]*) printf ''; exit 0 ;;
esac

# Arredonda + cor por faixa (70 warn / 90 critico)
p=$(awk "BEGIN{printf \"%.0f\", $raw}" 2>/dev/null)
[ -z "$p" ] && { printf ''; exit 0; }
if   [ "$p" -ge 90 ]; then c="#fc5e59"   # vermelho
elif [ "$p" -ge 70 ]; then c="#efc11a"   # amarelo
else                       c="#9dff6e"   # verde
fi

# Tempo ate o reset da janela de 5h (se houver)
rem="--"
if [ -n "${H5R:-}" ] && [ "$H5R" -gt "$now" ] 2>/dev/null; then
  diff=$(( H5R - now )); H=$(( diff / 3600 )); M=$(( (diff % 3600) / 60 ))
  rem=$(printf '%dh%02dm' "$H" "$M")
fi

# 7d (semanal), discreto, so quando vier
weekly=""
if [ -n "${D7:-}" ]; then
  case "$D7" in
    *[!0-9.]*) ;;
    *) weekly=" #[fg=#6f6a8e]7d $(awk "BEGIN{printf \"%.0f\", $D7}" 2>/dev/null)%%" ;;
  esac
fi

# Linha colorida p/ a barra do tmux (cores do tema kitty)
printf '#[fg=#c39df5,bold]Claude#[default] #[fg=%s]%s %s%%#[default] #[fg=#c8f9f3]%s %s#[default]%s' \
  "$c" "$label" "$p" "$CLOCK" "$rem" "$weekly"
