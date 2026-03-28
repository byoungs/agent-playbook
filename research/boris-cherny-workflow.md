# Boris Cherny's Claude Code Workflow

> Researched 2026-03-27. Boris is the creator and Head of Claude Code at Anthropic.

## Core Philosophy: Compounding Engineering

Every correction, every lesson learned, every best practice gets encoded into the system (CLAUDE.md, hooks, lint rules, skills) so each subsequent session is smarter than the last.

"You should never have to correct Claude twice for the same mistake."

## The Pipeline

1. **Spec/Plan** — Start in Plan Mode (shift+tab). Iterate until solid. Sometimes a second Claude reviews the plan "as a staff engineer."
2. **Draft/Execute** — Switch to auto-accept mode. Let Claude one-shot the implementation.
3. **Simplify** — `/simplify` dispatches parallel agents reviewing for reuse, quality, efficiency.
4. **Verify** — End-to-end testing. "Probably the most important thing" — 2-3x quality improvement.
5. **Review** — Multiple review agents in parallel → dedup agent synthesizes → human reviews. Catches ~80% of low-level bugs before human sees the code.

## Parallel Execution (The Biggest Productivity Unlock)

- 5 Claude Code instances simultaneously in iTerm2, each in its own git worktree (numbered 1-5)
- Additionally 5-10 sessions on claude.ai/code in browser tabs
- Can start sessions from phone via Claude iOS app
- Ships 20-30 PRs per day
- "Spinning up 3-5 git worktrees at once is the single biggest productivity unlock"

## CLAUDE.md as Institutional Memory

- Shared CLAUDE.md checked into git (~2,500 tokens), updated multiple times weekly
- When Claude does something incorrectly, team adds it to CLAUDE.md
- During code review, engineers tag `@.claude` on PRs to let Claude update the file
- Contents: style conventions, design guidelines, PR templates, common mistakes, domain knowledge

## Self-Expanding Quality Rules

When error categories surface repeatedly, Boris asks Claude to write lint rules that prevent the pattern at source — making the quality system itself AI-generated and self-expanding.

## Hooks for Deterministic Behavior

- **PostToolUse hooks**: Auto-format code after generation (catches last 10% of formatting)
- **Stop hooks**: For long-running tasks
- **Permission Route hooks**: Evaluate requests via Opus 4.5 for security
- **PostCompact hooks**: Fire when context compresses, allowing instruction re-injection

## Slash Commands

For any workflow repeated more than once a day, create a slash command:
- `/commit-push-pr` — dozens of times daily
- `/techdebt` — end of every session to find/eliminate duplicated code
- `/simplify` — parallel agents review changed code
- `/batch` — orchestrates parallel code migrations with worktree isolation

## Model Choice

"I use Opus 4.5 with thinking for everything." Even though bigger/slower, "since you have to steer it less and it's better at tool use, it is almost always faster than using a smaller model."

## Key Interviews

- [Lenny's Podcast (Feb 2026)](https://www.lennysnewsletter.com/p/head-of-claude-code-what-happens)
- [YC Lightcone (Feb 2026)](https://www.ycombinator.com/library/NJ-inside-claude-code-with-its-creator-boris-cherny)
- [Pragmatic Engineer (Mar 2026)](https://newsletter.pragmaticengineer.com/p/building-claude-code-with-boris-cherny)
- [Anthropic Blog: Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [howborisusesclaudecode.com](https://howborisusesclaudecode.com) (57 tips)
