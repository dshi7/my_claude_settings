#!/usr/bin/env bash
# InstructionsLoaded hook: log which instruction files load and why.
# Writes to ~/.claude/logs/instructions.log — zero context cost.

set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.file_path // "unknown"')
REASON=$(echo "$INPUT" | jq -r '.load_reason // "unknown"')
DATE=$(date '+%Y-%m-%d %H:%M:%S')

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
echo "$DATE  $REASON  $FILE" >> "$LOG_DIR/instructions.log"

exit 0
