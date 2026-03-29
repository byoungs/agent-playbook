---
name: dev-flow
description: "Configure how agents work in this project — trunk (direct to main) or worktree (isolated branches, review in wtr). Sets up hooks and CLAUDE.md accordingly."
argument-hint: "[trunk | worktree]"
---

# /dev-flow — Configure Your Development Flow

Choose how agents work in this project. The development pipeline (/dev, /harden, /stage)
runs the same either way — the flow controls where code goes and how it gets to main.

## The Two Flows

Present these options to the user if no argument was provided:

```
How should agents work in this project?

1. Trunk — Agents work directly on main. Commits land immediately.
   Fast and simple, but agents can step on each other if you run
   multiple in parallel. Best for solo work or early-stage projects.

2. Worktree — Each agent gets an isolated branch via git worktree.
   Parallel-safe. You review diffs in wtr and land with ff-only merge.
   Best once you're running multiple agents or want review before merge.
```

If `$ARGUMENTS` is "trunk" or "worktree", skip the prompt and use that directly.

## What Gets Configured

### For both flows

1. Read CLAUDE.md. If `## Build & Test` section is missing, ask the user for their
   build and test commands and add the section.

2. Write `.claude/settings.json` with hooks. **IMPORTANT:** Hooks must use the correct
   format — each entry has a `matcher` string and a `hooks` array of objects with
   `type` and `command` fields. Do NOT use a bare `"hook"` string — that is invalid.

   **Both flows get these hooks:**

   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash(git commit --amend*)",
           "hooks": [
             {
               "type": "command",
               "command": "branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); remote_head=$(git rev-parse origin/$branch 2>/dev/null); local_head=$(git rev-parse HEAD 2>/dev/null); if [ \"$remote_head\" = \"$local_head\" ]; then echo 'This commit has already been pushed. Create a new commit instead of amending.' && exit 2; fi"
             }
           ]
         }
       ],
       "PostToolUse": [
         {
           "matcher": "Write|Edit",
           "hooks": [
             {
               "type": "command",
               "command": "if [ -f Makefile ] && grep -q '^fmt:' Makefile; then make fmt 2>/dev/null; fi"
             }
           ]
         }
       ]
     }
   }
   ```

3. If `dev.env` doesn't exist and the project has code, offer to create:
   - `dev.env` (in git) with sensible defaults
   - `.env` (gitignored) for secrets
   - Add `.env` to `.gitignore` if not already there

4. If `## Linear` doesn't exist in CLAUDE.md, ask if this project uses Linear
   and add the section if yes.

### Worktree flow only (in addition to the above)

5. Add a PreToolUse hook to prevent ALL commits on main:

   ```json
   {
     "matcher": "Bash(git commit*)",
     "hooks": [
       {
         "type": "command",
         "command": "branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); if [ \"$branch\" = \"main\" ]; then echo 'Do not commit directly to main. Use EnterWorktree first, or run /dev to start the pipeline.' && exit 2; fi"
       }
     ]
   }
   ```

   Add this to the `PreToolUse` array alongside the amend-protection hook.

9. Add to CLAUDE.md:
   ```markdown
   ## Dev Flow
   Flow: worktree
   - All code changes happen in worktrees, never on main
   - Use /dev to start work (creates worktree automatically)
   - Use /stage to wrap up (prepares clean commit for wtr landing)
   - Brian reviews and lands via wtr (ff-only merge → validate → push)
   ```

### Trunk flow only (in addition to the shared config)

8. Add to CLAUDE.md:
   ```markdown
   ## Dev Flow
   Flow: trunk
   - Agents work directly on main
   - Commit and push when done
   - Never amend a commit that has already been pushed
   - Keep commits small and focused — other agents may be working too
   ```

## Advancing the Flow

When running `/dev-flow` in a project that already has a flow configured:

1. Show the current flow: "This project is on **trunk** flow."
2. If changing to worktree, explain what will change:
   - "I'll add a hook to prevent commits on main"
   - "You'll need to use /dev or EnterWorktree to start work"
   - "Use wtr to review and land branches"
3. If changing to trunk, explain:
   - "I'll remove the main-branch protection hook"
   - "Agents will commit directly to main"
4. Update `.claude/settings.json` and CLAUDE.md accordingly.

## Report

After configuration:
```
Project configured for [trunk|worktree] flow:
- Hooks: [list what was configured]
- CLAUDE.md: [sections added/updated]
- Env files: [created or already existed]

Next: run /dev to start working, or /harden to review existing code.
```
