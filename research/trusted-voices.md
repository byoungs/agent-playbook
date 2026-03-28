# Trusted Voices on Agentic Development

> Researched 2026-03-27. Organized by credibility tier and relevance to structured agent workflows.

## Tier 1: Primary Sources / Highest Credibility

### Anthropic Engineering Team

**Key publications:**

- **"How We Built Our Multi-Agent Research System"** — Orchestrator-worker pattern. Multi-agent Opus+Sonnet outperformed single-agent Opus by 90.2%. Token usage explained 80% of performance variance. Prompts, not code, drove agent behavior. [anthropic.com/engineering/multi-agent-research-system](https://www.anthropic.com/engineering/multi-agent-research-system)

- **"Effective Harnesses for Long-Running Agents"** — Two-part architecture: initializer agent + coding agents. Browser automation for e2e verification. Never delete tests. [anthropic.com/engineering/effective-harnesses-for-long-running-agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

- **"Effective Context Engineering for AI Agents"** — Context is the bottleneck, not intelligence. Just-in-time retrieval over pre-loading. Minimal, non-overlapping tool sets. [anthropic.com/engineering/effective-context-engineering-for-ai-agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

### Boris Cherny (Creator of Claude Code)

**Core philosophy: "Compounding Engineering"** — Every correction gets encoded (CLAUDE.md, hooks, lint rules, skills) so each session is smarter. "You should never have to correct Claude twice for the same mistake."

**His pipeline:** Spec/Plan → Draft/Execute → Simplify → Verify → Parallel Review → Dedup Synthesis

**Key practices:**
- Runs 5 Claude Code instances simultaneously in separate git worktrees
- Ships 20-30 PRs/day
- Verification loops are "probably the most important thing" — 2-3x quality improvement
- Multiple review agents in parallel → dedup agent synthesizes → catches ~80% of low-level bugs before human
- Self-expanding quality rules: asks Claude to write lint rules that prevent recurring error patterns
- Uses Opus 4.5 with thinking for everything

**Sources:**
- [Lenny's Podcast: What happens after coding is solved](https://www.lennysnewsletter.com/p/head-of-claude-code-what-happens)
- [YC Lightcone: Inside Claude Code](https://www.ycombinator.com/library/NJ-inside-claude-code-with-its-creator-boris-cherny)
- [Anthropic Blog: Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [howborisusesclaudecode.com](https://howborisusesclaudecode.com) (57 tips aggregated)

### Kent Beck (Created TDD and XP)

- Sharp distinction: "In vibe coding you don't care about the code, just the behavior. In augmented coding you care about the code, its complexity, the tests, and their coverage."
- TDD as "superpower" for AI agents — strict Red-Green-Refactor
- Three warning signs agent is going off track: **loops in code, unrequested functionality, test manipulation**
- Active human intervention: watch intermediate results, verify AI followed instructions

**Sources:**
- [Augmented Coding: Beyond the Vibes](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes)
- [Pragmatic Engineer podcast on TDD + AI](https://newsletter.pragmaticengineer.com/p/tdd-ai-agents-and-coding-with-kent)

### Martin Fowler / ThoughtWorks

- Three models: humans **outside** the loop (vibe coding), humans **in** the loop (bottleneck), humans **on** the loop (recommended)
- "On the loop" = build the harness (specs, quality checks, workflow guidance). Fix the system, not the artifacts.
- **"Almost right" is the #1 failure mode** — context degradation, compounding mistakes, false success claims
- **TDD as "the strongest form of prompt engineering"**
- Birgitta Boeckeler: AI-assisted teams get 80% productivity boost but results vary hugely by context

**Sources:**
- [Humans and Agents in Software Engineering Loops](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html)
- [Pragmatic Engineer: Two Years of Using AI Tools](https://newsletter.pragmaticengineer.com/p/two-years-of-using-ai)

## Tier 2: Highly Credible Practitioners

### Simon Willison (Django co-creator, Datasette)

- Publishing "Agentic Engineering Patterns" — growing guide with weekly chapters
- Red/Green TDD chapter: test-first helps agents produce more concise, reliable code
- "Skills may be bigger than MCP"
- Champions parallel coding agent lifestyle

**Sources:**
- [Agentic Engineering Patterns](https://simonwillison.net/2026/Feb/23/agentic-engineering-patterns/)
- [Designing Agentic Loops](https://simonw.substack.com/p/designing-agentic-loops)

### Andrej Karpathy

- "It's not magic, it's delegation — the people who decompose work well for junior engineers decompose it well for agents too."
- AutoResearch: 700 experiments in 2 days with one markdown prompt
- Core skill is **judgment**: what to delegate, how to specify, how to review fast

**Source:** [Year in Review 2025](https://karpathy.bearblog.dev/year-in-review-2025/)

### Steve Yegge (Building Gas Town agent orchestrator)

- **Rule of Five**: 4-5 self-review passes produce significantly better results
- **"Merge Wall" problem**: parallel agents finishing simultaneously creates reconciliation hell
- **40% of effort to code health** or you'll spend >60% later
- Software is now disposable — expect <1 year shelf life

**Sources:**
- [Six New Tips for Better Coding with Agents](https://steve-yegge.medium.com/six-new-tips-for-better-coding-with-agents-d4e9c86e42a9)
- [The Future of Coding Agents](https://steve-yegge.medium.com/the-future-of-coding-agents-e9451a84207c)

### Harper Reed (Former CTO Obama 2012 campaign)

- Two-phase: conversational spec building ("ask me one question at a time") → reasoning model for plan. ~15 min planning.
- TDD essential: builds tests and mocks first, then implements
- Uses Repomix for context bundles in existing codebases

**Sources:**
- [My LLM Codegen Workflow](https://harper.blog/2025/02/16/my-llm-codegen-workflow-atm/)
- [Basic Claude Code](https://harper.blog/2025/05/08/basic-claude-code/)

### Addy Osmani (Google Chrome engineering lead)

- Chunked workflows essential — asking for too much produces a "jumbled mess"
- Quality gates and automation: AI writes, automation catches issues, AI fixes, human oversees
- "The accountable engineer principle" — human owns the output regardless

**Source:** [My LLM Coding Workflow Going into 2026](https://addyosmani.com/blog/ai-coding-workflow/)

## The Sobering Data

From Mike Mason (ThoughtWorks Chief AI Officer):
- **Google DORA 2025**: 90% AI adoption increase correlates with 9% more bugs, 91% more review time, 154% larger PRs
- **METR study**: experienced OSS maintainers were 19% slower with AI tools while believing they were 20% faster
- **LinearB**: 67.3% of AI-generated PRs get rejected vs. 15.6% for manual code

**Source:** [AI Coding Agents in 2026: Coherence Through Orchestration](https://mikemason.ca/writing/ai-coding-agents-jan-2026/)

## Key Cross-Cutting Themes

1. **TDD is the strongest quality pattern** — Beck, Fowler, Willison, Anthropic, Reed, Tweag all independently converge
2. **"Humans on the loop" beats "in the loop"** — build the harness, not the habit of reviewing every line
3. **Decomposition is the core skill** — Karpathy, Anthropic, Osmani, Reed all emphasize this
4. **Context is the bottleneck, not intelligence** — Anthropic Applied AI team's most rigorous finding
5. **Multi-agent = orchestration, not autonomy** — parallel agents need structured coordination
6. **"Almost right" is the primary failure mode** — the review pipeline exists to catch this
7. **Spec-first/plan-first workflows dominate** — every credible voice converges here
