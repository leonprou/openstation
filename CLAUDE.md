# Agent Station

Task management system for coding AI agents. Pure convention —
markdown specs + skills, zero runtime dependencies.

## Vault Structure

```
tasks/           — Task specs (status tracked in frontmatter)
agents/          — Agent specs (identity + skill references)
skills/          — Agent Station skills (operational knowledge)
projects/        — Project artifacts (grouped by project)
research/        — General research artifacts (not project-specific)
manual.md        — Work process agents follow
```

## Spec Format

All specs use YAML frontmatter with a `kind` field (`task` or
`agent`) followed by markdown content. Every spec must have at
minimum `kind` and `name` fields.

## Creating a New Task

1. Create a file in `tasks/` named `NNNN-kebab-case-name.md` where
   `NNNN` is the next available 4-digit auto-incrementing ID
2. Add frontmatter: `kind: task`, `name: NNNN-kebab-case-name`,
   `status: backlog`, `agent`, `created`
3. Write Requirements and Verification sections in the body
4. Set `status: ready` when the task is ready for an agent

Use `/agent-station.create` to auto-assign the next ID.

## Dispatching an Agent

```bash
claude --agent researcher
```

The agent auto-loads the `agent-station-executor` skill (via the
`skills` field in its frontmatter), finds its ready tasks, follows
the manual, and executes.

## Task Statuses

- `backlog` — created, not ready
- `ready` — requirements defined, agent assigned
- `in-progress` — agent is working
- `done` — verification passed
- `failed` — verification failed

## Artifacts

Task outputs are stored alongside the task in `tasks/`. Artifact
files share the parent task's ID prefix (e.g.,
`tasks/0003-my-task-notes.md`). For multiple artifacts, use a
subdirectory: `tasks/<NNNN-task-name>/`.

## Discovery

- `.claude/agents/` symlinks to `agents/` for `--agent` resolution
- `.claude/commands/` contains skill symlinks for slash command
  discovery
- `skills/` is the source of truth for all Agent Station skills
