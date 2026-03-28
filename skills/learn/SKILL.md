---
name: learn
description: "Analyze recent work for recurring patterns and permission issues. Proposes CLAUDE.md updates and permission rule changes to make future sessions smarter."
argument-hint: "[optional: focus area or 'permissions']"
---

# /learn — Compounding Learning

Make the system smarter. Analyze recent review findings, permission events, and
workflow patterns to detect recurring issues, then propose CLAUDE.md rules and
permission changes to prevent them.

Run this after completing work, or anytime you want to reduce friction
(especially permission prompts).

## Input

$ARGUMENTS

- If empty: analyze the current session's work (git log, recent changes, any review findings in context)
- If "permissions": focus specifically on permission patterns and propose allow rules
- If a specific topic: focus analysis on that area

## What To Analyze

### A. Code Pattern Learning

1. Look at recent git history (`git log -20 --oneline`) and recent changes.
2. Read the project's CLAUDE.md for existing learned patterns.
3. Identify recurring themes:
   - Are agents making the same category of mistake repeatedly?
   - Are there patterns in review findings (if any review data is in context)?
   - Are there code conventions that should be documented but aren't?
4. For each pattern detected:
   - Draft a specific, actionable CLAUDE.md rule
   - Not "write better code" but "always add database indexes on foreign key columns"
   - Output as: `Proposed CLAUDE.md addition: "[exact text]"`

### B. Permission Pattern Learning

1. Think about what permission prompts have been occurring in this project.
2. For each pattern:
   - **ALLOW**: Safe, repetitive command. Propose an exact allow rule for settings.json.
     (e.g., `Bash(git stash)`, `Bash(go test ./...)`)
   - **GUIDE**: Agent didn't need to do this. Propose a CLAUDE.md rule teaching an alternative.
   - **FLAG**: Genuinely risky. Note it but take no action.
3. Common safe patterns to look for:
   - `git` commands (stash, rebase, log, diff, branch)
   - Build/test commands (go test, npm test, make build)
   - File operations within the project directory
   - `rm` within project dir, `/tmp/`, or `.worktrees/`

### C. Workflow Pattern Learning

- Do certain types of tasks consistently trigger review cycles?
- Are there workflow friction points that a new skill or rule could prevent?
- Should any heuristics be added to plan review?

## Application Rules

You REPORT proposed changes. Present them to the human for approval.

- **CLAUDE.md additions**: present each proposed rule. Wait for human approval before editing.
- **Permission ALLOW proposals**: list the exact rule syntax for settings.json. Do NOT auto-modify settings.json — the human applies these.
- **Workflow observations**: note for discussion, no auto-action.

## Output Format

```
## Learning Report

### Code Patterns
- [pattern]: [proposed rule]
(or "No patterns detected.")

### Permission Proposals
- [command pattern]: ALLOW | GUIDE | FLAG
  Rule: [exact settings.json syntax or CLAUDE.md text]
  Reasoning: [why]
(or "No permission patterns identified.")

### Workflow Observations
- [observation]
(or "No workflow patterns detected.")

### Recommended Actions
1. [specific action for human to take]
```
