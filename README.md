# Agent Playbook

This is the brain. The central authority for how I build software with AI agents — the methodology, the skills, the research behind it all.

Every project in `~/src/` shares these skills and follows these patterns. Project-specific config lives in each project's `CLAUDE.md`; the universal system lives here.

This repo itself runs on **trunk flow** — agents contribute directly to main.

## Here's How I Work

I run multiple Claude Code agents in parallel using three tools:

**[amux](https://github.com/byoungs/amux)** — A terminal multiplexer purpose-built for parallel AI coding. Agents expand and contract fluidly. Pane borders show agent state (working, waiting, idle). I zoom in to pair with one agent, zoom out to survey the team.

**[wtr](https://github.com/byoungs/wtr)** — A worktree review TUI. When an agent finishes work in a worktree, I review the diff, run tests, and land (ff-only merge → validate → push) — all without leaving the terminal.

**[Linear](https://linear.app)** — The coordination layer. Every task gets a Linear issue. Agents post status updates as they work. I see the big picture in Linear; I see the code in wtr; I manage attention in amux.

A typical session:

```
┌─────────────────────────────────────────────────────────┐
│  amux                                                   │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Agent 1     │  │ Agent 2     │  │ Agent 3     │     │
│  │ /dev Add    │  │ /dev next   │  │ /harden     │     │
│  │ auth system │  │ PEN-42      │  │ (reviewing  │     │
│  │ (worktree)  │  │ (worktree)  │  │  code on    │     │
│  │ [working]   │  │ [waiting]   │  │  main)      │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
│  Agent 1: implementing auth (Phase 4, task 3/5)         │
│  Agent 2: waiting for plan approval                     │
│  Agent 3: security review found 2 issues, fixing...     │
└─────────────────────────────────────────────────────────┘
```

### Two Development Flows

Every project uses one of two flows. Run `/dev-flow` to configure:

**Trunk flow** — Agents work directly on main. Commits land immediately.
```
/dev Fix the date parser  →  agent works on main  →  commit  →  push
```
Best for solo work, early-stage projects, or repos where multiple agents contribute docs and research (like this one).

**Worktree flow** — Each agent gets an isolated branch. Review in wtr before landing.
```
/dev Add user auth  →  worktree  →  plan  →  implement  →  review in wtr  →  land
```
Best once you're running parallel agents or want review before merge. A hook prevents commits on main.

The development pipeline runs the same in both flows — the only difference is where code goes. Projects naturally start on trunk and move to worktree as they grow. `/learn` detects when it's time and suggests the switch.

## The Development Pipeline

Every piece of work — feature, bugfix, refactor — goes through the same process. `/dev` orchestrates it end to end:

**Phase 1: Brainstorm** — You and the agent explore the problem together. What are we building? What are the trade-offs? You approve the design before anything gets built.

**Phase 2: Write Plan** — The design becomes a concrete plan with bite-sized tasks. You approve the plan.

**Phase 3: Review Plan** — A staff-engineer-persona agent reviews the plan skeptically. Catches gaps, bad decomposition, and unrealistic assumptions. Autonomous — you're only surfaced if it finds blocking issues.

**Phase 4: Execute** — For each task: implement with TDD, then three reviewers run in parallel (spec compliance, code quality, security). A synthesis critiquer deduplicates findings and routes: PASS, LOCAL_FIX (retry up to 3 times), or KICKBACK (escalate to human). Fully autonomous.

**Phase 5: Stage** — The agent wraps up: reviews its own work, runs tests, squashes into a clean commit. On worktree flow, you review in wtr and land. On trunk flow, the agent commits and pushes.

```
 /dev Add webhook notifications
   │
   ▼
 ┌─────────────┐
 │  Brainstorm  │  ← you participate, approve design
 └──────┬───────┘
        ▼
 ┌─────────────┐
 │  Write Plan  │  ← you approve plan
 └──────┬───────┘
        ▼
 ┌──────────────┐
 │ Review Plan  │  ← autonomous staff engineer review
 └──────┬───────┘
        ▼
   For each task:
        │
        ▼
 ┌──────────────┐
 │ Implementer  │  TDD, functional core architecture
 └──────┬───────┘
        │
        ├──────────────────┬──────────────────┐
        ▼                  ▼                  ▼
 ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
 │    Spec      │   │   Quality   │   │  Security   │
 │  Reviewer    │   │  Reviewer   │   │  Reviewer   │
 └──────┬───────┘   └──────┬──────┘   └──────┬──────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           ▼
                 ┌───────────────────┐
                 │    Synthesis      │  deduplicates, resolves
                 │    Critiquer      │  contradictions, routes
                 └────────┬─────────┘
                          │
              ┌───────────┼───────────┐
              ▼           ▼           ▼
            PASS      LOCAL_FIX    KICKBACK
              │       (max 3,     (to human)
              │        retry)
              ▼
        Next task...
              │
              ▼
      Compounding Learner
      (proposes CLAUDE.md rules)
              │
              ▼
         Stage + Land
```

**You participate during brainstorm and planning. Everything after plan approval is autonomous.** You're only surfaced on kickbacks, blockers, or the final review.

### Key Principles

- **Plan before you code, always.** Spec-driven development, not vibe coding.
- **TDD is the quality backbone.** Tests encode intent; agents write implementation to pass them.
- **Functional core, imperative shell.** Pure domain logic with no dependencies. Mocks at boundaries only. Fakes over mocks.
- **Parallel review beats serial review.** Three independent reviewers catch more than one pass.
- **A single critiquer routes all decisions.** Coordinated review topology prevents the [17x error trap](https://towardsdatascience.com/why-your-multi-agent-system-is-failing-escaping-the-17x-error-trap-of-the-bag-of-agents/).
- **Compounding engineering.** Every correction gets encoded so each session is smarter.
- **Humans on the loop, not in the loop.** Build the harness. Fix the system, not the artifacts.

## Skills

8 skills, installed globally via `bash setup.sh`.

**Start here — the big three cover 90% of daily work:**

| Skill | What it does |
|-------|-------------|
| `/dev` | **The central command.** `/dev <description>` runs the full pipeline. `/dev next` picks up a Linear task. `/dev track <note>` captures for later. |
| `/harden` | **Retroactive quality.** Already wrote code that skipped the process? Run design review, spec review, quality, and security on it — fix what's found without throwing anything away. |
| `/stage` | **Wrap up.** Review, validate, squash into a clean commit. On worktree flow, prepares for wtr landing. Also the final phase of `/dev`. |

**Set up a project:**

| Skill | What it does |
|-------|-------------|
| `/dev-flow` | **Configure the flow.** Choose trunk (direct to main) or worktree (isolated branches). Sets up hooks and CLAUDE.md. Run once per project, again to switch. |

**Supporting skills:**

| Skill | What it does |
|-------|-------------|
| `/learn` | **Compounding learning.** Analyze recent work for patterns. Propose CLAUDE.md rules and permission changes. Detects when a project should switch flows. |
| `/brainstorm` | **Thought partner.** Explore ideas before committing to a direction. |
| `/review-plan` | **Staff engineer review.** Skeptical plan review before execution begins. |
| `/tidy` | **Hygiene.** Clean up dead worktrees, stale branches, orphaned Linear tasks. |

### How to Use

```bash
# First time in a project — choose trunk or worktree flow, set up hooks
/dev-flow

# Full pipeline — brainstorm, plan, review, implement, stage
/dev Add webhook notifications when deployments complete

# Pick up next task from Linear
/dev next

# Specific Linear task
/dev next PEN-55

# Capture something for later
/dev track Need to refactor the auth middleware

# Already wrote code, make it robust
/harden

# Reduce permission prompts, learn from recent work
/learn permissions

# Clean up dead worktrees and stale tasks
/tidy
```

### Internal Pipeline Components

The `/dev` and `/harden` pipelines dispatch subagents using prompt templates from `lib/`:

| Component | Purpose |
|-----------|---------|
| `lib/security-reviewer.md` | Read-only security audit instructions for the security review subagent |
| `lib/synthesis-critiquer.md` | Deduplication, contradiction resolution, and routing logic for the synthesis subagent |

These are not user-facing skills. They're read by `/dev` and `/harden` and inlined into subagent prompts.

### Dependencies

- **[amux](https://github.com/byoungs/amux)** — Terminal multiplexer for parallel agents
- **[wtr](https://github.com/byoungs/wtr)** — Worktree review TUI for reviewing and landing (worktree flow)
- **Linear MCP server** — Task coordination (`/dev`, `/dev next`, `/dev track`, `/tidy`)
- **Git worktrees** — `/dev` and `/stage` use `EnterWorktree`/`ExitWorktree` (worktree flow)
- **Superpowers plugin** — TDD, verification, code review templates

## Setup

```bash
bash setup.sh
```

Symlinks skills and the global `CLAUDE.md` into `~/.claude/` so they're available in every project. Then run `/dev-flow` in each project to configure trunk or worktree flow.

## Best Practices for All Projects

Standards across all repos in `~/src/`. Each project's `CLAUDE.md` should reference or extend these.

### Project Configuration

Skills read project context from each project's `CLAUDE.md`. `/dev-flow` helps set this up:

```markdown
## Dev Flow
Flow: worktree

## Linear
- Workspace: your-workspace
- Team: Your Team (key: XX)
- Project: Your Project Name

## Build & Test
- Build: go build ./...
- Test: go test ./...
```

### Environment Variable Hygiene

| File | In git? | Contains |
|------|---------|----------|
| `dev.env` | **Yes** | Non-secret defaults (DB URL, ports, flags) |
| `.env` | No | Secrets only (API keys, OAuth creds, tokens) |

- **No direnv.** `dev.sh` loads both files.
- **Makefile targets use hardcoded constants** for local DB — never env vars.
- **Dev and prod use SEPARATE credentials.** Prod goes in hosting secrets, never `.env`.

### Testing & Architecture

**Design for testability.** Use hexagonal architecture (ports and adapters) or functional core / imperative shell so that domain logic is testable without mocks:

- **Domain layer** — pure business logic, no dependencies. Tests need zero mocks.
- **Application layer** — use cases orchestrate domain logic through ports (interfaces). Tests mock only ports.
- **Infrastructure layer** — adapters implement ports (DB, APIs, filesystem). Use in-memory fakes for integration tests.

**Testing rules for agents:**
- **Prefer fakes over mocks.** `InMemoryUserRepo` > `mock(UserRepo)`.
- **Mock at system boundaries only.** Never mock the unit under test.
- **Assert on outputs, not call counts.** Tests verify behavior, not implementation.
- **Separate test-writing from implementation when possible.** Same-context tests mirror implementation, not intent.

AI agents over-mock by 36% vs humans ([arXiv study](https://arxiv.org/html/2602.00409v1)). These architecture and testing rules are the primary defense. See [Testing & Architecture research](research/testing-architecture-2026-03-28.md) for the full data.

### Hooks

Hooks enforce behavior that prompt instructions alone can't guarantee. `/dev-flow` configures them automatically:

| Flow | Hooks installed |
|------|----------------|
| **Both** | Auto-format after file writes, auto-test after commits, prevent amending pushed commits |
| **Worktree** | + Prevent all commits on main (forces worktree usage) |

Run `/dev-flow` in any project to set up hooks. Run it again to switch flows as the project evolves.

## Research & Design

The methodology above is backed by research into what the best practitioners are doing.

### Research
- [Expert Review](research/expert-review-2026-03-28.md) — Critical assessment against Boris Cherny, Kent Beck, Fowler, Willison, Yegge, Anthropic, Tornhill (Mar 2026)
- [Testing & Architecture](research/testing-architecture-2026-03-28.md) — How hexagonal architecture fixes AI's mock problem
- [Landscape Report](research/landscape-report.md) — Tools, frameworks, and patterns across the agentic dev ecosystem
- [Trusted Voices](research/trusted-voices.md) — Boris Cherny, Kent Beck, Martin Fowler, Simon Willison — tiered by credibility
- [ClawMux Analysis](research/clawmux-analysis.md) — 7-agent pipeline with kickback mechanism
- [Boris Cherny's Workflow](research/boris-cherny-workflow.md) — How the Claude Code creator ships 20-30 PRs/day
- [Retry Limits](research/retry-limits.md) — Expert consensus: 3 retries before escalation
- [Brainstorm Session](research/2026-03-27-brainstorm-session.md) — Design session notes

### Design
- [Pipeline Architecture](design/pipeline-architecture.md) — Full pipeline spec
- [Comparison Matrix](design/comparison-matrix.md) — Stage-by-stage comparison against ClawMux, Boris, superpowers baseline

### References
- [Key Reading List](references/key-reading-list.md) — Prioritized reading (Anthropic eng blog, practitioner workflows, methodology)
