#!/bin/sh
# Turn Low Power Mode on/off. Usage: lowpower.sh on | off | status
DIR="$HOME/.claude/low-power"
SETTINGS="$HOME/.claude/settings.json"
# Plugins that add tokens to every session; disabled while the mode is on
PLUGINS="learning-output-style@claude-plugins-official explanatory-output-style@claude-plugins-official"

mode=off; week=; asked=
[ -f "$DIR/state" ] && . "$DIR/state"

set_plugin() {
  jq --arg p "$1" --argjson v "$2" '.enabledPlugins[$p] = $v' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
}

# Disable only the ones that were enabled, and remember them to re-enable exactly those
disable_plugins() {
  [ -f "$DIR/disabled-plugins" ] && return
  : > "$DIR/disabled-plugins"
  for p in $PLUGINS; do
    if [ "$(jq -r --arg p "$p" '.enabledPlugins[$p] // false' "$SETTINGS")" = true ]; then
      set_plugin "$p" false
      echo "$p" >> "$DIR/disabled-plugins"
    fi
  done
}

restore_plugins() {
  [ -f "$DIR/disabled-plugins" ] || return
  while read -r p; do
    [ -n "$p" ] && set_plugin "$p" true
  done < "$DIR/disabled-plugins"
  rm -f "$DIR/disabled-plugins"
}

case "$1" in
  on|off)
    mode=$1; asked=1
    mkdir -p "$DIR"
    if [ "$mode" = on ]; then disable_plugins; else restore_plugins; fi
    printf 'mode=%s\nweek=%s\nasked=%s\n' "$mode" "$week" "$asked" > "$DIR/state"
    echo "Low Power Mode: $mode (plugin changes apply on the next session)" ;;
  status)
    pct=$(cut -d' ' -f1 "$DIR/battery" 2>/dev/null)
    echo "Low Power Mode: $mode | weekly usage: ${pct:-?}%"
    [ -n "$pct" ] || echo "No reading yet. If you use a custom status line, copy the 'sensor' block from $DIR/statusline.sh into it (see README)." ;;
  *) echo "usage: lowpower.sh on|off|status" >&2; exit 1 ;;
esac
