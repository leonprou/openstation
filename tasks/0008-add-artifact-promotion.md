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

| Agent field | Destination |
|-------------|-------------|
| `researcher` | `research/` |
| other agents (`author`, etc.) | `projects/` |
| no agent | `archived/` |

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
   after "Verifying a Task" with routing rules and instructions
   to run `/agent-station.promote` after verification.

4. **Update `CLAUDE.md`** — update Artifacts section to document
   the promotion flow. Add `archived/` to vault structure.

5. **Update `projects/manual.md`** — note that completed
   project-type tasks are promoted here.

6. **Create `archived/` directory** — new top-level directory for
   completed operational tasks.

7. **Update `skills/agent-station.execute.md`** — add `research/`,
   `projects/`, and `archived/` to the vault structure listing.

8. **Migrate existing done tasks**:
   - `0001-add-operator-commands` (no agent) → `archived/`
   - `0002-update-vault-structure` (no agent) → `archived/`
   - `0003-research-obsidian-plugin-api` + notes (researcher) → `research/`
   - `0004-research-spec-agent-role` + notes (researcher) → `research/`
   - `0005-research-spec-kit` + report (researcher) → `research/`
   - `0007-add-verifier-field` (author) → `projects/`

## Verification

- [ ] `/agent-station.promote` skill exists and symlink works
- [ ] Manual has "Promoting Completed Work" section with routing rules
- [ ] CLAUDE.md documents promotion flow and `archived/` in vault structure
- [ ] All 7 done tasks migrated to correct destinations
- [ ] `tasks/` contains only active tasks (0006, 0008)
- [ ] `research/` has 6 files (3 specs + 3 artifacts)
- [ ] `projects/` has `manual.md` + `add-verifier-field.md`
- [ ] `archived/` has 2 files
