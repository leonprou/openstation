# Data Model: Agent Station

All entities are markdown files with YAML frontmatter. This document
defines the schema for each entity type.

## Task Spec

**Location**: `tasks/<task-name>.md`
**Discriminator**: `kind: task`

### Frontmatter Schema

| Field     | Type   | Required | Values / Description                              |
|-----------|--------|----------|---------------------------------------------------|
| `kind`    | string | yes      | `task`                                             |
| `name`    | string | yes      | Kebab-case identifier (matches filename sans `.md`) |
| `status`  | string | yes      | `backlog`, `ready`, `in-progress`, `done`, `failed` |
| `agent`   | string | yes      | Name of the assigned agent                         |
| `created` | date   | yes      | ISO date (YYYY-MM-DD)                              |
| `parent`  | string | no       | Name of parent task (for sub-tasks)                |

### Body Sections

| Section          | Required | Description                                  |
|------------------|----------|----------------------------------------------|
| Requirements     | yes      | What needs to be done                        |
| Verification     | yes      | Checklist for confirming completion           |

### State Transitions

```
backlog → ready → in-progress → done
                               → failed
```

- `backlog` → `ready`: Operator sets when task is fully specified
- `ready` → `in-progress`: Agent sets when it begins execution
- `in-progress` → `done`: Agent sets when verification passes
- `in-progress` → `failed`: Agent sets when verification fails

### Example

```yaml
---
kind: task
name: research-obsidian-plugin-api
status: ready
agent: researcher
created: 2026-02-21
---

# Research Obsidian Plugin API

## Requirements
Investigate the Obsidian plugin API...

## Verification
- [ ] Research notes cover all focus areas
- [ ] Notes include links to relevant docs
```

---

## Agent Spec

**Location**: `agents/<agent-name>.md`
**Discovery**: `.claude/agents/` → symlink to `agents/`
**Discriminator**: `kind: agent`

### Frontmatter Schema

| Field         | Type     | Required | Values / Description                          |
|---------------|----------|----------|-----------------------------------------------|
| `kind`        | string   | yes      | `agent`                                        |
| `name`        | string   | yes      | Kebab-case identifier                          |
| `description` | string   | yes      | What the agent does (for Claude Code discovery) |
| `model`       | string   | no       | `claude-opus-4-6`, `claude-sonnet-4-6`, etc.   |
| `skills`      | string[] | yes      | Skills to preload (must include `agent-station-executor`) |

### Body Sections

| Section       | Required | Description                                    |
|---------------|----------|------------------------------------------------|
| Identity      | yes      | Who the agent is (role description)             |
| Capabilities  | yes      | What the agent can do                           |
| Constraints   | no       | Behavioral guardrails                           |

Agent body MUST NOT contain Agent Station-specific instructions
(Constitution Principle II).

### Example

```yaml
---
kind: agent
name: researcher
description: Research agent for gathering and analyzing information
model: claude-sonnet-4-6
skills:
  - agent-station-executor
---

# Researcher

You are a research agent. Your job is to gather, analyze, and
synthesize information to support decision-making.

## Capabilities
- Search codebases, documentation, and the web
- Analyze and compare technical approaches
- Produce structured research summaries

## Constraints
- Present findings with evidence, not opinion
- Flag uncertainty explicitly
- Keep summaries concise
```

---

## Manual

**Location**: `manual.md` (vault root)
**Format**: Plain markdown, no frontmatter

### Sections

| Section          | Required | Description                                       |
|------------------|----------|---------------------------------------------------|
| Work Process     | yes      | Steps agents follow when executing tasks           |
| Artifact Storage | yes      | Where and how to store outputs                     |
| Sub-tasks        | no       | How to decompose work into sub-tasks               |
| Completion       | yes      | How to run verification and mark tasks done/failed |

---

## Skill (Executor)

**Location**: `skills/agent-station-executor.md`
**Discovery**: `.claude/commands/` → symlink to `skills/`
**Format**: Markdown with YAML frontmatter (Claude Code command format)

### Frontmatter Schema

| Field         | Type   | Required | Description                        |
|---------------|--------|----------|------------------------------------|
| `name`        | string | no       | Display name for slash command      |
| `description` | string | yes      | When Claude should use this skill   |

### Body

The executor skill body contains the full operational instructions
for how agents interact with Agent Station: startup sequence, task
discovery, manual loading, status updates, artifact storage, and
completion handling.

---

## Artifact

**Location**: Alongside the task in `tasks/`
**Format**: Markdown (no required frontmatter)

For tasks producing a single artifact, the artifact file sits next to
the task file in `tasks/`. For tasks producing multiple artifacts, a
subdirectory `tasks/<task-name>/` contains both the task spec and its
artifacts.

### Single-artifact layout

```
tasks/
├── research-obsidian-plugin-api.md
└── research-obsidian-plugin-api-notes.md   # artifact
```

### Multi-artifact layout

```
tasks/
└── build-user-auth/
    ├── build-user-auth.md                  # task spec
    ├── research-notes.md                   # artifact
    └── implementation-plan.md              # artifact
```
