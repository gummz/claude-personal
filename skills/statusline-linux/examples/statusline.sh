#!/bin/bash
# Claude Code statusline — Linux/macOS
# Output: [CAVEMAN:ULTRA] [claude-sonnet-4-6 | medium] [Linux]

input=$(cat)

# Caveman badge — delegates to caveman plugin hook
caveman_out=$(echo "$input" | bash "$HOME/.claude/hooks/caveman-statusline.sh" 2>/dev/null)
[ -n "$caveman_out" ] && printf '%s ' "$caveman_out"

# Model + effort — combined in one bracket
# jq not assumed present; use python3 (available on all modern Linux/macOS)
model=$(echo "$input" | python3 -c "
import sys, json
d = json.load(sys.stdin)
m = d.get('model', '')
print(m if isinstance(m, str) else m.get('display_name') or m.get('id', ''))
" 2>/dev/null)
effort=$(python3 -c "
import json, os
p = os.path.expanduser('~/.claude/settings.json')
d = json.load(open(p))
print(d.get('effortLevel', ''))
" 2>/dev/null)
if [ -n "$model" ] && [ -n "$effort" ]; then
  printf '\033[38;5;75m[%s | %s]\033[0m' "$model" "$effort"
elif [ -n "$model" ]; then
  printf '\033[38;5;75m[%s]\033[0m' "$model"
fi

# OS — uname -s returns "Linux" or "Darwin"
os=$(uname -s 2>/dev/null)
[ -n "$os" ] && printf ' \033[38;5;214m[%s]\033[0m' "$os"
