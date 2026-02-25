---
name: openstation.ready
description: Promote a task from backlog to ready. $ARGUMENTS = task-name [agent:<name>]. Use when user says "ready task", "promote task", "make ready", or wants to activate a backlog task.
---

# Promote Task to Ready

Move a task's symlink from `tasks/backlog/` to `tasks/current/`.

## Input

`$ARGUMENTS` — the task name followed by an optional `agent:<name>`.

Examples:
- `0010-refactor-commands-lifecycle`
- `0010-refactor-commands-lifecycle agent:author`
- `refactor-commands-lifecycle agent:author`

## Procedure

1. Parse the task name (first argument) and optional `agent:<name>`
   from `$ARGUMENTS`.
2. Locate the task folder in `tasks/backlog/`:
   - Try exact match: `tasks/backlog/<task-name>/index.md`
   - If not found, try glob fallback: `tasks/backlog/*-<task-name>/index.md`
   - If still not found, report an error and list available
     backlog tasks.
3. Read the task frontmatter from `index.md`. Verify
   `status: backlog` — refuse with an error if the task is not
   in backlog. Only `backlog` → `ready` is a valid transition
   for this command.
4. Validate that the `## Requirements` section exists and is
   non-empty. Warn (but allow) if requirements look sparse.
5. If `agent:<name>` was provided:
   - Check that `agents/<name>.md` exists. Warn if not found,
     but allow the assignment.
   - Set `agent: <name>` in frontmatter.
6. If no agent was provided and `agent` field is empty, ask
   the user which agent to assign. List available agents from
   `agents/`.
7. Set `status: ready` in the task frontmatter.
8. Delete the symlink from `tasks/backlog/` and create a new
   symlink in `tasks/current/` →
   `../../artifacts/tasks/<task-name>`.
9. Confirm with: task name, assigned agent, and new path.
