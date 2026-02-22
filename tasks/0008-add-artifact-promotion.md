---
kind: task
name: 0008-add-artifact-promotion
status: in-progress
agent:
owner: manual
created: 2026-02-22
---

# Add Artifact Promotion Workflow

## Requirements

When a task reaches `status: done`, its spec and artifacts should be
promoted out of `tasks/` to the appropriate destination, keeping
`tasks/` as a clean active work queue.

### Routing rules

Task specs are split from artifacts:

| What | Destination |
|------|-------------|
| Task spec (always) | `archive/tasks/` |
| Artifacts from `researcher` | `research/` |
| Artifacts from other agents | `specs/` |
| No agent (no artifacts) | just `archive/tasks/` |

### File naming

Strip the `NNNN-` ID prefix during promotion. Keep the rest as-is.
For subdirectory-format tasks, move the whole directory and strip
the ID from the directory name.

### Deliverables

1. **Create `skills/agent-station.promote.md`** — new skill that
   promotes a done task to the correct destination. Input is the
   task name. Procedure: locate task, verify done status, find
   associated files (same ID prefix or subdirectory), determine
   destination from agent field, strip ID prefix, move files,
   confirm.

2. **Create `.claude/commands/agent-station.promote.md`** — symlink
   to `../../skills/agent-station.promote.md`.

3. **Update `manual.md`** — add "Promoting Completed Work" section
   after "Verifying a Task" with split routing rules.

4. **Update `CLAUDE.md`** — update Artifacts section and vault
   structure to reflect `specs/`, `archive/tasks/`.

5. **Create `archive/tasks/`** — directory for all completed task
   specs.

6. **Update `skills/agent-station.execute.md`** — update vault
   structure listing to reflect `specs/`, `archive/tasks/`.

7. **Migrate existing done tasks** (split spec from artifacts):
   - `0001-add-operator-commands` spec → `archive/tasks/`
   - `0002-update-vault-structure` spec → `archive/tasks/`
   - `0003-research-obsidian-plugin-api` spec → `archive/tasks/`,
     notes artifact → `research/`
   - `0004-research-spec-agent-role` spec → `archive/tasks/`,
     notes artifact → `research/`
   - `0005-research-spec-kit` spec → `archive/tasks/`,
     report artifact → `research/`
   - `0007-add-verifier-field` spec → `archive/tasks/`

## Verification

- [ ] `/agent-station.promote` skill exists and symlink works
- [ ] Manual has "Promoting Completed Work" section with split routing
- [ ] CLAUDE.md documents split promotion and new vault structure
- [ ] All done task specs in `archive/tasks/` (6 files)
- [ ] `research/` has 3 artifact files (notes + report), no task specs
- [ ] `specs/` has `001-agent-station/` (unchanged)
- [ ] `projects/` and `archived/` directories removed
- [ ] `tasks/` contains only active tasks (0006, 0008)
