---
name: team-dash
description: One-shot dashboard showing agent team status, health, and problems
disable-model-invocation: true
---

## Team dashboard

**Requires:** Linear MCP server configured. Read the project's CLAUDE.md for Linear team name, project name, and workspace details.

Run everything below in one shot and present a single, compact report. After showing the dashboard, stay conversational — Brian will ask for follow-up actions (cleanup, reassign, etc.) in chat.

### 1. Active work

Fetch all "In Progress" issues from the project AND their comments (in parallel). Show a table:

```
| Issue | Title | Agent | Age | Last Update | Status |
```

- **Agent**: extract from `[agent: NAME]` in comments. "unnamed" if none found.
- **Age**: time since first "Claimed" comment
- **Last Update**: relative time of most recent comment
- **Status**: "active" if comment < 2hrs ago, "STALLED" if > 2hrs

### 2. Name collisions

From the comments already fetched, scan for `[agent: NAME]` patterns. If any name appears on multiple different In Progress issues, flag it:
```
COLLISION: "forge" on PEN-42, PEN-57
```

### 3. Orphaned worktrees

Run `git worktree list` in the project root. For each worktree (excluding main working tree), extract the branch name. Cross-reference with Linear: flag worktrees whose associated issue is Done, Cancelled, or doesn't exist.

### 4. Stale branches

Run `git branch` in the project root. For branches matching Linear patterns (e.g., containing `pen-`), check issue status. Flag branches whose issues are Done or not In Progress. Also flag branches with no commits in 7+ days that aren't tied to an active issue.

### 5. Queue

Count of Todo and Backlog issues.

### Output format

```
## Active (N agents)
| Issue   | Title              | Agent  | Age  | Last Update | Status  |
| PEN-42  | Build admin UI     | scout  | 3h   | 12m ago     | active  |
| PEN-57  | Email templates    | cedar  | 5h   | 3h ago      | STALLED |

## Problems
- COLLISION: "forge" on PEN-42, PEN-57
- STALLED: PEN-57 (cedar) — no update in 3h
- ORPHANED WORKTREE: /tmp/worktree-pen-31 — issue PEN-31 is Done
- STALE BRANCH: pen-28-old-feature — issue Done, last commit 12d ago

## Queue
4 todo, 12 backlog
```

If no problems: `No problems found.`

After displaying, Brian will chat about what to do. Common follow-ups:
- "clean up those worktrees" → run `git worktree remove` for the flagged ones (confirm first)
- "reassign PEN-57" → post comment `[agent: reassigned] Task freed up — previous agent stopped.`, move to Todo
- "delete those branches" → run `git branch -D` for flagged ones (confirm first)

Handle these conversationally — no sub-commands needed.
