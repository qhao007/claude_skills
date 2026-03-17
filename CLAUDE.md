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

## Adding New Skills

1. Edit `home_made_skill_locations.txt`
2. Add the path in Windows format: `c:\\path\\to\\skills`
3. Use wildcards for multiple skills: `c:\\Users\\haoq\\.claude\\skills\\dvv-*`
4. Run `./sync_skills.sh --dry-run` to preview, then `./sync_skills.sh` to sync

## Safety Features

- `--dry-run`: Preview what will be copied without copying
- `--limit N`: Set max files per skill (default: 500)
- `--max-size MB`: Set max size per skill in MB (default: 100)

## Skill Management

- Use `/sync-home-made-skill` skill for full sync workflow (sync + index + commit + push)
- Skills index is maintained in `skills_index.md`

## Git Conventions

- Local branch is `master`, remote is `main` - use `git push origin HEAD:main`
