#!/usr/bin/env bash
# =====================================================================
#  Uso do Claude Code na barra do tmux  —  DADOS OFICIAIS.
#
#  Le ~/.cache/claude/usage.json, que e gravado pelo statusLine do
#  Claude Code (~/.claude-statusline.sh) com os rate limits REAIS
#  (os mesmos numeros do comando /usage): % da janela de 5h, % dos
#  7 dias e o horario exato de reset.
#
#  Mostra so quando ha um processo `claude` ativo. Se os dados forem
#  antigos (Claude fechado ha tempo) ou ausentes, nao mostra nada.
# =====================================================================
USAGE="$HOME/.cache/claude/usage.json"
CLOCK=""   # icone de relogio (Nerd Font, U+F017)

# So quando o Claude Code estiver aberto
pgrep -x claude >/dev/null 2>&1 || { printf ''; exit 0; }
[ -f "$USAGE" ] || { printf ''; exit 0; }

# Le os dados oficiais (campos podem estar vazios)
IFS=$'\t' read -r h5 h5r d7 updated < <(
  jq -r '[(.five_hour_pct // ""), (.five_hour_reset // ""),
          (.seven_day_pct // ""), (.updated // 0)] | @tsv' "$USAGE" 2>/dev/null
)

# Sem % da janela de 5h -> nada a mostrar
# (ex.: login por API key, que nao recebe rate_limits; ou statusLine
#  ainda nao rodou nesta sessao)
[ -z "${h5:-}" ] && { printf ''; exit 0; }

# Descarta dados velhos (> 5 min) p/ nao mostrar info defasada
now=$(date +%s)
if [ -n "${updated:-}" ] && [ "$updated" -gt 0 ] 2>/dev/null; then
  [ $(( now - updated )) -gt 300 ] && { printf ''; exit 0; }
fi

# % da janela de 5h (arredondada) + cor por faixa (70 warn / 90 critico)
p5=$(awk "BEGIN{printf \"%.0f\", $h5}" 2>/dev/null)
if   [ "${p5:-0}" -ge 90 ]; then c5="#fc5e59"   # vermelho
elif [ "${p5:-0}" -ge 70 ]; then c5="#efc11a"   # amarelo
else                             c5="#9dff6e"   # verde
fi

# Tempo ate o reset da janela de 5h (horario real vindo da API)
if [ -n "${h5r:-}" ] && [ "$h5r" -gt "$now" ] 2>/dev/null; then
  diff=$(( h5r - now )); H=$(( diff / 3600 )); M=$(( (diff % 3600) / 60 ))
  rem=$(printf '%dh%02dm' "$H" "$M")
else
  rem="--"
fi

# % dos 7 dias (semana), discreta
p7=""
[ -n "${d7:-}" ] && p7=$(awk "BEGIN{printf \"%.0f\", $d7}" 2>/dev/null)

# Linha colorida p/ a barra do tmux (cores do tema kitty)
if [ -n "$p7" ]; then
  printf '#[fg=#c39df5,bold]Claude#[default] #[fg=%s]5h %s%%#[default] #[fg=#c8f9f3]%s %s#[default] #[fg=#6f6a8e]7d %s%%#[default]' \
    "$c5" "$p5" "$CLOCK" "$rem" "$p7"
else
  printf '#[fg=#c39df5,bold]Claude#[default] #[fg=%s]5h %s%%#[default] #[fg=#c8f9f3]%s %s#[default]' \
    "$c5" "$p5" "$CLOCK" "$rem"
fi
