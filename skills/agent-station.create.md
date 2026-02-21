---
name: agent-station.create
description: Create a new task spec in tasks/. $ARGUMENTS is the task description. Use when user says "add task", "new task", "create task", or describes work to be done.
---

# Create Task

Generate a new task spec from a description.

## Input

`$ARGUMENTS` — the task description (free text).

## Procedure

1. Take the description from `$ARGUMENTS`.
2. Generate a kebab-case slug from the description (short,
   descriptive, no more than 5 words).
3. Determine the next task ID:
   - Scan `tasks/` for files matching the pattern `NNNN-*.md`
     (4-digit prefix).
   - Extract the highest numeric prefix, increment by 1, and
     zero-pad to 4 digits.
   - If no prefixed files exist, start at `0001`.
4. The filename becomes `<ID>-<slug>.md` and the `name` field
   matches `<ID>-<slug>`.
5. Create `tasks/<ID>-<slug>.md` with this structure:

   ```markdown
   ---
   kind: task
   name: <ID>-<slug>
   status: backlog
   agent:
   created: <today's date YYYY-MM-DD>
   ---

   # <Title from description>

   ## Requirements

   <Expand the description into concrete requirements>

   ## Verification

   - [ ] <Verification items derived from requirements>
   ```

6. Ask the user:
   - Should an agent be assigned? If yes, which one?
   - Should the status be changed from `backlog` to `ready`?
7. Update the frontmatter with their answers.
8. Confirm the file was created and show the path.
