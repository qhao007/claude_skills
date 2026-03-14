#!/bin/bash
# analyze_logs.sh - Analyze QuestaSim log files for warnings
# Usage: ./analyze_logs.sh [log_directory]

LOG_DIR="${1:-./sim}"

echo "=== QuestaSim Log Analysis ==="
echo "Log directory: $LOG_DIR"
echo ""

# Find log files
LOG_FILES=$(find "$LOG_DIR" -name "*.log" -type f 2>/dev/null | head -10)

if [ -z "$LOG_FILES" ]; then
    echo "No log files found in $LOG_DIR"
    exit 0
fi

# Analyze each log file
for LOG in $LOG_FILES; do
    echo "--- $(basename $LOG) ---"

    # Count warnings
    WARN_COUNT=$(grep -ci "warning" "$LOG" 2>/dev/null || echo "0")
    ERR_COUNT=$(grep -ci "error" "$LOG" 2>/dev/null || echo "0")

    echo "  Warnings: $WARN_COUNT"
    echo "  Errors: $ERR_COUNT"

    # Show critical warnings
    if [ "$WARN_COUNT" -gt 0 ]; then
        echo ""
        echo "  Critical warnings:"
        grep -i "vlog-2697\|vsim-3015\|vsim-3839\|vopt-8885" "$LOG" 2>/dev/null | head -5
    fi

    # Check test result
    RESULT=$(grep -oi "passed\|failed\|success\|error.*at time" "$LOG" 2>/dev/null | head -1)
    if [ -n "$RESULT" ]; then
        echo ""
        echo "  Test result: $RESULT"
    fi

    echo ""
done

echo "=== Analysis Complete ==="
