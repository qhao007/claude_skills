---
name: excel-to-tracker-csv
description: 将Excel验证跟踪表转换为Tracker系统可导入的CSV格式。适用于用户说"转换Excel到Tracker"、"生成tracker csv"、"把数据导入tracker"等场景。自动处理数据清洗、字段映射、编码修复等。
---

# Excel to Tracker CSV 转换技能

## 概述

将芯片验证的Excel跟踪表（如EX1_ValChar_Tracker.xlsx）转换为Tracker系统可导入的CSV格式。

## 输入

- Excel文件路径（如 `D:/claude_workspace/tracker_project_summary/EX1_ValChar_Tracker.xlsx`）
- 工作表名称（通常为 `Coverage-EX1` 或类似名称）

## 输出

- Tracker兼容的CSV文件（保存为 `<原文件名>_CP.csv`）

## 执行步骤

### 步骤1：读取Excel数据

使用Excel MCP工具读取数据：
```bash
mcp__excel-mcp__get_workbook_metadata  # 获取工作表列表
mcp__excel-mcp__read_data_from_excel  # 读取数据
```

需要读取的典型字段：
- Category_Name (B列) → feature
- Block_Name (C列) → sub_feature
- Feature_Name (D列) → cover_point
- Status_P3 (E列) → **无法迁移**（Tracker CP无状态字段）
- Validation Owner (H列) → cover_point_details
- Validation Site (I列) → cover_point_details
- Performance feature (G列) → cover_point_details
- comment (Bug) (J列) → comments
- BringUp Items (N列) → priority (yes→P0, 其他→P1)

### 步骤2：数据清洗

#### 2.1 过滤无效行
- 跳过 Category_Name 为空且 Feature_Name 为空的行（分组标题行）
- 只保留有效的Cover Point记录

#### 2.2 向下填充（Fill Down）
- 当 Category_Name 为空时，使用**上一行的值**填充
- 当 Block_Name 为空时，使用**上一行的值**填充
- **禁止使用"Unknown"等占位符**

#### 2.3 清理错误值
Excel中的错误值需要清理：
- `#DIV/0!` → 空
- `#REF!` → 空
- `#N/A`, `#VALUE!`, `#NAME?` → 空
- 纯数字 `0` → 空（除非是有效的工号）
- Excel公式（如 `=COUNTIFS`, `=SUM`）→ 空

### 步骤3：编码修复

CSV文件必须使用UTF-8编码，且所有字符必须是有效的ASCII或UTF-8。

#### 3.1 替换Unicode字符
| 原始字符 | Unicode | 替换为 |
|---------|---------|--------|
| ± | U+00B1 | +/- |
| % (全角) | U+FF05 | % |
| → | U+2192 | -> |
| （ | U+FF08 | ( |
| ） | U+FF09 | ) |
| ， | U+FF0C | , |

#### 3.2 清理控制字符
- Tab (\\t) → 空格
- NBSP (不间断空格 U+00A0) → 空格
- 换行符在CSV中需要处理（见步骤4）



#### 3.3 清理Cover Point特殊字符

Cover Point字段**禁止**包含以下特殊字符，否则会导致TC-CP关联导入失败：

| 问题类型 | 示例 | 修复方法 |
|---------|------|---------|
| 前导空格 | ` DELAY_TIMING_TEST` | 去除前导空格 |
| 尾随空格 | `Basic TLP ` | 去除尾随空格 |
| 双空格 | `Recovery  mechanism` | 替换为单空格 |
| 内部换行 | `Test PUDC function:
pre-config` | 替换为`, `（逗号+空格） |

**自动清理规则**：
```python
import re
cp = cp.strip()  # 去除首尾空格
cp = re.sub(r'  +', ' ', cp)  # 替换双空格为单空格
cp = cp.replace('
', ', ')  # 替换内部换行为逗号空格
```

### 步骤4：拆分多行内容

某些cover_point字段包含多个条目（用换行符分隔），需要拆分为多行：

**示例**：
```
Dual Boot Primary error
1. AS header error
2. Start-of-frame identifier error
3. Device ID error
4. config-done frame error
5. CRC check error
```

**拆分为**：
```
Dual Boot Primary error: AS header error
Dual Boot Primary error: Start-of-frame identifier error
Dual Boot Primary error: Device ID error
Dual Boot Primary error: config-done frame error
Dual Boot Primary error: CRC check error
```



#### 3.3 清理Cover Point特殊字符

Cover Point字段**禁止**包含以下特殊字符，否则会导致TC-CP关联导入失败：

| 问题类型 | 示例 | 修复方法 |
|---------|------|---------|
| 前导空格 | ` DELAY_TIMING_TEST` | 去除前导空格 |
| 尾随空格 | `Basic TLP ` | 去除尾随空格 |
| 双空格 | `Recovery  mechanism` | 替换为单空格 |
| 内部换行 | `Test PUDC function:
pre-config` | 替换为`, `（逗号+空格） |

**自动清理规则**：
```python
import re
cp = cp.strip()  # 去除首尾空格
cp = re.sub(r'  +', ' ', cp)  # 替换双空格为单空格
cp = cp.replace('
', ', ')  # 替换内部换行为逗号空格
```

### 步骤4.1：处理重复Cover Points

当导入CSV时，如果出现"Cover Point已存在"的错误，需要对重复项进行重命名：

**处理方式**：
- 根据同名的Sub-Feature添加后缀区分
- 例如：`Reset` (PCIe) 和 `Reset` (APCS) → 重命名为 `Reset (PCIe)` 和 `Reset (APCS)`
- 对于POR模块的trip point：添加(APOR)或(SPOR)后缀

### 步骤5：字段映射

根据Tracker CP数据模型映射字段：

| Excel字段 | Tracker CP字段 | 说明 |
|-----------|---------------|------|
| Category_Name | feature | 直接映射 |
| Block_Name | sub_feature | 直接映射 |
| Feature_Name | cover_point | 直接映射 |
| Validation Owner | cover_point_details | 格式: "Owner: 值" |
| Validation Site | cover_point_details | 格式: "Site: 值"，用分号分隔多个字段 |
| Performance feature | cover_point_details | 值为"yes"时添加 "is performance feature" |
| comment (Bug) | comments | 直接映射 |
| BringUp Items | priority | yes→P0，其他→P1 |

### 步骤6：生成CSV

CSV格式（大写表头）：
```csv
Feature,Sub-Feature,Cover Point,Cover Point Details,Priority,Comments
```

**生成规则**：
- 使用UTF-8编码
- **表头必须大写**（Feature, Sub-Feature, Cover Point等）
- 分号(;)作为多个字段的分隔符
- 逗号(,)作为CSV列分隔符
- 确保无多余空行

### 步骤7：验证

验证生成的CSV：
1. 记录数对比（Excel有效记录数 = CSV行数）
2. 字段映射验证（抽查前10条）
3. 编码验证（无乱码，无非ASCII字符除非是中文字符）
4. 格式验证（CSV结构正确）

## 已知问题与解决方案

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 显示"Unknown" | 使用占位符填充空值 | 改用上一行值填充 |
| 乱码 | Excel Unicode字符编码错误 | 替换为ASCII兼容字符 |
| 换行符导致多行 | Excel单元格内含换行 | 拆分为多行或清理 |
| 数据不一致 | Excel公式错误值未清理 | 识别并替换错误值 |

## 项目命名规范

- 项目名称应与Excel文件名一致，去掉"Tracker"后缀
- 例如：`EX1_ValChar_Tracker.xlsx` → 项目名 `EX1_ValChar`
- 命名规则：使用有意义的项目标识符，避免冗余

## 重要安全规则

### 绝对禁止操作
- **禁止删除**服务器上的任何项目数据（无论是否错误）
- 即使项目创建错误或数据有问题，也必须由人类用户手动处理
- 禁止使用DELETE API操作项目资源

### 错误处理
- 如果项目创建错误：记录错误信息，告知用户手动处理
- 如果导入数据有问题：生成修正后的CSV，让用户重新导入
- 不要尝试"修复"已创建的数据，而是创建新的正确数据

## 注意事项

- **禁止**直接使用Linux/Shell命令操作Obsidian仓库
- 使用Excel MCP工具读写Excel文件
- 验证所有Unicode字符已正确转换
- 测试环境端口为8081，生产环境端口为8080
- 导入失败时，检查CSV格式是否正确（特别是表头大写）
