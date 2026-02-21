# Implementation Plan: Agent Station

**Branch**: `001-agent-station` | **Date**: 2026-02-21 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-agent-station/spec.md`

## Summary

Build the Agent Station vault — directory structure, spec templates
(task + agent), the executor skill, a root-level manual, a sample
agent and task, project CLAUDE.md, and the `.claude/commands/` symlink.
Pure convention system: markdown files with YAML frontmatter, zero
runtime dependencies.

## Technical Context

**Language/Version**: N/A — no code; all content is Markdown + YAML frontmatter
**Primary Dependencies**: None — zero runtime dependencies
**Storage**: Filesystem (markdown files in a git-tracked vault)
**Testing**: Manual validation — verify specs parse, references resolve, end-to-end dispatch works
**Target Platform**: Claude Code sessions on any OS
**Project Type**: Convention system (markdown vault)
**Performance Goals**: N/A — no runtime
**Constraints**: Zero dependencies, all state in markdown, human-readable without tooling
**Scale/Scope**: v1 ships with 1 agent, 1 manual, 1 sample task, 1 skill

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Everything Is a Spec | PASS | Tasks and agents are markdown with YAML frontmatter. `kind` + `name` fields required. |
| II. Skills Are the Glue | PASS | Agent specs contain no system-specific instructions. The executor skill is the sole bridge. |
| III. Obsidian Is the Database | PASS | All state in markdown files. Flat-by-type: `tasks/`, `agents/`, `skills/`, `manual.md` at root. Artifacts alongside tasks. |
| IV. Manual Dispatch | PASS | Human launches sessions. No automated scheduler. |
| Kebab-case naming | PASS | All spec filenames use kebab-case. |
| Symlink convention | PASS | `.claude/commands/` → `skills/`, `.claude/agents/` → `agents/`. |
| Markdown + YAML only | PASS | No JSON, TOML, or binary formats. |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-agent-station/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
agent-station/
├── tasks/                    # Task specs
│   └── research-obsidian-plugin-api.md  # Sample task
├── agents/                   # Agent specs
│   └── researcher.md         # Sample agent
├── skills/                   # Agent Station skills
│   └── agent-station-executor.md
├── manual.md                 # Work process document
├── CLAUDE.md                 # Project instructions for Claude Code
└── .claude/
    ├── agents/ → ../../agents/    # Symlink for agent discovery
    └── commands/ → ../../skills/  # Symlink for skill discovery
```

**Structure Decision**: No `src/` or `tests/` directories. This is a
pure convention system — the deliverables are markdown files organized
in a flat-by-type vault structure per Constitution Principle III.
No `contracts/` directory needed — the executor skill itself defines
the contract between agents and the system.

## Research Findings (Phase 0)

Key discoveries that affect implementation (full details in
[research.md](research.md)):

1. **Agent discovery**: Claude Code resolves `--agent <name>` from
   `.claude/agents/`. Added `.claude/agents/` → `agents/` symlink.
2. **No `--skill` flag**: Skills load via the `skills` field in agent
   frontmatter. Dispatch is simply `claude --agent researcher`.
3. **Agent frontmatter**: Merges Agent Station fields (`kind`) with
   Claude Code fields (`description`, `model`, `skills`). Extra
   fields are ignored by Claude Code.
4. **Artifacts**: Stored alongside tasks in `tasks/`. Multi-artifact
   tasks use a subdirectory.

## Complexity Tracking

No violations — no complexity tracking needed.
