# Retry & Loop Limits: Expert Consensus

> Researched 2026-03-27.

## The Magic Number: 3

The consensus across all credible sources is **3 retries** for fix/review cycles before changing strategy.

| Context | Limit | Source |
|---------|-------|--------|
| Bug fix attempts before questioning architecture | **3** | superpowers systematic-debugging |
| Code review fix cycles | **3** | CodeRabbit |
| API transient error retries | **3-4** | Google Vertex AI SDK |
| Max retries per task (general) | **3** | Practitioner consensus |
| Max actions per well-scoped session | **50** | Circuit breaker patterns |
| Max LLM calls per task | **10** | Token budget practices |
| Ralph loop max iterations (completion check) | **20** | Anthropic plugin default |

## Why 3?

If three different attempted fixes all fail, the problem is almost certainly not what you think it is. You are either misdiagnosing the root cause or fighting an architectural mismatch. Continuing yields diminishing returns and increasing risk.

## Our Pipeline Limits

| Situation | Limit | Then What |
|---|---|---|
| LOCAL_FIX cycles per task | **3** | Auto-escalate to KICKBACK → PLANNING |
| KICKBACK to PLANNING per session | **2** | Pause pipeline, surface to human |
| KICKBACK to DESIGN per session | **1** | Full stop. Design re-evaluation. |

## Key Sources

- [superpowers systematic-debugging](https://github.com/obra/superpowers): "If >= 3 fixes failed, STOP and question the architecture"
- [CodeRabbit cursor integration](https://docs.coderabbit.ai/cli/cursor-integration): Hard limit of 3 review-fix iterations
- [Anthropic: Effective harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents): Ralph loop uses max 20 iterations for completion checks
