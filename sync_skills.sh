#!/bin/bash

# Sync skills from 分散 locations to this directory
# Usage: ./sync_skills.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCATIONS_FILE="$SCRIPT_DIR/home_made_skill_locations.txt"
TARGET_DIR="$SCRIPT_DIR/skills"

# Convert path to standard format
normalize_path() {
    local path="$1"
    [[ "$path" == /* ]] && { echo "$path"; return; }
    if [[ "$path" =~ ^([A-Za-z]):\\(.+)$ ]]; then
        drive="${BASH_REMATCH[1],,}"
        rest="${BASH_REMATCH[2]}"
        rest="${rest//\\//}"
        echo "/$drive/$rest"
    else
        echo ""
    fi
}

# Check if path is remote (SSH)
is_remote_path() {
    [[ "$1" == /projects/* ]]
}

# Sync from remote server via SSH
sync_remote_skill() {
    local remote_path="$1"
    local skill_name=$(basename "$remote_path")
    skill_name="${skill_name%/}"

    # Skip single-letter and problematic directories
    [[ "$skill_name" =~ ^[a-z]$ ]] && return
    [[ "${skill_name,,}" == *"back"* ]] && return
    [[ "${skill_name,,}" == *"recycle"* ]] && return

    local target_subdir="$TARGET_DIR/$skill_name"

    # Check if SKILL.md or skill.md exists on remote
    if ssh -o StrictHostKeyChecking=no claude_ai@124.221.165.134 "[ -f '$remote_path/SKILL.md' ] || [ -f '$remote_path/skill.md' ]"; then
        mkdir -p "$target_subdir"
        # Copy all files from remote skill directory
        scp -o StrictHostKeyChecking=no -r "claude_ai@124.221.165.134:$remote_path/"* "$target_subdir/" 2>/dev/null
        echo "[UPDATED] $skill_name (from server)"
    else
        echo "[SKIP] $skill_name (not a skill directory)"
    fi
}

# Sync a single skill
sync_skill() {
    local src_path="$1"
    local skill_name=$(basename "$src_path")
    skill_name="${skill_name%/}"

    # Skip single-letter and problematic directories
    [[ "$skill_name" =~ ^[a-z]$ ]] && return
    [[ "${skill_name,,}" == *"back"* ]] && return
    [[ "${skill_name,,}" == *"recycle"* ]] && return

    # Handle remote paths
    if is_remote_path "$src_path"; then
        sync_remote_skill "$src_path"
        return
    fi

    if [[ -f "$src_path" ]]; then
        # Single file skill
        local target_file="$TARGET_DIR/$skill_name"
        if [[ ! -f "$target_file" ]] || [[ "$src_path" -nt "$target_file" ]]; then
            cp "$src_path" "$target_file"
            echo "[UPDATED] $skill_name"
        else
            echo "[OK] $skill_name (no change)"
        fi
    elif [[ -d "$src_path" ]]; then
        # Check if this directory IS a skill (contains SKILL.md)
        if [[ -f "$src_path/SKILL.md" ]] || [[ -f "$src_path/skill.md" ]]; then
            local target_subdir="$TARGET_DIR/$skill_name"
            mkdir -p "$target_subdir"

            local updated=false
            # Find files with proper filtering
            # Normalize src_path to ensure no trailing slash
            src_path="${src_path%/}"

            while IFS= read -r -d '' file; do
                # Skip problematic paths
                [[ "$file" == *"/BaiduNetdiskDownload/"* ]] && continue
                [[ "$file" == *"/back-up/"* ]] && continue
                [[ "$file" == *"/RECYCLE/"* ]] && continue
                [[ "$file" == *"$src_path"* ]] || continue

                # Get relative path - remove src_path prefix
                local rel_path="${file#$src_path}"
                rel_path="${rel_path#/}"

                local target_file="$target_subdir/$rel_path"
                local target_file_dir="$(dirname "$target_file")"

                mkdir -p "$target_file_dir"

                if [[ ! -f "$target_file" ]] || [[ "$file" -nt "$target_file" ]]; then
                    cp "$file" "$target_file"
                    echo "[UPDATED] $skill_name/$rel_path"
                    updated=true
                fi
            done < <(find -P "$src_path" -type f -print0 2>/dev/null)

            [[ "$updated" == "false" ]] && echo "[OK] $skill_name (no change)"
        else
            # Container directory - find subdirectories
            for subdir in "$src_path"/*/; do
                [[ -d "$subdir" ]] || continue
                sync_skill "$subdir"
            done
        fi
    fi
}

# Create target directory
mkdir -p "$TARGET_DIR"

# Clean existing stray directories
for item in "$TARGET_DIR"/[a-z]/; do
    [[ -d "$item" ]] && rm -rf "$item" 2>/dev/null
done

echo "========================================"
echo "Skill Sync Tool"
echo "========================================"
echo "Source: $LOCATIONS_FILE"
echo "Target: $TARGET_DIR"
echo ""

# Process each location
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue

    # Check if remote path
    if is_remote_path "$line"; then
        sync_skill "$line"
        continue
    fi

    src_path=$(normalize_path "$line")
    [[ -z "$src_path" ]] && continue
    [[ ! -e "$src_path" ]] && continue

    sync_skill "$src_path"
done < "$LOCATIONS_FILE"

echo ""
echo "========================================"
echo "Sync complete!"
echo "========================================"

# Final cleanup - remove stray directories
cd "$TARGET_DIR"
for dir in [a-z] [a-z][a-z]; do
    rm -rf "$dir" 2>/dev/null
done
# Force remove d just in case
rm -rf d 2>/dev/null
cd - >/dev/null
