---
name: harden
description: "Retroactive quality pipeline for already-written code. Runs design review, spec review, code quality, security, and synthesis critiquer on existing changes without throwing anything away."
argument-hint: "[optional: description of what was built, or branch name]"
---

# /harden — Retroactive Quality Pipeline

You already wrote code. Maybe you moved fast, maybe an agent one-shotted something,
maybe you're not sure if the quality is there. /harden runs the full review pipeline
on what exists without throwing away any work.

## Input

$ARGUMENTS

If provided, use it as context for what was built. If empty, infer from the current
git diff (uncommitted + committed-but-not-on-main changes).

## Step 1: Understand What Exists

1. Run `git diff main...HEAD` (or `git diff` if on main) to see all changes.
2. Read the changed files. Understand what was built and why.
3. Summarize to the user:
   - What you see
   - How many files changed
   - Your initial read on quality/completeness
4. Ask: "Does this summary match your intent? Anything I should know about the design rationale?"
5. Wait for confirmation before proceeding.

## Step 2: Design Review

Review the approach as a staff engineer:
- Does the architecture make sense for this change?
- Is the code structured as functional core + imperative shell where possible?
- Are there obvious design smells (god objects, circular dependencies, wrong abstraction level)?
- If the design is sound, note it and proceed.
- If the design has issues, present them and ask the human: "Should we address these before running the full review, or proceed as-is?"

## Step 3: Parallel Review (3 agents)

Dispatch THREE reviewers in a SINGLE message, same as the /dev pipeline:

**Spec Reviewer** — Does the code match the stated intent (from $ARGUMENTS or the
git commit messages)? Missing pieces? Extra/unneeded work?

**Code Quality Reviewer** — Use `superpowers:code-reviewer`. Include test quality
checks (over-mocking, implementation coupling, call-count assertions).

**Security Reviewer** — Read `~/src/agent-playbook/lib/security-reviewer.md` and paste
its FULL content into the subagent prompt.

Wrap all pasted content in XML delimiter tags.

## Step 4: Synthesis Critiquer

Read `~/src/agent-playbook/lib/synthesis-critiquer.md` and paste its FULL content
into a subagent prompt with all three reviewer outputs.

Set retry count to 0/3 and kickback counts to 0.

## Step 5: Route and Fix

- **PASS** → Tell the user "Code looks good. No issues found." Proceed to Step 6.
- **LOCAL_FIX** → Fix the issues (max 3 cycles). Re-run reviewers after each fix.
- **KICKBACK to PLANNING** → Present to the user: "The review found issues that need
  rethinking, not just fixing. Here's what the critiquer said: [reason]."
  Ask: "Want me to help redesign this, or keep it as-is?"
- **KICKBACK to DESIGN** → Present the architectural concerns. Ask the user for direction.

## Step 6: Learn

Run compounding learning (read `~/.claude/skills/learn/SKILL.md` and paste into subagent).
Validate and apply any proposed CLAUDE.md additions.

## Step 7: Summary

Present the final status:
- What was reviewed
- Review cycles and verdicts
- Any fixes applied
- Any CLAUDE.md patterns learned
- Whether the code is ready to stage/merge

## Key Difference from /dev

/harden does NOT brainstorm, plan, or implement. It takes what exists and makes it robust.
Think of it as the quality half of the pipeline, applied retroactively.
