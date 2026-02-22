---
name: openstation.list
description: List all tasks with status, agent, and dates. Supports filters via $ARGUMENTS (e.g., status:ready, agent:researcher). Use when user asks "what tasks exist", "show tasks", "task status", or wants a status overview.
---

# List Tasks

Scan all `.md` files in `.openstation/tasks/` and display them as a markdown table.

## Input

`$ARGUMENTS` — optional space-separated filters in `key:value` format.

Supported filters:
- `status:<value>` — filter by status (backlog, ready, in-progress, review, done, failed)
- `agent:<value>` — filter by assigned agent

If no arguments provided, show all tasks.

## Procedure

1. Read every `*.md` file in `.openstation/tasks/` (skip subdirectories that are
   artifact folders).
2. Parse YAML frontmatter from each file.
3. Apply any filters from `$ARGUMENTS`.
4. Display a markdown table with columns:
   | ID | Task | Status | Agent | Owner | Created |
   The ID column shows the 4-digit numeric prefix extracted from the
   filename (e.g., `0003`). The Owner column shows the `owner`
   field value (default `manual` if absent).
5. Sort by ID (ascending) as primary sort.
6. Below the table, show summary counts:
   ```
   Total: N | backlog: N | ready: N | in-progress: N | review: N | done: N | failed: N
   ```
   Only include statuses that have at least one task.
