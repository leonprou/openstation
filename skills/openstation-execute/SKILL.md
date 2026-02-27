---
name: openstation-execute
description: Teaches agents how to operate within Open Station — find tasks, execute work, update state, and store artifacts.
user-invocable: false
---

# Open Station Executor

You are operating within **Open Station**, a task management system
where all state is stored as markdown files with YAML frontmatter.

## Vault Structure

```
docs/              — Project documentation (lifecycle, task spec, README)
tasks/             — Lifecycle buckets (contain symlinks, not real folders)
  backlog/         —   Not yet ready for agents
  current/         —   Active work (ready → in-progress → review)
  done/            —   Completed tasks
artifacts/         — Canonical artifact storage (source of truth)
  tasks/           —   Task folders (canonical location, never move)
  agents/          —   Agent specs (canonical location)
  research/        —   Research outputs
  specs/           —   Specifications & designs
agents/            — Agent discovery (symlinks → artifacts/agents/)
skills/            — Skills (including this one)
commands/          — User-invocable slash commands
```

Task entries in buckets are symlinks to `artifacts/tasks/`.
Reads through symlinks are transparent — no special handling needed.

## On Startup

1. Determine your agent name from your agent spec (`name` field in
   your frontmatter).
2. Read `docs/lifecycle.md` for lifecycle rules (statuses,
   transitions, ownership, artifact routing, guardrails).
3. Read `docs/task.spec.md` for task format (fields, naming,
   body structure, editing guardrails).
4. Scan `tasks/current/` for task folders containing an `index.md`
   where `agent` matches your name AND `status` is `ready`.
5. If multiple ready tasks exist, pick the one with the earliest
   `created` date.
6. If no ready tasks exist, report: "No ready tasks assigned to
   agent [name]." and stop.

## Executing a Task

### 1. Load Context

- Read the task's `index.md` completely — note requirements and
  verification checklist.
- Set `status: in-progress` in the task frontmatter.

### 2. Work Through Requirements

- Follow the requirements section of the task spec.
- Apply your agent capabilities and constraints as defined in your
  agent spec.
- Break complex work into logical steps.

### 3. Store Artifacts

- Store artifacts in `artifacts/<category>/` (the canonical
  location). Routing:
  - Agent specs → `artifacts/agents/`
  - Research outputs → `artifacts/research/`
  - Other outputs → `artifacts/specs/`
- Symlink artifacts into the task folder for traceability:
  `artifacts/tasks/NNNN-slug/<name>.md → ../../agents/<name>.md`
- See `docs/lifecycle.md` § "Artifact Storage" for naming
  conventions and categories.

### 4. Record Findings

After completing the work, add a `## Findings` section to
`index.md` summarizing what you discovered or produced. Place it
between `## Requirements` and `## Verification`.

- Summarize key results — don't repeat the full artifact contents.
- Link to artifacts where relevant (e.g., "See
  `artifacts/research/topic-name.md`").
- Add `## Recommendations` after Findings if the task warrants
  actionable suggestions.
- Skip this step if the task produced no findings worth recording
  (e.g., pure implementation tasks with nothing to summarize
  beyond the code itself).

### 5. Create Sub-Tasks (if needed)

If a task requires decomposition, use `/openstation.create` to
create sub-tasks and set `parent: <current-task-name>` in their
frontmatter. See `docs/lifecycle.md` § "Sub-Tasks" for
blocking rules and lifecycle dependency.

## Completing a Task

After working through all requirements:

1. Update task frontmatter: `status: review`.
2. Stop. The designated owner handles verification from here.

See `docs/lifecycle.md` § "Status Transitions" for guardrails.

## Verifying a Task (when you are the owner)

Only the designated owner may approve or reject a task. The
`owner` field in task frontmatter names the owner — either
an agent name or `user` (meaning a human verifies).

### Agent Owner

If `owner` is your agent name:

1. Read the task spec and its **Verification** section.
2. Check each verification item against the artifacts and changes
   produced.
3. If ALL items pass: run `/openstation.done <task-name>`.
4. If ANY item fails: set `status: failed` and document which
   items failed and why (add a note in the task body or as an
   artifact).

### User Owner

If `owner` is `user`, a human operator handles verification.
Do not verify on their behalf.
