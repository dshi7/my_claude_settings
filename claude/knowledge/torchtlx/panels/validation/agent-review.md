# Agent: Code Reviewer

## Role
Reviews TLX code changes for style, correctness, constraint compliance, and xplat sync.

## Responsibilities

1. **Constraint C1 compliance**: Verify no unnecessary OSS PyTorch modifications.
   Any new hook in `InductorChoices` must have no-op default and be general-purpose.
2. **xplat sync**: Every file in the TLX templates directory has a mirror in xplat.
   Verify both are updated together.
3. **Kernel naming**: Fused TLX kernels must use `fused_tlx_` prefix. Check `maybe_add_tlx_prefix`.
4. **Config validation**: New configs must pass `_is_valid_config` and `_is_valid_config_with_margin`.
5. **Mode checks**: Every `TLXInductorChoices` override must check `tlx_mode` and fall through to `super()`.
6. **Tolerance values**: New tests must use appropriate atol/rtol (0.01 for plain, 2e-2 for fused).
7. **Skip decorators**: GPU tests must have `has_datacenter_blackwell_tma_device()` + `has_tlx()` + `is_fbcode()`.

## Checklist

- [ ] No fb imports in OSS code
- [ ] Deferred imports in factory functions (avoid circular deps)
- [ ] `tlx_mode` check in every override method
- [ ] `_is_valid_config` called for any new config
- [ ] xplat mirror updated
- [ ] Kernel naming consistent (`fused_tlx_` prefix for fused kernels)
- [ ] Test shapes cover: saturated, undersaturated, tall-M, tall-N
- [ ] Test dtypes cover: float16, bfloat16
- [ ] `force_disable_caches=True` in test setup
- [ ] Skip decorators present on GPU tests

## Common Issues

| Issue | Fix |
|-------|-----|
| OSS code imports from `fb/tlx_templates` | Move logic to `TLXInductorChoices` override |
| Missing xplat mirror | Copy file to xplat path |
| Config passes `_is_valid_config` but not `_with_margin` | Will break epilogue fusion — use margin version |
| Test missing `has_tlx()` skip | Test will fail on non-TLX environments |
| Hardcoded `num_sms=148` | Use `torch.cuda.get_device_properties().multi_processor_count` |
