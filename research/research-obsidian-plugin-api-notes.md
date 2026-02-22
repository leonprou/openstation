# Obsidian Plugin API — Research Notes

Research for task `0003-research-obsidian-plugin-api`. Covers three focus
areas: file I/O, custom views, and file change events.

---

## 1. Reading and Writing Vault Files

The `Vault` class (`app.vault`) provides full file system operations
over the vault.

### Read Operations

| Method | Signature | Description |
|--------|-----------|-------------|
| `read` | `(file: TFile): Promise<string>` | Read file as text |
| `readBinary` | `(file: TFile): Promise<ArrayBuffer>` | Read as binary |
| `getMarkdownFiles` | `(): TFile[]` | List all markdown files |
| `getAllLoadedFiles` | `(): TAbstractFile[]` | List all files/folders |
| `getAbstractFileByPath` | `(path: string): TAbstractFile \| null` | Lookup by path |

### Write Operations

| Method | Signature | Description |
|--------|-----------|-------------|
| `create` | `(path: string, data: string): Promise<TFile>` | Create new file |
| `modify` | `(file: TFile, data: string): Promise<void>` | Overwrite contents |
| `append` | `(file: TFile, data: string): Promise<void>` | Append to file |
| `write` | `(file: TFile, data: string): Promise<void>` | Write content |
| `rename` | `(file: TAbstractFile, newPath: string): Promise<void>` | Rename/move |
| `delete` | `(file: TAbstractFile, permanent?: boolean): Promise<void>` | Delete |
| `trash` | `(file: TAbstractFile, system: boolean): Promise<void>` | Move to trash |
| `createFolder` | `(path: string): Promise<TFolder>` | Create directory |

### Frontmatter Manipulation

`FileManager.processFrontMatter(file, fn, options?)` provides safe
YAML frontmatter editing. The callback receives a mutable frontmatter
object:

```typescript
app.fileManager.processFrontMatter(file, (fm) => {
  fm.status = "in-progress";
});
```

**Caveat (confirmed):** `processFrontMatter` destroys YAML
formatting — comments, string quotes, and custom formatting are
stripped. This is a known issue with no official fix. Workarounds
include post-processing or using `vault.modify()` with manual YAML
parsing.

### Relevance to Open Station

Open Station's convention (markdown + YAML frontmatter) maps
directly to the Vault API. A plugin could:

- Enumerate tasks via `getMarkdownFiles()` + path filtering
- Parse frontmatter via `MetadataCache` or `processFrontMatter`
- Update task status via `processFrontMatter` or `vault.modify()`
- Create new tasks via `vault.create()`

---

## 2. Custom Views (Task Board)

Obsidian supports custom pane views by extending `ItemView`.

### Implementation Pattern

```typescript
import { ItemView, WorkspaceLeaf } from "obsidian";

const VIEW_TYPE = "openstation-board";

class TaskBoardView extends ItemView {
  constructor(leaf: WorkspaceLeaf) { super(leaf); }

  getViewType() { return VIEW_TYPE; }
  getDisplayText() { return "Open Station"; }

  async onOpen() {
    const el = this.contentEl;
    el.empty();
    // Render task board UI here
  }

  async onClose() { /* cleanup */ }
}
```

### Registration and Activation

```typescript
// In plugin onload()
this.registerView(VIEW_TYPE, (leaf) => new TaskBoardView(leaf));

// Activate the view
async activateView() {
  this.app.workspace.detachLeavesOfType(VIEW_TYPE);
  await this.app.workspace.getRightLeaf(false).setViewState({
    type: VIEW_TYPE, active: true
  });
  this.app.workspace.revealLeaf(
    this.app.workspace.getLeavesOfType(VIEW_TYPE)[0]
  );
}
```

### Key Rules

- **Never cache view references** — Obsidian may instantiate views
  multiple times. Use `getLeavesOfType()` to access instances.
- **Use `contentEl`** for DOM injection — `containerEl.children[1]`
  is deprecated/unstable.
- **Initialize after layout ready** — use
  `workspace.onLayoutReady()`.
- **Clean up on unload** — call
  `detachLeavesOfType()` in `onunload()`.

### UI Rendering

Views can use:
- **Plain DOM** via Obsidian's `createEl()` helpers
- **React/Svelte/etc.** — mount a framework component into
  `contentEl` (the Kanban plugin uses React)
- **Obsidian components** like `Setting`, `Modal`, `Notice`

### Reference Implementation

The [obsidian-kanban](https://github.com/mgmeyers/obsidian-kanban)
plugin is the primary reference for a markdown-backed board view.
Architecture: `main.ts` → registers view, `KanbanView` extends
`ItemView`, React renders the board, a parser reads/writes the
markdown backing file.

---

## 3. File Change Events

The Vault class extends `Events` and emits lifecycle events.

### Vault Events

| Event | Callback Signature | Fires When |
|-------|--------------------|------------|
| `create` | `(file: TAbstractFile) => void` | File/folder created |
| `modify` | `(file: TFile) => void` | File content changed |
| `delete` | `(file: TAbstractFile) => void` | File/folder deleted |
| `rename` | `(file: TAbstractFile) => void` | File/folder renamed (new path) |

### Registration (with auto-cleanup)

```typescript
this.registerEvent(
  this.app.vault.on("modify", (file) => {
    if (file.path.startsWith("tasks/")) {
      this.refreshTaskBoard();
    }
  })
);
```

Using `registerEvent()` (inherited from `Component`) ensures the
listener is removed when the plugin unloads.

### MetadataCache Events

For frontmatter-specific changes, `MetadataCache` is more precise:

| Event | Callback | Description |
|-------|----------|-------------|
| `changed` | `(file: TFile, data: string, cache: CachedMetadata) => void` | Metadata updated |
| `deleted` | `(file: TFile) => void` | File removed from cache |
| `resolved` | `() => void` | All links resolved |

The `changed` event provides parsed `FrontMatterCache` within the
`CachedMetadata` object — ideal for detecting task status changes
without re-parsing YAML.

### Workspace Events

| Event | Description |
|-------|-------------|
| `active-leaf-change` | Focused pane changed |
| `file-open` | File opened in editor |
| `layout-change` | Layout modified |

### Relevance to Open Station

A plugin could listen to `vault.on("modify")` filtered to `tasks/`
to auto-refresh a task board view whenever an agent (or the user)
updates a task spec. The `MetadataCache.on("changed")` event would
provide parsed frontmatter, eliminating the need for manual YAML
parsing on each change.

---

## Feasibility Assessment

**Verdict: Highly feasible.** The Obsidian plugin API covers every
requirement for an Open Station integration.

### Strengths

| Capability | API Support | Confidence |
|------------|-------------|------------|
| Read/write task specs | `Vault.read()`, `create()`, `modify()` | Confirmed |
| Parse/update frontmatter | `processFrontMatter()`, `MetadataCache` | Confirmed |
| Task board view | `ItemView` extension | Confirmed |
| React-based UI | Mount into `contentEl` | Confirmed (Kanban does this) |
| Reactive updates | `vault.on("modify")`, `metadataCache.on("changed")` | Confirmed |
| Path-based filtering | `getMarkdownFiles()`, `getAbstractFileByPath()` | Confirmed |

### Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| `processFrontMatter` destroys YAML formatting | Medium | Use `vault.modify()` with careful string manipulation or a YAML library |
| No sandboxing — plugins have full vault access | Low | Standard for Obsidian plugins; not a blocker |
| Plugin maintenance burden | Medium | Obsidian API is stable but undocumented in places; pin API version |

### Recommended Approach

1. **MVP**: ItemView-based task board that reads `tasks/` specs,
   renders a kanban-style board grouped by status, and allows
   drag-and-drop status changes via `vault.modify()`.
2. **Reactive**: Use `vault.on("modify")` + `metadataCache.on("changed")`
   to auto-refresh the board when files change (from agents or
   manual edits).
3. **Frontmatter**: Use `vault.modify()` with a YAML library
   (e.g., `yaml` npm package) instead of `processFrontMatter()` to
   preserve formatting.
4. **Reference**: Fork architecture from `obsidian-kanban` for the
   React-based board rendering.

---

## Key Documentation Links

- [Vault API](https://docs.obsidian.md/Plugins/Vault)
- [Views](https://docs.obsidian.md/Plugins/User+interface/Views)
- [Events](https://docs.obsidian.md/Plugins/Events)
- [ItemView Reference](https://docs.obsidian.md/Reference/TypeScript+API/ItemView)
- [Vault Reference](https://docs.obsidian.md/Reference/TypeScript+API/Vault)
- [processFrontMatter](https://docs.obsidian.md/Reference/TypeScript+API/FileManager/processFrontMatter)
- [obsidian-api GitHub](https://github.com/obsidianmd/obsidian-api)
- [obsidian-kanban (reference plugin)](https://github.com/mgmeyers/obsidian-kanban)
- [DeepWiki API Reference](https://deepwiki.com/obsidianmd/obsidian-api/5-api-reference)
