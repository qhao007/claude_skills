---
name: project-lesson-loader
description: "Load and retrieve previously saved lessons and project memories with progressive loading. Use when agent needs to check past experience before starting a task, when subagent receives a task and wants to leverage prior knowledge, or when any agent wants to recall what was learned before. Automatically loads lessons index, searches relevant categories, and presents key insights without requiring human interaction. Triggered by task context like: agent starting work, subagent receiving assignment, checking for prior solutions, debugging with prior knowledge."
---

# Project Lesson Loader

## Overview

This skill is the inverse of `project-memory-saver`. It provides AI agents (especially subagents) with access to previously saved lessons **before starting work**, enabling them to leverage accumulated knowledge without re-learning lessons the hard way.

**Core principle**: Load the minimum necessary to be smarter about the task at hand.

## When to Use

**Trigger conditions (autonomous):**
- Agent/subagent receives a new task
- Agent is about to start debugging
- Agent needs to check if similar problems were solved before
- Agent wants to apply proven patterns to current work
- Any time agent could benefit from prior knowledge

**Explicit triggers:**
- "查一下之前的经验"
- "load relevant lessons"
- "check what we learned before"
- Agent proactively decides to check lessons before working

## Progressive Loading Strategy

### Phase 1: Load Index (Always Start)

Find workspace root and load the index file:

```python
# 1. Find workspace root
WORKSPACE_ROOT = find_workspace_root()  # Look for CLAUDE.md or tasks/ in parents

# 2. Load index
INDEX_PATH = f"{WORKSPACE_ROOT}/tasks/lessons.md"
if exists(INDEX_PATH):
    index_content = read(INDEX_PATH)
else:
    # Build index by scanning
    index_content = scan_lessons_meta(WORKSPACE_ROOT)
```

The index provides:
- Available lesson categories
- Brief descriptions
- File paths

### Phase 2: Context-Aware Search

Based on the **current task**, automatically determine relevant categories:

```python
# Map task keywords to lesson categories
TASK_CATEGORY_MAP = {
    "debug": ["debugging_methodology.md", "debug_notes/"],
    "simulation": ["questasim_common.md", "simulator_notes.md"],
    "uvm": ["uvm_patterns.md", "verification_patterns.md"],
    "pcie": ["pcie_protocol.md", "protocol_knowledge.md"],
    "cdc": ["cdc_analysis.md", "timing_methodology.md"],
    "lint": ["lint_issues.md", "coding_quality.md"],
    "synthesis": ["synthesis_notes.md", "asic_flow.md"],
    # ... more mappings
}
```

**Agent workflow:**
```
1. Analyze current task (what am I about to do?)
2. Map to relevant category keywords
3. Search/load matching lesson files
4. Extract relevant entries
5. Present key insights as part of task context
```

### Phase 3: Extract & Summarize

Only load specific entries, not entire files:

```python
def load_relevant_lessons(task_keywords, categories):
    results = []
    for category in categories:
        file_path = f"{LESSONS_META}/{category}"
        entries = search_in_file(file_path, task_keywords)
        results.extend(extract_summaries(entries))
    return results
```

Present as concise context:
```
📚 Relevant Past Lessons:

[Lesson 1 - Debugging]
Key Insight: CDC issues cause edge detection failures in monitors
Context: Monitor uses user_clk, DUT signals from PIPE clock domain

[Lesson 2 - UVM]
Key Insight: Always drop objection in sequence pre/post body
Context: Otherwise simulation hangs at time 0
```

## For Subagents

When a subagent receives a task:

1. **Immediately** check for relevant lessons before diving into work
2. **Use current task context** to determine search terms
3. **Load lessons silently** - incorporate into your understanding
4. **Apply** the insights to improve your approach

Example subagent thought:
```
Task: Debug why PCIe link training fails

→ Before diving in, let me check relevant lessons
→ Keywords: "PCIe", "link training", "debug", "LTSSM"
→ Found 2 relevant entries in pcie_protocol.md and debugging_methodology.md
→ Key insight: Check clock domain crossing between PIPE and user clocks
→ Applied this to my debug approach
```

## Response Format

Compact format for agent context:

```
📚 Relevant Past Lessons:

1. [<Category>] <Title>
   → Key Insight: <one-liner>
   → Context: <brief>
   → Source: <file>

2. [<Category>] <Title>
   → Key Insight: <one-liner>
   → Context: <brief>
   → Source: <file>
```

## Search Strategy

**Autonomous search:**
1. Extract keywords from current task
2. Match against known lesson categories
3. Search within files for keyword matches
4. Return top 3-5 most relevant entries

**Category auto-detection:**
```
Task contains "UVM" → search uvm_patterns.md
Task contains "PCIe" or "link" → search pcie_protocol.md
Task contains "debug" or "fail" → search debugging_methodology.md
Task contains "synthesis" or "timing" → search synthesis_notes.md
```

## Important Rules

1. **Be autonomous** - No need to ask humans for clarification
2. **Load incrementally** - Index → relevant files → specific entries
3. **Stay concise** - Extract key insights, don't dump entire files
4. **Integrate naturally** - Present as "Based on past lessons..."
5. **If nothing found** - Continue with task, optionally note "No prior lessons found for X"

## Example

**Subagent receives task:** "Debug why my PCIe DUT is not sending completion packets"

```
→ Keywords: "PCIe", "completion", "debug"
→ Categories: pcie_protocol.md, debugging_methodology.md
→ Found relevant entry:

📚 Relevant Past Lessons:

1. [PCIe Protocol] Completion timeout issues
   → Key Insight: Check completion timeout with CMPLTO timeout value
   → Context: DUT not sending completions within timeout window
   → Source: tasks/lessons_meta/pcie_protocol.md

2. [Debugging] Clock domain issues in PCIe
   → Key Insight: PIPE clock vs user_clk CDC is common failure point
   → Context: Monitor missing events due to clock domain mismatch
   → Source: tasks/lessons_meta/debugging_methodology.md

→ Applied to approach: Will check CDC first, then verify CMPLTO timing
```
