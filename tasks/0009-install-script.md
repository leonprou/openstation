---
kind: task
name: 0009-install-script
status: review
agent: author
owner: manual
created: 2026-02-22
---

# Install Script for Bootstrapping Agent Station

## Requirements

Create `install.sh` at repo root — a bash script that bootstraps
Agent Station into any existing project. Runnable via `curl | bash`
from the (future) open source GitHub repo.

### Script behavior

1. **Parse arguments**: `--no-agents`, `--local PATH`, `--help`
2. **Check prerequisites**: verify curl exists, warn if not in git repo
3. **Create directories**: `tasks/`, `agents/`, `skills/`, `specs/`,
   `research/`, `archive/tasks/`, `.claude/commands/` — with `.gitkeep`
   in content dirs
4. **Download skills** (6 files → `skills/`):
   - agent-station.create.md
   - agent-station.dispatch.md
   - agent-station.done.md
   - agent-station.execute.md
   - agent-station.list.md
   - agent-station.update.md
5. **Download manual.md** → project root
6. **Download example agents** (unless `--no-agents`):
   - researcher.md → `agents/`
   - author.md → `agents/`
7. **Create symlinks**:
   - `.claude/commands/agent-station.*.md` → `../../skills/agent-station.*.md`
   - `.claude/agents` → `../agents` (directory symlink)
8. **Update CLAUDE.md**: inject Agent Station section between
   `<!-- agent-station:start -->` / `<!-- agent-station:end -->` markers.
   Create if missing, append if no markers, replace if markers exist.
9. **Print summary** with next steps

### Idempotency rules

- Directories: create or skip
- Skills + manual.md: always overwrite (AS-owned)
- Agent specs: skip if exist (user-customizable)
- Symlinks: re-create to ensure correct target
- CLAUDE.md: managed section between markers

### Additional work

- Fix `.claude/agents/` in this repo to be a symlink to `../agents/`
  (currently a regular directory with file copies)
- Use `REPO_OWNER` constant at top of script (TBD — repo will be
  open sourced)

## Verification

- [ ] `install.sh --local .` in a temp dir creates all dirs, files, symlinks
- [ ] Running it again is idempotent (no errors, skills updated, agents skipped)
- [ ] `--no-agents` leaves `agents/` empty (just .gitkeep)
- [ ] CLAUDE.md gets Agent Station section with markers
- [ ] `.claude/agents/researcher.md` resolves through the symlink
- [ ] `.claude/commands/agent-station.create.md` symlink resolves to skill
- [ ] `--help` prints usage
