---
name: fbtriton-ci
description: Use when working on FBTriton CI — test infrastructure, CI pipelines,
  watchlist management, and test debugging for facebookexperimental/triton.
---

# FBTriton CI Conventions

<!-- TODO: Distill from CI workflow knowledge.
     This is a scaffold — fill in as patterns solidify. -->

## CI Workflow

- CI runs on PR submission and updates
- Watchlist tracks flaky/failing tests across commits

## Test Patterns

- Tests organized by component (compiler, runtime, integration)
- Use the triton test runner for GPU tests
- Mark known-flaky tests appropriately

## Debugging CI Failures

- Check watchlist status first (`/triton-ci-status`)
- Distinguish infra failures from real test failures
- Reproduce locally before investigating further
