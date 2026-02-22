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
/openstation.update 0001-add-input-validation status:ready agent:researcher
```

**3. Dispatch an agent**

```bash
claude --agent researcher
```

The agent finds its ready tasks, follows `.openstation/manual.md`, executes the work, and sets `status: review` when done.

**4. Mark done**

```
/openstation.done 0001-add-input-validation
```

Archives the task spec and promotes artifacts to the correct destination.

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

## Commands

| Command | Description |
|---------|-------------|
| `/openstation.create` | Create a new task spec from a description |
| `/openstation.list` | List all tasks with status, agent, and dates |
| `/openstation.update` | Update task frontmatter fields |
| `/openstation.dispatch` | Preview agent details and show launch instructions |
| `/openstation.done` | Mark a task done and archive it |
| `/openstation.execute` | Agent skill — find tasks, follow the manual, store artifacts |

## License

MIT
