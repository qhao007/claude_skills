# 工作流执行日志: pcie_debug_flow

> **创建时间**: 2026-03-16 10:38:00
> **执行代理**: Claude Agent
> **状态**: 进行中

---

## 执行目标

执行 Self-Crosslink PCIE 项目专用调试流程。该工作流强制执行调试必须遵守的开发流程：先检查时钟复位 -> 分析Warning -> 定位根因 -> 修复 -> 验证 -> 经验沉淀。

---

## 执行记录

### Step 0: 环境准备
- **时间**: 2026-03-16 10:38:00
- **执行者**: Claude Agent
- **目标**: 创建工作流执行目录和日志文件
- **做了什么**:
  - 创建 `.dvv/` 目录结构 (inputs/plans/others/reports/archived)
  - 创建工作流执行日志文件
- **结果**: 成功创建执行环境
- **输出文件**:
  - `.dvv/pcie_debug_flow_progress_log.md`
  - `.dvv/inputs/`
  - `.dvv/plans/`
  - `.dvv/others/`
  - `.dvv/reports/`
  - `.dvv/archived/`
- **遗留问题**: 无
- **注意事项**: 后续步骤需要更新此日志

---

## 当前状态

- 进度: 0/6 步骤
- 上一步: 环境准备
- 下一步: Step 1 - 问题分类

---

## 信息同步区

### 项目上下文
| 项目 | 路径 |
|------|------|
| 项目名称 | Self-Crosslink PCIE 仿真验证 |
| 项目路径 | `D:\claude_workspace\chip_dev_workarea\projects\self_crosslink` |
| 仿真工具 | QuestaSim 2024.1 |
| DUT 特性 | 预编译库（无源码访问） |

### 工作流核心原则
1. **调试第一原则**: 在任何调试开始前，必须先验证时钟和复位信号
2. **子代理调用规范**: sv-debug -> sv-refactor -> gf-lint -> gf-sim (串行执行)
3. **经验驱动原则**: 调试前后注入/更新 lessons.md
