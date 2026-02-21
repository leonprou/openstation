# Agent Station Manual

This document describes the work process that agents follow when
executing tasks within Agent Station.

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

- Artifacts are outputs produced during task execution (research
  notes, code changes, reports, etc.).
- Store artifacts alongside the task in `tasks/`:
  - **Single artifact**: Place the artifact file next to the task
    file, sharing the task's ID prefix (e.g.,
    `tasks/0003-my-task-notes.md` for task `0003-my-task`).
  - **Multiple artifacts**: Create a subdirectory named after the
    task containing the task spec and all artifacts:
    ```
    tasks/0003-my-task/
    ├── 0003-my-task.md      # task spec
    ├── research-notes.md    # artifact
    └── implementation.md    # artifact
    ```
- Artifact files are markdown. Include enough context that the
  artifact is useful on its own.

## Sub-Tasks

If a task requires decomposition into smaller pieces:

1. Create a new task file in `tasks/` using the create skill
   (`/agent-station.create`) to auto-assign the next ID.
2. Set `parent: <current-task-name>` in frontmatter.
3. Set `status: backlog` (or `ready` if it can be executed
   immediately).
4. Assign an `agent`.
5. Sub-tasks must be completed before the parent task can proceed.

## Completing a Task

After working through all requirements:

1. Update task frontmatter: `status: review`.
2. The designated verifier (specified in the task's `verifier`
   field) handles verification from here.
3. Do **not** self-verify or set `done`/`failed` — that is the
   verifier's responsibility.

## Verifying a Task

Only the designated verifier may approve or reject a task. The
`verifier` field in task frontmatter names the verifier — either
an agent name or `manual` (meaning a human verifies).

### Agent Verifier

If `verifier` is an agent name, that agent:

1. Reads the task spec and its **Verification** section.
2. Checks each verification item against the artifacts and changes
   produced.
3. If ALL items pass: set `status: done`.
4. If ANY item fails: set `status: failed` and document which items
   failed and why (add a note in the task body or as an artifact).

### Manual Verifier

If `verifier` is `manual` (the default), a human operator:

1. Reviews the task's artifacts and changes.
2. Runs through the **Verification** checklist.
3. Sets `status: done` or `status: failed` accordingly.

## Updating Frontmatter

When modifying YAML frontmatter in task specs:

- Edit only the specific field being changed.
- Preserve all other fields unchanged.
- Always update frontmatter directly — never just add a comment in
  the body as a substitute.
