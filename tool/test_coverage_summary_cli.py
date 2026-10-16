"""CLI regression checks for Flutter LCOV coverage summaries."""
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).with_name("coverage_summary.py")


class CoverageSummaryCLITests(unittest.TestCase):
    def run_cli(self, data=None):
        with tempfile.TemporaryDirectory() as root:
            report = pathlib.Path(root) / "lcov.info"
            if data is not None:
                report.write_text(data, encoding="utf-8")
            return subprocess.run(
                [sys.executable, str(SCRIPT), str(report)],
                capture_output=True, text=True, check=False,
            )

    def test_reports_percentage_and_counts(self):
        result = self.run_cli("SF:lib/example.dart\nDA:1,1\nDA:2,0\nend_of_record\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("1/2 (50.0%)", result.stdout)

    def test_missing_report_fails_with_actionable_error(self):
        result = self.run_cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Invalid coverage report:", result.stderr)

    def test_empty_report_fails(self):
        result = self.run_cli("")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("no DA line records", result.stderr)


if __name__ == "__main__":
    unittest.main()
