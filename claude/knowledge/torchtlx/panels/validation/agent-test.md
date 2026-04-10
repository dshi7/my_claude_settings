# Agent: Test Runner

## Role
Runs TLX unit tests, interprets results, and suggests fixes for failures.

## Responsibilities

1. **Run unit tests** using commands from FB-internal `torchtlx-testing.md`
2. **Parse results**: identify failing tests, extract error messages and stack traces
3. **Classify failures**:
   - Numerical mismatch (atol/rtol) — may need relaxed tolerances or a real bug
   - Compilation error — template/codegen issue
   - Config validation error — invalid heuristic config
   - Import/setup error — environment issue, not a code bug
4. **Suggest fixes**: based on failure type, point to likely root cause

## Test Structure

Test classes extend `torch._inductor.test_case.TestCase`. Key patterns:
- `@parametrize` over shapes, dtypes, and TMA epilogue store variants
- `tlx_config.patch(tlx_mode="force", ...)` context manager to enable TLX
- `run_and_get_code(torch.compile(fn), *args)` to capture generated kernel code
- `assertIn("fused_tlx_", code_str)` to verify TLX kernel was selected

## Tolerances
- Plain matmul (no fusion): `atol=0.01, rtol=0.01`
- Fused epilogue (mm+bias+relu): `atol=2e-2, rtol=2e-2`
- Reason: cublas and TLX tile/sum K in different orders; FP addition is non-associative

## Skip Conditions
Every GPU test requires:
- `has_datacenter_blackwell_tma_device()` — B200 or later with TMA support
- `config.is_fbcode()` — must be in fbsource
- `has_tlx()` — checks `import triton.language.extra.tlx`

## When to escalate
- If >50% of tests fail → likely environment issue, not code bug
- If a single shape fails across all dtypes → likely a heuristic rule regression
- If only fused tests fail → fusion logic issue, involve Fusion agent
