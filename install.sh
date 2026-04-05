#!/bin/bash
# Install Claude settings into ~/.claude/
# Run from the git repo root.
#
# Usage:
#   ./install.sh              # copy OSS files only
#   ./install.sh --internal   # also copy internal/ files

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude settings from $SCRIPT_DIR -> $CLAUDE_DIR"

# Copy general CLAUDE.md
cp "$SCRIPT_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  copied CLAUDE.md"

# Copy rules (merge into existing rules/)
mkdir -p "$CLAUDE_DIR/rules"
for f in "$SCRIPT_DIR/claude/rules/"*; do
  [ -f "$f" ] || continue
  cp "$f" "$CLAUDE_DIR/rules/$(basename "$f")"
  echo "  copied rules/$(basename "$f")"
done

# Optionally copy internal files
if [ "${1:-}" = "--internal" ] && [ -d "$SCRIPT_DIR/claude/internal" ]; then
  mkdir -p "$CLAUDE_DIR/rules"
  for f in "$SCRIPT_DIR/claude/internal/"*.md; do
    [ -f "$f" ] || continue
    cp "$f" "$CLAUDE_DIR/rules/$(basename "$f")"
    echo "  copied internal/$(basename "$f") -> rules/"
  done
fi

echo "Done."
