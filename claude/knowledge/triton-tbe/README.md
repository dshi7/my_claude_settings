# Triton TBE Knowledge Base

TBE (Table Batched Embedding) kernels implemented in Triton, based on
**pytorch/FBGEMM** (reference CUDA/FBGEMM implementation) and
**facebookexperimental/triton** (Triton compiler).

## Local skill: `SKILL.md`

TBE kernel patterns, performance conventions, and testing guidance.
Invoke with:
```
/triton-tbe
```

## FB-internal context

Internal benchmark targets and oncall context are in
`~/.claude/internal/triton-tbe.md`, loaded via @-import.
