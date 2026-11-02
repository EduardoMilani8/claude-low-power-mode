#!/bin/sh
# Installs Low Power Mode for Claude Code into ~/.claude
set -e
command -v jq >/dev/null || { echo "jq is required: install it first (e.g. sudo apt install jq / brew install jq)"; exit 1; }

SRC=$(cd "$(dirname "$0")" && pwd)
CLAUDE="$HOME/.claude"
DIR="$CLAUDE/low-power"
SETTINGS="$CLAUDE/settings.json"
HOOK="sh $DIR/hook.sh"

mkdir -p "$DIR" "$CLAUDE/skills/low-power-mode"
cp "$SRC/scripts/hook.sh" "$SRC/scripts/lowpower.sh" "$SRC/scripts/statusline.sh" "$DIR/"
cp "$SRC/skill/SKILL.md" "$CLAUDE/skills/low-power-mode/"

[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak-low-power"

# Register the hook (once)
if ! jq -e --arg c "$HOOK" '[.hooks.UserPromptSubmit[]?.hooks[]?.command] | index($c)' "$SETTINGS" >/dev/null; then
  jq --arg c "$HOOK" '.hooks.UserPromptSubmit += [{"hooks":[{"type":"command","command":$c}]}]' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
fi

# Status line: use ours only if there is none
if jq -e '.statusLine' "$SETTINGS" >/dev/null; then
  echo "You already have a status line. Copy the 'sensor' block from"
  echo "  $DIR/statusline.sh"
  echo "into your status line script so Low Power Mode can see your weekly usage."
else
  jq --arg c "sh $DIR/statusline.sh" '.statusLine = {"type":"command","command":$c}' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
fi

echo "Low Power Mode installed. Restart Claude Code to load it."
