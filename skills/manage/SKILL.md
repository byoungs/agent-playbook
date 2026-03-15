---
name: manage
description: Dashboard, health checks, and cleanup for the multi-agent system
disable-model-invocation: true
argument-hint: "[health | cleanup | collisions | stalled | reassign PEN-XX]"
---

## Manage agent work

**Requires:** Linear MCP server configured. Read the project's CLAUDE.md for Linear team name, project name, and workspace details.

Based on `$ARGUMENTS`:

### Default: Dashboard

1. Fetch all "In Progress" issues from the project specified in CLAUDE.md AND their comments (in parallel)
2. Show a compact table — one row per issue:

```
| Issue | Agent | Age | Last Comment | Status |
```

- **Agent**: extract from `[agent: NAME]` in comments. If none found, show "unnamed"
- **Age**: time since first "Claimed" comment
- **Last Comment**: relative time of most recent comment
- **Status**: "active" if comment < 2hrs ago, "STALLED" if > 2hrs

3. Below the table, show: `Queue: X todo, Y backlog`
4. If any stalled: `Stalled: /manage reassign PEN-XX`

Keep it short. No paragraphs, no recommendations unless asked.

### `health`: Full system health check

Run all checks in one shot and output a compact report with actionable commands for each problem found.

1. **Agent name collisions** — Fetch all "In Progress" issues and their comments. Scan for `[agent: NAME]` patterns. Flag any name that appears on multiple different issues.

2. **Stalled agents** — Issues "In Progress" with no comment in the last 2 hours.

3. **Orphaned worktrees** — Run `git worktree list` in the project root. For each worktree (excluding the main working tree), extract the branch name. Cross-reference with Linear issues: if the associated issue is Done, Cancelled, or doesn't exist, flag it as orphaned.

4. **Stale branches** — Run `git branch` in the project root. For branches that match Linear issue patterns (e.g., containing `pen-` or issue slugs), check the issue status. Flag branches whose issues are Done or not In Progress. Also flag branches with no commits in the last 7 days that aren't associated with any active issue.

5. **Unclaimed work** — Count of Todo and Backlog issues as a queue summary.

Format the output as sections with headers. For each problem found, include a suggested fix command:
- Orphaned worktree → `git worktree remove <path>`
- Stale branch → `git branch -D <name>`
- Stalled agent → `/manage reassign PEN-XX`
- Name collision → tell Brian which agents collide so he can rename one

If everything is clean, say so: `All clear. X agents active, Y items in queue.`

### `cleanup`: Interactive cleanup of stale worktrees and branches

1. Run `git worktree list` and `git branch` in the project root
2. Cross-reference each worktree and branch with Linear issue status (same logic as `health`)
3. For each orphaned/stale item, show:
   - Worktree path or branch name
   - Associated Linear issue (if any) and its status
   - Last commit date on that branch
4. Ask Brian which to clean up (list them numbered, or "all")
5. **Wait for Brian's response.** Do NOT clean up anything without approval.
6. For approved items: run `git worktree remove <path>` and/or `git branch -D <name>`
7. Confirm what was removed.

### `collisions`: Agent name collision check

Quick spot check for duplicate agent names:

1. Fetch all "In Progress" issues and their comments
2. Scan for `[agent: NAME]` patterns
3. Build a map of name → list of issues
4. If any name appears on multiple issues, report:
   ```
   COLLISION: "forge" claimed on PEN-42, PEN-57
   ```
5. If no collisions: `No collisions. Active agents: scout (PEN-42), cedar (PEN-57), ...`

### `stalled`: Just the stalled ones

Same as dashboard but only show issues with no comment activity in 2+ hours.

### `reassign PEN-XX`: Free up a task

1. Post comment: `"[agent: reassigned] Task freed up — previous agent stopped. Moving back to Todo."`
2. Move issue to "Todo"
3. Confirm: `PEN-XX moved to Todo.`
