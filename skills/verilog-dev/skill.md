---
name: verilog-dev
description: |
  Expert Verilog/SystemVerilog development skill covering IEEE 1800 standards, synthesizable RTL patterns, and practical debugging techniques.

  TRIGGER when: writing/modifying Verilog or SystemVerilog code, designing state machines, encountering timing issues or simulation anomalies, needing RTL quality checks, discussing blocking/non-blocking assignments, signal width issues, or implementing parameterized modules and interfaces.

  Use this skill for all Verilog/SV development tasks including module design, interface definitions, testbench creation, and code review.
allowed-tools: Read, Grep, Write, Edit, Bash, Glob
---

# Verilog/SystemVerilog 开发技能

面向 FPGA/ASIC 设计的综合开发技能，涵盖 IEEE 1800-2017 标准语法、可综合 RTL 模式、状态机设计以及实战调试技巧。

---

## 1. 语言基础

### 1.1 Always 块使用规范

SystemVerilog 提供三种专用 always 块，正确使用可防止综合问题：

```systemverilog
// 时序逻辑 - always_ff（触发器）
always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    counter <= '0;
    state   <= IDLE;
  end else begin
    counter <= counter + 1'b1;
    state   <= next_state;
  end
end

// 组合逻辑 - always_comb（防止锁存器）
always_comb begin
  // 先赋默认值，防止锁存器推断
  next_state = state;
  output_valid = 1'b0;

  case (state)
    IDLE: if (start) next_state = RUN;
    RUN: begin
      output_valid = 1'b1;
      if (done) next_state = IDLE;
    end
    default: next_state = IDLE;
  endcase
end

//  intentional latch - always_latch（极少使用）
always_latch begin
  if (enable) latch_out = data_in;
end
```

**规则摘要：**

| 块类型 | 用途 | 赋值类型 |
|--------|------|----------|
| `always_ff` | 时序逻辑（触发器） | 非阻塞 `<=` |
| `always_comb` | 组合逻辑 | 阻塞 `=` |
| `always_latch` | 显式锁存器 | 阻塞 `=` |

> **重要**：在 SystemVerilog 中避免使用传统的 `always @*`，改用显式的 `always_ff`/`always_comb`。

### 1.2 阻塞与非阻塞赋值

**核心原则**：
- 非阻塞赋值 (`<=`) 的**新值在下一个时钟沿才可见**
- 阻塞赋值 (`=`) **立即生效**

```systemverilog
// 正确：时序逻辑使用非阻塞赋值
always_ff @(posedge clk) begin
  reg_a <= data_in;     // 非阻塞
  reg_b <= reg_a;       // 创建流水线，reg_b 获得上一个周期的 reg_a
end

// 正确：组合逻辑使用阻塞赋值
always_comb begin
  temp = a & b;         // 阻塞，立即生效
  result = temp | c;    // 使用更新后的 temp
end

// 错误：在时序块中混用
always_ff @(posedge clk) begin
  temp = data_in;       // 错误！时序逻辑中使用阻塞赋值
  reg_a <= temp;
end
```

### 1.3 参数化模块

```systemverilog
module sync_fifo #(
  parameter int DATA_WIDTH = 8,
  parameter int DEPTH = 16,
  // 使用 localparam 定义派生参数
  localparam int ADDR_WIDTH = $clog2(DEPTH),
  localparam int CNT_WIDTH = $clog2(DEPTH + 1)
) (
  input  logic                    clk,
  input  logic                    rst_n,
  input  logic                    wr_en,
  input  logic [DATA_WIDTH-1:0]   wr_data,
  output logic                    full,
  input  logic                    rd_en,
  output logic [DATA_WIDTH-1:0]   rd_data,
  output logic                    empty
);

  // 内存数组
  logic [DATA_WIDTH-1:0] mem [DEPTH];
  logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;

  // 写指针逻辑
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
    end else if (wr_en && !full) begin
      mem[wr_ptr] <= wr_data;
      wr_ptr <= wr_ptr + 1'b1;
    end
  end

  // 读指针逻辑
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_ptr <= '0;
    end else if (rd_en && !empty) begin
      rd_ptr <= rd_ptr + 1'b1;
    end
  end

  // 状态信号
  assign full  = (wr_ptr == rd_ptr) && (wr_en != rd_en);
  assign empty = (wr_ptr == rd_ptr);

endmodule
```

**参数设计原则：**
- `parameter`：用户可配置的参数
- `localparam`：内部派生常量
- `$clog2()`：计算地址位宽
- 提供合理的默认值

---

## 2. SystemVerilog 高级特性

### 2.1 接口定义

接口封装信号组，简化模块连接：

```systemverilog
// AXI-Stream 接口定义
interface axis_if #(
  parameter int DATA_WIDTH = 32
) (
  input logic aclk,
  input logic aresetn
);

  logic                    tvalid;
  logic                    tready;
  logic [DATA_WIDTH-1:0]   tdata;
  logic [DATA_WIDTH/8-1:0] tkeep;
  logic                    tlast;

  // Master modport
  modport master (
    input  aclk, aresetn, tready,
    output tvalid, tdata, tkeep, tlast
  );

  // Slave modport
  modport slave (
    input  aclk, aresetn, tvalid, tdata, tkeep, tlast,
    output tready
  );

  // Monitor modport（用于验证）
  modport monitor (
    input aclk, aresetn, tvalid, tready, tdata, tkeep, tlast
  );

endinterface

// 使用接口的模块
module axis_register #(
  parameter int DATA_WIDTH = 32
) (
  input logic clk,
  input logic rst_n,
  axis_if.slave  s_axis,
  axis_if.master m_axis
);

  logic [DATA_WIDTH-1:0] data_reg;
  logic                  valid_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_reg <= 1'b0;
      data_reg  <= '0;
    end else if (s_axis.tready) begin
      valid_reg <= s_axis.tvalid;
      data_reg  <= s_axis.tdata;
    end
  end

  assign m_axis.tvalid = valid_reg;
  assign m_axis.tdata  = data_reg;
  assign s_axis.tready = m_axis.tready || !valid_reg;

endmodule
```

### 2.2 包和类型定义

```systemverilog
// 包定义
package design_pkg;

  // 枚举类型
  typedef enum logic [2:0] {
    IDLE  = 3'b000,
    INIT  = 3'b001,
    RUN   = 3'b010,
    DONE  = 3'b100,
    ERROR = 3'b101
  } state_t;

  // 结构体
  typedef struct packed {
    logic        valid;
    logic [31:0] data;
    logic [3:0]  strb;
    logic        last;
  } packet_t;

  // 常量
  localparam int TIMEOUT_CYCLES = 1000;

  // 函数
  function automatic int clog2(int value);
    int result = 0;
    value = value - 1;
    while (value > 0) begin
      result++;
      value = value >> 1;
    end
    return result;
  endfunction

endpackage

// 使用包
module my_module
  import design_pkg::*;
(
  input  logic    clk,
  input  logic    rst_n,
  output state_t  current_state
);

  state_t state, next_state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else        state <= next_state;
  end

  assign current_state = state;

endmodule
```

### 2.3 综合属性

```systemverilog
module synthesis_attributes (
  input  logic clk,
  input  logic rst_n,
  input  logic async_in,
  output logic sync_out
);

  // Xilinx: ASYNC_REG 用于同步器
  (* ASYNC_REG = "TRUE" *) logic [1:0] sync_reg;

  // Xilinx: 保留信号用于调试
  (* KEEP = "TRUE" *) logic debug_signal;

  // Xilinx: RAM 类型控制
  (* RAM_STYLE = "block" *) logic [7:0] block_mem [1024];
  (* RAM_STYLE = "distributed" *) logic [7:0] dist_mem [16];

  // Xilinx: FSM 编码
  (* FSM_ENCODING = "one_hot" *) enum logic [2:0] {
    IDLE, RUN, DONE
  } state;

  // Intel: RAM 推断
  (* ramstyle = "M20K" *) logic [7:0] intel_mem [1024];

  // 同步器实现
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) sync_reg <= '0;
    else        sync_reg <= {sync_reg[0], async_in};
  end

  assign sync_out = sync_reg[1];

endmodule
```

---

## 3. 状态机设计

### 3.1 核心问题：next_state 陷阱

**非阻塞赋值的新值在下一个时钟沿才可用。** 这是状态机设计中最常见的错误来源。

#### 错误模式

```verilog
// ❌ 错误：在状态判断中使用 next_state
always @* begin
    case(state)
        IDLE: next_state = HEADER;
        // ...
    endcase
end

always @(posedge clk) begin
    state <= next_state;           // 非阻塞赋值
    if (next_state == HEADER)      // 新值下个周期才可见！
        mwr_req <= 1'b1;           // 时序错误！
end
```

**问题分析**：`state` 和 `mwr_req` 在同一个时钟沿被赋值，但 `mwr_req` 的条件判断使用的是 `next_state`（还未更新的值），导致时序错位。

#### 正确模式

```verilog
// ✅ 正确：直接使用 state，信号在当前状态设置
always @(posedge clk) begin
    case(state)
        IDLE: begin
            if (vc_rx_valid && vc_rx_sop) begin
                mwr_req <= 1'b1;   // 在 IDLE 状态设置
                state <= HEADER;
            end
        end
        HEADER: begin
            // mwr_req 已在上个周期设置，此时可见
            if (vc_rx_eop) begin
                mwr_req <= 1'b0;   // 清除信号
                state <= DONE;
            end
        end
        DONE: state <= IDLE;
    endcase
end
```

### 3.2 状态机设计原则

| 原则 | 说明 |
|------|------|
| **信号提前设置** | 需要在下一个状态使用的信号，应在当前状态提前设置 |
| **避免中间变量陷阱** | 简化状态机，直接使用 `state` 判断，避免 `next_state` 带来的时序混乱 |
| **理解非阻塞赋值** | 新值在**下一个时钟沿采样时**才可见 |
| **单周期脉冲** | 如果信号只需保持一个周期，在设置后的下一个状态立即清除 |

### 3.3 调试方法

1. 使用 VCD 波形分析信号变化时机
2. 检查信号何时被设置、何时被采样
3. 验证时序是否与预期一致

---

## 4. 常见问题与调试

### 4.1 位宽匹配问题

访问超出信号定义范围的位会导致功能异常。

```verilog
// ❌ 错误：访问不存在的位
input  wire [7:0]  config_addr,   // 定义为 8 位
assign dw2[19:17] = config_addr[10:8];  // 越界！返回 X 或 0

// ✅ 方案 1: 扩展位宽
input  wire [15:0] config_addr,   // 扩展为 16 位

// ✅ 方案 2: 修正访问（如果功能不需要）
assign dw2[19:17] = 3'b0;         // 直接赋固定值
```

**位宽修改检查清单：**

- [ ] RTL 模块端口定义
- [ ] Testbench 信号声明
- [ ] Testbench 模块实例化
- [ ] 其他调用该模块的位置

```bash
# 查找模块所有调用位置
grep -r "module_name" rtl/ sim/
```

### 4.2 端口连接检查

| 阶段 | Warning 编号 | 含义 | 指示问题 |
|------|-------------|------|----------|
| 编译 | `vlog-2697` | part-select out of bounds | RTL 内部位宽定义不足 |
| 仿真 | `vsim-3015` | Port size mismatch | RTL 与 TB 端口位宽不匹配 |

**调试流程：**
```
vlog-2697 → 检查 RTL 内部位宽定义
vsim-3015 → 检查 RTL 与 TB 接口是否匹配
修改接口后 → 搜索所有实例化位置同步更新
```

### 4.3 Testbench 时序技巧

**输入信号时序**：所有输入信号要在 valid/sop 信号之前稳定。

**脉冲信号捕获**：使用捕获寄存器检测单周期脉冲信号：

```verilog
// 在 testbench 中
reg debug_mwr_req_captured;

always @(posedge clk) begin
    if (mwr_req) debug_mwr_req_captured <= 1'b1;
end

// 检查时使用捕获值
if (debug_mwr_req_captured) begin
    $display("PASSED");
end
```

---

## 5. 数组与存储

### 5.1 Packed vs Unpacked 数组

```systemverilog
// Unpacked 数组 - 多个存储位置（推断为存储器）
logic [WIDTH-1:0] memory_array [DEPTH];

// Packed 数组 - 连续位向量（移位寄存器）
logic [DEPTH-1:0][WIDTH-1:0] shift_reg;

// 多维 packed 数组
logic [3:0][7:0] packed_data;  // 32位值，按字节访问

// 多维 unpacked 数组
logic [7:0] mem_2d [4][8];     // 4x8 字节数组
```

### 5.2 使用场景

```systemverilog
// 移位寄存器 - 使用 packed 数组
always_ff @(posedge clk) begin
  shift_reg <= {shift_reg[DEPTH-2:0], data_in};
end

// 存储器写入 - 使用 unpacked 数组
always_ff @(posedge clk) begin
  memory_array[wr_addr] <= data_in;
end
```

---

## 6. 风格指南

### 6.1 命名约定

- 使用 `logic` 替代 `wire`/`reg`
- 使用 `'0` 和 `'1` 表示全零/全一
- 端口每行一个，提高可读性
- 使用 snake_case 命名

### 6.2 代码组织

```systemverilog
module module_name #(
  parameter type PARAM = default
) (
  // 时钟和复位
  input  logic clk,
  input  logic rst_n,
  // 输入端口
  input  logic [WIDTH-1:0] data_in,
  input  logic             valid_in,
  // 输出端口
  output logic [WIDTH-1:0] data_out,
  output logic             valid_out
);

  // ---------- 内部信号声明 ----------
  logic [WIDTH-1:0] reg_data;
  logic             reg_valid;

  // ---------- 组合逻辑 ----------
  always_comb begin
    // ...
  end

  // ---------- 时序逻辑 ----------
  always_ff @(posedge clk or negedge rst_n) begin
    // ...
  end

endmodule
```

---

## 7. 参考资源

- IEEE Std 1800-2017 (SystemVerilog)
- IEEE Std 1364-2005 (Verilog)
- Xilinx UG901: Vivado Synthesis Guide
- Intel Quartus Prime Synthesis Guide
- Verilator User Manual
