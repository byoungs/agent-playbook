---
name: tidy
description: "Clean up dead worktrees, stale branches, orphaned Linear tasks, and general project hygiene."
argument-hint: "[optional: project path]"
---

# /tidy — Project Hygiene

Clean up the mess. Dead worktrees, stale branches, orphaned Linear tasks,
lingering WIP commits. Run this periodically or when things feel cluttered.

## Input

$ARGUMENTS

If a project path is provided, tidy that project. Otherwise, tidy the current directory.

## Step 1: Worktree Audit

1. Run `git worktree list` to see all worktrees.
2. For each non-main worktree:
   - Is the branch still relevant? Check if it has unmerged commits.
   - Is it clean (no uncommitted changes)?
   - Has it been inactive? (Check last commit date.)
3. Report findings:
   - **Mergeable**: branch is clean, rebased, ready to land
   - **Stale**: no commits in >7 days, likely abandoned
   - **Dirty**: has uncommitted changes that need attention
   - **Orphaned**: worktree directory exists but branch is gone (or vice versa)

For stale/orphaned worktrees, ask: "Delete these? [list]" Wait for confirmation.

## Step 2: Branch Audit

1. Run `git branch` to see all local branches.
2. Identify branches with no worktree that are:
   - Already merged to main → safe to delete
   - Not merged but no recent commits → likely abandoned
3. Report and ask before deleting.

## Step 3: Linear Task Audit

**Requires:** Linear MCP server configured. Read CLAUDE.md for Linear details.

1. List "In Progress" issues for the team.
2. For each:
   - Does the branch still exist?
   - Is there a worktree?
   - Last activity date?
3. Identify:
   - **Orphaned tasks**: "In Progress" but no branch/worktree exists
   - **Completed but not closed**: branch merged to main but issue still open
   - **Blocked**: no activity in >3 days
4. For orphaned/completed tasks, propose status changes. Wait for confirmation.

## Step 4: General Hygiene

1. Check for leftover WIP commits on main (e.g., "WIP: partial Task N before kickback")
2. Check for untracked files that look like artifacts (*.tmp, *.bak, .DS_Store not in .gitignore)
3. Check if CLAUDE.md has a `## Learned Patterns` section — if not, note it

## Step 5: Report

```
## Tidy Report

### Worktrees
- [N] active, [N] stale, [N] orphaned
- Actions taken: [list]

### Branches
- [N] merged (deleted), [N] stale (flagged)

### Linear Tasks
- [N] in progress, [N] orphaned, [N] completed-but-open
- Actions taken: [list]

### Hygiene
- [observations]
```
