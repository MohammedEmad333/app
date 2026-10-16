"""Tests for child-facing learning content validator."""
import copy
import json
import pathlib
import unittest

from validate_content import validate

ROOT = pathlib.Path(__file__).resolve().parents[1]


class ContentValidationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.units = json.loads((ROOT / "assets/data/units.json").read_text(encoding="utf-8"))

    def test_real_course_is_valid(self):
        self.assertEqual(validate(self.units), [])

    def test_duplicate_question_identifier(self):
        units = copy.deepcopy(self.units)
        units[0]["lessons"][0]["questions"][1]["id"] = units[0]["lessons"][0]["questions"][0]["id"]
        self.assertTrue(any("duplicate id" in x for x in validate(units)))

    def test_wrong_correct_option(self):
        units = copy.deepcopy(self.units)
        units[0]["lessons"][0]["questions"][0]["correctOptionId"] = "missing"
        self.assertTrue(any("correctOptionId" in x for x in validate(units)))

    def test_unbuildable_sentence(self):
        units = copy.deepcopy(self.units)
        units[0]["lessons"][0]["questions"][1]["wordBank"] = ["other"]
        self.assertTrue(any("cannot be formed" in x for x in validate(units)))

    def test_unknown_question_type(self):
        units = copy.deepcopy(self.units)
        units[0]["lessons"][0]["questions"][0]["type"] = "unsupported"
        self.assertTrue(any("unknown question type" in x for x in validate(units)))


if __name__ == "__main__":
    unittest.main()
