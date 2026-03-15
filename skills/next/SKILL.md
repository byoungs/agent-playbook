---
name: next
description: Pick up the next most important Linear task, understand it deeply, then plan and execute in a worktree
disable-model-invocation: true
argument-hint: "[optional: issue ID like PEN-55]"
---

## Pick up the next task from Linear

**Requires:** Linear MCP server configured. Read the project's CLAUDE.md for Linear team name, project name, and workspace details.

### Step 0: Name

If you don't have an agent name yet, run `/name-agent` first. Your name goes in all Linear comments and commits.

### Step 1: Find the task

If `$ARGUMENTS` has an issue ID, fetch that. Otherwise:

1. List "Todo" and "In Progress" issues in the project specified in CLAUDE.md (in parallel)
2. Skip In Progress issues (already claimed) and blocked issues
3. If no Todo issues, check Backlog by priority
4. Pick highest-priority unblocked unclaimed issue
5. Tell user: "Picking up **PEN-XX: title** (priority, reason)"

### Step 2: Claim immediately

**Claim BEFORE research.** This prevents two agents grabbing the same task.

1. Move issue to "In Progress"
2. Post comment: `"[agent: NAME] Claimed. Starting investigation from main at COMMIT_HASH."`

If already In Progress → someone beat you. Pick next task.

### Step 3: Understand the task

1. Read full issue description + comments + relations
2. Check sibling In Progress issues for file conflicts
3. Read the files you'll modify — understand current state
4. Identify unknowns and assumptions

### Step 4: Ask questions

Present to user:
- **Summary**: your understanding (not restating the issue)
- **Current state**: what exists in code today
- **Questions**: anything ambiguous or unclear
- **Risks**: shared files, breaking changes

**STOP and wait for answers.**

### Step 5: Plan

After user answers:
1. Create implementation plan (files, approach, tests, validation gates)
2. Get user approval
3. Post approved plan as comment: `"[agent: NAME] Plan: ..."`

### Step 6: Execute in worktree

**ALL code changes in a worktree. Zero exceptions.**

1. `EnterWorktree`
2. Implement, write tests, validate
3. Run the project's build and test commands (check CLAUDE.md for specifics)
4. Commit: message must include issue ID and `Agent: NAME`
5. `ExitWorktree`

### Step 7: Close out

1. Move issue to "Done"
2. Post comment: `"[agent: NAME] Done. Branch: BRANCH. What was done: ... Follow-up: ..."`
3. Tell user what's done and what needs attention
