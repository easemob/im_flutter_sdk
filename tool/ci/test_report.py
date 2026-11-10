"""Reporting regressions; run: python3 -m unittest discover -s tool/ci -p 'test_*.py'."""

import contextlib
import io
import json
from pathlib import Path
import tempfile
import subprocess
import sys
import unittest

import report


def event(kind, **fields):
    return {"type": kind, **fields}


def begin(number, name):
    return event("testStart", test={"id": number, "suiteID": 0, "name": name}, time=0)


def end(number, result="success", **fields):
    return event("testDone", testID=number, result=result, time=25, **fields)


class ReportTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)

    def attempt(self, events, code=0, number=1):
        (self.directory / f"attempt-{number}.events.jsonl").write_text(
            "\n".join(json.dumps(item) for item in events))
        return report.parse_attempt(self.directory, {"number": number, "exitCode": code})

    def test_helpers_are_not_business_cases_and_errors_are_preserved(self):
        result = self.attempt([
            event("group", group={"parentID": None, "suiteID": 0, "testCount": 3}),
            begin(1, "loading example"), end(1, hidden=True),
            begin(2, "(setUpAll)"), end(2, hidden=True),
            begin(3, "FL-APP-001 works"), end(3),
            begin(4, "FL-MSG-007 fails"), event("error", testID=4, error="Expected FAIL, actual PROGRESS"), end(4, "failure"),
            begin(5, "FL-X-001 skipped"), end(5, skipped=True),
            begin(6, "(tearDownAll)"), event("error", testID=6, error="logout failed"), end(6, "error"),
            event("done", success=False),
        ], code=1)
        self.assertEqual(result["total"], 3)
        self.assertEqual(result["counts"], dict(passed=1, failed=1, skipped=1, incomplete=0, not_run=0))
        self.assertIn("PROGRESS", result["cases"][1]["errors"][0])
        self.assertTrue(any("logout failed" in fault for fault in result["faults"]))

    def test_interruption_keeps_unstarted_and_unfinished_separate(self):
        result = self.attempt([
            event("group", group={"parentID": None, "suiteID": 0, "testCount": 4}),
            begin(1, "FL-X-001 finished"), end(1), begin(2, "FL-X-002 interrupted"),
        ], code=143)
        self.assertEqual(result["counts"], dict(passed=1, failed=0, skipped=0, incomplete=1, not_run=2))

    def test_failure_before_discovery_has_unknown_total(self):
        result = self.attempt([begin(1, "loading example"), end(1, "error", hidden=True)], code=1)
        self.assertIsNone(result["total"])
        self.assertEqual(result["counts"]["failed"], 0)
        self.assertTrue(result["faults"])

    def test_nested_groups_do_not_double_count(self):
        result = self.attempt([
            event("group", group={"parentID": None, "suiteID": 0, "testCount": 2}),
            event("group", group={"parentID": 1, "suiteID": 0, "testCount": 2}),
            begin(1, "FL-X-001 done"), end(1), begin(2, "FL-X-002 done"), end(2), event("done", success=True),
        ])
        self.assertEqual(result["total"], 2)
        self.assertFalse(result["faults"])

    def test_retry_keeps_history_and_counts_only_final_attempt(self):
        self.attempt([begin(1, "loading example"), end(1, "error", hidden=True)], code=1)
        self.attempt([begin(1, "FL-X-001 recovered"), end(1), event("done", success=True)], number=2)
        report.write(self.directory / "run.json", {
            "target": "suite", "platform": "ios", "finishedAt": report.now(), "exitCode": 0,
            "attempts": [{"number": 1, "exitCode": 1}, {"number": 2, "exitCode": 0}],
        })
        with contextlib.redirect_stdout(io.StringIO()):
            report.render([self.directory], self.directory)
        result = report.read(self.directory / "report.json")
        self.assertEqual(result["knownTotal"], 1)
        self.assertEqual(result["counts"]["passed"], 1)
        self.assertEqual(len(result["batches"][0]["attempts"]), 2)
        self.assertTrue(result["batches"][0]["attempts"][0]["faults"])
        text = (self.directory / "summary.md").read_text()
        self.assertIn("（历史，保留失败）", text)
        self.assertIn("](attempt-2.events.jsonl)", text)

    def test_missing_batch_is_never_a_passing_report(self):
        with contextlib.redirect_stdout(io.StringIO()):
            report.render([self.directory / "not-started"], self.directory)
        result = report.read(self.directory / "report.json")
        self.assertEqual(result["status"], "attention")
        self.assertEqual(result["unknownTotalBatches"], 1)

    def test_truncated_json_is_a_report_fault(self):
        (self.directory / "attempt-1.events.jsonl").write_text('{"type":')
        result = report.parse_attempt(self.directory, {"number": 1, "exitCode": 1})
        self.assertTrue(any("格式错误" in item for item in result["faults"]))

    def test_started_attempt_can_be_rebuilt_after_hard_interruption(self):
        report.write(self.directory / "run.json", {"target": "suite", "platform": "android", "attempts": []})
        subprocess.run([sys.executable, report.__file__, "attempt", "--run", str(self.directory), "--number", "1"], check=True)
        self.attempt([begin(1, "FL-X-001 done"), end(1), begin(2, "FL-X-002 interrupted")])
        result = report.load_run(self.directory)
        self.assertEqual(result["counts"]["passed"], 1)
        self.assertEqual(result["counts"]["incomplete"], 1)
        self.assertTrue(result["faults"])

    def test_overlapping_batches_cannot_inflate_total(self):
        metadata = {"target": "suite", "platform": "android", "attempts": []}
        report.write(self.directory / "run.json", metadata)
        duplicate = self.directory / "duplicate"
        duplicate.mkdir()
        report.write(duplicate / "run.json", metadata)
        with self.assertRaisesRegex(ValueError, "重复合计"):
            report.render([self.directory, duplicate], self.directory / "merged")


if __name__ == "__main__":
    unittest.main()
