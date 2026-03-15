---
name: ship
description: Autonomous review, validate, commit, and push pipeline — detects incomplete work
disable-model-invocation: true
argument-hint: "[optional: issue ID like PEN-55]"
---

## Ship the current task

Wrap up the current worktree work: review, validate, commit, push, merge to main, and close out the Linear issue.

**Requires:** Linear MCP server configured. Read the project's CLAUDE.md for Linear team name, project name, build/test commands, and any deploy procedures.

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

### Step 5: Commit and push

1. Check for uncommitted changes — if any exist, commit them with a descriptive message referencing the Linear issue
2. Stage files individually with `git add <file>`. NEVER use `git add .` or `git add -A`
3. Write commit message following the project's recent commit style. Include issue ID. End with:
   ```
   Agent: NAME
   Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
   ```
4. Push the branch: `git push -u origin <branch>`

If push fails due to diverged branch, STOP and tell the user. Do NOT force push.

### Step 6: Merge to main

1. Use `ExitWorktree` to return to main and clean up the worktree
2. Run `git merge <branch>` to merge the work into main
3. Run `git push` to push main to the remote

### Step 7: Close out Linear

1. If an issue ID was provided (`$ARGUMENTS`), use that. Otherwise, infer from the branch name (e.g., `pen-56-sign-in-is-broken` → PEN-56)
2. Move the Linear issue to "Done"
3. Post a completion comment: `"[agent: NAME] Shipped. Branch: BRANCH. What was done: ... Follow-up: ..."`

### Step 8: Confirm

Tell the user:
- What was merged
- The Linear issue that was closed
- Whether the push to main succeeded
- Any follow-up items (deploy, notify someone, etc.)
