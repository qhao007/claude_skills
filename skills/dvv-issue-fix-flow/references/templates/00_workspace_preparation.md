# 工作区准备报告模板

```markdown
# 工作区准备报告

> **日期**: YYYY-MM-DD HH:MM:SS
> **工作流名称**: issue_fix_flow
> **执行代理**: general-purpose subagent

---

## 1. 目录结构创建

### 1.1 创建状态

| 目录 | 路径 | 状态 |
|------|------|------|
| 主目录 | `.dvv/` | ✅ 已创建 / ⏭️ 已存在 |
| 输入目录 | `.dvv/inputs/` | ✅ 已创建 / ⏭️ 已存在 |
| 计划目录 | `.dvv/plans/` | ✅ 已创建 / ⏭️ 已存在 |
| 报告目录 | `.dvv/reports/` | ✅ 已创建 / ⏭️ 已存在 |
| 其他目录 | `.dvv/others/` | ✅ 已创建 / ⏭️ 已存在 |
| 归档目录 | `.dvv/archived/` | ✅ 已创建 / ⏭️ 已存在 |

### 1.2 目录位置验证

```
当前工作目录: [pwd 输出]
.dvv 目录位置: [确认在项目根目录]
```

---

## 2. 历史文档归档

### 2.1 归档信息

| 项目 | 状态 |
|------|------|
| 是否存在历史运行 | 是 / 否 |
| 归档时间戳 | YYYYMMDD_HHMMSS |
| 归档目录 | `.dvv/archived/issue_fix_flow/{timestamp}/` |

### 2.2 归档文件列表

| 文件类型 | 归档路径 |
|----------|----------|
| 执行日志 | `.dvv/archived/issue_fix_flow/{timestamp}/issue_fix_flow_progress_log.md` |
| 输入文档 | `.dvv/archived/issue_fix_flow/{timestamp}/inputs/` |
| 计划文档 | `.dvv/archived/issue_fix_flow/{timestamp}/plans/` |
| 报告文档 | `.dvv/archived/issue_fix_flow/{timestamp}/reports/` |

---

## 3. 执行日志创建

### 3.1 日志文件

- **路径**: `.dvv/issue_fix_flow_progress_log.md`
- **状态**: ✅ 已创建

### 3.2 日志初始内容

```markdown
# 工作流执行日志: issue_fix_flow

> **创建时间**: YYYY-MM-DD HH:MM:SS
> **执行代理**: main_agent
> **状态**: 进行中

---

## 执行目标

[待填写：此工作流的执行目标]

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

---

## 4. 验证检查

### 4.1 目录结构验证

```bash
ls -la .dvv/
```

输出：
```
[粘贴 ls -la .dvv/ 的输出]
```

### 4.2 日志文件验证

```bash
ls -la .dvv/issue_fix_flow_progress_log.md
```

输出：
```
[粘贴验证输出]
```

---

## 5. 准备就绪确认

- [ ] .dvv 目录结构创建完整
- [ ] 执行日志已创建
- [ ] 历史文档已归档（如有）
- [ ] 当前修复迭代次数已初始化为 0

**工作区已准备就绪，可以开始 Phase 1。**
```

---

## 执行检查清单

在执行 Phase 0 时，必须逐项确认以下检查点：

### 目录创建检查
- [ ] 确认当前工作目录正确
- [ ] 创建 `.dvv/` 目录
- [ ] 创建 `.dvv/inputs/` 子目录
- [ ] 创建 `.dvv/plans/` 子目录
- [ ] 创建 `.dvv/others/` 子目录
- [ ] 创建 `.dvv/reports/` 子目录
- [ ] 创建 `.dvv/archived/` 子目录
- [ ] 验证目录位置正确（不在 outputs/ 等子目录下）

### 历史归档检查（如有历史运行）
- [ ] 检查是否存在历史执行日志
- [ ] 创建归档目录 `.dvv/archived/issue_fix_flow/{timestamp}/`
- [ ] 移动历史日志到归档目录
- [ ] 移动历史输入文档到归档目录
- [ ] 移动历史计划文档到归档目录
- [ ] 移动历史报告文档到归档目录

### 日志创建检查
- [ ] 创建执行日志文件
- [ ] 填写创建时间和执行代理信息
- [ ] 初始化迭代计数器为 0
- [ ] 设置初始状态为"进行中"
- [ ] 设置进度为"0/9 阶段"

### 最终验证
- [ ] 验证 `.dvv/` 目录存在
- [ ] 验证所有子目录存在
- [ ] 验证执行日志文件存在
- [ ] 验证执行日志内容正确
