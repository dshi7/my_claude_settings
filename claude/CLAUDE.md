# Preferences

- **Always plan before coding**: show a brief plan and wait for confirmation.
  Only skip for single-line fixes, typos, or obvious one-liner changes.
- **Do NOT run source control commit commands** (e.g., `git commit`, `sl commit`, `sl amend`).
  Leave changes uncommitted for me to review and commit myself.
  (Also enforced by `commit-guard.sh` hook.)
- **Always confirm before sending messages** to anyone other than me.
  If a name/alias resolves to multiple people, confirm which one before sending.

# Architecture

<!-- Two-layer design:
     - OSS layer (this repo): preferences, rules, hooks, knowledge. Git-tracked.
     - Internal layer (~/.claude/internal/): host context, memory, Meta-specific.
       Distributed via dotsync2, .gitignored. @-imports below load these if present;
       missing files are silently skipped by Claude Code. -->

@~/.claude/internal/fb-internal.md
@~/.claude/internal/memory/repos.md
@~/.claude/internal/memory/workstreams.md

# Project context

Use `/project` to load project-specific internal context on demand.
