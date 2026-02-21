<!--
Sync Impact Report
- Version change: N/A → 1.0.0 (initial ratification)
- Note: skills/ is the source of truth; .claude/commands/ is a
  symlink so Claude Code can discover skills natively
- Principles added:
  - I. Everything Is a Spec
  - II. Skills Are the Glue
  - III. Obsidian Is the Database
  - IV. Manual Dispatch
- Principles deferred:
  - Linear Workflows (deferred to future version)
- Sections added:
  - Technology Constraints
  - Development Workflow
  - Governance
- Amendments (pre-ratification):
  - Removed `workflow` as a primitive kind (Principle I)
  - Replaced `workflows/` directory with root-level `manual.md`
    (Principle III)
  - Removed `workflow` field from task frontmatter (Dev Workflow)
  - Updated dispatch: agents follow the manual instead of loading
    a workflow
- Templates requiring updates:
  - .specify/templates/plan-template.md — ✅ no changes needed
  - .specify/templates/spec-template.md — ✅ no changes needed
  - .specify/templates/tasks-template.md — ✅ no changes needed
  - .specify/templates/checklist-template.md — ✅ no changes needed
  - .specify/templates/agent-file-template.md — ✅ no changes needed
- Follow-up TODOs: none
-->

# Agent Station Constitution

## Core Principles

### I. Everything Is a Spec

All primitives — tasks and agents — MUST be markdown files with
YAML frontmatter. The `kind` field discriminates type. The body is
free-form markdown.

- Every entity in the system MUST have a corresponding `.md` file
  with valid YAML frontmatter containing at minimum a `kind` and
  `name` field.
- State MUST be stored in frontmatter fields, not external databases
  or runtime memory.
- Specs MUST be human-readable without tooling — a person opening
  the file MUST understand it without parsing scripts.

**Rationale**: A single format eliminates integration complexity and
keeps the system inspectable by both humans and agents.

### II. Skills Are the Glue

Agent Station operational knowledge MUST live in skills, not in
agent specs. Agent specs define identity and capabilities; skills
teach agents how to operate within the system.

- Agent specs MUST NOT contain Agent Station-specific instructions.
- The `agent-station-executor` skill MUST be the sole bridge
  between agents and the system.
- New system-level behaviors MUST be added as skills, not embedded
  in agent or task specs.
- `skills/` is the source of truth for all skills.
  `.claude/commands/` MUST be a symlink to `skills/` so that
  Claude Code discovers them natively.

**Rationale**: Separating operational knowledge from agent identity
allows any agent to participate in Agent Station by loading a skill,
and allows the system to evolve without rewriting every agent spec.

### III. Obsidian Is the Database

The vault is a directory of markdown files, browsable in Obsidian
and readable by agents. There is no database, no API server, no
runtime process.

- All persistent state MUST reside in the vault as markdown files.
- The vault MUST be usable without Obsidian — it is a directory of
  files first, an Obsidian vault second.
- Vault structure MUST be flat-by-type: `tasks/`, `agents/`,
  `skills/`, with `manual.md` at the vault root.
- Task artifacts MUST be stored alongside their task, not in a
  separate top-level directory.

**Rationale**: Markdown-on-disk is the lowest-common-denominator
storage. It requires zero infrastructure and works with any editor,
version control system, or search tool.

### IV. Manual Dispatch

A human launches Claude Code sessions pointed at tasks. There is no
automated scheduler, watcher, or orchestrator.

- Task execution MUST be initiated by a human running a Claude Code
  session with an agent spec and the executor skill.
- Agents MUST NOT autonomously pick up new tasks beyond the current
  session scope.
- The system MUST NOT require any long-running process to function.

**Rationale**: Manual dispatch keeps the system simple, auditable,
and safe. Automation can be layered on top in a future version
without changing the core model.

## Technology Constraints

- **Minimal dependencies** — the system targets zero runtime
  dependencies. Lightweight tooling (e.g., validation scripts, CLI
  helpers) MAY be added when justified, but the core system MUST
  remain usable without them.
- **Markdown + YAML only** — all data is stored in markdown files
  with YAML frontmatter. No JSON, TOML, or binary formats for
  specs.
- **Claude Code as the runtime** — agents execute within Claude
  Code sessions. The system does not target other agent frameworks.
- **Kebab-case naming** — all spec filenames MUST use kebab-case
  (e.g., `build-user-auth.md`, `backend-engineer.md`).
- **Symlink convention** — `.claude/commands/` MUST be a symlink
  to `skills/`. Skills are authored in `skills/` and discovered
  by Claude Code via the symlink. The symlink MUST be committed
  to version control.

## Development Workflow

- **Creating a task**: Create a file in `tasks/` with frontmatter
  (`kind: task`, `name`, `status: backlog`, `agent`, `created`) and
  Requirements + Verification sections in the body. Set
  `status: ready` when the task is ready for an agent.
- **Dispatching an agent**: Launch a Claude Code session with the
  agent spec and the `agent-station-executor` skill. The agent
  finds its ready tasks, follows the manual, and executes.
- **Task lifecycle**: `backlog` → `ready` → `in-progress` → `done`
  (or `failed`). Agents update status in frontmatter as they work.
- **Artifacts**: Step outputs are stored within the task scope (not
  in a separate top-level directory).
- **Sub-tasks**: Created as separate task files with a `parent`
  field referencing the parent task name.

## Governance

This constitution is the authoritative source of project principles
and constraints. It supersedes all other guidance when conflicts
arise.

- **Amendments** MUST be documented with a version bump, rationale,
  and propagation check across dependent templates.
- **Version policy**: MAJOR for principle removals or redefinitions,
  MINOR for new principles or material expansions, PATCH for
  clarifications and wording fixes.
- **Compliance**: All new specs, skills, and structural changes MUST
  be reviewed against these principles before merge.
- **Constitution Check**: The plan template's Constitution Check
  gate MUST verify alignment with the principles listed above.

**Version**: 1.0.0 | **Ratified**: 2026-02-21 | **Last Amended**: 2026-02-21
