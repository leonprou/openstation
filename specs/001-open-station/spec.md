# Feature Specification: Open Station

**Feature Branch**: `001-open-station`
**Created**: 2026-02-21
**Status**: Draft
**Input**: User description: "build the openstation"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a Task for Agent Execution (Priority: P1)

An operator creates a new task by writing a markdown file in `tasks/`
with the required YAML frontmatter and Requirements + Verification
sections. The task starts in `backlog` and moves to `ready` when it is
fully specified and assigned to an agent.

**Why this priority**: Task creation is the entry point to the system.
Without well-formed tasks, agents have nothing to execute.

**Independent Test**: Create a task file with valid frontmatter. Verify
an agent can parse and pick it up when status is set to `ready`.

**Acceptance Scenarios**:

1. **Given** an operator creates a file in `tasks/` with frontmatter
   (`kind: task`, `name`, `status: backlog`, `agent`, `created`) and
   Requirements + Verification body sections,
   **When** the operator sets `status: ready`,
   **Then** the assigned agent can discover and execute the task.

2. **Given** a task file missing the `kind` or `name` field,
   **When** the executor skill attempts to parse it,
   **Then** the agent skips the file and does not crash.

---

### User Story 2 - Dispatch an Agent to Execute a Task (Priority: P2)

An operator has a task ready for execution. They launch a Claude Code
session with an agent spec and the executor skill. The agent finds the
assigned task, follows the manual's work process, updates task status as
it progresses, and stores artifacts alongside the task.

**Why this priority**: This is the core loop — without dispatch and
execution, there is no system.

**Independent Test**: Create a task with `status: ready` and an
assigned agent. Launch the agent. Verify it picks up the task, moves
through the work process, produces artifacts, and marks the task `done`.

**Acceptance Scenarios**:

1. **Given** a task with `status: ready` and `agent: researcher`,
   **When** the researcher agent is launched with the executor skill,
   **Then** it reads the task, sets `status: in-progress`, follows the
   manual, and produces artifacts within the task scope.

2. **Given** an agent with no ready tasks assigned to it,
   **When** the agent is launched with the executor skill,
   **Then** it reports "No ready tasks" and stops without modifying
   any files.

3. **Given** a task whose verification checklist passes,
   **When** the agent completes execution,
   **Then** it sets `status: done` and writes a verification report.

4. **Given** a task whose verification checklist has a failing item,
   **When** the agent completes execution,
   **Then** it sets `status: failed` and documents which items failed.

---

### User Story 3 - Browse the Vault in Obsidian (Priority: P3)

An operator opens the vault in Obsidian (or any file browser) and can
understand the full state of the system — what tasks exist, their
statuses, which agents are defined, and what the work process is.

**Why this priority**: Human inspectability is a core principle.
The system must be useful without any tooling beyond a file browser.

**Independent Test**: Open the vault directory. Verify every spec is
readable, statuses are visible in frontmatter, and the overall
structure is self-explanatory.

**Acceptance Scenarios**:

1. **Given** a vault with tasks, agents, skills, and a manual,
   **When** an operator opens it in Obsidian or a file browser,
   **Then** the directory structure and file contents are
   self-explanatory without any additional tooling.

2. **Given** multiple tasks in various statuses,
   **When** an operator reads the frontmatter of each task file,
   **Then** the current status, assigned agent, and creation date are
   immediately visible.

---

### Edge Cases

- What happens when two tasks are `ready` for the same agent? The agent
  picks the one with the earliest `created` date.
- What happens when a task references a non-existent agent name? The
  task remains `ready` indefinitely — no agent will claim it.
- What happens when the manual is missing? The executor skill cannot
  guide the agent. The agent should report the missing manual and stop.
- What happens when a sub-task fails? The parent task cannot proceed
  until the sub-task is resolved.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST store all state as markdown files with YAML
  frontmatter in a flat directory structure (`tasks/`, `agents/`,
  `skills/`, plus `manual.md` at the vault root).
- **FR-002**: Task specs MUST include `kind: task`, `name`, `status`,
  `agent`, and `created` fields in frontmatter, with Requirements and
  Verification sections in the body.
- **FR-003**: Agent specs MUST include `kind: agent`, `name`, `model`,
  and `skills` fields in frontmatter. The body defines agent identity,
  capabilities, and constraints — generic, not system-specific.
- **FR-004**: The executor skill MUST teach agents to: discover ready
  tasks, follow the manual, update task status, store artifacts
  alongside the task, and run verification.
- **FR-005**: Task status MUST follow the lifecycle:
  `backlog` -> `ready` -> `in-progress` -> `done` (or `failed`).
  Agents update status in frontmatter as they work.
- **FR-006**: Artifacts MUST be stored within the task scope (alongside
  or nested under the task), not in a separate top-level directory.
- **FR-007**: `manual.md` at the vault root MUST describe the work
  process that agents follow when executing tasks.
- **FR-008**: `.claude/commands/` MUST be a symlink to `skills/` so
  Claude Code discovers skills natively.
- **FR-009**: Sub-tasks MUST be created as separate task files with a
  `parent` field referencing the parent task name.
- **FR-010**: All spec filenames MUST use kebab-case naming.

### Key Entities

- **Task**: A unit of work with status, assigned agent, requirements,
  and a verification checklist. Tracked in frontmatter.
- **Agent**: A Claude Code agent identity — model, skill references,
  capabilities, and constraints.
- **Manual**: A root-level document describing the work process agents
  follow. Plain markdown, no frontmatter.
- **Skill**: Operational knowledge that bridges agents to the system.
  The executor skill is the core skill.
- **Artifact**: An output produced during task execution, stored
  alongside the task.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An operator can create a task, dispatch an agent, and
  receive a completed task with artifacts in a single Claude Code
  session.
- **SC-002**: All system state is inspectable by opening the vault
  directory — no hidden state, no external dependencies.
- **SC-003**: A new agent can participate in the system by referencing
  the executor skill in its spec — no Open Station-specific
  instructions in the agent body.
- **SC-004**: The entire system functions with zero runtime
  dependencies — no servers, no databases, no build steps.
- **SC-005**: Any operator can understand the system's current state
  (task statuses, agent assignments, work process) by browsing the
  vault files in under 5 minutes.

## Assumptions

- Operators are familiar with Claude Code and can launch sessions with
  agent specs and skills.
- The vault lives in a git repository for version control and
  collaboration.
- Only one agent session works on a given task at a time — no
  concurrent execution of the same task.
- The initial version ships with one agent (researcher) and one manual
  to validate the system end-to-end.
