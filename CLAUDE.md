# CLAUDE.md

This file provides guidance for working with this project.

## Project Overview

This is a skill management repository that syncs home-made skills from various locations into a centralized `skills/` directory for version control.

## Files

- `sync_skills.sh` - Sync script that copies skills from分散 locations to `skills/` directory
- `home_made_skill_locations.txt` - Index file containing source paths for skills
- `skills/` - Target directory containing all synced skills

## Usage

Run the sync script to check for updates:
```bash
./sync_skills.sh
```

## Known Issues

### Strange "d" Directory Appears

There is a persistent issue where an unwanted `d/` directory (containing `BaiduNetdiskDownload`) appears in the `skills/` directory after running the sync script, even though:

1. The source paths in `home_made_skill_locations.txt` do not contain this path
2. Various filtering logic has been added to skip such directories

This appears to be a Git Bash/Windows filesystem interaction bug. The directory is automatically created during script execution and reappears even after deletion.

**Workaround:**
- The `d/` directory is excluded via `.gitignore`
- Manually delete if needed: `rm -rf skills/d`
- Or add a post-sync cleanup step in your workflow

## Adding New Skills

1. Edit `home_made_skill_locations.txt`
2. Add the path (Unix/Git Bash format, e.g., `/d/claude_workspace/...`)
3. Run `./sync_skills.sh` to sync
