---
name: project-memory-saver
description: "Save important session information to project-level memory files AND upper-level lessons. Use when user explicitly requests to save information to memory, remembers something, or wants to persist session context. Triggers include: '记住这个', 'save to memory', '保存到 memory', 'persist this', 'remember that', '沉淀经验', '记录经验', 'save to lessons'. This skill saves project-specific info to project's .claude/memory/ AND writes universal, reusable lessons to tasks/lessons_meta/."
---

# Project Memory Saver

## Overview

This skill saves important session information to two locations:

1. **Project memory**: `.claude/memory/` - project-specific info
2. **Lessons**: `tasks/lessons_meta/` - universal, reusable lessons

## When to Use

Use this skill when user explicitly requests to save information to memory:

**Trigger phrases:**
- "记住这个" / "记住"
- "save to memory" / "保存到 memory"
- "persist this" / "remember that"
- "write this to memory"
- "记录这个" / "记录下"
- "沉淀经验" / "记录经验"
- "save to lessons" / "写入 lessons"
- Any request to save session context to memory

## Two-Level Memory System

### Level 1: Project Memory (Project-Specific)

```
<project>/.claude/memory/
├── MEMORY.md           # Main memory file (always loaded)
├── <topic1>.md         # Topic-specific memory files
├── <topic2>.md
└── ...
```

**Use for**: Project-specific details that won't apply to other projects
- Specific file paths, function names
- DUT register addresses
- Project-specific configurations
- Implementation details

### Level 2: Lessons (Universal)

```
<workspace>/tasks/lessons_meta/
├── debugging_methodology.md    # Debugging methods
├── questasim_common.md        # Tool usage
├── pcie_protocol.md          # Protocol knowledge
├── project_specific/         # Project-specific (rarely used here)
│   ├── self_crosslink.md
│   └── pcie_demo.md
└── ...
```

**Use for**: Universal, reusable knowledge
- Debugging methodologies (CDC, clock domain issues)
- Tool usage patterns
- Protocol understanding
- Any knowledge that transfers across projects

## Classification Rule

**判断标准**: 如果换一个项目还能不能用？

| 类型 | 例子 | 写入位置 |
|------|------|----------|
| 通用经验 | CDC 导致边沿检测失败、调试流程 | `tasks/lessons_meta/debugging_methodology.md` |
| 工具经验 | QuestaSim 命令、选项 | `tasks/lessons_meta/questasim_common.md` |
| 协议经验 | PCIe 编码、LTSSM 状态 | `tasks/lessons_meta/pcie_protocol.md` |
| 项目专属 | DUT 寄存器路径、特定配置 | 项目 `.claude/memory/` |

## How to Save

### Step 0: Find Workspace Root (Critical)

When running from a project subdirectory, you MUST find the workspace root first:

**Method 1: Look for CLAUDE.md in parent directories**
```
Current: <project>/subdir/
Search:  ./CLAUDE.md
         ../CLAUDE.md
         ../../CLAUDE.md
         ... (keep going up until found)
```

**Method 2: Check for known directories**
```
Look for: tasks/lessons_meta/ in parent directories
```

**Result**: Determine `WORKSPACE_ROOT` (absolute path)
- Example: `D:\claude_workspace\chip_dev_workarea`

### Step 1: Analyze the Information

1. **Read lessons index** to find appropriate lesson file:
   ```
   <workspace>/tasks/lessons.md
   <workspace>/tasks/lessons_meta/
   ```

2. **Classify the knowledge**:
   - Universal → Write to `tasks/lessons_meta/<appropriate>.md`
   - Project-specific → Write to project `.claude/memory/`

### Step 2: Write to Lessons (Universal Knowledge)

If the knowledge is universal:

1. Use `WORKSPACE_ROOT` from Step 0 to construct path:
   ```
   <WORKSPACE_ROOT>/tasks/lessons_meta/debugging_methodology.md
   ```

2. Find appropriate file:
   - `debugging_methodology.md` - Debug methods
   - `questasim_common.md` - Tool patterns
   - `pcie_protocol.md` - Protocol understanding
   - `project_specific/<project>.md` - Only for truly project-specific

3. **Format:**
```markdown
---

## [<Category>] <Title>

> **Date**: YYYY-MM-DD
> **Session**: <brief context>

### What
<Description of what happened/fixed/learned>

### Why
<Why this matters / root cause>

### Key Insight
<The core lesson - transferable to other projects>

### Debug/Correlation
- How this was discovered
- Evidence (logs, signals, etc.)
```

4. **Append to existing file** (preserve content, add new entry with `---` separator)

### Step 3: Write to Project Memory (Project-Specific)

If the knowledge is project-specific:

1. Create `.claude/memory/` directory if not exists
2. Use `MEMORY.md` or topic-specific file

**Format:**
```markdown
# [<Topic>] <Title>

> **Date**: YYYY-MM-DD
> **Session**: <brief context>

## What
<Project-specific detail>

## Why
<Why it matters>

## Notes
<Additional context>
---
```

### Step 4: Confirm

Tell the user:
- What was saved
- Which files
- Classification (universal vs project-specific)

## Example

**User says:** "记住这个：CDC 问题会导致 Monitor 边沿检测失败"

**Analysis:**
- CDC issue is universal → applies to any project with clock domains
- Monitor edge detection applies to any verification project
- **Classification: Universal**

**Action:**
1. Write to `tasks/lessons_meta/debugging_methodology.md`
2. (Optional) Write summary to project memory if project-specific context exists

**Output:**
```
✓ 经验已沉淀

| 类型 | 位置 |
|------|------|
| 通用经验 | tasks/lessons_meta/debugging_methodology.md |
| 项目专属 | (无 - 通用经验) |

内容摘要:
## [调试方法论] 时钟域交叉导致的 Monitor 边沿检测失败
- 问题: Monitor FULL LINK UP 消息不触发
- 原因: Monitor 用 user_clk，DUT 信号来自 PIPE 时钟域
- 经验: 任何信号问题先问时钟域
```

## Important Notes

1. **Always read lessons index first** (`tasks/lessons.md`, `tasks/lessons_meta/`)
2. **Dual-write when appropriate**: If knowledge has both universal and project-specific aspects, write to both
3. **Preserve existing content**: Use Edit, not Write, for existing files
4. **Add separators**: Use `---` between entries in lesson files
5. **Be concise**: Summarize key points, don't dump entire conversation

## Classification Decision Tree

```
知识是否可以跨项目使用？
├── 是 → 写入 tasks/lessons_meta/
│   ├── 调试方法 → debugging_methodology.md
│   ├── 工具使用 → questasim_common.md
│   ├── 协议理解 → pcie_protocol.md
│   └── 其他 → 新建文件或 debugging_methodology.md
└── 否 → 写入项目 .claude/memory/
```
