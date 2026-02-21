---
description: Update task frontmatter fields. $ARGUMENTS = <task-name> field:value [...].
---

# Update Task

Modify frontmatter fields on an existing task.

## Input

`$ARGUMENTS` — the task name followed by one or more `field:value`
pairs separated by spaces.

Example: `research-obsidian-plugin-api status:ready agent:researcher`

## Procedure

1. Parse the task name (first argument) and field:value pairs from
   `$ARGUMENTS`.
2. Verify `tasks/<task-name>.md` exists. If not, report an error and
   list available tasks.
3. Read the current frontmatter.
4. Validate each field:value pair:
   - `status` must be one of: backlog, ready, in-progress, done, failed
   - `agent` should match an agent in `agents/` (warn if not found,
     but allow it)
   - Other frontmatter fields are updated as-is.
5. Show a before/after comparison of changed fields.
6. Apply the changes, preserving all other frontmatter fields and
   the full body content.
