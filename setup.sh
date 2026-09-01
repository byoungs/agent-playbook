#!/usr/bin/env bash
#
# Symlink agent-playbook skills, hooks, settings, and global CLAUDE.md into
# ~/.claude/ so they're available in every project.
#
# settings.json carries the permission allow/deny/ask lists and registers the
# hooks in hooks/. It holds no secrets, but it does hardcode absolute paths
# under $HOME, so it is machine-specific.
#
# Usage: bash setup.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DST="$HOME/.claude/skills"
HOOKS_SRC="$SCRIPT_DIR/hooks"
HOOKS_DST="$HOME/.claude/hooks"
CLAUDE_MD_SRC="$SCRIPT_DIR/CLAUDE.md"
CLAUDE_MD_DST="$HOME/.claude/CLAUDE.md"
SETTINGS_SRC="$SCRIPT_DIR/settings.json"
SETTINGS_DST="$HOME/.claude/settings.json"

mkdir -p "$SKILLS_DST" "$HOOKS_DST"

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

for hook_src in "$HOOKS_SRC"/*.sh; do
    [ -e "$hook_src" ] || continue
    hook_name="$(basename "$hook_src")"
    target="$HOOKS_DST/$hook_name"

    if [ -L "$target" ]; then
        echo "  update: $hook_name (replacing existing symlink)"
        rm "$target"
    elif [ -f "$target" ]; then
        echo "  backup: $hook_name (existing file moved to $hook_name.bak)"
        mv "$target" "$target.bak"
    else
        echo "  link: $hook_name"
    fi

    chmod +x "$hook_src"
    ln -s "$hook_src" "$target"
done

# Symlink settings.json (permissions + hook registrations)
if [ -L "$SETTINGS_DST" ]; then
    echo "  update: settings.json (replacing existing symlink)"
    rm "$SETTINGS_DST"
elif [ -f "$SETTINGS_DST" ]; then
    echo "  backup: settings.json (existing file moved to settings.json.bak)"
    mv "$SETTINGS_DST" "$SETTINGS_DST.bak"
fi
ln -s "$SETTINGS_SRC" "$SETTINGS_DST"
echo "  link: settings.json → ~/.claude/settings.json"

echo ""
echo "Done. Skills, hooks, settings, and global CLAUDE.md available via ~/.claude/"
echo "Run 'ls -la $SKILLS_DST $HOOKS_DST' to verify."
