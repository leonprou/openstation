---
description: List all tasks with status, agent, and dates. Supports filters via $ARGUMENTS (e.g., status:ready, agent:researcher).
---

# List Tasks

Scan all `.md` files in `tasks/` and display them as a markdown table.

## Input

`$ARGUMENTS` — optional space-separated filters in `key:value` format.

Supported filters:
- `status:<value>` — filter by status (backlog, ready, in-progress, done, failed)
- `agent:<value>` — filter by assigned agent

If no arguments provided, show all tasks.

## Procedure

1. Read every `*.md` file in `tasks/` (skip subdirectories that are
   artifact folders).
2. Parse YAML frontmatter from each file.
3. Apply any filters from `$ARGUMENTS`.
4. Display a markdown table with columns:
   | Task | Status | Agent | Created |
5. Sort by `created` date (oldest first).
6. Below the table, show summary counts:
   ```
   Total: N | backlog: N | ready: N | in-progress: N | done: N | failed: N
   ```
   Only include statuses that have at least one task.
