---
kind: task
name: 0004-research-spec-agent-role
status: done
agent: researcher
created: 2026-02-21
---

# Research Best Agent Role for Specs, Markdowns, and Skills Development

## Requirements

Investigate what kind of agent is best suited for authoring and
maintaining Agent Station's core content — specifications, markdown
documentation, and skills. The research should cover:

- **Role definition**: What capabilities does this agent need?
  (structured writing, convention adherence, frontmatter management,
  skill authoring, cross-referencing between vault artifacts)
- **Existing patterns**: How do other multi-agent systems define
  "builder" or "author" roles? What works, what doesn't?
- **Model selection**: Should this agent use Sonnet (fast, cheaper)
  or Opus (deeper reasoning)? Consider the complexity of typical
  tasks — writing skills requires precision, specs require structure.
- **Scope boundaries**: Where does this agent's responsibility end
  and the researcher's or operator's begin? Define clear handoff
  points.
- **Recommended spec**: Propose a concrete agent spec (name,
  description, capabilities, constraints) ready to be placed in
  `agents/`.

## Verification

- [ ] Research covers all five areas listed above
- [ ] Findings include evidence or reasoning, not just opinions
- [ ] A concrete agent spec is proposed with name, description,
      capabilities, and constraints
- [ ] Model recommendation is justified with trade-off analysis
- [ ] Scope boundaries with existing agents are clearly defined
