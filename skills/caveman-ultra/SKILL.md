---
name: caveman-ultra
description: This skill should be used when the user asks to "make caveman ultra default", "pin caveman ultra", "always start in caveman ultra", "caveman ultra every session", "set default caveman mode to ultra", or wants [CAVEMAN:ULTRA] to appear in statusline automatically on every session start. Requires caveman plugin installed.
version: 1.0.0
---

# Make Caveman Ultra Default Every Session

Two parts: (1) badge in statusline shows `[CAVEMAN:ULTRA]`, (2) Claude receives ultra ruleset injected at session start.

## Part 1: Badge — caveman config.json

`caveman-activate.js` runs at SessionStart and writes mode to `~/.claude/.caveman-active`. Mode resolution order:

1. `CAVEMAN_DEFAULT_MODE` env var
2. `%APPDATA%\caveman\config.json` → `defaultMode`
3. Falls back to `full`

**Windows:**
```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\caveman" | Out-Null
Set-Content "$env:APPDATA\caveman\config.json" '{ "defaultMode": "ultra" }'
```

File location: `C:\Users\<username>\AppData\Roaming\caveman\config.json`

**Linux/macOS:**
```bash
mkdir -p ~/.config/caveman
echo '{ "defaultMode": "ultra" }' > ~/.config/caveman/config.json
```

After next session start, statusline shows `[CAVEMAN:ULTRA]` instead of `[CAVEMAN]`.

## Part 2: Context injection — SessionStart hook

Badge alone doesn't inject ultra ruleset into Claude's context. Add a SessionStart hook to `~/.claude/settings.json` to pin ultra behavior every session.

**Windows** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "Set-Content -Path \"$env:USERPROFILE\\.claude\\caveman-mode.txt\" -Value 'ultra' -NoNewline; $sp = \"$env:USERPROFILE\\.claude\\skills\\caveman\\SKILL.md\"; $skill = if (Test-Path $sp) { Get-Content $sp -Raw } else { 'Caveman ultra: ultra-compress responses, abbreviate prose, arrows for causality, never abbreviate code/identifiers.' }; $ctx = \"Caveman skill is active at ULTRA intensity for this entire session (pinned). Apply the following skill, defaulting intensity to ultra regardless of the skill default, until the user says 'stop caveman' or 'normal mode':`n`n$skill\"; @{hookSpecificOutput=@{hookEventName='SessionStart';additionalContext=$ctx}} | ConvertTo-Json -Compress",
            "shell": "powershell"
          }
        ]
      }
    ]
  }
}
```

**Linux/macOS** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "printf 'ultra' > ~/.claude/caveman-mode.txt; sp=~/.claude/skills/caveman/SKILL.md; skill=$([ -f \"$sp\" ] && cat \"$sp\" || echo 'Caveman ultra: ultra-compress responses.'); printf '{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"Caveman skill is active at ULTRA intensity for this entire session (pinned). Apply the following skill, defaulting intensity to ultra until the user says stop caveman or normal mode:\\n\\n%s\"}}' \"$skill\""
          }
        ]
      }
    ]
  }
}
```

## How they work together

| What | Where | Effect |
|------|-------|--------|
| `config.json` defaultMode=ultra | `%APPDATA%\caveman\` or `~/.config/caveman/` | Badge = `[CAVEMAN:ULTRA]` |
| SessionStart hook | `~/.claude/settings.json` | Claude receives ultra ruleset in context |

Both needed. Config alone → badge only, Claude uses `full` behavior. Hook alone → ultra behavior, badge shows `[CAVEMAN]`.

## Verify

Start new session. Statusline should show `[CAVEMAN:ULTRA]`. Check system reminder at top of session — should contain `CAVEMAN MODE ACTIVE — level: ultra`.
