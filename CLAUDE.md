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

## Task Statuses

- `backlog` — created, not ready
- `ready` — requirements defined, agent assigned
- `in-progress` — agent is working
- `review` — work complete, awaiting verification
- `done` — verification passed
- `failed` — verification failed

## Owner Field

The `owner` field in task frontmatter specifies who owns the task
and is responsible for verification. Value is an agent name or
`manual` (default). When an agent finishes work it sets
`status: review` — only the designated owner may set `done` or
`failed`. Use `/openstation.done` to mark a task done and
archive its spec and artifacts in one step.

## Artifacts

During execution, task outputs are stored alongside the task in
`.openstation/tasks/`. Artifact files share the parent task's ID prefix (e.g.,
`.openstation/tasks/0003-my-task-notes.md`). For multiple artifacts, use a
subdirectory: `.openstation/tasks/<NNNN-task-name>/`.

When a task passes verification, run `/openstation.done` to mark
it done and archive it in one step. The task spec is split from
artifacts:

| What | Destination |
|------|-------------|
| Task spec (always) | `.openstation/archive/tasks/` |
| Artifacts from `researcher` | `.openstation/research/` |
| Artifacts from other agents | `.openstation/specs/` |
| No agent (no artifacts) | just `.openstation/archive/tasks/` |

The `NNNN-` ID prefix is stripped during promotion. `.openstation/tasks/`
should only contain active work.

## Discovery

- `.claude/agents/` symlinks to `.openstation/agents/` for `--agent` resolution
- `.claude/commands/` contains skill symlinks for slash command
  discovery
- `.openstation/skills/` is the source of truth for all Open Station skills
