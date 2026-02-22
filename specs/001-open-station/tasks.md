# Tasks: Open Station

**Input**: Design documents from `specs/001-open-station/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks grouped by user story for independent implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the vault directory structure and symlinks for
Claude Code discovery.

- [x] T001 Create vault directories: `tasks/`, `agents/`, `skills/` with `.gitkeep` files
- [x] T002 [P] Create symlink `.claude/agents/` → `agents/` for Claude Code agent discovery (per research R1)
- [x] T003 [P] Create individual symlink `.claude/commands/openstation-executor.md` → `skills/openstation-executor.md` for skill discovery. Note: directory-level symlink deferred — speckit commands coexist in `.claude/commands/`

**Checkpoint**: Vault directories exist, symlinks resolve correctly.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the manual and executor skill — agents cannot
operate without these.

**CRITICAL**: No user story work can begin until this phase is complete.

- [x] T004 [P] Write `manual.md` at vault root describing the work process: task discovery, execution steps, artifact storage conventions, sub-task creation, and completion/verification handling (per data-model.md Manual sections and FR-007)
- [x] T005 [P] Write executor skill in `skills/openstation-executor.md` with Claude Code command frontmatter (`description` field). Skill body must cover: startup sequence, task discovery (`status: ready` + agent match), manual loading, status updates, artifact storage alongside tasks, verification, and completion handling (per FR-004, data-model.md Skill schema, research R3)

**Checkpoint**: Manual and executor skill exist. An agent loading the skill would have full operational instructions.

---

## Phase 3: User Story 1 — Create a Task for Agent Execution (Priority: P1)

**Goal**: An operator can create a well-formed task file that an agent
can discover and parse.

**Independent Test**: Create a task file with valid frontmatter. Verify
it has all required fields (`kind: task`, `name`, `status`, `agent`,
`created`) and body sections (Requirements, Verification).

### Implementation for User Story 1

- [x] T006 [US1] Write sample task spec in `tasks/research-obsidian-plugin-api.md` with frontmatter per data-model.md Task schema (`kind: task`, `name: research-obsidian-plugin-api`, `status: ready`, `agent: researcher`, `created: 2026-02-21`) and Requirements + Verification body sections

**Checkpoint**: A valid task file exists in `tasks/`. Frontmatter parses correctly. All required fields present.

---

## Phase 4: User Story 2 — Dispatch an Agent to Execute a Task (Priority: P2)

**Goal**: An operator launches `claude --agent researcher` and the
agent finds its ready task, follows the manual, and executes.

**Independent Test**: Launch the researcher agent. Verify it discovers
the ready task, sets `status: in-progress`, follows the manual work
process, produces artifacts alongside the task, runs verification,
and sets final status.

### Implementation for User Story 2

- [x] T007 [US2] Write researcher agent spec in `agents/researcher.md` with merged frontmatter per data-model.md Agent schema and research R2 (`kind: agent`, `name: researcher`, `description`, `model: claude-sonnet-4-6`, `skills: [openstation-executor]`). Body: identity, capabilities, constraints — no Open Station-specific instructions (Principle II)
- [x] T008 [US2] End-to-end validation: verify all references resolve — task `agent: researcher` → `agents/researcher.md` exists, agent `skills: [openstation-executor]` → `skills/openstation-executor.md` exists, `.claude/agents/researcher.md` resolves via symlink, `.claude/commands/openstation-executor.md` resolves via symlink

**Checkpoint**: `claude --agent researcher` can be launched. The agent discovers the sample task and has full operational instructions from the executor skill and manual.

---

## Phase 5: User Story 3 — Browse the Vault in Obsidian (Priority: P3)

**Goal**: An operator opens the vault and understands the full system
state without tooling.

**Independent Test**: Open the vault directory. Verify the structure is
self-explanatory, statuses are visible in frontmatter, and all files
are human-readable.

### Implementation for User Story 3

- [x] T009 [US3] Write project `CLAUDE.md` at vault root with: vault structure overview, spec format description (kind field, frontmatter + markdown), task creation instructions, dispatch command (`claude --agent <name>`), task status lifecycle, and artifact conventions. Must align with constitution and corrected dispatch from research R4

**Checkpoint**: Any operator browsing the vault can understand the system in under 5 minutes (SC-005). Directory structure and CLAUDE.md together explain the full system.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup.

- [x] T010 Validate all spec filenames use kebab-case (FR-010)
- [x] T011 Validate no Open Station-specific instructions in agent body (Principle II)
- [x] T012 Validate constitution compliance: re-run Constitution Check from plan.md against delivered files
- [x] T013 Run quickstart.md walkthrough: verify the documented steps match the actual vault state

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup (needs `skills/` directory for T005)
- **US1 (Phase 3)**: Depends on Setup (needs `tasks/` directory)
- **US2 (Phase 4)**: Depends on Foundational (agent needs executor skill) + US1 (needs a task to validate against)
- **US3 (Phase 5)**: Depends on US1 + US2 (CLAUDE.md documents a populated vault)
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (P1)**: Can start after Setup (Phase 1) — needs only the `tasks/` directory
- **US2 (P2)**: Depends on Foundational + US1 — needs executor skill, manual, and a task to validate dispatch
- **US3 (P3)**: Depends on US1 + US2 — CLAUDE.md documents the full system which must exist first

### Parallel Opportunities

- T002 and T003 can run in parallel (different symlinks)
- T004 and T005 can run in parallel (different files: manual.md vs skills/openstation-executor.md)
- T006 (US1) can start in parallel with T004/T005 if Setup is complete (only needs `tasks/` directory)

---

## Parallel Example: Foundational Phase

```
# These two tasks can be written simultaneously:
Task T004: "Write manual.md at vault root"
Task T005: "Write executor skill in skills/openstation-executor.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T005)
3. Complete Phase 3: User Story 1 (T006)
4. **STOP and VALIDATE**: Verify the task file parses and has valid schema

### Incremental Delivery

1. Setup + Foundational → vault structure ready
2. Add US1 (sample task) → validate task format
3. Add US2 (agent + dispatch) → validate end-to-end loop
4. Add US3 (CLAUDE.md) → validate human inspectability
5. Polish → final validation pass

---

## Notes

- This is a convention system — all tasks produce markdown files, not code
- No test tasks included (not requested in spec)
- Commit after each task or logical group
- The symlink in T003 may require migrating existing speckit commands — handle as part of that task
- Avoid: vague descriptions, cross-story dependencies that break independence
