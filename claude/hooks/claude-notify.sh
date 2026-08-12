#!/usr/bin/env bash
# =====================================================================
#  Notificação do Claude Code: desktop (notify-send) + bell no terminal.
#  O bell é escrito no /dev/tty do shell ATUAL, que dentro do herdr
#  corresponde ao tty da pane em foco (a mesma onde o claude roda).
#  Isso faz o bell atravessar o herdr e o SSH, tocando/piscando tanto
#  no kitty (local) quanto no Windows Terminal (remoto).
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

# Bell no tty do shell atual — dentro do herdr isso é o tty da pane onde
# o claude esta rodando (o hook herda o mesmo /dev/tty do shell).
# [ -t 1 ] garante que NAO escrevemos em redirecionamentos (cron, pipes, etc.)
if [ -t 1 ]; then
  printf '\a' > /dev/tty 2>/dev/null
fi

exit 0
