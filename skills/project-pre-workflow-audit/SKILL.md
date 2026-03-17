---
name: project-pre-workflow-audit
description: |
  工作流执行前的准备工作 - 创建工作流目录结构和执行日志，归档历史文档。

  当用户开始执行一个多步骤工作流时，使用此技能作为第一步。它会：
  1. 创建 .dvv 目录及标准子目录结构（inputs/plans/others/reports/archived）
  2. 创建工作流执行日志 {workflow}_progress_log.md
  3. 归档该工作流的历史文档到 .dvv/archived/{workflow}/{timestamp}/

  触发场景：用户说"开始执行xxx工作流"、"创建工作流日志"、"我要运行xxx流程"等。
---

# 工作流执行日志准备

此技能在工作流执行开始时创建执行日志和目录结构，用于在多个子代理/步骤之间同步信息。

## ⚠️ 重要提示

**所有 .dvv 相关文件必须创建在当前工作目录的根目录下，而非 outputs/ 或其他子目录。**

```
正确:  .dvv/xxx_progress_log.md
错误:  outputs/.dvv/xxx_progress_log.md
错误:  outputs/xxx_progress_log.md
```

## 输入参数

用户应提供：
- **工作流名称**：用于生成日志文件名（如 `pcie_debug_flow` → `pcie_debug_flow_progress_log.md`）

## 目录结构标准

工作流执行期间，`.dvv` 目录结构如下：

```
.dvv/
├── inputs/           # 输入文档（问题报告、需求文档等）
├── plans/            # 执行计划文档
├── others/           # 其他中间文档
├── reports/          # 输出报告
├── archived/         # 历史运行归档
│   └── {workflow}/   # 按工作流名称分组
│       └── {timestamp}/
│           ├── inputs/
│           ├── plans/
│           ├── others/
│           ├── reports/
│           └── {workflow}_progress_log.md
└── {workflow}_progress_log.md  # 当前执行日志
```

## 执行步骤

### 1. 确认工作目录

首先确认当前工作目录，并在此目录下创建 `.dvv` 结构：

```bash
# 打印当前工作目录确认
pwd

# 创建主目录和标准子目录（必须在当前目录根下）
mkdir -p .dvv/inputs
mkdir -p .dvv/plans
mkdir -p .dvv/others
mkdir -p .dvv/reports
mkdir -p .dvv/archived
```

**验证步骤**：创建后立即验证目录位置：

```bash
# 验证 .dvv 目录存在于正确位置
ls -la .dvv/
```

### 2. 归档历史文档

如果该工作流已有历史运行，将相关文档归档：

1. **读取现有 progress_log**: 首先读取现有的 `.{workflow}_progress_log.md` 文件内容
2. **提取文件引用**: 从 progress_log 中提取所有"输出文件"、"输入文件"、"引用文件"等字段记录的文件路径
3. **确定时间戳**: `YYYYMMDD_HHMMSS` 格式
4. **创建归档目录**: `.dvv/archived/{workflow}/{timestamp}/`
5. **智能归档文件**:
   - progress_log 中记录的所有文件
   - progress_log 本身

#### 2.1 提取文件引用列表

从 progress_log.md 中使用正则表达式提取文件路径：

```bash
# 提取输出文件字段中的文件路径
# 匹配模式: - **输出文件**: path/to/file.md
grep -E '\*\*输出文件\*\*:' .dvv/{workflow}_progress_log.md | sed 's/.*: //' | tr ',' '\n' | sed 's/^ *//;s/ *$//'

# 提取输入文件字段中的文件路径
grep -E '\*\*输入文件\*\*:' .dvv/{workflow}_progress_log.md | sed 's/.*: //' | tr ',' '\n' | sed 's/^ *//;s/ *$//'

# 提取引用文件字段中的文件路径
grep -E '\*\*引用文件\*\*:' .dvv/{workflow}_progress_log.md | sed 's/.*: //' | tr ',' '\n' | sed 's/^ *//;s/ *$//'
```

#### 2.2 执行智能归档

```bash
# 示例：归档 pcie_debug_flow 的历史文档
workflow="pcie_debug_flow"
timestamp=$(date +%Y%m%d_%H%M%S)
archive_dir=".dvv/archived/${workflow}/${timestamp}"

# 创建归档目录结构（与主目录一致）
mkdir -p "${archive_dir}/inputs" "${archive_dir}/plans" "${archive_dir}/others" "${archive_dir}/reports"

# 读取现有的 progress_log
if [ -f ".dvv/${workflow}_progress_log.md" ]; then
    # 提取所有文件引用并归档
    # 输出文件
    grep -E '\*\*输出文件\*\*:' ".dvv/${workflow}_progress_log.md" | sed 's/.*: //' | tr ',' '\n' | sed 's/^ *//;s/ *$//' | while read -r file; do
        if [ -f "$file" ]; then
            # 根据文件类型移动到对应目录
            case "$file" in
                inputs/*) cp "$file" "${archive_dir}/inputs/" 2>/dev/null || true ;;
                plans/*) cp "$file" "${archive_dir}/plans/" 2>/dev/null || true ;;
                reports/*) cp "$file" "${archive_dir}/reports/" 2>/dev/null || true ;;
                others/*) cp "$file" "${archive_dir}/others/" 2>/dev/null || true ;;
                *) cp "$file" "${archive_dir}/" 2>/dev/null || true ;;
            esac
        fi
    done

    # 输入文件
    grep -E '\*\*输入文件\*\*:' ".dvv/${workflow}_progress_log.md" | sed 's/.*: //' | tr ',' '\n' | sed 's/^ *//;s/ *$//' | while read -r file; do
        if [ -f "$file" ]; then
            case "$file" in
                inputs/*) cp "$file" "${archive_dir}/inputs/" 2>/dev/null || true ;;
                *) cp "$file" "${archive_dir}/inputs/" 2>/dev/null || true ;;
            esac
        fi
    done

    # 移动 progress_log 本身
    cp ".dvv/${workflow}_progress_log.md" "${archive_dir}/"
fi
```

#### 2.3 备用归档策略（如果无法读取 progress_log）

如果 progress_log 不存在或无法解析，则使用传统方式归档所有非空目录：

```bash
# 备用：归档所有目录下的文件
[ "$(ls -A .dvv/inputs 2>/dev/null)" ] && mv .dvv/inputs/* "${archive_dir}/inputs/" 2>/dev/null
[ "$(ls -A .dvv/plans 2>/dev/null)" ] && mv .dvv/plans/* "${archive_dir}/plans/" 2>/dev/null
[ "$(ls -A .dvv/others 2>/dev/null)" ] && mv .dvv/others/* "${archive_dir}/others/" 2>/dev/null
[ "$(ls -A .dvv/reports 2>/dev/null)" ] && mv .dvv/reports/* "${archive_dir}/reports/" 2>/dev/null

# 移动日志文件
[ -f ".dvv/${workflow}_progress_log.md" ] && mv ".dvv/${workflow}_progress_log.md" "${archive_dir}/"
```

**注意**: 优先使用智能归档（根据 progress_log 内容），只有在其无法执行时才使用备用策略。

### 3. 创建新日志

创建 `{workflow}_progress_log.md`，包含以下结构：

```markdown
# 工作流执行日志: {workflow}

> **创建时间**: YYYY-MM-DD HH:MM:SS
> **执行代理**: {agent_name/ID}
> **状态**: 进行中

---

## 执行目标

[描述此工作流的执行目标]

---

## 执行记录

### Step 1: [步骤名称]
- **时间**: YYYY-MM-DD HH:MM:SS
- **执行者**: [代理名称]
- **目标**: [此步骤的目标]
- **做了什么**: [具体操作]
- **结果**: [执行结果]
- **输入文件**: [此步骤使用的输入文件路径，用逗号分隔，可选]
- **输出文件**: [此步骤生成的输出文件路径，用逗号分隔]
- **引用文件**: [此步骤引用的参考文件路径，用逗号分隔，可选]
- **遗留问题**: [如有]
- **注意事项**: [如需提醒后续代理注意的问题]

**重要**: 每个步骤都必须填写"输出文件"字段，这是归档功能能正确识别文件的唯一依据。

---

## 当前状态

- 进度: X/Y 步骤
- 上一步: [上一步骤名称]
- 下一步: [待执行步骤]

---

## 信息同步区

[用于在步骤之间传递上下文信息]
```

### 4. 验证与确认

执行验证检查，确保所有文件都在正确位置：

```bash
# 验证目录结构
ls -la .dvv/

# 验证日志文件存在
ls -la .dvv/{workflow}_progress_log.md
```

向用户确认：
- 目录结构创建状态（列出已创建的目录）
- 日志文件位置：`.dvv/{workflow}_progress_log.md`
- 归档的历史运行（如果有）：`.dvv/archived/{workflow}/{timestamp}/`
- 提醒用户后续步骤应该更新此日志

## 输出

- 创建的目录结构
- 日志文件路径
- 归档信息（如果有）
- 下一步操作建议
