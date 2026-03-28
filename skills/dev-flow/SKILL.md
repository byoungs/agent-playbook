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

2. Configure auto-format hook in `.claude/settings.json`:
   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Write|Edit",
           "hook": "Run the project formatter if one exists (check CLAUDE.md, package.json, or Makefile for format/lint commands)"
         }
       ]
     }
   }
   ```

3. Configure auto-test hook:
   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Bash(git commit*)",
           "hook": "Run the project's test command from CLAUDE.md Build & Test section. Report results but don't block the commit."
         }
       ]
     }
   }
   ```

4. Prevent amending pushed commits:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash(git commit --amend*)",
           "hook": "Check if HEAD has been pushed to origin (compare HEAD against origin/current-branch). If HEAD is already on origin, block with: 'This commit has already been pushed. Create a new commit instead of amending.' Exit code 2 to block."
         }
       ]
     }
   }
   ```

6. If `dev.env` doesn't exist and the project has code, offer to create:
   - `dev.env` (in git) with sensible defaults
   - `.env` (gitignored) for secrets
   - Add `.env` to `.gitignore` if not already there

7. If `## Linear` doesn't exist in CLAUDE.md, ask if this project uses Linear
   and add the section if yes.

### Worktree flow only (in addition to the above)

8. Add a hook to prevent ALL commits on main (not just amend — any commit):
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash(git commit*)",
           "hook": "Check if on main branch. If yes, block with: 'Do not commit directly to main. Use EnterWorktree first, or run /dev to start the pipeline.' Exit code 2 to block."
         }
       ]
     }
   }
   ```

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
