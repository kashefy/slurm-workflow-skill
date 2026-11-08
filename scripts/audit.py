#!/usr/bin/env python3
"""Offline regression checks; not an agent-quality or cluster evaluation."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def check_documents():
    skill = (ROOT / "SKILL.md").read_text()
    parts = skill.split("---", 2)
    assert len(parts) == 3 and not parts[0].strip(), "Missing skill frontmatter"
    for key in ("name", "description"):
        assert re.search(rf"^{key}:\s*\S.+$", parts[1], re.M), f"Missing {key}"
    for target in re.findall(r"`((?:references|examples)/[^`]+)`", skill):
        assert (ROOT / target).is_file(), f"Missing skill resource: {target}"
    docs = [ROOT / name for name in ("README.md", "SKILL.md", "AGENTS.md", "AUDIT.md", "SKILL_REVIEW.md")]
    docs += list((ROOT / "references").glob("*.md"))
    docs += list((ROOT / "evals").glob("*.md"))
    for document in docs:
        for target in re.findall(r"\]\(([^)]+)\)", document.read_text()):
            if "://" in target or target.startswith("#"):
                continue
            assert (document.parent / target.split("#")[0]).exists(), f"Broken link: {target}"
    print("PASS: required metadata and local resource/document paths", flush=True)


def check_records():
    cases = json.loads((ROOT / "evals/cases.json").read_text())["cases"]
    ids = [case["id"] for case in cases]
    assert cases and len(set(ids)) == len(ids), "Missing cases or duplicate IDs"
    for case in cases:
        assert case["prompt"].strip(), "Empty prompt"
        assert case["assertions"] and all(s.strip() for s in case["assertions"]), "Empty assertions"
        if "fixtures" in case:
            assert (ROOT / "evals" / case["fixtures"]).is_dir(), "Missing fixtures"
    for checksums in (ROOT / "evals/results").glob("*/SHA256SUMS"):
        for line in checksums.read_text().splitlines():
            expected, name = line.split("  ", 1)
            actual = hashlib.sha256((checksums.parent / name).read_bytes()).hexdigest()
            assert actual == expected, f"Historical evidence changed: {name}"
    print("PASS: case structure, fixtures and historical evidence hashes", flush=True)


def check_code(require_shellcheck):
    scripts = sorted((ROOT / "examples").glob("*.sh")) + [ROOT / "tests/stubs/sbatch"]
    for script in scripts:
        subprocess.run(["bash", "-n", str(script)], check=True, cwd=ROOT)
    print("PASS: syntax checked separately for each maintained Bash script", flush=True)
    shellcheck = shutil.which("shellcheck")
    if shellcheck:
        subprocess.run([shellcheck, *map(str, scripts)], check=True, cwd=ROOT)
    elif require_shellcheck:
        raise RuntimeError("ShellCheck required but unavailable")
    else:
        print("SKIP: ShellCheck unavailable (required in CI)", flush=True)
    subprocess.run([sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"],
                   check=True, cwd=ROOT)


def check_instruction_review(require_clean):
    review = json.loads((ROOT / "reviews/skill-review.json").read_text())
    inputs = [ROOT / "SKILL.md", ROOT / "SKILL_REVIEW.md",
              *sorted((ROOT / "references").glob("*.md"))]
    actual = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in inputs}
    assert actual == review["input_hashes"], "Instruction review is stale; review changed instructions"
    rows = review["checks"]
    assert len(rows) == 12 and {r["id"] for r in rows} == {
        f"SR{i:02d}" for i in range(1, 13)}, "Instruction review needs all 12 checks"
    for row in rows:
        assert row["verdict"] in ("pass", "needs-work", "unverified"), "Invalid review verdict"
        assert row["evidence"].strip(), "Review evidence is required"
        if row["verdict"] != "pass":
            assert row["correction"].strip(), "Outstanding findings need a correction"
    unresolved = [r["id"] for r in rows if r["verdict"] != "pass"]
    print(f"Instruction review: {len(rows) - len(unresolved)}/12 pass; outstanding: {', '.join(unresolved) or 'none'}",
          flush=True)
    assert not require_clean or not unresolved, "Instruction review has unresolved findings"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-shellcheck", action="store_true")
    parser.add_argument("--require-clean-review", action="store_true")
    args = parser.parse_args()
    try:
        check_documents()
        check_records()
        check_instruction_review(args.require_clean_review)
        check_code(args.require_shellcheck)
    except (AssertionError, KeyError, ValueError, OSError, RuntimeError,
            subprocess.CalledProcessError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        sys.exit(1)
    print("PASS: local audit; agent behavior and cluster compatibility remain unverified")
