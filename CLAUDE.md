# Open Station

Task management system for coding AI agents. Pure convention —
markdown specs + skills, zero runtime dependencies.

## Vault Structure

```
docs/              — Project documentation (lifecycle, task spec, README)
tasks/             — Lifecycle buckets (contain symlinks, not real folders)
  backlog/         —   Not yet ready for agents
  current/         —   Active work (ready → in-progress → review)
  done/            —   Completed tasks
artifacts/         — Canonical artifact storage (source of truth)
  tasks/           —   Task folders (canonical location, never move)
  research/        —   Research outputs
  specs/           —   Specifications & designs
agents/            — Agent specs (identity + skill references)
skills/            — Agent skills (operational knowledge, not user-invocable)
commands/          — User-invocable slash commands
```

Note: `install.sh` places these under `.openstation/` in target
projects. In this source repo they live at the root.

## How Docs Connect

```
                        ┌──────────┐
                        │ CLAUDE.md│
                        └────┬─────┘
                             │
                  references │
             ┌───────────────┤
             ▼               ▼
      ┌────────────┐  ┌───────────┐
      │lifecycle.md │◄─┤task.spec.md│
      └──┬──────┬──┘  └───────────┘
         │      │
         │      └───────────┐
         ▼                  ▼
┌─────────────────────────────┐
│  skills/                    │
│  openstation-execute/       │──► lifecycle.md
└────────────────┬────────────┘    task.spec.md
                 │                 /openstation.create
      skills:    │                 /openstation.done
      execute    │
         ┌───────┴───────┐
         ▼               ▼
  ┌──────────┐    ┌──────────┐
  │researcher│    │  author  │
  └──────────┘    └──────────┘

┌─────────────────────────────────────────┐
│  commands/                               │
│  openstation.create.md  ──► lifecycle.md │
│  openstation.done.md    ──► lifecycle.md │
│  openstation.update.md  ──► lifecycle.md │
│  openstation.list.md                     │
│  openstation.dispatch.md──► agents/      │
└─────────────────────────────────────────┘
```

- **task.spec.md** — the shape (schema, naming, format)
- **lifecycle.md** — the state machine (transitions, ownership, artifacts)
- **execute skill** — the agent playbook (discovery, execution, completion)

## Task Structure

Each task is a folder with an `index.md` inside, stored
canonically in `artifacts/tasks/`:

```
artifacts/tasks/0009-install-script/
└── index.md                             # canonical, never moves

tasks/current/0009-install-script/       # symlink → ../../artifacts/tasks/0009-install-script
```

Moving a task between stages = moving the symlink between
`backlog/`, `current/`, `done/`.

## Spec Format

All specs use YAML frontmatter with a `kind` field (`task` or
`agent`) followed by markdown content. Every spec must have at
minimum `kind` and `name` fields.

## Creating a New Task

1. Create a folder in `artifacts/tasks/` named `NNNN-kebab-case-name`
   where `NNNN` is the next available 4-digit auto-incrementing ID
2. Create `index.md` inside with frontmatter: `kind: task`,
   `name: NNNN-kebab-case-name`, `status: backlog`, `agent`,
   `owner: manual`, `created`
3. Create a symlink: `tasks/backlog/NNNN-slug` →
   `../../artifacts/tasks/NNNN-slug`
4. Write Requirements and Verification sections in the body
5. Set `status: ready` and move symlink to `tasks/current/` when
   the task is ready for an agent

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
`done`/`failed`. See `docs/lifecycle.md` for transition rules,
ownership model, artifact storage, and promotion routing.

## Discovery

- `.claude/agents` → `agents/` for `--agent` resolution
- `.claude/commands` → `commands/` for slash command discovery
- `skills/` contains agent-only skills (not user-invocable)
- `commands/` contains user-invocable slash commands
