# PyTorch Knowledge Base

Context for working with the PyTorch codebase. A local pytorch repo is assumed
to be available on every devserver.

## Local skill: `SKILL.md`

Distilled coding conventions, testing patterns, and logging. Loaded as a skill
on demand when working in the pytorch repo — not auto-loaded globally.

Invoke explicitly if needed:
```
/pytorch-style
```

## Reference from pytorch repo (load on demand)

The pytorch repo has rich Claude skills — use them directly instead of copying:

```
@/data/users/daohang/pytorch/CLAUDE.md
@/data/users/daohang/pytorch/.claude/skills/pr-review/SKILL.md
@/data/users/daohang/pytorch/.claude/skills/pr-review/review-checklist.md
@/data/users/daohang/pytorch/.claude/skills/pr-review/bc-guidelines.md
@/data/users/daohang/pytorch/.claude/skills/pt2-bug-basher/SKILL.md
```

| Skill | What it does |
|-------|-------------|
| `pr-review/` | PR review workflow + 170-item checklist + BC guidelines |
| `pt2-bug-basher/` | torch.compile error triage, debug env vars, minifier workflow |
| `triaging-issues/` | GitHub issue routing and labeling |
