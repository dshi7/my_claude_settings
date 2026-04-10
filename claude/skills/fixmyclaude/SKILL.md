---
name: fixmyclaude
description: Self-check and diagnose Claude Code setup — settings, hooks, skills, internal context, rules, and @-imports.
---

# Fix My Claude

Audit the Claude Code installation. Run ALL checks below, report a summary
table, then offer to fix issues.

## 1. CLAUDE.md

- `~/.claude/CLAUDE.md` exists and is non-empty
- Parse all `@` lines — for each @-import, verify the target file exists
- Report any @-imports pointing to missing files

## 2. Settings & hooks

Read `~/.claude/settings.json` and check:
- `hooks` key exists with these events: `PreToolUse`, `PostCompact`, `SessionStart`, `CwdChanged`, `InstructionsLoaded`
- For each hook command referencing a script path, verify the script exists on disk
- Verify hook scripts are executable (`test -x`)
- Check for stale hooks: scripts in `~/.claude/hooks/` not referenced by settings.json

Expected hooks:
| Script | Event |
|--------|-------|
| `vcs-guard.sh` | PreToolUse |
| `commit-guard.sh` | PreToolUse |
| `danger-guard.sh` | PreToolUse |
| `session-start.sh` | SessionStart |
| `cwd-changed.sh` | CwdChanged |
| `post-compact.sh` | PostCompact |
| `instructions-loaded.sh` | InstructionsLoaded |

## 3. Rules

Check `~/.claude/rules/` contains:
- `shell-safety.md`
- `kernel-style.md`

Report any missing rules.

## 4. Skills

Check `~/.claude/skills/` contains these directories, each with a `SKILL.md`:
- `project`
- `torchtlx-design`
- `torchtlx-validate`
- `devenv`
- `fixmyclaude`
- `pytorch`
- `torchtlx`
- `fbtriton-ci`
- `triton-tbe`
- `debug-tlparse`
- `triton-ci-status`

Report missing or empty SKILL.md files.

## 5. Internal context

Check `~/.claude/internal/` contains:
- `fb-internal.md`
- `torchtlx.md`
- `torchtlx-testing.md`
- `torchtlx-bench.md`
- `fbtriton-ci.md`
- `triton-tbe.md`

Check `~/.claude/internal/memory/` contains:
- `repos.md`
- `workstreams.md`
- `decisions.md`

Report missing files. These are scaffolded by `install.sh --internal`.

## 6. Knowledge base

Check `~/.claude/knowledge/` contains directories with README.md:
- `pytorch`
- `torchtlx`
- `fbtriton-ci`
- `triton-tbe`
- `debug-tlparse`

Check `~/.claude/knowledge/torchtlx/panels/` exists with:
- `design/README.md` + 6 agent files + `constraints.md`
- `validation/README.md` + 3 agent files

## 7. Dependencies

- `jq` available on PATH (required for hooks and install.sh)
- `nvidia-smi` available (for session-start.sh GPU detection)

## Summary

Present results as:

| Check | Status | Details |
|-------|--------|---------|
| CLAUDE.md | PASS/FAIL | N @-imports, M missing |
| Settings | PASS/FAIL | N hooks wired |
| Hook scripts | PASS/FAIL | N present, M missing/not-executable |
| Rules | PASS/FAIL | N/2 present |
| Skills | PASS/FAIL | N/11 present |
| Internal context | PASS/FAIL | N/6 present |
| Internal memory | PASS/FAIL | N/3 present |
| Knowledge base | PASS/FAIL | N dirs, panels status |
| Dependencies | PASS/FAIL | jq, nvidia-smi |

## Fix

For missing files that install.sh can fix:
> Run `init_my_agents` to reinstall from git repo.

For missing internal files only:
> Run `init_my_agents` (includes `--internal` scaffold).

For permission issues on skills (e.g., plugin-owned):
> Report as "skipped (no write access)" — not fixable automatically.

For missing dependencies:
> Report only — require manual install.
