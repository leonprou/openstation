#!/usr/bin/env bash
set -euo pipefail

# --- Constants -----------------------------------------------------------

REPO_OWNER="leonprou"
REPO_NAME="openstation"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

COMMANDS=(
  openstation.create.md
  openstation.dispatch.md
  openstation.done.md
  openstation.list.md
  openstation.ready.md
  openstation.reject.md
  openstation.show.md
  openstation.update.md
)

SKILLS=(
  openstation-execute
)

AGENTS=(
  researcher.md
  author.md
)

MARKER_START="<!-- openstation:start -->"
MARKER_END="<!-- openstation:end -->"

# --- Helpers -------------------------------------------------------------

info()  { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
skip()  { printf '  \033[1;33m⊘\033[0m %s (exists, skipped)\n' "$1"; }
warn()  { printf '  \033[1;33m!\033[0m %s\n' "$1"; }
err()   { printf '  \033[1;31m✗\033[0m %s\n' "$1" >&2; }

usage() {
  cat <<'USAGE'
Usage: install.sh [OPTIONS]

Bootstrap Open Station into the current project.

Options:
  --local PATH   Copy files from a local clone instead of downloading
  --no-agents    Skip installing example agent specs
  --help         Show this help message

Examples:
  curl -fsSL https://raw.githubusercontent.com/leonprou/openstation/main/install.sh | bash
  ./install.sh --local /path/to/openstation
  ./install.sh --no-agents
USAGE
  exit 0
}

fetch_file() {
  local src="$1" dst="$2"
  if [[ -n "${LOCAL_PATH:-}" ]]; then
    cp "$LOCAL_PATH/$src" "$dst"
  else
    curl -fsSL "$BASE_URL/$src" -o "$dst"
  fi
}

ensure_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    return
  fi
  mkdir -p "$dir"
  info "Created $dir/"
}

ensure_gitkeep() {
  local dir="$1"
  if [[ ! -f "$dir/.gitkeep" ]]; then
    touch "$dir/.gitkeep"
  fi
}

# --- Parse arguments -----------------------------------------------------

LOCAL_PATH=""
INSTALL_AGENTS=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      LOCAL_PATH="$2"
      shift 2
      ;;
    --no-agents)
      INSTALL_AGENTS=false
      shift
      ;;
    --help|-h)
      usage
      ;;
    *)
      err "Unknown option: $1"
      usage
      ;;
  esac
done

# --- Prerequisites -------------------------------------------------------

printf '\n\033[1mOpen Station Installer\033[0m\n\n'

# Check curl (only needed when not using --local)
if [[ -z "$LOCAL_PATH" ]]; then
  if ! command -v curl &>/dev/null; then
    err "curl is required but not found. Install it or use --local."
    exit 1
  fi
fi

# Check local path exists
if [[ -n "$LOCAL_PATH" ]]; then
  if [[ ! -d "$LOCAL_PATH" ]]; then
    err "Local path does not exist: $LOCAL_PATH"
    exit 1
  fi
  if [[ ! -f "$LOCAL_PATH/docs/lifecycle.md" ]]; then
    err "Local path does not look like an Open Station repo: $LOCAL_PATH"
    exit 1
  fi
  # Normalize to absolute path for reliable copies
  LOCAL_PATH="$(cd "$LOCAL_PATH" && pwd)"
fi

# Warn if not in a git repo
if ! git rev-parse --git-dir &>/dev/null 2>&1; then
  warn "Not inside a git repository. Proceeding anyway."
fi

# --- Create directories --------------------------------------------------

printf 'Creating directories...\n'

DIRS=(
  .openstation/docs
  .openstation/tasks/backlog
  .openstation/tasks/current
  .openstation/tasks/done
  .openstation/artifacts/tasks
  .openstation/artifacts/agents
  .openstation/artifacts/research
  .openstation/artifacts/specs
  .openstation/agents
  .openstation/skills
  .openstation/commands
  .claude
)
for dir in "${DIRS[@]}"; do
  ensure_dir "$dir"
done

# Add .gitkeep to content directories
CONTENT_DIRS=(
  .openstation/tasks/backlog
  .openstation/tasks/current
  .openstation/tasks/done
  .openstation/artifacts/tasks
  .openstation/artifacts/agents
  .openstation/artifacts/research
  .openstation/artifacts/specs
  .openstation/agents
  .openstation/skills
  .openstation/commands
)
for dir in "${CONTENT_DIRS[@]}"; do
  ensure_gitkeep "$dir"
done

# --- Download commands (always overwrite — AS-owned) ----------------------

printf 'Installing commands...\n'

for cmd in "${COMMANDS[@]}"; do
  fetch_file "commands/$cmd" ".openstation/commands/$cmd"
  info ".openstation/commands/$cmd"
done

# --- Download skills (always overwrite — AS-owned) ------------------------

printf 'Installing skills...\n'

for skill in "${SKILLS[@]}"; do
  ensure_dir ".openstation/skills/$skill"
  fetch_file "skills/$skill/SKILL.md" ".openstation/skills/$skill/SKILL.md"
  info ".openstation/skills/$skill/SKILL.md"
done

# --- Download docs (always overwrite — AS-owned) --------------------------

printf 'Installing docs...\n'

fetch_file "docs/lifecycle.md" ".openstation/docs/lifecycle.md"
info ".openstation/docs/lifecycle.md"

fetch_file "docs/task.spec.md" ".openstation/docs/task.spec.md"
info ".openstation/docs/task.spec.md"

# --- Download example agents (skip if exist) -----------------------------

if [[ "$INSTALL_AGENTS" == true ]]; then
  printf 'Installing example agents...\n'

  for agent in "${AGENTS[@]}"; do
    if [[ -f ".openstation/artifacts/agents/$agent" ]]; then
      skip ".openstation/artifacts/agents/$agent"
    else
      fetch_file "artifacts/agents/$agent" ".openstation/artifacts/agents/$agent"
      info ".openstation/artifacts/agents/$agent"
    fi
    # Create discovery symlink in agents/
    link=".openstation/agents/$agent"
    target="../artifacts/agents/$agent"
    if [[ -L "$link" ]]; then
      rm "$link"
    elif [[ -f "$link" ]]; then
      rm "$link"
    fi
    ln -s "$target" "$link"
    info "$link → $target"
  done
else
  printf 'Skipping agent specs (--no-agents)\n'
fi

# --- Create symlinks (re-create to ensure correct target) ----------------

printf 'Creating symlinks...\n'

# .claude/commands → ../.openstation/commands directory symlink
if [[ -L ".claude/commands" ]]; then
  rm ".claude/commands"
elif [[ -d ".claude/commands" ]]; then
  # Preserve any non-openstation commands
  if [[ -n "$(ls -A .claude/commands/ 2>/dev/null)" ]]; then
    warn ".claude/commands/ exists with files — merging openstation commands"
    for cmd in "${COMMANDS[@]}"; do
      target="../../.openstation/commands/$cmd"
      link=".claude/commands/$cmd"
      rm -f "$link"
      ln -s "$target" "$link"
      info "$link → $target"
    done
  else
    rm -rf ".claude/commands"
    ln -s "../.openstation/commands" ".claude/commands"
    info ".claude/commands → ../.openstation/commands"
  fi
fi
if [[ ! -e ".claude/commands" ]]; then
  ln -s "../.openstation/commands" ".claude/commands"
  info ".claude/commands → ../.openstation/commands"
fi

# .claude/agents → ../.openstation/agents directory symlink
if [[ -L ".claude/agents" ]]; then
  rm ".claude/agents"
elif [[ -d ".claude/agents" ]]; then
  rm -rf ".claude/agents"
fi
ln -s "../.openstation/agents" ".claude/agents"
info ".claude/agents → ../.openstation/agents"

# .claude/skills → ../.openstation/skills directory symlink
if [[ -L ".claude/skills" ]]; then
  rm ".claude/skills"
elif [[ -d ".claude/skills" ]]; then
  # Preserve any non-openstation skills
  if [[ -n "$(ls -A .claude/skills/ 2>/dev/null)" ]]; then
    warn ".claude/skills/ exists with files — merging openstation skills"
    for skill in "${SKILLS[@]}"; do
      target="../../.openstation/skills/$skill"
      link=".claude/skills/$skill"
      rm -rf "$link"
      ln -s "$target" "$link"
      info "$link → $target"
    done
  else
    rm -rf ".claude/skills"
    ln -s "../.openstation/skills" ".claude/skills"
    info ".claude/skills → ../.openstation/skills"
  fi
fi
if [[ ! -e ".claude/skills" ]]; then
  ln -s "../.openstation/skills" ".claude/skills"
  info ".claude/skills → ../.openstation/skills"
fi

# --- Update CLAUDE.md ----------------------------------------------------

printf 'Updating CLAUDE.md...\n'

# Write managed section to a temp file
section_file=$(mktemp)
cat > "$section_file" <<'SECTION'
<!-- openstation:start -->
# Open Station

Task management system for coding AI agents. Pure convention —
markdown specs + skills, zero runtime dependencies.

## Vault Structure

```
.openstation/
├── docs/              — Project documentation (lifecycle, task spec)
├── tasks/             — Lifecycle buckets (contain symlinks)
│   ├── backlog/       —   Not yet ready for agents
│   ├── current/       —   Active work (ready → in-progress → review)
│   └── done/          —   Completed tasks
├── artifacts/         — Canonical artifact storage (source of truth)
│   ├── tasks/         —   Task folders (canonical location, never move)
│   ├── agents/        —   Agent specs (canonical location)
│   ├── research/      —   Research outputs
│   └── specs/         —   Specifications & designs
├── agents/            — Agent discovery (symlinks → artifacts/agents/)
├── skills/            — Agent skills (not user-invocable)
└── commands/          — User-invocable slash commands
```

## Quick Start

Create a task:  `/openstation.create <description>`
List tasks:     `/openstation.list`
Update a task:  `/openstation.update <name> field:value`
Run an agent:   `claude --agent <name>`
Complete task:  `/openstation.done <name>`

See `.openstation/docs/lifecycle.md` for lifecycle rules and
`.openstation/docs/task.spec.md` for task format.
<!-- openstation:end -->
SECTION

if [[ ! -f "CLAUDE.md" ]]; then
  # Create new CLAUDE.md
  cp "$section_file" "CLAUDE.md"
  info "Created CLAUDE.md with Open Station section"
elif grep -q "$MARKER_START" "CLAUDE.md"; then
  # Replace existing managed section
  awk -v sfile="$section_file" '
    BEGIN { printing=1 }
    /<!-- openstation:start -->/ {
      while ((getline line < sfile) > 0) print line
      printing=0
      next
    }
    /<!-- openstation:end -->/ { printing=1; next }
    printing { print }
  ' "CLAUDE.md" > "CLAUDE.md.tmp"
  mv "CLAUDE.md.tmp" "CLAUDE.md"
  info "Updated Open Station section in CLAUDE.md"
else
  # Append to existing CLAUDE.md
  printf '\n' >> "CLAUDE.md"
  cat "$section_file" >> "CLAUDE.md"
  info "Appended Open Station section to CLAUDE.md"
fi

rm -f "$section_file"

# --- Summary -------------------------------------------------------------

printf '\n\033[1;32mOpen Station installed successfully!\033[0m\n\n'
printf 'Next steps:\n'
printf '  1. Review CLAUDE.md and .openstation/docs/lifecycle.md\n'
printf '  2. Customize agent specs in .openstation/agents/\n'
printf '  3. Create your first task: /openstation.create <description>\n'
printf '  4. Run an agent: claude --agent <name>\n\n'
