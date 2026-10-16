"""Unit tests for LCOV line coverage aggregation."""
import pathlib
import tempfile
import unittest

from coverage_summary import summarize


class CoverageSummaryTests(unittest.TestCase):
    def summarize_content(self, content):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / "lcov.info"
            path.write_text(content, encoding="utf-8")
            return summarize(path)

    def test_counts_covered_and_uncovered_lines(self):
        self.assertEqual(self.summarize_content("SF:lib/a.dart\nDA:1,1\nDA:2,0\nDA:3,4\nend_of_record\n"), (2, 3))

    def test_empty_data_fails(self):
        with self.assertRaisesRegex(ValueError, "no DA line records"):
            self.summarize_content("TN:\nSF:lib/a.dart\nend_of_record\n")

    def test_malformed_entry_fails(self):
        with self.assertRaisesRegex(ValueError, "Malformed"):
            self.summarize_content("DA:broken\n")

    def test_invalid_hit_count_fails(self):
        with self.assertRaises(ValueError):
            self.summarize_content("DA:1,not-a-number\n")

    def test_negative_hit_count_fails(self):
        with self.assertRaisesRegex(ValueError, "Negative LCOV hit count"):
            self.summarize_content("DA:1,-1\n")

    def test_zero_or_negative_line_number_fails(self):
        for line in ("0", "-5"):
            with self.subTest(line=line), self.assertRaisesRegex(ValueError, "Invalid LCOV line number"):
                self.summarize_content(f"DA:{line},1\n")

    def test_extra_data_fields_fail(self):
        with self.assertRaisesRegex(ValueError, "Malformed LCOV DA entry"):
            self.summarize_content("DA:1,2,a,extra\n")

    def test_optional_checksum_supported(self):
        self.assertEqual(self.summarize_content("DA:1,2,checksum\n"), (1, 1))

    def test_multiple_files_are_aggregated(self):
        self.assertEqual(self.summarize_content("SF:lib/a.dart\nDA:1,0\nend_of_record\nSF:lib/b.dart\nDA:1,3\nend_of_record\n"), (1, 2))


if __name__ == "__main__":
    unittest.main()
