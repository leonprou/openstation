---
description: Create a new task spec in tasks/. $ARGUMENTS is the task description.
---

# Create Task

Generate a new task spec from a description.

## Input

`$ARGUMENTS` — the task description (free text).

## Procedure

1. Take the description from `$ARGUMENTS`.
2. Generate a kebab-case filename from the description (short,
   descriptive, no more than 5 words).
3. Create `tasks/<name>.md` with this structure:

   ```markdown
   ---
   kind: task
   name: <name>
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

4. Ask the user:
   - Should an agent be assigned? If yes, which one?
   - Should the status be changed from `backlog` to `ready`?
5. Update the frontmatter with their answers.
6. Confirm the file was created and show the path.
