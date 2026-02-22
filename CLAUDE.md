# Open Station

Task management system for coding AI agents. Pure convention —
markdown specs + skills, zero runtime dependencies.

## Vault Structure

```
.openstation/
├── tasks/           — Task specs (active work: backlog through review)
├── agents/          — Agent specs (identity + skill references)
├── skills/          — Open Station skills (operational knowledge)
├── specs/           — Spec artifacts (from author and other agents)
├── research/        — Research artifacts (from researcher)
├── archive/tasks/   — Done task specs (all completed tasks)
├── workflow.md      — Lifecycle rules (statuses, ownership, artifacts)
└── manual.md        — Work process agents follow
```

## Spec Format

All specs use YAML frontmatter with a `kind` field (`task` or
`agent`) followed by markdown content. Every spec must have at
minimum `kind` and `name` fields.

## Creating a New Task

1. Create a file in `.openstation/tasks/` named `NNNN-kebab-case-name.md` where
   `NNNN` is the next available 4-digit auto-incrementing ID
2. Add frontmatter: `kind: task`, `name: NNNN-kebab-case-name`,
   `status: backlog`, `agent`, `owner: manual`, `created`
3. Write Requirements and Verification sections in the body
4. Set `status: ready` when the task is ready for an agent

Use `/openstation.create` to auto-assign the next ID.

## Dispatching an Agent

```bash
claude --agent researcher
```

The agent auto-loads the `openstation-executor` skill (via the
`skills` field in its frontmatter), finds its ready tasks, follows
the manual, and executes.

## Task Lifecycle

Statuses: `backlog` → `ready` → `in-progress` → `review` →
`done`/`failed`. See `.openstation/workflow.md` for transition
rules, ownership model, artifact storage, and promotion routing.

## Discovery

- `.claude/agents/` symlinks to `.openstation/agents/` for `--agent` resolution
- `.claude/commands/` contains skill symlinks for slash command
  discovery
- `.openstation/skills/` is the source of truth for all Open Station skills
