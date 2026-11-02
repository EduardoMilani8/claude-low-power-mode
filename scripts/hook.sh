#!/bin/sh
# UserPromptSubmit hook for Low Power Mode.
# Prints only when needed: empty output = nothing reaches Claude's context.
DIR="$HOME/.claude/low-power"
THRESHOLD=75

[ -f "$DIR/battery" ] || exit 0
read -r pct resets < "$DIR/battery"
[ -n "$pct" ] || exit 0

now=$(date +%s)
# Stale reading from a week that already reset: ignore until the status line updates
[ -n "$resets" ] && [ "$now" -ge "$resets" ] && exit 0

mode=off; week=; asked=
[ -f "$DIR/state" ] && . "$DIR/state"

save() {
  printf 'mode=%s\nweek=%s\nasked=%s\n' "$mode" "$week" "$asked" > "$DIR/state"
}

# New week: battery is full, turn the mode off and allow asking again
if [ -z "$week" ] || [ "$now" -ge "$week" ]; then
  [ "$mode" = on ] && sh "$DIR/lowpower.sh" off >/dev/null
  mode=off; asked=; week=$resets
  save
fi

if [ "$mode" = on ]; then
  echo "[Low Power Mode on (weekly usage ${pct}%): short answers, no summaries, read only the needed lines with grep/offset, avoid subagents. Details in the low-power-mode skill.]"
elif [ "$pct" -ge "$THRESHOLD" ] && [ -z "$asked" ]; then
  asked=1
  save
  echo "[Claude weekly usage is at ${pct}%. Before anything else, ask the user if they want to turn on Low Power Mode (use AskUserQuestion with Yes/No if available). If yes, use the low-power-mode skill. If no, continue normally. Then carry on with their request.]"
fi
exit 0
