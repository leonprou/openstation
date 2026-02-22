---
kind: task
name: 0005-research-spec-kit
status: done
agent: researcher
created: 2026-02-21
---

# Research GitHub Spec-Kit

## Requirements

Research GitHub's Spec-Kit (https://github.com/github/spec-kit) to
understand what Agent Station can learn from it. Cover:

1. **Architecture deep-dive**: How does Spec-Kit structure its specs,
   plans, tasks, and constitution? File format, frontmatter schema,
   directory layout.

2. **Slash command system**: How do they abstract slash commands
   across 18+ agents? Adapter pattern details.

3. **Workflow stages**: Constitution -> Specify -> Plan -> Tasks ->
   Implement. What happens at each stage? How are transitions
   managed?

4. **Multi-agent abstraction**: How do they support Claude Code,
   Cursor, Copilot, Gemini, etc. from the same spec files?

5. **Task generation and dependency management**: How are specs
   broken into tasks? Do tasks have dependencies?

6. **What Agent Station should adopt**: Concrete recommendations
   for patterns that work without runtime dependencies.

7. **What Agent Station should NOT adopt**: Things that don't fit
   Agent Station's zero-dependency philosophy.

## Verification

- [x] Report covers all 7 research goals
- [x] Findings are based on actual source file analysis, not just README
- [x] Recommendations distinguish adopt vs avoid with reasoning
- [x] Report includes specific file paths and code examples from Spec-Kit
