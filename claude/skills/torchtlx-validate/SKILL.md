---
name: torchtlx-validate
description: Run the TorchTLX validation panel. Tests, benchmarks, and reviews
  a TLX implementation against quality criteria.
---

# TorchTLX Validation Panel

You are orchestrating validation with 3 agents. Follow these steps:

## Step 1 — Load context

Read ALL of these files with the Read tool:
- `~/.claude/skills/torchtlx/SKILL.md` (conventions)
- `~/.claude/knowledge/torchtlx/panels/validation/agent-test.md`
- `~/.claude/knowledge/torchtlx/panels/validation/agent-bench.md`
- `~/.claude/knowledge/torchtlx/panels/validation/agent-review.md`
- `~/.claude/internal/torchtlx-testing.md` (FB-internal test commands)
- `~/.claude/internal/torchtlx-bench.md` (FB-internal benchmark commands)

## Step 2 — Confirm scope

Ask the user what to validate:
- Specific files changed?
- Run tests, benchmarks, or review? (or all three?)

## Step 3 — Test Runner

Using the test agent's role and the commands from `torchtlx-testing.md`:
1. Run the relevant unit tests
2. Parse results: identify failures, extract error messages
3. Classify failures (numerical mismatch, compilation error, config error, setup error)
4. Suggest fixes for any failures

## Step 4 — Benchmark Runner

Using the bench agent's role and the commands from `torchtlx-bench.md`:
1. Run EMS benchmarks (ref vs TLX)
2. Compare MFU against baselines
3. Flag regressions (>2% MFU drop is real)
4. Report improvements with confidence level

## Step 5 — Code Reviewer

Using the review agent's checklist:
1. Check constraint C1 compliance (no unnecessary OSS changes)
2. Verify xplat sync (mirrors updated)
3. Validate kernel naming (`fused_tlx_` prefix)
4. Check config validation (`_is_valid_config`, `_is_valid_config_with_margin`)
5. Verify test coverage (shapes, dtypes, skip decorators, tolerances)
6. Check for fb imports in OSS code

## Step 6 — Combined report

Present results:

| Agent | Status | Summary |
|-------|--------|---------|
| Tests | PASS/FAIL | X/Y passed, N failures |
| Benchmarks | PASS/REGRESS/IMPROVE | MFU delta per module |
| Review | PASS/ISSUES | N issues found |

List any blocking issues and suggested fixes.
