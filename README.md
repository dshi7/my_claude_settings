# claude-settings

My Claude Code settings — general preferences and rules for AI-assisted development.

## Structure

```
claude/
├── CLAUDE.md                    # Global prefs + @-imports for internal context
├── rules/
│   ├── shell-safety.md          # Shell command guardrails
│   └── vcs-detection.md         # hg vs git detection
└── internal/                    # .gitignored — distributed via dotsync2
    ├── meta-internal.md         # Domain, devserver hosts
    ├── settings.json            # Plugin config
    ├── settings.local.json      # Local permissions
    ├── commands/                 # Slash commands (triton-ci-status)
    ├── myclaw-prompts/          # Agentic job prompts
    └── memory/
        ├── repos.md             # Repo map: VCS type, paths, build cmds (stable)
        ├── projects.md          # Active workstreams (volatile)
        ├── decisions.md         # ADR log, append-only (loaded on demand)
        └── torchtlx/            # Multi-agent design system (7 agents)
```

## Install

Copy settings into `~/.claude/`:

```bash
./install.sh              # OSS files only
./install.sh --internal   # also copy internal configs + scaffold memory
```

## Two-layer design

- **OSS layer** (git-tracked): General, portable settings — preferences, shell safety rules, VCS detection.
- **Internal layer** (.gitignored): Host maps, project-specific rules, memory files. Distributed separately (e.g., via dotsync2).

CLAUDE.md uses `@`-import syntax to load internal files at session start. If the files don't exist, they're silently skipped.

## Memory schema

`internal/memory/` uses three fixed files with distinct update cadences:

| File | Loaded | Update when |
|------|--------|-------------|
| `repos.md` | Every session (via `@`-import) | Repo layout or build system changes |
| `projects.md` | Every session (via `@`-import) | Starting or finishing a workstream |
| `decisions.md` | On demand only | Never edit; only append new entries |

To load decisions during a session: `@~/.claude/internal/memory/decisions.md`
