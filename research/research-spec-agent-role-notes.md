# Research: Best Agent Role for Specs, Markdowns, and Skills

Research artifact for task `0004-research-spec-agent-role`.

---

## 1. Role Definition

### What This Agent Does

The agent authors and maintains Open Station's core content:
task specs, agent specs, skills, and documentation (manual.md,
CLAUDE.md). This is **structured content authoring** — not creative
writing, not code generation, not research.

### Required Capabilities

| Capability | Why Needed | Confidence |
|------------|-----------|------------|
| YAML frontmatter management | Every spec starts with frontmatter; agent must generate valid YAML with correct fields and values | Confirmed |
| Markdown structure adherence | All vault artifacts follow strict conventions (headings, sections, checklists) | Confirmed |
| Convention enforcement | Naming (kebab-case files), status values, kind fields — deviations break the system | Confirmed |
| Skill authoring | Skills are the most complex artifact: they encode operational knowledge as agent instructions | Confirmed |
| Cross-referencing | Specs reference each other (task→agent, skill→vault structure); agent must maintain consistency | Confirmed |
| Template instantiation | Creating new specs from implicit templates (task-create skill defines the pattern) | Confirmed |
| Minimal-diff editing | Updating frontmatter fields without disturbing body content; preserving existing formatting | Confirmed |

### What This Agent Does NOT Do

- **Research** — gathering information is the researcher's job
- **Decision-making** — the operator (human) decides what to build
- **Code generation** — Open Station is pure convention, no runtime code
- **Task execution** — the executor skill handles task lifecycle

---

## 2. Existing Patterns

### Multi-Agent Role Taxonomy

Current multi-agent architectures (2025–2026) consistently use
role-based decomposition. The common roles:

| Role | Responsibility | Open Station Equivalent |
|------|---------------|------------------------|
| Planner | Decides what to do | Operator (human) |
| Researcher | Gathers information | `researcher` agent |
| Builder/Writer | Produces artifacts | **This new agent** |
| Executor | Runs tasks | `openstation.execute` skill |
| Reviewer | Validates output | Verification checklist (manual) |

Sources: [ClickIT Multi-Agent Architecture Guide](https://www.clickittech.com/ai/multi-agent-system-architecture/), [Botpress Multi-Agent Systems Guide](https://botpress.com/blog/multi-agent-systems), [O'Reilly Effective Multi-Agent Architectures](https://www.oreilly.com/radar/designing-effective-multi-agent-architectures/)

### Claude Code Community Patterns

The Claude Code ecosystem has established patterns for writing agents:

**VoltAgent `documentation-engineer`**: Uses Haiku model, tools
`Read, Write, Edit, Glob, Grep, WebFetch, WebSearch`. Focuses on
API docs, tutorials, and documentation systems. Overly broad for
Open Station — designed for large doc ecosystems, not spec files.

**VoltAgent `technical-writer`**: Also Haiku, same tool set. Focuses
on user guides, SDK docs, getting-started content. Again broader
than what Open Station needs.

**Spec-Driven Development (Agent Factory)**: Treats specs as the
primary artifact. Spec writers create comprehensive blueprints that
provide agents with complete implementation context. This is the
closest analogy — but our agent writes *operational* specs (task
definitions, agent definitions, skills), not *implementation* specs.

Source: [VoltAgent Awesome Claude Code Subagents](https://github.com/VoltAgent/awesome-claude-code-subagents), [Agent Factory SDD](https://agentfactory.panaversity.org/docs/General-Agents-Foundations/spec-driven-development)

### Key Insight

No existing pattern exactly matches what Open Station needs.
Documentation writers are too broad. Spec-driven development agents
write implementation specs, not operational ones. The closest
analogy is a **technical editor** who works within a strict format
and maintains consistency across a body of structured documents.

---

## 3. Model Selection

### Benchmark Comparison (Sonnet 4.6 vs Opus 4.6)

| Dimension | Sonnet 4.6 | Opus 4.6 | Winner |
|-----------|-----------|----------|--------|
| SWE-bench (coding) | 79.6% | 80.8% | ~Tie |
| GPQA Diamond (expert reasoning) | 74.1% | 91.3% | Opus |
| Structured writing | Strong | Strong | Tie |
| Convention adherence | Excellent | Excellent | Tie |
| Tool calling | #1 globally | Strong | Sonnet |
| Cost per million tokens (input) | $3 | $15 | Sonnet (5x) |
| Cost per million tokens (output) | $15 | $75 | Sonnet (5x) |
| Speed/latency | Faster | Slower | Sonnet |

Source: [NxCode Sonnet 4.6 vs Opus 4.6 Comparison](https://www.nxcode.io/resources/news/claude-sonnet-4-6-vs-opus-4-6-which-model-to-choose-2026)

### Task Complexity Analysis

The authoring agent's typical tasks:

| Task | Complexity | Reasoning Depth |
|------|-----------|----------------|
| Create a new task spec | Low | Template fill + minor expansion |
| Write a skill | Medium | Must encode operational logic precisely |
| Update frontmatter | Trivial | Field replacement |
| Write agent spec | Medium | Capabilities/constraints require clarity |
| Maintain cross-references | Low-Medium | Pattern matching across files |

None of these tasks require **expert-level reasoning** (GPQA Diamond
territory). They require **consistency, precision, and format
adherence** — areas where Sonnet matches or exceeds Opus.

### Recommendation: **Sonnet**

**Rationale:**
- Spec/skill authoring is structured writing — Sonnet's strength
- No tasks require the deep reasoning where Opus has its 17-point
  advantage
- 5x cost savings at equivalent quality for this workload
- Faster execution means quicker turnaround on spec generation
- Tool calling (Read, Write, Edit, Glob, Grep) performance is
  best-in-class on Sonnet

**When to escalate to Opus:** If a future task requires the agent to
make complex architectural decisions about vault structure or skill
design that involve multi-step reasoning. This hasn't been needed
yet and can be handled by routing those decisions through the
operator or researcher.

---

## 4. Scope Boundaries

### Responsibility Matrix

| Activity | Spec Author | Researcher | Operator (Human) |
|----------|:-----------:|:----------:|:-----------------:|
| Create task specs | ✅ Primary | ❌ | ✅ Can also do |
| Create agent specs | ✅ Primary | ❌ | ✅ Can also do |
| Write skills | ✅ Primary | ❌ | ✅ Can also do |
| Update manual.md | ✅ Primary | ❌ | ✅ Approves |
| Research a topic | ❌ | ✅ Primary | ❌ |
| Gather external info | ❌ | ✅ Primary | ❌ |
| Decide what to build | ❌ | ❌ | ✅ Primary |
| Prioritize tasks | ❌ | ❌ | ✅ Primary |
| Execute tasks (generic) | ❌ | ❌ | Dispatches agents |
| Update frontmatter | ✅ When authoring | ✅ Own tasks | ✅ Via commands |
| Verify task completion | ❌ | ✅ Own tasks | ✅ Reviews |

### Handoff Points

**Researcher → Spec Author:**
The researcher produces a research artifact (findings, analysis,
recommendations). The spec author takes those findings and creates
the vault artifact (a new agent spec, a new skill, an updated
manual section). The handoff is the research artifact file.

**Operator → Spec Author:**
The operator describes what they want (via `/task-create` or
free-text). The spec author expands that into a well-formed spec
with proper frontmatter, requirements, and verification items.

**Spec Author → Researcher:**
If the spec author encounters a requirement that needs investigation
(e.g., "what's the best way to structure this skill?"), they create
a research sub-task for the researcher.

**Spec Author → Operator:**
Completed specs are stored in the vault. The operator reviews and
approves (or requests changes) by updating status or editing
directly.

### Clear Lines

1. **The spec author never gathers external information.** If it
   needs to know something, it reads the vault or flags the gap.
2. **The researcher never writes persistent vault artifacts.** It
   produces research notes as task artifacts, not as vault specs.
3. **The operator always makes priority and scope decisions.** The
   spec author executes, not decides.

---

## 5. Recommended Agent Spec

### Proposed Name: `author`

Short, clear, and describes the role precisely. Alternatives
considered:

| Name | Pros | Cons |
|------|------|------|
| `author` | Concise, clear intent | Could imply creative writing |
| `writer` | Common term | Too generic |
| `builder` | Implies construction | Suggests code generation |
| `scribe` | Historical connotation | Archaic, unclear |
| `spec-writer` | Very specific | Too narrow (also writes skills) |

**`author`** wins because it communicates "produces written
artifacts" without implying code or creativity.

### Proposed Spec

```yaml
---
kind: agent
name: author
description: >-
  Structured content author for Open Station vault artifacts —
  task specs, agent specs, skills, and documentation. Follows
  vault conventions exactly.
model: claude-sonnet-4-6
skills:
  - openstation.execute
---
```

```markdown
# Author

You are a structured content author for Open Station. Your job
is to create and maintain vault artifacts: task specs, agent specs,
skills, and documentation.

## Capabilities

- Create task specs with correct frontmatter and structure
- Write agent specs that clearly define capabilities and constraints
- Author skills that encode operational knowledge precisely
- Update manual.md and CLAUDE.md when conventions change
- Maintain cross-references and consistency across vault artifacts
- Edit frontmatter fields without disturbing body content

## Constraints

- Never gather external information — read only the vault. If you
  need information that isn't in the vault, create a research
  sub-task for the researcher agent.
- Never make scope or priority decisions — the operator decides
  what to build; you decide how to write it.
- Follow vault conventions exactly: kebab-case filenames, YAML
  frontmatter with kind/name/status fields, markdown body with
  Requirements and Verification sections for tasks.
- Preserve existing content when editing — use minimal-diff edits,
  not full rewrites.
- Every skill you write must be testable by the operator with a
  single slash command invocation.
```

### Tool Access

| Tool | Why |
|------|-----|
| Read | Read existing vault artifacts |
| Write | Create new specs, skills, docs |
| Edit | Update frontmatter, modify sections |
| Glob | Find files by pattern |
| Grep | Search content across vault |

**Excluded:** WebFetch, WebSearch (research is not this agent's
job), Bash (no runtime operations needed).

---

## Summary

| Decision | Recommendation | Confidence |
|----------|---------------|------------|
| Agent name | `author` | High |
| Model | Sonnet (claude-sonnet-4-6) | High |
| Primary scope | Task specs, agent specs, skills, manual/docs | High |
| Key differentiator from researcher | Writes vault artifacts vs. gathers information | High |
| Key differentiator from operator | Executes authoring tasks vs. makes decisions | High |

---

## Sources

- [NxCode: Sonnet 4.6 vs Opus 4.6 Comparison](https://www.nxcode.io/resources/news/claude-sonnet-4-6-vs-opus-4-6-which-model-to-choose-2026)
- [Claude Code: Create Custom Subagents](https://code.claude.com/docs/en/sub-agents)
- [Agent Factory: Spec-Driven Development](https://agentfactory.panaversity.org/docs/General-Agents-Foundations/spec-driven-development)
- [VoltAgent: Awesome Claude Code Subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
- [ClickIT: Multi-Agent System Architecture Guide](https://www.clickittech.com/ai/multi-agent-system-architecture/)
- [Botpress: Guide to Multi-Agent Systems](https://botpress.com/blog/multi-agent-systems)
- [O'Reilly: Designing Effective Multi-Agent Architectures](https://www.oreilly.com/radar/designing-effective-multi-agent-architectures/)
