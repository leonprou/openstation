---
description: Teaches agents how to operate within Agent Station — find tasks, follow the manual, update state, and store artifacts. Auto-loaded by agents with this skill in their frontmatter.
---

# Agent Station Executor

You are operating within **Agent Station**, a task management system
where all state is stored as markdown files with YAML frontmatter.

Follow these instructions exactly.

## Vault Structure

```
tasks/          — Task specs (your work items)
agents/         — Agent specs (agent definitions)
skills/         — Skills (including this one)
manual.md       — Work process document (at vault root)
```

## On Startup

1. Determine your agent name from your agent spec (`name` field in
   your frontmatter).
2. Read `manual.md` at the vault root — this is your work process.
3. Scan all files in `tasks/` for specs where `agent` matches your
   name AND `status` is `ready`.
4. If multiple ready tasks exist, pick the one with the earliest
   `created` date.
5. If no ready tasks exist, report: "No ready tasks assigned to
   agent [name]." and stop.

## Executing a Task

When you have a task to execute:

### 1. Load Context

- Read the task spec completely — note the requirements and
  verification checklist.
- Understand what needs to be produced.

### 2. Begin Work

- Update the task frontmatter: set `status: in-progress`.

### 3. Execute

- Follow the requirements section of the task spec.
- Apply your agent capabilities and constraints from your agent spec.
- Follow the work process described in `manual.md`.
- Produce artifacts as needed (see Storing Artifacts below).

### 4. Complete

- Read the **Verification** section of the task spec.
- Check each verification item.
- If ALL items pass: update `status: done`.
- If ANY item fails: update `status: failed` and document what
  failed (as a note in the task body or as an artifact).

## Storing Artifacts

- Store artifacts alongside the task in `tasks/`.
- **Single artifact**: place next to the task file.
- **Multiple artifacts**: create a subdirectory `tasks/<task-name>/`
  containing the task spec and all artifacts.
- Artifacts are markdown files with enough context to be useful
  standalone.

## Creating Sub-Tasks

If work requires decomposition:

1. Create a new task file in `tasks/` with a kebab-case name.
2. Set `parent: <current-task-name>` in frontmatter.
3. Set `status: backlog` (or `ready` if immediately executable).
4. Assign an `agent`.
5. Sub-tasks must complete before the parent task proceeds.

## Updating Frontmatter

- Edit only the specific field being changed.
- Preserve all other fields.
- Always update frontmatter directly, not via comments in the body.
