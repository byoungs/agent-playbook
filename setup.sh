#!/usr/bin/env bash
#
# Symlink agent-playbook skills into ~/.claude/skills/
# so they're available in every project.
#
# Usage: bash setup.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"

mkdir -p "$SKILLS_DST"

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
echo "Done. Skills available in all projects via ~/.claude/skills/"
echo "Run 'ls -la $SKILLS_DST' to verify."
