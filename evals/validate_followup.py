"""Collect local observations for preserved follow-up outputs; never use real Slurm."""

import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
ARTIFACTS = ROOT / "evals/results/followup"
CONTRACT = '''import sys
from pathlib import Path
args = dict(arg.split("=", 1) for arg in sys.argv[1:])
stage = Path(sys.argv[0]).stem
if stage == "prepare":
    assert Path(args["source_root"]).is_dir()
    for fold in ("fold-00", "fold-01", "fold-02"):
        dest = Path(args["output_dir"]) / fold
        dest.mkdir(parents=True, exist_ok=True)
        for name in ("train_ids.txt", "validation_ids.txt"):
            (dest / name).write_text("1\\n")
elif stage == "train":
    if "train_file" in args:
        assert Path(args["train_file"]).is_file()
        assert Path(args["validation_file"]).is_file()
        assert args["train_seed"] == "17"
    dest = Path(args["output_dir"])
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "best.ckpt").write_text("contract stub")
elif stage == "evaluate":
    assert args["checkpoint"] == "best"
    assert (Path(args["run_dir"]) / "best.ckpt").is_file()
    dest = Path(args["output_dir"])
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "evaluated.txt").write_text("contract stub")
'''


def collect(case, condition):
    with tempfile.TemporaryDirectory(prefix="slurm-followup-") as temp:
        root = Path(temp)
        project = root / "project with spaces"
        shutil.copytree(ARTIFACTS / case / condition, project)
        for name in ("prepare", "train", "evaluate"):
            (project / f"{name}.py").write_text(CONTRACT)
        source = root / "staged data"
        source.mkdir()
        private = root / "private settings"
        private.mkdir()
        setup = private / "environment.sh"
        setup.write_text(":\n")
        output = root / "output paths"
        calls = root / "calls"
        calls.mkdir()
        bindir = root / "bin"
        bindir.mkdir()
        shutil.copy(ROOT / "tests/stubs/sbatch", bindir / "sbatch")
        (bindir / "sbatch").chmod(0o700)
        env = {**os.environ, "PATH": str(bindir) + os.pathsep + os.environ["PATH"],
               "FAKE_SBATCH_DIR": str(calls), "PYTHONDONTWRITEBYTECODE": "1"}
        assert shutil.which("sbatch", path=env["PATH"]) == str(bindir / "sbatch")

        def run(args, extra=None):
            return subprocess.run(args, cwd=project, env={**env, **(extra or {})},
                                  text=True, capture_output=True)

        def arguments():
            return [p.read_bytes().decode().rstrip("\0").split("\0")
                    for p in sorted(calls.glob("*.args"), key=lambda p: int(p.stem))]

        def stage_args(args):
            index = next(i for i, arg in enumerate(args)
                         if arg.endswith(".sbatch") or arg.endswith("/stage.sh"))
            return args[index:]

        def execute(args, task=None, spool=False):
            script, *rest = stage_args(args)
            if spool:
                dest = root / "spooled batch.sh"
                dest.unlink(missing_ok=True)
                shutil.copy(script, dest)
                script = str(dest)
            result = run(["bash", script, *rest],
                         {} if task is None else {"SLURM_ARRAY_TASK_ID": str(task)})
            return {"exit": result.returncode, "stderr": result.stderr}

        profile = private / "profile.sh"
        settings = {"PROJECT_DIR": project, "PROJECT": project, "SOURCE_ROOT": source,
                    "ENV_SETUP": setup, "RUN_ROOT": output, "RUN_PARENT": output,
                    "RECEIPT_PARENT": private / "receipts", "PYTHON": shutil.which("python3")}
        config = "".join(f"{name}={shlex.quote(str(value))}\n" for name, value in settings.items())
        config += "PARTITION=invented_partition\nACCOUNT=invented_account\nSBATCH_OPTIONS=()\n"
        for stage in ("PREP", "TRAIN", "EVAL"):
            config += f"{stage}_TIME=00:10:00\n{stage}_CPUS=1\n{stage}_MEMORY=1G\n"
            config += f"{stage}_OPTIONS=()\n{stage}_EXTRA=()\n"
        profile.write_text(config)
        launcher = project / ("workflow/submit.sh" if case == "ml-authoring"
                              and condition == "with-skill" else "submit.sh")
        shellfiles = [p for p in project.rglob("*") if p.suffix in (".sh", ".sbatch")]
        syntax = {str(p.relative_to(project)): run(["bash", "-n", str(p)]).returncode
                  for p in shellfiles}
        submitted = run(["bash", str(launcher), str(profile)])
        captured = arguments()
        result = {"syntax": syntax, "submission_exit": submitted.returncode,
                  "submission_stdout": submitted.stdout, "submission_stderr": submitted.stderr,
                  "calls": captured}
        if submitted.returncode != 0:
            return result
        order = [(0, None), (1, 0), (1, 1), (1, 2), (2, None)] if case == "ml-authoring" else [(0, None), (1, None)]
        result["spooled_stages"] = [dict(stage=i, task=t, **execute(captured[i], t, True))
                                     for i, t in order]
        result["evaluation_files"] = len(list(output.rglob("evaluated.txt")))
        checkpoint = next(output.rglob("best.ckpt"))
        checkpoint.unlink()
        result["missing_checkpoint"] = execute(captured[-1])
        if case == "ml-authoring":
            if condition == "baseline":
                manifest = next(output.rglob("manifest.txt"))
                fields = manifest.read_text().splitlines()
                alternate_source = root / "alternate source"
                alternate_source.mkdir()
                fields[2] = str(alternate_source)
                changed = "\n".join(fields) + "\n"
            else:
                manifest = next(private.rglob("folds.txt"))
                changed = manifest.read_text().replace("fold-02", "fold-02 ")
            manifest.chmod(0o600)
            manifest.write_text(changed)
            result["changed_manifest"] = execute(captured[0])
        else:
            original = ROOT / "evals/fixtures/existing-workflow/jobs/train.sbatch"
            result["training_script_unchanged"] = (project / "jobs/train.sbatch").read_bytes() == original.read_bytes()
            result["training_log_preserved"] = any(arg == f"--output={output}/logs/train.out" for arg in captured[0])
        for call in calls.iterdir():
            call.unlink()
        if output.exists():
            shutil.rmtree(output)
        failed = run(["bash", str(launcher), str(profile)], {"FAKE_FAIL_AT": "2"})
        result["failure_second"] = {"exit": failed.returncode, "stdout": failed.stdout,
                                     "stderr": failed.stderr, "calls": len(arguments()),
                                     "accepted_id_in_message": "101" in failed.stderr}
        return result


if __name__ == "__main__":
    observations = {case: {condition: collect(case, condition)
                           for condition in ("baseline", "with-skill")}
                    for case in ("ml-authoring", "existing-workflow-open", "existing-workflow-preserve")}
    print(json.dumps(observations, indent=2))
