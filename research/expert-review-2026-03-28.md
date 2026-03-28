# Expert Review: Enhanced Pipeline Architecture
## Critical Assessment Against Current Expert Thinking

> Reviewed 2026-03-28. Stress-tests the pipeline design (design/pipeline-architecture.md) against the latest writing from Boris Cherny, Kent Beck, Martin Fowler, Simon Willison, Steve Yegge, Anthropic engineering, Adam Tornhill/CodeScene, and practitioner results.

## Executive Summary

The pipeline architecture is **well-aligned with expert consensus** on the fundamentals (plan-first, TDD, parallel review, human-on-the-loop). But three developments since the design was finalized warrant attention:

1. **Claude Code Agent Teams** (experimental) provides native multi-agent coordination that partially overlaps with our custom orchestration
2. **Anthropic's "Generator-Evaluator" harness pattern** (Mar 24 blog post) validates our separation of implementation from review but introduces "sprint contracts" we haven't adopted
3. **Kent Beck's Superego/Ego/Id framework** maps cleanly to our pipeline but his push beyond pass/fail TDD toward observability signals is something we're missing

**Overall verdict:** The architecture's core bets are holding. No expert is moving away from what we've built. But we should plan for Agent Teams migration and add observability to our quality signals.

---

## 1. Expert-by-Expert Assessment

### Boris Cherny (Claude Code Creator)

**Latest content:** 57 tips on howborisusesclaudecode.com (updated through March 17), Lenny's Newsletter interview (Feb 19), YC Lightcone podcast (Feb 17), 266 GitHub contributions in a single day (Mar 24 tweet).

**Alignment with our pipeline:**

| Our Design Choice | Boris's Current Practice | Assessment |
|---|---|---|
| Plan → implement → review → fix cycle | Plan mode (shift+tab) → auto-accept execution → /simplify → verify → review | **Aligned.** Same structure. |
| Parallel review agents | "Multiple review agents in parallel → dedup agent synthesizes" | **Strongly aligned.** Our synthesis critiquer IS his dedup agent. |
| Compounding learning via CLAUDE.md | Tags @.claude on PRs, team updates CLAUDE.md multiple times weekly | **Aligned.** We automated what he does manually. |
| Custom skill-based pipeline | Uses /simplify, /batch, /commit-push-pr — all custom skills | **Aligned.** Skills are his primary workflow mechanism. |
| 3 retry limit before escalation | Not explicitly documented | **No conflict.** |

**Where Boris has moved beyond us:**

1. **Scale of parallelism.** Boris runs 10-15 concurrent sessions (5 terminal + 5-10 browser + mobile). Our pipeline runs tasks sequentially within a session. We're not leveraging the full parallelism that Agent Teams could provide.
2. **Auto Mode** (Mar 25). Boris's team built a permission classifier that auto-approves safe actions. Our pipeline still requires manual permission approval for shell commands, creating bottlenecks in fully autonomous execution.
3. **Verification as the #1 lever.** Boris says verification yields "2-3x quality improvement" and calls it "probably the most important thing." Our pipeline has verification (via superpowers), but it's not elevated to the same prominence as review. Consider: is our review pipeline overshadowing verification?

**New Claude Code features that affect our pipeline:**

- **Agent Teams** (experimental): Native multi-agent with shared task lists, inter-agent messaging, and `TaskCompleted` hooks with exit-code-2 kickback. This is native kickback support. When stable, it could replace our custom synthesis critiquer routing.
- **Auto Mode**: Removes permission bottleneck for autonomous pipelines.
- **`/simplify` and `/batch`**: Built-in skills that partially overlap with our post-implementation quality checks.
- **Conditional hooks**: `if` field on hooks enables fine-grained automation triggers.
- **Sparse checkout for worktrees**: Makes worktree-based isolation practical for large repos.

**Risk:** Agent Teams is still experimental but is clearly the direction Claude Code is heading. Our custom orchestration may become redundant when it stabilizes. **Recommendation:** Design skills to be Agent Teams-compatible so migration is incremental, not a rewrite.

---

### Kent Beck (TDD Creator)

**Latest content:** 8 Substack posts (Jan-Mar 2026), "Augmented Software Design: Taming the Genie" book (Sept 2026), O11ycast podcast on Superego/Ego/Id framework.

**Alignment with our pipeline:**

| Our Design Choice | Beck's Current Position | Assessment |
|---|---|---|
| TDD as quality backbone | "TDD is a superpower for AI agents" | **Strongly aligned.** |
| Synthesis critiquer as routing gate | Superego/Ego/Id — dedicated constraint enforcer | **Strongly aligned.** Our critiquer IS Beck's Superego. |
| Aggressive kickback policy | "AI agents actively fight quality constraints" — need hard enforcement | **Validated.** |
| Retry limits (3 before escalation) | Documents agents that loop, add unrequested features, delete tests | **Validated.** His failure modes are exactly what our limits prevent. |

**Where Beck challenges our design:**

1. **TDD alone is insufficient.** Beck now says: "Red and green for tests is just not interesting for any interesting system." He's pushing toward **observability-driven constraints** — tracking performance, error rates, and emergent properties alongside pass/fail tests. Our pipeline's quality signals are entirely binary (tests pass/fail, review pass/fix/kickback). We have no observability layer.

2. **Constrained context as a design technique.** Rather than giving agents full system context, Beck uses narrow framing. Our pipeline passes "full text" of task requirements, implementer reports, and reviewer outputs through the chain. Beck would say we're giving agents too much context, increasing the risk of complexity explosion.

3. **The Compounding Game.** Beck argues agent-driven development alone cannot sustain system lifespan. You must deliberately invest in refactoring and design. Our compounding learner captures review patterns but doesn't propose refactoring tasks. Consider: should the learner also flag areas where code health is degrading?

**Recommended change:** Add an observability check to the review pipeline — not just "do tests pass?" but "are performance characteristics preserved? Are error rates stable?" This requires project-specific instrumentation but would close the gap Beck identifies.

---

### Martin Fowler / ThoughtWorks

**Latest content:** "Humans and Agents in Software Engineering Loops" (Mar 4), "Patterns for Reducing Friction in AI-Assisted Development" by Rahul Garg (Mar 17), "LLMs and the What/How Loop" (Jan 21), ThoughtWorks Technology Radar 2026.

**Alignment:** Our pipeline is a textbook implementation of Fowler's "humans on the loop" model — human designs the harness (skills, review rubrics, kickback rules), agents execute within it, human is surfaced only on exceptions.

**New concepts relevant to us:**

1. **The Agentic Flywheel.** Agents evaluate their own performance using test results and operational data, then recommend improvements to the harness itself. Humans prioritize and approve. This is exactly our compounding learner — Fowler's team arrived at the same pattern independently.

2. **Five Friction-Reduction Patterns** (Garg, Mar 17). The **Feedback Flywheel** pattern systematically captures successful prompts and learnings to improve collaboration. Advocates measuring "collaboration quality" (first-pass acceptance rate, iteration cycles per task, post-merge rework) rather than raw speed. We track review cycles but not first-pass acceptance rate or post-merge rework — these would be valuable metrics.

3. **"The rigor has to go somewhere."** Chad Fowler's framing: as agents produce more code, engineering discipline moves to the harness, the tests, and the specifications. This validates our entire architecture philosophy.

**Fowler's concern we should watch:** Boeckeler reports "80% productivity boost but results vary hugely by context." Our pipeline doesn't account for context-dependent quality — the same review rubrics apply regardless of whether the task is greenfield, legacy refactoring, or bug fixing. Consider: should the critiquer's aggression level vary by task type?

---

### Simon Willison (Django Co-creator)

**Latest content:** "Agentic Engineering Patterns" multi-chapter guide (Feb 23, ongoing), Subagents chapter (Mar 2026), "Use subagents and custom agents in Codex" (Mar 16), Auto Mode coverage (Mar 24).

**Alignment:** Willison's "skills may be bigger than MCP" directly validates our skill-based architecture. His Red/Green TDD chapter aligns with our TDD backbone.

**Key new content — Subagents chapter:**
- Recommends parallel subagents for tasks involving multiple independent files
- Three specialist subagent roles: **Code Reviewer**, **Test Runner**, **Debugger** — similar to our spec/quality/security split
- The "Explore" subagent pattern: dispatch a focused agent to map structure and return synthesized findings
- Caution against overuse: the root agent can self-review if it has tokens to spare (relevant with 1M context)

**Where Willison adds value we haven't captured:**
1. **Toolmaking as the core engineering skill** — reflected in our architecture but not in our compounding learner. The learner captures code patterns but doesn't propose new skills or tooling improvements.
2. **Using cheaper/faster models for subagent work.** Willison recommends Haiku for subagent tasks. Our pipeline uses Opus for everything. Consider: could reviewers run on Sonnet or Haiku to reduce cost and latency?

**Critical cross-cutting finding:** Willison's subagent reviewers are dispatched for *different purposes* (code review vs. testing vs. debugging), not redundant review of the same artifact. **Nobody in the expert community is writing about parallel review synthesis** — our synthesis critiquer pattern appears to be genuinely novel.

---

### Steve Yegge (Gas Town Creator)

**Latest content:** "Welcome to the Wasteland: A Thousand Gas Towns" (Mar 4), "The AI Vampire" (Feb 11), "The Anthropic Hive Mind" (Feb 6), "Software Survival 3.0" (Jan 29), "Welcome to Gas Town" (Jan 14). Also: Maggie Appleton's [design critique of Gas Town](https://maggieappleton.com/gastown).

**Key developments:**
- Gas Town runs 20-30 parallel agents via tmux with 7 specialized roles: Mayor (orchestrator), Polecats (swarm workers), Refinery (merge queue), Witness (health monitor), Deacon (daemon patrols), Dogs (maintenance), Crew (human-directed)
- **The Wasteland** (Mar 4): Federated multi-Gas-Town network. 2,400 submitted PRs, 1,500 merged, 450+ contributors in 2 months. Git fork/merge model with reputation tracking.
- **Rule of Five formalized** as reusable workflow: 4 review passes after implementation, each focused (Correctness → Clarity → Edge Cases → Excellence). Sequential, not parallel.
- **GUPP (Gastown Universal Propulsion Principle)**: "If there is work on your hook, YOU MUST RUN IT." Agents resume from checkpoints via nondeterministic idempotence.
- **The Refinery** solves the Merge Wall: sequential intelligent merging, can "re-imagine" implementations when changes diverge too far.

**Alignment with our pipeline:**

| Our Design Choice | Yegge's Position | Assessment |
|---|---|---|
| Retry limits (3) | Rule of Five (4 sequential passes) | **Compatible.** Different mechanisms, same principle. |
| Sequential task execution | Warns about "Merge Wall" — solves it with Refinery agent | **We avoid this** by executing tasks sequentially. |
| Synthesis critiquer | No equivalent — Rule of Five is sequential, not synthesized | **We're ahead.** |
| Compounding learning | "Four free upgrades" — models improve, training data improves, community contributes, APIs mature | **Different lens.** His compounding is external; ours is internal (CLAUDE.md). |

**Yegge's challenges to us:**
1. "Software is now disposable — expect <1 year shelf life." Counter: compounding learning is cheap (automated), low downside even if rules are short-lived.
2. **Appleton's critique:** Design becomes the bottleneck when agents write code. Poor upfront design means wasted tokens. Our plan review step addresses this, but we could be more rigorous about design quality.
3. **40% effort to code health** — not reflected in our pipeline. Gap we share with most tools.

---

### Anthropic Engineering Blog

**Critical new post (Mar 24, 2026):** ["Harness Design for Long-Running Application Development"](https://www.anthropic.com/engineering/harness-design-long-running-apps)

This is the most directly relevant new content. Key concepts:

1. **Generator-Evaluator pattern.** Separate Planner, Generator, and Evaluator agents. The Evaluator uses Playwright to interact with running apps like an end-user. Our pipeline has the Generator (implementer) and multiple Evaluators (reviewers) but lacks the behavioral/E2E evaluation that the Anthropic team recommends.

2. **Sprint contracts.** Negotiated agreements between generator and evaluator about deliverables before implementation begins. Our pipeline has task descriptions but not explicit contracts between the implementer and reviewers about what "done" means. Sprint contracts would make the spec reviewer's job much more precise.

3. **Key quote:** "Tuning a standalone evaluator to be skeptical turns out to be far more tractable than making a generator critical of its own work." This directly validates our architecture — separate reviewers are better than self-review.

4. **Model-dependent harness design.** With Opus 4.6's 1M context and longer session capability, sprint-based orchestration that was necessary for Sonnet 4.5 can be simplified. Our pipeline was designed for Opus 4.5 — we may be over-orchestrating for the current model.

**Other notable posts:**
- "Building a C compiler with a team of parallel Claudes" (Feb 5) — demonstrates parallel agent coordination at scale
- "Demystifying evals for AI agents" (Jan 9) — eval infrastructure we could apply to our pipeline quality measurement

---

### Adam Tornhill / CodeScene

**Latest:** Peer-reviewed paper showing AI coding assistants increase defect risk by **at least 30%** on unhealthy code, rising to **60% on legacy systems.** New "Making Legacy Code AI-Ready" benchmarks (Mar 18).

**Direct implication for our pipeline:** We have no code health pre-check. The pipeline assumes the codebase is ready for agent work. Tornhill's data says this assumption is dangerous — if we're modifying unhealthy code, our agents will introduce more bugs regardless of review quality.

**Recommended change:** Add a code health assessment to the plan review step. If a task targets code with known health issues, flag it as high-risk and either require refactoring first or increase the critiquer's aggression level.

---

## 2. New Tools That Challenge Our Approach

### Composio Agent Orchestrator (`@composio/ao`)
The closest direct competitor to our custom pipeline. 5.5k GitHub stars, 472+ commits. Spawns agent fleets in parallel worktrees with built-in CI failure routing, review feedback loops, and merge triggers.

**What it does better:** Automated CI-to-agent feedback loop (our pipeline doesn't integrate with CI at all), multi-repo support, agent-agnostic design.

**What we do better:** Opinionated quality gates (plan review, security review, kickback mechanism), Linear integration, deterministic pipeline stages, and the compounding learner.

**Verdict:** Not redundant yet. Complementary — AO handles the infrastructure (worktrees, CI routing), we handle the quality discipline (review rubrics, kickback logic).

### GitHub Agentic Workflows
Markdown-based workflow automation in GitHub Actions. Supports Claude Code as the agent engine. Could automate our review pipeline as a GitHub Action.

**Verdict:** Worth watching for CI integration but doesn't replace our local-first, ff-only merge workflow.

### JetBrains Central
Unified control/execution plane with governance, identity, and observability. Agent-agnostic. Early but potentially the enterprise standard.

**Verdict:** Too early to evaluate. Watch for convergence with our patterns.

---

## 3. Practitioner Results (Real Data)

### Validating Data
- **Monday.com's multi-agent review stopped 800+ production issues** — validates our parallel review approach
- **CodeScene's AI team reports 2-3x speedup after going fully agentic** — validates the productivity claim
- **Architecture matters as much as the model** — same Opus 4.5 scored 17 problems apart across different scaffoldings (SWE-bench). Our pipeline IS the scaffolding.
- **85% failure rate on ambiguous tasks vs. 67% merge rate on well-defined tasks** — validates our plan-first approach

### Cautionary Data
- **AI-coauthored PRs show 1.7x more issues** than human-only PRs (Panto AI)
- **Google DORA 2025:** 90% AI adoption increase correlates with 9% more bugs, 91% more review time
- **LinearB:** 67.3% of AI-generated PRs get rejected vs. 15.6% for manual code
- **88% of AI agents fail to reach production** (Digital Applied)
- **17x Error Trap:** Poorly coordinated multi-agent systems amplify errors at 17x the expected rate. Fix is better coordination topology, not more agents.

### Failure Modes We Should Guard Against
1. **Verification is the bottleneck, not generation** (Osmani) — are we spending enough pipeline time on verification vs. review?
2. **Agents don't replan well** — errors go undetected for multiple steps. Our kickback mechanism addresses this but only at review time, not during implementation.
3. **Stuck agent loops** — best practice is kill-and-reassign after 3+ iterations. Our retry limit of 3 aligns perfectly.
4. **Interface drift** — agents invent fields, omit inputs, drift across boundaries. Our XML delimiter tags for agent passthrough help but don't fully prevent this.

---

## 4. Where We're Ahead, Behind, and Betting

### Where We're Ahead
1. **Synthesis critiquer as single routing decision-maker.** Validated by the 17x Error Trap paper — coordinated review topology beats bag-of-agents. No other practitioner tool has this. Cross-cutting finding from Fowler/Willison/Yegge research: **nobody in the expert community is writing about parallel review synthesis.** Yegge's Rule of Five is sequential. Willison's subagent reviewers serve different purposes (not redundant review). Fowler focuses on self-evaluating agents. Our pattern appears genuinely novel.
2. **Kickback mechanism with retry limits.** ClawMux has individual reviewer kickbacks; we route through a critiquer. Anthropic's Agent Teams now has exit-code-2 kickbacks but without the synthesis layer.
3. **Compounding learning.** Boris does this manually; we automated it. No other tool automates CLAUDE.md evolution from review findings.
4. **Security review as a dedicated pipeline stage.** Most tools skip this entirely.

### Where We're Behind
1. **No observability signals.** Beck says pass/fail TDD is insufficient. We need performance, error rate, and behavioral checks alongside test results.
2. **No code health pre-check.** Tornhill's data shows 30-60% more defects when agents modify unhealthy code. We don't assess code health before tasking agents.
3. **No CI integration.** Composio Agent Orchestrator routes CI failures back to agents automatically. Our pipeline is entirely local with no CI feedback loop.
4. **No sprint contracts.** Anthropic's Mar 24 post recommends explicit contracts between generator and evaluator. Our task descriptions are less formal.
5. **Sequential task execution within sessions.** Boris runs 10-15 concurrent sessions. Agent Teams enables native multi-agent. Our pipeline processes tasks one at a time.

### Bets We've Made

| Bet | Field Direction | Risk Level |
|---|---|---|
| Prompt-based skills over external orchestrators | Skills ecosystem growing (Willison: "skills may be bigger than MCP") | **Low risk** — aligned with field |
| Custom synthesis critiquer over individual reviewer authority | 17x Error Trap paper validates coordination topology | **Low risk** — validated |
| TDD as quality backbone | Universal expert consensus (Beck, Fowler, Willison, Anthropic) | **Low risk** — strong consensus |
| Compounding learning via CLAUDE.md | Boris does this manually; we automated it | **Low risk** — ahead of field |
| Local-first, ff-only merge workflow | Industry moving toward PR-based and CI-integrated flows | **Medium risk** — our workflow is simpler but less integrated |
| Aggressive kickback policy | No expert contradicts this; Beck and Fowler support it | **Low risk** |
| Human approval for CLAUDE.md writes | Consistent with "humans on the loop" model | **Low risk** |

---

## 5. Recommended Changes

### High Priority
1. **Plan for Agent Teams migration.** Design skills to be compatible with Agent Teams' shared task list and hook-based kickback model. When Agent Teams stabilizes, our custom orchestration in enhanced-pipeline should migrate to native coordination.

2. **Add observability signals to the review pipeline.** Beyond pass/fail tests, check for: performance regression (if benchmarks exist), error rate changes (if logging exists), and behavioral properties. This closes the gap Beck identifies.

3. **Add code health pre-check to plan review.** Before tasking agents with modifying code, assess whether the target code is healthy enough for safe AI modification. Flag unhealthy targets as high-risk. This addresses Tornhill's 30-60% defect increase finding.

### Medium Priority
4. **Adopt sprint contracts from Anthropic's harness pattern.** Before dispatching the implementer, have the orchestrator generate an explicit contract: "Task N is done when: [specific acceptance criteria]. The spec reviewer will verify: [specific checks]." This makes the spec reviewer's job more precise and reduces ambiguity.

5. **Evaluate whether we're over-orchestrating for Opus 4.6.** The Mar 24 Anthropic post notes that Opus 4.6's longer session capability may make some sprint-based orchestration unnecessary. Test whether the full 5-step pipeline is needed for simple tasks or if a lightweight path (implement + single reviewer) would suffice.

6. **Integrate CI feedback loop.** Even without adopting Composio AO, add a step where the pipeline runs the project's CI checks and routes failures back to the implementer before triggering review. This catches build/test failures earlier.

### Low Priority
7. **Watch Agent Orchestrator and GitHub Agentic Workflows.** If scaling to 3+ parallel agents regularly, evaluate AO for worktree management and CI routing.

8. **Consider context-dependent critiquer aggression.** Fowler's observation that results "vary hugely by context" suggests the critiquer should be more aggressive on legacy code and less aggressive on greenfield work.

9. **Extend compounding learner to propose tooling improvements.** Following Willison's emphasis on toolmaking, the learner could flag opportunities for new skills or lint rules, not just CLAUDE.md additions.

---

## Sources

### Boris Cherny
- [howborisusesclaudecode.com](https://howborisusesclaudecode.com) — 57 tips, updated through March 17, 2026
- [Lenny's Newsletter: Head of Claude Code](https://www.lennysnewsletter.com/p/head-of-claude-code-what-happens) — Feb 19, 2026
- [YC Lightcone: Inside Claude Code](https://www.ycombinator.com/library/NJ-inside-claude-code-with-its-creator-boris-cherny) — Feb 17, 2026
- [developing.dev profile](https://www.developing.dev/p/boris-cherny-creator-of-claude-code)

### Kent Beck
- [Genie: Death of the Iron Triangle?](https://tidyfirst.substack.com/p/genie-death-of-the-iron-triangle) — Mar 2, 2026
- [Earn *And* Learn](https://tidyfirst.substack.com/p/earn-and-learn) — Feb 18, 2026
- [Don't Accomplish Everything](https://tidyfirst.substack.com/p/dont-accomplish-everything) — Feb 23, 2026
- [Nobody Knows](https://tidyfirst.substack.com/p/nobody-knows) — Mar 25, 2026
- [O11ycast Ep. #80: Augmented Coding](https://www.heavybit.com/library/podcasts/o11ycast/ep-80-augmented-coding-with-kent-beck) — Superego/Ego/Id framework

### Martin Fowler / ThoughtWorks
- [Humans and Agents in Software Engineering Loops](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html) — Mar 4, 2026
- [Patterns for Reducing Friction in AI-Assisted Development](https://martinfowler.com/articles/reduce-friction-ai/) — Mar 17, 2026
- [LLMs and the What/How Loop](https://martinfowler.com/articles/convo-what-how.html) — Jan 21, 2026
- [ThoughtWorks Technology Radar 2026](https://www.thoughtworks.com/en-us/radar)

### Anthropic Engineering
- [Harness Design for Long-Running Application Development](https://www.anthropic.com/engineering/harness-design-long-running-apps) — Mar 24, 2026
- [Claude Code Auto Mode](https://www.anthropic.com/engineering/claude-code-auto-mode) — Mar 25, 2026
- [Building a C Compiler with Parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler) — Feb 5, 2026
- [Claude Code Agent Teams Docs](https://code.claude.com/docs/en/agent-teams)
- [Claude Code Changelog](https://code.claude.com/docs/en/changelog)

### Adam Tornhill / CodeScene
- [Code for Machines, Not Just Humans (arXiv paper)](https://arxiv.org/html/2601.02200v1) — Jan 2026
- [Making Legacy Code AI-Ready](https://codescene.com/blog/making-legacy-code-ai-ready-benchmarks-on-agentic-refactoring) — Mar 18, 2026
- [Agentic AI Coding: Best Practice Patterns](https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality) — Feb 20, 2026

### Practitioner Data
- [Qodo: Single vs Multi-Agent Code Review](https://www.qodo.ai/blog/single-agent-vs-multi-agent-code-review/)
- [GitHub: Multi-agent workflows often fail](https://github.blog/ai-and-ml/generative-ai/multi-agent-workflows-often-fail-heres-how-to-engineer-ones-that-dont/)
- [TDS: The 17x Error Trap](https://towardsdatascience.com/why-your-multi-agent-system-is-failing-escaping-the-17x-error-trap-of-the-bag-of-agents/)
- [Panto AI: AI Coding Statistics](https://www.getpanto.ai/blog/ai-coding-assistant-statistics)
- [Digital Applied: AI Agent Scaling Gap](https://www.digitalapplied.com/blog/ai-agent-scaling-gap-march-2026-pilot-to-production)
- [Addy Osmani: The Code Agent Orchestra](https://addyosmani.com/blog/code-agent-orchestra/)

### Tools
- [Composio Agent Orchestrator](https://github.com/ComposioHQ/agent-orchestrator) — 5.5k stars
- [JetBrains Central](https://blog.jetbrains.com/blog/2026/03/24/introducing-jetbrains-central-an-open-system-for-agentic-software-development/) — Mar 24, 2026
- [GitHub Agentic Workflows](https://github.blog/changelog/2026-02-13-github-agentic-workflows-are-now-in-technical-preview/) — Feb 2026

### Steve Yegge
- [Welcome to the Wasteland: A Thousand Gas Towns](https://steve-yegge.medium.com/welcome-to-the-wasteland-a-thousand-gas-towns-a5eb9bc8dc1f) — Mar 4, 2026
- [Welcome to Gas Town](https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04) — Jan 14, 2026
- [The Future of Coding Agents](https://steve-yegge.medium.com/the-future-of-coding-agents-e9451a84207c) — Jan 5, 2026
- [Six New Tips for Better Coding with Agents](https://steve-yegge.medium.com/six-new-tips-for-better-coding-with-agents-d4e9c86e42a9)
- [Maggie Appleton: Gas Town's Agent Patterns](https://maggieappleton.com/gastown)

### Simon Willison
- [Agentic Engineering Patterns (guide)](https://simonwillison.net/guides/agentic-engineering-patterns/) — Feb 23, 2026 (ongoing)
- [Subagents chapter](https://simonwillison.net/guides/agentic-engineering-patterns/subagents/) — Mar 2026
- [Use subagents and custom agents in Codex](https://simonwillison.net/2026/Mar/16/codex-subagents/) — Mar 16, 2026
