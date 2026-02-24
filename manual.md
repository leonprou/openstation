# Open Station Manual

This document describes the work process that agents follow when
executing tasks within Open Station.

## Task Discovery

1. Determine your agent name from your agent spec (the `name` field
   in your frontmatter).
2. Scan all files in `tasks/` for specs where `agent` matches your
   name AND `status` is `ready`.
3. If multiple ready tasks exist, pick the one with the earliest
   `created` date.
4. If no ready tasks exist, report: "No ready tasks assigned to
   agent [name]." and stop.

## Executing a Task

### 1. Load Context

- Read the task spec completely — note requirements and verification
  checklist.
- Read this manual for the work process.
- Set `status: in-progress` in the task frontmatter.

### 2. Work Through Requirements

- Follow the requirements section of the task spec.
- Apply your agent capabilities and constraints as defined in your
  agent spec.
- Break complex work into logical steps.

### 3. Store Artifacts

- Store artifacts alongside the task in `tasks/`.
- See `workflow.md` § "Artifact Storage" for naming
  conventions (single file vs subdirectory).

## Sub-Tasks

If a task requires decomposition, use `/openstation.create` to
create sub-tasks and set `parent: <current-task-name>` in their
frontmatter. See `workflow.md` § "Sub-Tasks" for
blocking rules and lifecycle dependency.

## Completing a Task

After working through all requirements:

1. Update task frontmatter: `status: review`.
2. The designated owner (specified in the task's `owner`
   field) handles verification from here.
3. Do **not** self-verify or set `done`/`failed` — that is the
   owner's responsibility.

See `workflow.md` for valid status transitions and
ownership rules.

## Verifying a Task

Only the designated owner may approve or reject a task. The
`owner` field in task frontmatter names the owner — either
an agent name or `manual` (meaning a human verifies).

### Agent Owner

If `owner` is an agent name, that agent:

1. Reads the task spec and its **Verification** section.
2. Checks each verification item against the artifacts and changes
   produced.
3. If ALL items pass: run `/openstation.done <task-name>` to mark
   the task done and archive it.
4. If ANY item fails: set `status: failed` and document which items
   failed and why (add a note in the task body or as an artifact).

### Manual Owner

If `owner` is `manual` (the default), a human operator:

1. Reviews the task's artifacts and changes.
2. Runs through the **Verification** checklist.
3. If all items pass: run `/openstation.done <task-name>`.
4. If any item fails: set `status: failed` accordingly.

## Completing & Archiving

When a task passes verification, run `/openstation.done <task-name>`
to mark it done and move it out of `tasks/` in a single step. This
keeps the directory as a clean active work queue.

### Routing Rules

See `workflow.md` § "Artifact Promotion" for the
routing table, ID prefix stripping, and destination rules.

## Updating Frontmatter

When modifying YAML frontmatter in task specs:

- Edit only the specific field being changed.
- Preserve all other fields unchanged.
- Always update frontmatter directly — never just add a comment in
  the body as a substitute.
