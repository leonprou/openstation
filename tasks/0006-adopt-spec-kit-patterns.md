---
kind: task
name: 0006-adopt-spec-kit-patterns
status: backlog
agent: author
created: 2026-02-21
---

# Adopt Spec-Kit Patterns

Implement patterns learned from GitHub's Spec-Kit research
(see `tasks/0005-research-spec-kit-report.md`) that fit Agent
Station's zero-dependency, convention-based philosophy.

## Subtasks

### HIGH Priority

1. **Add constitution file** — Create `constitution.md` at vault
   root with versioned project principles all agents must follow.
   Reference from `manual.md`. Update CLAUDE.md vault structure.

2. **Add templates** — Create `templates/` with structured templates
   for tasks, agents, and research artifacts. Use placeholder tokens.
   Update skills that create artifacts to reference templates.
   Update CLAUDE.md vault structure.

3. **Add workflow-stage skills** — Create `/specify` (description →
   spec), `/plan` (spec → plan), `/breakdown` (plan → tasks) skills
   in `skills/` with symlinks in `.claude/commands/`. These
   complement existing CRUD skills.

### MEDIUM Priority

4. **Add handoff suggestions** — Add `handoffs` field to skill
   frontmatter suggesting the next command. Update workflow skills
   and existing CRUD skills with handoff chains. Document in manual.

5. **Add quality checklist skill** — Create `/checklist` skill that
   validates spec quality before execution (are requirements
   testable? edge cases covered?). Output stored as task artifact.

### LOW Priority

6. **Add audit skill** — Create `/audit` skill for read-only
   cross-artifact consistency checking (broken references, orphaned
   tasks, missing agents).

7. **Add parallel markers convention** — Document convention for
   marking parallelizable tasks in frontmatter
   (`parallelizable: true`). Update manual.

## Verification

- [ ] `constitution.md` exists at vault root and is referenced in manual
- [ ] `templates/` exists with task, agent, and research templates
- [ ] Workflow skills (`specify`, `plan`, `breakdown`) exist with symlinks
- [ ] Skills include `handoffs` in frontmatter where appropriate
- [ ] `/checklist` skill exists
- [ ] `/audit` skill exists
- [ ] Parallel markers convention documented in manual
