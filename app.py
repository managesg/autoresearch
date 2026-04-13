"""
SeaBridgeAI Research Orchestrator — Streamlit UI

Local-only tool for running sustainability research scenarios
(A/B/C) without the terminal. Calls sustainability_research.ps1
and streams output line by line.

Launch:
    streamlit run app.py
    # or:
    .\\run_ui.ps1
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import streamlit as st

SCRIPT_DIR = Path(__file__).parent
PS1_SCRIPT = SCRIPT_DIR / "sustainability_research.ps1"
PAPER2AGENT_SCRIPT = SCRIPT_DIR / "paper2agent.ps1"

# ── Cost warnings ─────────────────────────────────────────────────────────────

COST_INFO = {
    "A": "**Feynman** ~$0.05–0.50 · **Paper2Agent** ~$2–10, 30 min – 3 hrs",
    "B": "**Feynman** ~$0.05–0.50 · **Graphify** local only (no API cost)",
    "C": "**Feynman** ~$0.05–0.50",
}
DEEP_RESEARCH_COST = " · **Deep Research** ~$1–5, ~20 min"

SCENARIO_LABELS = {
    "A": "A — New ESG Research Question (Feynman → Paper2Agent)",
    "B": "B — Improve a Backend Agent (Feynman → Graphify → autoresearch loop)",
    "C": "C — Quick ESG Data Intelligence Question (Feynman rapid mode)",
}

SCENARIO_DESCRIPTIONS = {
    "A": (
        "Use when you have a new ESG/sustainability research question. "
        "Feynman produces a cited literature brief; Paper2Agent then converts "
        "a key methodology repo into an interactive MCP-backed agent."
    ),
    "B": (
        "Use when you want to improve an existing backend agent "
        "(e.g. nature_agent, climate_agent, regulation_monitoring) "
        "using research findings or ML experiments."
    ),
    "C": (
        "Use when you need a rapid cited answer to an ESG data question "
        "without running a full experiment. Outputs in ~2–5 minutes."
    ),
}

# ── Subprocess helpers ─────────────────────────────────────────────────────────


def _powershell_cmd(
    scenario: str,
    task: str,
    deep_research: bool,
    dry_run: bool,
) -> list[str]:
    """Build the powershell command list for sustainability_research.ps1."""
    cmd = [
        "powershell",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        str(PS1_SCRIPT),
        "-Scenario",
        scenario,
    ]
    if task.strip():
        cmd += ["-Task", task.strip()]
    if deep_research and scenario in ("A", "B"):
        cmd.append("-DeepResearch")
    if dry_run:
        cmd.append("-DryRun")
    return cmd


def _paper2agent_cmd(github_url: str, project_dir: str, dry_run: bool) -> list[str]:
    """Build the powershell command list for paper2agent.ps1."""
    cmd = [
        "powershell",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        str(PAPER2AGENT_SCRIPT),
        "-GithubUrl",
        github_url.strip(),
        "-ProjectDir",
        project_dir.strip(),
    ]
    if dry_run:
        cmd.append("-DryRun")
    return cmd


def stream_subprocess(cmd: list[str], output_placeholder) -> int:
    """Run cmd, stream stdout+stderr line-by-line into output_placeholder. Returns exit code."""
    lines: list[str] = []
    try:
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            encoding="utf-8",
            errors="replace",
        )
        for line in proc.stdout:  # type: ignore[union-attr]
            lines.append(line.rstrip())
            output_placeholder.code("\n".join(lines), language="")
        proc.wait()
        return proc.returncode
    except FileNotFoundError:
        output_placeholder.error(
            "powershell.exe not found. This tool requires Windows + PowerShell."
        )
        return 1
    except Exception as exc:
        output_placeholder.error(f"Subprocess error: {exc}")
        return 1


# ── Page config ───────────────────────────────────────────────────────────────

st.set_page_config(
    page_title="SeaBridgeAI Research Orchestrator",
    page_icon="🌿",
    layout="wide",
)

# ── Sidebar ───────────────────────────────────────────────────────────────────

with st.sidebar:
    st.title("Research Orchestrator")
    st.caption("SeaBridgeAI Co-Scientist Stack")
    st.divider()

    scenario = st.radio(
        "Scenario",
        options=list(SCENARIO_LABELS.keys()),
        format_func=lambda k: SCENARIO_LABELS[k],
        index=0,
    )

    st.divider()

    deep_research = st.checkbox(
        "Deep Research mode",
        value=False,
        disabled=(scenario == "C"),
        help="Spawns parallel sub-agents (~20 min, higher cost). Disabled for Scenario C.",
    )

    dry_run = st.checkbox(
        "Dry Run",
        value=False,
        help="Preview all steps without making API calls or running cost-incurring commands.",
    )

    st.divider()
    st.markdown("**Links**")
    st.markdown("- [Stack docs](AI_COSCIENTIST_STACK.md)")
    st.markdown("- [Workflow runbook](SUSTAINABILITY_WORKFLOW.md)")

# ── Main area ─────────────────────────────────────────────────────────────────

st.header("SeaBridgeAI Research Orchestrator")
st.markdown(f"**Scenario {scenario}** — {SCENARIO_DESCRIPTIONS[scenario]}")

# Cost warning
cost_str = COST_INFO[scenario]
if deep_research and scenario in ("A", "B"):
    cost_str += DEEP_RESEARCH_COST
if dry_run:
    st.info("Dry Run enabled — no API calls or cost-incurring steps will execute.")
else:
    st.warning(f"Estimated cost: {cost_str}")

st.divider()

# Task input
task = st.text_area(
    "Research task / question",
    placeholder="e.g. What biodiversity metrics best predict physical risk for real estate?",
    height=100,
)

# Scenario A: Paper2Agent fields (shown upfront, used after Feynman phase)
github_url = ""
project_dir = ""
if scenario == "A":
    st.markdown("#### Paper2Agent Handoff _(Scenario A — Phase 2)_")
    st.caption(
        "After reviewing the Feynman output, enter the GitHub URL of the key methodology "
        "repo and a project directory name. Leave blank to skip Paper2Agent."
    )
    col1, col2 = st.columns(2)
    with col1:
        github_url = st.text_input(
            "GitHub URL",
            placeholder="https://github.com/example/methodology-repo",
        )
    with col2:
        project_dir = st.text_input(
            "Project directory name",
            placeholder="TNFD_Risk_Agent",
        )

st.divider()

run_btn = st.button("Run", type="primary", use_container_width=True)

# ── Execution ─────────────────────────────────────────────────────────────────

if run_btn:
    if not task.strip() and not dry_run:
        st.error("Please enter a research task before running.")
        st.stop()

    # Phase 1: sustainability_research.ps1
    st.subheader("Output")
    feynman_placeholder = st.empty()

    cmd = _powershell_cmd(scenario, task, deep_research, dry_run)
    with st.spinner("Running…"):
        rc = stream_subprocess(cmd, feynman_placeholder)

    if rc == 0:
        st.success("Phase 1 complete.")
    else:
        st.error(f"Phase 1 exited with code {rc}. Check output above.")

    # Phase 2 (Scenario A only): Paper2Agent
    if scenario == "A" and github_url.strip() and project_dir.strip():
        st.subheader("Paper2Agent — Phase 2")
        if not dry_run:
            st.warning(
                "Paper2Agent costs ~$2–10 and can take 30 min – 3 hrs. "
                "Approval required from adelmar@seabridge.ai before proceeding."
            )
            approved = st.checkbox("I have written approval from adelmar@seabridge.ai")
        else:
            approved = True  # dry run always proceeds

        if approved:
            p2a_placeholder = st.empty()
            p2a_cmd = _paper2agent_cmd(github_url, project_dir, dry_run)
            with st.spinner("Running Paper2Agent…"):
                p2a_rc = stream_subprocess(p2a_cmd, p2a_placeholder)

            if p2a_rc == 0:
                st.success(
                    f"Paper2Agent complete. "
                    f"Output: `autoresearch/{project_dir}/src/` · "
                    f"Report: `autoresearch/{project_dir}/reports/coverage_and_quality_report.md`"
                )
            else:
                st.error(f"Paper2Agent exited with code {p2a_rc}.")
    elif scenario == "A" and not dry_run and (github_url or project_dir):
        st.info(
            "Fill in both GitHub URL and Project Directory to run Paper2Agent, "
            "or leave both blank to skip."
        )
