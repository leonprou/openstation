---
kind: task
name: 0007-add-verifier-field
status: done
agent: author
created: 2026-02-22
---

# Add verifier field to task specs

## Requirements

- Add a `verifier` field to task frontmatter. Value is an agent name or `manual`. Default is `manual`.
- Add a `review` status between `in-progress` and `done`/`failed`. When an agent finishes work, it sets `status: review` instead of self-verifying.
- Only the designated verifier can approve a task as `done` or reject it as `failed`.
- Update `manual.md`:
  - Completing a Task: agent sets `status: review`, no longer self-verifies
  - Add a new "Verifying a Task" section describing the verification process for both agent and manual verifiers
- Update `CLAUDE.md`: document the `verifier` field and `review` status
- Update `skills/openstation.create.md`: add `verifier: manual` to the frontmatter template
- Update `skills/openstation.update.md`: add `review` to allowed statuses, add `verifier` to recognized fields
- Update `skills/openstation.list.md`: show `verifier` column, include `review` in status counts
- Existing done tasks do not need migration — absent `verifier` field is treated as legacy

## Verification

- [ ] `verifier` field present in create skill template with default `manual`
- [ ] `manual.md` has updated Completing a Task section (agent sets `review`, not `done`)
- [ ] `manual.md` has new Verifying a Task section
- [ ] `CLAUDE.md` documents `review` status and `verifier` field
- [ ] `skills/openstation.update.md` accepts `review` status and `verifier` field
- [ ] `skills/openstation.list.md` displays verifier column
