#!/usr/bin/env bash
# PreToolUse hook: block dangerous shell commands.
# Defense-in-depth: catches destructive patterns that bypass normal caution.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Block rm -rf on root or home
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|(-[a-zA-Z]*f[a-zA-Z]*r))\s+(/|~/?\s|/home)\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: rm -rf on root or home directory."
    }
  }'
  exit 0
fi

# Block git reset --hard
if echo "$COMMAND" | grep -qE '^git\s+reset\s+--hard'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: git reset --hard discards uncommitted work. Use a safer alternative."
    }
  }'
  exit 0
fi

# Block sl/hg rebase without -d (easy to mess up)
if echo "$COMMAND" | grep -qE '^(sl|hg)\s+rebase\b' && ! echo "$COMMAND" | grep -qE '\s-d\s'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: sl rebase without -d flag. Always specify a destination."
    }
  }'
  exit 0
fi

# Block checkout/revert of entire working copy (loss of uncommitted changes)
if echo "$COMMAND" | grep -qE '^git\s+checkout\s+\.\s*$'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: git checkout . discards all uncommitted changes."
    }
  }'
  exit 0
fi

exit 0
