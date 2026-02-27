---
kind: task
name: 0011-add-project-manager-agent
status: done
agent: author
owner: manual
artifacts:
  - artifacts/agents/project-manager.md
created: 2026-02-27
---

# Introduce a Project Manager Agent

## Requirements

Create a new agent spec at `agents/project-manager.md` that defines
a project manager role for Open Station. This agent is responsible
for high-level coordination across the vault:

### Core responsibilities

1. **Create and manage tasks** — Create new tasks via
   `/openstation.create`. Prioritize and triage the backlog.
   Promote tasks to ready when requirements are clear. Monitor
   in-progress work and flag stalled tasks. Review completed
   work (act as verifier).

2. **Assign tasks to agents** — Match tasks to the right agent
   (`author`, `researcher`, or others) based on task type and
   agent capabilities. Balance workload across agents. Reassign
   when needed.

3. **Organize artifacts** — Oversee artifact promotion from
   completed tasks to canonical locations (`artifacts/research/`,
   `artifacts/specs/`). Ensure artifacts follow naming conventions
   and are properly cross-referenced. Keep `artifacts/` clean
   and navigable.

4. **Manage docs** — Keep `docs/` accurate and up-to-date.
   Ensure CLAUDE.md reflects current vault structure and
   conventions. Identify documentation gaps and create tasks
   to fill them.

5. **Plan future work** — Maintain the project roadmap
   (`artifacts/tasks/roadmap.md`). Break down large goals into
   actionable tasks. Sequence work across agents to avoid
   conflicts and maximize throughput. Think ahead about what
   the project needs next.

### Agent spec requirements

- Frontmatter with `kind: agent`, `name`, `skills` list
- Identity section describing the PM role and decision authority
- Clear boundaries: the PM coordinates but does not implement.
  If a task falls outside its core responsibilities, the PM
  delegates by assigning it to the best-suited agent (`author`,
  `researcher`, or others)
- Skills: should reference `openstation-execute` plus any
  PM-specific skills needed

### Integration

- The PM agent should be launchable via `claude --agent project-manager`
- Symlink from `.claude/agents/project-manager.md` to
  `agents/project-manager.md`

## Verification

- [ ] `agents/project-manager.md` exists with valid frontmatter
- [ ] `.claude/agents/project-manager.md` symlink resolves correctly
- [ ] Agent spec defines task, docs, artifact, and planning responsibilities
- [ ] Agent delegates implementation work — does not self-implement
- [ ] Agent can be invoked via `claude --agent project-manager`
