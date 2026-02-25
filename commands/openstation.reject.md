---
name: openstation.reject
description: Reject a task in review and mark it failed. $ARGUMENTS = task-name [reason...]. Use when user says "reject task", "fail task", "send back", or wants to reject work after review.
---

# Reject Task

Mark a task in `review` as `failed` and archive it.

## Input

`$ARGUMENTS` — the task name, optionally followed by a reason.

Examples:
- `0010-refactor-commands-lifecycle`
- `0010-refactor-commands-lifecycle missing unit tests`

## Procedure

1. Parse the task name (first argument) and optional reason
   (remaining text) from `$ARGUMENTS`.
2. Locate the task folder in `tasks/current/`:
   - Try exact match: `tasks/current/<task-name>/index.md`
   - If not found, try glob fallback: `tasks/current/*-<task-name>/index.md`
   - If still not found, report an error and list available tasks
     in `tasks/current/`.
3. Read the task frontmatter from `index.md`. Verify
   `status: review` — refuse with an error if the task is not
   in review. Only `review` → `failed` is a valid transition
   for this command.
4. Set `status: failed` in the task frontmatter.
5. If a reason was provided, append to the task body:

   ```markdown

   ## Rejection

   **Date:** YYYY-MM-DD
   **Reason:** <reason text>
   ```

6. Delete the symlink from `tasks/current/` and create a new
   symlink in `tasks/done/` →
   `../../artifacts/tasks/<task-name>`.
7. Confirm with: task name, reason (if any), and new path.
