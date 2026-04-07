---
name: berry-plan-verification
description: |
  Integrates Berry hallucination detection into /plan mode.
  Before finalizing any plan, verify each reasoning step with audit_trace_budget
  and each factual claim with detect_hallucination. Use this skill whenever
  creating implementation plans, architecture designs, or multi-step proposals.
origin: ECC
version: 1.0.0
---

# Berry Plan Verification

Evidence-backed planning: verify claims before committing to a plan, eliminating hallucinated facts, unsupported assumptions, and speculative API behavior.

## When to Activate

- During `/plan` mode before finalizing any plan
- When generating implementation proposals with technical claims
- When the plan references external APIs, framework behavior, or version-specific features
- Before writing code that implements a plan with uncertain assumptions
- When evaluating architecture decisions with factual dependencies

## The Verification-First Planning Loop

### Step 1: Start a Berry run

```
Call: start_run
  problem: "<the planning task description>"
```

Note the `run_id` — use it for all subsequent calls.

### Step 2: Gather evidence before writing the plan

Before drafting plan steps, collect evidence for the key claims you will make:

```
Call: add_span (for each piece of evidence)
  run_id: <run_id>
  text: "<relevant code snippet, doc excerpt, or API behavior>"
  label: "<what this evidence supports>"
```

For file-based evidence (reading existing code):
```
Call: add_file_span
  run_id: <run_id>
  path: "<relative file path>"
  label: "<what this file shows>"
```

### Step 3: Draft the plan as structured steps

Each step must be a claim that can be verified:

```python
steps = [
    {"idx": 0, "claim": "The existing auth middleware is at app/core/security.py and uses JWT via python-jose"},
    {"idx": 1, "claim": "FastAPI's Depends() system allows injecting the verified user into any endpoint"},
    {"idx": 2, "claim": "We can add rate limiting via slowapi without changing existing endpoint signatures"},
]
```

### Step 4: Verify the plan with audit_trace_budget

```
Call: audit_trace_budget
  run_id: <run_id>
  steps: <the steps array above>
  citations: <map of step idx to evidence span IDs that support it>
```

**If flagged=true**: A step lacks evidence. Either:
- Gather more evidence (add more spans) and re-verify
- Revise the claim to remove the unsupported assertion
- Mark the step as an assumption and note it explicitly

### Step 5: Verify narrative claims with detect_hallucination

For any prose summary or factual claim in the plan:

```
Call: detect_hallucination
  run_id: <run_id>
  answer: "<the factual claim or summary sentence>"
  citations: <list of span IDs that support this claim>
```

### Step 6: Present the verified plan

Only present the plan after:
- `audit_trace_budget` returns `flagged=false` for all steps
- Any flagged steps have been revised or explicitly marked as assumptions
- `detect_hallucination` returns `flagged=false` for all factual claims

## Integration with /plan Mode

When in `/plan` mode (Plan Mode activated via Shift+Tab or `/plan`):

1. **Before entering plan mode**: Call `start_run` with the task description.
2. **During exploration**: Use `add_file_span` and `add_span` to capture evidence.
3. **Before proposing steps**: Call `audit_trace_budget` on your draft steps.
4. **Before each factual claim**: Call `detect_hallucination`.
5. **Flag assumptions explicitly**: Steps that cannot be verified become explicitly labelled assumptions.

## Handling Berry States

Berry tool responses include a `state` field:

| State | Action |
|-------|--------|
| `done` | Use the returned answer/plan |
| `ask_user` | Ask the user the returned questions verbatim; do not answer yourself |
| `need_grant` | Show the user what scopes are requested; only call `berry_approve` after explicit user confirmation |
| `cannot` | Note the limitation; proceed with explicit assumption labeling |

## Example: Plan with Verification

**Task**: "Add a nature risk score cache to the AI Manager"

```
1. start_run("Add nature risk score caching to AI Manager")
   → run_id: "run_abc123"

2. add_file_span(run_id="run_abc123", path="gresb_agent/src/sustainability_agents/seabridge_ai_manager/improved_ai_manager.py", label="current AI Manager structure")

3. add_span(run_id="run_abc123", text="Redis is configured at REDIS_URL in .env.example with TTL support", label="caching infrastructure available")

4. audit_trace_budget(
     run_id="run_abc123",
     steps=[
       {"idx":0, "claim":"AI Manager routes nature_risk queries via get_risk_by_asset in optimized_natural_language_to_mql.py"},
       {"idx":1, "claim":"Redis client is available via app.core.database; TTL can be set per key"},
       {"idx":2, "claim":"Cache key should be sha256(company_id + period + query_hash) to prevent collisions"},
     ],
     citations={"0": ["span_1"], "1": ["span_2"], "2": []}
   )
   → {"flagged": true, "flagged_steps": [2]}  ← step 2 has no evidence

5. Revise step 2 → mark as "ASSUMPTION: cache key format TBD — verify with team"

6. Re-verify → {"flagged": false}  ← plan is clean
```

## Use in AI Manager and AI Agents

For future integration in ManagESG's AI Manager and Agents:

- **Before returning agent responses**: Call `detect_hallucination` on any factual claim (ESG data, regulatory citations, benchmark values)
- **Before executing multi-step agent plans**: Call `audit_trace_budget` on the agent's reasoning trace
- **Evidence sources**: Agent tool results (MongoDB queries, document retrieval) become spans
- **Flagged responses**: Trigger evidence-gathering loop before finalizing output

The Berry MCP server is available to the AI Manager at runtime since it's registered as an MCP server in `.mcp.json`. The AI Manager can call `detect_hallucination` as a post-processing step on agent outputs.
