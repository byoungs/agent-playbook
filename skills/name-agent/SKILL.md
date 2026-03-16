---
name: name-agent
description: Get a session number from Brian (1-9) for agent identity and port offset
disable-model-invocation: false
argument-hint: "<number 1-9>"
---

## Get your session number

Every agent session needs a number (1-9) for identity and port isolation.

### Step 1: Get a number from Brian

If `$ARGUMENTS` is a number 1-9, use it. Skip to Step 2.

Otherwise, ask:

> **What number am I? (1-9)**

**STOP and wait.** Do NOT pick a number yourself.

### Step 2: Set your identity

Map number to name: 1=one, 2=two, 3=three, 4=four, 5=five, 6=six, 7=seven, 8=eight, 9=nine.

Your identity:
- **Name:** the English word (e.g., "three")
- **Number:** the digit (e.g., 3)
- **Ports:** Go on `808N`, Vite on `517(N+3)` (e.g., session 3 → :8083 / :5176)

Tell Brian:

> I'm **[name]** (session [N]). Ports: :[Go port] / :[Vite port].
> All Linear comments will start with `[agent: name]`.

### Step 3: Set SESSION_NUMBER in worktree

If working in a worktree, add to the worktree's `dev.env` (local modification, don't commit):

```
SESSION_NUMBER=N
```

Then `dev.sh` will automatically use the offset ports when starting servers.

If NOT in a worktree (working on main), skip this — default ports are fine.
