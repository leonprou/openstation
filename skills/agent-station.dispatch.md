---
description: Dispatch an agent to execute its ready tasks. $ARGUMENTS = agent name.
---

# Dispatch Agent

Show agent details and instruct the user how to launch it.

## Input

`$ARGUMENTS` — the agent name.

## Procedure

1. Validate that `agents/<name>.md` exists. If not, report an error
   and list available agents from `agents/`.
2. Read and display the agent spec (name, description, model, skills).
3. Scan `tasks/` for tasks where `agent` matches this name AND
   `status` is `ready`. Display them in a short list.
4. If no ready tasks exist, report: "No ready tasks for agent
   <name>." and stop.
5. Instruct the user to launch the agent:

   ```
   claude --agent <name>
   ```
