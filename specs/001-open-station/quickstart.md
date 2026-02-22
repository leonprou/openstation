# Quickstart: Open Station

## Prerequisites

- Claude Code installed and configured
- A git repository for the vault

## 1. Create a Task

Create `tasks/my-first-task.md`:

```markdown
---
kind: task
name: my-first-task
status: backlog
agent: researcher
created: 2026-02-21
---

# My First Task

## Requirements
Research how markdown-based task systems compare to traditional
project management tools. Cover at least 3 alternatives.

## Verification
- [ ] Research covers at least 3 alternatives
- [ ] Each alternative has pros and cons listed
- [ ] A recommendation is provided
```

Set `status: ready` when you're satisfied with the requirements.

## 2. Dispatch an Agent

Launch a Claude Code session with the assigned agent:

```bash
claude --agent researcher
```

The agent auto-loads the `openstation-executor` skill (listed in its
`skills` frontmatter), finds the ready task, follows the manual, and
executes.

## 3. Monitor Progress

Check the task's frontmatter to see its current status:

- `in-progress` — agent is working
- `done` — verification passed, artifacts stored
- `failed` — verification failed, see notes

Artifacts appear alongside the task in `tasks/`.

## Vault Layout

```
openstation/
├── tasks/           # Your work items
├── agents/          # Agent definitions
├── skills/          # System skills
├── manual.md        # Work process
└── CLAUDE.md        # Project instructions
```

## Next Steps

- Create more agents in `agents/` for different roles
- Add tasks and dispatch agents to execute them
- Browse the vault in Obsidian for a visual overview
