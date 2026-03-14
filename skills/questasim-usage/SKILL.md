# QuestaSim Usage

QuestaSim 仿真工具的使用指南和最佳实践。

## 触发条件

当用户：
- 提到 QuestaSim、vlib、vlog、vsim 命令
- 需要运行 Verilog 仿真
- 遇到编译或仿真警告/错误
- 需要生成波形文件
- 设置仿真环境或脚本

---

## 1. 环境配置

### 设置 PATH

```bash
# Windows Git Bash
export PATH="D:/questasim64_10.7c/win64:$PATH"

# 验证安装
vlib -help
vlog -help
vsim -help
```

### 许可证问题

如果遇到许可证错误，检查：
- LICENSE_FILE 环境变量是否正确设置
- 许可证服务器是否运行

---

## 2. 基本工作流程

```bash
# 1. 创建工作库
vlib work

# 2. 编译源文件
vlog -f filelist.f        # 使用 filelist
vlog file1.v file2.v      # 直接指定文件

# 3. 运行仿真
vsim -c tb_name -do "run -all; quit"   # 命令行模式
vsim tb_name                            # GUI 模式
```

### 清理工作目录

```bash
rm -rf work
vlib work
```

---

## 3. Filelist 文件

### 文件格式

```
// 注释行以 // 开头
D:/path/to/file1.v
D:/path/to/file2.v
```

### 编译选项

```bash
vlog -f rtl.f                          # 基本编译
vlog -debug -f rtl.f                   # 带调试信息
vlog +incdir+../include -f rtl.f       # 指定 include 路径
```

---

## 4. 仿真控制

### 命令行模式 (-c)

```bash
vsim -c tb_name -do "run -all; quit"              # 运行到结束
vsim -c tb_name -do "run 100us; quit"             # 运行指定时间
vsim -c tb_name -l tb_name.log -do "run -all; quit"  # 生成日志文件
```

### 完整仿真命令（VCD + 日志）

```bash
vopt +acc tb_name -o tb_name_opt
vsim -c tb_name_opt -l tb_name.log -do "vcd file tb_name.vcd; vcd add -r /*; run -all; quit"
```

### TCL 脚本

```tcl
# run_sim.do
vlib work
vlog -f rtl.f
vlog tb.v
vsim -c tb -do "run -all; quit"
```

运行方式:
```bash
vsim -c -do run_sim.do
```

---

## 5. 波形调试

### VCD 波形生成

**重要：QuestaSim 优化会移除信号可见性，必须使用 `vopt +acc`**

```bash
# 1. 编译设计
vlog -f rtl.f tb.v

# 2. 使用 vopt +acc 保留信号可见性
vopt +acc tb_name -o tb_name_opt

# 3. 运行仿真并生成 VCD
vsim -c tb_name_opt -do "vcd file tb_name.vcd; vcd add -r /*; run -all; quit"
```

### 错误的做法 (信号不可见)

```bash
# ❌ 错误：优化后信号不可见
vsim -c tb_name -do "vcd add -r /*; ..."
# 错误信息: No objects found matching '*'
```

### WLF 波形 (QuestaSim 原生)

```bash
vsim -c tb_name -do "log -r /*; run -all; quit"  # 生成 vsim.wlf
vsim -view vsim.wlf                               # 查看波形
```

---

## 6. Warning 消息分析

**重要**: 每次编译和仿真后必须检查 Warning 消息。

### 常见编译 Warning

| Warning 编号 | 类型 | 严重程度 | 处理建议 |
|-------------|------|----------|----------|
| vlog-2697 | 位宽越界 | **中等** | 检查信号位宽定义 |
| vlog-2957 | 位宽越界 | **中等** | 同上 |
| vlog-2576 | 未使用信号 | 低 | 可忽略 |
| vlog-1335 | 端口未连接 | 低 | 检查是否预期 |

### 常见仿真 Warning

| Warning 编号 | 类型 | 严重程度 | 处理建议 |
|-------------|------|----------|----------|
| vsim-PLI-3110 | PLI 重复调用 | 低 | $dumpfile 多次调用，可忽略 |
| vsim-3014 | 端口未连接 | **需分析** | 参见下文分析流程 |
| vsim-3015 | 端口位宽不匹配 | **高** | 检查 RTL 与 TB 接口 |
| vsim-8755 | 未初始化寄存器 | 中 | 添加复位值 |

### Warning 处理决策

| 情况 | 处理方式 |
|------|----------|
| 影响功能正确性 | **必须修复** |
| 影响仿真性能 | 建议修复 |
| 只是警告信息，无功能影响 | 可忽略，但记录原因 |
| 工具兼容性问题 | 可忽略，添加注释说明 |

### 预编译库端口缺失警告分析 (vsim-3014)

**重要**: 使用预编译库时可能出现大量端口未连接警告，需要正确分析。

#### 分析流程

```
┌─────────────────────────────────────────────────────────────┐
│              预编译库端口缺失警告分析流程                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 1: 确定信号来源                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 警告来源文件路径:                                     │   │
│  │ - 内部路径 (如 Wrapper.v) → 内部信号                  │   │
│  │ - 预编译库路径 (如 work_serdes_phy) → 库端口信号      │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                  │
│  Step 2: 根据来源判断                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 内部信号 → ✅ 可以忽略                                │   │
│  │ 库端口信号 → 进入 Step 3                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                  │
│  Step 3: 检查端口方向                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ INPUT 端口 → ❌ 必须连接                              │   │
│  │ OUTPUT 端口 → ✅ 可以忽略                             │   │
│  │ INOUT 端口 → ❌ 必须连接                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 判断规则

| 信号类型 | 端口方向 | 是否可忽略 | 原因 |
|----------|----------|------------|------|
| **内部信号** | 任意 | ✅ **可忽略** | 属于预编译库内部实现细节，用户无需关心 |
| **库端口信号** | OUTPUT | ✅ **可忽略** | 输出端口不连接不影响 DUT 功能 |
| **库端口信号** | INPUT | ❌ **必须连接** | 输入悬空会导致功能异常 |
| **库端口信号** | INOUT | ❌ **必须连接** | 双向端口必须正确连接 |

#### 验证方法

**方法 1: 查阅参考文件**
```bash
# 在参考文件中搜索端口定义
grep -E "^\s*(input|output|inout)\s+.*port_name" reference_file.sv
```

**方法 2: QuestaSim describe 命令**
```tcl
# 在 QuestaSim 控制台中
describe /path/to/module/port_name
# 输出会显示端口方向
```

#### 分析示例

```
警告内容:
  Warning: (vsim-3014) Port 'pcs_pma_rx_pos_dir_0' is not connected.
  Warning: (vsim-3014) Port 'pipe_rx_data_pcs_0' is not connected.
  ... (289 个类似警告)

分析步骤:
1. 检查警告来源文件
   - 内部 Wrapper.v → 内部信号 → 可忽略
   - testbench 实例化 → 库端口信号 → 需检查方向

2. 对于库端口信号，检查端口方向
   - 使用 grep 搜索参考文件确认方向
   - 或使用 describe 命令

3. 结论
   - 所有端口均为 OUTPUT → 可安全忽略
   - 如有 INPUT 端口缺失 → 必须修复
```

#### 经验教训

1. **不要盲目修复所有警告** - 区分信号来源和端口方向是关键
2. **参考文件是验证依据** - 使用设计参考文件确认端口方向
3. **INPUT 端口是关键** - 确保 INPUT 端口都有连接，这是功能正确性的保证
4. **OUTPUT 可安全忽略** - OUTPUT 端口不连接只意味着不监控该输出，不影响功能

---

## 7. 标准化仿真脚本

### 目录结构

```
项目目录/
├── setup.sh        # 环境设置脚本
├── sim.sh          # 仿真脚本 (跨平台)
├── rtl.f           # RTL 文件列表
├── tb.f            # Testbench 文件列表
└── sim_work/       # 仿真工作目录
```

### 使用方式

```bash
source setup.sh
./sim.sh all TEST=tb_xxx     # 完整流程
./sim.sh clean               # 清理
./sim.sh build TEST=tb_xxx   # 编译
./sim.sh sim TEST=tb_xxx     # 仿真
./sim.sh check TEST=tb_xxx   # 检查结果
```

### 脚本设计要点

1. 使用 `(cd dir && command)` 在子 shell 中执行，避免目录切换问题
2. 使用 `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"` 获取脚本绝对路径
3. 所有路径使用绝对路径或基于 SCRIPT_DIR
4. 支持命令行参数解析 `TEST=xxx`

---

## 8. 与 Icarus Verilog 对照

| 操作 | Icarus Verilog | QuestaSim |
|------|---------------|-----------|
| 创建库 | (自动) | `vlib work` |
| 编译 | `iverilog -o sim.vvp file.v` | `vlog file.v` 或 `vlog -f filelist.f` |
| 运行 | `vvp sim.vvp` | `vsim -c tb -do "run -all; quit"` |
| 波形 | VCD (GTKWave) | WLF/VCD (内置) |

---

## 9. 常见问题解决

| 问题 | 解决方案 |
|------|----------|
| 找不到模块定义 | 检查编译顺序，确保被依赖的模块先编译 |
| 语法错误 | QuestaSim 对语法要求更严格，检查 Verilog 语法 |
| 仿真卡住不结束 | 检查 testbench 是否有 $finish 或适当的结束条件 |
| 信号值为 X | 检查初始化逻辑，确保所有寄存器都有复位值 |
| VCD 信号不可见 | 使用 `vopt +acc` 保留信号可见性 |
