---
name: openstation.show
description: Show full details of a single task. $ARGUMENTS = task name. Use when user says "show task", "view task", "task details", or wants to inspect a specific task.
---

# Show Task

Display the full spec of a single task.

## Input

`$ARGUMENTS` — the task name (ID-prefixed or slug).

Examples:
- `0010-refactor-commands-lifecycle`
- `refactor-commands-lifecycle`
- `0010`

## Procedure

1. Parse the task name from `$ARGUMENTS`.
2. Locate the task folder across all buckets:
   - Search `tasks/backlog/`, `tasks/current/`, and `tasks/done/`
     in that order.
   - Try exact match: `tasks/<bucket>/<task-name>/index.md`
   - If not found, try glob fallback: `tasks/<bucket>/*-<task-name>/index.md`
   - If input is numeric only (e.g., `0010`), match any folder
     starting with that prefix: `tasks/<bucket>/<input>-*/index.md`
   - If still not found, report an error and suggest using
     `/openstation.list` to find the correct name.
3. Read the full `index.md` file.
4. Display:
   - The frontmatter fields in a readable format
   - The full markdown body
   - The canonical location (e.g., `artifacts/tasks/0010-refactor-commands-lifecycle/index.md`)
   - The bucket the task is in (backlog, current, or done)
