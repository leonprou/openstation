---
kind: workflow
name: task-lifecycle
---

# Task Lifecycle

This document is the authoritative reference for how tasks move
through the system. Skills and the manual reference this file —
it is the single source of truth for lifecycle rules.

## Task Statuses

| Status | Meaning |
|--------|---------|
| `backlog` | Created, not ready for execution |
| `ready` | Requirements defined, agent assigned |
| `in-progress` | Agent is actively working |
| `review` | Work complete, awaiting verification |
| `done` | Verification passed |
| `failed` | Verification failed |

### Valid Transitions

```
backlog → ready          (human or agent assigns requirements + agent)
ready → in-progress      (assigned agent picks up the task)
in-progress → review     (agent finishes work)
review → done            (owner verifies — use /openstation.done)
review → failed          (owner rejects)
failed → in-progress     (agent reworks)
```

Setting `done` is only allowed via `/openstation.done`, which
archives the task in one step. Direct `status: done` edits are
not permitted.

## Ownership

The `owner` field names who is responsible for verification.

- Value is an agent name or `manual` (default).
- Only the designated owner may transition a task from `review` →
  `done` or `review` → `failed`.
- When `owner: manual`, a human operator verifies.

## Sub-Tasks

A task may be decomposed into sub-tasks:

- Set `parent: <parent-task-name>` in the sub-task frontmatter.
- All sub-tasks must reach `done` before the parent can proceed
  to `review`.
- Sub-tasks follow the same lifecycle as any other task.

## Artifact Storage

Artifacts are outputs produced during task execution (research
notes, code, reports, etc.). Store them alongside the task in
`tasks/`:

- **Single artifact**: same ID prefix as the task.
  `tasks/0003-my-task-notes.md`
- **Multiple artifacts**: subdirectory named after the task.
  ```
  tasks/0003-my-task/
  ├── 0003-my-task.md      # task spec
  ├── research-notes.md    # artifact
  └── implementation.md    # artifact
  ```
- Artifact files are markdown with enough context to be useful
  standalone.

## Artifact Promotion

When a task passes verification, `/openstation.done` splits the
task spec from artifacts and moves each to its destination.

### Routing Table

| What | Destination |
|------|-------------|
| Task spec (always) | `archive/tasks/` |
| Artifacts from `researcher` | `research/` |
| Artifacts from other agents | `specs/` |
| No agent (no artifacts) | just `archive/tasks/` |

### Destination Manual

Before moving an artifact to its destination, check for a
`manual.md` in the destination directory (e.g.,
`specs/manual.md`). If it exists, follow its
placement instructions. If it does not exist, move the
artifact directly into the destination directory.

### ID Prefix Stripping

The `NNNN-` ID prefix is stripped from all filenames during
promotion. For subdirectories, strip the ID from the directory
name.

## Directory Purposes

```
tasks/          — Active work only (backlog through review)
agents/         — Agent specs (identity + skill references)
skills/         — Skills (operational knowledge)
specs/          — Promoted artifacts from non-researcher agents
research/       — Promoted artifacts from researcher agent
archive/tasks/  — Completed task specs (done)
workflow.md     — This file (lifecycle rules)
manual.md       — Work process agents follow
```

`tasks/` should only contain active work. Completed
tasks are archived via `/openstation.done`.
