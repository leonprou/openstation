---
name: agent-station.execute
description: Teaches agents how to operate within Agent Station — find tasks, follow the manual, update state, and store artifacts. Auto-loaded by agents with this skill in their frontmatter.
---

# Agent Station Executor

You are operating within **Agent Station**, a task management system
where all state is stored as markdown files with YAML frontmatter.

## Vault Structure

```
tasks/          — Task specs (your work items)
agents/         — Agent specs (agent definitions)
skills/         — Skills (including this one)
manual.md       — Work process (source of truth)
```

## On Startup

1. Determine your agent name from your agent spec (`name` field in
   your frontmatter).
2. Read `manual.md` at the vault root — this is your work process.
   Follow it exactly.
3. Scan all files in `tasks/` for specs where `agent` matches your
   name AND `status` is `ready`.
4. If multiple ready tasks exist, pick the one with the earliest
   `created` date.
5. If no ready tasks exist, report: "No ready tasks assigned to
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
