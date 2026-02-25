---
kind: spec
name: task-spec
---

# Task Specification

Defines the format for task in Open Station. A task is a
unit of work — a folder containing an `index.md` file with YAML
frontmatter and a markdown body.

## File Location

### Canonical Location

Every task folder lives permanently in `artifacts/tasks/`:

```
artifacts/tasks/NNNN-kebab-slug/
└── index.md
```

Task folders are created here once and never move.

### Bucket Symlinks

Lifecycle buckets contain folder-level symlinks that point back
to the canonical location:

```
tasks/<bucket>/NNNN-kebab-slug/  →  ../../artifacts/tasks/NNNN-kebab-slug/
```

| Bucket | Statuses held |
|--------|---------------|
| `tasks/backlog/` | `backlog` |
| `tasks/current/` | `ready`, `in-progress`, `review` |
| `tasks/done/` | `done`, `failed` |

Moving a task between lifecycle stages = moving the symlink
between buckets. The canonical folder never moves.

## Naming

### Task ID

- 4-digit zero-padded auto-incrementing integer (`0001`, `0042`)
- Unique across all tasks — scan `artifacts/tasks/` to find the
  next available ID

### Slug

- Kebab-case, max 5 words
- Descriptive of the task's goal
- Combined with ID: `NNNN-kebab-slug`

### Folder and `name` field

The folder name and the `name` frontmatter field must match
exactly: `NNNN-kebab-slug`.

### Sub-tasks

Sub-tasks use the naming pattern `NNNN-parent-slug-sub-slug`
and set `parent: <parent-task-name>` in frontmatter.

## Frontmatter Schema

```yaml
---
kind: task              # Required. Always "task".
name: NNNN-kebab-slug   # Required. Matches folder name.
status: backlog         # Required. See Status Values below.
agent:                  # Optional. Agent name assigned to execute.
owner: user             # Required. Who verifies. Default: "user".
parent:                 # Optional. Parent task name (for sub-tasks).
artifacts:              # Optional. List of artifact paths produced.
created: YYYY-MM-DD     # Required. Date the task was created.
---
```

### Editing Guardrails

- Edit only the specific field being changed.
- Preserve all other fields unchanged.
- Always update frontmatter directly — never add a body
  comment as a substitute for a field update.

### Field Reference

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `kind` | string | yes | — | Always `task` |
| `name` | string | yes | — | `NNNN-kebab-slug`, matches folder name |
| `status` | enum | yes | `backlog` | Current lifecycle stage |
| `agent` | string | no | empty | Agent assigned to execute the task |
| `owner` | string | yes | `user` | Who verifies: agent name or `user` |
| `parent` | string | no | empty | Parent task name (for sub-tasks) |
| `artifacts` | list | no | empty | Paths to artifacts produced by this task |
| `created` | date | yes | — | ISO 8601 date (`YYYY-MM-DD`) |

### Status Values

| Value | Meaning |
|-------|---------|
| `backlog` | Created, not ready for execution |
| `ready` | Requirements defined, agent assigned |
| `in-progress` | Agent is actively working |
| `review` | Work complete, awaiting verification |
| `done` | Verification passed |
| `failed` | Verification failed |

See `docs/lifecycle.md` for valid transitions, ownership rules,
sub-task lifecycle, and artifact routing.

## Body Structure

The markdown body follows the frontmatter. It starts with an
H1 title and contains required and optional sections.

### Required Sections

#### `# Title`

Human-readable task title as an H1 heading. Should clearly
describe the goal.

#### `## Requirements`

What needs to be done. Can contain:
- Prose descriptions
- Numbered sub-steps
- Sub-headings (H3) for grouping related requirements
- Tables, code blocks, and links as needed

Requirements should be concrete and testable.

#### `## Verification`

Checklist of items that must be true when the task is complete.
Each item is a GitHub-flavored markdown checkbox:

```markdown
## Verification

- [ ] First verification criterion
- [ ] Second verification criterion
```

Items are checked (`[x]`) as they are verified.

### Optional Sections

| Section              | Purpose                                                         |
| -------------------- | --------------------------------------------------------------- |
| `## Context`         | Background information, links to related tasks or research      |
| `## Subtasks`        | Decomposition into sub-tasks (H3 per group with numbered items) |
| `## Findings`        | Results discovered during research tasks                        |
| `## Recommendations` | Actionable suggestions based on findings                        |

Optional sections appear between Requirements and Verification
when present.

## Progressive Disclosure

Tasks start minimal and gain detail as they mature. Only add
fields and sections when they become relevant — never front-load
structure that isn't needed yet.

### Stages

| Stage          | Frontmatter                                  | Body                                                                  |
| -------------- | -------------------------------------------- | --------------------------------------------------------------------- |
| **Idea**       | `kind`, `name`, `status: backlog`, `created` | `# Title`, `## Requirements` (rough), `## Verification` (placeholder) |
| **Scoped**     | + `agent`, `owner`                           | Requirements become concrete and testable                             |
| **Decomposed** | + `parent` (on sub-tasks)                    | + `## Subtasks` with priority groups                                  |
| **In-flight**  | `status: in-progress`                        | + `## Context` if background is needed                                |
| **Completed**  | `status: done`                               | + `## Findings`, `## Recommendations` (research tasks)                |

### Rules

1. **Start with the minimum** — `kind`, `name`, `status`,
   `created`, a rough Requirements section, and placeholder
   Verification items. This is enough for backlog.
2. **Add assignment when ready** — set `agent` and `owner`
   when the task moves to `ready`. Leave them empty until then.
3. **Decompose only when needed** — add `## Subtasks` and
   `parent` fields only if the task is too large for a single
   agent pass.
4. **Add output sections at the end** — `## Findings` and
   `## Recommendations` are written by agents during execution,
   not by the task author upfront.

## Examples

### Minimal backlog task

```markdown
---
kind: task
name: 0010-add-login-page
status: backlog
agent:
owner: user
created: 2026-02-24
---

# Add Login Page

## Requirements

Create a login page with email and password fields. On submit,
call the `/auth/login` endpoint and redirect to the dashboard
on success.

## Verification

- [ ] Login page renders at `/login`
- [ ] Successful login redirects to `/dashboard`
- [ ] Invalid credentials show an error message
```

### Full investigation task

```markdown
---
kind: task
name: 0003-research-obsidian-plugin-api
status: done
agent: researcher
owner: user
created: 2026-02-21
---

# Research Obsidian Plugin API

## Requirements

Investigate the Obsidian plugin API to understand how Open Station
could integrate with Obsidian as a plugin in the future. Focus on:

- How plugins read and write vault files
- How plugins can add custom views (e.g., a task board)
- How plugins hook into file change events

## Verification

- [x] Research notes cover all three focus areas
- [x] Notes include links to relevant Obsidian documentation
- [x] Findings include a recommendation on feasibility
```

### Task with sub-tasks

```markdown
---
kind: task
name: 0006-adopt-spec-kit-patterns
status: backlog
agent: author
owner: user
created: 2026-02-21
---

# Adopt Spec-Kit Patterns

Implement patterns learned from Spec-Kit research.

## Requirements

Adopt conventions that fit Open Station's zero-dependency
philosophy.

## Subtasks

### HIGH Priority

1. **Add constitution file** — Create `constitution.md` at vault
   root with versioned project principles.

2. **Add templates** — Create `templates/` with structured
   templates for tasks, agents, and research artifacts.

### MEDIUM Priority

3. **Add handoff suggestions** — Add `handoffs` field to skill
   frontmatter suggesting the next command.

## Verification

- [ ] Constitution file exists and is referenced in manual
- [ ] Templates directory exists with task, agent, and research templates
- [ ] Skills include handoffs in frontmatter where appropriate
```
