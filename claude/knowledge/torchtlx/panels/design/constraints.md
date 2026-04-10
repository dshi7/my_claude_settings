# Cross-Cutting Constraints

All agents MUST respect these constraints when proposing designs.

## C1: Minimize OSS PyTorch Changes

**Priority: Hard constraint**

TorchTLX is built on top of PyTorch Inductor. New TLX features must avoid
modifying OSS Inductor code whenever possible. All TLX logic lives in the
FB-only TLX templates directory.

### Approved Pattern: Subclass + Factory + Virtual Hook

1. **Define a hook in the OSS base class** (`InductorChoices`) with a no-op/pass-through default
2. **Override in FB subclass** (`TLXInductorChoices`) with TLX-specific behavior
3. **Register via factory** in `registry.py`
4. **Dispatch via `V.choices`** — OSS code calls `V.choices.method()`, polymorphic dispatch handles the rest

### Key Properties
- No fb imports in OSS code — OSS only references `V.choices` and `InductorChoices`
- Deferred import via factory — avoids circular dependencies
- Runtime mode check — every override checks `tlx_mode`, falls through to `super()` when disabled
- Config-based registration — `config.inductor_choices_class` is the single injection point

### When OSS Changes Are Unavoidable
If a new hook point is truly needed in OSS:
- The hook must have a sensible default (no-op or identity)
- It must not expose TLX-specific concepts
- It must be general enough that other backends could use it
- Flag this in the design for explicit user approval

## C2: All Testing in fbsource via Buck

TorchTLX is entirely in fbsource. No OSS CI from pytorch repo.
- Unit tests: `buck test` or `buck run`
- Benchmarks: `buck run` with EMS or tritonbench targets
- Never reference or verify against pytorch OSS CI

See FB-internal testing context (`torchtlx-testing.md`) for specific commands.
