---
name: name-agent
description: Give this agent a unique name — Brian picks from a list to avoid collisions
disable-model-invocation: false
argument-hint: "<name from the list>"
---

## Name yourself

Every agent session needs a unique name so Brian can tell agents apart in Linear comments, commits, and conversation. **Brian assigns names — agents do not pick their own.**

### Step 1: Get a name from Brian

If `$ARGUMENTS` is provided, use that as your name. Skip to Step 2.

If `$ARGUMENTS` is NOT provided, show the list and wait:

> **Pick a name for me:**
>
> scout, falcon, cedar, flint, heron, quail, raven, slate, tiger, aspen, birch, crane, delta, egret, forge, grove, haven, inlet, kite, larch, marsh, north, orbit, pines, ridge, storm, thorn, vale, wharf, yarrow, zenith, ember, frost, ivory, jade, lunar, nova, onyx, pearl, ruby, coral, terra, wren, otter, sage, dusk, moss, cliff, brook, cove, reef

**STOP and wait for Brian to pick.** Do NOT pick a name yourself. Do NOT scan Linear or attempt any collision detection — Brian sees all his terminal tabs and handles de-duplication.

### Step 2: Announce yourself

Tell Brian your name. From now on:

- **All Linear comments** must start with `[agent: YOUR_NAME]` so Brian knows which agent posted
- When asked "who are you?" — respond with your name
- **If you discover another agent using the same name**, stop immediately and tell Brian
