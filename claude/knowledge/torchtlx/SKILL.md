---
name: torchtlx-style
description: Use when working on TorchTLX (Triton Language Extensions) across
  pytorch/pytorch and facebookexperimental/triton. Covers TLX template design,
  Inductor integration, kernel authoring patterns, and code review guidance.
---

# TorchTLX Conventions

<!-- TODO: Distill from existing torchtlx agent system and working knowledge.
     This is a scaffold — fill in as patterns solidify. -->

## Architecture

- TLX templates live in the Inductor backend (pytorch repo)
- Triton compiler extensions live in facebookexperimental/triton
- Changes often span both repos — coordinate landing order

## Design Patterns

- Prefer composable TLX templates over monolithic kernels
- Template parameters should have clear type annotations
- Test against both eager and compiled paths

## Code Review Checklist

- [ ] Template composes correctly with existing templates
- [ ] Kernel correctness validated against PyTorch eager reference
- [ ] Performance tested at representative shapes
- [ ] Both repos updated if interface changes

## Testing

- Use `buck test` in fbsource for integration tests
- Use pytest in fbtriton for compiler-level tests
- Always test with real GPU shapes, not just small synthetic ones
