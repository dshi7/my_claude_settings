#!/usr/bin/env bash
# PreToolUse hook: block hg commands in git repos and git commands in hg repos.
# Reads tool input JSON from stdin.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

# Detect VCS in cwd
in_hg=false
in_git=false

if cd "$CWD" 2>/dev/null && hg root &>/dev/null 2>&1; then
  in_hg=true
fi
if cd "$CWD" 2>/dev/null && git rev-parse --git-dir &>/dev/null 2>&1; then
  in_git=true
fi

# Block hg commands in a git-only repo
if $in_git && ! $in_hg; then
  if echo "$COMMAND" | grep -qE '^hg '; then
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "hg command blocked: this is a git repo. Use git commands instead."
      }
    }'
    exit 0
  fi
fi

# Block git commands in an hg-only repo
if $in_hg && ! $in_git; then
  if echo "$COMMAND" | grep -qE '^git '; then
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "git command blocked: this is an hg/Mercurial repo. Use hg commands instead."
      }
    }'
    exit 0
  fi
fi

exit 0
