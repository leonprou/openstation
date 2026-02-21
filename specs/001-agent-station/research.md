# Research: Agent Station

## R1: Claude Code Agent Discovery

**Decision**: Agent specs live in `agents/` at vault root with a
symlink `.claude/agents/` → `agents/`, mirroring the existing
`.claude/commands/` → `skills/` symlink convention.

**Rationale**: Claude Code discovers agents from `.claude/agents/`
(project-level) or `~/.claude/agents/` (user-level) when launched
with `claude --agent <name>`. The `--agent` flag takes a name (not a
path) and resolves it from these directories. A symlink keeps the
vault's flat-by-type structure while enabling Claude Code discovery.

**Alternatives considered**:
- Put agents directly in `.claude/agents/` — violates Constitution
  Principle III (vault structure must be `tasks/`, `agents/`, `skills/`
  at root).
- Use full paths with `--agent` — not supported; it resolves by name
  from known directories.

## R2: Agent Spec Frontmatter

**Decision**: Agent specs include both Agent Station fields (`kind`,
`name`) and Claude Code fields (`description`, `tools`, `model`,
`skills`). Claude Code ignores unknown frontmatter fields.

**Rationale**: The constitution requires `kind` and `name` in all
specs. Claude Code agent specs require `name` and `description` at
minimum. Since Claude Code ignores extra fields, both can coexist.

**Merged format**:
```yaml
kind: agent
name: researcher
description: Research agent for gathering and analyzing information
model: claude-sonnet-4-6
skills:
  - agent-station-executor
```

**Alternatives considered**:
- Separate Agent Station metadata from Claude Code metadata — adds
  complexity with no benefit since extra fields are ignored.

## R3: Skill Discovery via Symlink

**Decision**: Skills are single `.md` files in `skills/` (commands
format). `.claude/commands/` symlinks to `skills/`.

**Rationale**: Claude Code discovers slash commands from
`.claude/commands/<name>.md`. The symlink makes `skills/` files
discoverable without duplication. The `skills` field in agent
frontmatter references skill names, which resolve through the same
discovery mechanism.

**Key detail**: The executor skill should NOT set
`disable-model-invocation: true` — agents need to auto-load it
via the `skills` field in their frontmatter.

## R4: Dispatch Command

**Decision**: The correct dispatch command is:
```bash
claude --agent researcher
```

**Rationale**: There is no `--skill` flag. Skills are loaded
automatically when listed in the agent's `skills` frontmatter field.
The `--agent` flag resolves the agent by name from `.claude/agents/`.

The old design doc's command
(`claude --agent agents/researcher.md --skill skills/agent-station-executor.md`)
is invalid — both flags are wrong.

**Alternatives considered**:
- Manual skill invocation via `/agent-station-executor` — requires
  the operator to type a slash command every session. The `skills`
  field in agent frontmatter auto-loads it.

## R5: Artifact Storage

**Decision**: Artifacts are stored alongside the task file, not in a
separate directory. For tasks that produce multiple artifacts, a
subdirectory named after the task can be created under `tasks/`.

**Rationale**: Constitution Principle III requires artifacts alongside
tasks. Options:
- Single artifact: place next to task file in `tasks/`
- Multiple artifacts: `tasks/<task-name>/` directory containing the
  task spec and its artifacts

**Alternatives considered**:
- Top-level `artifacts/` directory — explicitly rejected by
  constitution ("Task artifacts MUST be stored alongside their task,
  not in a separate top-level directory").

## R6: No `--skill` Flag Exists

**Decision**: Remove all references to `--skill` from design docs.
Skill loading happens through agent frontmatter `skills` field or
user invocation via `/skill-name`.

**Rationale**: Confirmed via Claude Code documentation — the `--skill`
flag does not exist. Skills are auto-discovered from `.claude/commands/`
and `.claude/skills/` directories.
