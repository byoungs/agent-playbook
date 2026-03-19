---
name: ship
description: Autonomous review, validate, commit, and prepare a single rebased commit for Brian's local review and ff-only merge
disable-model-invocation: true
argument-hint: "[optional: issue ID like PEN-55]"
---

## Ship the current task

Wrap up the current worktree work: review, validate, squash into a single commit rebased on main, and hand off for Brian's local review. Does NOT merge to main — Brian does that.

**Requires:** Linear MCP server configured. Read the project's CLAUDE.md for Linear team name, project name, build/test commands.

### Step 1: Verify you're in a worktree

1. Run `git status` and check the current branch — you should NOT be on main
2. If you're on main, tell the user there's nothing to ship and stop

### Step 2: Code review

Review all uncommitted + committed-but-unmerged changes as a senior tech lead. Focus on:
- Bugs, logic errors, off-by-one
- Security issues (injection, auth, data exposure)
- Pattern violations per CLAUDE.md
- Missing error handling for likely failure modes

**Fix issues immediately.** Don't just report them — edit the code. After fixing, re-review your own fixes.

### Step 3: Run checks

Run the project's build and test commands. Check CLAUDE.md for project-specific commands. Common patterns:

- **Go:** `go build ./...` and `go test ./...`
- **Python:** `make typecheck` and `make test` (or `poetry run pytest`)
- **Node/TypeScript:** `npx tsc --noEmit` and `npm test`
- **Mixed (Go + React):** Run both backend and frontend checks
- **Makefile:** If `make build` and `make test` exist, prefer those

If anything fails, **fix it and re-run**. Max 3 attempts, then stop and report what's broken.

### Step 4: Completeness check

Before shipping, verify the work is actually done:

1. **If a Linear issue ID was provided or can be inferred from the branch name**, fetch the issue and check:
   - Does the issue description have acceptance criteria? Are they all met?
   - Are there sub-issues that are still open?
   - Does the code actually accomplish what the issue describes?

2. **Trace the feature end-to-end.** Ask: "does this actually work for the human at the end of it?" If data is collected, where does it go? If a button triggers an action, does it reach its destination?

3. **If work appears incomplete**, stop and tell the user what's missing. Offer to continue implementing or ship what's done with a note.

### Step 5: Prepare a single commit

The goal is **one clean commit** on a branch that is up-to-date with main, ready for `git merge --ff-only`.

1. Stage all changes individually with `git add <file>`. NEVER use `git add .` or `git add -A`
2. Commit (or amend into a single commit if there are multiple). Write a message following the project's recent commit style. Include Linear issue ID. End with:
   ```
   Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
   ```
3. Rebase onto main: `git rebase main` — resolve any conflicts
4. Verify the branch has exactly **1 commit** ahead of main: `git log --oneline main..HEAD`
   - If more than 1 commit, squash with `git rebase -r main` using fixup
5. Run checks one more time after rebase to make sure nothing broke

### Step 6: Update Linear

1. If an issue ID was provided (`$ARGUMENTS`), use that. Otherwise, infer from the branch name (e.g., `pen-56-sign-in-is-broken` → PEN-56)
2. Move the Linear issue to "In Review"
3. Post a comment: `"[agent: NAME] Ready for review. Branch: BRANCH. What was done: ... Needs attention: ..."`

### Step 7: Hand off to Brian

Tell the user:
- The worktree path (they review in VS Code GitLens)
- What the commit contains (brief summary)
- The Linear issue status
- Any areas that deserve extra attention during review

Brian will:
1. Review the commit in VS Code
2. `git merge --ff-only <branch>` on main
3. Run `make test`, `make validate`, `git push`, and `make deploy` from his terminal

**Do NOT merge to main. Do NOT push to origin. Do NOT deploy.**
