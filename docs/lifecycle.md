---
kind: workflow
name: task-lifecycle
---

# Task Lifecycle

Authoritative reference for how tasks move through the system.
Skills and agents reference this file — it is the single
source of truth for lifecycle rules.

For task format, field schema, and naming conventions see
`docs/task.spec.md`.

## Status Transitions

```
backlog → ready          (use /openstation.ready)
ready → in-progress      (assigned agent picks up the task)
in-progress → review     (agent finishes work)
review → done            (owner verifies — use /openstation.done)
review → failed          (owner rejects — use /openstation.reject)
failed → in-progress     (agent reworks)
```

### Guardrails

- Each user-driven transition has a dedicated command.
  `/openstation.update` does not change status — it only edits
  metadata fields (agent, owner, parent, etc.).
- `backlog → ready` is only allowed via `/openstation.ready`,
  which validates requirements and moves the folder.
- `review → done` is only allowed via `/openstation.done`, which
  archives the task in one step.
- `review → failed` is only allowed via `/openstation.reject`,
  which records the rejection reason and archives the task.
- Agents must NOT self-verify their own work. After completing
  requirements, set `status: review` and stop. Only the
  designated `owner` may transition to `done` or `failed`.

## Bucket Mapping

Moving a task between lifecycle stages = moving the symlink,
not the folder. The canonical folder in `artifacts/tasks/` never
moves. See `docs/task.spec.md` § File Location for the
bucket-to-status mapping.

### Symlink Move Procedure

1. Delete the symlink from the source bucket.
2. Create a new symlink in the target bucket:
   `tasks/<target>/NNNN-slug → ../../artifacts/tasks/NNNN-slug/`

## Ownership

The `owner` field names who is responsible for verification.

- Value is an agent name or `user` (default).
- Only the designated owner may transition a task from `review` →
  `done` or `review` → `failed`.
- When `owner: user`, a human operator verifies.

## Sub-Tasks

A task may be decomposed into sub-tasks:

- Set `parent: <parent-task-name>` in the sub-task frontmatter.
- All sub-tasks must reach `done` before the parent can proceed
  to `review`.
- Sub-tasks follow the same lifecycle as any other task.

## Artifact Storage

Artifacts are outputs produced during task execution (research
notes, code, reports, etc.). Store them in `artifacts/<category>/`:

- `artifacts/tasks/` — Task folders (canonical location for all tasks)
- `artifacts/research/` — Research outputs (from researcher agent)
- `artifacts/specs/` — Specifications and designs
- Additional categories can be added as needed

Artifacts are written directly to `artifacts/` during task
execution. They stay there permanently — they never move.

## Artifact Promotion

When a task passes verification, `/openstation.done` moves the
task folder to `tasks/done/`. Artifacts are already in
`artifacts/` and do not need to be moved.

### Routing Table (for new artifacts during task execution)

| Artifact Type | Destination |
|---------------|-------------|
| task creation | `artifacts/tasks/` |
| `researcher` output | `artifacts/research/` |
| other agent output | `artifacts/specs/` |

## Directory Purposes

```
docs/              — Project documentation (lifecycle, task spec, README)
tasks/             — Lifecycle buckets (contain symlinks, not real folders)
  backlog/         —   Not yet ready for agents
  current/         —   Active work (ready → in-progress → review)
  done/            —   Completed tasks
artifacts/         — Canonical artifact storage (source of truth)
  tasks/           —   Task folders (canonical location, never move)
  research/        —   Research outputs
  specs/           —   Specifications & designs
agents/            — Agent specs (identity + skill references)
skills/            — Agent skills (not user-invocable)
commands/          — User-invocable slash commands
docs/lifecycle.md  — This file (lifecycle rules)
docs/task.spec.md  — Task format specification
```

Task bucket entries are symlinks to `artifacts/tasks/`. Agents
read through symlinks transparently. `tasks/current/` should
only contain active work — completed tasks are moved to
`tasks/done/` via `/openstation.done`.
