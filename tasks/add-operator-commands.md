---
kind: task
name: add-operator-commands
status: done
agent:
created: 2026-02-21
---

# Add Operator Commands for Main Operations

## Requirements

Create dedicated skills in `skills/` (with symlinks in
`.claude/commands/`) for the main Agent Station operations. Each
skill should be a standalone slash command the operator can invoke.

### Commands to create

1. **`/task-list`** — List all tasks with a summary table (status,
   agent, created date). Support optional filters via `$ARGUMENTS`
   (e.g., `status:ready`, `agent:researcher`).

2. **`/task-create`** — Create a new task spec in `tasks/`.
   `$ARGUMENTS` provides the task description. The command should:
   - Generate a kebab-case filename from the description
   - Create the file with proper frontmatter (`kind: task`,
     `status: backlog`, `created` date)
   - Prompt for optional fields: `agent`, initial `status`
   - Write a Requirements section derived from the description
   - Write an empty Verification section with placeholder items

3. **`/task-update`** — Update an existing task. `$ARGUMENTS`
   specifies the task name and fields to change (e.g.,
   `research-obsidian-plugin-api status:ready`).

4. **`/dispatch`** — Dispatch an agent to execute its ready tasks.
   `$ARGUMENTS` is the agent name. The command should validate the
   agent exists in `agents/` and instruct the user to run
   `claude --agent <name>`.

### Conventions

- Each command lives in `skills/<command-name>.md` with YAML
  frontmatter containing at minimum a `description` field.
- Each command gets a symlink in `.claude/commands/` pointing to
  the skill file (e.g., `../../skills/task-list.md`).
- Commands accept user input via `$ARGUMENTS`.
- Commands should be concise — focus on the operation, not on
  teaching the agent how Agent Station works (that's the executor
  skill's job).

## Verification

- [ ] Four skill files exist in `skills/`: `task-list.md`,
      `task-create.md`, `task-update.md`, `dispatch.md`
- [ ] Four corresponding symlinks exist in `.claude/commands/`
- [ ] Each skill has a `description` field in frontmatter
- [ ] Each skill uses `$ARGUMENTS` for input
- [ ] `/task-list` produces a markdown table of all tasks
- [ ] `/task-create` generates valid task specs with correct
      frontmatter
