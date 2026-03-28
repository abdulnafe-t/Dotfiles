---
name: file-search
description: "Use when working with ANY codebase search — text patterns, structural/AST code search, finding files by name, searching non-code files (PDFs, archives), or analyzing codebase size and language breakdown."
license: "(MIT AND CC-BY-SA-4.0). See LICENSE-MIT and LICENSE-CC-BY-SA-4.0"
compatibility: "Requires ripgrep (rg). Optional: fd, ast-grep, tokei."
metadata:
  author: Netresearch DTT GmbH
  version: "1.1.0"
  repository: https://github.com/netresearch/file-search-skill
allowed-tools: Bash(rg:*) Bash(fd:*) Bash(sg:*) Read Glob Grep
---

# File Search Skill

Efficient CLI search tools for AI agents. Covers tool selection, targeting
strategies, and best practices.

## Tool Selection Guide

| Task | Use | Instead of |
|------|-----|------------|
| Search text in code files | `rg` (ripgrep) | `grep`, `grep -r` |
| Find files by name/path | `fd` | `find`, `ls -R` |
| Structural/syntax-aware code search | `sg` (ast-grep) | regex hacks |
| Search PDFs, Office docs, archives | `rga` (ripgrep-all) | manual extraction |
| Count lines of code by language | `tokei` | `cloc`, `wc -l` |
| Code stats with complexity metrics | `scc` | `cloc`, `tokei` |

**Decision flow:**

1. Text pattern in source code? --> `rg`
2. Code structure (function signatures, class patterns)? --> `sg`
3. Files by name, extension, or type? --> `fd`
4. Inside PDFs, Word docs, spreadsheets, archives? --> `rga`
5. Codebase size/language breakdown? --> `tokei` or `scc`

## Quick Examples

**rg** -- text/regex search:
```bash
rg 'def \w+\(' -t py src/          # Python function defs in src/
rg -c 'TODO' -t js | wc -l         # count files with TODOs
rg 'pattern' -g '!vendor/' -g '!node_modules/'  # exclude noise
```

**sg** -- structural/AST search:
```bash
sg --pattern 'if $ERR != nil { return $ERR }' --lang go   # unwrapped errors
sg --pattern 'console.log($$$)' --rewrite 'logger.info($$$)' --lang js
```

**fd** -- find files:
```bash
fd -e py --changed-within 1d        # Python files changed today
fd -g '*_test.go' -X rg 'func Test' # verify test files have tests
```

## Targeting Searches

- **File types** (`rg -t py`, `sg --lang go`, `fd -e ts`) -- cuts search space.
- **Directory scope** (`rg pattern src/api/`) -- never search from root.
- **Count first** (`rg -c pattern | wc -l`) -- narrow if >50 files.
- **Exclude noise** (`-g '!vendor/'`, `fd -E node_modules`).

See [references/search-strategies.md](references/search-strategies.md).

## Best Practices

1. **Start narrow, widen if needed.** Most specific search first.
2. **`fd` for files, `rg` for content.** Never `find` or `grep -r`.
3. **`rga` for non-code files.** Never manually extract PDFs.
4. **`sg` for structural patterns.** Use ast-grep when regex is fragile.
5. **`--json` output** when piping to further processing.

## References

| Topic | File |
|-------|------|
| rg flags, patterns, recipes | [references/ripgrep-patterns.md](references/ripgrep-patterns.md) |
| ast-grep patterns by language | [references/ast-grep-patterns.md](references/ast-grep-patterns.md) |
| fd flags, usage, fd+rg combos | [references/fd-guide.md](references/fd-guide.md) |
| rga formats, usage, caching | [references/rga-guide.md](references/rga-guide.md) |
| tokei and scc usage | [references/code-metrics.md](references/code-metrics.md) |
| Search targeting strategies | [references/search-strategies.md](references/search-strategies.md) |
| Tool comparison and decision guide | [references/tool-comparison.md](references/tool-comparison.md) |
