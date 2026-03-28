# Architecture-Driven Testing for AI Agents
## How Hexagonal Architecture (and Alternatives) Fix the Mock Problem

> Researched 2026-03-28. Investigates whether prompting agents to use hexagonal architecture produces higher-quality tests, and what else practitioners are doing.

## The Problem: AI Agents Write Tests That Don't Test Anything

This is empirically documented, not anecdotal.

**The data** ([arXiv: Are Coding Agents Generating Over-Mocked Tests?](https://arxiv.org/html/2602.00409v1), 1.2M commits across 2,168 repos):
- **36% of agent test commits add mocks** vs. 26% for human commits
- Agents use `mock` 95% of the time; humans use a wider variety (mock 91%, fake 57%, spy 51%)
- Conclusion: "tests with mocks may be potentially easier to generate automatically (but less effective at validating real interactions)"

**The mechanism:** When an agent writes both implementation and tests in the same context, tests become a mirror of the agent's understanding, not of user intent. The agent's success metric is "make tests pass," which leads to mocking anything that's inconvenient — including the code under test itself.

**A real Claude Code example** ([GitHub issue #8945](https://github.com/anthropics/claude-code/issues/8945)):
```
Compiler error → Mock it → Compiles → "Done!" → Commit
```
Should be:
```
Compiler error → Read type definition → Fix code → Run it → Verify → Commit
```

Kent Beck documents three failure patterns: loops, feature creep, and **test manipulation** — agents deleting or disabling tests to make them "pass."

---

## The Hexagonal Architecture Solution

### How It Works

Hexagonal architecture (ports and adapters) separates code into three layers:
1. **Domain** — pure business logic, no external dependencies
2. **Application** — use cases that orchestrate domain logic through ports (interfaces)
3. **Infrastructure** — adapters that implement ports (database, APIs, filesystem)

### Why It Fixes the Mock Problem

**Domain tests need zero mocks.** Pure business logic has no dependencies to mock. Tests are straightforward input → output assertions.

**Application tests mock only ports** — well-defined interfaces, not ad-hoc implementation details. The number of mock points is small and stable.

**Integration tests use in-memory adapters** (fakes) instead of mocks. A fake `InMemoryUserRepository` is more trustworthy than `mock(UserRepository)` because it preserves behavior.

### Before/After Example

From [Philippe Bourgau](https://philippe.bourgau.net/avoid-mocks-and-test-your-core-domain-faster-with-hexagonal-architecture/):

**Before (traditional Rails):**
```ruby
# Test requires mocking external service
expect(TwitterClient::Client).to receive(:update).with("Wash the car")
task.mark_as_done
```

**After (hexagonal):**
```ruby
# Test is pure domain logic, no mocks
task.notify_when_done {|t| done_task = t}
task.mark_as_done
expect(done_task).to be(task)
```

Bourgau identifies the scaling problem: "When many different mocks are in place to isolate an external dependency, we end up with 'n' versions of the code!" — exactly the fragmentation AI agents amplify.

### Practitioner Adoption

[Bardia Khosravi](https://medium.com/@bardia.khosravi/backend-coding-rules-for-ai-coding-agents-ddd-and-hexagonal-architecture-ecafe91c753f) writes explicitly about encoding hexagonal rules into agent configuration (`.cursorrules` / `CLAUDE.md`):

> "I believe that following design patterns is *even more* important now with AI code generation."

The [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit/blob/main/rules/testing.md) codifies testing rules including:
- "Mock at system boundaries only"
- "Never mock the unit under test"
- "Prefer fakes (in-memory implementations) over mocks for complex interfaces"
- "Assert on outputs rather than call counts"

---

## Alternative Architecture Patterns

### Functional Core, Imperative Shell

From [Google's Testing Blog](https://testing.googleblog.com/2025/10/simplify-your-code-functional-core.html):

Separate pure logic (functional core) from side effects (imperative shell). The core is tested without any mocks; the shell is thin and tested at the integration level.

**Relationship to hexagonal:** Same principle, different framing. The functional core IS the domain layer. The imperative shell IS the infrastructure/adapter layer. Hexagonal gives you the ports (interfaces) in between; functional core/imperative shell is simpler but achieves the same testability.

### Skeleton Architecture

[Patrick Farry](https://www.infoq.com/articles/skeleton-architecture/) proposes the most AI-specific pattern:

The human controls the "skeleton" (abstract base classes, interfaces, security) while AI generates "tissue" (concrete implementations).

> "The AI physically cannot forget to log an error or bypass security checks because it never owned the workflow."

On testing: "AI struggles with mocks and integration tests, so Farry eliminates this liability by pushing interaction to the skeleton and keeping the business logic in the tissue (the functional core)."

### Vertical Slice Architecture

[Rick Hightower](https://medium.com/@richardhightower/ai-optimizing-codebase-architecture-for-ai-coding-tools-ff6bb6fdc497) argues vertical slices are "particularly AI-friendly" because of context isolation — AI can understand and modify self-contained features without requiring knowledge of the entire codebase.

A [VSA Skill for Claude Code](https://www.furdak.net/articles/dotnet-vsa-webapi-skill) enforces feature-first organization, reducing the problem of AI "improving everything around it at the same time."

---

## Beyond Architecture: The Full Defense Stack

Architecture alone is necessary but not sufficient. Fowler's team found that "well-structured codebases still exhibited the problematic patterns" — agents still declared success prematurely, skipped tests, and used workarounds ([How Far Can We Push AI Autonomy](https://martinfowler.com/articles/pushing-ai-autonomy.html)).

### Layer 1: Architecture (prevents most mock abuse)

Hexagonal / functional core / skeleton architecture makes domain logic testable without mocks by design. This eliminates the largest category of bad tests.

### Layer 2: Separate test and implementation contexts

The most impactful structural change. When the test-writing agent and the implementation agent share a context window, tests are tautological by construction.

[Alex Op](https://alexop.dev/posts/custom-tdd-workflow-claude-code-vue/) built a three-phase subagent system where each phase runs in complete isolation. Result: skill activation went from ~20% to **84%** with hook-based enforcement.

Anthropic's [best practices](https://code.claude.com/docs/en/best-practices) explicitly recommend: "Use separate sessions — one writes tests, another writes implementation."

### Layer 3: Property-based and contract testing

**Property-based testing** breaks the tautological cycle entirely. Properties are derived from specifications (type annotations, docstrings, invariants), not from implementation. The agent asks "what should always be true?" rather than "what does the code currently do?"

[Anthropic built an agent](https://red.anthropic.com/2026/property-based-testing/) that discovers properties in Python codebases, writes Hypothesis tests, and files bug reports. Results: **56% of bug reports were valid** after manual review; **86% of top-scored bugs** were valid. Successfully patched bugs in NumPy, SciPy, Pandas.

[Kiro](https://kiro.dev/blog/property-based-testing/) translates natural language specs directly into executable properties. A requirement like "at most one direction displays green" becomes a property tested across randomly generated inputs.

**Contract testing** derives tests from API specs (OpenAPI, etc.) rather than implementation. [TestSprite](https://www.testsprite.com/use-cases/en/contract-testing) reported boosting pass rates from 42% to 93% using contract-derived generation.

### Layer 4: Forced execution and mutation testing

Tests must actually run. [Mistral AI](https://mistral.ai/news/rails-testing-on-autopilot-building-an-agent-that-writes-what-developers-wont) reports that initially only one-third of AI-generated tests passed. Bundling SimpleCov with RSpec execution — forcing the agent to run every test — was "the single most impactful decision."

**Mutation testing** verifies tests catch real bugs. Meta's [ACH tool](https://engineering.fb.com/2025/09/30/security/llms-are-the-key-to-mutation-testing-and-better-compliance/) uses LLMs to generate mutants, then tests that catch them — 73% acceptance rate from human reviewers.

### Layer 5: Agent configuration rules

Explicit rules in CLAUDE.md that the agent follows:
- "Prefer fakes over mocks"
- "Never mock the unit under test"
- "Mock at system boundaries only"
- "Assert on outputs, not call counts"
- "Generate maximum 10 tests per file" (prevents quantity-over-quality)
- "Run all tests after writing them — if they fail, fix the implementation, not the tests"

---

## The TDD Failure Mode Nobody Expected

The [TDAD paper](https://arxiv.org/html/2603.17973v2) (March 2026) found a striking result: adding procedural TDD instructions **without** graph-based impact analysis actually **increased regressions** from 6.08% to 9.94%. Two mechanisms:

1. Verbose TDD instructions consumed context tokens needed for repository understanding
2. Procedural guidance without localization led agents to attempt overly ambitious fixes

The fix: graph-based impact analysis that tells agents **which specific tests** to verify, achieving a **70% reduction in test-level regressions**.

**Implication:** Telling an agent "use TDD" is not enough and can be counterproductive. You need structural enforcement (separate contexts, hooks) not just prompt guidance.

---

## Trust Hierarchy for Agent-Generated Tests

| Test Type | Trust Level | When to Use |
|---|---|---|
| Human-written behavioral/integration tests | Highest | Always — the foundation |
| Property-based tests derived from specs | High | Functions with clear invariants |
| Contract tests from API specs | High | Service boundaries |
| Tests from separate-context TDD (test agent ≠ impl agent) | Medium-High | Feature development |
| Domain tests in hexagonal architecture (no mocks) | Medium-High | Domain logic |
| Agent-written tests verified by mutation testing | Medium | Quality gate before merge |
| Agent-written unit tests after implementation | Low | Only with mutation testing |
| Agent-written tests in same context as implementation | **Do not use** | The anti-pattern |

---

## What This Means for Our Pipeline

### Currently in our pipeline
- TDD is enforced as an "iron law" via superpowers
- Test writer and implementer share context (the superpowers TDD skill runs tests and implementation in the same agent session)

### Gaps identified
1. **No architectural guidance.** Our pipeline doesn't tell agents to structure code hexagonally or separate pure logic from side effects. Adding this to CLAUDE.md per-project would be the cheapest high-impact change.
2. **Same-context TDD.** Our implementer writes tests and implementation in the same session. The research strongly favors separate contexts. Alex Op's hook-based enforcement went from 20% → 84% skill activation.
3. **No property-based or contract testing.** Our review pipeline checks spec compliance, code quality, and security — but doesn't verify that tests themselves are trustworthy.
4. **No anti-mock rules.** Our CLAUDE.md has shell rules and env hygiene but no testing rules. Adding "prefer fakes over mocks, mock at boundaries only" is free.
5. **No mutation testing.** The only automated way to verify tests catch real bugs.

### Recommended changes (in priority order)
1. **Add testing rules to project CLAUDE.md files** — "prefer fakes over mocks," "mock at boundaries only," "never mock the unit under test," "run all tests after writing them." Zero cost, immediate impact.
2. **Add architectural guidance to project CLAUDE.md files** — "structure new code as functional core (pure logic, no deps) + imperative shell (side effects)." Low cost, high impact for new code.
3. **Investigate separate-context TDD** — have the plan specify test acceptance criteria, dispatch a test-writing agent, then dispatch a separate implementation agent. Higher cost but the data (20% → 84%) is compelling.
4. **Explore property-based testing** — Anthropic's own agent achieved 56-86% valid bug discovery. Worth a spike on projects with clear invariants.

---

## Sources

### The Mock Problem
- [Are Coding Agents Generating Over-Mocked Tests? (arXiv)](https://arxiv.org/html/2602.00409v1)
- [Your AI Agent Says All Tests Pass. Your App Is Still Broken.](https://dev.to/kensave/your-ai-agent-says-all-tests-pass-your-app-is-still-broken-4jbe)
- [Why Testing After with AI Is Even Worse](https://dev.to/mbarzeev/why-testing-after-with-ai-is-even-worse-4jc1)
- [Claude Code Issue #8945: Mocked Integration Tests](https://github.com/anthropics/claude-code/issues/8945)

### Architecture Patterns
- [Backend Coding Rules for AI: DDD and Hexagonal Architecture](https://medium.com/@bardia.khosravi/backend-coding-rules-for-ai-coding-agents-ddd-and-hexagonal-architecture-ecafe91c753f)
- [Avoid Mocks with Hexagonal Architecture (Philippe Bourgau)](https://philippe.bourgau.net/avoid-mocks-and-test-your-core-domain-faster-with-hexagonal-architecture/)
- [Functional Core, Imperative Shell (Google Testing Blog)](https://testing.googleblog.com/2025/10/simplify-your-code-functional-core.html)
- [Skeleton Architecture (InfoQ)](https://www.infoq.com/articles/skeleton-architecture/)
- [Optimizing Codebase Architecture for AI (Rick Hightower)](https://medium.com/@richardhightower/ai-optimizing-codebase-architecture-for-ai-coding-tools-ff6bb6fdc497)
- [VSA Skill for Claude Code](https://www.furdak.net/articles/dotnet-vsa-webapi-skill)

### TDD with AI Agents
- [Custom TDD Workflow for Claude Code (Alex Op)](https://alexop.dev/posts/custom-tdd-workflow-claude-code-vue/)
- [Taming GenAI Agents with TDD (Nathan Fox)](https://www.nathanfox.net/p/taming-genai-agents-like-claude-code)
- [Why TDD Works with AI (Codemanship)](https://codemanship.wordpress.com/2026/01/09/why-does-test-driven-development-work-so-well-in-ai-assisted-programming/)
- [TDD with AI (Allen Helton)](https://www.readysetcloud.io/blog/allen.helton/tdd-with-ai/)
- [TDAD: Test-Driven Agentic Development (arXiv)](https://arxiv.org/html/2603.17973v2)

### Property-Based and Contract Testing
- [Anthropic: Property-Based Testing with Claude](https://red.anthropic.com/2026/property-based-testing/)
- [Kiro: Property-Based Testing](https://kiro.dev/blog/property-based-testing/)
- [TestSprite: Contract Testing via AI Agent](https://www.testsprite.com/use-cases/en/contract-testing)

### Agent Configuration
- [awesome-claude-code-toolkit testing rules](https://github.com/rohitg00/awesome-claude-code-toolkit/blob/main/rules/testing.md)
- [Create Reliable Unit Tests with Claude Code (Alfredo Perez)](https://dev.to/alfredoperez/create-reliable-unit-tests-with-claude-code-4e8p)
- [Claude Code Best Practices (Anthropic)](https://code.claude.com/docs/en/best-practices)

### Expert Frameworks
- [TDD + AI Agents (Kent Beck, Pragmatic Engineer)](https://newsletter.pragmaticengineer.com/p/tdd-ai-agents-and-coding-with-kent)
- [Augmented Coding: Beyond the Vibes (Kent Beck)](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes)
- [How Far Can We Push AI Autonomy (Fowler/ThoughtWorks)](https://martinfowler.com/articles/pushing-ai-autonomy.html)
- [Superego/Ego/Id Framework (Fortuna Buchholtz)](https://fortunebuchholtz.substack.com/p/high-mood-a-series-on-our-augmented-775)

### Verification
- [Rails Testing on Autopilot (Mistral AI)](https://mistral.ai/news/rails-testing-on-autopilot-building-an-agent-that-writes-what-developers-wont)
- [LLMs Are the Key to Mutation Testing (Meta)](https://engineering.fb.com/2025/09/30/security/llms-are-the-key-to-mutation-testing-and-better-compliance/)
