#!/usr/bin/env bash
#
# Symlink agent-playbook skills and global CLAUDE.md into ~/.claude/
# so they're available in every project.
#
# Usage: bash setup.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"
CLAUDE_MD_SRC="$SCRIPT_DIR/CLAUDE.md"
CLAUDE_MD_DST="$HOME/.claude/CLAUDE.md"

mkdir -p "$SKILLS_DST"

# Symlink global CLAUDE.md
if [ -L "$CLAUDE_MD_DST" ]; then
    echo "  update: CLAUDE.md (replacing existing symlink)"
    rm "$CLAUDE_MD_DST"
elif [ -f "$CLAUDE_MD_DST" ]; then
    echo "  backup: CLAUDE.md (existing file moved to CLAUDE.md.bak)"
    mv "$CLAUDE_MD_DST" "$CLAUDE_MD_DST.bak"
fi
ln -s "$CLAUDE_MD_SRC" "$CLAUDE_MD_DST"
echo "  link: CLAUDE.md → ~/.claude/CLAUDE.md"

for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    target="$SKILLS_DST/$skill_name"

    if [ -L "$target" ]; then
        echo "  update: $skill_name (replacing existing symlink)"
        rm "$target"
    elif [ -d "$target" ]; then
        echo "  skip: $skill_name (directory exists — remove manually to use symlink)"
        continue
    else
        echo "  link: $skill_name"
    fi

    ln -s "$skill_dir" "$target"
done

echo ""
echo "Done. Skills and global CLAUDE.md available via ~/.claude/"
echo "Run 'ls -la $SKILLS_DST' to verify."
