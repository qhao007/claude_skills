# sync-home-made-skill

## Description

同步并管理本地自建skill的工作流技能。

执行以下步骤：
1. 运行 `sync_skills.sh` 同步所有skill
2. 生成技能索引文件 `skills_index.md`，包含每个技能的名称、描述、版本、更新日期等信息
3. 提交所有更改到本地git仓库
4. 推送到远程仓库

## Usage

```bash
./sync-home-made-skill.sh
```

## Requirements

- 已初始化git仓库
- 已配置远程仓库
- `sync_skills.sh` 脚本存在于项目根目录

## Output

- `skills_index.md` - 技能索引文件
- git commit with all changes
- pushed to remote
