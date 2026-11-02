# Low Power Mode for Claude Code 🔋

Like your phone's Low Power Mode, but for Claude.

When your **weekly Claude usage reaches 75%**, Claude asks:

> ⚡ Weekly usage at 76%. Turn on Low Power Mode? **Yes / No**

Say yes and Claude starts saving tokens until your weekly limit resets.

## What it does

- ✂️ **Shorter answers:** no intros, no summaries, no repeated code.
- 📖 **Reads less:** greps for the exact lines instead of opening whole files.
- 🧩 **Fewer extras:** avoids subagents and web searches. Turns off the learning/explanatory output style plugins (if you use them).
- 🔁 **Turns itself off** when your weekly limit resets.

You can also turn it on or off any time. Just tell Claude "turn on Low Power Mode".

## Install

Requires [Claude Code](https://claude.com/claude-code), a Pro/Max plan (for the weekly usage number), and `jq`.

```bash
git clone https://github.com/EduardoMilani8/claude-low-power-mode
cd claude-low-power-mode
sh install.sh
```

Restart Claude Code. Done.

> **Already have a custom status line?** The installer won't touch it. Copy the small "sensor" block from `~/.claude/low-power/statusline.sh` into your script.

## Use

```bash
sh ~/.claude/low-power/lowpower.sh on       # turn on
sh ~/.claude/low-power/lowpower.sh off      # turn off
sh ~/.claude/low-power/lowpower.sh status   # check
```

Want a different threshold? Change `THRESHOLD=75` in `~/.claude/low-power/hook.sh`.

## How it works (and why it costs ~0 tokens)

```
status line ──▶ saves weekly % to a file           (local, 0 tokens)
your message ──▶ hook reads the file and decides:  (local, 0 tokens)
                  ├─ below 75%      → says nothing
                  ├─ first time 75% → asks you once
                  └─ mode on        → adds a 1-line reminder (~40 tokens)
```

All the checking happens in small shell scripts on your machine. Claude only sees a message when there's something to say.

## Uninstall

```bash
sh uninstall.sh
```

## License

MIT
