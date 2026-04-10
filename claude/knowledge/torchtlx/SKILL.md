---
name: torchtlx-style
description: Use when working on TorchTLX (Triton Language Extensions) across
  pytorch/pytorch and facebookexperimental/triton. Covers TLX template design,
  Inductor integration, kernel authoring patterns, and code review guidance.
---

# TorchTLX Conventions

## Architecture

- TLX templates live in the Inductor backend (pytorch repo)
- Triton compiler extensions live in facebookexperimental/triton
- Changes often span both repos — coordinate landing order
- TLX integrates via `TLXInductorChoices` subclass + factory + hook pattern (minimize OSS changes)

## Design Patterns

- Prefer composable TLX templates over monolithic kernels
- Template parameters should have clear type annotations
- Every `TLXInductorChoices` override must check `tlx_mode` and fall through to `super()`
- Fused TLX kernels must use `fused_tlx_` prefix (see `maybe_add_tlx_prefix`)
- New configs must pass `_is_valid_config` and `_is_valid_config_with_margin`
- No fb imports in OSS code; deferred imports in factory functions (avoid circular deps)

## Code Review Checklist

- [ ] Template composes correctly with existing templates
- [ ] Kernel correctness validated against PyTorch eager reference
- [ ] Performance tested at representative shapes (saturated, undersaturated, tall-M, tall-N)
- [ ] Both repos updated if interface changes
- [ ] xplat mirror updated for any file in TLX templates directory
- [ ] No hardcoded `num_sms` — use `torch.cuda.get_device_properties().multi_processor_count`

## Testing

- Use `buck test` in fbsource for integration tests
- Use pytest in fbtriton for compiler-level tests
- Tolerances: `atol=0.01` for plain matmul, `atol=2e-2` for fused epilogue
- GPU tests require `has_datacenter_blackwell_tma_device()` + `has_tlx()` + `is_fbcode()` skips
- Always use `force_disable_caches=True` in test setup
- Cover float16 and bfloat16 dtypes

## Agent Panels

For complex design or validation tasks, use the agent panels:

- **Design panel** (`panels/design/`): 6 expert agents collaborate sequentially to produce
  a design proposal. Agents: TLX Upstream, Kernel Architect, Inductor Integration,
  Heuristics & Autotuning, Fusion & Epilogue, Higher-Order Ops.
- **Validation panel** (`panels/validation/`): 3 agents test, benchmark, and review an
  implementation. Agents: Test Runner, Benchmark Runner, Code Reviewer.
