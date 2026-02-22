---
name: agent-station.update
description: Update task frontmatter fields. $ARGUMENTS = <task-name> field:value [...]. Use when user says "update task", "change status", "assign agent", or wants to modify task metadata.
---

# Update Task

Modify frontmatter fields on an existing task.

## Input

`$ARGUMENTS` — the task name followed by one or more `field:value`
pairs separated by spaces.

Example: `0003-research-obsidian-plugin-api status:ready agent:researcher`

The task name can be either the full ID-prefixed name (e.g.,
`0003-research-obsidian-plugin-api`) or just the slug (e.g.,
`research-obsidian-plugin-api`).

## Procedure

1. Parse the task name (first argument) and field:value pairs from
   `$ARGUMENTS`.
2. Locate the task file:
   - Try exact match: `tasks/<task-name>.md`
   - If not found, try glob fallback: `tasks/*-<task-name>.md`
   - If still not found, report an error and list available tasks.
3. Read the current frontmatter.
4. Validate each field:value pair:
   - `status` must be one of: backlog, ready, in-progress, review, done, failed
   - `agent` should match an agent in `agents/` (warn if not found,
     but allow it)
   - `owner` should be an agent name or `manual` (warn if agent
     not found, but allow it)
   - Other frontmatter fields are updated as-is.
5. Show a before/after comparison of changed fields.
6. Apply the changes, preserving all other frontmatter fields and
   the full body content.
