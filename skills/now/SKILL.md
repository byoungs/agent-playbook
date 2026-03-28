---
name: now
description: Create a Linear task from a description, claim it, enter a worktree, and start planning
argument-hint: "<describe the task>"
---

## Start working on something right now

For work that isn't in Linear yet. Creates the issue, claims it, and drops you into a worktree in plan mode.

**Requires:** Linear MCP server configured. Read the project's CLAUDE.md for Linear team name, project name, and workspace details.

### Step 1: Validate input

`$ARGUMENTS` is the task description. If empty, ask the user: "What do you need done?" and **STOP**.

### Step 2: Create the Linear issue

1. Read CLAUDE.md for the Linear team ID and project ID. Fetch them via MCP if needed.
2. Create an issue with:
   - **Title**: concise summary derived from the description (under 80 chars)
   - **Description**: the full `$ARGUMENTS` text, plus a note: `Created via /now by [agent: NAME]`
   - **Team**: from CLAUDE.md
   - **Project**: from CLAUDE.md
   - **Status**: "In Progress" (claim immediately on creation)
3. Post a comment: `"[agent: NAME] Claimed. Starting work from main at COMMIT_HASH."`

Tell the user: "Created **PEN-XX: title** and claimed it."

### Step 3: Enter worktree + plan mode

**ALL code changes in a worktree. Zero exceptions.**

1. `EnterWorktree`
2. `EnterPlanMode`

Tell the user you're in plan mode and ready to design the approach. Then start Step 4.

### Step 4: Understand and plan

1. Read relevant files to understand current state
2. Present to the user:
   - **Summary**: your understanding of what needs to be done
   - **Current state**: what exists in code today
   - **Proposed approach**: files to modify/create, tests, validation gates
   - **Risks**: shared files, breaking changes, anything that needs coordination
3. **STOP and wait for user approval before writing any code.**

### Step 5: Execute (after user approves)

1. `ExitPlanMode`
2. Implement, write tests, validate
3. Run the project's build and test commands (check CLAUDE.md for specifics)
4. Commit with issue ID in the message

### Step 6: Close out

1. Move issue to "Done"
2. Post comment: `"[agent: NAME] Done. Branch: BRANCH. What was done: ... Follow-up: ..."`
3. Tell user what's done and what needs attention
