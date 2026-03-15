---
name: manage
description: See what agents are working on, find stalled tasks, and reassign abandoned work
disable-model-invocation: true
argument-hint: "[optional: 'stalled' or 'reassign PEN-XX']"
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

### `stalled`: Just the stalled ones

Same as dashboard but only show issues with no comment activity in 2+ hours.

### `reassign PEN-XX`: Free up a task

1. Post comment: `"[agent: reassigned] Task freed up — previous agent stopped. Moving back to Todo."`
2. Move issue to "Todo"
3. Confirm: `PEN-XX moved to Todo.`
