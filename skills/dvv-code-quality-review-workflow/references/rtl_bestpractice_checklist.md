# RTL/Verilog Best Practice Checklist

Based on rtl_design_patterns.md - Design patterns and best practices for SystemVerilog RTL design.

---

## 1. Clocking & Reset

### Clock Generation
- [ ] Clock generation uses `always` or `always_ff` with proper period
- [ ] No clock division using blocking assignments in sequential logic
- [ ] Differential clock pairs toggle simultaneously

### Reset Strategy
- [ ] Asynchronous reset uses `or negedge rst_n`
- [ ] Reset polarity is consistent throughout design
- [ ] Reset release is synchronized when crossing clock domains

---

## 2. Sequential Logic (always_ff)

### Basic Rules
- [ ] Uses non-blocking assignment (`<=`)
- [ ] All inputs to FF are defined in all branches
- [ ] No mixing of blocking and non-blocking in same always block

### Template
```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        q <= '0;
    end else begin
        if (en) q <= d;
    end
end
```

---

## 3. Combinational Logic (always_comb)

### Basic Rules
- [ ] Uses blocking assignment (`=`)
- [ ] All inputs are evaluated in all paths
- [ ] No latches inferred (all branches assigned)

### Template
```systemverilog
always_comb begin
    out = '0;
    case (sel)
        1'b0: out = a;
        1'b1: out = b;
    endcase
end
```

---

## 4. Valid-Ready Handshake

- [ ] Producer has valid signal with proper deassertion logic
- [ ] Consumer provides ready signal
- [ ] Transfer happens on valid && ready
- [ ] Data is stable during transfer

---

## 5. State Machines

### Encoding
- [ ] Uses enum for state names
- [ ] Uses `(* enum_encoding *)` or localparam for encoding
- [ ] Considers one-hot for high-speed paths

### Default State
- [ ] Default state explicitly defined
- [ ] All state transitions have complete case coverage

---

## 6. CDC (Clock Domain Crossing)

### Synchronizers
- [ ] 2-FF synchronizer for single-bit signals
- [ ] Gray code for multi-bit counters/pointers
- [ ] Handshake or FIFO for multi-bit data

### 2FF Sync Template
```systemverilog
logic [1:0] sync_ff;
always_ff @(posedge clk_dst or negedge rst_n)
    if (!rst_n) sync_ff <= '0;
    else sync_ff <= {sync_ff[0], async_in};
assign sync_out = sync_ff[1];
```

---

## 7. FIFO Design

### Sync FIFO
- [ ] Empty/full flags correctly generated
- [ ] Pointer comparison handles wraparound
- [ ] Read/write don't conflict

### Async FIFO
- [ ] Uses Gray code for pointer crossing
- [ ] Full/empty comparison in respective clock domain
- [ ] Handles metastability

---

## 8. Memory Elements

### RAM
- [ ] Uses `(* ram_style = "block" *)` for block RAM
- [ ] Read data is registered
- [ ] Write enable has proper timing

### ROM
- [ ] Uses `(* rom_style = "block" *)` for block ROM
- [ ] Initialized with `$readmemh` or `$readmemb`

---

## 9. Error Handling

### Fault Detection
- [ ] Parity for single-bit errors
- [ ] ECC (SECDED) for memory protection
- [ ] CRC for packet integrity
- [ ] Watchdog for system liveness

### Response
- [ ] Error flags properly propagated
- [ ] Interrupt or status signals for errors
- [ ] Recovery mechanisms defined

---

## 10. Arbiter Design

### Round-Robin
- [ ] Fair arbitration
- [ ] No starvation
- [ ] Priority rotates after each grant

---

## 11. Interface Design

### Handshake Protocols
- [ ] Valid-ready for point-to-point
- [ ] Request-acknowledge for pipelined
- [ ] Backpressure handled properly

### Parameters
- [ ] Use parameters for configurability
- [ ] Localparam for derived constants

---

## 12. Coding Style

### Naming
- [ ] Signal names descriptive (snake_case)
- [ ] Consistent prefix/suffix (e.g., _vld, _rdy, _i, _o)
- [ ] Module names PascalCase or snake_case consistently

### Documentation
- [ ] Module header with description, inputs, outputs
- [ ] Complex logic has comments
- [ ] State machine states documented

### Structure
- [ ] Single responsibility per module
- [ ] Parameterized where applicable
- [ ] Reusable functions/tasks for common logic

---

## 13. Timing Closure

### Combinational Delay
- [ ] Critical path analyzed
- [ ] Pipelining considered for long paths
- [ ] No excessive fan-in

### Latency
- [ ] Latency documented and understood
- [ ] Throughput meets requirements

---

## 14. Power

### Clock Gating
- [ ] Used for idle blocks
- [ ] Integrated with tool

### Bus Encoding
- [ ] Gray coding for counters
- [ ] One-hot for low-activity signals

---

## Severity Levels

| Category | Severity | Description |
|----------|----------|-------------|
| Clock/Reset | Critical | Functional failure likely |
| CDC | Critical | Metastability, data corruption |
| State Machine | High | Incorrect state transitions |
| FIFO/Memory | High | Data corruption |
| Style | Medium | Maintainability |
| Documentation | Low | Readability |

---

## Reference

- Source: `D:\claude_workspace\agent_knowledge_center\rtl_design_patterns.md`
