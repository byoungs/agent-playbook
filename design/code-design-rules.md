# Code Design Rules

> Created 2026-03-30. Origin: race condition in amux where a `relayout` function queried mutable state mid-computation instead of computing from a snapshot.

## Why These Rules Exist

AI coding agents default to the simplest implementation that satisfies the immediate request. Without explicit constraints, they produce code that:

- Queries mutable state mid-computation (causing race conditions)
- Mutates shared data structures (causing spooky action at a distance)
- Mixes orchestration with detail work (causing functions that can't be understood in isolation)
- Adds silent fallbacks that mask bugs (causing failures to go undetected)
- Duplicates existing logic instead of reusing it (causing divergent implementations)

These aren't hypothetical. The amux `relayout` bug was a direct example: the agent wrote a layout function that called back into amux to query state during execution, creating a race condition. A pure function taking a layout snapshot as input would have been correct by construction.

## Why Rules, Not Principles

Principles ("prefer purity") require judgment about when to apply them. Agents apply judgment inconsistently. Rules ("functions take all inputs as parameters and return results") are concrete and verifiable — a code reviewer (human or agent) can point to a specific violation.

When multiple code reviewers suggest deviating from a rule, that's a signal to evaluate whether the rule needs updating. The rule stands until deliberately changed.

## The Core Stance: Pure Functions and Immutable Data

Pure functions and immutable data eliminate entire categories of bugs by construction:

| Bug category | How purity prevents it |
|---|---|
| Race conditions | No shared mutable state to race on |
| Action at a distance | No mutations visible outside the function |
| Order-dependent bugs | No hidden dependency on execution sequence |
| Debugging difficulty | Output depends only on input — fully reproducible |
| Testing complexity | `assert f(input) == expected` — no setup, no teardown, no mocks |

Beyond bug prevention, purity makes the agent's own job easier at every subsequent step:

- **Reasoning transparency** — a pure function can be understood by reading it alone. An impure function requires reading everything it touches. This directly maps to context window constraints: a function the agent can see in one read is one it can reason about correctly.
- **Composability** — pure functions compose freely. Impure ones require careful orchestration. Agents are good at composition but bad at orchestration.
- **Refactorability** — pure functions can be moved, split, or inlined without fear.
- **Self-review** — an agent can verify its own pure function by checking input→output. It cannot easily verify that side effects happened correctly.

### Research Support

No major practitioner voice explicitly prescribes pure functions for agents yet, but the research supports it from multiple angles:

- **Kent Beck** explicitly instructs agents to "prefer functional programming over imperative style" in his augmented coding workflow. He notes that getting agents to care about simplicity is "the hardest problem." ([Augmented Coding: Beyond the Vibes](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes))

- **Steve Yegge** found that "AI cognition takes a hit every time it crosses a boundary in the code — every RPC, IPC, FFI call, database call." Pure functions have zero boundary crossings; they're the maximum-cognition form factor. ([Six New Tips](https://steve-yegge.medium.com/six-new-tips-for-better-coding-with-agents-d4e9c86e42a9))

- **CodeScene/Adam Tornhill** showed a non-linear relationship between code health and AI performance. Below a threshold (~9.5/10), agents spiral. "AI operates in a self-harm mode, often writing code it cannot reliably maintain later." Pure functions are the healthiest unit of code. ([Best Practice Patterns](https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality))

- **Kief Morris (martinfowler.com)** found that "a cleanly-designed, well-structured codebase... agents work faster and spiral less." ([Humans and Agents](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html))

- **Community CLAUDE.md files** widely ship rules like "pure functions only modify return values" and "ALWAYS create new objects, NEVER mutate existing ones." ([Sources: agentic-coding.github.io, cursor.com/blog/agent-best-practices, various GitHub repos](https://agentic-coding.github.io/))

## Rule-by-Rule Reasoning

### 1. Write pure functions by default

**Rule:** Functions take all inputs as parameters and return results. Do not read globals, query system state, or call external services mid-computation. Gather inputs first, then compute, then apply effects.

**Why:** This is the rule the amux bug violated. The `relayout` function queried live state during computation instead of taking a snapshot. The three-phase pattern (gather → compute → apply) prevents this entire class of bug. Including "gather inputs first" in the rule gives the agent a concrete pattern to follow, not just a constraint to satisfy.

### 2. Never mutate input data

**Rule:** Copy, transform, and return a new value. The caller decides what to do with the result.

**Why:** Mutation of inputs is the most common source of "spooky action at a distance." When function A mutates a data structure that function B also holds a reference to, the bug is in neither function — it's in the invisible coupling between them. Agents don't track reference sharing across functions.

### 3. Stop when reaching for state

**Rule:** If you're reaching for `self.state`, a global, or an import inside a computation — stop. That function needs an additional parameter, not access to the world.

**Why:** This is the "smell test" version of rule 1. Agents won't always recognize that they're violating purity in the abstract, but they can recognize the concrete action of reaching for `self.state` mid-function. Framing it as "stop and add a parameter" gives them the fix, not just the diagnosis.

### 4. Command-query separation

**Rule:** A function either changes state or returns information, never both. Queries must be pure. Operations that inherently combine both (e.g., `pop`, `insert` returning old value) are acceptable; "update and return the new state" as a default pattern is not.

**Why:** Bertrand Meyer's CQS principle. When a function both mutates and returns, callers can't tell whether they're reading or writing. Agents frequently produce functions that "update and return the new value" — creating hidden state changes in what looks like a read operation. This is especially dangerous in concurrent code (like amux). The exception for inherent combined operations (like `pop`) prevents the rule from prohibiting idiomatic patterns in every language — the target is the *default habit* of combining mutation with return values, not the occasional justified case.

### 5. One function, one job

**Rule:** No boolean/enum parameters that switch behavior. If a function does two things depending on a flag, split it into two functions.

**Why:** Flag parameters are a code smell in any context, but agents produce them constantly because they're the path of least resistance when adding a new mode to existing logic. Two separate functions are easier to name, test, and reason about than one function with branching behavior. Community CLAUDE.md files cite this as one of the most effective rules for agent-generated code.

### 6. Don't mix levels of abstraction

**Rule:** A function either orchestrates (calls other functions) or does detail work (string manipulation, math, data transformation). Not both in the same scope.

**Why:** Agents produce "god functions" that handle HTTP parsing, business logic, and database writes in the same scope. These are hard to test, hard to reuse, and hard for the agent itself to modify later. Enforcing abstraction levels produces naturally small, focused functions.

### 7. Make illegal states unrepresentable

**Rule:** Use types, enums, and structure to prevent invalid combinations rather than checking at runtime. If a field is only valid when another field has a specific value, model that as separate types.

**Why:** Agents default to stringly-typed, loosely validated data (e.g., `status: string` instead of `status: "active" | "inactive"`). Runtime validation is a safety net for external input; type structure is how you prevent internal bugs. When the type system makes invalid states impossible, neither the agent nor the human needs to think about them.

### 8. Design error paths first

**Rule:** Decide how errors propagate before writing the happy path. No bolted-on try/catch after the fact. Never silently swallow errors or add default-value fallbacks that mask failures — if something breaks, it should be visible. Structured resilience (retries, circuit breakers, error responses to callers) is fine when explicitly designed.

**Why:** Agents have a strong tendency to add "helpful" error handling — try/catch blocks that log and continue, default values that mask missing data, graceful degradation that hides broken features. Multiple community CLAUDE.md files include "no fallbacks unless I explicitly ask" because this is one of the most common agent failure modes. The rule to design error paths *first* forces intentional error handling rather than defensive afterthoughts. The explicit carve-out for structured resilience prevents agents from avoiding legitimate patterns like retries and circuit breakers at system boundaries.

### 9. Names reveal intent

**Rule:** If you can't name it clearly, the abstraction is wrong. `processData`, `handleStuff`, `doWork` mean the responsibilities are muddled. Rename or split until the name is obvious.

**Why:** Naming is a design activity, not a labeling activity. A function that can't be named clearly has unclear responsibilities. Agents will name things `processData` and move on without recognizing this as a design problem. The rule reframes naming as a signal that triggers restructuring.

### 10. Search before writing

**Rule:** Check if the logic already exists before writing new code. Search the codebase first.

**Why:** Code duplication is the single most common quality failure in agent-generated code (cited across community sources, CodeScene, and Willison). Agents generate fresh implementations rather than discovering and reusing existing ones. This rule is only effective if the agent actually searches — including the "why" in CLAUDE.md ("agents duplicate constantly") demonstrably changes agent behavior.

### 11. Separate structural from behavioral changes

**Rule:** A commit that refactors (renames, moves, restructures) must not also change behavior (new features, bug fixes). Never mix the two.

**Why:** Kent Beck's core practice, and one he explicitly encodes in agent instructions. Mixed commits are hard to review (which changes are safe refactoring vs. which change behavior?) and hard to revert (can't undo the feature without undoing the refactoring). Agents love to "clean up" code while implementing features — this rule prevents that.

## Evolution

These rules should evolve. When code reviewers consistently recommend deviating from a rule, that's a signal to reconsider it. Update the rule here with reasoning, then propagate to CLAUDE.md.

Rules added from session research (2026-03-30):
- Rules 1-3: from decades of functional programming practice, triggered by amux race condition bug
- Rule 4: Bertrand Meyer's CQS, reinforced by community CLAUDE.md patterns
- Rules 5-6: community CLAUDE.md patterns + Tweag handbook
- Rule 7: type-driven design, common in Rust/Haskell/TypeScript communities
- Rule 8: community CLAUDE.md pattern ("no unsolicited fallbacks")
- Rule 9: clean code canon, reframed as agent-specific design signal
- Rule 10: most-cited agent failure mode across all sources
- Rule 11: Kent Beck, explicitly encoded in his agent instructions
