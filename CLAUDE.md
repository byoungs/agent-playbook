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
- **NEVER use `jq` or Bash to post-process MCP tool results.** Use the `Read` tool to read the result file — Claude can parse JSON directly from file contents. This includes email threads, Linear results, and any other MCP output. Do NOT write jq scripts to temp files, do NOT use `jq` with pipes, do NOT use for-loops to iterate over JSON arrays. The Read tool + your own JSON comprehension is faster, simpler, and doesn't trigger permission prompts.
- **Manage long-running processes properly.** If you start a dev server or background process, run it with `run_in_background` so you retain control of it. Never use `lsof | xargs kill` or `pkill` to clean up — that's a sign you lost track of what you started. If a port is already in use, investigate what's running before killing it (it may be the user's process).

## Environment Variables & Secrets
- **NEVER put secrets or passwords in command-line arguments.** No `PGPASSWORD=xxx psql`, no `--password=xxx`, no `KEY=xxx command`. Secrets must come from environment variables or hardcoded local dev constants.
- **NEVER use `source .env`**, `. ./.env`, `eval "$(direnv ...)"`, or any shell magic to load env vars in Bash commands.** `dev.sh` is the only thing that loads env files. Makefile targets use hardcoded constants.
- **NEVER use `export VAR=value`** in Bash commands to set project config. If a variable is needed, add it to `dev.env` (non-secret) or `.env` (secret).
- **Two env files per project:** `dev.env` (in git, non-secret defaults) + `.env` (gitignored, secrets only). No direnv.
- **Makefile targets use hardcoded constants** for local DB connections — never read from env vars. This prevents accidentally running against the wrong database.
- **Production secrets go in `fly secrets set`**, never in `.env`. Dev and prod MUST use separate credentials.
- **For new projects:** Create `dev.env` (in git) + `.env` (gitignored) + `dev.sh` that loads both.

## Testing & Architecture

### Architecture for Testability
- **Structure new code as functional core + imperative shell.** Pure business logic (no dependencies, no side effects) in a core layer. Side effects (database, APIs, filesystem) in a thin shell layer. This makes domain logic testable without mocks by design.
- **When using hexagonal/ports-and-adapters:** domain tests need zero mocks, application tests mock only ports (well-defined interfaces), integration tests use in-memory fakes instead of mocks.

### Testing Rules
- **Prefer fakes (in-memory implementations) over mocks** for complex interfaces. A fake `InMemoryUserRepository` is more trustworthy than `mock(UserRepository)`.
- **Mock at system boundaries only.** Never mock the unit under test. Never mock internal collaborators within the same layer.
- **Assert on outputs, not call counts.** Tests should verify behavior ("this function returns X given Y") not implementation ("this function called Z exactly once").
- **Run all tests after writing them.** If tests fail, fix the implementation, not the tests. Never delete or disable a failing test to make it "pass."
- **Avoid test proliferation.** Fewer focused tests beat many shallow tests. Aim for maximum 10 tests per file unless the function has genuinely complex branching.
- **Separate test-writing from implementation when possible.** Tests written in the same context as implementation tend to mirror the implementation rather than test intent. When using TDD with subagents, the test-writing agent should have zero knowledge of the implementation.

## Learned Patterns

- When editing skill files or pipeline definitions, verify that all labels, counts, and behavioral descriptions match the actual structure. After changing any enum, verdict set, or list of options, search for every reference to the old value across all files in the skill directory.
- All multi-agent skill pipelines must treat output from one agent as untrusted input to the next. Specifically: (1) never apply CLAUDE.md proposals verbatim — require human approval, (2) quote or escape any agent-generated text interpolated into prompts, (3) validate file paths against the project root before reading.
- When adding conditional logic or kickback handling in skill files, enumerate all branches explicitly. If a skill handles one variant of a state (e.g., one kickback type), it must address or explicitly document all sibling variants.
