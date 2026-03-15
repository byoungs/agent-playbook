---
name: track
description: Capture observations, bugs, feature ideas, or gaps into Linear — quick note or deep exploration. Non-blocking by default.
disable-model-invocation: false
argument-hint: "<observation or idea in plain English>"
---

## Track — Capture and explore product work

`/track` is how the user captures observations about the product — bugs, gaps, feature ideas, rough edges — and optionally explores them more deeply. It creates Linear issues so all agents can see and coordinate around them.

**Philosophy:** One observation usually represents a broader gap. When someone says "you can't get back to the home page after signing in," that's not just a missing link — it's a navigation gap that probably includes missing signup nav, no breadcrumbs, etc. Always think broader than the literal observation.

**Requires:** Linear MCP server configured. Read the project's CLAUDE.md for Linear team name, project name, and workspace details.

### The conversation flow

**Start by acknowledging the observation from `$ARGUMENTS`.** Then ask two quick questions:

> Got it. Quick read:
>
> **Priority?** 🚨 Launch blocker · ⬆️ High · ➡️ Medium · ⬇️ Low · 💡 Idea
>
> **Explore now or track it?** I can dig in now or just save it for later.

Keep this lightweight — the user can answer in a few words ("high, track it" or "blocker, let's explore").

---

### Path A: "Just track it" (quick capture)

1. Create a Linear issue in the project specified in CLAUDE.md with:
   - Clear title summarizing the observation
   - Status: **Backlog**
   - Priority: set from user's answer (map: launch blocker → Urgent, high → High, medium → Normal, low → Low, idea → Low)
   - Description containing:
     - The observation as-is
     - Your quick take on what broader gap this might represent (1-2 sentences)

2. If the observation seems related to existing issues, check Linear and mention related issues in the description.

3. Confirm: "Tracked as **PEN-XX: title** (priority). When you're ready to explore it deeper, run `/track PEN-XX`."

**Done. Stop here.**

---

### Path B: "Explore it" (deep dive)

Run an interactive exploration. Ask questions in small batches (2-3 at a time, not a wall of 10). Cover:

#### Understanding the gap
- What triggered this observation? (user testing, self-use, feedback?)
- Is this about the current state being wrong, or a missing capability?
- Who does this affect? (new visitors, signed-in users, admins, end users?)

#### Scoping the broader issue
- What related problems exist in the same area? (Check the codebase, existing Linear issues, and docs)
- Should this be one issue or split into several?
- What's the minimum viable fix vs. the ideal solution?

#### Priority and timing
- Is this a launch blocker? (Would it embarrass us if a new user hit this on day 1?)
- Is it time-sensitive? (Gets worse with more users? Blocks other work?)
- How does it compare to other work in Linear?

**The user can say "that's enough" at any point.** When they do, or when you've covered enough ground:

1. Create one or more Linear issues with status **Todo** (explored and ready for implementation):
   - Detailed description with context from the exploration
   - Minimum viable fix vs. ideal solution
   - Priority set with reasoning
   - Related issues linked
   - If multiple issues, set up parent/sub-issue structure or blocking relations as appropriate

2. If exploration revealed knowledge worth preserving (design reasoning, user insight, architectural context), offer to update appropriate docs in the repo.

3. Summarize what was captured. Suggest next steps:
   - "Ready to implement? Run `/next PEN-XX`"
   - "Want to think more broadly? Run `/brainstorm` on this topic"
   - "Related issues that might be worth exploring: ..."

---

### Path C: Revisiting a raw issue

If `$ARGUMENTS` is a Linear issue ID (e.g., `/track PEN-42`):

1. Fetch the issue from Linear
2. Say: "Picking up where we left off on **PEN-42: title**. Current status: Backlog. Want to explore it now?"
3. If yes, follow Path B using the existing observation as the starting point
4. Update the existing issue (don't create a new one) — move to Todo when explored

---

### Rules

- **Never block the user.** If they say "just track it," track it and stop. No "but first let me ask..."
- **Think broadly.** One observation = look for the family of related issues.
- **Check existing Linear issues** before creating duplicates. If a related issue exists, link to it or expand it.
- **Priority is a recommendation.** State your reasoning but the user decides.
- **Docs updates are for durable knowledge.** Don't put implementation details in docs — that's what the Linear issue description is for.
