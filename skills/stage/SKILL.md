---
name: stage
description: Autonomous review, validate, commit, and prepare a single rebased commit for Brian's local review and ff-only merge
disable-model-invocation: true
argument-hint: "[optional: issue ID like PEN-55]"
---

## Stage the current task

Wrap up the current worktree work: review, validate, squash into a single commit rebased on main, and hand off for Brian's local review via `wtr`. Does NOT merge to main — Brian does that.

### Step 1: Verify you're in a worktree

1. Run `git status` and check the current branch — you should NOT be on main
2. If you're on main, tell the user there's nothing to stage and stop
3. Check for uncommitted changes — if any, they need to be committed or stashed

### Step 2: Code review

Review all changes vs main (`git diff main`) as a senior tech lead. Focus on:
- Bugs, logic errors, off-by-one
- Security issues (injection, auth, data exposure)
- Pattern violations per CLAUDE.md
- Missing error handling for likely failure modes
- Dead code, debug logging, TODO comments that shouldn't ship

**Fix issues immediately.** Don't just report them — edit the code. After fixing, re-review your own fixes.

### Step 3: Run the project's validation gate

Read CLAUDE.md for the project's test commands. Use the strongest available:
- If `make validate` exists → run it (full suite including integration tests)
- Else if `make test` exists → run it
- Else check CLAUDE.md for project-specific commands

**This is the same gate `wtr` uses during `land`.** If it fails here, it will fail there.
**Do NOT hand off work that fails validation.**

If anything fails, fix it and re-run. Max 3 attempts, then stop and report what's broken.

### Step 4: Completeness check

Before staging, verify the work is actually done:

1. **If a Linear issue ID was provided or can be inferred from the branch name**, fetch the issue and check acceptance criteria. If Linear is not configured for this project, skip this — just verify against the commit messages and any plan docs.

2. **Trace the feature end-to-end.** Ask: "does this actually work for the human?" If it's a bug fix, is the bug actually fixed? If it's a feature, does the happy path work?

3. **If work appears incomplete**, stop and tell the user what's missing. Offer to continue implementing or stage what's done with a note.

### Step 5: Prepare a single commit

The goal is **exactly one commit ahead of main**, up-to-date, ready for `git merge --ff-only`.

**This is non-negotiable: the branch MUST end up exactly 1 commit ahead of main. Not 0, not 2+. Verify before handing off.**

1. Stage all changes individually with `git add <file>`. NEVER use `git add .` or `git add -A`
2. Rebase onto main FIRST: `git rebase main` — resolve any conflicts. This ensures you're up-to-date.
3. If there are multiple commits on the branch, squash to one:
   ```bash
   # Find the merge base
   BASE=$(git merge-base HEAD main)
   # Soft reset to merge base (keeps all changes staged)
   git reset --soft $BASE
   # Re-commit as a single commit
   git commit -m "commit message here"
   ```
4. **Verify exactly 1 commit ahead of main:** `git log --oneline main..HEAD`
   - If 0 commits: something went wrong — your changes were lost. STOP and tell the user.
   - If 2+ commits: squash failed. Re-run step 3.
   - If 1 commit: correct. Proceed.
5. **Run validation again after rebase.** Rebasing can introduce failures.
6. **Re-rebase right before handoff.** Main may have advanced during the session via parallel agents or manual commits. Run `git rebase main` again immediately before Step 7 and re-verify exactly 1 commit ahead. A stale branch surfaces new commits' files as `deleted` in `wtr`; this rebase fixes that.

Write the commit message following the project's recent commit style (check `git log --oneline -10` on main). Include Linear issue ID if available.

### Step 6: Update Linear (if configured)

If the project uses Linear (check CLAUDE.md for team/project name):
1. If an issue ID was provided (`$ARGUMENTS`), use that. Otherwise, infer from the branch name
2. Move the Linear issue to "In Review"
3. Post a comment summarizing what was done

**If Linear is not configured for this project, skip this step entirely.**

### Step 7: Hand off to Brian

Tell the user:
- The worktree path
- The branch name
- What the commit contains (brief summary)
- Any areas that deserve extra attention during review
- Suggest: `wtr` to review and land

Brian reviews in `wtr` and lands with `l` (ff-only merge → validate → push).

**Do NOT merge to main. Do NOT push to origin. Do NOT deploy.
Do NOT hand off work that fails validation.**
