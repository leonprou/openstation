---
kind: spec
name: agent-station-design
created: 2026-02-20
---

# Agent Station Design

## Overview

Agent Station is a task management system for Claude Code agents. It uses markdown specs as the sole data format, Obsidian as the human interface, and skills as the agent interface. Zero runtime dependencies — the system is pure convention.

## Core Principles

- **Everything is a spec** — tasks, agents, and workflows are all markdown files with YAML frontmatter
- **Skills are the glue** — Agent Station operational knowledge lives in skills, not agent specs
- **Obsidian is the database** — markdown files in a vault, human-browsable and agent-readable
- **Manual dispatch** — a human launches Claude Code sessions pointed at tasks
- **Linear workflows** — sequential step pipelines, simple and predictable

## Unified Spec Format

Every primitive shares this structure:

```markdown
---
kind: task | agent | workflow
name: human-readable-name
# ... kind-specific fields
---

# Markdown body — instructions, requirements, notes
```

The `kind` field discriminates the type. Frontmatter schema varies by kind. Body is free-form markdown.

## Primitives

### Task Spec

```yaml
kind: task
name: build-user-auth
status: backlog | ready | in-progress | done | failed
workflow: feature-development
agent: backend-engineer
current_step: implement
parent: optional-parent-task-name
created: 2026-02-20
```

Body contains:
- **Requirements** — what needs to be built
- **Verification** — checklist for confirming completion (used by the agent)

Sub-tasks are separate files referencing a `parent` task.

### Agent Spec

```yaml
kind: agent
name: backend-engineer
model: claude-opus-4-6
skills:
  - agent-station-executor
  - test-driven-development
```

Body contains:
- Agent identity, capabilities, and constraints
- Generic instructions — NOT Agent Station-specific
- The `agent-station-executor` skill bridges agents to the system

### Workflow Spec

```yaml
kind: workflow
name: feature-development
```

Body contains ordered steps as markdown headings:

```markdown
### 1. Research
Gather context. Produce research summary.
**produces:** research-notes

### 2. Plan
Create implementation plan.
**produces:** implementation-plan

### 3. Implement
Execute the plan. Write code and tests.
**produces:** code-changes

### 4. Verify
Run verification checklist from task spec.
**produces:** verification-report
```

Steps are sequential. Each step produces named artifacts.

## Vault Structure

```
agent-station/
├── tasks/                    # Task specs
├── agents/                   # Agent specs
├── workflows/                # Workflow specs
├── artifacts/                # Task-scoped outputs
│   └── <task-name>/
│       ├── research-notes.md
│       └── implementation-plan.md
├── skills/                   # Agent Station skills
│   └── agent-station-executor.md
└── .claude/
    └── settings.json
```

Flat by type. Artifacts nested by task name.

## Skills

The `agent-station-executor` skill teaches any Claude Code agent how to:

1. **Read the assigned task** — parse frontmatter, understand requirements and verification
2. **Load the workflow** — find the referenced workflow, determine current step
3. **Execute the current step** — follow step instructions, produce artifacts
4. **Update task state** — advance `current_step`, update `status` in frontmatter
5. **Store artifacts** — write outputs to `artifacts/<task-name>/`
6. **Handle completion** — run verification checklist, mark task done or failed

## Dispatch Model

A human launches a Claude Code session:

```bash
claude --agent agents/backend-engineer.md --skill skills/agent-station-executor.md
```

The skill instructs the agent to:
1. Find assigned tasks in `tasks/` (where `agent: <name>` and `status: ready`)
2. Load the referenced workflow
3. Execute from `current_step` (or step 1 if new)

## Task Lifecycle

```
backlog → ready → in-progress → done
                              → failed
```

- **backlog** — created but not ready for execution
- **ready** — requirements defined, agent assigned, workflow set
- **in-progress** — agent is actively working (with `current_step` tracking progress)
- **done** — verification checklist passed
- **failed** — verification failed or agent encountered a blocking issue

## What's Intentionally Out of Scope (v1)

- Automated dispatch / task watching
- CLI tooling for spec validation
- DAG or state-machine workflows
- Cross-task knowledge base
- Step-level agent overrides
- Parallel step execution
