---
kind: task
name: 0002-update-vault-structure
status: done
agent:
created: 2026-02-21
---

# Update Vault Structure

## Requirements

Restructure the Open Station vault to better organize artifacts:

### 1. Remove `knowledge/` folder

- Delete the `knowledge/` directory if it exists.
- Migrate any existing content to the appropriate new location
  (`projects/` or `research/`).

### 2. Add `projects/` folder

- Create a top-level `projects/` directory.
- Each project lives in its own subdirectory:
  `projects/<project-name>/`.
- Project subdirectories contain all artifacts related to that
  project (specs, research, notes, etc.).
- Add a `projects/manual.md` that explains:
  - What a project is and how to create one
  - Expected structure of a project subdirectory
  - Naming conventions

### 3. Add `research/` folder

- Create a top-level `research/` directory.
- This folder holds general research artifacts that are not tied
  to a specific project.
- Research files follow the same markdown conventions as other
  vault artifacts.

### 4. Update documentation

- Update `CLAUDE.md` vault structure section to reflect the new
  directories.
- Update `manual.md` if it references the old structure.

## Verification

- [ ] `knowledge/` folder does not exist (or was already absent)
- [ ] `projects/` directory exists at vault root
- [ ] `projects/manual.md` exists and explains project structure
- [ ] `research/` directory exists at vault root
- [ ] `CLAUDE.md` vault structure section lists `projects/` and `research/`
- [ ] No broken references to removed directories
