#!/usr/bin/env python3
"""Example Python workload; replace processing and validation for your project."""

import json
import os
import sys
from pathlib import Path

from manifest import read_manifest


def main(args):
    stage = args[0]
    if stage == "single" and len(args) == 1:
        print("Hello from a Python batch job")
        return
    manifest, digest, output = args[1:4]
    lines = read_manifest(manifest, digest)
    output = Path(output)
    if stage == "prepare" and len(args) == 4:
        output.mkdir(parents=True, exist_ok=True)
    elif stage == "task" and len(args) == 6:
        task_id = int(args[4])
        if task_id < 0 or task_id >= len(lines) or lines[task_id] != args[5]:
            raise ValueError("task input does not match manifest")
        result = {"task_id": task_id, "manifest_sha256": digest, "input": args[5], "result": args[5].upper()}
        temporary = output / f".task-{task_id}.{os.getpid()}.tmp"
        temporary.write_text(json.dumps(result) + "\n", encoding="utf-8")
        os.replace(temporary, output / f"task-{task_id}.json")
    elif stage == "aggregate" and len(args) == 4:
        results = []
        for task_id, value in enumerate(lines):
            result = json.loads((output / f"task-{task_id}.json").read_text(encoding="utf-8"))
            expected = {"task_id": task_id, "manifest_sha256": digest, "input": value, "result": value.upper()}
            if result != expected:
                raise ValueError(f"invalid output for task {task_id}")
            results.append(result)
        (output / "summary.json").write_text(json.dumps(results) + "\n", encoding="utf-8")
    else:
        raise ValueError("invalid workflow stage")


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except (ValueError, OSError, IndexError) as error:
        print(f"workflow: {error}", file=sys.stderr)
        sys.exit(1)
