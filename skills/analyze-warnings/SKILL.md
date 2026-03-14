---
name: analyze-warnings
description: Analyze QuestaSim compile/simulation logs for warnings and errors
---

# Analyze Warnings

Analyze QuestaSim log files for warnings and errors after compile/simulation.

## Usage

Invoke this skill after any simulation run to check for issues:

```bash
# From project directory
/analyze-warnings
```

## What It Checks

1. **Compile warnings** - vlog warnings in compile.log
2. **Simulation warnings** - vsim warnings in simulation.log
3. **Test results** - PASSED/FAILED status

## Warning Types

| Warning Code | Meaning | Action |
|--------------|---------|--------|
| `vlog-2697` | Bit width out of bounds | **Fix required** |
| `vsim-3015` | Port size mismatch | **Fix required** |
| `vsim-PLI-3110` | $dumpfile duplicate | Can ignore |
| `vsim-3839` | Multiply driven variable | **Fix required** |
| `vopt-8885` | Illegal inout port connection | **Fix required** |

## Process

1. Find the most recent log files in current project's `sim/` directory
2. Extract all warning lines with context
3. Categorize by severity
4. Check for test result keywords (PASSED, FAILED, completed)
5. Report findings with recommendations

## Output Format

```
=== Warnings Summary ===
Total warnings: X
Must fix: Y
Can ignore: Z

=== Must Fix ===
[warning lines with file:line]

=== Can Ignore ===
[warning lines with reason]

=== Test Result ===
[PASSED/FAILED/Not found]
```

## Integration

This skill should be invoked automatically via hook after any simulation script execution.
