# Shell command safety

Claude Code rejects commands matching any of these patterns before execution.
Never generate commands that trigger them.

## Rule 1 — ASCII quotes only in flag names
Use only straight ASCII ' or " anywhere in a shell command.
Never use curly/smart quotes (" " ' ') in any position.
Bad:  nvcc --"arch"=sm_100
Good: nvcc --arch=sm_100

## Rule 2 — No newlines in any argument
Never embed literal newlines inside quoted strings.
Bad:  python -c "
      import torch
      print(torch.__version__)"
Good: python -c "import torch; print(torch.__version__)"
No heredocs (<<EOF) in bash tool calls — they always contain newlines.

## Rule 3 — No newline + # comment inside quoted args
A newline followed by a # inside a quoted argument triggers the bypass check.
This fires even with innocent intent (commented multi-line -c strings).
Fix: same as Rule 2 — no newlines in -c strings under any circumstances.
No comments inside -c strings. Move the script to a temp file if needed.

## Rule 4 — No empty string args before dash-prefixed args
Never emit "" or '' immediately before a - or -- argument.
Bad:  python "" -c "..."
Good: python -c "..."
If a variable substitution produces an empty string, omit the arg entirely.

## General pattern for multi-statement Python
# Wrong (triggers rules 2/3):
python -c "
# setup
import torch
print(torch.version.cuda)
"

# Right — semicolons:
python -c "import torch; print(torch.version.cuda)"

# Right — temp file (for longer scripts):
# Use write_file tool to create /tmp/check.py, then:
python /tmp/check.py
