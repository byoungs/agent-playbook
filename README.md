# Agent Playbook

Reusable Claude Code skills for agent coordination across all projects. Managed by [Penfield Six](https://github.com/byoungs).

## Skills

### Agent Coordination
| Skill | Description |
|-------|-------------|
| `/name-agent` | Assign a unique agent name for Linear comments and commits |
| `/track` | Quick-capture observations, bugs, ideas → Linear backlog items |
| `/brainstorm` | Pure thought partner — explore vague ideas without producing artifacts |
| `/next` | Pick up the next task from Linear, plan, execute in a worktree |
| `/ship` | Review, validate, commit, push, merge, close — with completeness checks |
| `/manage` | Dashboard of in-flight agent work, stalled detection, reassignment |

### Dependencies

- **Linear MCP server** — Required for `/track`, `/next`, `/ship`, `/manage`. The skills read Linear configuration (team, project) from each project's `CLAUDE.md`.
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

## Philosophy

- **Linear is the coordination layer.** All task tracking, agent communication, and status lives in Linear.
- **Skills are generic.** Project-specific config comes from each project's CLAUDE.md, not from the skills themselves.
- **Worktrees for safety.** Code changes never happen on main.
- **Could be adapted.** Linear is free and good at this, but the patterns could work with GitHub Issues, a text file, or any other tracking system if needed.
