---
name: agent-station.promote
description: Promote a done task's spec and artifacts to the correct destination. $ARGUMENTS = task name. Use when user says "promote task" or after verifying a task as done.
---

# Promote Task

Move a completed task out of `tasks/`, splitting the task spec
from its artifacts into separate destinations.

## Input

`$ARGUMENTS` — the task name (ID-prefixed or slug).

Example: `0003-research-obsidian-plugin-api` or
`research-obsidian-plugin-api`

## Routing Rules

The task spec and artifacts are split:

| What | Destination |
|------|-------------|
| Task spec (always) | `archive/tasks/` |
| Artifacts from `researcher` | `research/` |
| Artifacts from other agents | `specs/` |
| No agent (no artifacts) | just `archive/tasks/` |

The **task spec** is the file whose name matches the task name
(`NNNN-task-name.md`). Everything else with the same ID prefix
is an **artifact**.

## Procedure

1. Parse the task name from `$ARGUMENTS`.
2. Locate the task file:
   - Try exact match: `tasks/<task-name>.md`
   - If not found, try glob fallback: `tasks/*-<task-name>.md`
   - If still not found, report an error and list available tasks.
3. Read the task frontmatter. Verify `status: done` — refuse with
   an error if the task is not done.
4. Extract the 4-digit ID prefix from the filename (the `NNNN-`
   portion).
5. Find all associated files:
   - If a subdirectory `tasks/<task-name>/` exists, that entire
     directory is the unit to process.
   - Otherwise, glob `tasks/<ID>-*` to find the spec and any
     artifact files sharing the same ID prefix.
6. Identify which file is the task spec (matches the task name)
   and which are artifacts (same ID prefix, different name).
7. Move the task spec to `archive/tasks/`, stripping the `NNNN-`
   ID prefix.
8. Determine artifact destination from the `agent` field:
   - `researcher` → `research/`
   - other agents → `specs/`
   - no agent → no artifacts expected
9. Move each artifact to its destination, stripping the `NNNN-`
   ID prefix:
   - `tasks/0003-research-obsidian-plugin-api.md` →
     `archive/tasks/research-obsidian-plugin-api.md`
   - `tasks/0003-research-obsidian-plugin-api-notes.md` →
     `research/research-obsidian-plugin-api-notes.md`
   - For subdirectories: task spec file inside →
     `archive/tasks/`, other files → artifact destination.
     Strip the ID from the directory name.
10. Confirm what was moved and where. List each file with its old
    and new path.
