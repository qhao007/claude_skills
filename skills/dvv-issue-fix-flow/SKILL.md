---
name: dvv-issue-fix-flow
description: |
  代码问题调试修复工作流技能。当用户需要调试代码问题、做根因分析、确认debug手段和方法、执行修复到验证修复的闭环时使用此技能。

  适用场景：
  - 用户提供了问题/缺陷报告
  - 仿真/测试失败需要调试
  - 代码行为不符合预期
  - 需要完整的"分析→计划→实施→验证"闭环

  工作流包括9个阶段：工作区准备 → 输入获取 → 问题分析 → 计划评审(1-3轮) → 计划优化 → 执行修复 → 验证 → 结果评审 → 总结回顾。

  触发方式：用户说"调试问题"、"修复bug"、"分析问题"、"工作流"等相关表述。
---

# DVV Issue Fix Flow - 代码问题调试修复工作流

> **提示**: 报告模板见 `references/templates/` 目录（00_workspace_preparation.md, 01_analysis_report.md, 01_debug_plan.md, 02_review_report.md, 03_verification_report.md, 04_fix_record.md, 05_result_review.md）

## 概述

通用的代码问题调试修复工作流，通过9个阶段子代理完成完整的"问题分析→修复实施→验证闭环"流程。

> **核心原则**: 主代理只控制/编排流程，不做决策，不执行具体任务。所有任务/决策通过子代理执行。

---

## 阶段总览

| 阶段 | 子代理 | 职责 | 输出 |
|------|--------|------|------|
| 0 | Subagent W (工作区准备) | 准备工作区，创建目录结构和执行日志 | .dvv 目录结构 + 执行日志 |
| 1 | 主代理 | 获取用户输入/问题描述 | 问题描述文档 |
| 2 | Subagent A (问题分析) | 详细问题分析 + 调试实施计划 | 分析报告 + 调试计划 |
| 3 | Subagent B (评审) | 评审调试计划，评估遗漏/逻辑问题 | 评审意见 |
| 4 | Subagent A (优化) | 根据评审意见优化调试计划 | 优化后的调试计划 |
| 5 | Subagent C (执行修复) | 执行调试和修复 | 修复后的代码 |
| 6 | Subagent D (验证) | 仿真验证修复，确认无新问题 | 验证报告 |
| 7 | Subagent B (结果评审) | 评估验证结果，决策是否再次修复 | 评审结论 |
| 8 | 主代理 | 总结 + 调用工作流回顾 | 最终报告 |

---

## 通用必须阅读文档

所有阶段（Phase 0-8）**必须**在开始执行前阅读以下文档：

| 文档 | 说明 | 位置 |
|------|------|------|
| 项目 CLAUDE.md | 当前项目的规范 | `{项目路径}/CLAUDE.md` |
| 工作流进度日志 | 工作流执行进度和状态 | `.dvv/issue_fix_flow_progress_log.md` |

---

# Phase 0: 工作区准备 (Subagent W)

## 职责定义

**工作区准备工程师** - 准备工作区环境，创建标准目录结构，初始化执行日志，归档历史文档。

## 必须阅读的输入文档

无需输入文档，此阶段为工作流起始点。

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "general-purpose"
- model: "haiku"
- description: "DVV 工作区准备"
- prompt: |
  执行 project-pre-workflow-audit 技能，准备工作区：
  1. 工作流名称: issue_fix_flow
  2. 创建 .dvv 目录结构 (inputs/plans/others/reports/archived)
  3. 创建执行日志 .dvv/issue_fix_flow_progress_log.md
  4. 归档历史文档（如有）
- max_retries: 2
```

## 必须执行的技能

**project-pre-workflow-audit** - 工作流执行前准备工作

## 执行步骤

### 1. 确认工作目录

```bash
pwd
```

### 2. 创建目录结构

```bash
mkdir -p .dvv/inputs
mkdir -p .dvv/plans
mkdir -p .dvv/others
mkdir -p .dvv/reports
mkdir -p .dvv/archived
```

### 3. 归档历史文档

如果存在历史运行文档，移动到归档目录：

```bash
timestamp=$(date +%Y%m%d_%H%M%S)
archive_dir=".dvv/archived/issue_fix_flow/${timestamp}"
mkdir -p "${archive_dir}/inputs" "${archive_dir}/plans" "${archive_dir}/others" "${archive_dir}/reports"

# 移动历史文件
[ -f ".dvv/issue_fix_flow_progress_log.md" ] && mv ".dvv/issue_fix_flow_progress_log.md" "${archive_dir}/"
```

### 4. 创建执行日志

创建 `.dvv/issue_fix_flow_progress_log.md`：

```markdown
# 工作流执行日志: issue_fix_flow

> **创建时间**: YYYY-MM-DD HH:MM:SS
> **执行代理**: main_agent
> **状态**: 进行中

---

## 执行目标

[描述此工作流的执行目标]

---

## 执行记录

### Phase 0: 工作区准备
- **时间**: YYYY-MM-DD HH:MM:SS
- **执行者**: general-purpose subagent
- **目标**: 准备工作区环境
- **做了什么**: 创建目录结构，初始化执行日志
- **结果**: 成功
- **输出文件**: .dvv/issue_fix_flow_progress_log.md

---

## 当前状态

- 进度: 0/9 阶段
- 上一步: 无
- 下一步: Phase 1 - 获取输入信息

---

## 信息同步区

- 当前修复迭代次数: 0 / 3
```

## 输出要求

| 输出 | 路径 | 必须 |
|------|------|------|
| 输入目录 | `.dvv/inputs/` | ✅ |
| 计划目录 | `.dvv/plans/` | ✅ |
| 报告目录 | `.dvv/reports/` | ✅ |
| 其他文档目录 | `.dvv/others/` | ✅ |
| 归档目录 | `.dvv/archived/` | ✅ |
| 执行日志 | `.dvv/issue_fix_flow_progress_log.md` | ✅ |

**模板参考**: 阅读 `references/templates/00_workspace_preparation.md`

---

# Phase 1: 获取输入信息

## 主代理职责

1. **收集用户输入**：
   - 问题/缺陷描述
   - 进展/测试报告
   - 相关日志/波形文件
   - 用户期望行为描述

2. **解析输入内容**：
   - 提取关键问题点
   - 识别相关代码文件
   - 确定问题类型（功能/性能/接口等）

3. **创建问题描述文档**：
   ```
   .dvv/inputs/issue_description_{timestamp}.md
   ```

4. **更新执行日志**：
   - 记录 Phase 1 执行状态
   - 更新当前状态信息

---

# Phase 2: 问题分析 (Subagent A)

## 职责定义

**问题分析工程师** - 负责详细分析问题，识别根因，制定调试和修复计划。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| 用户原始输入 | 问题描述、日志、波形文件等（在 `.dvv/inputs/` 下） |

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "dvv-issue-analysis-agent"
- model: "sonnet"
- description: "DVV 问题分析调试"
- max_retries: 3
```

## 必须执行的技能

1. **加载 CLAUDE.md** - 读取当前工作目录的 CLAUDE.md 了解项目规范
2. **project-lesson-loader** - 调用技能获取相关知识索引
3. **project-memory-saver** - 调用技能获取/保存项目知识

## 必须完成的分析任务

### 1. 问题理解
- 理解用户期望行为 vs 实际行为
- 识别涉及的模块/信号/接口

### 2. 根因分析
- 分析代码逻辑
- 检查时钟/复位信号
- 检查信号时序
- 对比协议规范

### 3. 调试计划制定
- 列出需要验证的关键点
- 确定 debug 手段（仿真、波形分析、打印等）
- 制定修复方案

## 输出要求

### 1. 分析报告
```
.dvv/reports/analysis_report_{timestamp}.md
```

**模板参考**: 阅读 `references/templates/01_analysis_report.md`

### 2. 调试计划
```
.dvv/plans/debug_plan_{timestamp}.md
```

**模板参考**: 阅读 `references/templates/01_debug_plan.md`

**调试计划必须包含**：
- 明确的执行步骤划分
- 每个步骤的**成功条件**检查清单
- 测试矩阵（如需要多配置验证）
- 执行步骤汇总表（供 Phase 5 追踪使用）

---

# Phase 3: 计划评审 (Subagent B)

## 职责定义

**评审工程师** - 评审调试计划，评估是否有遗漏的现象、更多可行的debug思路、逻辑合理性。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 2 分析报告 | 问题分析报告 `.dvv/reports/analysis_report_*.md` |
| Phase 2 调试计划 | 调试计划 `.dvv/plans/debug_plan_*.md` |

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "general-purpose"
- model: "opus"
- description: "DVV 调试计划评审"
- max_retries: 3
```

## 评审检查清单

### 1. 遗漏检查
- [ ] 是否考虑了所有可能的根因？
- [ ] 是否有未考虑的边界条件？
- [ ] 是否有未考虑的异常路径？

### 2. Debug 思路检查
- [ ] 推荐的 debug 手段是否充分？
- [ ] 是否有更高效的调试方法？
- [ ] 是否遗漏了关键信号的检查？

### 3. 逻辑合理性检查
- [ ] 修复方案逻辑是否正确？
- [ ] 是否可能引入新的问题？
- [ ] 是否考虑了副作用？

### 4. 验证方案检查
- [ ] 验证方案是否覆盖所有场景？
- [ ] 是否考虑了回归测试？
- [ ] 是否有 negative test？

## 评审输出格式

**模板参考**: 阅读 `references/templates/02_review_report.md`

---

# Phase 4: 计划优化 (Subagent A 复用)

## 职责定义

根据 Phase 3 的评审意见，优化调试计划。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 2 调试计划 | 原始调试计划 `.dvv/plans/debug_plan_*.md` |
| Phase 3 评审意见 | 评审报告 `.dvv/reports/plan_review_*.md` |

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "dvv-issue-analysis-agent"
- model: "sonnet"
- description: "DVV 调试计划优化"
- max_retries: 2
```

## 执行逻辑

1. 读取 Phase 2 的调试计划
2. 读取 Phase 3 的评审意见
3. 根据评审意见修改调试计划
4. 输出优化后的调试计划

---

# Phase 5: 执行修复 (Subagent C)

## 职责定义

**修复实施工程师** - 根据调试计划执行具体的调试和修复。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 4 优化后的调试计划 | 最终调试计划 `.dvv/plans/debug_plan_*.md` |
| Phase 2 分析报告 | 问题分析报告 `.dvv/reports/analysis_report_*.md` |

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "general-purpose"
- model: "sonnet"
- description: "DVV 执行修复"
- max_retries: 3
```

## 必须执行的技能

1. **加载 CLAUDE.md** - 读取当前工作目录的 CLAUDE.md
2. **project-memory-saver** - 执行知识沉淀

## 执行要求

### 1. 计划执行追踪（新增）

在执行修复前，**必须**创建执行追踪表，对照调试计划中的执行步骤：

```markdown
# 执行状态追踪

| 调试计划步骤 | 计划要求 | 执行状态 | 备注 |
|--------------|----------|----------|------|
| [步骤1名称] | 必须 | 待执行 | - |
| [步骤2名称] | 必须 | 待执行 | - |
| [步骤3名称] | 建议 | 待执行 | - |
| ... | ... | ... | ... |
```

每完成一个步骤，更新执行状态为"已完成"或"跳过"（并说明原因）。

### 2. 实施修复
- 按照调试计划执行修复
- 如果发现新问题，主动进一步调试
- 记录修复过程中的发现

### 3. 修复记录
```
.dvv/reports/fix_record_{timestamp}.md
```

**修复记录必须包含执行状态追踪表的最终状态**。

**模板参考**: 阅读 `references/templates/04_fix_record.md`

### 4. 知识沉淀（必须执行）
调用 `project-memory-saver` 技能记录：
- 问题类型和解决方法的经验
- 使用的调试工具和方法
- 修复过程中的教训

---

# Phase 6: 验证 (Subagent D)

## 职责定义

**验证工程师** - 通过仿真验证修复，同时验证没有引入新问题。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 5 修复记录 | 修复记录 `.dvv/reports/fix_record_*.md` |
| Phase 2/4 调试计划 | 调试计划中的验证方案 `.dvv/plans/debug_plan_*.md` |

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "dvv-checking-agent"
- model: "sonnet"
- description: "DVV 修复验证"
- max_retries: 3
```

## 验证要求

### 1. 计划执行完整性检查（新增 - 关键改进）

**必须**对照调试计划，检查所有要求执行的步骤是否已执行：

```markdown
# 计划执行完整性检查

## 调试计划步骤执行状态

| 调试计划步骤 | 计划要求 | 实际执行 | 状态 |
|--------------|----------|----------|------|
| [步骤1名称] | 必须 | ✅/❌ | ✅/⚠️遗漏 |
| [步骤2名称] | 必须 | ✅/❌ | ✅/⚠️遗漏 |
| [步骤3名称] | 建议 | ✅/❌ | ✅/⚠️遗漏 |
| ... | ... | ... | ... |

## 测试矩阵执行状态

| 测试配置 | 计划要求 | 实际执行 | 结果 |
|----------|----------|----------|------|
| [配置A] | 必须 | ✅ 执行 | PASS/FAIL |
| [配置B] | 必须 | ✅ 执行 | PASS/FAIL |
| [配置C] | 建议 | ❌ 未执行 | - |
| ... | ... | ... | ... |

## 遗漏项评估

| 遗漏项 | 优先级 | 影响评估 | 是否阻塞 |
|--------|--------|----------|----------|
| [遗漏项1] | 高/中/低 | [影响说明] | 是/否 |
```

### 2. 遗漏项决策标准

| 遗漏项优先级 | 决策 |
|--------------|------|
| **高优先级**（如：根因验证、核心测试） | **阻塞验证通过**，必须返回补充执行 |
| **中优先级**（如：扩展边界测试） | 记录遗漏，可继续但需在报告中明确说明风险 |
| **低优先级**（如：可选优化项） | 记录遗漏，继续执行 |

### 3. 功能验证
- 确认原问题已修复
- 验证边界条件
- 验证异常处理

### 4. 回归验证
- 确认原有功能未受影响
- 运行相关测试用例

### 5. 验证报告
```
.dvv/reports/verification_report_{timestamp}.md
```

**模板参考**: 阅读 `references/templates/03_verification_report.md`

**验证报告必须包含**：
- 计划执行完整性检查表
- 遗漏项评估
- 决策建议（是否需要返回补充验证）

---

# Phase 7: 结果评审 (Subagent B 复用)

## 职责定义

评估 Phase 6 的验证结果，决策是否需要再次修复。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 6 验证报告 | 验证报告 `.dvv/reports/verification_report_*.md` |
| Phase 5 修复记录 | 修复记录 `.dvv/reports/fix_record_*.md` |
| Phase 2/4 调试计划 | 用于覆盖度验证 `.dvv/plans/debug_plan_*.md` |

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "general-purpose"
- model: "opus"
- description: "DVV 验证结果评审"
- max_retries: 2
```

## 覆盖度验证（新增 - 关键改进）

**必须**检查验证报告是否完整覆盖调试计划的要求：

### 1. 计划阶段执行覆盖

```markdown
## 覆盖度检查清单

| 检查项 | 状态 | 说明 |
|--------|------|------|
| 调试计划所有阶段是否都有执行记录？ | ✅/❌ | |
| 跳过的阶段是否有合理说明？ | ✅/❌ | |
| 高优先级遗漏项是否已补充执行？ | ✅/❌ | |
```

### 2. 测试矩阵覆盖

```markdown
## 测试覆盖度检查

| 检查项 | 状态 |
|--------|------|
| 必须测试项是否全部执行？ | ✅/❌ |
| 未执行项是否在验证报告中明确记录？ | ✅/❌ |
| 未执行项的风险评估是否合理？ | ✅/❌ |
```

### 3. 覆盖度决策

| 覆盖度状态 | 决策 |
|------------|------|
| 高优先级遗漏未补充 | **返回 Phase 5 补充执行** |
| 中优先级遗漏未说明 | 要求验证报告补充风险说明 |
| 覆盖度完整 | 继续功能验证检查 |

## 决策标准（必须严格遵守）

### 验证结果分类

| 分类 | 定义 | 决策 |
|------|------|------|
| **全部通过** | 所有验证项通过，原问题已修复，无新问题引入，覆盖度完整 | 进入 Phase 8 |
| **部分失败** | 原问题已修复，但有边界条件/回归测试失败 | 返回 Phase 5 重新修复 |
| **覆盖度不足** | 高优先级验证项未执行 | 返回 Phase 5 补充执行 |
| **未通过** | 原问题未修复，或引入严重新问题 | 返回 Phase 2 重新分析 |
| **无法判断** | 验证结果不明确，需要更多信息 | 返回 Phase 5 获取更多信息 |

### 决策检查清单（逐项确认）

1. **覆盖度检查**（新增）: 调试计划要求是否全部执行？
   - [ ] 是 → 继续检查
   - [ ] 否 → 检查遗漏项优先级
     - [ ] 有高优先级遗漏 → 返回 Phase 5
     - [ ] 只有中/低优先级遗漏 → 记录并继续

2. **原问题验证**: 原问题是否已修复？
   - [ ] 是 → 继续检查
   - [ ] 否 → 返回 Phase 2

3. **边界条件**: 边界条件验证是否通过？
   - [ ] 是 → 继续检查
   - [ ] 否 → 返回 Phase 5

4. **回归测试**: 原有功能是否正常？
   - [ ] 是 → 继续检查
   - [ ] 否 → 返回 Phase 5

5. **新问题引入**: 是否引入新的严重问题？
   - [ ] 否 → 进入 Phase 8
   - [ ] 是 → 返回 Phase 2

## 最大优化迭代次数

**重要约束**: 整个修复循环（Phase 5 → Phase 6 → Phase 7）的最大迭代次数为 **3 次**。

- 第 1 次迭代: 初始修复
- 第 2 次迭代: 第 1 次修复失败后的修复
- 第 3 次迭代: 第 2 次修复失败后的修复（最后一次）

**迭代计数规则**:
- 每次从 Phase 7 返回 Phase 5 计为 1 次迭代
- 达到 3 次迭代后，无论结果如何，必须进入 Phase 8
- 达到迭代上限时，即使验证未通过也终止循环，并在最终报告中说明

## 迭代计数记录

主代理必须在 `.dvv/issue_fix_flow_progress_log.md` 中记录当前迭代次数：
```
当前修复迭代次数: X / 3
```

## 输出文档

- **结果评审报告**: `.dvv/reports/result_review_{timestamp}.md`

**模板参考**: 阅读 `references/templates/05_result_review.md`

---

# Phase 8: 总结回顾

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| 所有阶段报告 | 分析报告、调试计划、修复记录、验证报告等 |
| 工作流进度日志 | `.dvv/issue_fix_flow_progress_log.md` |
| 工作流定义文件 | `workflow_definition.yaml`（用于审计） |

## 主代理职责

1. **生成最终报告**
   ```
   .dvv/reports/issue_fix_summary_{timestamp}.md
   ```

2. **调用工作流审计技能**
   使用 `project-post-workflow-audit` 技能执行工作流执行效果评估：
   ```markdown
   调用时传递：
   - workflow_definition: <skill-path>/workflow_definition.yaml
   - progress_log: .dvv/issue_fix_flow_progress_log.md
   - reports_dir: .dvv/reports/
   ```

3. **输出最终总结**
   - 问题描述
   - 分析过程
   - 修复内容
   - 验证结果
   - 覆盖度评估
   - 经验教训

---

# 子代理通用要求

## 必须执行的初始动作

每个子代理在开始执行任务时**必须**执行以下操作：

### 1. 加载 CLAUDE.md
```markdown
读取当前工作目录的 CLAUDE.md 文件，了解：
- 项目规范
- 工具使用方式
- 调试约定
```

### 2. 调用 project-memory-saver（如适用）
```markdown
调用 project-memory-saver 技能：
- 获取相关知识索引
- 如有新发现，保存到知识库
```

## 文件输出规范

| 类型 | 输出目录 |
|------|----------|
| 分析报告 | `.dvv/reports/` |
| 调试计划 | `.dvv/plans/` |
| 修复记录 | `.dvv/reports/` |
| 验证报告 | `.dvv/reports/` |
| 参考信息 | `.dvv/others/` |
| 执行日志 | `.dvv/issue_fix_flow_progress_log.md` |

## 知识沉淀要求

每个子代理**结束任务前必须**：
1. 调用 `project-memory-saver` 技能
2. 记录本次执行的重要发现
3. 保存调试/修复经验到知识库

---

# 主代理流程控制

## 流程图

```
Phase 0: 工作区准备 (Subagent W)
    ↓
Phase 1: 获取输入 (主代理)
    ↓
Phase 2: 问题分析 (Subagent A)
    ↓
Phase 3: 计划评审 (Subagent B) ←──┐
    ↓                              │
Phase 4: 计划优化 (Subagent A) ────┘ (循环1-3次)
    ↓
Phase 5: 执行修复 (Subagent C)
    ↓
Phase 6: 验证 (Subagent D)
    ↓
Phase 7: 结果评审 (Subagent B) ←─────────────┐
    ↓                                       │
[覆盖度不足?] → Yes → Phase 5 补充执行        │
    ↓ No                                    │
[需要再次修复?] → Yes → Phase 5 (迭代+1)      │
    │                    ↓                  │
    │              迭代计数检查 → ≤3次? No → │
    │                    ↓ Yes              │
    └─────────────→ Phase 8 ←───────────────┘
    ↓
Phase 8: 总结回顾 + 工作流审计
```

## 主代理任务清单

1. ✅ Phase 0: 调用 `general-purpose` subagent 执行 `project-pre-workflow-audit` 准备工作区
2. ✅ Phase 1-7: 串行调用各子代理
3. ✅ Phase 3/4 循环控制: 最多3轮
4. ✅ Phase 7 循环控制:
   - 每次返回 Phase 5 时迭代计数+1
   - 最大迭代次数: 3次
   - 达到上限后强制进入 Phase 8
5. ✅ Phase 8: 调用 `project-post-workflow-audit` 执行审计

## 迭代计数初始化

在 Phase 0 完成后，主代理必须初始化迭代计数器：
```
.dvv/issue_fix_flow_progress_log.md 中记录：
- 当前修复迭代次数: 0 / 3
```

---

# 使用示例

## 示例1: 完整调试流程

```
用户: 我的 PCIe 仿真在发送 Completion TLP 时出错，请帮我调试
```

**解析**:
- 输入: 用户问题描述
- 工作流: 完整9阶段

**执行**:
- Phase 0: 准备工作区（创建目录结构、执行日志）
- Phase 1: 收集问题详情
- Phase 2: 分析 TLP 编码问题
- Phase 3: 评审调试计划
- Phase 4: 优化计划（如需要）
- Phase 5: 修复代码
- Phase 6: 验证修复 + 计划执行完整性检查
- Phase 7: 评审结果 + 覆盖度验证
- Phase 8: 总结 + 审计

---

## 示例2: 仅执行修复和验证

```
用户: 分析报告已经完成，请直接执行修复
```

**解析**:
- 输入: 现有的分析报告路径
- 工作流: Phase 5-8

---

# 质量保证

## 各阶段验收标准

| 阶段 | 验收标准 |
|------|----------|
| Phase 0 | .dvv 目录结构创建完整，执行日志已创建 |
| Phase 1 | 问题描述文档包含问题描述、期望行为、相关文件 |
| Phase 2 | 分析报告和调试计划已分别输出，包含问题描述、根因分析、执行步骤 |
| Phase 3 | 评审报告包含遗漏检查、改进建议、决策 |
| Phase 4 | 优化后的计划回应了所有评审意见 |
| Phase 5 | 修复记录完整，代码变更已保存，**执行状态追踪表已填写** |
| Phase 6 | 验证报告包含**计划执行完整性检查**、功能验证和回归测试结果 |
| Phase 7 | 评审结论明确，决策清晰，**覆盖度已验证**，迭代计数正确 |
| Phase 8 | 最终报告已生成，工作流审计报告已生成 |

## 工作流完成标准

- 所有阶段执行完成
- 验证通过
- **覆盖度验证通过**（新增）
- 知识已沉淀
- 工作流审计报告已生成

## 迭代次数验收

- 修复迭代次数不超过 3 次
- 达到迭代上限时，最终报告需说明未完全解决的原因

---

# 改进历史

| 版本 | 日期 | 改进内容 |
|------|------|----------|
| v1.3 | 2026-03-16 | 完善 `04_fix_record.md` 模板，添加执行状态追踪表 |
| v1.3 | 2026-03-16 | 分离 Phase 2 输出模板，新增 `01_debug_plan.md` 调试计划模板 |
| v1.3 | 2026-03-16 | 明确 Phase 3/4 迭代控制，更新 `workflow_definition.yaml` |
| v1.3 | 2026-03-16 | 更新 `dvv-checking-agent.md` 添加工作流上下文 |
| v1.3 | 2026-03-16 | 统一文件命名规范：`plan_review_*.md` vs `result_review_*.md` |
| v1.3 | 2026-03-16 | 新增 `05_result_review.md` Phase 7 结果评审模板 |
| v1.2 | 2026-03-16 | 新增 Phase 0 工作区准备阶段，调用 project-pre-workflow-audit 技能 |
| v1.2 | 2026-03-16 | 重新编号所有 Phase（0-8），更新流程图和阶段总览 |
| v1.1 | 2026-03-16 | 新增 Phase 5 执行状态追踪机制 |
| v1.1 | 2026-03-16 | 新增 Phase 6 计划执行完整性检查机制 |
| v1.1 | 2026-03-16 | 新增 Phase 7 覆盖度验证机制 |
| v1.1 | 2026-03-16 | 新增遗漏项决策标准（高/中/低优先级） |
| v1.1 | 2026-03-16 | 新增 `workflow_definition.yaml` 工作流定义文件 |

**v1.2 改进背景**: 工作流执行前需要准备工作区环境，包括创建标准目录结构和执行日志。通过将此步骤标准化为 Phase 0，确保工作流有一个干净的起始环境，同时支持历史文档归档。

---

# 工作流定义文件

技能目录下包含 `workflow_definition.yaml` 文件，定义了：

- **phases**: 9个阶段的输入/输出/成功标准
- **iteration_control**: 迭代控制规则
- **audit_checks**: 审计检查点定义
- **quality_standards**: 质量标准
- **file_conventions**: 文件路径约定

此文件用于 `project-post-workflow-audit` 技能执行结构化的工作流审计。
