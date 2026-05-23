---
name: statusline-linux
description: This skill should be used when the user asks to "set up statusline on Linux", "set up statusline on macOS", "show model in statusline", "show OS in statusline on Linux", "add caveman badge to statusline", "configure statusline bash", or wants to display [claude-sonnet-4-6], [Linux], or [CAVEMAN:ULTRA] in the Claude Code statusline on Linux or macOS. See statusline-windows skill for Windows setup.
version: 1.0.0
---

# Claude Code Statusline — Linux / macOS

Displays `[CAVEMAN:ULTRA] [claude-sonnet-4-6] [Linux]` in the Claude Code statusline.

Requires [caveman plugin](https://github.com/JuliusBrussee/caveman) for the badge. Model + OS work without it.

## Step 1: Install the script

Copy `examples/statusline.sh` to `~/.claude/statusline.sh` and make it executable:

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

### What the script does

- **Caveman badge**: pipes stdin JSON to `~/.claude/hooks/caveman-statusline.sh` (from caveman plugin) and captures output. If non-empty, prints it with a trailing space separator.
- **Model**: reads JSON from stdin via `python3`. Field `.model` may be a string (e.g. `"claude-sonnet-4-6"`) or an object with `.display_name`/`.id` — handles both. `jq` is not assumed present.
- **OS**: calls `uname -s` → `Linux` or `Darwin`.

### Critical pitfall: `jq` not assumed

`jq` is absent on many Linux systems. Always use `python3` (available on all modern Linux/macOS) to parse the JSON stdin.

## Step 2: Register in settings.json

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/bin/bash /root/.claude/statusline.sh"
  }
}
```

Use an absolute path — `settings.json` does not expand `~` or `$HOME`.

## Step 3: Caveman ultra badge (optional)

For `[CAVEMAN:ULTRA]` instead of `[CAVEMAN]`, see the `caveman-ultra` skill.

## Troubleshooting

**No output at all** → Script path wrong in settings.json, or script not executable. Test manually:
```bash
echo '{"model":"claude-sonnet-4-6"}' | bash ~/.claude/statusline.sh
```

**Badge missing** → caveman plugin not installed or `~/.claude/hooks/caveman-statusline.sh` absent.

**`[CAVEMAN]` not `[CAVEMAN:ULTRA]`** → caveman plugin config missing `"defaultMode": "ultra"`. See caveman-ultra skill.

**Model missing, no error** → `python3` absent (unlikely), or `.model` field empty in JSON. Pipe real session JSON to script to verify.

**Permission denied** → Script not executable. Run `chmod +x ~/.claude/statusline.sh`.

## Additional Resources

- `examples/statusline.sh` — complete working script
- `statusline-windows` skill — Windows/PowerShell equivalent
- `caveman-ultra` skill — pin caveman ultra every session
