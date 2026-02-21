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

1. Read the **Verification** section of the task spec.
2. Check each verification item.
3. If ALL items pass:
   - Update task frontmatter: `status: done`
4. If ANY item fails:
   - Update task frontmatter: `status: failed`
   - Document which items failed and why (add a note in the task
     body or as an artifact).

## Updating Frontmatter

When modifying YAML frontmatter in task specs:

- Edit only the specific field being changed.
- Preserve all other fields unchanged.
- Always update frontmatter directly — never just add a comment in
  the body as a substitute.
