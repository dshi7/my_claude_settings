---
name: debug-tlparse
description: Debug tlparse issues by running tlparse with verbose logging and analyzing output. Use when the user encounters tlparse errors or wants to troubleshoot tlparse behavior.
allowed-tools: Read, Bash(lg:*), Bash(mast:*), Bash(buck:*), Bash, Grep, Glob
---

# Debug tlparse

## When To Use
- User reports tlparse failures, crashes, or unexpected behavior
- User wants to investigate tlparse output or logs
- User needs help interpreting tlparse error messages

## Quick Reference

| Action | Command |
|--------|---------|
| Run tlparse | `buck run @//mode/opt fbcode//caffe2/fb/tlparse:tlparse` |
| Run with verbose logging | `buck run @//mode/opt fbcode//caffe2/fb/tlparse:tlparse -- -v` |
| Run with specific input | `buck run @//mode/opt fbcode//caffe2/fb/tlparse:tlparse -- -v <input_file>` |

## Workflow

1. **Get the failing command**: Ask the user to provide the exact command or invocation that is failing. For example:
   - "What command are you running that produces the error?"
   - "Please paste the full command and its output so I can reproduce the issue."

   If the user hasn't provided a command yet, prompt them:
   > Please share the exact tlparse command (or pipeline) that is failing, along with any error output you see.

2. **Reproduce the issue**: Once you have the failing command, re-run it with verbose logging enabled to capture detailed output:
   ```bash
   buck run @//mode/opt fbcode//caffe2/fb/tlparse:tlparse -- -v <user's arguments>
   ```
   Compare the verbose output with what the user reported.

3. **Analyze verbose output**: Look for error messages, warnings, or unexpected behavior in the verbose log output.

4. **Check the source code**: If the error points to specific parsing logic, examine the tlparse source:
   ```bash
   # Find relevant source files
   ls fbcode/caffe2/fb/tlparse/
   ```

5. **Identify the root cause**: Based on the verbose logs and source code, determine what is causing the issue.

6. **Propose a fix**: If a code change is needed, locate the relevant file and suggest or apply the fix.

## Common Issues

| Symptom | Likely Cause | Action |
|---------|-------------|--------|
| Parse failure | Malformed input or unsupported format | Check input format against expected schema |
| Crash / panic | Unhandled edge case in parser | Run with `-v` and check stack trace |
| Unexpected output | Logic error in transformation | Compare verbose log with expected behavior |
| Build failure | Missing dependency or Buck config issue | Check TARGETS/BUCK file and dependencies |
| "No pre-existing report" warning | Report hasn't been generated yet | This is a benign warning, not a bug. Proceed to generate the report. |
| "No torch trace logs found for this job" | log downloading failed.| This does NOT mean the job had no issues. Still check the `lg` download step for problems — the logs may have failed to download or the time range may be wrong. |
| "Logarithm is throttling queries" | Transient throttling from the Logarithm service | Retry the same command — this is a transient issue. You can also try suggestions from the error message, such as adding `--slow-download` to the `lg` command. |

## Debugging Log Download Failures

If the log download step failed (i.e., the `lg ...` command returned no results or errored):

1. **Retry the download manually**: Create a temporary folder and run the `lg` command again to download to this folder. If that also fails, the problem is with downloading the file itself.

2. **Pass the downloaded file directly to tlparse**: When you manually download logs with `lg`, the resulting filenames are prefixed with `log.{job_handle}.` which causes tlparse's directory scanner to skip them (it expects filenames starting with `dedicated_log_torch_trace_`). To work around this, pass the log file path directly instead of the directory:
   ```bash
   buck run @//mode/opt fbcode//caffe2/fb/tlparse:tlparse -- /path/to/log.tsp_rcd_...dedicated_log_torch_trace_rank_0_...
   ```
   Do NOT pass the directory — pass the full file path.

3. **Diagnose the download issue**: If the download fails, install and use the `logarithm-cli` skill to debug:
   ```bash
   claude-templates skill logarithm-cli install
   ```
   Then invoke the skill to troubleshoot the `lg` command — it will help verify the command syntax is correct and check whether the `--start-time` and `--end-time` timestamps passed to `lg` are correct (they should cover the job's actual runtime window).

## Proposing a Fix

Once you've identified the root cause, propose a fix to the tlparse source code:

1. **Locate the relevant source file**: The tlparse source lives at `fbcode/caffe2/fb/tlparse/`. The main parsing logic is in `src/lib.rs`.
   ```bash
   ls fbcode/caffe2/fb/tlparse/src/
   ```

2. **Make the code change**: Edit the appropriate file to fix the issue. Common fix locations:
   - Log file discovery/filtering: `src/lib.rs` (look for `copy_file_to_tmpdir`, `parse_logs`)
   - CLI argument handling: `src/cli_main.rs` or `src/cli_log.rs`
   - Log downloading: `src/lib.rs` (look for `download_logs`)

3. **Test the fix**: Rebuild and re-run tlparse against the same input that was failing:
   ```bash
   buck run @//mode/opt fbcode//caffe2/fb/tlparse:tlparse -- -v <original failing input>
   ```

## Performance Tips
- **tlparse and lg commands can be very slow** (minutes). Run them in the background using `run_in_background`, a subagent, or any async mechanism so you can continue working on proposing a fix while waiting for results.
- **Always use opt mode**: You need `buck run @//mode/opt fbcode//caffe2/fb/tlparse:tlparse` — note the `@//mode/opt`. tlparse running time can be much slower without it, especially for inductor code highlighting and Symbolic shape processing. If the user gives a command without `@//mode/opt`, prompt them to add it.

## Updating Third-Party tlparse Version

Use this workflow when the user wants to update the vendored tlparse crate to a new version (e.g. 0.4.8). This follows the standard [Rust third-party library update process](https://www.internalfb.com/wiki/Rust/Third_Party_Code/Adding_or_Updating_Libraries/). See [D82322715](https://www.internalfb.com/diff/D82322715) for a real example of updating tlparse from 0.4.2 to 0.4.3.

### Step 1: Edit Cargo.toml

Update the tlparse version in `third-party/rust/Cargo.toml`. The entry is in the `[dependencies]` section — find the `tlparse = "..."` line and change it to the target version:

```bash
# Find the current version
grep 'tlparse' third-party/rust/Cargo.toml
```

Edit the file to set the new version, e.g. `tlparse = "0.4.8"`. Keep entries alphabetized.

### Step 2: Run Reindeer vendor

This downloads the new crate source (including transitive dependencies), updates `Cargo.lock`, and regenerates `third-party/rust/BUCK`:

```bash
cd ~/fbsource
fbcode/common/rust/tools/reindeer/vendor
```

This command can take several minutes. Run it in the background so you can continue responding to the user while it completes.

**Important:** This command requires internet access to download crates from crates.io and git dependencies from GitHub. If you get HTTP 403 errors from a proxy or network timeouts, either:
- Ask the user to run `fbcode/common/rust/tools/reindeer/vendor` themselves from a terminal with internet access, or
- Ensure Claude is started in an environment with internet access (e.g., a devserver with proxy configured or a sandcastle with network enabled).

**Note:** If Reindeer reports fixup issues, see the [Fixups wiki](https://www.internalfb.com/wiki/Rust/Third_Party_Libraries/Fixups/) for guidance.

### Step 3: Handle large test files

tlparse vendors test input files that can be very large. Check if any new test input files are too large for the repo and add them to `third-party/rust/.gitignore` if needed. For example, D82322715 added:

```
/vendor/tlparse-*/tests/inputs/inductor_provenance_long_log.txt
```

Check for large files in the new vendor directory:

```bash
find third-party/rust/vendor/tlparse-*/tests/ -size +1M -type f
```

Add any large files to `third-party/rust/.gitignore` using glob patterns with `tlparse-*` so they apply to future versions too.

### Step 4: Build tlparse to verify

Build the tlparse buck target to confirm the updated crate compiles correctly:

```bash
buck build @//mode/opt fbcode//caffe2/fb/tlparse:tlparse
```

Then do a quick smoke test by running tlparse against one of the vendored test input files:

```bash
buck run @//mode/opt fbcode//caffe2/fb/tlparse:tlparse -- third-party/rust/vendor/tlparse-<VERSION>/tests/inputs/<some_test_file>
```

If the build fails, check for API changes in the new version and update `fbcode/caffe2/fb/tlparse/` source code accordingly.

### Step 5: Submit the diff

Create a commit and submit as a draft diff:

```bash
sl commit -m "[tlparse] Update third-party tlparse to <VERSION>

Summary: Update tlparse to <VERSION>

Test Plan:
\`\`\`
fbcode/common/rust/tools/reindeer/vendor
\`\`\`
"

jf submit --draft
```

## Tips
- Always start with `-v` (verbose) to get the most diagnostic information
- If the issue is intermittent, try running multiple times to see if output changes
- `@//mode/opt` resolves relative to your working directory. Either run from `fbcode/` or use `@fbcode//mode/opt` instead.
- Check recent diffs to `fbcode/caffe2/fb/tlparse/` if the issue started recently
