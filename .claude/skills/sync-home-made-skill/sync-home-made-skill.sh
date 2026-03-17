#!/bin/bash
# sync-home-made-skill workflow
# 1. Sync skills
# 2. Generate index
# 3. Commit
# 4. Push

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Parent directory (project root)
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$PROJECT_DIR/skills"
INDEX_FILE="$PROJECT_DIR/skills_index.md"

echo "========================================"
echo "Sync Home Made Skill Workflow"
echo "========================================"
echo ""

# Step 1: Sync skills
echo "[1/4] Syncing skills..."
if [[ -f "$PROJECT_DIR/sync_skills.sh" ]]; then
    cd "$PROJECT_DIR"
    ./sync_skills.sh
    echo ""
else
    echo "Error: sync_skills.sh not found"
    exit 1
fi

# Step 2: Generate index
echo "[2/4] Generating skills index..."

# Remove d directory if exists
rm -rf "$SKILLS_DIR/d" 2>/dev/null

cat > "$INDEX_FILE" << 'EOF'
# Skills Index

Generated on: $(date '+%Y-%m-%d %H:%M:%S')

## Skills List

EOF

# Add timestamp
sed -i "s/\$(date '+%Y-%m-%d %H:%M:%S')/$(date '+%Y-%m-%d %H:%M:%S')/" "$INDEX_FILE"

# Find all skill directories
for skill_dir in "$SKILLS_DIR"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name=$(basename "$skill_dir")

    # Skip hidden or system directories
    [[ "$skill_name" == .* ]] && continue
    [[ "$skill_name" =~ ^[a-z]$ ]] && continue

    # Get description from SKILL.md or skill.md
    description="No description"
    skill_md=""
    if [[ -f "$skill_dir/SKILL.md" ]]; then
        skill_md="$skill_dir/SKILL.md"
    elif [[ -f "$skill_dir/skill.md" ]]; then
        skill_md="$skill_dir/skill.md"
    fi

    if [[ -n "$skill_md" ]]; then
        # Extract third line (first line after title and empty line)
        description=$(sed -n '3p' "$skill_md" 2>/dev/null | sed 's/^# *//' | xargs | head -c 200)
        [[ -z "$description" ]] && description="No description"
    fi

    # Get version (look for version in SKILL.md)
    version="Unknown"
    if [[ -f "$skill_dir/SKILL.md" ]]; then
        version_match=$(grep -i "^version:" "$skill_dir/SKILL.md" 2>/dev/null | head -1)
        if [[ -n "$version_match" ]]; then
            version=$(echo "$version_match" | cut -d: -f2 | tr -d ' ')
        fi
    fi

    # Get last update date (from most recent file)
    last_update="Unknown"
    if [[ -d "$skill_dir" ]]; then
        latest_file=$(find "$skill_dir" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1)
        if [[ -n "$latest_file" ]]; then
            timestamp=$(echo "$latest_file" | cut -d. -f1)
            last_update=$(date -d "@$timestamp" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "Unknown")
        fi
    fi

    # Count files
    file_count=$(find "$skill_dir" -type f 2>/dev/null | wc -l)

    # Write to index
    cat >> "$INDEX_FILE" << INDEXEOF
### $skill_name

- **Description**: $description
- **Version**: $version
- **Last Updated**: $last_update
- **Files**: $file_count

INDEXEOF

done

echo "  Generated: $INDEX_FILE"

# Step 3: Commit
echo "[3/4] Committing changes..."

cd "$PROJECT_DIR"

# Check if git is initialized
if [[ ! -d ".git" ]]; then
    echo "  Initializing git repository..."
    git init
fi

# Check for remote
if ! git remote geturl origin &>/dev/null; then
    echo "  Warning: No remote configured, skipping push"
    SKIP_PUSH=true
else
    SKIP_PUSH=false
fi

# Add files
git add sync_skills.sh home_made_skill_locations.txt CLAUDE.md skills_index.md

# Add skills directory (excluding d)
git add skills/
# Remove d from staging if it was added
git reset skills/d 2>/dev/null || true

# Check for changes
if git diff --cached --quiet; then
    echo "  No changes to commit"
else
    # Get commit message with date
    commit_msg="Update skills - $(date '+%Y-%m-%d')"
    git commit -m "$commit_msg"
    echo "  Committed: $commit_msg"
fi

# Step 4: Push
if [[ "$SKIP_PUSH" == "true" ]]; then
    echo "[4/4] Skipping push (no remote configured)"
else
    echo "[4/4] Pushing to remote..."
    git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null
fi

echo ""
echo "========================================"
echo "Workflow complete!"
echo "========================================"
