# ClawMux Deep Analysis

> Researched 2026-03-27 from [github.com/avirtuos/clawmux](https://github.com/avirtuos/clawmux)

## What It Is

A GenAI coding assistant multiplexer and task orchestrator written in Rust. Turns a single AI coding agent into a disciplined software development team by imposing a scrum-style workflow on top of LLM-powered coding tools.

**Core insight:** A single agent doing design, implementation, and review in one shot produces lower-quality output than multiple specialized agents working sequentially, each with a focused mandate, constrained tool access, and the ability to reject earlier work.

## The 7-Agent Pipeline

1. **Intake Agent** (read-only) — Reviews task, verifies completeness, asks clarifying questions
2. **Design Agent** (read-only) — Proposes architectural design and trade-offs
3. **Planning Agent** (read+execute) — Concrete step-by-step implementation plan
4. **Implementation Agent** (full access) — Writes the actual code
5. **Code Quality Agent** (read+execute) — Style, correctness, test coverage, coding standards
6. **Security Review Agent** (read-only) — Vulnerabilities, credential exposure, insecure defaults
7. **Code Review Agent** (read+git) — Final holistic review, prepares commit message

## The Kickback Mechanism

Review agents can reject work and send it backward:
- Code Quality → kicks back to Implementation
- Security Review → kicks back to Implementation OR Design
- Code Review → kicks back to Implementation, Design, OR Planning

Invalid kickbacks are rejected (Code Quality can't kick back to Design — not its domain).

Each kickback includes a structured reason injected into the target stage's context.

## Progressive Tool Scoping

Each agent only has tools appropriate for their role:
- **Read-only**: Intake, Design, Security Review
- **Read + execute**: Planning, Code Quality, Code Review
- **Full access**: Implementation only

## Communication Protocol

Agents respond with structured JSON: `complete` (advance), `kickback` (send backward), or `question` (ask the human). Deterministic state machine transitions.

## Architecture

- Single Rust binary with async subsystems communicating via `mpsc` channels
- TUI layer (ratatui), Workflow Engine (pure state machine), AgentBackend trait
- Backend-agnostic: supports OpenCode (HTTP/SSE) or kiro-cli (JSON-RPC over stdin/stdout)
- Kiro: fresh process per stage to avoid context compaction across pipeline stages
- 206+ tests, including 62+ for the workflow state machine

## What We Borrowed

- **Kickback mechanism** (adapted): reviewers can route work backward, but through a synthesis critiquer rather than individual reviewers
- **Security review as dedicated stage**: separate read-only security audit
- **Progressive tool scoping concept**: prompt-based "you are read-only" (not mechanically enforced)

## What We Didn't Borrow

- External Rust orchestrator (we use prompt-based skills instead)
- Task-as-markdown-file pattern (we use superpowers plan files)
- Mechanical JSON communication protocol (we use natural language)
- Individual reviewer kickback authority (we route through synthesis critiquer)
- TUI/terminal interface
