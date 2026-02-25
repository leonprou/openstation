# Changelog

## v2

Major restructuring of the vault layout, specs, and lifecycle
model. Tasks become first-class artifacts with a symlink-based
architecture.

### Architecture

- **Tasks as artifacts** — Task folders now live permanently in
  `artifacts/tasks/` with `index.md` as the canonical file.
  Lifecycle buckets (`tasks/backlog/`, `tasks/current/`,
  `tasks/done/`) contain folder-level symlinks pointing back to
  the canonical location. "Moving" a task between stages means
  deleting the symlink from one bucket and creating it in another.
- **Renamed `task.md` → `index.md`** — The primary file in each
  task folder is now `index.md` (conventional name for a folder's
  main document).
- **Vault restructured** — Flat file layout replaced with
  folder-per-task structure (`NNNN-slug/index.md`). Status buckets
  (`backlog/`, `current/`, `done/`) replace the single `tasks/`
  directory. Artifacts moved to `artifacts/research/` and
  `artifacts/specs/`.

### Specs & Docs

- **Task specification** (`docs/task.spec.md`) — New formal spec
  defining task format, YAML frontmatter schema, naming
  conventions, progressive disclosure stages, and examples.
- **Lifecycle rules** (`docs/lifecycle.md`) — Renamed from
  `workflow.md`. Deduplicated with task spec. Added symlink move
  procedure, artifact routing table, and directory purposes.
- **Execute skill** (`skills/openstation-execute/`) — Merged
  the standalone manual into the skill. Added Record Findings
  step, verification guardrails, and agent ownership rules.

### Commands

- **New commands:**
  - `/openstation.ready` — Promote backlog → ready with
    requirements validation
  - `/openstation.reject` — Reject a task in review → failed
  - `/openstation.show` — Display full task details
- **Updated `/openstation.update`** — No longer handles status
  changes. Only edits metadata fields (agent, owner, parent).
  Status transitions use dedicated commands.
- **Updated `/openstation.create`** — Scans `artifacts/tasks/`
  for next ID. Creates canonical folder + backlog symlink.
- **Updated `/openstation.done`** — Moves symlink instead of
  folder.
- **Removed** speckit commands (analyze, checklist, clarify,
  constitution, implement, plan, specify, tasks, taskstoissues).

### Install

- `install.sh` creates `artifacts/tasks/` directory.
- Installs new commands (ready, reject, show).
- Updated managed CLAUDE.md section with symlink-aware vault
  structure.

### Cleanup

- Removed outdated design artifacts
  (`artifacts/specs/001-open-station/`).
- Removed standalone `docs/manual.md` (merged into execute
  skill).
- Migrated all 10 existing tasks to `artifacts/tasks/` with
  symlinks in their respective buckets.

## v1

Initial release. Built the core vault structure, agent model,
and task lifecycle from scratch.

### Core

- **Vault structure** — `tasks/`, `agents/`, `skills/`,
  `commands/`, `artifacts/`, `docs/` directory layout with
  YAML frontmatter conventions.
- **Task lifecycle** — `backlog` → `ready` → `in-progress` →
  `review` → `done`/`failed` status machine with folder-move
  semantics.
- **Auto-incrementing IDs** — 4-digit zero-padded task IDs
  (`0001`, `0042`) with kebab-case slugs.
- **Owner/verifier model** — `owner` field (renamed from
  `verifier`) controls who may approve or reject a task.
  Agents cannot self-verify.

### Agents & Skills

- **Researcher agent** — Research-focused agent spec.
- **Author agent** — Structured vault content authoring agent.
- **Execute skill** (`openstation-execute/`) — Agent playbook
  for task discovery, execution, artifact storage, and
  completion.
- **Manual** (`docs/manual.md`) — Standalone agent operating
  guide (later merged into execute skill in v2).

### Commands

- `/openstation.create` — Create a new task from a description.
- `/openstation.list` — List all tasks with status and filters.
- `/openstation.update` — Update task frontmatter fields
  (including status transitions).
- `/openstation.done` — Mark a task done and archive it. Merged
  the separate promote step into a single command.
- `/openstation.dispatch` — Preview agent details and show
  launch instructions.

### Infrastructure

- **`install.sh`** — Bootstrap script to install Open Station
  into any project. Supports `--local` and `--no-agents` flags.
  Creates directories, installs commands/skills/agents, sets up
  `.claude/` symlinks, and manages a section in `CLAUDE.md`.
- **README** with install instructions, quick start, vault
  structure, architecture diagram, and commands reference.
- **Renamed** from "Agent Station" to "Open Station".

### Design Artifacts (removed in v2)

- Initial design document, feature spec, implementation plan,
  data model, and research notes in `artifacts/specs/001-open-station/`.
- Spec-Kit integration commands (9 speckit.* commands).
