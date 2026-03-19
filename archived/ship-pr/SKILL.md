---
name: ship-pr
description: Autonomous review, validate, commit, push, and open PR for human review — does not merge to main
disable-model-invocation: true
argument-hint: "[optional: issue ID like PEN-55]"
---

## Ship the current task as a PR

Wrap up the current worktree work: review, validate, commit, push, and open a pull request for human review. Does NOT merge to main.

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
   Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
   ```
4. Push the branch: `git push -u origin <branch>`

If push fails due to diverged branch, STOP and tell the user. Do NOT force push.

### Step 6: Create pull request

1. Determine the Linear issue ID — from `$ARGUMENTS`, or infer from branch name (e.g., `pen-56-sign-in-is-broken` -> PEN-56)
2. Create a PR using `gh pr create` with:
   - **Title:** Short description referencing the issue ID (e.g., "PEN-56: Fix sign-in redirect loop")
   - **Body:** Use this format:
     ```
     ## Summary
     <1-3 bullet points of what changed and why>

     ## Linear
     <Issue ID and link if available>

     ## Self-review notes
     <Anything you found and fixed during code review, or areas to pay extra attention to>

     ## Test plan
     - [ ] <How to verify this works>

     Generated with [Claude Code](https://claude.com/claude-code)
     ```
   - **Base branch:** main (or whatever the project's default branch is)

### Step 7: Update Linear

1. Move the Linear issue to **"In Review"**
2. Post a comment: `"[agent: NAME] PR ready for review: <PR_URL>. Branch: BRANCH. What was done: ... Needs attention: ..."`

### Step 8: Clean up worktree

1. Use `ExitWorktree` to return to main and clean up the local worktree
2. The branch lives on the remote — it will be needed until the PR is merged

### Step 9: Confirm

Tell the user:
- The PR URL
- What the PR contains (brief summary)
- The Linear issue that was moved to In Review
- Any areas that deserve extra attention during review
