# claude-personal

Personal [Claude Code](https://claude.ai/code) plugin — skills for statusline setup and caveman ultra default mode.

## Install

```
/plugins install claude-personal@claude-personal
```

Requires `extraKnownMarketplaces` in `~/.claude/settings.json`:

```json
"extraKnownMarketplaces": {
  "claude-personal": {
    "source": {
      "source": "github",
      "repo": "gummz/claude-personal"
    }
  }
}
```

## Skills

### `statusline-linux` / `statusline-macos` / `statusline-windows`

Configures the Claude Code statusline to show active model, OS, and [caveman](https://github.com/JuliusBrussee/caveman) mode badge.

Example output: `[claude-sonnet-4-6] [macOS] [CAVEMAN:ULTRA]`

Trigger: ask Claude to "set up statusline" or "show model in statusline".

### `caveman-ultra`

Pins [caveman](https://github.com/JuliusBrussee/caveman) ultra mode as the default every session — injects the ultra ruleset at session start and shows `[CAVEMAN:ULTRA]` in the statusline.

Trigger: ask Claude to "make caveman ultra default" or "always start in caveman ultra".

> Requires the caveman plugin installed. The manual SessionStart hook in the skill instructions is only needed for standalone installs without the caveman plugin.
