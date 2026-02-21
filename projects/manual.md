# Projects Manual

A **project** is a collection of related artifacts grouped under a
single directory in `projects/`.

## Creating a Project

1. Create a subdirectory in `projects/` using a descriptive
   kebab-case name (e.g., `projects/obsidian-plugin/`).
2. Add artifacts as markdown files inside the project directory.
3. Optionally add a `README.md` at the project root to summarize
   scope and status.

## Project Structure

```
projects/<project-name>/
├── README.md           # (optional) project overview
├── spec.md             # specifications, requirements
├── research.md         # project-specific research
├── notes.md            # working notes, decisions
└── ...                 # any other relevant artifacts
```

All files are markdown with enough context to be useful standalone.

## Naming Conventions

- **Project directories**: kebab-case, descriptive
  (e.g., `obsidian-plugin`, `task-board-ui`)
- **Artifact files**: kebab-case, describe the content
  (e.g., `api-research.md`, `architecture-decisions.md`)

## When to Use Projects vs Research

- **Projects**: Artifacts tied to a specific initiative, feature,
  or deliverable. Group them here.
- **Research** (`research/`): General-purpose research artifacts
  not tied to any single project.
