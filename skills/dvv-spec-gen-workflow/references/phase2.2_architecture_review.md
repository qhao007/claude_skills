# Phase 2.2: 架构审查 Prompt

## 任务背景

你是架构审查代理，负责审查生成的架构规划是否满足需求。

## 输入信息

### 需求文档
```
{requirements_content}
```

### 架构规划文档
```
{architecture_plan_content}
```

## 审查要求

### 1. 架构完整性检查

检查架构图是否包含：
- [ ] 所有必要的模块
- [ ] 数据流方向清晰
- [ ] 时钟和复位信号
- [ ] 外部接口

### 2. 层级合理性检查

检查层级结构是否：
- [ ] 划分合理（无过度拆分或过度合并）
- [ ] 模块依赖关系清晰
- [ ] 符合设计原则

### 3. 需求满足度检查

对照需求文档，检查：
- [ ] 所有功能需求都有对应的模块实现
- [ ] 接口要求被满足
- [ ] 性能目标可达

### 4. 潜在问题识别

识别可能的问题：
- 架构设计不合理之处
- 遗漏的功能块
- 接口定义不清晰

## 输出要求

生成审查报告 `architecture_review.md`：

```markdown
# 架构审查报告

## 审查信息
- 审查阶段: Phase 2.2
- 审查日期: YYYY-MM-DD

## 审查结果
- 决策: PASS / NEEDS_REVISION

## 审查发现

### 通过项
- [通过项列表]

### 需要修改项（如有）
| 序号 | 问题 | 描述 | 建议 |
|------|------|------|------|
| 1 | [问题] | [描述] | [建议] |

## 建议
[修改建议或通过说明]

## 决策
---GATEFLOW-RETURN---
STATUS: {PASS|NEEDS_REVISION}
PHASE: phase22_architecture_review
DECISION: {决策说明}
OUTPUT_FILE: .dvv/reports/architecture_review.md
---END-GATEFLOW-RETURN---
```

## 验收标准

- [ ] 架构完整性已验证
- [ ] 层级合理性已验证
- [ ] 需求满足度已验证
- [ ] 决策明确（PASS/NEEDS_REVISION）
- [ ] 输出格式符合规范
