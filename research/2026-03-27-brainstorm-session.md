# Brainstorm Session: Enhanced Agentic Pipeline

> Full session transcript summary from 2026-03-27. This captures the thinking, decisions, and reasoning that led to the enhanced pipeline architecture — things that aren't in the final design docs.

## How We Got Here

Brian came in with a thread: people he respects are building structured multi-stage pipelines around coding agents — brainstorm → spec → architecture → tests → review → code. Not just "chat with AI to write code" but disciplined pipelines that produce reliable outcomes. He pointed to ClawMux (github.com/avirtuos/clawmux) and mentioned someone from LinkedIn doing similar things.

The question: can I leverage someone else's solution, or mimic what they're doing to improve my agentic dev workflows?

## Research Conducted

### 1. ClawMux Deep Dive
- Rust TUI orchestrating agents through a 7-stage pipeline
- Key innovation: **kickback mechanism** — reviewers can send work backward to earlier stages
- Progressive tool scoping — each agent only gets tools appropriate for their role
- 5 stars, 18/26 tasks complete at time of research
- Built on OpenCode or kiro-cli backends

### 2. Broader Landscape Scan
- Surveyed: ClaudeFast Code Kit (18 agents), Ruflo/Claude-Flow, claude-code-workflow-orchestration, claude-octopus, GitHub Spec Kit, GitHub Agentic Workflows, OpenAI Codex + Agents SDK, MetaGPT, LangGraph, CrewAI, Zencoder, Aider
- Found the "canonical pipeline": brain dump → research/Q&A → structured plan → fresh context → contract chain analysis → wave execution → post-build validation
- Key pattern: **contract chain injection** — pass actual outputs between agents, not references

### 3. Boris Cherny's Workflow
- Runs 5 Claude Code instances in parallel worktrees, ships 20-30 PRs/day
- Pipeline: Spec/Plan → Draft/Execute → Simplify → Verify → Parallel Review → Dedup Synthesis
- **Dedup agent catches ~80% of low-level bugs** before human sees the code — this validated the synthesis critiquer concept
- "Compounding Engineering" — every correction encoded into the system
- Self-expanding quality rules: asks Claude to write lint rules preventing recurring errors

### 4. Trusted Voices Survey
Researched: Anthropic engineering team, Boris Cherny, Kent Beck, Martin Fowler, Simon Willison, Karpathy, Steve Yegge, Harper Reed, Addy Osmani, Thorsten Ball, Mike Mason, Tweag, Latent Space/swyx

**Key convergences across all credible voices:**
- TDD is the quality backbone (Beck, Fowler, Willison, Anthropic, Reed, Tweag)
- "Humans on the loop" beats "in the loop" (Fowler)
- Decomposition is the core skill (Karpathy)
- Context is the bottleneck, not intelligence (Anthropic)
- "Almost right" is the #1 failure mode (Fowler/ThoughtWorks)
- Spec-first/plan-first workflows dominate

**Sobering data (Mike Mason/ThoughtWorks):**
- Google DORA 2025: 90% AI adoption → 9% more bugs, 91% more review time
- METR: devs 19% slower with AI while believing 20% faster
- LinearB: 67.3% of AI PRs rejected vs 15.6% manual

### 5. Retry Limits Research
Consensus: **3 is the magic number** for fix/retry cycles before changing strategy. Sources: superpowers systematic-debugging, CodeRabbit, circuit breaker patterns, practitioner consensus.

## Key Design Decisions (and Why)

### Decision 1: Build on superpowers, don't replace it
**Why:** Superpowers already has the best discipline layer (TDD iron law, verification, debugging). The gaps are in review synthesis, security, and routing — not in the fundamentals. Building our own skills alongside superpowers means we get their updates without merge conflicts.

### Decision 2: Synthesis critiquer as single router (not per-reviewer kickbacks)
**Why:** ClawMux lets individual reviewers kick back. We considered this but decided a synthesis critiquer is better because:
- Individual reviewer kickbacks mean any single reviewer can derail progress
- A critiquer that aggregates first is more disciplined — it can detect patterns across reviews that no single reviewer sees
- It's the single point where "should this go back to design?" gets decided
- Boris's dedup agent validates this pattern (proven at scale)

### Decision 3: Aggressive critiquer
**Why:** Brian explicitly wanted this. The critiquer is the quality gate for 3 independent reviewers, so its bar should be higher than any individual. "When in doubt between LOCAL_FIX and KICKBACK, choose KICKBACK."

### Decision 4: Collapsed LOCAL_FIX and KICKBACK to IMPLEMENTATION
**Why:** Plan review caught that these had identical routing behavior. No reason to maintain a distinction that doesn't change anything. Simplified to 4 verdicts: PASS, LOCAL_FIX, KICKBACK to PLANNING, KICKBACK to DESIGN.

### Decision 5: Learner reports, orchestrator applies
**Why:** Plan review caught a role confusion — who edits CLAUDE.md? If the learner subagent edits directly, the orchestrator loses visibility. Solution: learner outputs proposals, orchestrator applies them.

### Decision 6: Permission learning is best-effort
**Why:** Claude Code doesn't expose a programmatic API for permission events. The orchestrator logs what it observes, but events inside subagents may be missed. We accepted this because code pattern learning (the primary value) works without permission data.

### Decision 7: Parallel reviews override superpowers' sequential model
**Why:** Superpowers says "dispatch code quality reviewer only after spec review passes." We override this because (a) the reviews are independent — quality doesn't need spec results to do its job, and (b) the synthesis critiquer handles any cross-review dependencies. Cuts review time by ~2/3.

### Decision 8: 3/2/1 retry limits
**Why:** Expert consensus (CodeRabbit, superpowers debugging, circuit breaker patterns). 3 LOCAL_FIX per task, 2 PLANNING kickbacks per session, 1 DESIGN kickback per session. The reasoning: if 3 different fixes fail, you're fighting the wrong problem.

### Decision 9: Autonomous after plan approval
**Why:** Brian explicitly wanted this. "I don't need human in the loop at each stage, I could wait if the quality is better." Human engages for brainstorming + planning, then walks away until either completion or a kickback surfaces.

## What We Compared Against

### Our pipeline vs. ClawMux
- **We're ahead on:** TDD discipline, verification, debugging methodology, compounding learning
- **ClawMux is ahead on:** mechanical enforcement (Rust state machine), progressive tool scoping (not just prompt-based), structured JSON communication
- **We borrowed:** kickback concept (via critiquer), security review stage, tool scoping idea (prompt-based)
- **We didn't borrow:** external orchestrator, task-as-markdown pattern, individual reviewer kickbacks

### Our pipeline vs. Boris
- **We're ahead on:** formal kickback mechanism, security as dedicated stage, structured retry limits
- **Boris is ahead on:** throughput (20-30 PRs/day), self-expanding lint rules, mature tooling
- **We borrowed:** dedup/synthesis pattern, compounding learning concept, parallel review dispatch
- **Key difference:** Boris's pipeline is tooling-based (hooks, commands, worktrees). Ours is prompt-based (skills).

### Our pipeline vs. superpowers baseline
- **We added:** security reviewer, synthesis critiquer, kickback mechanism, compounding learner, parallel reviews, plan review
- **We kept:** TDD, verification, debugging, brainstorming, writing-plans, git worktrees, finishing-branch

## Plan Review Findings

The plan went through two reviews (acting as a skeptical staff engineer):

**Review 1 — BLOCK:**
- ~/.claude/skills/ is not a git repo (can't commit there)
- Task 4 had state machine vs prompt tension
- Tasks 1-3 should be parallelized
- Missing template paths
- Self-review duplication with existing implementer template
- Permission events not programmatically accessible
- Contradictory commit strategy

**Review 2 — APPROVE WITH CONCERNS:**
- Nested markdown formatting fragile (fixed: use Write tool, not Edit)
- Parallel review contradicts superpowers' sequential model (fixed: explicit override note)
- Integration checks are soft (accepted: runtime concern, not static)
- Learner/orchestrator edit responsibility (fixed: learner reports, orchestrator applies)
- LOCAL_FIX vs KICKBACK to IMPLEMENTATION identical (fixed: collapsed)

All blocking issues resolved. Concerns addressed or accepted.

## Skills Built

| Skill | File | Purpose |
|---|---|---|
| review-plan | ~/.claude/skills/review-plan/SKILL.md | Staff engineer plan review |
| security-reviewer | ~/.claude/skills/security-reviewer/SKILL.md | Read-only security audit |
| synthesis-critiquer | ~/.claude/skills/synthesis-critiquer/SKILL.md | Meta-reviewer + pipeline router |
| compounding-learner | ~/.claude/skills/compounding-learner/SKILL.md | Pattern detection + system improvement |
| enhanced-pipeline | ~/.claude/skills/enhanced-pipeline/SKILL.md | Full orchestration |
| build-feature | ~/.claude/skills/build-feature/SKILL.md | End-to-end: brainstorm → plan → review → execute with Linear + worktree |

All skills are version-controlled in ~/src/agent-playbook/skills/ and symlinked to ~/.claude/skills/ via setup.sh.

## Open Questions for Future Sessions

1. **How well does the kickback mechanism work in practice?** We designed it but haven't battle-tested it. First few uses will reveal if the critiquer is too aggressive, not aggressive enough, or if the retry limits need adjusting.

2. **Should the compounding learner run after every task or every 3?** We said every 3. Boris runs his dedup after every PR. The right frequency depends on how much context the learner needs to detect patterns.

3. **Does prompt-based tool scoping actually work?** We tell reviewers "you are read-only" but don't mechanically enforce it. If reviewers start "helpfully" fixing things instead of reporting, we may need to explore mechanical enforcement.

4. **What happens when enhanced-pipeline and superpowers:subagent-driven-development conflict?** They solve the same problem differently. Do we always use enhanced-pipeline, or are there cases where the simpler superpowers flow is better? Probably: enhanced-pipeline for features, superpowers for quick fixes.

5. **Should the build-feature skill be the default entry point?** Right now it's opt-in (/build-feature). Could it become the default when someone asks to build something? That depends on whether the overhead of Linear + worktree + full pipeline is justified for small changes.

## Sources Index

All sources with URLs are in references/key-reading-list.md. The most important ones:
- Anthropic multi-agent research system blog post
- Anthropic effective harnesses blog post
- Anthropic context engineering blog post
- Boris Cherny: howborisusesclaudecode.com
- Kent Beck: Augmented Coding Beyond the Vibes
- Martin Fowler: Humans and Agents in Software Engineering Loops
- CodeScene: Best Practice Patterns for Speed with Quality
