# claude-settings

My Claude Code settings — general preferences and rules for AI-assisted development.

## Structure

```
claude/                              # OSS layer — git-tracked
├── CLAUDE.md                        # Global prefs + @-imports to internal/
├── settings.json                    # Hooks wiring (PreToolUse, SessionStart, etc.)
├── rules/
│   ├── shell-safety.md              # Shell command guardrails
│   └── kernel-style.md              # GPU kernel conventions (path-scoped)
├── hooks/
│   ├── vcs-guard.sh                 # Block wrong VCS commands (PreToolUse)
│   ├── commit-guard.sh              # Block commit/amend/submit (PreToolUse)
│   ├── danger-guard.sh              # Block destructive commands (PreToolUse)
│   ├── session-start.sh             # Inject hostname + GPU type (SessionStart)
│   ├── cwd-changed.sh               # Set REPO_VCS env var (CwdChanged)
│   ├── post-compact.sh              # Persist summary to workstreams.md (PostCompact)
│   └── instructions-loaded.sh       # Debug logging (InstructionsLoaded)
└── knowledge/
    └── pytorch/
        ├── README.md                # Pointers to pytorch repo skills
        └── SKILL.md                 # Distilled conventions (on-demand skill)

templates/                           # Git-tracked templates for internal layer
└── internal/
    ├── fb-internal.md               # Domain, devserver hosts, repo paths
    └── memory/
        ├── repos.md                 # Repo map scaffold
        ├── workstreams.md           # Workstreams scaffold
        └── decisions.md             # ADR log scaffold
```

After `install.sh --internal`, the internal layer is installed to `~/.claude/internal/`
and synced across devservers via dotsync2.

## Install

```bash
./install.sh              # OSS files only
./install.sh --internal   # also copy internal configs + scaffold memory
```

**Requires `jq`** — install.sh deep-merges hooks from the repo into your
existing `~/.claude/settings.json`, preserving `enabledPlugins`, `env`, and
other live keys. Without jq, it falls back to a plain copy.

## Two-layer design

- **OSS layer** (git-tracked): Preferences, rules, hooks, knowledge base.
- **Internal layer** (.gitignored): Host maps, workstreams, memory. Distributed via dotsync2.

CLAUDE.md uses `@`-import syntax to load internal files at session start.
Missing files are silently skipped.

## Hooks

Hooks are shell scripts that run at specific lifecycle events, wired via `settings.json`.
All hooks read JSON from stdin and output JSON to stdout. Exit code 0 = success,
exit code 2 = blocking error.

| Hook | Event | Purpose |
|------|-------|---------|
| `vcs-guard.sh` | PreToolUse (Bash) | Blocks `hg` in git repos and `git` in hg repos |
| `commit-guard.sh` | PreToolUse (Bash) | Blocks commit, amend, force-push, and jf submit |
| `danger-guard.sh` | PreToolUse (Bash) | Blocks `rm -rf /`, `git reset --hard`, rebase without `-d` |
| `session-start.sh` | SessionStart | Injects devserver hostname and GPU type into context |
| `cwd-changed.sh` | CwdChanged | Sets `REPO_VCS=hg|git|none` env var |
| `post-compact.sh` | PostCompact | Appends compact summary to `workstreams.md` |
| `instructions-loaded.sh` | InstructionsLoaded | Logs loaded files to `~/.claude/logs/` |

### Testing hooks

Test any PreToolUse hook with mock JSON:

```bash
# Should deny:
echo '{"tool_input":{"command":"sl commit -m test"},"cwd":"/tmp"}' | bash claude/hooks/commit-guard.sh

# Should deny:
echo '{"tool_input":{"command":"git reset --hard HEAD~3"},"cwd":"/tmp"}' | bash claude/hooks/danger-guard.sh

# Should pass (no output):
echo '{"tool_input":{"command":"sl diff"},"cwd":"/tmp"}' | bash claude/hooks/commit-guard.sh
```

## Knowledge base

`knowledge/pytorch/` contains a skill (on-demand, not auto-loaded) with distilled
coding conventions, test patterns, and logging. The skill triggers automatically
when working in the pytorch repo, or invoke with `/pytorch-style`.

Pointers to the pytorch repo's own Claude skills (PR review, PT2 debugging,
issue triage) are in `knowledge/pytorch/README.md` — reference them on demand.

## Memory schema

| File | Loaded | Update when |
|------|--------|-------------|
| `repos.md` | Every session | Repo layout or build system changes |
| `workstreams.md` | Every session | Starting or finishing a workstream |
| `decisions.md` | On demand | Append-only; never edit past entries |
