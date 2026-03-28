# Agent Playbook

The central brain for how we build software with AI agents. This repo contains the development methodology, reusable skills, and research that guide all projects in `~/src/`.

Every project shares these skills and follows these patterns. Project-specific config lives in each project's `CLAUDE.md`; the universal system lives here.

## How We Work

### The Development Lifecycle

Projects follow a natural arc from simple to structured:

**Early stage** — Work directly on main. Low ceremony. Just describe what you need and go.
```
Human: "Fix the date parser"  →  Agent works on main  →  Commit  →  Push
```

**Growing** — Move to worktrees as the project develops. `/now` creates a task and isolates work.
```
Human: /now Add user authentication
  →  Linear issue created  →  Worktree  →  Plan  →  Implement  →  /stage  →  Review + merge
```

**Mature** — Full pipeline with parallel agents, structured review, and compounding learning.
```
Human: /build-feature Add webhook notifications
  →  Brainstorm  →  Plan  →  Review plan  →  Execute with enhanced pipeline  →  Merge
```

### The Enhanced Pipeline

When a feature goes through the full pipeline, here's what happens:

```
 Human
   │
   │  describes intent
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
 │ Implementer  │  TDD, self-review
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
 ┌──────────────────┐
 │   Compounding    │  proposes CLAUDE.md rules,
 │    Learner       │  permission changes
 └──────────────────┘
              │
              ▼
       Session Summary
```

**Human touchpoints:** You participate during brainstorm and planning. After plan approval, the pipeline runs autonomously. You're only surfaced if a kickback or blocker occurs.

### Key Principles

- **Plan before you code, always.** Spec-driven development, not vibe coding.
- **TDD is the quality backbone.** Tests encode intent; agents write implementation to pass them. Prefer fakes over mocks; mock at boundaries only.
- **Parallel review beats serial review.** Three independent reviewers catch more than one pass.
- **A single critiquer routes all decisions.** Coordinated review topology prevents the [17x error trap](https://towardsdatascience.com/why-your-multi-agent-system-is-failing-escaping-the-17x-error-trap-of-the-bag-of-agents/).
- **Compounding engineering.** Every correction gets encoded so each session is smarter. You should never correct an agent twice for the same mistake.
- **Humans on the loop, not in the loop.** Build the harness — specs, quality checks, workflow guidance. Fix the system, not the artifacts.

## Skills

Installed globally via `bash setup.sh`. Available in every project.

### Development Pipeline

| Skill | Description |
|-------|-------------|
| `/brainstorm` | Thought partner — explore ideas before committing to a direction |
| `/build-feature` | **End-to-end**: brainstorm → plan → review → execute → merge. The single entry point for new features. |
| `/enhanced-pipeline` | Full orchestration with parallel reviews, kickbacks, compounding learning. Use when you already have a plan. |
| `/review-plan` | Staff engineer plan review before execution begins |

### Review & Quality (used by the pipeline internally)

| Skill | Description |
|-------|-------------|
| `/security-reviewer` | Read-only security audit dispatched during review |
| `/synthesis-critiquer` | Deduplicates findings, resolves contradictions, decides routing (PASS / LOCAL_FIX / KICKBACK) |
| `/compounding-learner` | Detects recurring patterns, proposes CLAUDE.md updates |

### Agent Coordination

| Skill | Description |
|-------|-------------|
| `/now` | Create a Linear task, claim it, enter a worktree, start planning |
| `/next` | Pick up the next task from Linear, plan, execute in a worktree |
| `/stage` | Review, validate, squash into a single rebased commit for local ff-only merge |
| `/track` | Quick-capture observations, bugs, ideas → Linear backlog |
| `/team-dash` | One-shot team dashboard — active agents, health, problems |

### How to Use

```bash
# New feature, full pipeline
/build-feature Add webhook notifications when deployments complete

# Already have a plan
/enhanced-pipeline docs/superpowers/plans/your-plan.md

# Quick task, lightweight
/now Fix the broken date parser in utils.go

# Just review a plan
/review-plan docs/superpowers/plans/your-plan.md

# Already implemented, want the review phase only
# (describe what to review — the pipeline starts from Step 2)
```

### Dependencies

- **Linear MCP server** — for `/track`, `/now`, `/next`, `/stage`, `/team-dash`
- **Git worktrees** — `/now`, `/next`, `/stage`, `/build-feature` use `EnterWorktree`/`ExitWorktree`
- **Superpowers plugin** — the pipeline reuses superpowers skills (TDD, verification, code review)

## Setup

```bash
bash setup.sh
```

Symlinks skills and the global `CLAUDE.md` into `~/.claude/` so they're available in every project. Project-specific skills (like `/deploy`) stay in each project's `.claude/skills/`.

## Best Practices for All Projects

These are the standards across all repos in `~/src/`. Each project's `CLAUDE.md` should reference or extend these.

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
- Lint: golangci-lint run ./...
```

### Environment Variable Hygiene

| File | In git? | Contains |
|------|---------|----------|
| `dev.env` | **Yes** | Non-secret defaults (DB URL, ports, flags, dev signing keys) |
| `.env` | No | Secrets only (API keys, OAuth creds, tokens) |

**Rules:**
- **No direnv.** `dev.sh` loads both files explicitly before starting servers.
- **Makefile targets use hardcoded constants** for local DB — never env vars. Prevents accidentally running against the wrong database.
- **Dev and prod use SEPARATE credentials.** Prod creds go in hosting platform secrets (e.g., `fly secrets set`), never in `.env`.
- **SESSION_NUMBER in `dev.env`** offsets ports for parallel agents (Go: 8080+N, Vite: 5173+N).

**For new projects:** Create `dev.env` (in git) + `.env` (gitignored) + `dev.sh` that loads both.

### Testing & Architecture

- **Structure code as functional core + imperative shell.** Pure business logic in a core layer; side effects in a thin shell. Domain logic should be testable without mocks.
- **Prefer fakes over mocks.** A fake `InMemoryUserRepo` is more trustworthy than `mock(UserRepo)`.
- **Mock at system boundaries only.** Never mock the unit under test.
- **Assert on outputs, not call counts.** Tests verify behavior, not implementation.
- **Separate test-writing from implementation when possible.** Tests in the same context mirror the implementation, not intent.

See [Testing & Architecture research](research/testing-architecture-2026-03-28.md) for the full rationale (arXiv data, practitioner evidence, five-layer defense stack).

## Research & Design

The methodology in [How We Work](#how-we-work) is backed by research into what the best practitioners are doing.

### Research
- [Landscape Report](research/landscape-report.md) — Tools, frameworks, and patterns across the agentic dev ecosystem
- [Trusted Voices](research/trusted-voices.md) — Boris Cherny, Kent Beck, Martin Fowler, Simon Willison, Karpathy, Yegge — tiered by credibility
- [Expert Review](research/expert-review-2026-03-28.md) — Critical assessment against latest expert thinking (Mar 2026)
- [Testing & Architecture](research/testing-architecture-2026-03-28.md) — How hexagonal architecture fixes AI's mock problem
- [ClawMux Analysis](research/clawmux-analysis.md) — 7-agent pipeline with kickback mechanism (inspiration for our critiquer)
- [Boris Cherny's Workflow](research/boris-cherny-workflow.md) — How the Claude Code creator ships 20-30 PRs/day
- [Retry Limits](research/retry-limits.md) — Expert consensus: 3 retries before escalation
- [Brainstorm Session](research/2026-03-27-brainstorm-session.md) — Design session notes: how we got here, every decision and why

### Design
- [Pipeline Architecture](design/pipeline-architecture.md) — Full pipeline spec: parallel reviews, synthesis critiquer, kickbacks, compounding learning
- [Comparison Matrix](design/comparison-matrix.md) — Stage-by-stage comparison against ClawMux, Boris's workflow, superpowers baseline

### References
- [Key Reading List](references/key-reading-list.md) — Prioritized reading (Anthropic eng blog, practitioner workflows, methodology)

## Philosophy

- **This repo is the brain.** Central authority for development methodology, best practices, and agent skills across all projects.
- **Linear is the coordination layer.** Task tracking, agent communication, and status live in Linear.
- **Skills are generic.** Project-specific config comes from each project's `CLAUDE.md`, not from the skills.
- **Could be adapted.** Linear is free and good at this, but the patterns could work with GitHub Issues or any tracking system.
