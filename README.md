# Open Station

Task management system for coding AI agents. Pure convention — markdown specs + skills, zero runtime dependencies.

## What It Is

Open Station gives coding AI agents a structured way to receive, execute, and complete tasks. Everything is plain markdown with YAML frontmatter — no runtime, no database, no dependencies. Drop it into any project and agents can discover tasks, follow a defined work process, and store artifacts, all through file conventions.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/leonprou/openstation/main/install.sh | bash
```

This creates the vault directories, installs skills and the manual, sets up symlinks for slash-command discovery, and adds an Open Station section to your `CLAUDE.md`.

**Options:**

| Flag | Description |
|------|-------------|
| `--local PATH` | Copy from a local clone instead of downloading |
| `--no-agents` | Skip installing example agent specs |

## Quick Start

**1. Create a task**

```
/openstation.create Add input validation to the signup form
```

**2. Set it ready**

```
/openstation.ready 0001-add-input-validation agent:researcher
```

**3. Dispatch an agent**

```bash
claude --agent researcher
```

The agent finds its ready tasks, follows the manual, executes the work, and sets `status: review` when done.

**4. Mark done**

```
/openstation.done 0001-add-input-validation
```

Moves the task symlink to `tasks/done/`.

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
skills/            — Agent skills (not user-invocable)
commands/          — User-invocable slash commands
```

When installed into another project via `install.sh`, these are
placed under `.openstation/`.

## Architecture

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

| Doc | Purpose |
|-----|---------|
| `task.spec.md` | The shape — schema, naming, format |
| `lifecycle.md` | The state machine — transitions, ownership, artifacts |
| `execute skill` | The agent playbook — discovery, execution, completion |

## Commands

| Command | Description |
|---------|-------------|
| `/openstation.create` | Create a new task spec from a description |
| `/openstation.list` | List all tasks with status, agent, and dates |
| `/openstation.show` | Show full details of a single task |
| `/openstation.ready` | Promote a task from backlog to ready |
| `/openstation.update` | Update task frontmatter fields |
| `/openstation.done` | Mark a task done and move it to done/ |
| `/openstation.reject` | Reject a task in review and mark it failed |
| `/openstation.dispatch` | Preview agent details and show launch instructions |

## License

MIT
