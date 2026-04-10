# TorchTLX Knowledge Base

TorchTLX (Triton Language Extensions) spans two repos:
- **pytorch/pytorch** — Inductor backend, TLX template system, torch.compile integration
- **facebookexperimental/triton** — Triton compiler, TLX language extensions

## Local skill: `SKILL.md`

Distilled TLX design patterns, code review checklist, and conventions.
Auto-triggers when working on TLX-related code, or invoke explicitly:
```
/torchtlx-style
```

## Reference from repos (load on demand)

PyTorch repo skills (see `knowledge/pytorch/README.md`):
```
@/data/users/daohang/pytorch/.claude/skills/pr-review/SKILL.md
@/data/users/daohang/pytorch/.claude/skills/pt2-bug-basher/SKILL.md
```

FB-internal context (CI, fbcode paths, agent system) is in
`~/.claude/internal/torchtlx.md`, loaded via @-import.
