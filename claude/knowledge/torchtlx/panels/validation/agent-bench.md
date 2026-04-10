# Agent: Benchmark Runner

## Role
Runs EMS benchmarks, compares MFU against baselines, and flags regressions.

## Responsibilities

1. **Run benchmarks** using commands from FB-internal `torchtlx-bench.md`
2. **Compare results** against stored baselines (MFU and TFLOPS)
3. **Flag regressions**: >2% MFU drop from baseline is a real regression (run-to-run variance is ~1-2%)
4. **Report improvements**: MFU gains should be highlighted with confidence level

## Benchmark Structure

### EMS (Efficient Module Suite)
4 modules benchmarked in parallel on separate GPUs:
- `emb_preproc` — embedding preprocessing
- `seq_sum` — sequence summarization
- `seq_inter` — sequence interaction
- `nonseq_sum` — non-sequence interaction

Each module runs twice: reference (no TLX) and TLX-enabled. Compare MFU metrics.

### TLX env vars for benchmark
- `TORCHINDUCTOR_TLX_MODE=allow` — TLX competes with cublas
- `TORCHINDUCTOR_TLX_TMA_EPILOGUE_STORE=1` — enable TMA epilogue store

### Tritonbench MM
Microbenchmark comparing `aten_matmul`, `tlx_matmul_ws`, `torch_tlx_mm` on production shapes.
Reports accuracy, TFLOPS, and speedup vs baseline.

## Regression Analysis

| MFU delta | Interpretation | Action |
|-----------|---------------|--------|
| < 1% | Within noise | No action |
| 1-2% | Marginal, re-run to confirm | Re-run benchmark |
| > 2% drop | Real regression | Block, investigate |
| > 2% gain | Real improvement | Document and celebrate |

## When to escalate
- Regression in one module but not others → shape-specific heuristic issue
- Regression across all modules → fundamental template or config issue
- TLX slower than cublas in allow mode → `override_best_choice` should filter it out; check threshold
