# Contributing to Agent Playbook

This repo runs on **trunk flow** — agents contribute directly to main.

## Testing

This is a knowledge repo (markdown, skills, research), not a code project. Its "tests" are consistency checks validated by Claude and gated by a stamp file.

```bash
make test
```

The stamp (`.consistency-stamp`) records the commit hash when consistency was last verified by `/harden` or `/stage`. If the stamp matches HEAD, the test passes. If it's stale:

```
FAIL: Consistency stamp is stale.
      Run /harden to re-validate after your changes.
```

The consistency check validates:
- All skills in `skills/` are listed in the README
- No README references to skills that don't exist
- Internal references (`lib/` files) are valid

## Project Configuration

Skills read project context from each project's `CLAUDE.md`. `/dev-flow` sets this up:

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

## Environment Variable Hygiene

Standard pattern for all projects in `~/src/`:

| File | In git? | Contains |
|------|---------|----------|
| `dev.env` | **Yes** | Non-secret defaults (DB URL, ports, flags) |
| `.env` | No | Secrets only (API keys, OAuth creds, tokens) |

- **No direnv.** `dev.sh` loads both files.
- **Makefile targets use hardcoded constants** for local DB — never env vars.
- **Dev and prod use SEPARATE credentials.** Prod goes in hosting secrets, never `.env`.

## Testing & Architecture Standards

Use hexagonal architecture (ports and adapters) or functional core / imperative shell so that domain logic is testable without mocks:

- **Domain layer** — pure business logic, no dependencies. Tests need zero mocks.
- **Application layer** — use cases through ports (interfaces). Tests mock only ports.
- **Infrastructure layer** — adapters (DB, APIs). Use in-memory fakes for integration tests.

**Testing rules for agents:**
- Prefer fakes over mocks. `InMemoryUserRepo` > `mock(UserRepo)`.
- Mock at system boundaries only. Never mock the unit under test.
- Assert on outputs, not call counts.
- Separate test-writing from implementation when possible.

AI agents over-mock by 36% vs humans ([arXiv study](https://arxiv.org/html/2602.00409v1)). See [testing research](research/testing-architecture-2026-03-28.md) for the full data.

## Hooks

`/dev-flow` configures per-project hooks:

| Flow | Hooks installed |
|------|----------------|
| **Both** | Auto-format after file writes, auto-test after commits, prevent amending pushed commits |
| **Worktree** | + Prevent all commits on main |

A global PostCompact hook (in `~/.claude/settings.json`) confirms when CLAUDE.md has been refreshed from disk after compaction.

## Propagating Updates to Running Agents

When you update skills, rules, or patterns in this repo:

1. Commit to main (skills and CLAUDE.md are symlinked — changes are on disk immediately)
2. In a running agent session, type `/compact`
3. Claude Code re-reads CLAUDE.md fresh from disk — all new rules are active
4. The PostCompact hook confirms the refresh

New sessions always get the latest at startup. Long-running sessions get updates on auto-compaction (~95% context) or manual `/compact`.

**Note:** Skill *content* updates on compaction, but the skill *list* (available `/slash-commands`) loads at session start. Added or renamed skills need a new session.

## Internal Pipeline Components

`/dev` and `/harden` dispatch subagents using prompt templates from `lib/`:

| File | Purpose |
|------|---------|
| `lib/security-reviewer.md` | Security audit instructions for the review subagent |
| `lib/synthesis-critiquer.md` | Deduplication, routing logic for the synthesis subagent |

These are not user-facing skills. They're read and inlined into subagent prompts.

## Dependencies

- **[amux](https://github.com/byoungs/amux)** — Terminal multiplexer for parallel agents
- **[wtr](https://github.com/byoungs/wtr)** — Worktree review TUI (worktree flow)
- **Linear MCP server** — Backlog management (`/dev next`, `/dev track`, `/tidy`)
- **Git worktrees** — `/dev` and `/stage` use `EnterWorktree`/`ExitWorktree` (worktree flow)
- **Superpowers plugin** — TDD, verification, code review templates
