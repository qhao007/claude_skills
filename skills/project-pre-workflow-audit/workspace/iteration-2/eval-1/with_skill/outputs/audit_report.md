# 工作流环境准备审计报告

> **执行时间**: 2026-03-16 10:54:00
> **工作流**: pcie_debug_flow
> **状态**: 完成

---

## 1. 执行摘要

成功为 `pcie_debug_flow` 工作流准备了执行环境。

## 2. 创建的目录结构

```
.dvv/
├── inputs/           # 输入文档（问题报告、需求文档等）
├── plans/            # 执行计划文档
├── others/           # 其他中间文档
├── reports/          # 输出报告
├── archived/         # 历史运行归档
└── pcie_debug_flow_progress_log.md  # 当前执行日志
```

## 3. 创建的文件

| 文件 | 路径 | 说明 |
|------|------|------|
| 执行日志 | `.dvv/pcie_debug_flow_progress_log.md` | 工作流执行进度追踪 |

## 4. 归档历史运行

- 本次为首次运行，无历史文档需要归档

## 5. 验证结果

- [x] .dvv 目录创建在正确位置（工作目录根目录）
- [x] 所有子目录创建成功
- [x] 执行日志文件创建成功
- [x] 目录结构符合标准规范

## 6. 下一步操作建议

1. **Step 0**: 询问用户具体问题（根据 pcie_debug_flow skill）
   - 请描述具体的问题现象？
   - 是什么时候发现的？
   - 有什么错误信息或日志吗？
   - 期望的行为是什么，实际发生了什么？

2. **Step 1**: 问题分类
3. **Step 2**: 信息收集（优先使用 MCP 工具）
4. **Step 3**: sv-debug 根因分析
5. **Step 4**: sv-refactor 修复执行
6. **Step 5**: 验证修复
7. **Step 6**: 经验沉淀

## 7. 重要提醒

### 调试第一原则
在任何调试开始前，必须先验证时钟和复位信号！

### 子代理调用规范
调试必须使用子代理串行执行：
```
sv-debug (分析) -> sv-refactor (修复) -> gf-lint (验证) -> gf-sim (验证)
```

### MCP 工具优先
优先使用 questasim-selfcrosslink MCP 工具：
- `questasim_analyze_log` - 日志分析
- `questasim_run_simulation` - 运行仿真
- `questasim_search_vcd_signal` - VCD信号搜索
