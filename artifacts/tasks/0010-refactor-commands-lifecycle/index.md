---
kind: task
name: 0010-refactor-commands-lifecycle
status: in-progress
agent:
owner: user
created: 2026-02-25
---

# Refactor Commands to Align with Lifecycle

Restructure slash commands so each user-driven lifecycle transition
has a dedicated command. Currently `update` handles both field edits
and status transitions (including folder moves), which is overloaded
and hides important operations.

## Requirements

### New commands

1. **`openstation.ready`** — promote backlog → ready
   - Input: `$ARGUMENTS` = task name, optionally `agent:<name>`
   - Locate task in `tasks/backlog/`
   - Validate requirements section is non-empty
   - Assign agent if provided (warn if agent spec not found)
   - Set `status: ready`
   - Move folder from `tasks/backlog/` to `tasks/current/`
   - Show confirmation with task name and assigned agent

2. **`openstation.reject`** — reject a task in review
   - Input: `$ARGUMENTS` = task name followed by optional reason text
   - Locate task in `tasks/current/` with `status: review`
   - Set `status: failed`
   - If reason provided, append a `## Rejection` section to the
     task body with the reason and date
   - Move folder from `tasks/current/` to `tasks/done/`
   - Show confirmation

3. **`openstation.show`** — display a single task
   - Input: `$ARGUMENTS` = task name (ID-prefixed or slug)
   - Search across all buckets (`backlog/`, `current/`, `done/`)
   - Display full frontmatter and body content
   - Show the file path for reference

### Modified commands

4. **`openstation.update`** — narrow to metadata-only edits
   - Remove status transition handling
   - If user passes `status:ready`, respond with:
     "Use `/openstation.ready` to promote a task."
   - If user passes `status:done`, respond with:
     "Use `/openstation.done` to complete a task."
   - If user passes `status:failed`, respond with:
     "Use `/openstation.reject` to reject a task."
   - Allowed fields: `agent`, `owner`, `parent`, and any
     non-status frontmatter field
   - No folder moves — task stays in its current bucket

### Documentation updates

5. Update `docs/lifecycle.md` to reference new commands:
   - `backlog → ready` references `/openstation.ready`
   - `review → failed` references `/openstation.reject`

6. Update `CLAUDE.md` if it references command names that changed.

### No changes required

- `openstation.create` — unchanged
- `openstation.done` — unchanged
- `openstation.list` — unchanged
- `openstation.dispatch` — unchanged
- `skills/openstation.execute.md` — agent-driven transitions
  (`ready→in-progress`, `in-progress→review`) are direct
  frontmatter edits, not commands. No changes needed.

## Verification

- [ ] `openstation.ready` command exists and promotes backlog → ready with folder move
- [ ] `openstation.reject` command exists and fails review tasks with optional reason
- [ ] `openstation.show` command exists and displays task details from any bucket
- [ ] `openstation.update` rejects status field changes with helpful redirect messages
- [ ] `docs/lifecycle.md` references new commands at relevant transitions
- [ ] All existing commands (`create`, `done`, `list`, `dispatch`) still work unchanged
- [ ] Execute skill (`skills/openstation.execute.md`) requires no changes
