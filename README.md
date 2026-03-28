# Agent Playbook

This is the brain. The central authority for how I build software with AI agents — the methodology, the skills, the research behind it all.

Every project in `~/src/` shares these skills and follows these patterns. Project-specific config lives in each project's `CLAUDE.md`; the universal system lives here.

## Here's How I Work

I run multiple Claude Code agents in parallel using three tools:

**[amux](https://github.com/byoungs/amux)** — A terminal multiplexer purpose-built for parallel AI coding. Agents expand and contract fluidly. Pane borders show agent state (working, waiting, idle). I zoom in to pair with one agent, zoom out to survey the team.

**[wtr](https://github.com/byoungs/wtr)** — A worktree review TUI. When an agent finishes work in a worktree, I review the diff, run tests, and land (ff-only merge → validate → push) — all without leaving the terminal.

**[Linear](https://linear.app)** — The coordination layer. Every task gets a Linear issue. Agents post status updates as they work. I see the big picture in Linear; I see the code in wtr; I manage attention in amux.

A typical session looks like this:

```
┌─────────────────────────────────────────────────────────┐
│  amux                                                   │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Agent 1     │  │ Agent 2     │  │ Agent 3     │     │
│  │ /dev Add    │  │ /dev next   │  │ /harden     │     │
│  │ auth system │  │ PEN-42      │  │ (reviewing  │     │
│  │             │  │             │  │  yesterday's │     │
│  │ [working]   │  │ [waiting]   │  │  code)      │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
│  Agent 1: implementing auth (Phase 4, task 3/5)         │
│  Agent 2: waiting for plan approval                     │
│  Agent 3: security review found 2 issues, fixing...     │
│                                                         │
│  Linear: 3 tasks in progress, 2 in review               │
└─────────────────────────────────────────────────────────┘
```

When agents finish, I switch to wtr to review and land their work:

```
wtr → review diff → run tests → land (ff-only merge → push)
```

### The Project Lifecycle

Projects follow a natural arc from simple to structured:

**Early stage** — Work directly on main. Low ceremony. Just describe what you need.
```
"Fix the date parser"  →  agent works on main  →  commit  →  push
```

**Growing** — Move to worktrees as the project develops and parallel work increases.
```
/dev Add user auth  →  Linear issue  →  worktree  →  plan  →  implement  →  review in wtr  →  land
```

**Mature** — Full pipeline with parallel agents in amux, structured review, compounding learning.
```
/dev Add webhooks  →  brainstorm  →  plan  →  3 parallel reviewers  →  synthesis critiquer  →  land
```

Every project I've built — ai-scheduler, wtr, clueless-closet, trade — has gone through this same arc.

## The Development Pipeline

When work goes through the full `/dev` pipeline, here's what happens:

```
 Human
   │
   │  /dev Add webhook notifications
   ▼
 ┌─────────────┐
 │  Brainstorm  │  ← human participates, approves design
 └──────┬───────┘
        ▼
 ┌─────────────┐
 │  Write Plan  │  ← human approves plan
 └──────┬───────┘
        ▼
 ┌──────────────┐
 │ Review Plan  │  ← staff engineer skepticism (autonomous)
 └──────┬───────┘
        ▼
   For each task:
        │
        ▼
 ┌──────────────┐
 │ Implementer  │  TDD, self-review, functional core architecture
 └──────┬───────┘
        │
        ├──────────────────┬──────────────────┐
        ▼                  ▼                  ▼
 ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
 │    Spec      │   │   Quality   │   │  Security   │  3 reviewers
 │  Reviewer    │   │  Reviewer   │   │  Reviewer   │  in parallel
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
      Stage for review in wtr
```

**Human touchpoints:** I participate during brainstorm and planning. After plan approval, the pipeline runs autonomously. I'm only surfaced if a kickback or blocker occurs. When it's done, I review and land in wtr.

### Key Principles

- **Plan before you code, always.** Spec-driven development, not vibe coding.
- **TDD is the quality backbone.** Tests encode intent; agents write implementation to pass them.
- **Functional core, imperative shell.** Pure domain logic with no dependencies. Mocks at boundaries only. Fakes over mocks.
- **Parallel review beats serial review.** Three independent reviewers catch more than one pass.
- **A single critiquer routes all decisions.** Coordinated review topology prevents the [17x error trap](https://towardsdatascience.com/why-your-multi-agent-system-is-failing-escaping-the-17x-error-trap-of-the-bag-of-agents/).
- **Compounding engineering.** Every correction gets encoded so each session is smarter.
- **Humans on the loop, not in the loop.** Build the harness. Fix the system, not the artifacts.

## Skills

7 skills, installed globally via `bash setup.sh`.

| Skill | What it does |
|-------|-------------|
| `/dev` | **The central command.** `/dev <description>` runs the full pipeline. `/dev next` picks up a Linear task. `/dev track <note>` captures for later. |
| `/harden` | **Retroactive quality.** Already wrote code? Run the review pipeline on it without throwing anything away. |
| `/learn` | **Compounding learning.** Analyze recent work for patterns. Propose CLAUDE.md rules and permission changes to reduce friction. |
| `/brainstorm` | **Thought partner.** Explore ideas before committing to a direction. |
| `/review-plan` | **Staff engineer review.** Skeptical plan review before execution begins. |
| `/stage` | **Wrap up.** Review, validate, squash into a clean commit for wtr landing. Also the final phase of `/dev`. |
| `/tidy` | **Hygiene.** Clean up dead worktrees, stale branches, orphaned Linear tasks. |

### How to Use

```bash
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

The `/dev` and `/harden` pipelines dispatch subagents using instructions from `lib/`:

| Component | Purpose |
|-----------|---------|
| `lib/security-reviewer.md` | Read-only security audit instructions for the security review subagent |
| `lib/synthesis-critiquer.md` | Deduplication, contradiction resolution, and routing logic for the synthesis subagent |

These are not user-facing skills. They're prompt templates that `/dev` and `/harden` read and inline into subagent dispatches.

### Dependencies

- **[amux](https://github.com/byoungs/amux)** — Terminal multiplexer for parallel agents
- **[wtr](https://github.com/byoungs/wtr)** — Worktree review TUI for reviewing and landing agent work
- **Linear MCP server** — Task coordination (`/dev`, `/dev next`, `/dev track`, `/tidy`)
- **Git worktrees** — `/dev` and `/stage` use `EnterWorktree`/`ExitWorktree`
- **Superpowers plugin** — TDD, verification, code review templates

## Setup

```bash
bash setup.sh
```

Symlinks skills and the global `CLAUDE.md` into `~/.claude/` so they're available in every project.

## Best Practices for All Projects

Standards across all repos in `~/src/`. Each project's `CLAUDE.md` should reference or extend these.

### Project Configuration

Skills read project context from each project's `CLAUDE.md`:

```markdown
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

- **Functional core + imperative shell.** Pure business logic in a core layer; side effects in a thin shell.
- **Prefer fakes over mocks.** `InMemoryUserRepo` > `mock(UserRepo)`.
- **Mock at system boundaries only.** Never mock the unit under test.
- **Assert on outputs, not call counts.**
- **Separate test-writing from implementation when possible.**

See [Testing & Architecture research](research/testing-architecture-2026-03-28.md) for the data behind these rules.

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
