#!/usr/bin/env bash
# =====================================================================
#  Notificação do Claude Code: desktop (notify-send) + bell no terminal.
#  O bell é escrito no tty do painel ATIVO do tmux, então atravessa o
#  tmux e o SSH, tocando/piscando tanto no kitty (local) quanto no
#  Windows Terminal (remoto).
#
#  Uso (no hook do settings.json):
#    claude-notify.sh stop          # quando o Claude termina
#    claude-notify.sh notification  # quando o Claude aguarda input
#  Recebe o JSON do evento na stdin.
# =====================================================================
set -u
kind="${1:-stop}"
input="$(cat 2>/dev/null)"   # JSON do evento (pode vir vazio)

case "$kind" in
  notification)
    msg="$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)"
    [ -z "$msg" ] && msg="Aguardando sua resposta"
    notify-send -a 'Claude Code' -u critical 'Claude Code 🔔' "$msg" 2>/dev/null
    ;;
  *)
    notify-send -a 'Claude Code' 'Claude Code ✅' 'Terminou de processar' 2>/dev/null
    ;;
esac

# Bell que atravessa o tmux: escreve no tty do painel ativo.
tty="$(tmux display-message -p '#{pane_tty}' 2>/dev/null)"
[ -n "$tty" ] && printf '\a' > "$tty" 2>/dev/null

exit 0
