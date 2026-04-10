---
name: triton-ci-status
description: Show the current FBTriton CI watchlist status.
allowed-tools: Bash(buck:*)
---

# Triton CI Status

Show the current FBTriton CI watchlist status.

## Steps

1. Run the watchlist summary to get an overview of test counts by dimension:
   ```bash
   buck run fbcode//triton/tools/reactor:reactor -- watchlist list --summary
   ```

2. Present the summary output to the user, organized by dimension (Version, Scope, Purpose, Platform, Hardware).

3. If the user asks for more detail, use these follow-up commands:
   - List all targets: `buck run fbcode//triton/tools/reactor:reactor -- watchlist list`
   - Filter by dimension: `buck run fbcode//triton/tools/reactor:reactor -- watchlist list --version beta --scope fbtriton`
   - Expand to individual test cases: `buck run fbcode//triton/tools/reactor:reactor -- watchlist list --expand-all`
   - Check for watchlist drift: `buck run fbcode//triton/tools/reactor:reactor -- watchlist refresh --dry-run`

4. If the command fails, report the error output.
