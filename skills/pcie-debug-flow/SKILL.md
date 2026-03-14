---
name: pcie-debug-flow
description: Self-Crosslink PCIE 项目专用调试流程约束。当用户说 "/pcie-debug-flow" 或明确要求使用调试工作流时触发此 skill。此 skill 强制执行调试必须遵守的开发流程：先检查时钟复位 → 分析Warning → 定位根因 → 修复 → 验证 → 经验沉淀。必须使用子代理 (sv-debug → sv-refactor) 串行执行，禁止直接使用主代理。整合了 questasim-selfcrosslink MCP 工具用于自动化日志分析和仿真验证。
---

# PCIE Debug Flow

Self-Crosslink PCIE 项目专用调试流程约束。

## 触发条件

当用户说以下任意一条时触发：
- `/pcie-debug-flow`
- "用调试工作流"
- "根据 WF-003"
- 其他明确要求使用调试流程的表述

## 项目上下文

| 项目 | 路径 |
|------|------|
| 项目名称 | Self-Crosslink PCIE 仿真验证 |
| 项目路径 | `D:\claude_workspace\chip_dev_workarea\projects\self_crosslink` |
| 仿真工具 | QuestaSim 2024.1 |
| DUT 特性 | 预编译库（无源码访问） |

## MCP 工具（优先使用）

**questasim-selfcrosslink MCP 提供以下工具，优先使用：**

| 工具 | 功能 | 返回内容 |
|------|------|---------|
| `questasim_build` | 编译设计 | errors, warnings, output_dir |
| `questasim_run_simulation` | 运行仿真 | status(PASS/FAIL), link_state, duration_ms |
| `questasim_analyze_log` | 分析日志 | **errors, warnings, link_status, key_events** |
| `questasim_search_vcd_signal` | VCD信号搜索 | signals, transitions |
| `questasim_search_live_signal` | 实时信号搜索 | signals, paths |
| `questasim_run_unit_test` | 运行单元测试 | passed, details |

**MCP 工具优先原则**：
- 调试分析时，优先调用 MCP 工具获取结构化数据
- 仅当 MCP 工具不可用或返回不完整时，回退到手动日志分析
- MCP 工具的 JSON 输出可直接用于 GATEFLOW-RETURN 格式

## 核心原则（强制）

### 调试第一原则（必须首先执行）

**在任何调试开始前，必须先验证时钟和复位信号！永远不要假设输入是正确的。**

检查顺序（严格按此执行）：
1. 时钟是否存在？频率是否正确？
2. 复位极性/时序是否正确？
3. 只有上述通过后才检查内部逻辑

### 子代理调用规范（强制）

调试必须使用子代理串行执行，**禁止**直接使用主代理：

```
sv-debug (分析) → sv-refactor (修复) → gf-lint (验证) → gf-sim (验证)
```

每个子代理的职责：
| 代理 | 职责 | 必须完成的工作 |
|------|------|---------------|
| sv-debug | 问题诊断、根因分析 | 时钟复位检查、Warning分析、根因定位、生成诊断报告 |
| sv-refactor | 执行代码修复 | 根据诊断报告执行修复、返回 GATEFLOW-RETURN |
| gf-lint | 代码质量验证 | 运行 lint 检查 |
| gf-sim | 功能验证 | 运行仿真验证修复 |

### 经验驱动原则（强制）

- 调试开始前：注入 lessons.md 相关经验
- 调试完成后：必须更新 lessons.md 和相关经验文档

## 执行流程（强制）

### Step 0: 询问问题（触发后首先执行）

**在执行任何调试动作之前，必须先询问用户具体问题：**

- 请描述具体的问题现象？
- 是什么时候发现的？
- 有什么错误信息或日志吗？
- 期望的行为是什么，实际发生了什么？

只有在明确问题后，才能进入后续分析步骤。

### Step 1: 问题分类

根据症状判断问题类型：

| 问题类型 | 症状 | 优先级 |
|----------|------|--------|
| 编译错误 | vlog Error | P0 |
| 端口问题 | vsim-3014/3015 | P1 |
| 仿真挂死 | 无输出、超时 | P0 |
| 功能异常 | 输出错误、状态不对 | P1 |
| X值传播 | 输出为X | P1 |

### Step 2: 信息收集（MCP 工具优先）

**优先使用 MCP 工具收集信息：**

1. **日志分析（MCP）** - 调用 `questasim_analyze_log`：
   ```json
   {
     "errors": [...],
     "warnings": [...],
     "link_status": {"pl_link_up": "1", "dl_link_up": "1", "tl_link_up": "1"},
     "key_events": [...]
   }
   ```

2. **备选方案（手动）** - 仅当 MCP 不可用时：
   - 编译日志：`projects/self_crosslink/build/compile.log`
   - 仿真日志：`projects/self_crosslink/build/sim.log`
   - 波形文件：`projects/self_crosslink/build/*.wlf`

3. **用户描述** - 问题现象

### Step 3: sv-debug 根因分析

调用 sv-debug 子代理，必须包含：
- 项目上下文
- 时钟复位检查结果（强制）
- Warning 分类分析
- 根因定位

### Step 4: sv-refactor 修复执行

调用 sv-refactor 子代理，必须包含：
- sv-debug 输出的诊断报告
- 修复建议

### Step 5: 验证修复（MCP 工具优先）

**优先使用 MCP 工具验证：**

1. **快速单元测试（MCP）** - 调用 `questasim_run_unit_test`：
   - 验证修复后模块功能正常

2. **完整仿真验证（MCP）** - 调用 `questasim_run_simulation`：
   ```json
   {
     "status": "PASS",
     "link_state": {
       "pl_link_up": true,
       "dl_link_up": true,
       "tl_link_up": true
     }
   }
   ```

3. **日志分析（MCP）** - 调用 `questasim_analyze_log`：
   - 确认无新增错误/警告

4. **备选方案（手动）** - 仅当 MCP 不可用时：
   - 调用 gf-lint skill 验证代码质量
   - 调用 gf-sim skill 验证功能

**验证结果判定**：
- MCP 返回 `status: PASS` 且 link_state 全部为 true = 验证通过
- 任何错误或 link_state 为 false = 验证失败，重试（上限3次）

### Step 6: 经验沉淀（必须执行）

调试完成后必须：
- 更新 `tasks/lessons.md`
- 更新 `docs/experience/` 相关文档
- 如适用，创建调试案例到 `docs/debug_cases/`

## 输出格式

### MCP 工具返回值（优先使用）

**questasim_analyze_log 返回：**
```json
{
  "success": true,
  "errors": [{"line": 123, "message": "...", "severity": "Error"}],
  "warnings": [{"line": 45, "message": "...", "severity": "Warning"}],
  "link_status": {"pl_link_up": "1", "dl_link_up": "1", "tl_link_up": "1"},
  "key_events": [{"time": 1000, "event": "Link UP detected"}]
}
```

**questasim_run_simulation 返回：**
```json
{
  "success": true,
  "status": "PASS",
  "link_state": {
    "pl_link_up": true,
    "dl_link_up": true,
    "tl_link_up": true,
    "negotiated_width": "x1",
    "current_speed": "GEN1"
  }
}
```

### GATEFLOW-RETURN 格式

sv-debug 必须返回 GATEFLOW-RETURN 格式：
```
---GATEFLOW-RETURN---
STATUS: complete|needs_clarification|error
SUMMARY: [诊断结果概述]
ROOT_CAUSE: [编译错误|时钟问题|端口问题|功能异常|时序问题|其他]
FIX_FILES: [需要修改的文件列表]
FIX_SUGGESTIONS:
  - [修复建议1]
  - [修复建议2]
---END-GATEFLOW-RETURN---
```

sv-refactor 必须返回 GATEFLOW-RETURN 格式：
```
---GATEFLOW-RETURN---
STATUS: complete
SUMMARY: [修复概述]
FILES_MODIFIED: [修改的文件列表]
CHANGES:
  - file: [文件路径]
    line: [行号]
    change: [修改内容]
---END-GATEFLOW-RETURN---
```

## 禁止事项

- 禁止跳过时钟复位检查直接分析内部逻辑
- 禁止在调试流程中使用主代理替代子代理
- 禁止忽略 Warning（P0/P1 必须处理）
- 禁止跳过经验沉淀步骤
- **禁止绕过 MCP 工具直接手动分析日志**（MCP 不可用时除外）

## 相关文档

- WF-003 完整版：`docs/workflow/WF-003_Workflow_For_Debug_Driven_Development.md`
- 调试案例库：`docs/debug_cases/`
- 历史教训：`tasks/lessons.md`
