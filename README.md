# Agent Playbook

This is the brain. The central authority for how I build software with AI agents — the methodology, the skills, the research behind it all.

Every project shares these skills and follows these patterns. Project-specific config lives in each project's `CLAUDE.md`; the universal system lives here.

## How I Work

I run multiple Claude Code agents in parallel across projects using [amux](https://github.com/byoungs/amux) (a terminal multiplexer for AI coding) and [wtr](https://github.com/byoungs/wtr) (a worktree review TUI). A backlog lives in [Linear](https://linear.app) but most work starts as a thought — "this needs auth" or "that API is too slow" — and spins up from there.

```
┌──────────────────────────────────────────────────────────────┐
│  amux                                                        │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ trade/       │  │ wtr/         │  │ agent-       │       │
│  │ /dev Add     │  │ /dev Fix     │  │ playbook/    │       │
│  │ options API  │  │ rebase bug   │  │ /harden      │       │
│  │ [working]    │  │ [waiting]    │  │ [working]    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                              │
│  trade: implementing options pricing (task 3/5)              │
│  wtr: waiting for plan approval                              │
│  agent-playbook: security review found 1 issue, fixing...    │
└──────────────────────────────────────────────────────────────┘
```

One idea leads to another. An agent finishes auth in one project, and that surfaces a need in another. I spin up a new pane, describe the work, and it enters the pipeline. When agents finish, I review in wtr and land.

## Skills

8 skills, installed globally via `bash setup.sh`. Start with the big three:

| Skill | What it does |
|-------|-------------|
| `/dev` | **The central command.** `/dev <description>` runs the full pipeline. `/dev next` picks up a task from the backlog. `/dev track <note>` captures an idea for later. |
| `/harden` | **Retroactive quality.** Already wrote code that skipped the process? Run design review, spec, quality, and security on it — fix what's found without throwing anything away. |
| `/stage` | **Wrap up.** Review, validate, squash into a clean commit for landing. Also the final phase of `/dev`. |

```bash
/dev Add webhook notifications when deployments complete
/dev next
/dev track Need to refactor the auth middleware
/harden
/tidy
```

The rest:

| Skill | What it does |
|-------|-------------|
| `/dev-flow` | **Configure a project.** Choose trunk (direct to main) or worktree (isolated branches). Sets up hooks. |
| `/learn` | **Compounding learning.** Propose CLAUDE.md rules and permission changes from recent work. |
| `/brainstorm` | **Thought partner.** Explore ideas before committing to a direction. |
| `/review-plan` | **Staff engineer review.** Skeptical plan review before execution begins. |
| `/tidy` | **Hygiene.** Clean up dead worktrees, stale branches, orphaned tasks. |

## The Development Pipeline

Every piece of work goes through the same process. `/dev` orchestrates it:

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
        Next task → ... → Stage + Land
```

**You participate during brainstorm and planning. Everything after plan approval is autonomous.** You're only surfaced on kickbacks, blockers, or the final review.

### Two Flows

Projects use one of two flows (run `/dev-flow` to configure):

- **Trunk** — Agents work directly on main. Fast, simple. Best for solo or early-stage work.
- **Worktree** — Each agent gets an isolated branch. Review in wtr before landing. Best for parallel work.

The pipeline runs the same in both. Projects start on trunk and move to worktree as they grow.

### Key Principles

- **Pure functions and immutable data by default.** Clean code isn't just craft — it's agent infrastructure. Agents reason better, test easier, and spiral less in well-structured code. See [Code Design Rules](design/code-design-rules.md) for the full set of rules and reasoning.
- **Plan before you code.** Spec-driven development, not vibe coding.
- **TDD is the quality backbone.** Functional core, imperative shell. Fakes over mocks. Mock at boundaries only.
- **Parallel review.** Three independent reviewers catch more than one pass. A single [synthesis critiquer](design/pipeline-architecture.md) routes all decisions.
- **Compounding engineering.** Every correction gets encoded so each session is smarter.
- **Humans on the loop, not in the loop.** Build the harness. Fix the system, not the artifacts.

## Setup

```bash
bash setup.sh
```

Symlinks skills and the global `CLAUDE.md` into `~/.claude/` so they're available in every project. Then run `/dev-flow` in each project to configure its flow and hooks.

See [CONTRIBUTING.md](CONTRIBUTING.md) for maintaining this repo, propagating updates, and project configuration details.

## Research & Design

This methodology is backed by [research](research/) into what the best practitioners are doing — Boris Cherny, Kent Beck, Martin Fowler, Simon Willison, Steve Yegge, Anthropic engineering, and Adam Tornhill/CodeScene.

- [Code Design Rules](design/code-design-rules.md) — Why pure functions and immutability matter for agents, with rule-by-rule reasoning
- [Pipeline Architecture](design/pipeline-architecture.md) — Full pipeline spec
- [Expert Review](research/expert-review-2026-03-28.md) — Critical assessment against latest expert thinking (Mar 2026)
- [Testing & Architecture](research/testing-architecture-2026-03-28.md) — How hexagonal architecture fixes AI's mock problem
- [Key Reading List](references/key-reading-list.md) — Prioritized reading list
- [All research docs](research/)
