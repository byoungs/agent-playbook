# Pipeline Comparison Matrix

> Created 2026-03-27. Compares our enhanced pipeline against ClawMux, Boris's workflow, and the superpowers baseline.

## Stage-by-Stage Comparison

| Pipeline Stage | Our Enhanced Pipeline | Superpowers (baseline) | ClawMux | Boris's Workflow |
|---|---|---|---|---|
| Task intake / validation | /review-plan skill | Brainstorming (creative, not validation) | Dedicated Intake Agent (read-only) | Plan Mode, sometimes 2nd Claude as staff eng |
| Design / architecture | Brainstorming skill (superpowers) | Same | Design Agent (read-only) | Plan Mode |
| Implementation planning | Writing-plans skill (superpowers) | Same | Planning Agent (read+execute) | Informal |
| Plan review | /review-plan (staff eng persona) | Self-review checklist only | Not separate | Sometimes 2nd Claude reviews |
| Implementation | Subagent with TDD + self-review | Same | Implementation Agent (full access) | Auto-accept, one-shot |
| Spec compliance review | Parallel (superpowers template) | Serial, dedicated | Not separate | Not separate |
| Code quality review | Parallel (superpowers template) | Serial, dedicated | Code Quality Agent | Parallel review agents |
| Security review | Parallel (custom skill) | **Missing** | Security Review Agent (read-only) | Not explicit |
| Review synthesis | Synthesis Critiquer (custom) | **Missing** | Not present | Dedup agent (~80% bug catch) |
| Kickback mechanism | Via critiquer (3 targets) | **Missing** | Individual reviewers (validated targets) | Not present |
| TDD discipline | Enforced (iron law) | Enforced (iron law) | Not enforced | "Claude tests every change" |
| Debugging methodology | Systematic debugging (superpowers) | Same | Not addressed | Not addressed |
| Verification | Verification-before-completion | Same | Not explicit | "Most important step" |
| Compounding learning | Custom skill (auto CLAUDE.md) | Manual CLAUDE.md only | Not present | Auto lint rules + CLAUDE.md |
| Branch integration | Finishing-a-development-branch | Same | Not addressed (manages task state) | /commit-push-pr |

## Strengths by System

**Our Enhanced Pipeline:**
- Most rigorous discipline (TDD iron law, verification, debugging)
- Synthesis critiquer as single routing decision-maker (vs ClawMux's individual reviewer kickbacks)
- Compounding learning with permission analysis
- Fully autonomous after plan approval

**ClawMux:**
- Mechanical enforcement (Rust state machine, not prompt-based)
- Progressive tool scoping (reviewers can't edit files)
- Structured JSON communication protocol
- Concurrent multi-task support

**Boris's Workflow:**
- Highest throughput (20-30 PRs/day)
- Self-expanding quality rules
- Mature tooling (hooks, slash commands, worktree workflow)
- Dedup agent proven at scale

**Superpowers (baseline):**
- Best discipline documentation (iron laws, rationalizations tables)
- Fresh context per task via subagents
- Comprehensive debugging methodology
- Strong plan granularity guidelines
