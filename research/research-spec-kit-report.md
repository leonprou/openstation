# Spec-Kit Research Report

Research artifact for task `0005-research-spec-kit`. Based on source-level
analysis of https://github.com/github/spec-kit (cloned and read in
full).

---

## 1. Architecture Deep-Dive

### Directory Layout

Spec-Kit uses a `.specify/` directory as its namespace inside any
project. After `specify init`, the layout is:

```
.specify/
  memory/
    constitution.md        -- project principles (immutable governance)
  scripts/
    bash/                  -- shell automation (create-new-feature.sh,
                              setup-plan.sh, check-prerequisites.sh,
                              update-agent-context.sh, common.sh)
    powershell/            -- Windows equivalents
  templates/
    constitution-template.md
    spec-template.md
    plan-template.md
    tasks-template.md
    checklist-template.md
    agent-file-template.md
    commands/              -- slash command definitions (9 commands)
  specs/
    001-feature-name/      -- per-feature directory
      spec.md              -- functional specification
      plan.md              -- implementation plan
      tasks.md             -- task breakdown
      research.md          -- tech research
      data-model.md        -- entity definitions
      quickstart.md        -- validation scenarios
      contracts/           -- API contracts
      checklists/          -- quality checklists
```

There is also an `.<agent>/commands/` directory at the project root
(e.g., `.claude/commands/`) where agent-specific command files are
placed during `specify init`.

### File Format

Spec-Kit uses **plain markdown with YAML frontmatter** for slash
commands. The frontmatter schema for commands includes:

```yaml
---
description: "Human-readable description"
handoffs:                          # optional - suggests next commands
  - label: "Build Technical Plan"
    agent: speckit.plan
    prompt: "Create a plan for..."
    send: true                     # optional - auto-send
scripts:                           # optional - shell scripts to run
  sh: scripts/bash/some-script.sh --json
  ps: scripts/powershell/some-script.ps1 -Json
agent_scripts:                     # optional - agent-aware scripts
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
tools:                             # optional - MCP tools needed
  - 'github/github-mcp-server/issue_write'
---
```

Spec files (spec.md, plan.md, tasks.md) are **pure markdown with no
frontmatter** -- they use heading structure and placeholder tokens
(e.g., `[FEATURE NAME]`, `[NEEDS CLARIFICATION]`) instead.

The tasks template has a thin frontmatter (`description` only) but
spec.md and plan.md do not use frontmatter at all -- they rely on
markdown structure.

### Key Architectural Insight

Spec-Kit is NOT a task management system. It is a **specification
authoring pipeline** where each command transforms the previous
stage's output into the next stage's input. The "specs" are the
primary artifact; code is a derived output.

---

## 2. Slash Command System

### How It Works

Spec-Kit abstracts slash commands across 20+ agents through a
**code generation approach** at project init time:

1. **Template commands** live in `templates/commands/*.md` (9 files:
   constitution, specify, plan, tasks, implement, clarify, analyze,
   checklist, taskstoissues).

2. During `specify init --ai <agent>`, the Python CLI reads each
   template command and writes agent-specific files to the agent's
   commands directory.

3. The **AGENT_CONFIG** dictionary in `__init__.py` maps each agent
   to its conventions:

   | Agent         | Directory              | Format   | Argument Syntax |
   |---------------|------------------------|----------|-----------------|
   | Claude Code   | `.claude/commands/`    | Markdown | `$ARGUMENTS`    |
   | Gemini CLI    | `.gemini/commands/`    | TOML     | `{{args}}`      |
   | Copilot       | `.github/agents/`      | Markdown | `$ARGUMENTS`    |
   | Cursor        | `.cursor/commands/`    | Markdown | `$ARGUMENTS`    |
   | Windsurf      | `.windsurf/workflows/` | Markdown | `$ARGUMENTS`    |
   | Codex CLI     | `.codex/prompts/`      | Markdown | `$ARGUMENTS`    |

4. For TOML-based agents (Gemini, Qwen), a format conversion happens
   during init that transforms markdown+frontmatter into TOML with
   a `prompt` field.

### The Adapter Pattern

The key abstraction is the `AGENT_CONFIG` dictionary:

```python
AGENT_CONFIG = {
    "claude": {
        "name": "Claude Code",
        "folder": ".claude/",
        "commands_subdir": "commands",
        "install_url": "https://docs.anthropic.com/...",
        "requires_cli": True,
    },
    # ... 20+ more agents
}
```

Each agent has: display name, directory structure, commands
subdirectory name, install URL, and whether it needs a CLI check.

The CLI then uses this config to:
- Know where to write command files
- Know what format (markdown vs TOML) to use
- Know what argument placeholder to use (`$ARGUMENTS` vs `{{args}}`)
- Check if the agent's CLI tool is installed

### Critical Observation

This is a **static generation** approach, not a runtime abstraction.
Commands are copied/converted at init time and never dynamically
resolved. This means:
- Adding a new command requires re-running init or manually copying
- Commands are duplicated across agent directories
- Updates to templates don't automatically propagate

### The `handoffs` Frontmatter Field

Spec-Kit commands can declare handoffs -- suggested next commands:

```yaml
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...
  - label: Clarify Spec Requirements
    agent: speckit.clarify
    prompt: Clarify specification requirements
    send: true
```

This enables workflow chaining. When a command completes, the agent
can suggest the next step to the user. The `send: true` flag
auto-executes the next command.

---

## 3. Workflow Stages

### Stage 0: Constitution

**Command**: `/speckit.constitution`
**Input**: User's project principles
**Output**: `.specify/memory/constitution.md`

Creates immutable project governance principles. The template has
9 articles (Library-First, CLI Interface, Test-First, etc.). The
command:
- Loads existing constitution or creates from template
- Fills placeholder tokens with user-supplied values
- Versions the constitution (semantic versioning)
- Propagates changes to dependent templates
- Produces a Sync Impact Report

**Transition**: Manual -- user decides when to proceed.

### Stage 1: Specify

**Command**: `/speckit.specify <feature description>`
**Input**: Natural language feature description
**Output**: `specs/NNN-feature-name/spec.md`, git branch

The specify command:
1. Generates a branch name from the description
2. Runs `create-new-feature.sh` to create branch + directory
3. Fills the spec template with user stories, requirements,
   success criteria
4. Creates a quality checklist at `checklists/requirements.md`
5. Runs self-validation (max 3 iterations)
6. Limits `[NEEDS CLARIFICATION]` markers to 3

**Transition**: Suggests `/speckit.clarify` or `/speckit.plan`.

### Stage 2: Clarify (Optional)

**Command**: `/speckit.clarify`
**Input**: Existing spec.md
**Output**: Updated spec.md with clarifications

Interactive sequential questioning (max 5 questions). Each answer
is immediately integrated back into the spec. Uses a taxonomy of
10 categories for ambiguity detection. Provides recommended answers
with reasoning.

**Transition**: Suggests `/speckit.plan`.

### Stage 3: Plan

**Command**: `/speckit.plan <tech stack description>`
**Input**: spec.md + constitution.md
**Output**: plan.md, research.md, data-model.md, contracts/,
           quickstart.md

The plan command:
1. Runs `setup-plan.sh` to copy plan template
2. Fills Technical Context section
3. Runs Constitution Check (quality gates)
4. Phase 0: Research (resolves all NEEDS CLARIFICATION)
5. Phase 1: Design (data model, contracts, quickstart)
6. Runs `update-agent-context.sh` to update agent config file
7. Re-checks constitution after design

**Transition**: Suggests `/speckit.tasks`.

### Stage 4: Tasks

**Command**: `/speckit.tasks`
**Input**: plan.md + spec.md + optional design docs
**Output**: tasks.md

Generates a structured task list organized by:
- Phase 1: Setup (project initialization)
- Phase 2: Foundational (blocking prerequisites)
- Phase 3+: One phase per user story (priority order)
- Final Phase: Polish

Each task has: `- [ ] T001 [P] [US1] Description with file path`
- `[P]` marks parallelizable tasks
- `[US1]` traces task to user story

**Transition**: Suggests `/speckit.analyze` or `/speckit.implement`.

### Stage 5: Analyze (Optional)

**Command**: `/speckit.analyze`
**Input**: spec.md + plan.md + tasks.md + constitution.md
**Output**: Read-only analysis report (not written to file)

Cross-artifact consistency checking: duplication, ambiguity,
underspecification, constitution alignment, coverage gaps,
terminology drift. Assigns severity (CRITICAL/HIGH/MEDIUM/LOW).

**Transition**: User decides whether to fix issues or proceed.

### Stage 6: Implement

**Command**: `/speckit.implement`
**Input**: tasks.md + all design docs
**Output**: Actual code implementation

Executes tasks phase by phase:
1. Checks checklists (stops if incomplete)
2. Creates ignore files (.gitignore, etc.)
3. Parses task dependencies
4. Executes sequentially, respects `[P]` markers
5. Marks completed tasks as `[X]` in tasks.md
6. Validates completion

### Quality Gates

Gates exist at multiple points:
- **Constitution Check**: Before and after planning (plan.md)
- **Requirement Quality Checklist**: After spec creation
- **Checklist System**: Custom checklists before implementation
- **Analyze Command**: Cross-artifact consistency check
- **Implementation Checkpoints**: Per-phase validation

Transitions are **manual** -- the user (or handoff suggestion)
triggers the next stage. There is no automated state machine.

---

## 4. Multi-Agent Abstraction

### Architecture

Spec-Kit supports 20+ agents through a **three-layer approach**:

**Layer 1: Agent-Agnostic Content**
- Templates (`templates/commands/*.md`) use `$ARGUMENTS` and
  `{SCRIPT}` as universal placeholders
- Shell scripts are agent-independent
- All spec artifacts (spec.md, plan.md, tasks.md) are universal

**Layer 2: Agent Config Registry**
- `AGENT_CONFIG` dictionary maps agents to their file conventions
- Each entry defines: folder, commands_subdir, format, CLI tool

**Layer 3: Agent-Specific Generation**
- `specify init --ai <agent>` copies templates to agent-specific
  locations
- Format conversion (markdown to TOML) for agents that need it
- Argument placeholder substitution (`$ARGUMENTS` to `{{args}}`)
- Script path rewriting

### What's Agent-Specific

- Command file location (`.claude/commands/` vs `.gemini/commands/`)
- Command file format (Markdown vs TOML)
- Argument placeholder syntax
- Agent context file (CLAUDE.md vs GEMINI.md vs AGENTS.md)
- VS Code settings (for IDE-based agents)

### What's Agent-Agnostic

- All specification content (spec.md, plan.md, tasks.md, etc.)
- Shell scripts (bash + powershell)
- Templates
- The workflow itself (constitution -> specify -> plan -> tasks ->
  implement)
- Constitution and memory files

---

## 5. Task Generation and Dependencies

### Task Structure

Tasks follow a strict format:
```
- [ ] T001 [P] [US1] Description with exact file path
```

Components:
- **Checkbox**: `- [ ]` (markdown checkbox, marked `[X]` on completion)
- **Task ID**: Sequential (T001, T002, T003...)
- **[P] marker**: Parallelizable (different files, no dependencies)
- **[Story] label**: Maps to user story (US1, US2, US3...)
- **Description**: Action + exact file path

### Dependencies

Dependencies are managed through **phase ordering** and **naming
convention**, not through explicit dependency graphs:

1. **Phase-level ordering**: Setup -> Foundational -> User Stories ->
   Polish. Each phase blocks on the previous.
2. **Within-phase ordering**: Models before services, services before
   endpoints, tests before implementation.
3. **[P] markers**: Tasks marked `[P]` can run in parallel within
   their phase.
4. **User story independence**: Each user story phase is designed to
   be independently testable after the Foundational phase completes.

There are **no explicit task dependency references** (no "depends on
T003" syntax). Ordering is implicit through position in the document
and phase membership.

### Task Execution

The `/speckit.implement` command reads tasks.md and executes:
- Phase by phase, sequentially
- Within each phase, respects [P] markers for parallelism
- Marks tasks `[X]` as they complete
- Stops on non-parallel task failures
- Reports progress after each task

---

## 6. What Agent Station Should Adopt

### 6.1 Constitution/Principles System (HIGH PRIORITY)

**What**: A `memory/` or `principles/` file that defines immutable
project-level governance that all tasks and agents must respect.

**Why**: Spec-Kit's constitution creates consistency across all
generated specs and code. Agent Station lacks project-level
constraints that agents must follow.

**How to adopt**: Add a `constitution.md` (or `principles.md`) to
the vault root. Reference it from `manual.md`. Agent specs should
declare they must read and respect it. This is pure convention --
zero runtime cost.

### 6.2 Workflow Stage Commands (HIGH PRIORITY)

**What**: Explicit slash commands for each workflow stage with clear
inputs, outputs, and transition suggestions.

**Why**: Agent Station has `task-create`, `task-update`, `task-list`,
`dispatch` -- these are CRUD operations, not workflow stages. Spec-Kit
shows that workflow-level commands (specify, plan, tasks, implement)
are more natural for users.

**How to adopt**: Add workflow-oriented skills alongside the existing
CRUD skills. For example:
- `/specify` -- create a specification from a description
- `/plan` -- create an implementation plan from a spec
- `/breakdown` -- generate tasks from a plan
- `/implement` -- execute tasks

These would be skills in `skills/` with symlinks in
`.claude/commands/`. Each skill's markdown body defines the workflow
step, and its frontmatter references the next suggested skill.

### 6.3 Handoff Suggestions in Command Frontmatter (MEDIUM PRIORITY)

**What**: Spec-Kit's `handoffs` field in command frontmatter suggests
the next command after completion.

**Why**: This creates a guided workflow. Users don't need to remember
the right sequence of commands.

**How to adopt**: Add a `handoffs` field to Agent Station skill
frontmatter. The executor skill can read this and suggest the next
step to the user. Example:

```yaml
---
kind: skill
name: specify
handoffs:
  - skill: plan
    prompt: "Create a technical plan for the spec"
---
```

### 6.4 Template-Driven Output (HIGH PRIORITY)

**What**: Each Spec-Kit command fills a structured template rather
than free-form generation.

**Why**: Templates constrain LLM output, prevent drift, and ensure
consistent structure. The spec-template.md forces user stories with
acceptance scenarios, the plan-template.md enforces constitution
checks.

**How to adopt**: Create `templates/` in the vault with:
- `task-template.md` -- template for new task specs
- `agent-template.md` -- template for new agent specs
- `research-template.md` -- template for research artifacts

Skills reference these templates when creating artifacts. This is
pure convention -- templates are just markdown files.

### 6.5 Quality Checklist System (MEDIUM PRIORITY)

**What**: Spec-Kit's `/speckit.checklist` generates "unit tests for
requirements" -- checklists that validate the QUALITY of specs, not
whether they're implemented.

**Why**: Agent Station tasks have Verification sections, but these
check implementation completeness, not specification quality. Adding
a checklist step before execution would catch ambiguities early.

**How to adopt**: Add a `/checklist` skill that reads a task spec and
generates quality-validation questions (e.g., "Are all requirements
testable?", "Are edge cases addressed?"). Store output as an artifact
alongside the task.

### 6.6 Task Format with Parallel Markers (LOW PRIORITY)

**What**: The `[P]` marker and `[US1]` story labels on tasks.

**Why**: Explicit parallelism markers help agents understand which
tasks can be worked simultaneously. Story labels provide traceability.

**How to adopt**: Add conventions to the manual for how to mark tasks
that can be parallelized. Could use tags in frontmatter:
`parallelizable: true`, `story: US1`.

### 6.7 Cross-Artifact Analysis Command (LOW PRIORITY)

**What**: The `/speckit.analyze` command that checks consistency
across spec, plan, and tasks without modifying anything.

**Why**: As Agent Station grows, consistency between tasks, agents,
and skills will matter. A read-only audit skill would catch drift.

**How to adopt**: Create an `/audit` skill that scans all tasks,
agents, and skills for inconsistencies (broken references, missing
agents, orphaned tasks).

---

## 7. What Agent Station Should NOT Adopt

### 7.1 The Python CLI (specify init)

**Why not**: Agent Station's core philosophy is zero runtime
dependencies. Spec-Kit requires `uv`, Python 3.11+, and a CLI tool
(`specify`). The CLI handles agent detection, file generation, and
command format conversion. This adds a build step and dependency
chain that contradicts Agent Station's convention-only approach.

**Alternative**: Agent Station already handles project setup through
its vault structure and CLAUDE.md. No CLI is needed.

### 7.2 Shell Script Automation Layer

**Why not**: Spec-Kit uses 5+ shell scripts (`create-new-feature.sh`,
`setup-plan.sh`, `check-prerequisites.sh`, `update-agent-context.sh`,
`common.sh`) plus PowerShell equivalents. These scripts:
- Create git branches
- Copy templates to feature directories
- Parse plan files for tech stack info
- Update agent context files
- Check prerequisites

This automation is useful but adds operational complexity. Agent
Station agents can do all of this directly through their natural
language capabilities -- an agent reading a template and filling it
in is the same as a shell script copying and sed-ing a template.

**Alternative**: Encode the workflow logic in skill markdown rather
than shell scripts. The agent IS the runtime.

### 7.3 Multi-Agent Command Format Conversion

**Why not**: Spec-Kit's adapter pattern for 20+ agents is impressive
engineering but irrelevant to Agent Station. Agent Station currently
targets Claude Code only via `.claude/commands/` and `--agent`. The
complexity of maintaining TOML conversion, per-agent directories,
and argument placeholder translation is not justified.

**If needed later**: Agent Station could adopt a simpler version --
a skill that generates command files for other agents from a
canonical markdown template. But this should be deferred until
there's actual demand for multi-agent support.

### 7.4 The `.specify/` Namespace

**Why not**: Spec-Kit puts everything under `.specify/`. Agent
Station uses the vault root directly (tasks/, agents/, skills/).
Adding a namespace directory would create unnecessary nesting and
break the current discovery mechanism (`.claude/agents/` symlinks
to `agents/`).

### 7.5 Branch-Coupled Feature Directories

**Why not**: Spec-Kit ties specs to git branches (`001-feature-name`
branch -> `specs/001-feature-name/` directory). This creates a tight
coupling between git workflow and spec organization. Agent Station
tasks are standalone files in `tasks/` -- they don't need branch
awareness.

### 7.6 The Extension System (RFC)

**Why not**: Spec-Kit has an RFC for a full extension system with
manifests, catalogs, hooks, versioning, and package management. This
is enterprise-grade infrastructure. Agent Station should not adopt
this level of complexity. Skills ARE the extension mechanism in Agent
Station -- they're just markdown files.

### 7.7 Agent Context File Generation

**Why not**: Spec-Kit's `update-agent-context.sh` automatically
generates/updates CLAUDE.md, GEMINI.md, AGENTS.md, etc. with project
information extracted from plan.md. This is useful for projects that
use Spec-Kit's planning workflow, but Agent Station's CLAUDE.md is
hand-maintained and specific to the vault's needs.

---

## Summary of Recommendations

| Recommendation | Priority | Effort | Type |
|----------------|----------|--------|------|
| Add constitution/principles file | HIGH | Low | New file + manual update |
| Add workflow-stage skills (specify, plan, breakdown) | HIGH | Medium | New skills |
| Add template-driven output for artifacts | HIGH | Medium | New templates + skill updates |
| Add handoff suggestions to skill frontmatter | MEDIUM | Low | Convention update |
| Add quality checklist skill | MEDIUM | Medium | New skill |
| Add audit/analyze skill | LOW | Medium | New skill |
| Add parallel markers to task convention | LOW | Low | Manual update |
| Python CLI | DO NOT ADOPT | - | Contradicts philosophy |
| Shell script automation | DO NOT ADOPT | - | Agent IS the runtime |
| Multi-agent format conversion | DO NOT ADOPT | - | Premature |
| Extension system | DO NOT ADOPT | - | Over-engineered for vault |

---

## Key Takeaway

Spec-Kit and Agent Station solve different problems. Spec-Kit is a
**specification pipeline** -- it transforms ideas into specs into
plans into tasks into code, with heavy template-driven LLM
constraint. Agent Station is a **task management system** for AI
agents -- it organizes work, assigns agents, and tracks status.

The most valuable thing Agent Station can borrow is Spec-Kit's
**discipline around templates and quality gates**. The templates
force structured output. The constitution enforces consistency. The
checklist validates quality before execution. These are all pure
conventions that require zero runtime dependencies.

The thing Agent Station should explicitly avoid is Spec-Kit's
**toolchain complexity**. The Python CLI, shell scripts, and
multi-agent format conversion are necessary for Spec-Kit's goal of
supporting 20+ agents, but they contradict Agent Station's core
principle of being pure convention with zero runtime dependencies.
