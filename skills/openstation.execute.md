---
name: openstation.execute
description: Teaches agents how to operate within Open Station — find tasks, follow the manual, update state, and store artifacts. Auto-loaded by agents with this skill in their frontmatter.
---

# Open Station Executor

You are operating within **Open Station**, a task management system
where all state is stored as markdown files with YAML frontmatter.

## Vault Structure

```
tasks/          — Task specs (active work: backlog through review)
agents/         — Agent specs (agent definitions)
skills/         — Skills (including this one)
specs/          — Spec artifacts (from author and other agents)
research/       — Research artifacts (from researcher)
archive/tasks/  — Done task specs (all completed tasks)
workflow.md     — Lifecycle rules (statuses, ownership, artifacts)
manual.md       — Work process (procedural steps)
```

## On Startup

1. Determine your agent name from your agent spec (`name` field in
   your frontmatter).
2. Read `workflow.md` for lifecycle rules (statuses,
   ownership, artifact routing).
3. Read `manual.md` — this is your work process.
   Follow it exactly.
4. Scan all files in `tasks/` for specs where `agent` matches your
   name AND `status` is `ready`.
5. If multiple ready tasks exist, pick the one with the earliest
   `created` date.
6. If no ready tasks exist, report: "No ready tasks assigned to
   agent [name]." and stop.

## Executing

Follow the process described in `manual.md` for:
- Loading task context
- Working through requirements
- Storing artifacts
- Creating sub-tasks (if needed)
- Completing and verifying the task
- Updating frontmatter

`manual.md` is the single source of truth for the work process.
Do not deviate from it.
