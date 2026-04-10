# TorchTLX Validation Panel

3 agents that test, benchmark, and review a TLX implementation.

## Agents

| Agent | File | Role | Internal context |
|-------|------|------|-----------------|
| Test Runner | `agent-test.md` | Runs unit tests, interprets results | `torchtlx-testing.md` |
| Benchmark Runner | `agent-bench.md` | Runs EMS benchmarks, compares MFU | `torchtlx-bench.md` |
| Code Reviewer | `agent-review.md` | Style, xplat sync, constraint compliance | `constraints.md`, `torchtlx.md` |

## Workflow

1. Implementation is done (design panel output approved, code written)
2. User invokes `/torchtlx-validate`
3. **Test Runner**: runs unit tests, reports pass/fail, suggests fixes for failures
4. **Benchmark Runner**: runs EMS benchmarks (ref vs TLX), compares MFU against baselines, flags regressions
5. **Code Reviewer**: checks xplat sync, constraint compliance, kernel naming, tolerance values
6. Combined report: pass/fail + perf delta + review findings

## Dependencies

Test Runner and Benchmark Runner need FB-internal context files for buck commands
and baseline numbers. These are loaded via @-import from `~/.claude/internal/`.
