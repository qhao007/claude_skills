---
name: dvv-code-quality-review-workflow
description: |
  代码质量审查工作流。用于对芯片设计/验证代码进行系统性质量审查，包括Spec合规性检查、代码风格检查、RTL设计最佳实践检查、Testbench最佳实践检查。

  适用场景：
  - 对 RTL 模块进行代码质量审查
  - 对 Testbench 进行最佳实践检查
  - 验证代码实现是否符合 Spec 规范

  工作流包括7个阶段：工作区准备 → 需求收集(需用户确认) → Spec完整性检查 → Spec合规性审查(并行) → 经验教训检查(并行) → 代码质量审查(并行) → 完备性检查 → 结果总结。

  触发方式：用户提到"代码质量审查"、"code quality review"、"执行代码审查工作流"、"代码规范检查"时使用此技能。
---

# DVV Code Quality Review Workflow - 代码质量审查工作流

> **提示**: 报告模板见 `references/templates/` 目录

## 概述

代码质量审查工作流通过7个阶段完成系统性的代码质量审查。

> **核心原则**: 主代理只控制/编排流程，不做决策，不执行具体任务。所有任务/决策通过子代理执行。
> **例外**: Phase 1 (需求收集) 和 Phase 7 (结果总结) 为主代理执行，负责与用户交互。

---

## 阶段总览

| 阶段 | 执行方式 | 子代理 | 职责 | 输出 |
|------|----------|--------|------|------|
| 0 | Subagent W | general-purpose | 准备工作区，创建目录结构和执行日志 | .dvv 目录结构 + 执行日志 |
| 1 | 主代理 | - | 收集需求，确认审查目标，**用户确认** | 需求文档 |
| 2 | Subagent A | general-purpose | Spec 完整性检查 | Spec 完整性报告 |
| 3 | Subagent B(s) | dvv-code-review-agent (并行) | Spec 合规性审查，每个模块一个子代理 | Spec 合规报告 |
| 4 | Subagent C(s) | general-purpose (并行) | **经验教训检查**，加载历史经验防止重复犯错 | 经验教训检查报告 |
| 5 | Subagent B(s) | dvv-code-review-agent (并行) | 代码质量审查，每个模块一个子代理 | 质量审查报告 |
| 6 | Subagent A | general-purpose | 完备性检查 | 完备性检查报告 |
| 7 | 主代理 | - | 汇总报告，**调用后评估** | 最终总结报告 |

---

## 通用必须阅读文档

所有阶段（Phase 0-7）**必须**在开始执行前阅读以下文档：

| 文档 | 说明 | 位置 |
|------|------|------|
| 项目 CLAUDE.md | 当前项目的规范 | `{项目路径}/CLAUDE.md` |
| 工作流进度日志 | 工作流执行进度和状态 | `.dvv/code_quality_review_progress_log.md` |

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
- description: "DVV 代码审查工作区准备"
- prompt: |
  执行 project-pre-workflow-audit 技能，准备工作区：
  1. 工作流名称: code-quality-review
  2. 创建 .dvv 目录结构 (inputs/plans/others/reports/archived)
  3. 创建执行日志 .dvv/code_quality_review_progress_log.md
  4. 归档历史文档（如有）
- max_retries: 2
```

## 必须执行的技能

**project-pre-workflow-audit** - 工作流执行前准备工作

## 输出要求

| 输出 | 路径 | 必须 |
|------|------|------|
| 输入目录 | `.dvv/inputs/` | ✅ |
| 报告目录 | `.dvv/reports/` | ✅ |
| 归档目录 | `.dvv/archived/` | ✅ |
| 执行日志 | `.dvv/code_quality_review_progress_log.md` | ✅ |

---

# Phase 1: 需求收集 (主代理)

## 职责定义

**主代理** - 负责收集审查目标文件和 Spec，确认审查范围，并**必须获取用户确认**。

## 执行步骤

### 1. 确认代码文件位置

1. 检查 `.dvv/codemap/critical-code-file-list.json` 是否存在
2. 如果存在，读取文件获取目标代码列表
3. 如果不存在，询问用户指定目标代码/文件

**重要**: 目标代码列表应来自 codemap 文件中声明的 `files` 数组，不要自行扩展。

### 2. 确认 Spec 位置

对于 codemap 中声明的每个代码文件：
1. 检查是否存在对应的 spec 文件（路径在 `spec_file` 字段）
2. 如果 spec 文件不存在，该模块**无法进行 Spec 合规性审查**
3. 记录可用的 Spec 列表

### 3. 创建需求文档

创建 `.dvv/inputs/review_requirements.md`：

```markdown
# Code Review Requirements

## 目标代码 (来自 codemap)

| ID | 类型 | 文件路径 | Spec 路径 | 状态 |
|----|------|----------|-----------|------|
| 1 | rtl | rtl/module_a.sv | rtl/module_a.spec.md | ✅ 有 Spec |
| 2 | tb | tb/testbench.sv | - | ⚠️ 无 Spec |

## 审查范围

### RTL 模块 (1个)
- dut_status_monitor.sv - 有对应 Spec

### Testbench 文件 (0个)
- 无

## 审查类型

| 模块 | Spec 合规 | 代码质量 | 备注 |
|------|-----------|----------|------|
| dut_status_monitor | ✅ | ✅ | 完整审查 |

## 审查重点
- [ ] Spec 合规性检查
- [ ] 代码风格检查
- [ ] RTL 最佳实践 (always_ff, always_comb, CDC)
- [ ] Testbench 最佳实践
```

### 4. 用户确认 (必须)

**在继续执行之前，必须向用户确认以下内容**：

1. **审查目标确认**：
   - 列出所有待审查的代码文件
   - 明确每个文件的审查类型（仅 RTL / 仅 TB / 两者）

2. **Spec 完整性确认**：
   - 列出有 Spec 的模块
   - 告知无 Spec 的模块将跳过 Spec 合规性审查

3. **审查范围确认**：
   - 是否需要进行 Spec 合规性审查？
   - 是否需要进行代码质量审查？
   - 是否有特定的审查重点？

使用 AskUserQuestion 工具请求用户确认。

### 5. 更新执行日志

记录 Phase 1 执行状态，包括：
- 确认的目标文件列表
- 用户确认状态
- 下一阶段的执行计划

---

# Phase 2: Spec 完整性检查 (Subagent A)

## 职责定义

**Spec 完整性检查工程师** - 验证 Spec 文档是否包含所有必要章节。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 1 需求文档 | `.dvv/inputs/review_requirements.md` |
| Spec 文件 | Phase 1 确认的 spec 文件路径 |

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "general-purpose"
- model: "sonnet"
- description: "DVV Spec 完整性检查"
- max_retries: 2
```

## 检查清单

对于 Phase 1 确认的每个 Spec 文件，检查是否包含：

| 检查项 | 说明 |
|--------|------|
| 接口定义 | 参数配置、输入端口、输出端口 |
| 功能描述 | 主要功能说明 |
| 状态机定义 | Major State 和 Sub State 编码 |
| 时序要求 | 状态转换延迟、复位行为 |
| 测试用例 | 单元测试/集成测试用例 |

## 输出要求

```markdown
# Spec 完整性检查报告

## 检查结果

| Spec 文件 | 接口定义 | 功能描述 | 状态机定义 | 时序要求 | 测试用例 | 总体 |
|-----------|----------|----------|------------|----------|----------|------|
| module_a.spec.md | PASS | PASS | PASS | PASS | PASS | ✅ |
| module_b.spec.md | PASS | FAIL | PASS | - | - | ⚠️ |

## 遗漏清单

- module_b.spec.md: 缺少测试用例章节
```

输出文件: `.dvv/reports/spec_completeness_report.md`

---

# Phase 3: Spec 合规性审查 (Subagent B - 并行)

## 职责定义

**Spec 合规性审查工程师** - 检查代码实现是否符合 Spec 规范。每个模块分配给一个独立的子代理。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 1 需求文档 | `.dvv/inputs/review_requirements.md` |
| Phase 2 Spec 完整性报告 | `.dvv/reports/spec_completeness_report.md` |
| Spec 文件 | 每个模块对应的 spec |
| 代码文件 | 每个模块对应的代码文件 |

## 调用方式

### 并行执行策略

根据模块数量决定执行方式：

**模块数量 ≤ 8**:
- 每个模块启动一个独立的 dvv-code-review-agent
- 并行执行

**模块数量 > 8**:
- 分批执行，每批最多 8 个
- 等待一批完成后再启动下一批

### 子代理调用模板

```markdown
使用 Task 工具启动子代理（每个模块）：
- subagent_type: "dvv-code-review-agent"
- model: "sonnet"
- description: "DVV Spec 合规性审查 - {module_name}"
- max_retries: 2
```

**重要**: 每个子代理只负责**一个**模块的审查，不要在一个子代理中审查多个模块。

## 审查内容

### 1. 端口一致性检查
- RTL 模块端口是否与 Spec 中的接口定义一致
- 参数定义是否匹配

### 2. 功能符合性检查
- 状态转换检测功能是否实现
- 状态名称解码功能是否实现
- Link Up 检测功能是否实现
- 其他 Spec 描述的功能是否实现

### 3. 功能完整性检查
- 是否有 Spec 中描述但未实现的功能
- 是否有额外的未文档化功能

## 输出要求

每个子代理输出独立报告：

| 模块 | 输出文件 |
|------|----------|
| module_a | `.dvv/reports/spec_compliance_module_a.md` |
| module_b | `.dvv/reports/spec_compliance_module_b.md` |

---

# Phase 4: 经验教训检查 (Subagent C - 并行)

## 职责定义

**经验教训检查工程师** - 在审查代码之前，先加载历史经验教训，确保不重复犯以前犯过的错误。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 1 需求文档 | `.dvv/inputs/review_requirements.md` |
| 代码文件 | 每个模块对应的代码文件 |

## 调用方式

### 并行执行策略

根据模块数量决定执行方式：

**模块数量 ≤ 8**:
- 每个模块启动一个独立的 general-purpose 子代理
- 并行执行

**模块数量 > 8**:
- 分批执行，每批最多 8 个
- 等待一批完成后再启动下一批

### 子代理调用模板

```markdown
使用 Task 工具启动子代理（每个模块）：
- subagent_type: "general-purpose"
- model: "sonnet"
- description: "DVV 经验教训检查 - {module_name}"
- max_retries: 2
- prompt: |
  执行以下任务：
  1. 首先使用 Skill 工具加载 project-lesson-loader 技能
  2. 读取代码文件：{module_file_path}
  3. 根据模块类型和代码内容，自动加载相关的历史经验教训
  4. 分析代码中是否存在与历史教训相关的问题模式
  5. 输出经验教训检查报告
```

**重要**: 每个子代理只负责**一个**模块的经验教训检查，不要在一个子代理中检查多个模块。

## 必须执行的技能

**project-lesson-loader** - 加载历史经验教训

## 审查内容

### 1. 自动加载经验教训

子代理需要根据模块特征自动加载相关经验。使用 project-lesson-loader 技能，根据关键字匹配：

| 模块类型 | 搜索关键字 | 相关经验文件 |
|----------|------------|--------------|
| RTL | rtl, verilog, state machine, cdc, always_ff, always_comb | debugging_methodology.md, systemverilog_development.md |
| TB | testbench, uvm, coverage, assertion | testbench_workflow.md, verification_patterns.md |
| PCIe | pcie, tlp, link training, ltssm | pcie_protocol.md |
| 时序 | timing, clock, async, CDC | cdc_analysis.md |
| Lint | lint, warning, error | lint_issues.md, coding_quality.md |

### 2. 经验教训检查清单

基于加载的历史经验教训，检查是否存在以下常见问题模式：

- [ ] **历史 Bug 模式**: 代码中是否存在以前发现过的类似 bug 模式？
- [ ] **危险模式**: 是否使用了已知的危险编码模式？
- [ ] **审查历史**: 该模块在之前的审查中是否被标记过有问题？
- [ ] **最佳实践**: 是否应用了之前总结的最佳实践？
- [ ] **常见错误**: 是否存在项目特定经验中记录的常见错误？

### 3. 输出格式

```markdown
# 经验教训检查报告 - {module_name}

## 加载的经验教训

| 经验来源 | 关键字匹配 | 相关内容摘要 |
|----------|------------|--------------|
| debugging_methodology.md | CDC, clock domain | 跨时钟域同步必须使用 2 级触发器 |
| pcie_protocol.md | Link training | LTSSM 状态转换必须满足时序要求 |

## 检查结果

### 潜在问题

| 问题类型 | 严重程度 | 描述 | 建议 |
|----------|----------|------|------|
| 历史Bug模式 | High | 检测到异步信号跨时钟域，未见同步器 | 添加 2 级同步器 |
| 危险模式 | Medium | 使用阻塞赋值于时序逻辑 | 改用非阻塞赋值 |

### 通过的检查

- [x] 状态机编码符合规范
- [x] 接口定义完整
- [x] 注释规范完整

## 结论

**需要关注**: 2 个问题
**已应用最佳实践**: 3 项
```

## 输出要求

每个子代理输出独立报告：

| 模块 | 输出文件 |
|------|----------|
| module_a | `.dvv/reports/lessons_learned_module_a.md` |
| module_b | `.dvv/reports/lessons_learned_module_b.md` |

---

# Phase 5: 代码质量审查 (Subagent B - 并行)

## 职责定义

**代码质量审查工程师** - 检查代码风格和最佳实践。每个模块分配给一个独立的子代理。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 1 需求文档 | `.dvv/inputs/review_requirements.md` |
| 代码文件 | 每个模块对应的代码文件 |

## 调用方式

### 并行执行策略

与 Phase 3 相同：根据模块数量并行执行。

### 子代理调用模板

```markdown
使用 Task 工具启动子代理（每个模块）：
- subagent_type: "dvv-code-review-agent"
- model: "sonnet"
- description: "DVV 代码质量审查 - {module_name}"
- max_retries: 2
```

**重要**: 每个子代理只负责**一个**模块的审查，不要在一个子代理中审查多个模块。

## 审查内容

### 1. RTL 模块审查

使用 `references/rtl_bestpractice_checklist.md` 检查：

| 检查项 | 说明 |
|--------|------|
| always_ff 使用 | 时序逻辑必须使用 always_ff |
| always_comb 使用 | 组合逻辑必须使用 always_comb |
| 阻塞/非阻塞赋值 | 正确使用阻塞(=)和非阻塞(<=)赋值 |
| CDC 处理 | 异步信号同步、时钟域交叉 |
| 状态机编码 | 状态机编码方式 (binary, one-hot, gray) |
| 命名规范 | 信号、模块、参数命名规范 |
| 注释规范 | 代码注释完整性 |

### 2. Testbench 模块审查

使用 `references/tb_bestpractice_checklist.md` 检查：

| 检查项 | 说明 |
|--------|------|
| 分层架构 | 是否采用分层测试架构 |
| Transaction 设计 | Transaction 类设计合理性 |
| 覆盖率 | 是否有覆盖率收集 |
| 随机化约束 | 约束是否合理 |
| 断言使用 | 是否使用断言 |

## 输出要求

每个子代理输出独立报告：

| 模块 | 输出文件 |
|------|----------|
| module_a | `.dvv/reports/quality_review_module_a.md` |
| module_b | `.dvv/reports/quality_review_module_b.md` |

---

# Phase 6: 完备性检查 (Subagent A)

## 职责定义

**完备性检查工程师** - 确认所有模块和 checklist 均已覆盖。

## 必须阅读的输入文档

| 文档 | 说明 |
|------|------|
| Phase 1 需求文档 | `.dvv/inputs/review_requirements.md` |
| Phase 2 Spec 完整性报告 | `.dvv/reports/spec_completeness_report.md` |
| Phase 3 Spec 合规报告 | `.dvv/reports/spec_compliance_*.md` |
| Phase 4 经验教训检查报告 | `.dvv/reports/lessons_learned_*.md` |
| Phase 5 质量审查报告 | `.dvv/reports/quality_review_*.md` |

## 调用方式

```markdown
使用 Task 工具启动子代理：
- subagent_type: "general-purpose"
- model: "sonnet"
- description: "DVV 完备性检查"
- max_retries: 2
```

## 检查清单

### 1. 模块覆盖率检查
- 对比 Phase 1 确认的模块列表
- 确认每个模块都有 Phase 3、Phase 4 和 Phase 5 报告
- 识别漏检模块

### 2. Checklist 覆盖率检查
- RTL: always_ff, always_comb, 阻塞/非阻塞赋值, CDC, 状态机
- TB: 分层架构, 覆盖率, 断言

### 3. 决策
- 如果有遗漏，记录并报告
- 最多迭代 3 轮

## 输出要求

输出文件: `.dvv/reports/completeness_check.md`

---

# Phase 7: 结果总结 (主代理)

## 职责定义

**主代理** - 汇总所有报告，生成最终总结，并调用工作流后评估。

## 执行步骤

### 1. 汇总所有报告

1. 统计发现的问题数量
2. 按严重程度分类 (High/Medium/Low)
3. 按模块分类

### 2. 生成最终总结报告

```markdown
# 代码质量审查 - 最终总结报告

## 执行摘要

| 阶段 | 状态 | 结果 |
|------|------|------|
| Phase 0: 工作区准备 | ✅ 完成 | |
| Phase 1: 需求收集 | ✅ 完成 | 用户已确认 |
| Phase 2: Spec完整性检查 | ✅ 通过 | |
| Phase 3: Spec合规性审查 | ✅ 完成 | N个模块 |
| Phase 4: 经验教训检查 | ✅ 完成 | N个模块 |
| Phase 5: 代码质量审查 | ✅ 完成 | N个模块 |
| Phase 6: 完备性检查 | ✅ 通过 | |
| Phase 7: 结果总结 | ✅ 完成 | |

## 审查结果汇总

### Spec 合规性

| 模块 | 合规率 | 结果 |
|------|--------|------|
| module_a | 100% | ✅ PASS |
| module_b | 95% | ⚠️ 建议改进 |

### 代码质量

| 模块 | 评分 | 主要问题 |
|------|------|----------|
| module_a | 95/100 | 建议添加 CDC 同步 |
| module_b | 85/100 | 缺少覆盖率收集 |

## 问题列表

### 高优先级
1. [问题描述]

### 中优先级
1. [问题描述]

### 低优先级
1. [问题描述]

## 最终评估

| 指标 | 结果 |
|------|------|
| 代码质量评分 | X/100 |
| Spec 合规率 | X% |
| 模块覆盖率 | X% |

**结论**: [结论描述]
```

### 3. 调用工作流后评估

```markdown
Task: 执行代码质量审查工作流的后评估
Workflow name: code-quality-review
```

使用 Skill 工具调用 `project-post-workflow-audit` 技能。

---

## 输出文件结构

```
.dvv/
├── inputs/
│   └── review_requirements.md          # Phase 1 输出
├── reports/
│   ├── spec_completeness_report.md     # Phase 2 输出
│   ├── spec_compliance_{module}.md    # Phase 3 输出 (每个模块)
│   ├── lessons_learned_{module}.md    # Phase 4 输出 (每个模块)
│   ├── quality_review_{module}.md     # Phase 5 输出 (每个模块)
│   ├── completeness_check.md           # Phase 6 输出
│   └── final_summary.md                # Phase 7 输出
├── archived/                           # Phase 0 归档
└── code_quality_review_progress_log.md # 执行日志
```

---

## 关键约束

1. **并行限制**: Phase 3、Phase 4 和 Phase 5 最多 8 个并行 subagent
2. **迭代限制**: Phase 6 最多 3 轮迭代
3. **子代理类型**: 必须使用 `dvv-code-review-agent` 进行代码审查
4. **工作区位置**: `.dvv` 必须在当前项目根目录下
5. **用户确认**: Phase 1 必须获取用户确认后才能继续
6. **单模块原则**: 每个子代理只负责审查一个模块，不要在一个子代理中审查多个模块

---

## 依赖技能

- `project-pre-workflow-audit`: Phase 0 工作区准备
- `project-post-workflow-audit`: Phase 7 后评估
- `dvv-code-review-agent`: Phase 3/5 代码审查子代理
- `project-lesson-loader`: Phase 4 经验教训检查
