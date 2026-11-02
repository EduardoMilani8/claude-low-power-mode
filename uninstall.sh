#!/bin/sh
# Removes Low Power Mode from ~/.claude
CLAUDE="$HOME/.claude"
DIR="$CLAUDE/low-power"
SETTINGS="$CLAUDE/settings.json"

# Turn the mode off first so disabled plugins come back
[ -f "$DIR/lowpower.sh" ] && sh "$DIR/lowpower.sh" off >/dev/null

if [ -f "$SETTINGS" ]; then
  jq --arg c "sh $DIR/hook.sh" --arg s "sh $DIR/statusline.sh" '
    .hooks.UserPromptSubmit |= (map(.hooks |= map(select(.command != $c))) | map(select(.hooks | length > 0)))
    | if .hooks.UserPromptSubmit == [] then del(.hooks.UserPromptSubmit) else . end
    | if .hooks == {} then del(.hooks) else . end
    | if .statusLine.command == $s then del(.statusLine) else . end
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
fi

rm -rf "$DIR" "$CLAUDE/skills/low-power-mode"
echo "Low Power Mode removed."
