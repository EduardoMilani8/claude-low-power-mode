---
name: low-power-mode
description: Token-saving Low Power Mode. Use when the user accepts turning on Low Power Mode (after the high weekly usage warning) or asks to turn it on, off, or check its status.
---

# Low Power Mode

## On / off
- On: `sh ~/.claude/low-power/lowpower.sh on`
- Off: `sh ~/.claude/low-power/lowpower.sh off`
- Status: `sh ~/.claude/low-power/lowpower.sh status`

It turns off by itself when the weekly limit resets.

## When turning on
1. Run the "on" command.
2. Say in one line: "To save more, start your next session with `/model haiku` and `/effort low`." Do not switch models in the middle of a long conversation: it breaks the prompt cache and the new model re-reads the whole context at full price.
3. Confirm in one line and continue with the user's request.

## Rules while on
**Writing**
- Short, direct answers. No intro, no final summary, no repeating what the user said.
- No "Insight" blocks or teaching explanations unless asked.
- Edit with Edit (only the changed part). Never rewrite a whole file to change a few lines.
- Do not show code you just wrote to a file.

**Reading** (where most tokens go)
- Use grep/rg to find the spot before opening files; read with offset/limit.
- Do not re-read files already read in this conversation.
- Do not list whole directories or run commands with long output; filter with `head`, `tail`, `grep`.

**Tools**
- Avoid subagents. If unavoidable, use the Haiku model.
- No web searches unless needed.
- Ask before big tasks ("this will read ~20 files, go ahead?").

**Session** (every message resends the whole history)
- When the topic changes, suggest `/clear`; in a long conversation on the same topic, suggest `/compact`.
- Before suggesting `/clear`, save the task state (done / left to do) to a short file, so you can resume without re-reading everything.
