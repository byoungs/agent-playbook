# Agent Playbook

Reusable Claude Code skills for agent coordination across all projects. Managed by [Penfield Six](https://github.com/byoungs).

## Skills

### Agent Coordination
| Skill | Description |
|-------|-------------|
| `/name-agent` | Get a session number (1-9) for agent identity and port isolation |
| `/track` | Quick-capture observations, bugs, ideas → Linear backlog items |
| `/brainstorm` | Pure thought partner — explore vague ideas without producing artifacts |
| `/next` | Pick up the next task from Linear, plan, execute in a worktree |
| `/ship` | Review, validate, commit, push, merge, close — with completeness checks |
| `/team-dash` | One-shot team dashboard — active agents, health checks, problems |

### Dependencies

- **Linear MCP server** — Required for `/track`, `/next`, `/ship`, `/team-dash`. The skills read Linear configuration (team, project) from each project's `CLAUDE.md`.
- **Git worktrees** — `/next` and `/ship` use Claude Code's `EnterWorktree`/`ExitWorktree` for safe parallel work.

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

## Philosophy

- **Linear is the coordination layer.** All task tracking, agent communication, and status lives in Linear.
- **Skills are generic.** Project-specific config comes from each project's CLAUDE.md, not from the skills themselves.
- **Worktrees for safety.** Code changes never happen on main.
- **Could be adapted.** Linear is free and good at this, but the patterns could work with GitHub Issues, a text file, or any other tracking system if needed.
