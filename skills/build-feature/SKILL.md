---
name: build-feature
description: "End-to-end feature development: brainstorm → plan → review plan → execute with enhanced pipeline. Creates a Linear issue, works in a worktree, tracks progress in Linear throughout."
argument-hint: "<describe the feature>"
---

# Build Feature

End-to-end feature development pipeline. Creates a Linear issue for tracking, works in
an isolated worktree, guides the human through design and planning, then executes
autonomously with parallel reviews, synthesis critiquer, and compounding learning.

## Input

$ARGUMENTS

If no description provided, ask: "What do you want to build?"

## Phase 0: Setup (Linear + Worktree)

### Create Linear Issue
1. Read CLAUDE.md for the Linear team ID, project name, and workspace details.
2. Create an issue with:
   - **Title**: concise summary derived from the description (under 80 chars)
   - **Description**: the full `$ARGUMENTS` text, plus: `Created via /build-feature by [agent: NAME]`
   - **Team**: from CLAUDE.md
   - **Project**: from CLAUDE.md
   - **Status**: "In Progress"
3. Post a comment: `"[agent: NAME] Starting build-feature pipeline. Phases: brainstorm → plan → review → execute."`

Tell the user: "Created **ISSUE-ID: title** — tracking progress there."

### Enter Worktree
1. `EnterWorktree` — all work happens in isolation. Zero exceptions.

## Phase 1: Brainstorm (Human Participates)

Post Linear comment: `"[agent: NAME] Phase 1: Brainstorming design."`

Invoke the **brainstorming** skill. Explore the user's intent, ask clarifying questions
one at a time, propose 2-3 approaches, and converge on a design spec.

Write the approved design to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`.

**Do NOT proceed to Phase 2 until the human approves the design.**

Post Linear comment: `"[agent: NAME] Design approved. Spec: docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md"`

## Phase 2: Write Plan (Human Participates)

Post Linear comment: `"[agent: NAME] Phase 2: Writing implementation plan."`

Invoke the **writing-plans** skill. Translate the approved design into bite-sized,
agent-executable tasks.

Write the plan to `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`.

Present the plan to the human for approval.

**Do NOT proceed to Phase 3 until the human approves the plan.**

Post Linear comment: `"[agent: NAME] Plan approved. N tasks. Plan: docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md"`

## Phase 3: Review Plan (Autonomous)

Post Linear comment: `"[agent: NAME] Phase 3: Staff engineer plan review."`

Invoke the **review-plan** skill on the approved plan.

If the review returns **BLOCK**:
- Present blocking issues to the human
- Fix them in the plan
- Re-run the review
- Repeat until no blocking issues

If the review returns **APPROVE WITH CONCERNS**:
- Present concerns to the human
- Ask: "Want me to address any of these before executing, or proceed as-is?"
- If the human wants fixes, make them and re-review
- If the human says proceed, continue

If the review returns **APPROVE**:
- Continue to Phase 4

Post Linear comment: `"[agent: NAME] Plan review passed. Starting autonomous execution."`

## Phase 4: Execute (Autonomous)

Announce to the human:
```
Design approved. Plan approved. Plan reviewed. Starting autonomous execution.
I'll only surface if I hit a kickback or blocker. You'll get a session summary at the end.
```

Invoke the **enhanced-pipeline** skill with the plan file path.

The enhanced pipeline handles everything from here:
- Implementer dispatch with TDD
- Parallel reviews (spec, quality, security)
- Synthesis critiquer routing
- Kickback mechanism (LOCAL_FIX / PLANNING / DESIGN)
- Compounding learning

### Linear Updates During Execution
After each task completes, post a Linear comment:
`"[agent: NAME] Task N/M complete: [task name]. Review: [PASS/LOCAL_FIX cycles]. Cumulative: N/M tasks done."`

If a KICKBACK to PLANNING or DESIGN occurs, post:
`"[agent: NAME] KICKBACK to [target]. Reason: [reason]. Pausing for human input."`

## Phase 5: Finish (Human Reviews)

When all tasks complete (or pipeline stops):

1. Post Linear comment with the full session summary:
   ```
   [agent: NAME] Build complete.
   - Tasks: N/M completed
   - Review cycles: X total
   - Kickbacks: Y
   - CLAUDE.md changes: [list or "none"]
   - Branch: [branch name]
   - Ready for review.
   ```

2. Invoke the **finishing-a-development-branch** skill to present merge/PR options.

3. After the human chooses:
   - If merged or PR created: move Linear issue to "Done"
   - If kept as-is: leave issue "In Progress" with a comment noting the branch
   - If discarded: move issue to "Cancelled"

## Human Touchpoints

You ONLY need the human during:
- **Phase 1**: Design approval
- **Phase 2**: Plan approval
- **Phase 3**: Blocking issue resolution (if any)
- **Phase 4**: Only if a PLANNING/DESIGN kickback or retry limit is hit
- **Phase 5**: Merge/PR decision

Everything else is autonomous.
