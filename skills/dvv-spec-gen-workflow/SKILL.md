# dvv-spec-gen-workflow

> **Skill Name**: dvv-spec-gen-workflow
> **Version**: 1.0
> **Created**: 2026-03-16

## 概述

本工作流用于生成芯片设计/验证的规格说明文档（SPEC）。工作流通过多阶段审查和迭代，确保生成的SPEC满足需求且符合规范。

## 触发条件

当用户请求创建以下文档时触发：
- "创建模块规格书"、"生成SPEC"、"编写设计规格"
- "创建testbench规格书"、"生成TB验证计划"
- "需要设计模块的规格文档"
- "需要验证环境的规格文档"

## 核心原则

### 主代理职责（编排者）
- **只负责编排**：不执行具体代码编写或文档生成任务
- **只负责协调**：不直接做决策，将决策权交给审查代理
- **收集确认**：在phase1收集需求后，必须与用户确认Spec类型

### 决策机制
- 审查代理（phase2.2, 3.2, 5, 6）负责决策是否需要迭代
- 审查结果分为：PASS（通过）、NEEDS_REVISION（需要修改）、FAIL（失败）
- 决策基于审查报告，主代理根据结果决定下一步

### 迭代约束
- phase6（内容审查）最少1轮，最多3轮
- 其他审查阶段为单轮
- 迭代计数器独立计数

---

## 工作流架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 0: 工作区准备                               │
│    spawn project-pre-workflow-audit skill                          │
│    创建 .dvv 目录结构，归档历史文件                                 │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 1: 需求收集                                 │
│    主代理与用户交互，收集需求                                       │
│    明确：Design SPEC vs Testbench SPEC                            │
│    输出：.dvv/inputs/requirements.md                              │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 2: 架构规划                                 │
│                                                                      │
│  Phase 2.1 ─────────────────────────────────────────────            │
│  spawn sv-planner (general-purpose agent)                         │
│  生成系统架构图 + 模块层级结构规划                                   │
│  输出：.dvv/plans/architecture_plan.md                            │
│                                                                      │
│  Phase 2.2 ─────────────────────────────────────────────            │
│  spawn general-purpose agent (审查)                                │
│  审查架构图和层级规划是否满足需求                                   │
│  决策：PASS / NEEDS_REVISION                                       │
│  输出：.dvv/reports/architecture_review.md                        │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 3: 接口定义                                 │
│                                                                      │
│  Phase 3.1 ─────────────────────────────────────────────            │
│  spawn general-purpose agent (生成)                                 │
│  Design SPEC → 生成模块接口定义列表                                 │
│  Testbench SPEC → 生成TB与DUT连接关系列表                          │
│  输出：.dvv/plans/interface_definitions.md                       │
│                                                                      │
│  Phase 3.2 ─────────────────────────────────────────────            │
│  spawn general-purpose agent (审查)                                │
│  审查接口定义是否符合协议/业界标准                                  │
│  决策：PASS / NEEDS_REVISION                                       │
│  输出：.dvv/reports/interface_review.md                          │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 4: 详细规格生成                             │
│    spawn general-purpose agent                                     │
│    基于phase2&3输出，生成详细SPEC                                  │
│    Design SPEC → SPEC-Design_Module_Template                     │
│    Testbench SPEC → SPEC-Testbench_Template                       │
│    输出：.dvv/plans/specification.md                              │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 5: 规格完整性审查                           │
│    spawn general-purpose agent                                    │
│    审查SPEC是否与模板相比有缺失                                     │
│    决策：PASS / NEEDS_REVISION                                     │
│    输出：.dvv/reports/spec_completeness_review.md                │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 6: 规格内容审查                             │
│    spawn general-purpose agent (迭代1-3轮)                        │
│    审查SPEC内容是否满足需求                                         │
│    决策：PASS / NEEDS_REVISION                                     │
│    输出：.dvv/reports/spec_content_review_N.md                   │
│                                                                      │
│    迭代规则：                                                       │
│    - 最少1轮，最多3轮                                               │
│    - NEEDS_REVISION → 返回Phase 4重新生成                          │
│    - PASS → 进入Phase 7                                            │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Phase 7: 总结与归档                              │
│    主代理生成最终总结报告                                           │
│    执行 project-post-workflow-audit skill                         │
│    输出：.dvv/reports/final_summary.md                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 详细说明

### Phase 0: 工作区准备

**执行内容**:
1. 使用 `Skill: project-pre-workflow-audit` 创建工作区
2. 在当前项目目录下创建 `.dvv/` 目录结构：
   ```
   .dvv/
   ├── inputs/          # 需求文档
   ├── plans/           # 规划文档（架构、接口、SPEC）
   ├── reports/         # 审查报告
   ├── others/          # 其他文件
   └── archived/        # 归档目录
   ```
3. 归档本工作流的历史文档（如有）

**输出**: 已创建的工作区目录结构

---

### Phase 1: 需求收集

**执行内容**:
1. 主代理与用户交互，收集以下信息：
   - 项目名称
   - 模块名称/被测模块
   - 功能描述
   - 接口要求
   - 性能目标
   - 约束条件

2. **关键确认**：必须明确用户需要的是：
   - **Design SPEC**（设计规格书）→ 使用 SPEC-Design_Module_Template
   - **Testbench SPEC**（验证规格书）→ 使用 SPEC-Testbench_Template

3. 将需求整理为需求文档

**输出**: `.dvv/inputs/requirements.md`

---

### Phase 2: 架构规划

#### Phase 2.1: 架构生成

**执行内容**:
1. spawn `general-purpose` agent (subagent_type)
2. 传递需求文档内容
3. 要求生成：
   - 系统架构图（ASCII格式）
   - 模块层级结构规划
   - 子模块划分建议

**输出**: `.dvv/plans/architecture_plan.md`

#### Phase 2.2: 架构审查

**执行内容**:
1. spawn `general-purpose` agent 作为审查代理
2. 审查内容：
   - 架构图是否清晰表达系统结构
   - 层级规划是否合理
   - 是否满足需求
3. 决策：
   - **PASS**: 进入Phase 3
   - **NEEDS_REVISION**: 返回Phase 2.1重新生成

**输出**: `.dvv/reports/architecture_review.md`

---

### Phase 3: 接口定义

#### Phase 3.1: 接口生成

**执行内容**:
1. spawn `general-purpose` agent
2. 根据Spec类型生成不同内容：

   **Design SPEC**:
   - 模块端口定义列表
   - 信号名称、方向、位宽
   - 协议接口定义（如AXI/APB/PCIe等）

   **Testbench SPEC**:
   - TB与DUT的连接关系列表
   - 事务类型定义
   - 接口时序要求

**输出**: `.dvv/plans/interface_definitions.md`

#### Phase 3.2: 接口审查

**执行内容**:
1. spawn `general-purpose` agent 作为审查代理
2. 审查内容：
   - 接口定义是否符合协议标准
   - 位宽和方向是否正确
   - 命名是否规范
3. 决策：
   - **PASS**: 进入Phase 4
   - **NEEDS_REVISION**: 返回Phase 3.1重新生成

**输出**: `.dvv/reports/interface_review.md`

---

### Phase 4: 详细规格生成

**执行内容**:
1. spawn `general-purpose` agent
2. 传递：
   - 需求文档 `.dvv/inputs/requirements.md`
   - 架构规划 `.dvv/plans/architecture_plan.md`
   - 接口定义 `.dvv/plans/interface_definitions.md`
3. 根据Spec类型选择模板：

   **Design SPEC** → `SPEC-Design_Module_Template.md`:
   - 位置: `docs/templates/SPEC-Design_Module_Template.md`
   - 包含：概述、功能规格、系统架构、接口定义、协议规格、寄存器规格、错误处理、资源估算、验收标准

   **Testbench SPEC** → `SPEC-Testbench_Template.md`:
   - 位置: `docs/templates/SPEC-Testbench_Template.md`
   - 包含：概述、验证环境、DUT接口、事务定义、测试用例、验证检查点、覆盖率

4. 生成完整的SPEC文档

**输出**: `.dvv/plans/specification.md`

---

### Phase 5: 规格完整性审查

**执行内容**:
1. spawn `general-purpose` agent 作为审查代理
2. 审查内容：
   - SPEC是否与模板相比有缺失章节
   - 必要字段是否填写完整
   - 格式是否符合模板规范
3. 决策：
   - **PASS**: 进入Phase 6
   - **NEEDS_REVISION**: 返回Phase 4重新生成

**输出**: `.dvv/reports/spec_completeness_review.md`

---

### Phase 6: 规格内容审查（迭代）

**执行内容**:
1. spawn `general-purpose` agent 作为审查代理
2. 审查内容：
   - SPEC内容是否满足需求
   - 功能描述是否准确
   - 验收标准是否可验证
3. 迭代规则：
   - 第1轮审查：必须执行
   - 2-3轮：如需修改则迭代，否则结束
   - 最多3轮
4. 决策：
   - **PASS**: 进入Phase 7
   - **NEEDS_REVISION**: 返回Phase 4重新生成，迭代计数+1
   - **FAIL**（3轮后仍失败）: 报告给用户

**输出**: `.dvv/reports/spec_content_review_N.md` (N=1,2,3)

---

### Phase 7: 总结与归档

**执行内容**:
1. 主代理生成最终总结报告，包含：
   - 工作流执行概述
   - 各Phase执行结果
   - 生成的SPEC文档路径
   - 经验教训（如有）

2. 执行 `Skill: project-post-workflow-audit`
   - 创建工作流执行日志
   - 归档最终文档

**输出**:
- `.dvv/reports/final_summary.md`
- 工作流执行日志

---

## 模板文件位置

```
D:\claude_workspace\chip_dev_workarea\docs\templates\
├── SPEC-Design_Module_Template.md    # 设计模块规格书模板
├── SPEC-Testbench_Template.md         # Testbench规格书模板
├── IMPLEM-Design_Module_Template.md   # 设计实现模板
├── IMPLEM-Testbench_Template.md       # TB实现模板
├── REVIEW-Template.md                 # 评审模板
└── ...
```

---

## 输出格式规范

### GATEFLOW-RETURN 块（审查决策）

```
---GATEFLOW-RETURN---
STATUS: PASS|NEEDS_REVISION|FAIL
PHASE: [phase名称]
ITERATION: [当前迭代次数]
DECISION: [决策说明]
OUTPUT_FILE: [输出文件路径]
NOTES: [备注]
---END-GATEFLOW-RETURN---
```

### 审查报告结构

```markdown
# [审查类型] 报告

## 审查信息
- 审查阶段: [Phase X]
- 审查日期: YYYY-MM-DD
- 迭代次数: N

## 审查结果
- 决策: PASS / NEEDS_REVISION / FAIL

## 审查发现
### 通过项
- [通过项列表]

### 需要修改项（如有）
- [问题1]: [描述] → [建议]

## 建议
[修改建议或通过说明]
```

---

## 关键约束

1. **主代理不决策**：所有决策由审查代理完成
2. **主代理不执行具体任务**：代码和文档生成由子代理完成
3. **迭代上限**：phase6最多3轮迭代
4. **工作区位置**：`.dvv` 在当前项目工作目录
5. **模板使用**：必须使用项目模板目录中的模板

---

## 经验注入

在spawn子代理时，应根据任务类型注入相关经验：

| 任务类型 | 注入经验 |
|----------|----------|
| 架构规划 | 项目CLAUDE.md、相关workflow文档 |
| 接口定义 | 协议文档、接口标准文档 |
| Design SPEC | SystemVerilog开发经验 |
| Testbench SPEC | Testbench最佳实践 |
| 审查 | 历史审查报告、常见问题列表 |

---

## 验收清单

### Phase 0
- [ ] `.dvv/` 目录结构已创建
- [ ] 历史文件已归档

### Phase 1
- [ ] 需求文档已生成
- [ ] SPEC类型已确认（Design/Testbench）

### Phase 2
- [ ] 架构图已生成
- [ ] 架构审查通过

### Phase 3
- [ ] 接口定义已生成
- [ ] 接口审查通过

### Phase 4
- [ ] SPEC文档已生成

### Phase 5
- [ ] 完整性审查通过

### Phase 6
- [ ] 内容审查通过（至少1轮，最多3轮）

### Phase 7
- [ ] 最终总结已生成
- [ ] 工作流执行日志已创建
