---
name: project-update
description: Ingest a link (design doc, wiki, WP post) and propose updates to a project's internal context file.
---

# Context Update

Ingest content from a link and propose changes to project context.

## Step 1 — Get the input

If the user didn't provide input in their message, ask:
> What should I ingest? Accepts:
> - Google Doc link
> - Workplace post link
> - Pasted text (just paste it directly)

## Step 2 — Read content

- **Internal link** (Google Doc, Workplace, wiki, fburl): Use
  `mcp__plugin_meta_mux__knowledge_load` with the URL — it has auth context.
  If that fails, ask the user to paste the content instead.
- **External link**: Use WebFetch. If it returns empty or auth-blocked,
  ask the user to paste the content instead.
- **Pasted text**: Use directly — no fetch needed.

## Step 3 — Select project

Ask the user:
> Which project does this belong to?
> 1. torchtlx
> 2. fbtriton-ci
> 3. triton-tbe

## Step 4 — Read current context

Read the matching internal context file:
- torchtlx → `~/.claude/internal/torchtlx.md`
- fbtriton-ci → `~/.claude/internal/fbtriton-ci.md`
- triton-tbe → `~/.claude/internal/triton-tbe.md`

## Step 5 — Propose changes

Analyze the fetched content and extract what's relevant for Claude to know
when working on this project. Focus on:
- Key decisions or design choices
- New APIs, interfaces, or patterns introduced
- Constraints or requirements that affect implementation
- Important context that isn't obvious from the code

Do NOT include:
- Verbatim copy of the document
- Temporary status updates or timelines
- Names/people (unless they're technical owners to consult)
- Content already in the file

Propose the update as a diff — show exactly what lines to add/modify in the
internal context file. Keep it concise — distill, don't copy.

## Step 6 — Confirm

Show the proposed changes and ask:
> Apply these changes to `~/.claude/internal/<project>.md`?

Only edit the file after the user confirms.
