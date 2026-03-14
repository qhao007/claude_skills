---
name: run-simulation
description: Run QuestaSim simulation using project scripts
disable-model-invocation: true
arguments:
  - name: project
    description: Project name (pcie_demo, self_crosslink, basic_demo)
    required: true
  - name: command
    description: Command to run (all, clean, build, sim, check, gui)
    required: false
    default: all
  - name: test
    description: Test name (required for pcie_demo)
    required: false
---

# Run Simulation

Execute QuestaSim simulation using project-specific scripts.

## Usage

```bash
# Basic usage
/run-simulation project=pcie_demo test=tb_tlp_mem_req_encoder

# Self-crosslink project
/run-simulation project=self_crosslink

# Basic demo
/run-simulation project=basic_demo

# With specific command
/run-simulation project=pcie_demo command=clean test=tb_xxx
/run-simulation project=self_crosslink command=gui
```

## Projects

| Project | Script | Notes |
|---------|--------|-------|
| pcie_demo | `./scripts/sim.sh` | Requires TEST parameter |
| self_crosslink | `./scripts/run_sim.sh` | No TEST parameter needed |
| basic_demo | `./run_sim.sh` | No TEST parameter needed |

## Commands

| Command | Description |
|---------|-------------|
| all | Complete flow (clean + build + sim) |
| clean | Clean work directory |
| build | Compile design |
| sim | Run simulation |
| check | Check results |
| gui | Run in GUI mode (if supported) |

## Workflow

1. **Validate project name** - Must be one of: pcie_demo, self_crosslink, basic_demo
2. **Navigate to project directory** - `cd projects/<name>`
3. **Execute appropriate script** - Based on project type
4. **Check for warnings** - Use /analyze-warnings skill after completion

## Example

```bash
# Run pcie_demo test
cd projects/pcie_demo
source scripts/setup.sh
./scripts/sim.sh all TEST=tb_tlp_mem_req_encoder

# Run self_crosslink
cd projects/self_crosslink
./scripts/run_sim.sh all

# Run basic_demo
cd projects/basic_demo
./run_sim.sh all
```

## After Simulation

Always invoke `/analyze-warnings` to check for issues.
