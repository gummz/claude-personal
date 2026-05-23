#!/bin/bash
# Claude Code statusline — macOS
# Output: [CAVEMAN:ULTRA] [claude-sonnet-4-6] [macOS]

input=$(cat)

# Caveman badge — delegates to caveman plugin hook
caveman_out=$(echo "$input" | bash "$HOME/.claude/hooks/caveman-statusline.sh" 2>/dev/null)
[ -n "$caveman_out" ] && printf '%s ' "$caveman_out"

# Model — read from stdin JSON; field may be string or object with .id/.display_name
# jq not assumed present; use python3 (available on all modern macOS)
model=$(echo "$input" | python3 -c "
import sys, json
d = json.load(sys.stdin)
m = d.get('model', '')
print(m if isinstance(m, str) else m.get('display_name') or m.get('id', ''))
" 2>/dev/null)
[ -n "$model" ] && printf '\033[38;5;75m[%s]\033[0m' "$model"

# OS — always macOS on Darwin
printf ' \033[38;5;214m[macOS]\033[0m'
