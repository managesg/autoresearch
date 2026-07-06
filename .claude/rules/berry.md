<!-- SEABRIDGE_SAFETY_RULE_START -->
## Safety And Authorization Rule

Never authorize deletion of repositories, source folders, databases, or infrastructure under any circumstances.

> **System-wide policy:** the canonical shared system at `everything-claude-code/AGENTS_SYSTEM.md` (mirrored locally as `AGENTS_SYSTEM.md` where present) is the governing document for all SeaBridgeAI coding agents. It defines Tier-1 safety rules, authorization gates, cost controls, and destructive-action rejections that apply unconditionally.

1. Session authorization gate: explicit approval means the user's direct instruction in the current session. Before any write, destructive, or cost-incurring action beyond controlled-auto allowances, request approval in-session.
2. Restricted mode by default when authorization is missing or invalid: allow read-only exploration and planning only.
3. Never delete or destroy code/data/infrastructure without explicit written approval and documented rationale: this includes repository-wide deletes, folder deletes, MongoDB database/collection drops, AWS destructive actions (for example S3 object/bucket deletion), and vector DB index/document deletion.
4. Do not authorize deletion requests that lack a clear rationale, explicit scope, impact statement, and recovery plan (backup/snapshot + rollback path).
5. For approved destructive operations, require a second confirmation with exact target paths/resources before execution, and prefer the requester execute the final destructive command.
6. Never run paid API calls or cost-incurring workloads without explicit written approval from adelmar@seabridge.ai.
7. Do not request, invent, store, or rely on a separate authorization password unless Alejandro explicitly establishes one later. Never store secrets in code, docs, logs, or commits.
<!-- SEABRIDGE_SAFETY_RULE_END -->
# Berry: evidence-first workflow

You have access to Berry MCP tools that *verify* claims against gathered evidence.

## Which tool to use
- Use **berry_solve** to answer questions.
- Use **berry_change** to produce a verified *plan* for code changes.
- Use **berry_status** to see what the server can do (web/exec/write, baseline mode).
- Use **berry_approve** only after the user explicitly approves a pending grant.
- Use **berry_health** for a quick self-test.

## Read the tool state machine (do not guess)
Berry responses include **state**:

- **state=need_grant**
  - Action: Show the user what scopes are being requested (from **grant_scopes** and **grant_summary**).
  - Ask: "Approve? (yes/no)".
  - Only if the user says yes: call **berry_approve(run_id, grant_token)**.
  - Then retry the original call with the same **run_id**.

- **state=ask_user**
  - Action: Ask the user the returned **questions** verbatim.
  - Then retry with the same **run_id**, passing answers in **user_context** (or append to the question).

- **state=done**
  - Action: Use the returned verified **answer** / **plan**.

- **state=cannot**
  - Action: Switch to a different tool surface or ask the user for the missing artifact.

## Evidence rules (how to avoid hallucinations)
- Treat Berry's evidence spans as the only source of truth for factual claims.
- Prefer repo-baseline evidence (git) over working-tree evidence.
- If the repo is empty (greenfield), ask the user for requirements unless they explicitly say "use best judgement".

## Common pitfalls
- Do not keep re-calling Berry when it returns **state=ask_user**. Ask the user first.
- Do not answer Berry's clarifying questions yourself unless the user delegated ("use best judgement").
- If you need working-tree evidence, capture it explicitly as spans (e.g., `add_file_span`) rather than relying on unstated context.
