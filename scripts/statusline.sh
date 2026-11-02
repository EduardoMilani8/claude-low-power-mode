#!/bin/sh
# Minimal status line that also feeds Low Power Mode.
# Already have a status line? Copy only the "sensor" block into yours.
input=$(cat)
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# --- Low Power Mode sensor: saves weekly usage for the hook (local, zero tokens) ---
if [ -n "$week_pct" ]; then
  lp="$HOME/.claude/low-power"
  mkdir -p "$lp"
  printf '%.0f %s\n' "$week_pct" "$week_resets" > "$lp/battery.tmp" && mv "$lp/battery.tmp" "$lp/battery"
fi
# --- end sensor ---

mode=$(sed -n 's/^mode=//p' "$HOME/.claude/low-power/state" 2>/dev/null)
[ -n "$week_pct" ] && printf '7d: %.0f%%' "$week_pct"
[ "$mode" = on ] && printf ' | low power'
