"""
Skill Optimizer — autoresearch module.

Applies the Executor → Analyst → Mutator loop from Karpathy's autoresearch
methodology to SKILL.md prompt files instead of model weights.

Based on: https://github.com/Shubhamsaboo/awesome-llm-apps/tree/main/
          awesome_agent_skills/self-improving-agent-skills

Usage:
    python skill_optimizer.py --skill path/to/SKILL.md --max-rounds 10
    python skill_optimizer.py --skill path/to/SKILL.md --target-pass-rate 0.85
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Optional

from dotenv import load_dotenv

load_dotenv(override=True)
logger = logging.getLogger(__name__)

# ── Constants ─────────────────────────────────────────────────────────────────

MUTATION_STRATEGIES = ("add_example", "add_constraint", "restructure", "add_edge_case")
DEFAULT_MAX_ROUNDS = 20
DEFAULT_TARGET_PASS_RATE = 0.80
DEFAULT_PLATEAU_PATIENCE = 3


# ── Data classes ──────────────────────────────────────────────────────────────

@dataclass
class TestScenario:
    label: str
    input_prompt: str
    expected_behavior: str


@dataclass
class EvalCriterion:
    text: str  # "Does the output X?" — answerable yes/no


@dataclass
class ScenarioScore:
    scenario: TestScenario
    criteria_results: list[bool]

    @property
    def score(self) -> float:
        if not self.criteria_results:
            return 0.0
        return sum(self.criteria_results) / len(self.criteria_results)


@dataclass
class RoundResult:
    round_num: int
    strategy: str
    change_description: str
    before_text: str
    after_text: str
    candidate_pass_rate: float
    previous_pass_rate: float
    kept: bool


@dataclass
class OptimizationResult:
    skill_name: str
    baseline_pass_rate: float
    final_pass_rate: float
    rounds_run: int
    changes_applied: list[RoundResult] = field(default_factory=list)
    final_skill_body: str = ""
    plateau_reached: bool = False


# ── Prompts ───────────────────────────────────────────────────────────────────

_SCENARIO_GEN_SYSTEM = """You are an expert skill tester. Given a skill's name and description, generate diverse test scenarios and evaluation criteria.

Respond in this exact JSON format:
{
  "scenarios": [
    {
      "label": "happy path",
      "input_prompt": "...",
      "expected_behavior": "..."
    }
  ],
  "criteria": [
    "Does the output explicitly state the next action to take?",
    "Does the output avoid generic advice not tied to the specific request?"
  ]
}

Generate 4 scenarios (happy path, edge case, stress case, failure case) and 5 binary yes/no criteria."""


_EXECUTOR_SYSTEM = """You are an expert skill executor. You will be given a skill's instruction body as your operating instructions, then a user prompt.

Follow the skill instructions exactly and produce the output the skill would produce.
Be faithful to the skill's intent — do not add features the skill doesn't describe."""


_SCORER_SYSTEM = """You are a strict evaluator. Given a skill's output and a list of yes/no evaluation criteria, score each criterion.

Respond in this exact JSON format:
{
  "results": [true, false, true, true, false],
  "reasoning": "Criterion 1: YES because... Criterion 2: NO because..."
}

Each boolean corresponds to the criterion at the same index. Be strict — partial fulfillment is NO."""


_ANALYST_SYSTEM = """You are an expert prompt engineer diagnosing why a skill's instructions produce failing outputs.

Given: the skill body, failing criteria, and example outputs, identify the root cause and recommend ONE mutation.

Respond in this exact JSON format:
{
  "failing_criteria": ["Does the output X?", "Does the output Y?"],
  "root_cause": "The skill lacks explicit instructions for X because...",
  "strategy": "add_constraint",
  "rationale": "Adding a DO NOT constraint will prevent the model from...",
  "change_location_quote": "exact substring from the skill body near where the change should go"
}

strategy must be one of: add_example, add_constraint, restructure, add_edge_case"""


_MUTATOR_SYSTEM = """You are a precise prompt editor. Apply exactly ONE targeted change to a skill's instruction body.

Rules:
- Make ONLY the change the Analyst prescribed
- Do not restructure unrelated sections
- add_example: insert a concrete before/after example near the relevant section
- add_constraint: add an explicit "DO NOT" or "ALWAYS" rule
- restructure: reorder or rename one section only
- add_edge_case: add a note handling a specific edge case

Respond in this exact JSON format:
{
  "change_description": "Added explicit constraint against generic advice",
  "before_text": "exact text being replaced (must match the skill body exactly)",
  "after_text": "replacement text"
}

The before_text must be an exact substring of the skill body provided."""


# ── Helpers ───────────────────────────────────────────────────────────────────

def _get_client():
    """Return an Anthropic client."""
    try:
        import anthropic
        return anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    except ImportError as exc:
        raise RuntimeError("anthropic package required: pip install anthropic") from exc


def _call_claude(
    client: Any,
    system: str,
    user: str,
    model: str = "claude-sonnet-4-6",
    max_tokens: int = 4096,
    retries: int = 3,
) -> str:
    """Call Claude and return the text response."""
    for attempt in range(retries):
        try:
            resp = client.messages.create(
                model=model,
                max_tokens=max_tokens,
                system=system,
                messages=[{"role": "user", "content": user}],
            )
            return resp.content[0].text
        except Exception as exc:
            is_overload = "529" in str(exc) or "overloaded" in str(exc).lower()
            if is_overload and attempt < retries - 1:
                wait = 2 ** attempt
                logger.warning("Anthropic overload (attempt %d), retrying in %ds", attempt + 1, wait)
                time.sleep(wait)
                continue
            raise
    raise RuntimeError("Claude call failed after retries")


def _parse_json(text: str) -> dict:
    """Extract and parse the first JSON object from text."""
    start = text.find("{")
    end = text.rfind("}") + 1
    if start < 0 or end <= start:
        raise ValueError(f"No JSON found in response: {text[:300]}")
    return json.loads(text[start:end])


def _parse_skill_md(path: Path) -> tuple[str, str]:
    """Return (frontmatter_block, instruction_body) from a SKILL.md file."""
    content = path.read_text(encoding="utf-8")
    if not content.startswith("---"):
        return ("", content)
    end_fm = content.find("\n---", 3)
    if end_fm < 0:
        return ("", content)
    frontmatter = content[: end_fm + 4]
    body = content[end_fm + 4:].lstrip("\n")
    return frontmatter, body


# ── Core loop ─────────────────────────────────────────────────────────────────

def _generate_config(
    client: Any,
    skill_name: str,
    skill_description: str,
    model: str,
) -> tuple[list[TestScenario], list[EvalCriterion]]:
    """Step 1: Generate test scenarios and evaluation criteria."""
    user_prompt = f"Skill name: {skill_name}\nDescription: {skill_description}"
    raw = _call_claude(client, _SCENARIO_GEN_SYSTEM, user_prompt, model=model)
    data = _parse_json(raw)

    scenarios = [
        TestScenario(
            label=s["label"],
            input_prompt=s["input_prompt"],
            expected_behavior=s["expected_behavior"],
        )
        for s in data.get("scenarios", [])
    ]
    criteria = [EvalCriterion(text=c) for c in data.get("criteria", [])]
    return scenarios, criteria


def _run_executor(
    client: Any,
    skill_body: str,
    scenario: TestScenario,
    criteria: list[EvalCriterion],
    model: str,
) -> ScenarioScore:
    """Execute the skill against one scenario and score it."""
    # Execute
    output = _call_claude(
        client,
        system=f"You are operating under these instructions:\n\n{skill_body}",
        user=scenario.input_prompt,
        model=model,
        max_tokens=2048,
    )

    # Score
    criteria_list = "\n".join(f"{i+1}. {c.text}" for i, c in enumerate(criteria))
    scorer_user = (
        f"## Skill Output\n{output}\n\n"
        f"## Evaluation Criteria\n{criteria_list}"
    )
    score_raw = _call_claude(client, _SCORER_SYSTEM, scorer_user, model=model, max_tokens=1024)
    score_data = _parse_json(score_raw)

    results: list[bool] = [bool(r) for r in score_data.get("results", [])]
    # Pad/truncate to match criteria count
    while len(results) < len(criteria):
        results.append(False)
    results = results[: len(criteria)]

    return ScenarioScore(scenario=scenario, criteria_results=results)


def _compute_pass_rate(scores: list[ScenarioScore]) -> float:
    if not scores:
        return 0.0
    return sum(s.score for s in scores) / len(scores)


def _run_analyst(
    client: Any,
    skill_body: str,
    scores: list[ScenarioScore],
    criteria: list[EvalCriterion],
    model: str,
) -> dict:
    """Diagnose failures and recommend a mutation strategy."""
    failing = []
    for s in scores:
        for i, passed in enumerate(s.criteria_results):
            if not passed and i < len(criteria):
                failing.append(criteria[i].text)

    user_prompt = (
        f"## Skill Body\n{skill_body[:8000]}\n\n"
        f"## Failing Criteria\n" + "\n".join(f"- {c}" for c in set(failing))
    )
    raw = _call_claude(client, _ANALYST_SYSTEM, user_prompt, model=model, max_tokens=2048)
    return _parse_json(raw)


def _run_mutator(
    client: Any,
    skill_body: str,
    analyst_result: dict,
    model: str,
) -> Optional[dict]:
    """Apply ONE surgical change to the skill body."""
    user_prompt = (
        f"## Analyst Diagnosis\n{json.dumps(analyst_result, indent=2)}\n\n"
        f"## Current Skill Body\n{skill_body[:8000]}"
    )
    raw = _call_claude(client, _MUTATOR_SYSTEM, user_prompt, model=model, max_tokens=2048)
    try:
        return _parse_json(raw)
    except ValueError:
        logger.warning("Mutator response was not valid JSON")
        return None


def _apply_mutation(skill_body: str, mutation: dict) -> Optional[str]:
    """Apply the mutation's before→after text replacement."""
    before = mutation.get("before_text", "")
    after = mutation.get("after_text", "")
    if not before or before not in skill_body:
        logger.warning("Mutation before_text not found in skill body — skipping")
        return None
    return skill_body.replace(before, after, 1)


def optimize_skill(
    skill_path: str | Path,
    max_rounds: int = DEFAULT_MAX_ROUNDS,
    target_pass_rate: float = DEFAULT_TARGET_PASS_RATE,
    plateau_patience: int = DEFAULT_PLATEAU_PATIENCE,
    model: str = "claude-sonnet-4-6",
    verbose: bool = True,
) -> OptimizationResult:
    """
    Run the Executor→Analyst→Mutator optimization loop on a SKILL.md file.

    Args:
        skill_path: Path to the SKILL.md file.
        max_rounds: Maximum number of optimization rounds.
        target_pass_rate: Stop when this pass rate (0–1) is reached.
        plateau_patience: Stop after this many consecutive reverts.
        model: Claude model to use for all agents.
        verbose: Print progress to stdout.

    Returns:
        OptimizationResult with the improved skill body and changelog.
    """
    path = Path(skill_path)
    if not path.exists():
        raise FileNotFoundError(f"SKILL.md not found: {path}")

    frontmatter, skill_body = _parse_skill_md(path)
    skill_name = path.parent.name

    # Extract description from frontmatter
    skill_description = ""
    for line in frontmatter.splitlines():
        if line.startswith("description:"):
            skill_description = line[len("description:"):].strip()
            break

    client = _get_client()

    def _log(msg: str) -> None:
        if verbose:
            print(msg)
        logger.info(msg)

    _log(f"\n{'='*60}")
    _log(f"SKILL OPTIMIZER — {skill_name}")
    _log(f"{'='*60}")

    # Step 1: Generate config
    _log("\n[Step 1] Generating test scenarios and evaluation criteria...")
    scenarios, criteria = _generate_config(client, skill_name, skill_description, model)
    _log(f"  {len(scenarios)} scenarios, {len(criteria)} criteria generated")

    # Step 2: Baseline
    _log("\n[Step 2] Running baseline evaluation...")
    baseline_scores = [_run_executor(client, skill_body, s, criteria, model) for s in scenarios]
    baseline_pass_rate = _compute_pass_rate(baseline_scores)
    pass_rate = baseline_pass_rate

    _log(f"\nBASELINE RESULTS")
    _log(f"{'='*40}")
    for sc in baseline_scores:
        passed = sum(sc.criteria_results)
        total = len(sc.criteria_results)
        _log(f"  {sc.scenario.label}: {passed}/{total} criteria passed ({sc.score:.0%})")
    _log(f"  Overall pass rate: {pass_rate:.1%} (target: {target_pass_rate:.0%})")

    result = OptimizationResult(
        skill_name=skill_name,
        baseline_pass_rate=baseline_pass_rate,
        final_pass_rate=pass_rate,
        rounds_run=0,
        final_skill_body=skill_body,
    )

    if pass_rate >= target_pass_rate:
        _log(f"\nSkill already meets target ({pass_rate:.1%} >= {target_pass_rate:.0%}). No optimization needed.")
        return result

    # Step 3: Optimization loop
    current_scores = baseline_scores
    consecutive_reverts = 0

    for round_num in range(1, max_rounds + 1):
        _log(f"\n{'─'*40}")
        _log(f"ROUND {round_num}")
        _log(f"{'─'*40}")

        # Analyst
        analyst_result = _run_analyst(client, skill_body, current_scores, criteria, model)
        strategy = analyst_result.get("strategy", "add_constraint")
        _log(f"  Analyst: {strategy} — {analyst_result.get('root_cause', '')[:120]}")

        # Mutator
        mutation = _run_mutator(client, skill_body, analyst_result, model)
        if mutation is None:
            _log("  Mutator: failed to produce valid change — skipping round")
            consecutive_reverts += 1
            if consecutive_reverts >= plateau_patience:
                result.plateau_reached = True
                break
            continue

        candidate_body = _apply_mutation(skill_body, mutation)
        if candidate_body is None:
            _log("  Mutator: change location not found in skill — skipping round")
            consecutive_reverts += 1
            if consecutive_reverts >= plateau_patience:
                result.plateau_reached = True
                break
            continue

        change_desc = mutation.get("change_description", strategy)
        _log(f"  Mutator: {change_desc}")

        # Re-score
        candidate_scores = [_run_executor(client, candidate_body, s, criteria, model) for s in scenarios]
        candidate_pass_rate = _compute_pass_rate(candidate_scores)

        kept = candidate_pass_rate > pass_rate
        _log(f"  Score: {pass_rate:.1%} → {candidate_pass_rate:.1%} — {'KEEP' if kept else 'REVERT'}")

        round_result = RoundResult(
            round_num=round_num,
            strategy=strategy,
            change_description=change_desc,
            before_text=mutation.get("before_text", ""),
            after_text=mutation.get("after_text", ""),
            candidate_pass_rate=candidate_pass_rate,
            previous_pass_rate=pass_rate,
            kept=kept,
        )

        if kept:
            skill_body = candidate_body
            pass_rate = candidate_pass_rate
            current_scores = candidate_scores
            result.changes_applied.append(round_result)
            consecutive_reverts = 0
        else:
            consecutive_reverts += 1

        result.rounds_run = round_num

        if pass_rate >= target_pass_rate:
            _log(f"\nTarget pass rate reached ({pass_rate:.1%}). Stopping.")
            break

        if consecutive_reverts >= plateau_patience:
            _log(f"\nOptimization plateaued ({consecutive_reverts} consecutive reverts). Stopping.")
            result.plateau_reached = True
            break

    result.final_pass_rate = pass_rate
    result.final_skill_body = skill_body

    # Step 4: Output
    _log(f"\n{'='*60}")
    _log("OPTIMIZATION COMPLETE")
    _log(f"{'='*60}")
    _log(f"  Rounds run:        {result.rounds_run}")
    _log(f"  Baseline:          {result.baseline_pass_rate:.1%}")
    _log(f"  Final:             {result.final_pass_rate:.1%}")
    _log(f"  Improvement:       +{result.final_pass_rate - result.baseline_pass_rate:.1%}")
    _log(f"  Changes applied:   {len(result.changes_applied)}")

    # Write improved skill
    if result.changes_applied:
        improved_content = frontmatter + "\n" + skill_body
        path.write_text(improved_content, encoding="utf-8")
        _log(f"\nImproved skill written to: {path}")

        # Write changelog
        changelog_path = path.parent / "CHANGELOG.md"
        lines = [f"# {skill_name} Optimization Changelog\n\n"]
        lines.append(
            f"Baseline: {result.baseline_pass_rate:.1%} → Final: {result.final_pass_rate:.1%} "
            f"({result.rounds_run} rounds)\n\n"
        )
        for r in result.changes_applied:
            lines.append(f"## Round {r.round_num} — {r.strategy}\n")
            lines.append(f"{r.change_description}\n\n")
            lines.append(f"Score: {r.previous_pass_rate:.1%} → {r.candidate_pass_rate:.1%}\n\n")
        changelog_path.write_text("".join(lines), encoding="utf-8")
        _log(f"Changelog written to: {changelog_path}")

    return result


# ── CLI ────────────────────────────────────────────────────────────────────────

def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)-7s | %(message)s",
    )

    parser = argparse.ArgumentParser(description="Self-Improving Skill Optimizer")
    parser.add_argument("--skill", required=True, help="Path to SKILL.md file")
    parser.add_argument("--max-rounds", type=int, default=DEFAULT_MAX_ROUNDS)
    parser.add_argument("--target-pass-rate", type=float, default=DEFAULT_TARGET_PASS_RATE)
    parser.add_argument("--plateau-patience", type=int, default=DEFAULT_PLATEAU_PATIENCE)
    parser.add_argument("--model", default="claude-sonnet-4-6")
    args = parser.parse_args()

    optimize_skill(
        skill_path=args.skill,
        max_rounds=args.max_rounds,
        target_pass_rate=args.target_pass_rate,
        plateau_patience=args.plateau_patience,
        model=args.model,
    )


if __name__ == "__main__":
    main()
