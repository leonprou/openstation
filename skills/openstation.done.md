---
name: openstation.done
description: Mark a task done and archive it — sets status to done, then promotes the spec and artifacts to the correct destination. $ARGUMENTS = task name. Use when user says "done task", "complete task", "mark done", or wants to finish and archive a task.
---

# Done & Archive Task

Mark a task as done and move it out of `tasks/`, splitting the
task spec from its artifacts into separate destinations.

## Input

`$ARGUMENTS` — the task name (ID-prefixed or slug).

Example: `0003-research-obsidian-plugin-api` or
`research-obsidian-plugin-api`

## Procedure

0. Read `workflow.md` § "Artifact Promotion" for the
   canonical routing table and ID stripping rules.

1. Parse the task name from `$ARGUMENTS`.
2. Locate the task file:
   - Try exact match: `tasks/<task-name>.md`
   - If not found, try glob fallback: `tasks/*-<task-name>.md`
   - If still not found, report an error and list available tasks.
3. Read the task frontmatter. Verify `status: review` — refuse
   with an error if the task is not in review. Only `review` →
   `done` is a valid transition.
4. Set `status: done` in the task frontmatter.
5. Extract the 4-digit ID prefix from the filename (the `NNNN-`
   portion).
6. Find all associated files:
   - If a subdirectory `tasks/<task-name>/` exists, that entire
     directory is the unit to process.
   - Otherwise, glob `tasks/<ID>-*` to find the spec and any
     artifact files sharing the same ID prefix.
7. Identify which file is the task spec (matches the task name)
   and which are artifacts (same ID prefix, different name).
8. Move the task spec to `archive/tasks/`, stripping the `NNNN-`
   ID prefix.
9. Determine artifact destination from the `agent` field per
   `workflow.md` § "Artifact Promotion":
   - `researcher` → `research/`
   - other agents → `specs/`
   - no agent → no artifacts expected
10. Check for a `manual.md` in the destination directory. If
    found, read it and follow its placement instructions for
    the artifact. If not found, place the artifact directly
    in the destination directory.
11. Move each artifact to its destination, stripping the `NNNN-`
    ID prefix:
    - `tasks/0003-research-obsidian-plugin-api.md` →
      `archive/tasks/research-obsidian-plugin-api.md`
    - `tasks/0003-research-obsidian-plugin-api-notes.md` →
      `research/research-obsidian-plugin-api-notes.md`
    - For subdirectories: task spec file inside →
      `archive/tasks/`, other files → artifact destination.
      Strip the ID from the directory name.
12. Confirm what was moved and where. List each file with its old
    and new path.
