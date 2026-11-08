import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / "examples"


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.calls = self.root / "calls"
        self.calls.mkdir()
        self.output = self.root / "output"
        self.receipts = self.root / "private"
        self.manifest = self.root / "input.txt"
        self.manifest.write_text("first value\nsecond\n", encoding="utf-8")
        self.env = os.environ.copy()
        self.env.update(
            PATH=str(ROOT / "tests" / "stubs") + os.pathsep + self.env["PATH"],
            FAKE_SBATCH_DIR=str(self.calls),
            PYTHONDONTWRITEBYTECODE="1",
        )

    def run_script(self, script, *args, env=None):
        return subprocess.run(
            [str(script), *map(str, args)],
            text=True,
            capture_output=True,
            env=env or self.env,
        )

    def args(self, number):
        return (self.calls / f"{number}.args").read_bytes().decode().rstrip("\0").split("\0")

    def chain(self):
        return self.run_script(
            EXAMPLES / "submit-chain.sh", self.manifest, self.output,
            self.receipts, "2", EXAMPLES / "workflow.py", "--time=00:10:00",
        )

    def receipt(self):
        return next(self.receipts.iterdir())

    def run_job(self, number, task_id=None):
        args = self.args(number)
        index = next(i for i, arg in enumerate(args) if arg.endswith("-job.sh"))
        env = self.env.copy()
        if task_id is not None:
            env["SLURM_ARRAY_TASK_ID"] = str(task_id)
        return self.run_script(args[index], *args[index + 1:], env=env)

    def test_single_submission_arguments_and_job(self):
        result = self.run_script(
            EXAMPLES / "submit-single.sh", ROOT / "tests/dummy/job.py",
            self.receipts, "--time=00:01:00",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.args(1)[:2], ["--parsable", "--time=00:01:00"])
        self.assertEqual((self.receipt() / "single.txt").read_text(), "101\n")
        job = self.run_job(1)
        self.assertEqual(job.returncode, 0, job.stderr)
        self.assertIn("dummy job ran", job.stdout)

    def test_chain_wiring_and_outputs(self):
        self.env["FAKE_CLUSTER"] = ";invented-cluster"
        result = self.chain()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("--dependency=afterok:101", self.args(2))
        self.assertIn("--array=0-1%2", self.args(2))
        self.assertIn("--dependency=afterok:102", self.args(3))
        self.assertTrue(any("%A_%a" in arg for arg in self.args(2) if arg.startswith("--output=")))
        self.assertEqual((self.receipt() / "array.txt").read_text(), "102;invented-cluster\n")
        self.assertEqual(
            (self.receipt() / "manifest.sha256").read_text().strip(),
            hashlib.sha256(self.manifest.read_bytes()).hexdigest(),
        )
        self.assertEqual(self.run_job(1).returncode, 0)
        self.assertNotEqual(self.run_job(3).returncode, 0)
        for task_id in (0, 1):
            job = self.run_job(2, task_id)
            self.assertEqual(job.returncode, 0, job.stderr)
        bad = self.run_job(2, 2)
        self.assertNotEqual(bad.returncode, 0)
        self.assertEqual(self.run_job(3).returncode, 0)
        self.assertEqual([x["result"] for x in json.loads((self.output / "summary.json").read_text())], ["FIRST VALUE", "SECOND"])
        (self.output / "task-1.json").write_text("{}")
        self.assertNotEqual(self.run_job(3).returncode, 0)

    def test_failure_on_second_submission_preserves_first_receipt(self):
        self.env["FAKE_FAIL_AT"] = "2"
        result = self.chain()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Accepted jobs:", result.stderr)
        self.assertIn("101", result.stderr)
        self.assertNotIn("first value", result.stderr)
        self.assertEqual((self.receipt() / "accepted-jobs.tsv").stat().st_mode & 0o777, 0o600)
        self.assertEqual((self.receipt() / "prepare.txt").read_text(), "101\n")
        self.assertFalse((self.calls / "3.args").exists())

    def test_preview_never_invokes_scheduler(self):
        self.env["SLURM_WORKFLOW_PREVIEW"] = "1"
        result = self.chain()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("afterok:PLAN_prepare", result.stdout)
        self.assertIn("afterok:PLAN_array", result.stdout)
        self.assertIn("--array=0-1%2", result.stdout)
        self.assertEqual(list(self.calls.iterdir()), [])
        self.assertEqual((self.receipt() / "accepted-jobs.tsv").read_text(), "")

    def test_copied_workflow_runs_without_skill_checkout(self):
        project = self.root / "independent project"
        shutil.copytree(EXAMPLES, project)
        result = self.run_script(
            project / "submit-chain.sh", self.manifest, self.output,
            self.receipts, "2", project / "workflow.py",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        for number in (1, 2, 3):
            self.assertNotIn(str(EXAMPLES), " ".join(self.args(number)))
        self.assertEqual(self.run_job(1).returncode, 0)
        for task_id in (0, 1):
            self.assertEqual(self.run_job(2, task_id).returncode, 0)
        self.assertEqual(self.run_job(3).returncode, 0)

    def test_unparseable_response_stops_without_retry(self):
        self.env["FAKE_BAD_AT"] = "1"
        result = self.chain()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("may have been submitted", result.stderr)
        self.assertEqual((self.receipt() / "prepare.txt").read_text(), "unexpected response\n")
        self.assertFalse((self.calls / "2.args").exists())

    def test_manifest_validation_and_changed_snapshot(self):
        self.manifest.write_text("first\n\nsecond\n")
        self.assertNotEqual(self.chain().returncode, 0)
        self.assertFalse((self.calls / "1.args").exists())
        self.manifest.write_text("first\nsecond\n")
        self.assertEqual(self.chain().returncode, 0)
        # The invalid attempt also has a receipt; identify the submitted one.
        snapshot = next(p for p in self.receipts.iterdir() if (p / "prepare.txt").exists())
        (snapshot / "manifest.txt").chmod(0o600)
        (snapshot / "manifest.txt").write_text("changed\n")
        job = self.run_job(2, 0)
        self.assertNotEqual(job.returncode, 0)
        self.assertIn("hash mismatch", job.stderr)


if __name__ == "__main__":
    unittest.main()
