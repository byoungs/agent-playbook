# Enhanced Agentic Pipeline Architecture

> Designed 2026-03-27. Based on competitive analysis of ClawMux, Boris Cherny's workflow, and practitioner research.

## Design Philosophy

Three approaches to agent quality, combined:
- **Discipline via prompts** (from superpowers) — iron laws for TDD, verification, debugging
- **Throughput + synthesis** (from Boris) — parallel reviews, dedup agent, compounding learning
- **Routing via state machine** (from ClawMux) — kickback mechanism for structural issues

## The Full Pipeline

```
Human intent
    |
Brainstorming (design spec)                          [superpowers]
    |
Writing Plans (bite-sized tasks)                      [superpowers]
    |
/review-plan (staff engineer review)                  [custom skill]
    | (fix blocking issues, re-review if needed)
    |
[Per task in plan:]
    |
+-- Implementer (TDD + existing self-review)          [superpowers template]
|      |
|  +-- Spec Reviewer --------+
|  +-- Code Quality Reviewer -+  (parallel dispatch)  [superpowers templates]
|  +-- Security Reviewer -----+                        [custom skill]
|      |
|  Synthesis Critiquer                                 [custom skill]
|      |
|  +-- PASS -> task complete
|  +-- LOCAL_FIX -> Implementer (max 3 cycles)
|  |     +-- after 3 failures -> auto-KICKBACK to PLANNING
|  +-- KICKBACK ->
|        +-- to PLANNING (pause, surface to human)
|        +-- to DESIGN (pause, surface to human)
|
|  [After every 3 tasks or final task:]
|  Compounding Learner                                 [custom skill]
|      +-- Code patterns -> propose CLAUDE.md updates
|      +-- Permission patterns -> ALLOW / GUIDE / FLAG
|      +-- Workflow observations -> session summary
|
+-- Next task
       |
Session Summary (all compounding changes announced)
```

## Key Design Decisions

### 1. Collapsed LOCAL_FIX / KICKBACK to IMPLEMENTATION

Originally had 5 verdicts. Review found that LOCAL_FIX and KICKBACK to IMPLEMENTATION had identical routing behavior. Collapsed to 4 verdicts: PASS, LOCAL_FIX, KICKBACK to PLANNING, KICKBACK to DESIGN.

### 2. Aggressive Critiquer

The critiquer is instructed to be aggressive with kickbacks because it's the synthesis of 3 independent reviewers, not a single opinion. "When in doubt between LOCAL_FIX and KICKBACK, choose KICKBACK."

### 3. Learner Reports, Orchestrator Applies

The compounding learner does NOT edit CLAUDE.md itself. It outputs proposed changes; the orchestrator applies them. This prevents the learner subagent from making uncontrolled edits and gives the orchestrator visibility.

### 4. Parallel Reviews Override Sequential Model

The superpowers code-quality-reviewer says "Only dispatch after spec compliance review passes." Our pipeline intentionally overrides this — all three reviewers run in parallel. The synthesis critiquer handles cross-reviewer dependencies.

### 5. Permission Learning is Best-Effort

Claude Code doesn't expose a programmatic API for permission events. The orchestrator manually logs what it observes. Missing events from subagents is acceptable — primary value comes from code pattern learning.

### 6. Autonomy Model

Human engages during brainstorming and planning only. After plan approval, pipeline runs autonomously. Human surfaced only on:
- KICKBACK to PLANNING or DESIGN
- Retry limit exceeded
- Implementer reports BLOCKED
- Genuinely ambiguous situations

## What We Reuse vs. Build

| Component | Source |
|---|---|
| Brainstorming | superpowers (reuse) |
| Writing Plans | superpowers (reuse) |
| Plan Review | custom skill (built) |
| TDD | superpowers (reuse) |
| Implementer dispatch | superpowers template (reuse) |
| Spec reviewer | superpowers template (reuse) |
| Code quality reviewer | superpowers template (reuse) |
| Security reviewer | custom skill (built) |
| Synthesis critiquer | custom skill (built) |
| Compounding learner | custom skill (built) |
| Enhanced pipeline orchestration | custom skill (built) |
| Verification | superpowers (reuse) |
| Systematic debugging | superpowers (reuse) |
| Finishing branch | superpowers (reuse) |

## Retry Limits

| Situation | Limit | Escalation |
|---|---|---|
| LOCAL_FIX per task | 3 | Auto → KICKBACK to PLANNING |
| PLANNING kickbacks per session | 2 | Pause, surface to human |
| DESIGN kickbacks per session | 1 | Full stop |

## Skills Location

All custom skills in `~/.claude/skills/`:
- `review-plan/SKILL.md`
- `security-reviewer/SKILL.md`
- `synthesis-critiquer/SKILL.md`
- `compounding-learner/SKILL.md`
- `enhanced-pipeline/SKILL.md`
