# Phase 3.1: 接口生成 Prompt

## 任务背景

你是接口定义代理，负责生成模块接口定义或TB-DUT连接关系。

## 输入信息

### 需求文档
```
{requirements_content}
```

### 架构规划文档
```
{architecture_plan_content}
```

### SPEC类型
- **Design SPEC**: 生成模块端口定义
- **Testbench SPEC**: 生成TB与DUT连接关系

## 技能要求

加载以下技能（如适用）：
- 协议相关技能（如 PCIe 协议知识）
- 接口标准知识

## 任务要求

### Design SPEC 模式

生成模块端口定义列表：
- 信号名称
- 方向（Input/Output/Inout）
- 位宽
- 类型（logic, wire等）
- 描述
- 协议接口定义（如AXI/APB/自定义协议）

### Testbench SPEC 模式

生成TB与DUT的连接关系：
- DUT端口信号列表
- TB信号驱动/监控关系
- 时钟和复位连接
- 事务接口定义

## 输出要求

生成 `interface_definitions.md`：

```markdown
# 接口定义

## Design SPEC 模式

### 端口定义表

| 信号名 | 方向 | 宽度 | 类型 | 描述 |
|--------|------|------|------|------|
| clk | Input | 1 | logic | 主时钟 |
| rst_n | Input | 1 | logic | 异步复位，低有效 |

## Testbench SPEC 模式

### DUT连接关系

| DUT信号 | TB信号 | 方向 | 说明 |
|---------|--------|------|------|
| clk | tb_clk | → | 时钟驱动 |
```

## 验收标准

- [ ] 所有必要端口已定义
- [ ] 位宽和方向正确
- [ ] 接口协议定义清晰
- [ ] 符合命名规范
