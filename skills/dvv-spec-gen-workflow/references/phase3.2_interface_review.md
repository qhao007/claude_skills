# Phase 3.2: 接口审查 Prompt

## 任务背景

你是接口审查代理，负责审查接口定义是否符合协议要求或业界标准。

## 输入信息

### 接口定义文档
```
{interface_definitions_content}
```

### 架构规划文档
```
{architecture_plan_content}
```

### 使用的协议/标准（如有）
```
{protocol_info}
```

## 审查要求

### 1. 协议合规性检查

检查接口定义是否符合：
- [ ] 使用的协议标准（如AXI4, APB, PCIe等）
- [ ] 协议规定的信号时序
- [ ] 协议规定的数据宽度

### 2. 位宽和方向正确性

检查：
- [ ] 数据位宽是否符合标准
- [ ] 控制信号位宽是否正确
- [ ] 方向（Input/Output）是否正确

### 3. 命名规范性

检查：
- [ ] 命名是否符合项目规范
- [ ] 缩写使用是否一致
- [ ] 信号命名是否有歧义

### 4. 完整性检查

检查：
- [ ] 必要的控制信号是否完整
- [ ] 握手信号是否完整
- [ ] 错误处理信号是否定义

## 输出要求

生成审查报告 `interface_review.md`：

```markdown
# 接口审查报告

## 审查信息
- 审查阶段: Phase 3.2
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

## 决策
---GATEFLOW-RETURN---
STATUS: {PASS|NEEDS_REVISION}
PHASE: phase32_interface_review
DECISION: {决策说明}
OUTPUT_FILE: .dvv/reports/interface_review.md
---END-GATEFLOW-RETURN---
```

## 验收标准

- [ ] 协议合规性已验证
- [ ] 位宽和方向正确性已验证
- [ ] 命名规范性已验证
- [ ] 决策明确（PASS/NEEDS_REVISION）
