---
kind: spec
name: agent-station-implementation-plan
created: 2026-02-20
---

# Agent Station Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Bootstrap the Agent Station vault — folder structure, spec templates, the executor skill, and a sample task to validate the system end-to-end.

**Architecture:** Pure convention system — markdown files with YAML frontmatter, organized in an Obsidian vault. No runtime code. A Claude Code skill (`agent-station-executor`) teaches agents how to operate within the system.

**Tech Stack:** Markdown, YAML frontmatter, Claude Code skills

---

### Task 1: Create vault folder structure

**Files:**
- Create: `tasks/.gitkeep`
- Create: `agents/.gitkeep`
- Create: `workflows/.gitkeep`
- Create: `artifacts/.gitkeep`
- Create: `skills/.gitkeep`

**Step 1: Create directories with .gitkeep files**

```bash
mkdir -p tasks agents workflows artifacts skills
touch tasks/.gitkeep agents/.gitkeep workflows/.gitkeep artifacts/.gitkeep skills/.gitkeep
```

**Step 2: Verify structure**

```bash
find . -maxdepth 2 -not -path './.git/*' -not -path './.claude/*' -not -path './docs/*' | sort
```

Expected: all five directories present with .gitkeep files.

**Step 3: Commit**

```bash
git add tasks agents workflows artifacts skills
git commit -m "chore: create vault folder structure"
```

---

### Task 2: Write the `feature-development` workflow spec

**Files:**
- Create: `workflows/feature-development.md`

**Step 1: Create the workflow spec**

Write `workflows/feature-development.md`:

```markdown
---
kind: workflow
name: feature-development
---

# Feature Development

A linear pipeline for building new features from research through verification.

## Steps

### 1. Research
Gather context about the requirements. Read relevant codebase, documentation, and prior decisions. Understand the problem space before proposing solutions.

**produces:** research-notes

### 2. Plan
Create an implementation plan based on the research. Define the approach, files to create or modify, and testing strategy. Get approval before proceeding.

**produces:** implementation-plan

### 3. Implement
Execute the plan. Write code, tests, and any necessary documentation changes. Follow the project's conventions and the agent spec's constraints.

**produces:** code-changes

### 4. Verify
Run the verification checklist from the task spec. Confirm all criteria pass. If any fail, document what failed and why.

**produces:** verification-report
```

**Step 2: Verify frontmatter parses correctly**

```bash
head -4 workflows/feature-development.md
```

Expected: valid YAML frontmatter with `kind: workflow` and `name: feature-development`.

**Step 3: Commit**

```bash
git add workflows/feature-development.md
git commit -m "feat: add feature-development workflow spec"
```

---

### Task 3: Write the `bug-fix` workflow spec

**Files:**
- Create: `workflows/bug-fix.md`

**Step 1: Create the workflow spec**

Write `workflows/bug-fix.md`:

```markdown
---
kind: workflow
name: bug-fix
---

# Bug Fix

A focused pipeline for diagnosing and fixing bugs.

## Steps

### 1. Reproduce
Understand and reproduce the bug. Document the expected vs actual behavior, and the steps to trigger it.

**produces:** reproduction-report

### 2. Diagnose
Trace the root cause. Identify the specific code, configuration, or interaction causing the bug.

**produces:** diagnosis-notes

### 3. Fix
Implement the minimal fix. Write a regression test that fails without the fix and passes with it.

**produces:** code-changes

### 4. Verify
Run the verification checklist from the task spec. Confirm the bug is fixed and no regressions introduced.

**produces:** verification-report
```

**Step 2: Commit**

```bash
git add workflows/bug-fix.md
git commit -m "feat: add bug-fix workflow spec"
```

---

### Task 4: Write a sample agent spec — `researcher`

**Files:**
- Create: `agents/researcher.md`

**Step 1: Create the agent spec**

Write `agents/researcher.md`:

```markdown
---
kind: agent
name: researcher
model: claude-sonnet-4-6
skills:
  - agent-station-executor
---

# Researcher

You are a research agent. Your job is to gather, analyze, and synthesize information to support decision-making.

## Capabilities
- Search codebases, documentation, and the web for relevant information
- Analyze and compare technical approaches
- Produce structured research summaries with clear recommendations

## Constraints
- Present findings with evidence, not opinion
- Flag uncertainty explicitly — distinguish "confirmed" from "likely" from "unknown"
- Keep summaries concise — lead with conclusions, support with details
```

**Step 2: Commit**

```bash
git add agents/researcher.md
git commit -m "feat: add researcher agent spec"
```

---

### Task 5: Write the `agent-station-executor` skill

This is the core of Agent Station. It teaches any Claude Code agent how to operate within the system.

**Files:**
- Create: `skills/agent-station-executor.md`

**Step 1: Create the skill file**

Write `skills/agent-station-executor.md`:

```markdown
---
name: agent-station-executor
description: Teaches agents how to operate within Agent Station — find tasks, follow workflows, update state, and store artifacts.
---

# Agent Station Executor

You are operating within **Agent Station**, a task management system. All state is stored as markdown files with YAML frontmatter. Follow these instructions exactly.

## Vault Structure

```
tasks/          — Task specs (your work items)
agents/         — Agent specs (agent definitions)
workflows/      — Workflow specs (step pipelines)
artifacts/      — Task-scoped outputs, nested by task name
skills/         — Skills (including this one)
```

## On Startup

1. Determine your agent name from context (the agent spec you were launched with)
2. Scan all files in `tasks/` for specs where `agent` matches your name AND `status` is `ready`
3. If multiple ready tasks exist, pick the one with the earliest `created` date
4. If no ready tasks exist, report: "No ready tasks assigned to agent [name]." and stop

## Executing a Task

When you have a task to execute:

### 1. Load Context
- Read the task spec completely — note `workflow`, `current_step`, requirements, and verification
- Read the workflow spec from `workflows/<workflow-name>.md`
- Determine the current step: use `current_step` from frontmatter, or default to the first step

### 2. Begin Work
- Update the task frontmatter: set `status: in-progress`
- If `current_step` is not set, set it to the first step's name

### 3. Execute Current Step
- Read the step's instructions from the workflow spec
- Follow the instructions to produce the step's artifact
- Save the artifact to `artifacts/<task-name>/<artifact-name>.md`

### 4. Advance to Next Step
- Update `current_step` in the task frontmatter to the next step
- If there are no more steps, proceed to Completion

### 5. Repeat
- Execute steps 3-4 until all workflow steps are done

## Completing a Task

After all workflow steps are finished:

1. Read the **Verification** section of the task spec
2. Check each verification item
3. If ALL items pass:
   - Update task frontmatter: `status: done`
   - Write a summary to `artifacts/<task-name>/verification-report.md`
4. If ANY item fails:
   - Update task frontmatter: `status: failed`
   - Document which items failed and why in `artifacts/<task-name>/verification-report.md`

## Creating Sub-Tasks

If a workflow step requires decomposition into smaller pieces:

1. Create a new task file in `tasks/` with a descriptive name
2. Set `parent: <current-task-name>` in frontmatter
3. Set `status: backlog` (or `ready` if it can be executed immediately)
4. Assign an `agent` and `workflow`
5. Sub-tasks must be completed before the parent task can proceed

## Updating Frontmatter

When updating YAML frontmatter in task specs:
- Use the Edit tool to modify only the specific field
- Preserve all other fields unchanged
- Always update the frontmatter, never just add a comment in the body

## Storing Artifacts

- All artifacts go in `artifacts/<task-name>/`
- Use the artifact name from the workflow's `**produces:**` field as the filename
- Artifact files are markdown with a descriptive title and structured content
- Include enough context that the artifact is useful on its own (not just to the current agent session)
```

**Step 2: Review the skill for completeness**

Verify the skill covers all six responsibilities from the design doc:
1. Read the assigned task — YES (On Startup + Load Context)
2. Load the workflow — YES (Load Context)
3. Execute the current step — YES (Execute Current Step)
4. Update task state — YES (Updating Frontmatter + Advance)
5. Store artifacts — YES (Storing Artifacts)
6. Handle completion — YES (Completing a Task)

**Step 3: Commit**

```bash
git add skills/agent-station-executor.md
git commit -m "feat: add agent-station-executor skill — core of Agent Station"
```

---

### Task 6: Write a sample task spec to validate the system

Create a real task that tests the entire flow. The task is for the `researcher` agent to research a topic using the `feature-development` workflow.

**Files:**
- Create: `tasks/research-obsidian-plugin-api.md`

**Step 1: Create the task spec**

Write `tasks/research-obsidian-plugin-api.md`:

```markdown
---
kind: task
name: research-obsidian-plugin-api
status: ready
workflow: feature-development
agent: researcher
created: 2026-02-20
---

# Research Obsidian Plugin API

## Requirements
Investigate the Obsidian plugin API to understand how Agent Station could integrate with Obsidian as a plugin in the future. Focus on:
- How plugins read/write vault files
- How plugins can add custom views (e.g., a task board)
- How plugins hook into file change events

## Verification
- [ ] Research notes cover all three focus areas
- [ ] Notes include links to relevant Obsidian docs
- [ ] Findings include a recommendation on feasibility
```

**Step 2: Verify all references are valid**

```bash
# Check that the referenced workflow exists
ls workflows/feature-development.md

# Check that the referenced agent exists
ls agents/researcher.md
```

Expected: both files exist.

**Step 3: Commit**

```bash
git add tasks/research-obsidian-plugin-api.md
git commit -m "feat: add sample task spec for system validation"
```

---

### Task 7: Write project CLAUDE.md

**Files:**
- Create: `CLAUDE.md`

**Step 1: Create the project CLAUDE.md**

Write `CLAUDE.md`:

```markdown
# Agent Station

Task management system for Claude Code agents. Pure convention — markdown specs + skills.

## Vault Structure

- `tasks/` — Task specs. Status tracked in frontmatter.
- `agents/` — Agent specs. Generic agent instructions + skill references.
- `workflows/` — Workflow specs. Linear step pipelines.
- `artifacts/` — Task-scoped outputs, nested by task name.
- `skills/` — Agent Station skills (loaded by agents at runtime).

## Spec Format

All specs use YAML frontmatter with a `kind` field (`task`, `agent`, or `workflow`) followed by markdown content.

## Creating a New Task

1. Create a file in `tasks/` with a descriptive kebab-case name
2. Add frontmatter: `kind: task`, `name`, `status: backlog`, `workflow`, `agent`, `created`
3. Write Requirements and Verification sections in the body
4. Set `status: ready` when the task is ready for an agent

## Dispatching an Agent

```bash
claude --agent agents/<agent-name>.md --skill skills/agent-station-executor.md
```

The agent will find its ready tasks, load the workflow, and execute step by step.

## Task Statuses

- `backlog` — created, not ready
- `ready` — requirements defined, agent assigned
- `in-progress` — agent is working
- `done` — verification passed
- `failed` — verification failed
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add project CLAUDE.md with vault conventions"
```

---

### Task 8: End-to-end validation

Verify all specs are internally consistent and the system is ready for use.

**Step 1: Verify all task references resolve**

```bash
# For each task, check that its workflow and agent exist
for task in tasks/*.md; do
  echo "=== $task ==="
  grep "^workflow:" "$task" | awk '{print "workflows/"$2".md"}' | xargs ls 2>&1
  grep "^agent:" "$task" | awk '{print "agents/"$2".md"}' | xargs ls 2>&1
done
```

Expected: all referenced files exist, no errors.

**Step 2: Verify agent skill references exist**

```bash
for agent in agents/*.md; do
  echo "=== $agent ==="
  # Check that agent-station-executor skill exists
  ls skills/agent-station-executor.md 2>&1
done
```

Expected: skill file exists.

**Step 3: Verify vault structure is complete**

```bash
ls -la tasks/ agents/ workflows/ artifacts/ skills/
```

Expected: all directories exist with their content files.

**Step 4: Final commit (if any fixes were needed)**

If any issues were found and fixed, commit the fixes:

```bash
git add -A
git commit -m "fix: resolve spec reference issues found during validation"
```

If no fixes needed, skip this step.
