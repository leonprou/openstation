---
name: openstation.done
description: Mark a task done and move it to tasks/done/. $ARGUMENTS = task name. Use when user says "done task", "complete task", "mark done", or wants to finish and archive a task.
---

# Done & Archive Task

Mark a task as done and move its symlink to `tasks/done/`.

## Input

`$ARGUMENTS` — the task name (ID-prefixed or slug).

Example: `0003-research-obsidian-plugin-api` or
`research-obsidian-plugin-api`

## Procedure

0. Read `docs/lifecycle.md` § "Artifact Promotion" for the
   canonical routing table.

1. Parse the task name from `$ARGUMENTS`.
2. Locate the task folder:
   - Search `tasks/current/` for a folder matching the task name.
   - Try exact match: `tasks/current/<task-name>/index.md`
   - If not found, try glob fallback: `tasks/current/*-<task-name>/index.md`
   - If still not found, report an error and list available tasks.
3. Read the task frontmatter from `index.md`. Verify `status: review`
   — refuse with an error if the task is not in review. Only
   `review` → `done` is a valid transition.
4. Set `status: done` in the task frontmatter.
5. Delete the symlink from `tasks/current/` and create a new
   symlink in `tasks/done/` →
   `../../artifacts/tasks/<task-name>`.
6. Artifacts are already in `artifacts/` — they do not need to
   be moved.
7. Confirm the task was completed and show the new path.
