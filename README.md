# claude-settings

My Claude Code settings — general preferences and rules for AI-assisted development.

## Structure

```
claude/
├── CLAUDE.md              # General preferences (loaded as ~/.claude/CLAUDE.md)
├── rules/
│   └── shell-safety.md    # Shell command guardrails
└── internal/              # .gitignored — host/project-specific configs
    ├── meta-internal.md   #   domain, repos, hosts
    ├── settings.json      #   plugin config
    ├── settings.local.json#   local permissions
    └── memory/            #   project memory files
```

## Install

Copy settings into `~/.claude/`:

```bash
./install.sh              # OSS files only
./install.sh --internal   # also copy internal configs
```

## Two-layer design

- **OSS layer** (git-tracked): General, portable settings — preferences, shell safety rules.
- **Internal layer** (.gitignored): Host maps, project-specific rules, memory files. Distributed separately (e.g., via dotsync2).

Both layers are loaded by Claude Code. The `internal/` folder is referenced in `CLAUDE.md` so Claude knows to look there.
