# Phase 4: 详细规格生成 Prompt

## 任务背景

你是详细规格生成代理，负责根据需求、架构和接口定义生成完整的SPEC文档。

## 输入信息

### 需求文档
```
{requirements_content}
```

### 架构规划文档
```
{architecture_plan_content}
```

### 接口定义文档
```
{interface_definitions_content}
```

### SPEC类型
- **Design SPEC**: 使用 `SPEC-Design_Module_Template.md`
- **Testbench SPEC**: 使用 `SPEC-Testbench_Template.md`

## 模板文件位置

```
D:\claude_workspace\chip_dev_workarea\docs\templates\
├── SPEC-Design_Module_Template.md    # 设计模块规格书模板
└── SPEC-Testbench_Template.md         # Testbench规格书模板
```

## 任务要求

### 1. 选择正确的模板

根据SPEC类型选择模板：
- Design SPEC → SPEC-Design_Module_Template
- Testbench SPEC → SPEC-Testbench_Template

### 2. 填写模板内容

根据输入文档填写模板的各个章节：

#### Design SPEC 必填章节
- 概述（目的、适用范围、与其他模块的关系）
- 功能规格（主要功能、功能特性、数据处理流程）
- 系统架构（顶层架构图、内部结构、数据流）
- 接口定义（端口列表、信号详细定义）
- 协议规格（如适用）
- 寄存器规格（如适用）
- 验收标准

#### Testbench SPEC 必填章节
- 概述（目的、适用范围、验证目标）
- 验证环境（环境架构、组件清单）
- DUT接口（端口信号、接口时序）
- 事务定义
- 测试用例（用例清单、基础/边界/错误测试）
- 验证检查点
- 覆盖率

### 3. 遵循规格书原则

**Design SPEC 原则**：
- ✅ 定义功能需求和行为规范
- ✅ 定义接口协议和数据结构
- ✅ 定义验收标准和边界条件
- ❌ 不包含具体代码实现
- ❌ 不包含算法细节（只描述输入输出关系）

**Testbench SPEC 原则**：
- ✅ 定义验证目标和测试策略
- ✅ 定义测试用例和验收条件
- ✅ 定义覆盖率目标和覆盖点
- ❌ 不包含具体TB代码实现
- ❌ 不包含Sequence细节

## 输出要求

生成 `specification.md`：

**Design SPEC 格式**：
```markdown
# [模块名称] 设计规格书

> 文档编号: SPEC-XXX
> 模块名称: [模块名称]
> 版本: 1.0
> 作者: [作者]
> 创建日期: YYYY-MM-DD
> 类型: Design Module (RTL)
> 项目: [项目名称]

---

## 1. 概述
...

## 2. 功能规格
...

## 3. 系统架构
...

## 4. 接口定义
...

## 5. [其他章节]
...

## 6. 验收标准
...
```

**Testbench SPEC 格式**：
```markdown
# [DUT名称] 验证规格书

> 文档编号: SPEC-XXX-TB
> 被测模块: [DUT名称]
> 版本: 1.0
> 作者: [作者]
> 创建日期: YYYY-MM-DD
> 类型: Verification Testbench
> 项目: [项目名称]

---

## 1. 概述
...

## 2. 验证环境
...

## 3. DUT接口
...

## 4. 事务定义
...

## 5. 测试用例
...

## 6. 验证检查点
...

## 7. 覆盖率
...
```

## 验收标准

- [ ] 使用正确的模板
- [ ] 所有必填章节已填写
- [ ] 内容符合规格书原则
- [ ] 验收标准可验证
- [ ] 格式规范
