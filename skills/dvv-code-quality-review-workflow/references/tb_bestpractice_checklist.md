# Verification/Testbench Best Practice Checklist

Based on verification_testbench_best_practice.md - Professional verification patterns for SystemVerilog testbenches.

---

## 1. Testbench Architecture

### Layered Architecture
- [ ] Test layer (test scenarios)
- [ ] Environment layer (agent coordination)
- [ ] Agent layer (driver, monitor, sequencer)
- [ ] Interface layer (signal abstraction)
- [ ] DUT layer

### Self-Checking Testbench
- [ ] Has clock/reset generation
- [ ] Has DUT instantiation
- [ ] Has stimulus generation
- [ ] Has result checking
- [ ] Has pass/fail reporting

---

## 2. Transaction Class Design

### Data Separation
- [ ] Transaction separates data from timing
- [ ] All fields declared as rand for randomization
- [ ] Has proper constraints

### Methods
- [ ] Has copy() method for deep copy
- [ ] Has display() method for debugging
- [ ] Has convert() method if needed

### Template
```systemverilog
class Transaction;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0] burst_len;
    rand bit        write;

    constraint c_aligned { addr[1:0] == 2'b00; }

    function Transaction copy();
        Transaction t = new();
        t.addr = this.addr;
        t.data = this.data;
        // ... copy all fields
        return t;
    endfunction
endclass
```

---

## 3. Driver Design

### Interface Access
- [ ] Uses virtual interface (not raw signals)
- [ ] Drives signals through interface
- [ ] Drives on clocking block if available

### Protocol Handling
- [ ] Waits for ready before driving
- [ ] Handles backpressure
- [ ] Drives according to protocol timing

---

## 4. Monitor Design

### Passive Observation
- [ ] Monitors without driving DUT
- [ ] Uses virtual interface (monitor mode)
- [ ] Extracts transaction from protocol

### Transaction Output
- [ ] Puts transactions to scoreboard/mailbox
- [ ] Captures timing information if needed

---

## 5. Scoreboard Design

### Comparison
- [ ] Has expected and actual mailboxes
- [ ] Compares expected vs actual
- [ ] Tracks pass/fail counts

### Reporting
- [ ] Has report() method
- [ ] Displays final pass/fail summary

---

## 6. Randomization

### Constraint Layering
- [ ] Uses soft constraints for defaults
- [ ] Can be overridden in extended classes
- [ ] Organized by constraint groups

### Weighted Distribution
- [ ] Uses dist for weighted values
- [ ] Appropriate weights for corner cases

### Solve Order
- [ ] Uses solve...before for correct randomization
- [ ] Avoids circular dependencies

---

## 7. Coverage

### Functional Coverage
- [ ] Has covergroup for transaction
- [ ] Has coverpoints for important fields
- [ ] Has cross coverage for interactions

### Coverage Goals
- [ ] Line coverage > 95%
- [ ] Branch coverage > 90%
- [ ] FSM state coverage 100%
- [ ] FSM transition coverage > 95%
- [ ] Functional coverage > 98%

---

## 8. Threading Patterns

### Fork-Join Usage
- [ ] Uses fork...join for parallel execution
- [ ] Uses fork...join_any with disable fork for timeout
- [ ] Uses fork...join_none for background tasks

### Timeout Handling
- [ ] All waits have timeout protection
- [ ] Timeout clearly indicates failure

---

## 9. Interface Design

### Parameterized Interface
- [ ] Parameters for width, depth, etc.
- [ ] Proper modport definitions (master, slave, monitor)
- [ ] Clocking blocks for testbench

### Virtual Interface
- [ ] Uses virtual interface in classes
- [ ] Passed through constructor or config

---

## 10. Assertions

### Protocol Checks
- [ ] Property-based assertions
- [ ] Sequence-based assertions
- [ ] Covers expected behaviors

### Checkers
- [ ] Valid-stable checker
- [ ] Handshake timing checker
- [ ] Protocol violation detection

---

## 11. Test Organization

### Base Test Class
- [ ] Virtual base test class
- [ ] Has run(), pre_test(), post_test() tasks
- [ ] Environment instantiated in base

### Test Types
- [ ] Smoke test for basic functionality
- [ ] Directed tests for specific scenarios
- [ ] Random tests for corner cases

---

## 12. Checklist Summary

### Before Starting
- [ ] Define verification plan
- [ ] Identify coverage goals
- [ ] List test scenarios
- [ ] Design TB architecture

### During Development
- [ ] Use transactions, not raw signals
- [ ] Separate driver/monitor/scoreboard
- [ ] Use virtual interfaces
- [ ] Add functional coverage
- [ ] Include protocol assertions

### Before Signoff
- [ ] All tests pass
- [ ] Coverage goals met
- [ ] No X/Z in simulation
- [ ] Edge cases tested
- [ ] Error injection tested

---

## 13. Common Issues

### Functional
- [ ] Race conditions between driver and monitor
- [ ] Improper handling of ready/valid
- [ ] Missing timeout protection
- [ ] Incomplete coverage

### Performance
- [ ] Inefficient randomization
- [ ] Too much logging
- [ ] Inefficient mailboxes

### Debugging
- [ ] Poor visibility into transactions
- [ ] Missing debug prints
- [ ] Hard to reproduce failures

---

## Severity Levels

| Category | Severity | Description |
|----------|----------|-------------|
| Architecture | Critical | Wrong testbench structure |
| Driver/Monitor | Critical | Incorrect protocol handling |
| Scoreboard | High | Missing/incomplete comparison |
| Coverage | High | Coverage goals not met |
| Randomization | Medium | Ineffective constraints |
| Style | Medium | Maintainability |
| Documentation | Low | Readability |

---

## Reference

- Source: `D:\claude_workspace\agent_knowledge_center\verification_testbench_best_practice.md`
- Book: SystemVerilog for Verification, 3rd ed. — Spear/Tumbush
