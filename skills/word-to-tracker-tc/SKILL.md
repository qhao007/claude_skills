---
name: word-to-tracker-tc
description: 从Word测试计划文档中提取Test Cases并转换为Tracker系统可导入的CSV格式。适用于用户说"提取Test Case"、"从测试计划导入TC"、"转换测试用例到tracker"等场景。
---

# Word to Tracker TC 转换技能

## 概述

将芯片验证的Word测试计划文档（如EX1_65K_IODDR_Validation_testplan.docx）转换为Tracker系统可导入的Test Case CSV格式，并生成TC与CP的关联关系文件。

## 输入

- Word文件路径（如 `D:/claude_workspace/tracker_project_summary/EX1_ValChar_TestPlans/EX1_65K_IODDR_Validation_testplan.docx`）
- 已导入的CP CSV文件（用于建立TC-CP关联）

## 输出

1. **TC CSV文件**（保存为 `<原文件名>_TC.csv`）- 可直接导入Tracker
2. **TC-CP关联CSV文件**（保存为 `<原文件名>_TC_CP_Connection.csv`）- 记录推测的关联关系，供后续手动关联

## 执行步骤

### 步骤1：读取Word测试计划

使用Word MCP工具读取文档内容：
```bash
mcp__word-mcp__get_document_text  # 读取Word文档
```

重点关注文档末尾的**Pattern Name表格**，这是具体的test pattern列表。

### 步骤2：识别文档格式并提取Test Cases

**当前支持的文档格式类型：**

| 类型 | 特征 | 示例 |
|------|------|------|
| Pattern表格 | 有独立的Pattern Name表格 | IODDR, DDR Memory, MIPI |
| Test Item+Protocol | 有Test Item和Protocol表格 | APCS, Serdes PCIe, Serdes PMA |
| Test Item+Protocol+Vector | 有Test Vector表格 | PCIe |
| 中文Test Item | 中文Test Item列表 | M3soc, 上电复位, 配置功能 |

#### 2.1 类型A：Pattern Name表格

#### 2.1 格式类型判断

Word测试计划文档有两种主要格式：

**类型A：Pattern Name表格**（如IODDR、DDR Memory、MIPI）
- 文档末尾有独立的Pattern Name表格
- 可直接使用表格中的pattern名称作为Test Name
- 示例：`hpio_lvcm18_tx_oddrx1_sclk250m`

**类型B：Test Item + Protocol组合**（如APCS、Serdes PCIe/PMA）
- 没有独立的Pattern Name表格
- 需要组合Test Item表格和Protocol参数表格
- 需要从Protocol表格提取参数到Scenario Details

#### 2.2 类型A提取方法

从文档末尾的Pattern Name表格直接提取pattern名称。

#### 2.3 类型B提取方法（APCS格式）

1. **提取Test Item列表**（10项）：
   - Reset
   - Power down mode
   - 8B/10B Coding
   - 10B/8B Coding
   - 8B/10B Tx Gearing
   - 10B/8B Rx Gearing
   - Word Aligner
   - RX CTC
   - Rx Lane-to-lane De-skew
   - Mix PCIe and APCS transmit

2. **提取Protocol参数表格**：
   | Protocol | Ref CLK | Data rate | Coding | Gearing |
   |---------|---------|-----------|--------|---------|
   | Ethernet-SGMII | 100MHz | 1.25Gbs | 8B/10B | 1:1 |
   | DP/eDP-HBR3 | 27MHz | 8.1Gbs | 8B/10B | 1:4 |
   | JESD204B | 156.25MHz | 12.5Gbs | 64B/66B | 1:2 |

3. **组合生成Test Case**：
   - Test Name格式：`apcs_<test_item>_<protocol_lowercase>`
   - Scenario Details包含：Protocol参数（Ref CLK, Data rate, Coding, Gearing）
   - 某些Test Item可能每个Protocol生成一个TC（如Coding, Gearing）
   - 某些Test Item可能只需要一个TC（如Reset, Power down）

**示例**：
```
Test Name: apcs_8b10b_coding_dp_edp_hbr3
Category: Coding
Scenario Details: APCS 8B/10B Coding test; Protocol: DP/eDP-HBR3; Ref CLK: 27MHz; Data Rate: 8.1Gbps; Coding: 8B/10B; Gearing: 1:4
```

#### 2.4 类型C：Test Item + Protocol + Test Vector（PCIe格式）

某些文档（如PCIe）在Test Item和Protocol之外还有**Test Vector表格**，提供更细化的测试类型：

1. **提取Test Item列表**
2. **提取Protocol参数表格**
3. **提取Test Vector表格**（如TLP类型、Recovery类型等）
4. **组合生成Test Case**：
   - 对于每个Test Item，可能需要根据Protocol和Test Vector组合生成多个TC
   - Test Name格式：`pcie_<test_item>_<vector>`
   - Scenario Details包含：Protocol参数 + Test Vector信息

**PCIe Test Vector示例**：
- Basic TLP测试: Memory Write, Memory Read, Configuration Write, Configuration Read, Completion with/without Data
- Recovery测试: Hot plug, PMU power down, PCIe reset
- Stress测试: 8小时稳定性, Maximum Payload, Mixed Traffic

**示例**：
```
Test Name: pcie_basic_tlp_mem_write
Category: TLP
Scenario Details: PCIe Basic TLP test; Protocol: PCIe3; Data Rate: 8Gbps; Test: Memory Write
```

#### 2.5 类型D：中文Test Item列表

中文文档（如M3soc、上电复位、配置功能）的Test Item列表：

1. **提取Test Item列表**：从文档末尾的表格中提取测试项目
2. **清理名称**：移除括号内容、转换为小写、替换空格为下划线
3. **生成Test Case**：
   - Test Name格式：`<模块名>_<test_item_clean>`
   - Category根据测试类型推断（如MCU Debug, SRAM Test, Interrupt等）

**示例**：
```
源: MCU在线仿真测试
生成: m3_jtag_debug
Category: MCU Debug
```

### 步骤2-EX：TC命名规范汇总

| 文档类型 | 命名格式 | 示例 |
|---------|---------|------|
| Pattern表格 | 直接使用pattern名称 | `hpio_lvcm18_tx_oddrx1_sclk250m` |
| Test Item+Protocol | `<module>_<item>_<protocol>` | `apcs_8b10b_coding_dp_edp_hbr3` |
| Test Item+Vector | `<module>_<item>_<vector>` | `pcie_basic_tlp_mem_write` |
| 中文Test Item | `<module>_<item_clean>` | `m3_jtag_debug`, `ccb_as_x1_80m` |

### 步骤3：生成TC CSV

#### 3.1 字段映射

| TestPlan字段 | Tracker TC字段 | 说明 |
|-------------|---------------|------|
| Pattern Name | Test Name | 直接映射 |
| Description | Scenario Details | 包含gearing rate, SCLK频率, IO标准, Bank信息 |
| 测试类型(TX/RX/Delay/Timing/Stress) | Category | 分类 |
| N/A | TestBench | 默认填"bench"（除非文档特别说明使用ATE） |

#### 3.2 Scenario Details构建

根据测试计划的描述，构建详细的scenario_details，包含：
- 测试模式（如ODDRx1, ODDRx2, IDDRx4等）
- 电压标准（LVCMOS18, LVDS, SLVS, subLVDS等）
- 频率信息（SCLK, FCLK）
- Bank位置
- Protocol参数（Ref CLK, Data rate, Coding, Gearing等）

**示例**：
```
ODDRx1 TX static default HPIO; Gearing: 2:1; SCLK: 250MHz; IO: LVCMOS18; Bank: 4,5,6,7,8,9
```

#### 3.3 Category提取规则

从测试项名称或协议类型推断Category：

| 测试类型 | 关键词 | Category |
|---------|-------|----------|
| TX相关 | TX, Transmit, Output | TX |
| RX相关 | RX, Receive, Input | RX |
| 初始化 | Initialization, Reset, Boot | Initialization |
| 延迟测试 | Delay, Timing | Delay |
| 压力测试 | Stress, Endurance | Stress |
| 电源测试 | Power, Low Power | Power Down |
| 编码测试 | Coding, Encode, Decode | Coding |
| 时钟测试 | PLL, Clock, Jitter | Clock |
| 校准测试 | Calibration, Alignment | Calibration |
| 循环测试 | Loopback | Loopback |
| MCU测试 | MCU, Debug, JTAG | MCU Debug |
| 外设测试 | UART, SPI, I2C, GPIO | Peripheral |
| 配置测试 | Boot, Config, JTAG, AS, PS | Config |

### 步骤4：生成TC-CP关联CSV

#### 4.1 读取已导入的CP数据

读取CP CSV文件，获取已导入的Cover Point列表。

#### 4.2 建立映射关系

根据命名规则和测试类型建立TC-CP关联：

| TC Test Name模式 | 对应CP |
|-----------------|--------|
| `hpio_lvcm18_tx_oddrx1_*` | `HPIO_LVCMOS18_TX_ODDRx1` |
| `hpio_lvds_tx_oddrx4` | `HPIO_LVDS_TX_ODDRx4` |
| `hpio_lvds_rx_iddrx4` | `HPIO_LVDS_RX_IDDRx4` |
| `hpio_lvds_rx_iddrx7` | `HPIO_LVDS_RX_IDDRx7` |
| `*_delay_module_test` | `DDR_DELAY_MODULE_TEST` |
| `*_delay_test` | ` DELAY_TIMING_TEST`（注意有前导空格） |

**重要**：部分CP名称在Tracker中有特殊字符，生成连接时必须完全匹配：

| CP名称（带特殊字符） | 原始名称 |
|---------------------|---------|
| ` DELAY_TIMING_TEST` | 前导空格 |
| ` Recovery  mechanism` | 前导空格+双空格 |
| `Basic TLP Transmission/Reception ` | 尾随空格 |
| ` Mix PCIe and APCS transmit` | 前导空格 |
| `Test PUDC function:
pre-configuration...` | 内部换行 |

**建议**：生成TC-CP连接前，先从Tracker API获取准确的CP名称列表，避免手动匹配出错。
| `*_loopback_stress_test` | `DDR_LOOPBAK_STRESS_TEST` |
| `ddr4_*` | `DDR_MEM`分类下的CP（如`Training_and_Initialization`） |
| `mipi_*` | `MIPI TX/RX`分类下的CP（如`MIPI TX DPHY HS mode`） |
| `pma_*` | `PMA`分类下的CP（如`TX MASK`） |
| `apor_*` | `POR/APOR`分类下的CP |
| `spor_*` | `POR/SPOR`分类下的CP |
| `ccb_*` | `CCB`分类下的CP（如`JTAG Boot`, `AS Boot`） |

#### 4.3 特殊映射情况

**一对多映射**：某些TC对应多个CP
- MIPI TX测试通常同时覆盖TX和RX功能
- 示例：`mipi_dphy_hs_tx2rx_4p5G` → TX CP + RX CP

**无对应CP**：某些模块在CP文件中无对应项
- 仍需生成TC CSV，但不生成TC-CP连接文件
- 示例：M3soc模块

#### 4.3 输出格式

```csv
Test Case,Cover Point
hpio_lvcm18_tx_oddrx1_sclk250m,HPIO_LVCMOS18_TX_ODDRx1
hrio_lvcm33_tx_oddrx2,HRIO_LVCMOS33_TX_ODDRx2
...
```

**注意**：Tracker系统目前不支持通过CSV导入直接建立TC-CP关联，此文件仅供记录和后续手动关联使用。

### 步骤5：导入Tracker（可选）

#### 5.1 登录Tracker

```bash
curl -X POST 'http://localhost:8080/api/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123"}'
```

#### 5.2 上传CSV到服务器

将TC CSV文件上传到服务器的uploads目录。

#### 5.3 执行导入

```bash
curl -X POST 'http://localhost:8080/api/import' \
  -H 'Content-Type: application/json' \
  -d '{
    "project_id": <项目ID>,
    "type": "tc",
    "file_data": "<base64编码的CSV文件>"
  }'
```

## Tracker TC CSV格式

**表头（大写）**：
```csv
TestBench,Test Name,Category,Owner,Scenario Details,Checker Details,Coverage Details,Comments
```

**必填字段**：
- `TestBench` - 测试平台（默认填"bench"）
- `Test Name` - 测试用例名称

**可选字段**：
- `Category` - 分类（TX/RX/Delay/Timing/Stress）
- `Owner` - 负责人
- `Scenario Details` - 测试场景详情
- `Checker Details` - 检查器详情
- `Coverage Details` - 覆盖率详情
- `Comments` - 备注

## 编码注意事项

- CSV文件必须使用UTF-8编码
- 分号(;)作为多个字段的分隔符
- 逗号(,)作为CSV列分隔符
- 确保无多余空行

## 已知问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| Pattern Name表格提取不完整 | Word文档格式问题 | 手动检查文档末尾的表格 |
| TC-CP关联不准确 | 推测基于命名规则 | 人工验证关联关系 |
| Tracker不支持关联导入 | 系统限制 | 手动在UI中建立关联 |

## 项目命名规范

- TC CSV: `<项目名>_TC.csv`（如 `EX1_ValChar_TC.csv`）
- 关联CSV: `<项目名>_TC_CP_Connection.csv`（如 `EX1_ValChar_TC_CP_Connection.csv`）

## 重要安全规则

### 绝对禁止操作
- **禁止删除**服务器上的任何项目数据（无论是否错误）
- 即使项目创建错误或数据有问题，也必须由人类用户手动处理
- 禁止使用DELETE API操作项目资源

### 错误处理
- 如果项目创建错误：记录错误信息，告知用户手动处理
- 如果导入数据有问题：生成修正后的CSV，让用户重新导入
- 不要尝试"修复"已创建的数据，而是创建新的正确数据
