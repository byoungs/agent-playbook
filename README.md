# Agent Playbook

Reusable Claude Code skills for agent coordination across all projects. Managed by [Penfield Six](https://github.com/byoungs).

## Skills

### Agent Coordination
| Skill | Description |
|-------|-------------|
| `/name-agent` | Get a session number (1-9) for agent identity and port isolation |
| `/track` | Quick-capture observations, bugs, ideas → Linear backlog items |
| `/brainstorm` | Pure thought partner — explore vague ideas without producing artifacts |
| `/now` | Create a Linear task from a description, claim it, enter a worktree, and start planning |
| `/next` | Pick up the next task from Linear, plan, execute in a worktree |
| `/stage` | Review, validate, squash into a single rebased commit for local review and ff-only merge |
| `/team-dash` | One-shot team dashboard — active agents, health checks, problems |

### Dependencies

- **Linear MCP server** — Required for `/track`, `/now`, `/next`, `/stage`, `/team-dash`. The skills read Linear configuration (team, project) from each project's `CLAUDE.md`.
- **Git worktrees** — `/now`, `/next`, `/stage`, and `/build-feature` use Claude Code's `EnterWorktree`/`ExitWorktree` for safe parallel work.

## Setup

```bash
bash setup.sh
```

This symlinks each skill into `~/.claude/skills/` so they're available in every project. Project-specific skills (like `/deploy`) stay in each project's `.claude/skills/` directory.

## Project Configuration

Skills that need project context (Linear team/project, build commands) read from the project's `CLAUDE.md`. Include a section like:

```markdown
## Linear
- Workspace: your-workspace
- Team: Your Team (key: XX)
- Project: Your Project Name

## Build & Test
- Build: go build ./...
- Test: go test ./...
- Frontend: npx --prefix client tsc -p client/tsconfig.json --noEmit
```

## Environment Variable Hygiene

Standard pattern for all projects:

| File | In git? | Contains |
|------|---------|----------|
| `dev.env` | **Yes** | Non-secret defaults (DB URL, ports, flags, dev signing keys) |
| `.env` | No | Secrets only (API keys, OAuth creds, tokens) + personal info |

**Rules:**
- **No direnv.** `dev.sh` loads both files explicitly before starting servers.
- **Makefile targets use hardcoded constants** for local DB — never env vars.
- **Dev and prod use SEPARATE credentials.** Prod creds go in hosting platform secrets (e.g., `fly secrets set`), never in `.env`.
- **`dev.env` values with `$` must be single-quoted** — `dev.sh` uses a safe loader but `$` in unquoted values is a shell footgun.
- **SESSION_NUMBER in `dev.env`** offsets ports for parallel agents (Go: 8080+N, Vite: 5173+N).

### For new projects

1. Create `dev.env` with non-secret defaults (DB connection, `MOCK_LLM=true`, ports)
2. Create `.env` for secrets, add `.env` to `.gitignore`
3. Have `dev.sh` load both files safely before starting servers
4. Hardcode local DB connection in Makefile and ORM config — no env vars

## Research & Design (2026-03-27)

Research and architecture for the enhanced agentic pipeline — parallel reviews, synthesis critiquer with kickback mechanism, security review, and compounding learning.

### Research
- [Landscape Report](research/landscape-report.md) — Tools, frameworks, and patterns across the agentic dev ecosystem
- [Trusted Voices](research/trusted-voices.md) — Who to trust: Boris Cherny, Kent Beck, Martin Fowler, Simon Willison, Karpathy, Yegge, etc.
- [ClawMux Analysis](research/clawmux-analysis.md) — Deep dive on the 7-agent pipeline orchestrator with kickback mechanism
- [Boris Cherny's Workflow](research/boris-cherny-workflow.md) — How the Claude Code creator uses Claude Code (20-30 PRs/day)
- [Retry Limits](research/retry-limits.md) — Expert consensus on loop/retry limits (the magic number is 3)
- [Brainstorm Session](research/2026-03-27-brainstorm-session.md) — Full session summary: how we got here, every design decision and why, plan review findings, open questions
- [Expert Review](research/expert-review-2026-03-28.md) — Critical assessment of pipeline against latest expert thinking (Boris, Beck, Fowler, Willison, Yegge, Anthropic, Tornhill)
- [Testing & Architecture](research/testing-architecture-2026-03-28.md) — How hexagonal architecture and functional core/imperative shell fix AI's mock problem; five-layer defense stack for test quality

### Design
- [Pipeline Architecture](design/pipeline-architecture.md) — The enhanced pipeline: parallel reviews, synthesis critiquer, kickbacks, compounding learning
- [Comparison Matrix](design/comparison-matrix.md) — Stage-by-stage comparison against ClawMux, Boris, superpowers baseline

### References
- [Key Reading List](references/key-reading-list.md) — Prioritized reading list (Anthropic eng blog, practitioner workflows, methodology)

### Enhanced Pipeline Skills

Built from this research, installed in `~/.claude/skills/`:

| Skill | Description |
|-------|-------------|
| `/build-feature` | **End-to-end**: brainstorm → plan → review → execute. Creates Linear issue, works in worktree, tracks progress throughout. The single entry point for new features. |
| `/enhanced-pipeline` | Full orchestration: parallel reviews, kickbacks, compounding learning. Use directly when you already have a plan. |
| `/review-plan` | Staff engineer plan review before execution |
| `/security-reviewer` | Read-only security audit (subagent persona) |
| `/synthesis-critiquer` | Meta-reviewer + pipeline router with kickback mechanism |
| `/compounding-learner` | Pattern detection, CLAUDE.md auto-updates, permission analysis |

### How to Use

**New feature (full pipeline):**
```
/build-feature Add webhook notifications when deployments complete
```
Creates Linear issue → brainstorms design (you approve) → writes plan (you approve) → reviews plan → executes autonomously in worktree → presents merge/PR options.

**Already have a plan:**
```
/enhanced-pipeline docs/superpowers/plans/your-plan.md
```

**Already implemented, want reviews:**
```
Skip implementation, run the review phase of /enhanced-pipeline starting from Step 2 for the changes on this branch. Task requirements: [paste or point to plan]
```

**Just review a plan:**
```
/review-plan docs/superpowers/plans/your-plan.md
```

## Philosophy

- **Linear is the coordination layer.** All task tracking, agent communication, and status lives in Linear.
- **Skills are generic.** Project-specific config comes from each project's CLAUDE.md, not from the skills themselves.
- **Worktrees for safety.** Code changes never happen on main.
- **Could be adapted.** Linear is free and good at this, but the patterns could work with GitHub Issues, a text file, or any other tracking system if needed.
