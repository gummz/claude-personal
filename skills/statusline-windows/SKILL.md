---
name: statusline-windows
description: This skill should be used when the user asks to "set up statusline on Windows", "show model in statusline", "show OS in statusline on Windows", "add caveman badge to statusline", "configure statusline PowerShell", or wants to display [Sonnet 4.6], [Windows 11], or [CAVEMAN:ULTRA] in the Claude Code statusline on Windows. See statusline-linux skill for Linux/macOS setup.
version: 1.0.0
---

# Claude Code Statusline — Windows

Displays `[CAVEMAN:ULTRA] [Sonnet 4.6 | medium] [Windows 11]` in the Claude Code statusline.

Requires [caveman plugin](https://github.com/JuliusBrussee/caveman) for the badge. Model + OS work without it.

## Step 1: Install the script

Copy `examples/statusline.ps1` to `~/.claude/statusline.ps1` (`C:\Users\<username>\.claude\statusline.ps1`).

### What the script does

- **Caveman badge**: calls `~/.claude/hooks/caveman-statusline.ps1` (from caveman plugin). That script uses `[Console]::Write()` directly — it cannot be captured via PowerShell pipeline. Check `.caveman-active` flag file instead to know if badge printed, then add separator space.
- **Model + effort**: reads JSON from stdin (`$data.model`), regex-formats `claude-sonnet-4-6` → `Sonnet 4.6`. Reads `effortLevel` from `~\.claude\settings.json` and displays as `[Sonnet 4.6 | medium]`. Model field may be string or object with `.id` — handle both.
- **OS**: reads `[System.Environment]::OSVersion.Version.Build`, maps build number → human name.

### Critical pitfall: `$input` is reserved

`$input` is a PowerShell automatic variable. Using it as variable name causes silent failures. Always use `$raw` or another name for stdin content.

### OS build number map

| Build | Name |
|-------|------|
| ≥ 22000 | Windows 11 |
| ≥ 10240 | Windows 10 |
| ≥ 9200 | Windows 8 |
| < 9200 | Windows |

## Step 2: Register in settings.json

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\Users\\YOUR_USERNAME\\.claude\\statusline.ps1\""
  }
}
```

Use literal path — `settings.json` does not expand `$env:USERPROFILE`.

## Step 3: Caveman ultra badge (optional)

For `[CAVEMAN:ULTRA]` instead of `[CAVEMAN]`, see the `caveman-ultra` skill. Short version: create `%APPDATA%\caveman\config.json`:

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\caveman" | Out-Null
Set-Content "$env:APPDATA\caveman\config.json" '{ "defaultMode": "ultra" }'
```

## Troubleshooting

**No output at all** → Script path wrong in settings.json, or PowerShell execution policy blocking. Test manually: `echo '{"model":"claude-sonnet-4-6"}' | powershell -File ~/.claude/statusline.ps1`

**Badge missing** → caveman plugin not installed or `.caveman-active` absent. Verify `~/.claude/hooks/caveman-statusline.ps1` exists.

**`[CAVEMAN]` not `[CAVEMAN:ULTRA]`** → `%APPDATA%\caveman\config.json` missing. See caveman-ultra skill.

**Extra/missing space between badge and model** → Badge writes directly to Console, not captured. Script uses `Test-Path .caveman-active` to detect and add space conditionally.

**Model shows raw ID** → Check `$data.model` — may be `{id: "..."}` object not string. Script handles both cases.

## Additional Resources

- `examples/statusline.ps1` — complete working script
- `caveman-ultra` skill — pin caveman ultra every session
