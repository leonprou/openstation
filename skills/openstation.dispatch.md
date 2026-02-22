---
name: openstation.dispatch
description: Preview agent details and show launch instructions for executing ready tasks. $ARGUMENTS = agent name. Use when user says "run agent", "start agent", "dispatch agent", or wants to launch an agent on its tasks.
---

# Dispatch Agent

Show agent details and instruct the user how to launch it.

## Input

`$ARGUMENTS` — the agent name.

## Procedure

1. Validate that `.openstation/agents/<name>.md` exists. If not, report an error
   and list available agents from `.openstation/agents/`.
2. Read and display the agent spec (name, description, model, skills).
3. Scan `.openstation/tasks/` for tasks where `agent` matches this name AND
   `status` is `ready`. Display them in a short list.
4. If no ready tasks exist, report: "No ready tasks for agent
   <name>." and stop.
5. Instruct the user to launch the agent:

   ```
   claude --agent <name>
   ```
