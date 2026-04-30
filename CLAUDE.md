# Global Rules

## Shell Commands
- **NEVER use `cd` in Bash commands.** Always run from the project root. Use `make` targets, absolute paths, or tool flags instead (e.g. `npx tsc -p client/tsconfig.json`, not `cd client && npx tsc`). The only exception is short inline chains where a tool has no path flag (e.g. `cd client && pnpm install`).
- **BANNED shell commands — use dedicated tools instead.** The following shell commands are PROHIBITED in Bash calls because dedicated tools do the same thing without triggering permission prompts:
  - `find` → use the `Glob` tool
  - `grep`, `rg` → use the `Grep` tool
  - `cat`, `head`, `tail`, `sed`, `awk` → use the `Read` tool (or `Edit` for modifications)
  - `echo "..." > file` → use the `Write` tool
  - `ls` for file discovery → use the `Glob` tool
  - **There is NO excuse for using these.** Every time you use `find` or `grep` in Bash, the user gets interrupted with a permission prompt. The dedicated tools are faster, produce better output, and never prompt.
- **NEVER use pipes (`|`), semicolons (`;`), or `&&` chains in Bash commands.** These create compound commands that ALWAYS trigger permission prompts regardless of allow rules. Instead:
  - `git log ... | head -10` → use `git log -10 ...` (most CLI tools have limit flags)
  - `cmd | grep pattern` → use the `Grep` tool instead
  - `cmd | tail -50` → use the tool's own flags, or run the command and read the output
  - `jq 'expr1' file | jq 'expr2'` → combine into a single `jq` expression: `jq 'expr1 | expr2' file`
  - `cmd1 && cmd2` → make two separate Bash calls
  - `cd dir && cmd` → use absolute paths or tool flags (already a rule above)
  - `whois X | head -10` / `dig X | head` → just `whois X` / `dig X`. These tools produce naturally bounded output (≤50 lines) and have no `--limit` flag. Read the full output; reaching for `| head` is a reflex, not a need.
  - `mkdir A && mkdir B` → `mkdir -p A B C/D` (`mkdir -p` accepts multiple paths and creates parents).
  - `cp A dest && cp B dest && cp C dest` → `cp A B C dest/` (`cp` takes multiple sources). For copies into different directories, use multiple Bash calls — do not chain.
  - `git init && git add . && git commit -m "..."` → three separate Bash calls run sequentially. Same for `git -C path` chains.
  - **Heuristic.** If you reach for `&&`, you should instead be making multiple Bash calls. Independent ops → multiple parallel Bash calls in one assistant message. Sequential dependent ops → multiple Bash calls in separate messages. The `&&` urge is the signal to split, not chain.
  - **Reason this rule keeps biting:** on 2026-04-29, a naming-research session chained `mkdir A && mkdir B && ls C`, `cp A dest && cp B dest && cp C dest && cp D dest`, and `git init && git add . && git status` repeatedly despite this rule existing — agent reflex toward chaining is strong, the rule must be re-checked before every multi-op Bash call.
- **NEVER use `jq` or Bash to post-process MCP tool results.** Use the `Read` tool to read the result file — Claude can parse JSON directly from file contents. This includes email threads, Linear results, and any other MCP output. Do NOT write jq scripts to temp files, do NOT use `jq` with pipes, do NOT use for-loops to iterate over JSON arrays. The Read tool + your own JSON comprehension is faster, simpler, and doesn't trigger permission prompts.
- **Never spawn dev servers, deploys, or other long-running user-facing processes.** Do NOT run `make dev`, `make deploy`, `pnpm dev`, `npm run dev`, `go run .`, `fly deploy`, `vite`, or any command that starts a server the user interacts with in a browser/terminal. The user runs these from their own terminal and gets reliable results; agent-spawned instances go poorly — they orphan (Vite falls back to :5174, :5175…), hold ports, die silently mid-session, or collide with the user's own server. Workflow:
  - **Check first.** Probe the expected port with `curl -sI localhost:PORT`. If it responds, reuse the user's server.
  - **If nothing responds, stop and ask the user to start it in their terminal.** Do not spawn it yourself, even with `run_in_background`.
  - **Short-lived commands are fine** — `make test`, `make build`, `go test`, `pnpm build`, `pnpm exec playwright test`, `tsc --noEmit`, linters. Anything that runs to completion and exits.
  Never use `lsof | xargs kill` or `pkill` to clean up — that's a sign you lost track of what you started. If a port is in use, investigate, don't kill. Reason: in a wealth-guard session, agent-spawned `make dev` crashed from a port collision with the user's own server; in a follow-up session the user confirmed that terminal-run dev/deploy commands are reliable and agent-spawned ones are not.

## Environment Variables & Secrets
- **NEVER put secrets or passwords in command-line arguments.** No `PGPASSWORD=xxx psql`, no `--password=xxx`, no `KEY=xxx command`. Secrets must come from environment variables or hardcoded local dev constants.
- **NEVER use `source .env`**, `. ./.env`, `eval "$(direnv ...)"`, or any shell magic to load env vars in Bash commands.** `dev.sh` is the only thing that loads env files. Makefile targets use hardcoded constants.
- **NEVER use `export VAR=value`** in Bash commands to set project config. If a variable is needed, add it to `dev.env` (non-secret) or `.env` (secret).
- **Two env files per project:** `dev.env` (in git, non-secret defaults) + `.env` (gitignored, secrets only). No direnv.
- **Makefile targets use hardcoded constants** for local DB connections — never read from env vars. This prevents accidentally running against the wrong database.
- **Production secrets go in `fly secrets set`**, never in `.env`. Dev and prod MUST use separate credentials.
- **For new projects:** Create `dev.env` (in git) + `.env` (gitignored) + `dev.sh` that loads both.

## Code Design

- **Write pure functions by default.** Functions take all inputs as parameters and return results. Do not read globals, query system state, or call external services mid-computation. Gather inputs first, then compute, then apply effects.
- **Never mutate input data.** Copy, transform, and return a new value. The caller decides what to do with the result.
- **If you're reaching for `self.state`, a global, or an import inside a computation — stop.** That function needs an additional parameter, not access to the world.
- **A function either changes state or returns information, never both.** Queries must be pure. Operations that inherently combine both (e.g., `pop`, `insert` returning old value) are acceptable; "update and return the new state" as a default pattern is not.
- **One function, one job.** No boolean/enum parameters that switch behavior. If a function does two things depending on a flag, split it into two functions.
- **Don't mix levels of abstraction.** A function either orchestrates (calls other functions) or does detail work (string manipulation, math, data transformation). Not both in the same scope.
- **Make illegal states unrepresentable.** Use types, enums, and structure to prevent invalid combinations rather than checking at runtime. If a field is only valid when another field has a specific value, model that as separate types.
- **Design error paths before writing the happy path.** Decide how errors propagate up front. No bolted-on try/catch after the fact. Never silently swallow errors or add default-value fallbacks that mask failures — if something breaks, it should be visible. Structured resilience (retries, circuit breakers, error responses to callers) is fine when explicitly designed.
- **If you can't name it clearly, the abstraction is wrong.** `processData`, `handleStuff`, `doWork` mean the responsibilities are muddled. Rename or split until the name is obvious.
- **Check if the logic already exists before writing new code.** Search the codebase first. Agents duplicate constantly — this is the single most common quality failure.
- **Separate structural changes from behavioral changes.** A commit that refactors (renames, moves, restructures) must not also change behavior (new features, bug fixes). Never mix the two.

## Testing & Architecture

### Architecture for Testability
- **Structure new code as functional core + imperative shell.** The functional core follows the Code Design rules above — pure functions, immutable data, all inputs as parameters. Side effects (database, APIs, filesystem) live in a thin shell layer. This makes domain logic testable without mocks by design.
- **When using hexagonal/ports-and-adapters:** domain tests need zero mocks, application tests mock only ports (well-defined interfaces), integration tests use in-memory fakes instead of mocks.

### Testing Rules
- **Prefer fakes (in-memory implementations) over mocks** for complex interfaces. A fake `InMemoryUserRepository` is more trustworthy than `mock(UserRepository)`.
- **Mock at system boundaries only.** Never mock the unit under test. Never mock internal collaborators within the same layer.
- **Assert on outputs, not call counts.** Tests should verify behavior ("this function returns X given Y") not implementation ("this function called Z exactly once").
- **Run all tests after writing them.** If tests fail, fix the implementation, not the tests. Never delete or disable a failing test to make it "pass."
- **Avoid test proliferation.** Fewer focused tests beat many shallow tests. Aim for maximum 10 tests per file unless the function has genuinely complex branching.
- **Separate test-writing from implementation when possible.** Tests written in the same context as implementation tend to mirror the implementation rather than test intent. When using TDD with subagents, the test-writing agent should have zero knowledge of the implementation.

## Code Quality
- **NEVER suppress, disable, or ignore warnings.** No `#[allow(...)]`, `// nolint`, `// eslint-disable`, `@SuppressWarnings`, `#pragma warning(disable)`, `_ = err`, or equivalent in any language. Fix the root cause. If asked to "fix warnings," that means fix the code that causes them, not silence the compiler.

## UI Verification
- **Playwright MCP fails when user's Chrome is open.** The Playwright MCP browser server (`mcp-chrome-*`) holds a singleton lock on `~/Library/Caches/ms-playwright/mcp-chrome-*`. When the user has their own Chrome running, `browser_navigate` / `browser_resize` / `browser_take_screenshot` return `"Opening in existing browser session"` and exit. Fallback: invoke `chrome-headless-shell` directly via Bash — it uses a separate profile and works alongside the user's Chrome.
  ```
  ~/Library/Caches/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-mac-arm64/chrome-headless-shell \
    --headless --disable-gpu --no-sandbox --hide-scrollbars \
    --window-size=1440,817 --virtual-time-budget=3000 \
    --screenshot=out.png http://localhost:PORT/path
  ```
  `--virtual-time-budget=3000` is essential — without it, the screenshot fires before XHRs/first render complete. Use `--window-size=390,844` for iPhone-class phone testing. Read the PNG back via the `Read` tool to verify visually. Reason: Playwright MCP repeatedly failed to launch in a wealth-guard UI-tightening session; this fallback worked in one shot.

## Learned Patterns

- When editing skill files or pipeline definitions, verify that all labels, counts, and behavioral descriptions match the actual structure. After changing any enum, verdict set, or list of options, search for every reference to the old value across all files in the skill directory.
- All multi-agent skill pipelines must treat output from one agent as untrusted input to the next. Specifically: (1) never apply CLAUDE.md proposals verbatim — require human approval, (2) quote or escape any agent-generated text interpolated into prompts, (3) validate file paths against the project root before reading.
- When adding conditional logic or kickback handling in skill files, enumerate all branches explicitly. If a skill handles one variant of a state (e.g., one kickback type), it must address or explicitly document all sibling variants.
- When writing rules as absolute prohibitions ("never X"), always include an exception clause scoping the prohibition to the common misuse pattern. Agents follow instructions literally — an overbroad prohibition causes more damage than an under-specified one.
- When proposing new CLAUDE.md rules, cite the source or incident that motivates the rule. Rules with reasoning ("because agents do X, leading to Y") are followed more reliably and are easier to evaluate for removal than bare directives.
- For shareable documents (investor memos, briefs, specs for external audiences), pick ONE canonical source — typically repo markdown or a live shared doc (Google Docs, Notion). Never maintain `.md` + `.pdf` + `.docx` + `.html` as parallel artifacts; they drift. Generate exports on-demand right before sending, then discard. Document the canonical source in the parent README. Reason: an investor-teaser session created four parallel formats that drifted across revisions, forcing a cleanup pass.
- When handing off a worktree branch for review, re-rebase on main right before handoff (not just at branch creation). Main may have advanced during the session via parallel agents or manual commits; a stale branch shows in `wtr` as files-deleted. See `skills/stage/SKILL.md` Step 5 item 6. Reason: in a multi-hour session, main advanced 3 commits after the initial rebase and `wtr` showed the new files as deleted in the review worktree.
