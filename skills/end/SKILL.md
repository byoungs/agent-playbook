---
name: end
description: "End-of-session flush. Run when finishing work / wrapping up / 'done for now' / before exiting. Learns reusable permission allow-rules from the session, captures durable facts to working memory, sets any needed reminders/triggers, saves loose context, then hands off for exit. Systematizes the evolve-and-flush loop (replaces manually running /learn + adding memories + /exit)."
argument-hint: "[optional: focus note, e.g. 'skip permissions' or 'just memory']"
---

# /end — Session Flush & Evolve

One command to close out a work session. It compounds learning (so the next
session is smarter and prompts less) and flushes durable context to disk (so
nothing is lost when this conversation is cleared), then hands off for exit.

Run this instead of manually doing `/learn` → add memories → set reminders →
`/exit`.

## Hard rule: propose, then apply on approval

Per Brian's global rules, agent-generated proposals are NEVER written verbatim
without a human OK. So this skill:

1. Gathers everything and presents ONE consolidated **Flush Report**.
2. Waits for a single approval (`go` / edit / per-item skip).
3. Applies only the approved items.
4. Hands off for exit.

Do not write memory files, edit settings, or create triggers before the
approval gate. The whole point is a fast, reviewable batch — not silent writes.

## $ARGUMENTS

- empty → run all four sections below
- `skip permissions` / `just memory` / etc. → run only the named section(s)

## Checklist (create one todo per item)

1. Permissions sweep
2. Working-memory flush
3. Reminders & triggers
4. Loose-context capture
5. Present Flush Report → get approval
6. Apply approved items
7. Hand off for exit

---

## 1. Permissions sweep

Goal: turn this session's repeated permission friction into allow-rules so the
next session prompts less.

- Look back over THIS session's tool calls. Find Bash/MCP calls that were
  denied, prompted, or are obviously safe + repeated (and would prompt again).
- **Dedupe against existing rules FIRST.** Read the target settings file(s) and
  check whether a rule (incl. wildcards like `mcp__server__*`, `make *`,
  `git *`) already covers the pattern. If covered, propose nothing — say
  "already allowed." Likewise, if a GUIDE just restates an existing CLAUDE.md
  rule, mark it FLAG (agent drift), not a new rule.
- Classify each pattern (reuse the `/learn` taxonomy):
  - **ALLOW** — safe, repetitive → propose an exact rule for settings.
    e.g. `Bash(git stash)`, `Bash(make -C * deploy)`, `mcp__claude_ai_Google_Calendar__list_events`.
  - **GUIDE** — agent didn't need to do it; a better tool/path exists → propose a
    one-line CLAUDE.md rule instead of an allow.
  - **FLAG** — genuinely risky → note it, propose nothing.
- Respect Brian's banned-command rules (no `find`/`grep`/`cat`/pipes/`&&`); never
  propose allow-rules that bless those — propose the GUIDE alternative.
- Scope each ALLOW rule:
  - project-specific (paths, this repo's make targets) → project
    `.claude/settings.local.json`
  - universally safe across all projects → offer `~/.claude/settings.json`
  - default to project `settings.local.json` when unsure.
- Output: for each, the exact rule text + target file + one-line reason.

## 2. Working-memory flush

Goal: persist what a future session would need and can't re-derive from the repo
or git history.

- Use the project's auto-memory directory (the one named in this session's
  memory instructions: `~/.claude/projects/<encoded-cwd>/memory/`) and its
  `MEMORY.md` index.
- Review the session for durable facts. For each, pick a type:
  - `user` — who Brian is / stable preferences
  - `feedback` — guidance on how to work (include **Why** + **How to apply**)
  - `project` — ongoing work/goals/constraints not in the code (convert relative
    dates to absolute)
  - `reference` — pointers to external resources (URLs, dashboards, confs, IDs)
- **Dedupe first**: read `MEMORY.md`; if an existing file already covers it,
  propose an UPDATE to that file, not a new one. Delete memories proven wrong.
- Do NOT propose saving what the repo/git/CLAUDE.md already records, or what only
  mattered to this one conversation. If a fact is trivial, drop it.
- For each proposed memory: filename, type, the body (frontmatter + content,
  `[[links]]` to related memories), and the one-line `MEMORY.md` pointer.

Memory file format (one fact per file):

```markdown
---
name: <short-kebab-slug>
description: <one-line summary, used for recall>
metadata:
  type: user | feedback | project | reference
---

<the fact; for feedback/project add **Why:** and **How to apply:** lines.
Link related memories with [[their-name]].>
```

## 3. Reminders & triggers

Goal: nothing time-sensitive falls through after context is flushed.

- Scan the session for follow-ups with a time element (waiting on a reply, a
  deadline, a "check tomorrow", a deploy to verify).
- For each, propose a scheduled trigger:
  - one-shot → `create_trigger` with `run_once_at` (RFC3339, future), usually
    `create_new_session_on_fire: true` with a STANDALONE prompt (fresh session
    has no context — embed all needed facts).
  - recurring → `create_trigger` with `cron_expression`.
- Prefer wake times that match how fast the watched thing changes; default a
  check to ~10am ET next business day unless the deadline says otherwise.
- Output: name, fire time, and the full standalone prompt for each.

## 4. Loose-context capture

Goal: catch anything the above three missed.

- Open threads, half-finished work, decisions made, next obvious step, blockers.
- Route each:
  - belongs in working memory → fold into section 2
  - a concrete next task → `BACKLOG.md` (project root) or the project's task tracker
  - already safe in a file/commit/site → note it's covered, propose nothing
- Keep this tight. If everything's already captured, say "nothing loose."

## 5. Flush Report (the approval gate)

Present everything in one block, then STOP and wait for Brian:

```
## Flush Report

### Permissions (→ apply to settings)
- [rule] → [file] — [reason]   |  GUIDE: [claude.md line]  |  FLAG: [note]
(or "no permission changes")

### Working memory (→ write files + MEMORY.md)
- NEW  <file> (<type>): <one-line>
- EDIT <file>: <what changes>
(or "nothing to remember")

### Reminders (→ create triggers)
- <name> @ <when>: <standalone prompt summary>
(or "no reminders")

### Loose context
- <item> → <destination>
(or "nothing loose")

Reply `go` to apply all, or name items to skip / edit.
```

## 6. Apply approved items

Only after approval:
- Write/update memory files; add the one-line pointer(s) to `MEMORY.md`.
- Edit the settings file(s) with approved ALLOW rules; append approved GUIDE
  lines to the relevant CLAUDE.md.
- Create approved triggers; report each trigger ID so Brian can cancel/move it.
- Write approved backlog items.
- Confirm what was applied, concisely.

## 7. Hand off for exit

A skill can't quit the CLI for you (no exit tool; killing the process risks a
corrupt transcript). So finish with:

> Session flushed: <N> permission rules, <N> memories, <N> reminders. Safe to
> exit — press Ctrl+D or run `/exit`. Run `/clear` instead if you want to keep
> this terminal open with a clean context.

Then stop. Do not loop back.
